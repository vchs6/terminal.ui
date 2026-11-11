import os,sys,subprocess,pathlib,json,datetime,termios,tty,select,time
binary,out,initial=sys.argv[1:];p=pathlib.Path(out)
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def publish(path,value):
 temp=path.with_name(path.name+'.next');temp.write_text(json.dumps(value,indent=2)+'\n');temp.replace(path)
def status_query(label):
 before=termios.tcgetattr(0);raw=b'';begin=utc()
 try:
  tty.setraw(0);os.write(1,b'\x1b[?25$p');end=time.monotonic()+1
  while not raw.endswith(b'$y') and time.monotonic()<end:
   ready,_,_=select.select([0],[],[],max(0,end-time.monotonic()))
   if ready:raw+=os.read(0,128)
 finally:termios.tcsetattr(0,termios.TCSANOW,before)
 (p/(label+'-host-reply.bin')).write_bytes(raw);return {'utc':begin,'query_hex':'1b5b3f32352470','reply_hex':raw.hex()}
os.write(1,b'\x1b[?25h' if initial=='visible' else b'\x1b[?25l')
original=status_query('original');assert original['reply_hex']==(b'\x1b[?25;1$y' if initial=='visible' else b'\x1b[?25;2$y').hex(),original
stty=lambda:subprocess.check_output(['stty','-g'],text=True).strip()
meta={'utcStart':utc(),'initial':initial,'original_query':original,'before':stty(),'grid':subprocess.check_output(['stty','size'],text=True).strip(),'tty':os.ttyname(0),'TERM':os.getenv('TERM'),'COLORTERM':os.getenv('COLORTERM'),'LANG':os.getenv('LANG'),'uid':os.getuid()};publish(p/'terminal-before.json',meta)
env=os.environ.copy();env['CJTUI_VIEWPORT_CASE']=os.environ['VIEWPORT_MODE'];env['CJTUI_VIEWPORT_OUTPUT']=str(p)
cmd=['strace','-f','-xx','-s','65535','-e','trace=read,write,ioctl,rt_sigaction,poll,ppoll,openat,execve','-o',str(p/'product.strace'),binary];(p/'product-command.json').write_text(json.dumps({'argv':cmd,'utc':utc()},indent=2)+'\n')
r=subprocess.run(cmd,env=env);meta.update(exit=r.returncode,after=stty(),utcEnd=utc());meta['restored_query']=status_query('restored');publish(p/'terminal-after.json',meta);assert r.returncode==0 and meta['before']==meta['after'];assert meta['restored_query']['reply_hex']==original['reply_hex'];sys.exit(r.returncode)
