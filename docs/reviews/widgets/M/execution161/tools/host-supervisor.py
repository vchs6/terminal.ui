import os,pathlib,subprocess,sys,json,termios,re,hashlib,time,datetime,tty,select
binary=pathlib.Path(sys.argv[1]);out=pathlib.Path(sys.argv[2]);mode=sys.argv[3];before=termios.tcgetattr(0)
def encode(a):return [*a[:6],[x.hex() if isinstance(x,bytes) else x for x in a[6]]]
def measure(label):
 saved=termios.tcgetattr(0);data=bytearray();start=time.monotonic()
 try:
  tty.setraw(0);os.write(1,b'\x1b[?25$p');end=start+.7
  while time.monotonic()<end:
   if select.select([0],[],[],max(0,end-time.monotonic()))[0]:
    data.extend(os.read(0,4096))
    if re.search(rb'\x1b\[\?25;[0-4]\$y',data):break
 finally:termios.tcsetattr(0,termios.TCSANOW,saved)
 statuses=[int(x) for x in re.findall(rb'\x1b\[\?25;([0-4])\$y',data)]
 r=dict(label=label,utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),query_hex=b'\x1b[?25$p'.hex(),reply_hex=data.hex(),status=statuses[-1] if statuses else None,method='External fixture observes actual host DECRQM reply; does not set mode/capability or fake reply; own temporary raw input restored.',termios_restored=termios.tcgetattr(0)==saved);(out/('mode25-'+label+'.json')).write_text(json.dumps(r,indent=2)+'\n');return r
pre=measure('before')
(out/'terminal-before.json').write_text(json.dumps(dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),termios=encode(before),tty=os.ttyname(0),size=list(os.get_terminal_size(0)),TERM=os.getenv('TERM'),uid=os.getuid(),binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),fixed_source_sha='6e3f26aaaeee9442fde91ce31d720a841eeda473',mode25=pre),indent=2)+'\n')
env=os.environ.copy()
if mode!='example':env.update(CJTUI_COMPOSITE_OUTPUT=str(out),CJTUI_COMPOSITE_MODE=mode)
cmd=['strace','-f','-xx','-s','65535','-e','trace=read,write,ioctl,poll,ppoll,rt_sigaction,openat,execve','-o',str(out/'product.strace'),str(binary)]
(out/'product-command.json').write_text(json.dumps(dict(argv=cmd,mode=mode,utc=datetime.datetime.now(datetime.timezone.utc).isoformat()),indent=2)+'\n')
with (out/'product.stderr').open('wb') as err:child=subprocess.Popen(cmd,env=env,stderr=err);rc=child.wait()
after=termios.tcgetattr(0);post=measure('after');trace=(out/'product.strace').read_text(errors='replace');encoded=''.join('\\x%02x'%x for x in str(binary).encode());m=re.search(r'^(\d+)\s+execve\("'+re.escape(encoded)+r'".* = 0$',trace,re.M);pid=m[1] if m else None;ex=re.search(r'^'+str(pid)+r'\s+\+\+\+ exited with (\d+) \+\+\+$',trace,re.M)
known=pre['status'] in [1,2,3,4];match=pre['status']==post['status'] if known else None
(out/'terminal-after.json').write_text(json.dumps(dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),termios=encode(after),termios_equal=before==after,product_pid=pid,product_exit=int(ex[1]) if ex else None,tracer_exit=rc,mode25=post,known_original_mode_restored=match),indent=2)+'\n')
end=time.monotonic()+30
while not (out/'exit-release').exists() and time.monotonic()<end:time.sleep(.02)
sys.exit(rc)
