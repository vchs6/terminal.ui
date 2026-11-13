#!/usr/bin/env python3
"""C consumer handshake/termios recorder using the existing B PTY primitives.
No terminal emulation or product stub. Real-host PNG evidence remains separate.
"""
import argparse, importlib.util, json, os, signal, subprocess, tempfile, termios, time
from pathlib import Path
spec=importlib.util.spec_from_file_location('bpty',Path(__file__).resolve().parents[1]/'interaction_b/pty_driver.py')
b=importlib.util.module_from_spec(spec);spec.loader.exec_module(b)

def wait_file(child,path,timeout=8):
    until=time.monotonic()+timeout
    while time.monotonic()<until:
        if path.is_file():return path.read_text()
        if child.poll() is not None:raise RuntimeError('product exited before acknowledgement '+path.name)
        time.sleep(.005)
    raise RuntimeError('missing acknowledged state '+str(path))

def judge(result,expected_trace,expected_exit=0):
    if result['product_exit']!=expected_exit:raise RuntimeError('product exit '+str(result['product_exit']))
    if result['before_termios']!=result['after_termios']:raise RuntimeError('termios not restored')
    if result['trace']!=expected_trace:raise RuntimeError('domain trace mismatch '+result['trace'])
    if result.get('cleanup')!=['once','once','once']:raise RuntimeError('missing/duplicate cleanup')

def validate_binary(binary):
    if not binary.is_file() or not os.access(binary,os.X_OK):raise RuntimeError('actual executable missing/non-executable')

def self_test():
    good=dict(product_exit=0,before_termios=[1],after_termios=[1],trace='Cc;Tc;Tb;Cb;Td;Ca;|0|0',cleanup=['once']*3)
    judge(good,good['trace'])
    for field,value in [('product_exit',9),('after_termios',[2]),('trace','Tc;Cc;'),('cleanup',['once'])]:
        bad=dict(good);bad[field]=value
        try:judge(bad,good['trace'])
        except RuntimeError:pass
        else:raise RuntimeError('negative control accepted '+field)
    for name in ['missing','timeout']:
        class Ended:
            def poll(self):return 9 if name=='missing' else None
        try:wait_file(Ended(),Path('/nonexistent/cjtui-overlay-ack'),.01)
        except RuntimeError:pass
        else:raise RuntimeError('negative acknowledgement accepted')
    with tempfile.TemporaryDirectory() as directory:
        p=Path(directory)/'absent'
        for present in [False,True]:
            if present:p.write_bytes(b'')
            try:validate_binary(p)
            except RuntimeError:pass
            else:raise RuntimeError('missing/non-executable binary accepted')
    print('TOOLS_ONLY: missing/non-executable binary, trace/order, exit9, termios, cleanup, missing ack and timeout controls reject; no C execution')

def run(binary,destination,mode):
    validate_binary(binary)
    destination.mkdir(parents=True,exist_ok=True);master,slave=b.pty.openpty();b.resize(slave,40,10)
    before=b.attributes(slave);raw=bytearray();sent=bytearray();child=None
    env=dict(os.environ,CJTUI_OVERLAY_NATIVE=mode,CJTUI_OVERLAY_OUTPUT=str(destination),TERM='xterm-256color')
    try:
        with (destination/'stderr').open('wb') as err:
            child=subprocess.Popen([str(binary)],stdin=slave,stdout=slave,stderr=err,env=env,preexec_fn=lambda:b.controlling_terminal(slave))
            ready=b.wait_ready(child,master,slave,raw,(b'BASE-OVERLAY-READY',))
            def send(data):sent.extend(data);os.write(master,data)
            # Genuine query reply, never a replacement writer/clock.
            send(b'\x1b[?25;1$y');send(b'm');wait_file(child,destination/'M')
            send(b'p');wait_file(child,destination/'P');send(b'c');wait_file(child,destination/'C')
            send(b'x');trace=wait_file(child,destination/'trace')
            if mode=='prevent':
                send(b'\x03');assert wait_file(child,destination/'prevent')=='active'
                if child.poll() is not None:raise RuntimeError('prevented interrupt exited')
                send(b'q')
            elif mode=='escape':
                send(b'\x1b');wait_file(child,destination/'C-clean');send(b's')
                assert wait_file(child,destination/'escape')=='Escape|true|true';send(b'q')
            elif mode=='signal':os.kill(child.pid,signal.SIGINT)
            elif mode=='callback-error':send(b'!')
            else:send(b'\x03')
            until=time.monotonic()+10
            while child.poll() is None and time.monotonic()<until:raw.extend(b.drain(master,.02))
            if child.poll() is None:raise RuntimeError('actual product did not exit within bound')
            raw.extend(b.drain(master,.03));after=b.attributes(slave)
            result=dict(mode=mode,readiness=ready,product_exit=child.returncode,before_termios=before,after_termios=after,trace=trace,cleanup=[wait_file(child,destination/(n+'-clean')) for n in ['C','P','M']])
            (destination/'metadata.json').write_text(json.dumps(result,indent=2)+'\n')
            judge(result,'Cc;Tc;Tb;Cb;Td;Ca;|0|0')
    finally:
        if child and child.poll() is None:child.kill();child.wait()
        (destination/'output.raw').write_bytes(raw);(destination/'input.raw').write_bytes(sent)
        os.close(master);os.close(slave)

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--self-test',action='store_true');parser.add_argument('--binary',type=Path);parser.add_argument('--output',type=Path);args=parser.parse_args()
    if args.self_test:self_test()
    else:
        for mode in ['interrupt','prevent','escape','signal','callback-error']:run(args.binary.resolve(),args.output/mode,mode)
