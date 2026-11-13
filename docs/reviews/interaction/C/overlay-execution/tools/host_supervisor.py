"""Run only after GO, inside the real host PTY. No synthetic host replies."""
import argparse, datetime, json, os, pathlib, re, select, signal, subprocess, termios, threading, time, tty
def utc(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def publish(path,value):
    tmp=path.with_suffix('.next');tmp.write_text(json.dumps(value,indent=2)+'\n');tmp.replace(path)
def termios_json(value):
    return [*value[:6],[dict(bytes_hex=x.hex()) if isinstance(x,bytes) else dict(integer=x) for x in value[6]]]
def query():
    before=termios.tcgetattr(0);raw=b''
    try:
        tty.setraw(0);os.write(1,b'\x1b[?25$p');until=time.monotonic()+1
        while not raw.endswith(b'$y') and time.monotonic()<until:
            ready,_,_=select.select([0],[],[],max(0,until-time.monotonic()))
            if ready:raw+=os.read(0,128)
    finally:termios.tcsetattr(0,termios.TCSANOW,before)
    return raw
def exact_pid(root,binary):
    pending=[root]
    while pending:
        pid=pending.pop()
        try:
            if pathlib.Path('/proc',str(pid),'exe').resolve()==binary:return pid
            pending.extend(map(int,pathlib.Path('/proc',str(pid),'task',str(pid),'children').read_text().split()))
        except (FileNotFoundError,ProcessLookupError):pass
    return None
def traced_pid(path,binary):
    if not path.exists():return None
    encoded=''.join('\\x%02x'%x for x in str(binary).encode())
    match=re.search(r'^(\d+)\s+execve\("'+re.escape(encoded)+r'",.* = 0$',path.read_text(errors='replace'),re.M)
    return int(match[1]) if match else None
def run(binary,out,mode):
    binary=binary.resolve();out=out.resolve()
    assert binary.is_file() and os.access(binary,os.X_OK)
    os.write(1,b'\x1b[?25h');original=query();(out/'host-original-reply.bin').write_bytes(original)
    before=termios.tcgetattr(0);grid=os.get_terminal_size(0)
    publish(out/'terminal-before.json',dict(utc=utc(),termios=termios_json(before),cols=grid.columns,rows=grid.lines,tty=os.ttyname(0),TERM=os.getenv('TERM'),COLORTERM=os.getenv('COLORTERM'),original_reply=original.hex()))
    env=dict(os.environ,CJTUI_OVERLAY_NATIVE=mode,CJTUI_OVERLAY_OUTPUT=str(out))
    if mode=='caret':
        env.pop('CJTUI_OVERLAY_NATIVE',None);env.update(CJTUI_OVERLAY_NATIVE_CARET='opaque',CJTUI_OVERLAY_CARET_OUTPUT=str(out))
    cmd=['strace','-f','-xx','-s','65535','-e','trace=read,write,ioctl,rt_sigaction,poll,ppoll,openat,execve','-o',str(out/'product.strace'),str(binary)]
    publish(out/'product-command.json',dict(argv=cmd,cwd=os.getcwd(),utc=utc()))
    with (out/'product.stderr').open('wb') as err:
        child=subprocess.Popen(cmd,env=env,stderr=err)
        def control():
            while child.poll() is None:
                pid=traced_pid(out/'product.strace',binary)
                if pid and not (out/'product-pid.json').exists():publish(out/'product-pid.json',dict(pid=pid,exe=str(binary),utc=utc()))
                request=out/'signal-request'
                if request.exists():
                    if not pid:raise RuntimeError('actual binary PID unavailable')
                    os.kill(pid,signal.SIGINT);request.unlink();publish(out/'signal-delivered.json',dict(pid=pid,signal='SIGINT',utc=utc()))
                time.sleep(.01)
        watcher=threading.Thread(target=control,daemon=True);watcher.start();rc=child.wait();watcher.join(timeout=1)
    after=termios.tcgetattr(0);restored=query();(out/'host-restored-reply.bin').write_bytes(restored)
    identity=json.loads((out/'product-pid.json').read_text());lines=(out/'product.strace').read_text(errors='replace');match=re.search(r'^'+str(identity['pid'])+r'\s+\+\+\+ exited with (\d+) \+\+\+$',lines,re.M)
    if not match:raise RuntimeError('actual binary terminal exit missing from strace')
    publish(out/'terminal-after.json',dict(utc=utc(),product_pid=identity['pid'],product_exit=int(match[1]),tracer_exit=rc,before_termios=termios_json(before),after_termios=termios_json(after),termios_equal=before==after,original_reply=original.hex(),restored_reply=restored.hex()))
    until=time.monotonic()+30
    while not (out/'exit-release').exists():
        if time.monotonic()>until:raise TimeoutError('collector exit screenshot barrier')
        time.sleep(.01)
    return rc
if __name__=='__main__':
    a=argparse.ArgumentParser();a.add_argument('binary',type=pathlib.Path);a.add_argument('output',type=pathlib.Path);a.add_argument('mode',choices=['interrupt','prevent','escape','signal','callback-error','caret']);v=a.parse_args();raise SystemExit(run(v.binary,v.output,v.mode))
