"""H01 five frozen scenarios on XTerm398/VTE; requires explicit GO record.
Native cell capture is evidence, not a replacement for frozen headless goldens.
"""
import argparse, hashlib, json, os, pathlib, re, shlex, signal, subprocess, time
from xtest import Keyboard
from xsize import hints, resize
from trace_bytes import extract
from host_supervisor import utc,publish
from h01_expected import judge_rows,expected_rows
MODES=['interrupt','prevent','escape','signal','callback-error']
TRACE='Cc;Tc;Tb;Cb;Td;Ca;|0|0'
def wait(fn,child,seconds=12):
    end=time.monotonic()+seconds
    while time.monotonic()<end:
        value=fn()
        if value:return value
        if child.poll() is not None:raise RuntimeError('host exited before barrier')
        time.sleep(.01)
    raise TimeoutError('acknowledgement barrier')
def one(binary,out,host,mode,display):
    out.mkdir(parents=True,exist_ok=False);env=os.environ.copy()
    for key in ['XAUTHORITY','DBUS_SESSION_BUS_ADDRESS','SESSION_MANAGER','GTK_MODULES']:env.pop(key,None)
    home=out/'home';home.mkdir();env.update(DISPLAY=display,HOME=str(home),XDG_CONFIG_HOME=str(home/'config'),XDG_CACHE_HOME=str(home/'cache'),LANG='C.UTF-8',LC_ALL='C.UTF-8')
    os.environ['DISPLAY']=display;keyboard=Keyboard();title='TASK111 '+host+' '+mode
    child=['python3',str(pathlib.Path(__file__).with_name('host_supervisor.py')),str(binary),str(out),mode]
    if host=='xterm':
        cmd=['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-geometry','40x10+20+20','-T',title,'-fa','DejaVu Sans Mono','-fs','16','-xrm','XTerm*printerCommand: /bin/cat >> '+str(out/'native-grid.ansi'),'-xrm','XTerm*printAttributes: 2','-xrm','XTerm*VT100.translations: #override <Key>F6: print()','-e',*child]
    else:
        env.update(GTK_MODULES='/workspace/work/viewport-execution/tools/vte-native-fullrows-module.so',VTE_NATIVE_CAPTURE_DIR=str(out))
        cmd=['dbus-run-session','--','xfce4-terminal','--disable-server','--hide-menubar','--geometry=40x10+20+20','--title='+title,'--command='+shlex.join(child)]
    publish(out/'launch.json',dict(argv=cmd,cwd=os.getcwd(),utc=utc(),binary=str(binary),binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),env={k:env[k] for k in ['DISPLAY','HOME','XDG_CONFIG_HOME','XDG_CACHE_HOME','GTK_MODULES','VTE_NATIVE_CAPTURE_DIR'] if k in env}))
    hp=subprocess.Popen(cmd,env=env,stdout=(out/'host.stdout').open('wb'),stderr=(out/'host.stderr').open('wb'),start_new_session=True);events=[];stages=[]
    def ack(name,expected):return wait(lambda:(out/name).is_file() and (out/name).read_text()==expected,hp)
    def key(*keys):keyboard.chord(*keys);events.append(dict(keys=list(keys),utc=utc()))
    def raw():return extract((out/'product.strace').read_text(errors='replace'))[0] if (out/'product.strace').exists() else b''
    try:
        wait(lambda:(out/'terminal-before.json').exists(),hp)
        tree=subprocess.check_output(['xwininfo','-display',display,'-root','-tree'],env=env,text=True);(out/'window-tree.txt').write_text(tree)
        win=next(line.split()[0] for line in tree.splitlines() if title in line);keyboard.focus(win)
        mapped=[]
        process_table=subprocess.check_output(['ps','-eo','pid,args'],text=True)
        for line in process_table.splitlines():
            fields=line.strip().split(None,1)
            if len(fields)!=2 or title not in fields[1]:continue
            if host=='vte' and fields[1].startswith('xfce4-terminal '):
                pid=int(fields[0]);maps=pathlib.Path('/proc',str(pid),'maps').read_text();libraries=sorted(set(x.split()[-1] for x in maps.splitlines() if 'libvte-' in x));assert libraries
                mapped.append(dict(pid=pid,argv=fields[1],loaded_vte=libraries,loaded_hashes={v:hashlib.sha256(pathlib.Path(v).read_bytes()).hexdigest() for v in libraries}))
        if host=='vte':assert len(mapped)==1
        publish(out/'actual-host-mapping.json',dict(host=host,utc=utc(),mapped=mapped,frontend_binary=cmd[0] if host=='xterm' else '/usr/bin/xfce4-terminal'))
        hi=hints(keyboard,win);publish(out/'window-hints.json',hi)
        # Physical window geometry, no fabricated TIOCSWINSZ on the slave.
        pixels=resize(keyboard,win,40,10,hi);publish(out/'requested-window-size.json',dict(cols=40,rows=10,pixels=pixels))
        wait(lambda:b'BASE-OVERLAY-READY' in raw(),hp)
        before=json.loads((out/'terminal-before.json').read_text());assert [before['cols'],before['rows']]==[40,10]
        def capture(name,expected=None):
            ix=len(stages)
            until=time.monotonic()+12;attempt=0
            while True:
                if host=='vte':
                    (out/f'native-{ix}-meta.json').unlink(missing_ok=True)
                    temp=out/'native-request.next';temp.write_text(str(ix));temp.replace(out/'native-request')
                    wait(lambda:(out/f'native-{ix}-meta.json').exists() and not(out/'native-request').exists(),hp)
                    meta=json.loads((out/f'native-{ix}-meta.json').read_text());assert [meta['cols'],meta['rows']]==[40,10]
                    native=[(out/f'native-{ix}-row-{n}.txt').read_text() for n in range(meta['rows'])]
                else:
                    path=out/'native-grid.ansi';offset=path.stat().st_size if path.exists() else 0;key('F6');wait(lambda:path.exists() and path.stat().st_size>offset,hp)
                    data=path.read_bytes()[offset:];(out/f'native-{ix}-attempt-{attempt}.ansi').write_bytes(data);native=re.sub(r'\x1b(?:\[[0-?]*[ -/]*[@-~]|#[0-9])','',data.decode()).splitlines()
                publish(out/f'native-{ix}-attempt-{attempt}.json',dict(utc=utc(),native=native))
                try:
                    if expected is not None and expected not in ''.join(native):raise RuntimeError('native source label not committed: '+expected)
                    judge_rows(name,native)
                    break
                except RuntimeError:
                    subprocess.run(['import','-display',display,'-window',win,str(out/(name+f'-transient-{attempt}.png'))],env=env,check=True)
                    if time.monotonic()>until:raise
                    attempt+=1
            subprocess.run(['import','-display',display,'-window',win,str(out/(name+'.png'))],env=env,check=True)
            stages.append(dict(name=name,utc=utc(),native_index=ix,native_text=native,expected_rows=expected_rows(name),note='Native evidence; source labels + design Center geometry; frozen headless golden remains independent'))
        capture('base','BASE-OVERLAY-READY');key('m');ack('M','mounted');key('p');ack('P','mounted');key('c');ack('C','mounted');key('x');ack('trace',TRACE);capture('confirmation','CONFIRM')
        if mode=='prevent':key('Control_L','c');ack('prevent','active');assert not (out/'terminal-after.json').exists();capture('prevented');key('q')
        elif mode=='escape':key('Escape');ack('C-clean','once');key('s');ack('escape','Escape|true|true');capture('escaped-to-popup');key('q')
        elif mode=='signal':(out/'signal-request').write_text('SIGINT');ack('C-clean','once')
        elif mode=='callback-error':key('Shift_L','1')
        else:key('Control_L','c')
        # Actual binary/termios result is published before host launcher exit.
        wait(lambda:(out/'terminal-after.json').exists(),hp)
        after=json.loads((out/'terminal-after.json').read_text());assert after['product_exit']==0 and after['termios_equal'];assert after['original_reply']==after['restored_reply']
        for n in ['C','P','M']:assert (out/(n+'-clean')).read_text()=='once'
        capture('restored-session');(out/'exit-release').write_text('captured')
        hostexit=hp.wait(timeout=15);assert hostexit==0
        text=(out/'product.strace').read_text();output,stats=extract(text);(out/'product-stdout.raw').write_bytes(output);input_bytes,input_stats=extract(text,0,'read');(out/'product-stdin.raw').write_bytes(input_bytes);publish(out/'wire-extraction.json',dict(output=stats,input=input_stats))
        publish(out/'result.json',dict(mode=mode,host=host,host_exit=hostexit,product_exit=after['product_exit'],termios_equal=True,trace=TRACE,cleanup=['once']*3,utc=utc()))
    except BaseException as e:publish(out/'failure.json',dict(error=repr(e),utc=utc()));raise
    finally:
        publish(out/'events.json',events);publish(out/'stages.json',stages)
        if hp.poll() is None:os.killpg(hp.pid,signal.SIGTERM);hp.wait(timeout=10)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--go',type=pathlib.Path,required=True);p.add_argument('--binary',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--display',default=':199');p.add_argument('--host',choices=['xterm','vte']);p.add_argument('--mode',choices=MODES);a=p.parse_args()
    assert a.go.is_file(), 'Formal GO record required';binary=a.binary.resolve();assert binary.is_file() and os.access(binary,os.X_OK)
    for host in ([a.host] if a.host else ['xterm','vte']):
        for mode in ([a.mode] if a.mode else MODES):one(binary,a.output.resolve()/(host+'-'+mode),host,mode,a.display)
