import os,pathlib,subprocess,sys,json,termios,re,hashlib,time,datetime
binary=pathlib.Path(sys.argv[1]);out=pathlib.Path(sys.argv[2]);mode=sys.argv[3];before=termios.tcgetattr(0)
def serial(a):return [*a[:6],[x.hex() if isinstance(x,bytes) else x for x in a[6]]]
(out/'terminal-before.json').write_text(json.dumps(dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),termios=serial(before),tty=os.ttyname(0),size=list(os.get_terminal_size(0)),TERM=os.getenv('TERM'),binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),fixed_source_sha='22ca8cf7c756c5185064a6f8bc7e9f2c58d4f167'),indent=2)+'\n')
env=os.environ.copy()
if mode!='example':env.update(CJTUI_EDITING_OUTPUT=str(out),CJTUI_EDITING_MODE=mode)
cmd=['strace','-f','-xx','-s','65535','-e','trace=read,write,ioctl,poll,ppoll,rt_sigaction,openat,execve','-o',str(out/'product.strace'),str(binary)]
(out/'product-command.json').write_text(json.dumps(dict(argv=cmd,mode=mode,utc=datetime.datetime.now(datetime.timezone.utc).isoformat()),indent=2)+'\n')
with (out/'product.stderr').open('wb') as err:child=subprocess.Popen(cmd,env=env,stderr=err);rc=child.wait()
after=termios.tcgetattr(0);trace=(out/'product.strace').read_text(errors='replace');encoded=''.join('\\x%02x'%x for x in str(binary).encode());m=re.search(r'^(\d+)\s+execve\("'+re.escape(encoded)+r'".* = 0$',trace,re.M);pid=m[1] if m else None;ex=re.search(r'^'+str(pid)+r'\s+\+\+\+ exited with (\d+) \+\+\+$',trace,re.M)
(out/'terminal-after.json').write_text(json.dumps(dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),termios=serial(after),termios_equal=before==after,product_pid=pid,product_exit=int(ex[1]) if ex else None,tracer_exit=rc),indent=2)+'\n')
end=time.monotonic()+30
while not (out/'exit-release').exists() and time.monotonic()<end:time.sleep(.02)
sys.exit(rc)
