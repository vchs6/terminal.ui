"""One frozen nativecaret vector, real XTerm/VTE responses, original PNG/cells."""
import argparse,hashlib,json,os,pathlib,re,shlex,signal,subprocess,time
from xtest import Keyboard
from xsize import hints,resize
from host_supervisor import utc,publish
from trace_bytes import extract
from caret_common import fields,judge_state,judge_wire,ROWS
from h01_gui import wait
def one(binary,out,host,display):
    out.mkdir(parents=True,exist_ok=False);env=os.environ.copy()
    for k in ['XAUTHORITY','DBUS_SESSION_BUS_ADDRESS','SESSION_MANAGER','GTK_MODULES','CJTUI_OVERLAY_NATIVE']:env.pop(k,None)
    home=out/'home';home.mkdir();env.update(DISPLAY=display,HOME=str(home),XDG_CONFIG_HOME=str(home/'config'),XDG_CACHE_HOME=str(home/'cache'),LANG='C.UTF-8',LC_ALL='C.UTF-8');os.environ['DISPLAY']=display
    keyboard=Keyboard();title='TASK111 nativecaret '+host;child=['python3',str(pathlib.Path(__file__).with_name('host_supervisor.py')),str(binary),str(out),'caret']
    if host=='xterm':cmd=['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-geometry','8x3+20+20','-T',title,'-fa','DejaVu Sans Mono','-fs','24','-xrm','XTerm*cursorBlink: false','-xrm','XTerm*printerCommand: /bin/cat >> '+str(out/'native-grid.ansi'),'-xrm','XTerm*printAttributes: 2','-xrm','XTerm*VT100.translations: #override <Key>F6: print()','-e',*child]
    else:
        env.update(GTK_MODULES='/workspace/work/viewport-execution/tools/vte-native-fullrows-module.so',VTE_NATIVE_CAPTURE_DIR=str(out));cmd=['dbus-run-session','--','xfce4-terminal','--disable-server','--hide-menubar','--geometry=8x3+20+20','--title='+title,'--command='+shlex.join(child)]
    binhash=hashlib.sha256(binary.read_bytes()).hexdigest();publish(out/'launch.json',dict(argv=cmd,cwd=os.getcwd(),utc=utc(),binary=str(binary),binary_sha256=binhash,env={k:env[k] for k in ['DISPLAY','HOME','XDG_CONFIG_HOME','XDG_CACHE_HOME','GTK_MODULES','VTE_NATIVE_CAPTURE_DIR'] if k in env},capability_source='Actual host replies, no controlled response injection'))
    hp=subprocess.Popen(cmd,env=env,stdout=(out/'host.stdout').open('wb'),stderr=(out/'host.stderr').open('wb'),start_new_session=True);events=[];states={};stages=[]
    def raw():return extract((out/'product.strace').read_text(errors='replace'))[0] if (out/'product.strace').exists() else b''
    def key(name):keyboard.chord(name);events.append(dict(key=name,utc=utc(),wire_offset=len(raw())))
    try:
        wait(lambda:(out/'terminal-before.json').exists(),hp);before=json.loads((out/'terminal-before.json').read_text());assert[before['cols'],before['rows']]==[8,3]
        tree=subprocess.check_output(['xwininfo','-display',display,'-root','-tree'],env=env,text=True);(out/'window-tree.txt').write_text(tree);win=next(x.split()[0] for x in tree.splitlines() if title in x);keyboard.focus(win);hi=hints(keyboard,win);publish(out/'window-hints.json',hi);resize(keyboard,win,8,3,hi)
        if host=='vte':
            table=subprocess.check_output(['ps','-eo','pid,args'],text=True);mapped=[]
            for line in table.splitlines():
                parts=line.strip().split(None,1)
                if len(parts)==2 and parts[1].startswith('xfce4-terminal ') and title in parts[1]:
                    maps=pathlib.Path('/proc',parts[0],'maps').read_text();loaded=sorted(set(x.split()[-1] for x in maps.splitlines() if 'libvte-' in x));assert loaded;mapped.append(dict(pid=int(parts[0]),loaded_vte=loaded,sha256={x:hashlib.sha256(pathlib.Path(x).read_bytes()).hexdigest() for x in loaded}))
            assert len(mapped)==1;publish(out/'actual-host-mapping.json',mapped)
        def native(ix,attempt):
            if host=='vte':
                (out/f'native-{ix}-meta.json').unlink(missing_ok=True);temp=out/'native-request.next';temp.write_text(str(ix));temp.replace(out/'native-request');wait(lambda:(out/f'native-{ix}-meta.json').exists() and not(out/'native-request').exists(),hp);meta=json.loads((out/f'native-{ix}-meta.json').read_text());assert[meta['cols'],meta['rows']]==[8,3];return [(out/f'native-{ix}-row-{n}.txt').read_text().rstrip('\n').ljust(8) for n in range(3)]
            p=out/'native-grid.ansi';offset=p.stat().st_size if p.exists() else 0;key('F6');wait(lambda:p.exists() and p.stat().st_size>offset,hp);data=p.read_bytes()[offset:];(out/f'native-{ix}-attempt-{attempt}.ansi').write_bytes(data);return[x.ljust(8) for x in re.sub(r'\x1b(?:\[[0-?]*[ -/]*[@-~]|#[0-9])','',data.decode()).splitlines()]
        def capture(stage):
            ix=len(stages);until=time.monotonic()+12;attempt=0
            while True:
                rows=native(ix,attempt);publish(out/f'{stage}-attempt-{attempt}.json',dict(utc=utc(),rows=rows,expected=ROWS.get(stage)))
                if stage not in ROWS or rows==ROWS[stage]:break
                subprocess.run(['import','-display',display,'-window',win,str(out/f'{stage}-transient-{attempt}.png')],env=env,check=True)
                if time.monotonic()>until:raise RuntimeError('native grid not matching frozen stage '+stage)
                attempt+=1
            # Two original frames distinguish native blink phase without drawing pixels.
            for frame in range(2):subprocess.run(['import','-display',display,'-window',win,str(out/f'{stage}-{frame}.png')],env=env,check=True);time.sleep(.15)
            stages.append(dict(stage=stage,utc=utc(),rows=rows,wire_offset=len(raw()),native_index=ix))
        def query(stage,status=None):
            path=out/('state-'+stage);path.unlink(missing_ok=True);key('s');answer={}
            def complete():
                nonlocal answer
                if not path.exists():return False
                try:answer=fields(path.read_text())
                except(ValueError,UnicodeDecodeError):return False
                return answer['stage']==stage
            wait(complete,hp);judge_state(stage,answer,status);states[stage]=answer;publish(out/'states.json',states);return answer
        wait(lambda:all(x in raw() for x in [b'ABCDEFGH',b'ijklmnop',b'QRSTUVWX']),hp);capture('base');base=query('base');until=time.monotonic()+3
        while base['cursorStatus'] in ['pending','not-probed'] and time.monotonic()<until:base=query('base')
        status=base['cursorStatus'];assert status==base['savedCursorStatus'] and status in ['original-visible','original-hidden','unknown-timeout','unknown-clock']
        start=len(raw());key('o');wait(lambda:re.search(rb'\x1b\[2;1H(?:\x1b\[[0-9;]*m)*ij   nop',raw()[start:]),hp);capture('covered');query('covered',status)
        if status.startswith('original-'):assert re.findall(rb'\x1b\[\?25([hl])',raw())[-1:]==[b'l']
        start=len(raw());key('c');wait(lambda:re.search(rb'\x1b\[2;1H(?:\x1b\[[0-9;]*m)*ijklmnop',raw()[start:]),hp);capture('restored');query('restored',status)
        if status.startswith('original-'):assert b'\x1b[2;4H' in raw()[start:] and re.findall(rb'\x1b\[\?25([hl])',raw())[-1:]==[b'h']
        key('q');wait(lambda:(out/'terminal-after.json').exists(),hp);after=json.loads((out/'terminal-after.json').read_text());assert after['product_exit']==0 and after['termios_equal'] and after['original_reply']==after['restored_reply']
        assert(out/'returned').read_text()==f'exit=0\ncleanup=1\nresources=0/0/0/0\ncursorStatus={status}\n';capture('exit-restored');(out/'exit-release').write_text('captured');hostexit=hp.wait(timeout=15);assert hostexit==0
        text=(out/'product.strace').read_text();output,ostats=extract(text);stdin,istats=extract(text,0,'read');(out/'product-stdout.raw').write_bytes(output);(out/'product-stdin.raw').write_bytes(stdin);classification=judge_wire(output,status);assert binhash==hashlib.sha256(binary.read_bytes()).hexdigest();publish(out/'result.json',dict(host=host,product_exit=after['product_exit'],host_exit=hostexit,termios_equal=True,cursorStatus=status,classification=classification,binary_sha256=binhash,wire_stats=dict(output=ostats,input=istats),utc=utc()))
    except BaseException as e:publish(out/'failure.json',dict(error=repr(e),utc=utc()));raise
    finally:
        publish(out/'events.json',events);publish(out/'stages.json',stages)
        if hp.poll() is None:os.killpg(hp.pid,signal.SIGTERM);hp.wait(timeout=10)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--go',type=pathlib.Path,required=True);p.add_argument('--binary',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--host',choices=['xterm','vte']);p.add_argument('--display',default=':199');a=p.parse_args();assert a.go.is_file()
    for host in ([a.host] if a.host else ['xterm','vte']):one(a.binary.resolve(),a.output.resolve()/host,host,a.display)
