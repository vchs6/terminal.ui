#!/usr/bin/env python3
"""One real Application.run caret/opaque-layer vector; no terminal emulator.
The native consumer never writes ANSI. This recorder supplies a controlled
mode25 reply on a plain PTY, observes literal paint spans and then sends a
separate read-only query key, after the preceding native write transaction.
"""
import argparse,datetime,hashlib,importlib.util,json,os,re,signal,subprocess,time
from pathlib import Path
spec=importlib.util.spec_from_file_location('bpty',Path(__file__).resolve().parents[1]/'interaction_b/pty_driver.py')
b=importlib.util.module_from_spec(spec);spec.loader.exec_module(b)
QUERY=b'\x1b[?25$p';CUP_CARET=b'\x1b[2;4H'

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def fields(text):
    result=dict(line.split('=',1) for line in text.splitlines() if '=' in line)
    if len(result)!=9:raise ValueError('incomplete state file')
    return result

def run(binary,out,reply):
    binary=binary.resolve();assert binary.is_file() and os.access(binary,os.X_OK)
    out.mkdir(parents=True,exist_ok=False);master,slave=b.pty.openpty();b.resize(slave,8,3)
    before=b.attributes(slave);raw=bytearray();sent=bytearray();events=[];states={};child=None
    metadata={'utc_start':utc(),'cwd':str(Path.cwd()),'binary':str(binary),'binary_pre_sha256':sha(binary),'reply':reply,'size':[8,3],'before_termios':before,'events':events,'states':states}
    def pump():raw.extend(b.drain(master,.01))
    def wait(predicate,label):
        until=time.monotonic()+8
        while time.monotonic()<until:
            pump()
            if predicate():return
            if child.poll() is not None:raise AssertionError('native exit before '+label)
        raise AssertionError('missing native observation '+label)
    def send(data):
        events.append({'input_hex':data.hex(),'wire_offset_before':len(raw),'monotonic_ns':time.monotonic_ns()});sent.extend(data);os.write(master,data)
    def span(start,text):
        # Literal backend-independent SGR may separate CUP and the changed span.
        return re.search(rb'\x1b\[2;3H(?:\x1b\[[0-9;]*m)*'+re.escape(text),bytes(raw[start:]))
    def query(stage):
        path=out/('state-'+stage)
        if path.exists():path.unlink() # Require this query's acknowledgement, including Pending retries.
        send(b's');answer={}
        def complete():
            nonlocal answer
            if not path.is_file():return False
            try:answer=fields(path.read_text())
            except (ValueError,UnicodeDecodeError):return False
            return answer['stage']==stage
        wait(complete,'completed-frame query '+stage);pump();states[stage]=answer
        events.append({'query_fence':stage,'wire_offset_after':len(raw),'monotonic_ns':time.monotonic_ns()})
        assert answer['focusBase']=='true'
        hidden=stage=='covered'
        assert answer['logicalVisible']==str(not hidden).lower()
        assert [answer['owner'],answer['x'],answer['y']]==(['None','0','0'] if hidden else ['base','3','1'])
        assert answer['handleOpen']==str(hidden).lower()
        return answer
    try:
        env=dict(os.environ,CJTUI_OVERLAY_NATIVE_CARET='opaque',CJTUI_OVERLAY_CARET_OUTPUT=str(out))
        env.setdefault('TERM','xterm-256color')
        with (out/'stderr').open('wb') as err:
            metadata['argv']=[str(binary)];metadata['env']={'CJTUI_OVERLAY_NATIVE_CARET':'opaque','CJTUI_OVERLAY_CARET_OUTPUT':str(out),'TERM':env['TERM']}
            child=subprocess.Popen([str(binary)],stdin=slave,stdout=slave,stderr=err,env=env,preexec_fn=lambda:b.controlling_terminal(slave))
            metadata['readiness']=b.wait_ready(child,master,slave,raw,(b'ABCDEFGH',b'ijklmnop',b'QRSTUVWX'))
            if reply!='none':
                start=len(raw);send(b'\x1b[?25;'+reply.encode()+b'$y')
                wait(lambda:CUP_CARET in raw[start:] and b'\x1b[?25h' in raw[start:],'known base caret CUP/show')
                base=query('base')
            else:
                base=query('base')
                until=time.monotonic()+3
                while base['cursorStatus'] in ('pending','not-probed') and time.monotonic()<until:base=query('base')
            status=base['cursorStatus'];assert status in ('original-visible','original-hidden','unknown-timeout','unknown-clock'),status
            assert base['savedCursorStatus']==status
            start=len(raw);send(b'o')
            wait(lambda:span(start,b'   ') is not None,'opaque row1 columns2..4 actual paint')
            if status.startswith('original-'):wait(lambda:b'\x1b[?25l' in raw[start:],'known covered hide')
            events.append({'paint_fence':'covered','wire_start':start,'wire_observed_end':len(raw),'expected_changed_span':'row1 col2: three spaces'})
            cover=query('covered');assert cover['cursorStatus']==cover['savedCursorStatus']==status
            if status.startswith('original-'):assert re.findall(rb'\x1b\[\?25([hl])',bytes(raw))[-1:]==[b'l']
            start=len(raw);send(b'c')
            wait(lambda:span(start,b'klm') is not None,'restored row1 columns2..4 actual paint')
            if status.startswith('original-'):wait(lambda:CUP_CARET in raw[start:] and b'\x1b[?25h' in raw[start:],'known restored caret CUP/show')
            events.append({'paint_fence':'restored','wire_start':start,'wire_observed_end':len(raw),'expected_changed_span':'row1 col2: klm'})
            restored=query('restored');assert restored['cursorStatus']==restored['savedCursorStatus']==status
            send(b'q');until=time.monotonic()+8
            while child.poll() is None and time.monotonic()<until:pump()
            assert child.poll() is not None,'native exit deadline'
            pump();after=b.attributes(slave);metadata.update(product_exit=child.returncode,after_termios=after)
            assert child.returncode==0 and before==after,metadata
            assert (out/'returned').read_text()==f'exit=0\ncleanup=1\nresources=0/0/0/0\ncursorStatus={status}\n'
            assert bytes(raw).count(QUERY)==1
            modes=re.findall(rb'\x1b\[\?25([hlsr])',bytes(raw))
            if status.startswith('unknown-'):
                assert not modes,'Unknown must never emit25h/l/s/r'
                classification='logical coverage PASS; physical visibility unmanaged/insufficient; original mode unchanged by framework'
            else:
                assert modes[-1:]==([b'h'] if status=='original-visible' else [b'l']),'original mode restoration wire'
                classification='logical and known-mode hide/show/CUP wire PASS; controlled PTY is not a real-host pixel claim'
            metadata['classification']=classification;metadata['result']='PASS'
    except BaseException as error:
        metadata['result']='FAIL';metadata['error']=repr(error);raise
    finally:
        if child and child.poll() is None:os.killpg(child.pid,signal.SIGKILL);child.wait();metadata['forced']=True
        if child:metadata.setdefault('product_exit',child.returncode)
        raw.extend(b.drain(master,.01));metadata.setdefault('after_termios',b.attributes(slave));metadata.update(utc_end=utc(),binary_post_sha256=sha(binary))
        assert metadata['binary_pre_sha256']==metadata['binary_post_sha256']
        (out/'output.raw').write_bytes(raw);(out/'input.raw').write_bytes(sent)
        (out/'metadata.json').write_text(json.dumps(metadata,indent=2)+'\n');os.close(master);os.close(slave)
    print('PASS C03 native caret opaque vector; actual exit0; exact termios restored; '+metadata['classification'])

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--binary',required=True,type=Path);p.add_argument('--output',required=True,type=Path);p.add_argument('--cursor-reply',choices=['1','2','none'],default='1',help='controlled plain-PTY report only; real-host collectors use actual native reply and no synthetic report')
    a=p.parse_args();run(a.binary,a.output.resolve(),a.cursor_reply)
