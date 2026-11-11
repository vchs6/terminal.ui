from pathlib import Path
import os,subprocess as s,time,socket,json,hashlib,re,gzip,base64,tarfile,io
B=Path('/workspace/work/interaction-execution');R=B/'raw/kernel-vt';R.mkdir(exist_ok=False)
def utc():return __import__('datetime').datetime.now(__import__('datetime').timezone.utc).isoformat()
def js(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def wait(fn,seconds=60):
 end=time.monotonic()+seconds
 while time.monotonic()<end:
  if fn():return
  time.sleep(.03)
 raise TimeoutError(str(fn))
summary=[]
for initial in ['visible','hidden']:
 p=R/initial;p.mkdir();env=os.environ.copy();env.update(VT_RUN_DIR=str(p),VT_SCENE=initial,VT_INITRD=str(B/'packages/vt-interaction.cpio.gz'));cmd=['sh',str(B/'tools/start-vt.sh')];meta={'utcStart':utc(),'argv':cmd,'env':{k:env[k] for k in ['VT_RUN_DIR','VT_SCENE','VT_INITRD']},'kernelSha256':hashlib.sha256(Path('/workspace/work/linux-console-hosts/packages/linux').read_bytes()).hexdigest(),'initrdSha256':hashlib.sha256((B/'packages/vt-interaction.cpio.gz').read_bytes()).hexdigest()};js(p/'launch.json',meta);proc=s.Popen(cmd,env=env,stdout=(p/'qemu.stdout').open('wb'),stderr=(p/'qemu.stderr').open('wb'));q=None;control=None
 try:
  serial=lambda:(p/'vt-serial.log').read_text(errors='replace') if (p/'vt-serial.log').exists() else ''
  wait(lambda:(p/'vt-qmp.sock').exists());q=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);q.settimeout(15);q.connect(str(p/'vt-qmp.sock'));f=q.makefile('rwb',buffering=0);log=(p/'qmp.jsonl').open('w');ix=0
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
  recv();command('qmp_capabilities');command('query-version');command('query-kvm');wait(lambda:'PRODUCT_OUTPUT_READY' in serial() or 'PRODUCT_EXIT=' in serial(),90);assert 'PRODUCT_OUTPUT_READY' in serial();control=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);control.connect(str(p/'control.sock'));stages=[]
  def key(names):
   command('send-key',{'keys':[{'type':'qcode','data':n} for n in names],'hold-time':50});time.sleep(.12)
  def state():
   control.sendall(b's');time.sleep(.08);found=re.findall(r'PROFILE seq=(\d+) BEGIN\n(.*?)PROFILE_END',serial(),re.S);return found[-1] if found else ('-1','')
  for stage,actions,focus,caret in [('initial',[],'A','0,0,true'),('tab',[['tab']],'B','0,1,true'),('caret-only',[['shift','tab'],['m']],'A','2,0,true'),('logical-hidden',[['h']],'A','0,0,false')]:
   for names in actions:key(names)
   key(['s']);end=time.monotonic()+10;seq,text=state()
   while not (text.startswith('unknown-timeout\n'+focus+'\n') and text.count('text:s|')>=len(stages)+1):
    if time.monotonic()>end:raise AssertionError((stage,text))
    seq,text=state()
   (p/(stage+'-state.txt')).write_text(text)
   for frame in range(3):command('screendump',{'filename':str(p/(stage+f'-{frame}.png')),'format':'png'});time.sleep(.15)
   grids=re.findall(r'GRID seq='+seq+r' phase=RUNNING path=(\S+) n=(\d+) hex=([0-9a-f]*)',serial());js(p/(stage+'-native-grids.json'),[{'path':path,'bytes':int(n),'hex':data} for path,n,data in grids]);stages.append({'name':stage,'grid_sequence':seq,'public_state':text,'utc':utc()})
  key(['q']);wait(lambda:'PRODUCT_EXIT=' in serial());command('screendump',{'filename':str(p/'restored.png'),'format':'png'});rc=proc.wait(timeout=30);assert rc==0;wait(lambda:'EVIDENCE_TAR_BASE64_END' in serial());text=serial();assert 'PRODUCT_EXIT=0 raw_status=0' in text and 'termios_equal=1' in text and 'INIT_CHILD_EXIT=0' in text
  block=text.split('EVIDENCE_TAR_BASE64_BEGIN',1)[1].split('EVIDENCE_TAR_BASE64_END',1)[0];data=base64.b64decode(''.join(block.split()));(p/'guest-evidence.tar').write_bytes(data)
  with tarfile.open(fileobj=io.BytesIO(data)) as t:t.extractall(p/'evidence',filter='data')
  js(p/'stages.json',stages);meta.update(qemuExit=rc,productExit=0,termiosEqual=True,utcEnd=utc());js(p/'result.json',meta);summary.append({'initial':initial,'exit':rc,'productExit':0,'termios':True,'status':'unknown-timeout','PNGs':13});print('kernel VT',initial,'actual collection0',flush=True)
 except BaseException as e:
  js(p/'failure.json',{'error':repr(e),'utc':utc()});raise
 finally:
  if control:control.close()
  if q:q.close()
  if proc.poll() is None:proc.terminate();proc.wait(timeout=10)
js(R/'summary.json',summary)
