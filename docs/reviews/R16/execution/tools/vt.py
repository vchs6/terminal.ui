import pathlib,os,sys,subprocess as s,time,socket,json,datetime,hashlib,re
B=pathlib.Path('/workspace/work/glyph-execution');R=B/'raw/vt';R.mkdir(exist_ok=True)
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def js(p,v):p.write_text(json.dumps(v,indent=2))
def wait(fn,seconds=45):
 end=time.monotonic()+seconds
 while time.monotonic()<end:
  if fn():return
  time.sleep(.03)
 raise TimeoutError(str(fn))
summary=[]
for scene in os.environ.get('VT_SCENES','glyph-uid1000-auto,glyph-root-unicode,glyph-root-ascii,glyph-root-deny-auto,session-wire,session-unknown-title').split(','):
 p=R/scene;p.mkdir();env=os.environ.copy();env.update(VT_RUN_DIR=str(p),VT_SCENE=scene,VT_INITRD=str(B/'packages/vt-final-product.cpio.gz'))
 cmd=['/bin/sh',str(B/'tools/start-vt.sh')];meta={'utcStart':utc(),'scene':scene,'command':cmd,'cwd':str(B),'env':{k:env[k] for k in ['VT_RUN_DIR','VT_SCENE','VT_INITRD']},'kernelSha256':hashlib.sha256(pathlib.Path('/workspace/work/linux-console-hosts/packages/linux').read_bytes()).hexdigest(),'initrdSha256':hashlib.sha256((B/'packages/vt-final-product.cpio.gz').read_bytes()).hexdigest()};js(p/'launch.json',meta)
 proc=s.Popen(cmd,cwd=B,env=env,stdout=(p/'qemu.stdout').open('wb'),stderr=(p/'qemu.stderr').open('wb'));meta['qemuPid']=proc.pid;js(p/'launch.json',meta);q=None;control=None
 try:
  serial=lambda:(p/'vt-serial.log').read_text(errors='replace') if (p/'vt-serial.log').exists() else ''
  wait(lambda:(p/'vt-qmp.sock').exists());q=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);q.settimeout(15);q.connect(str(p/'vt-qmp.sock'));f=q.makefile('rwb',buffering=0);log=(p/'vt-qmp.jsonl').open('w');ix=0
  def recv():
   d=json.loads(f.readline());log.write(json.dumps({'receive':d,'utc':utc()})+'\n');log.flush();return d
  def command(name,args=None):
   global ix
   ix+=1;d={'execute':name,'id':ix}
   if args:d['arguments']=args
   log.write(json.dumps({'send':d,'utc':utc()})+'\n');log.flush();f.write((json.dumps(d)+'\n').encode())
   while True:
    z=recv()
    if z.get('id')==ix:
     if 'error'in z:raise RuntimeError(z)
     return z
  recv();command('qmp_capabilities');command('query-version');command('query-status');command('query-kvm');wait(lambda:'PRODUCT_OUTPUT_READY' in serial() or 'PRODUCT_EXIT=' in serial(),90);assert 'PRODUCT_OUTPUT_READY' in serial(), 'product exited before output readiness';control=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);control.connect(str(p/'control.sock'));time.sleep(.5);seq=1;stages=[];count=0
  def key(k):command('send-key',{'keys':[{'type':'qcode','data':k}],'hold-time':50});time.sleep(.18)
  def capture(name):
   global seq
   control.sendall(b's');wait(lambda:f'GRID seq={seq} phase=RUNNING path=/dev/vcsu1' in serial());
   if scene.startswith('glyph'):wait(lambda:f'serial={count}\n' in serial().replace('\r\n','\n'))
   command('screendump',{'filename':str(p/(name+'.ppm'))});stages.append({'name':name,'gridSeq':seq,'utc':utc()});seq+=1
  if scene.startswith('glyph'):
   actions=[('initial',''),('equivalent-v','v'),('literal','t'),('zwj','z'),('ascii','a'),('unicode','u'),('auto','o'),('narrow','n')] if scene=='glyph-root-auto' else [('initial','')]
   for name,action in actions:
    if action:key(action)
    key('p');count+=1;capture(name)
    wait(lambda:f'serial={count}\n' in serial().replace('\r\n','\n'))
   key('q')
  else:
   capture('initial');key('x')
  wait(lambda:'PRODUCT_EXIT=' in serial());command('screendump',{'filename':str(p/'exit.ppm')});rc=proc.wait(timeout=30);meta.update(qemuExit=rc,utcEnd=utc(),stages=stages);js(p/'result.json',meta);assert rc==0
  text=serial();assert 'PRODUCT_EXIT=0 raw_status=0' in text and 'termios_equal=1' in text and 'INIT_CHILD_EXIT=0' in text
  result=s.run(['python3',str(B/'tools/export-evidence.py'),str(p)],stdout=s.PIPE,stderr=s.PIPE,text=True);(p/'export.stdout').write_text(result.stdout);(p/'export.stderr').write_text(result.stderr);assert result.returncode==0
  summary.append({'scene':scene,'qemuExit':rc,'productExit':0,'termiosEqual':True,'utcEnd':utc()});print(scene,'PASS collection',flush=True)
 except BaseException as error:
  js(p/'failure.json',{'error':repr(error),'utc':utc()});raise
 finally:
  if q:q.close()
  if control:control.close()
  if proc.poll() is None:proc.terminate();proc.wait(timeout=15)
js(R/'summary.json',summary)
