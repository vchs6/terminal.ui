import os,pathlib,subprocess,sys,json,termios,re,hashlib,time
binary=pathlib.Path(sys.argv[1]);out=pathlib.Path(sys.argv[2]);before=termios.tcgetattr(0)
def serial(a):return [*a[:6],[x.hex() if isinstance(x,bytes) else x for x in a[6]]]
(out/'terminal-before.json').write_text(json.dumps(dict(termios=serial(before),tty=os.ttyname(0),size=list(os.get_terminal_size(0)),TERM=os.getenv('TERM'),binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest()),indent=2)+'\n')
env=dict(os.environ,CJTUI_KEYBOARD_FORMAL_OUTPUT=str(out),CJTUI_KEYBOARD_FORMAL_MODE='host-observation')
cmd=['strace','-f','-xx','-s','65535','-e','trace=read,write,ioctl,poll,ppoll,rt_sigaction,openat,execve','-o',str(out/'product.strace'),str(binary)]
with (out/'product.stderr').open('wb') as err:child=subprocess.Popen(cmd,env=env,stderr=err);rc=child.wait()
after=termios.tcgetattr(0);trace=(out/'product.strace').read_text(errors='replace');encoded=''.join('\\x%02x'%x for x in str(binary).encode());m=re.search(r'^(\d+)\s+execve\("'+re.escape(encoded)+r'".* = 0$',trace,re.M);assert m,'actual exec PID missing';pid=m[1];ex=re.search(r'^'+pid+r'\s+\+\+\+ exited with (\d+) \+\+\+$',trace,re.M);assert ex,'actual direct exit missing'
(out/'terminal-after.json').write_text(json.dumps(dict(termios=serial(after),termios_equal=before==after,product_pid=int(pid),product_exit=int(ex[1]),tracer_exit=rc),indent=2)+'\n')
end=time.monotonic()+30
while not (out/'exit-release').exists() and time.monotonic()<end:time.sleep(.02)
sys.exit(rc)
