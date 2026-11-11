from pathlib import Path
import os,subprocess as s,time,socket,json,hashlib,re,base64,tarfile,io
B=Path('/workspace/work/viewport-execution');R=B/'raw/kernel-hosts-fenced';R.mkdir(exist_ok=False)
def utc():return __import__('datetime').datetime.now(__import__('datetime').timezone.utc).isoformat()
def js(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def wait(fn,seconds=60):
 end=time.monotonic()+seconds
 while time.monotonic()<end:
  if fn():return
  time.sleep(.03)
 raise TimeoutError(str(fn))
summary=[]
for mode in ['pty','caret-resize','same-turn']:
 p=R/mode;p.mkdir();env=os.environ.copy();env.update(VT_RUN_DIR=str(p),VT_SCENE=mode,VT_INITRD=str(B/'packages/vt-viewport.cpio.gz'));cmd=['sh',str(B/'tools/start-vt.sh')];meta={'utcStart':utc(),'argv':cmd,'env':{k:env[k] for k in ['VT_RUN_DIR','VT_SCENE','VT_INITRD']},'kernelSha256':hashlib.sha256(Path('/workspace/work/linux-console-hosts/packages/linux').read_bytes()).hexdigest(),'initrdSha256':hashlib.sha256((B/'packages/vt-viewport.cpio.gz').read_bytes()).hexdigest()};js(p/'launch.json',meta);proc=s.Popen(cmd,env=env,stdout=(p/'qemu.stdout').open('wb'),stderr=(p/'qemu.stderr').open('wb'));q=None;control=None
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
  recv();command('qmp_capabilities');command('query-version');command('query-kvm');wait(lambda:'PRODUCT_OUTPUT_READY' in serial() or 'HOST_PHYSICAL_RESIZE_UNSUPPORTED' in serial() or 'PRODUCT_EXIT=' in serial(),90);assert 'PRODUCT_OUTPUT_READY' in serial(),serial()[-2000:];control=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);control.connect(str(p/'control.sock'));stages=[]
  def key(name,count=1):
   for _ in range(count):
    for down in [True,False]:command('input-send-event',{'events':[{'type':'key','data':{'down':down,'key':{'type':'qcode','data':name}}}]});time.sleep(.04)
  def state():
   control.sendall(b'p');time.sleep(.4);found=re.findall(r'PROFILE seq=(\d+) BEGIN\n(.*?)PROFILE_END',serial(),re.S);return found[-1] if found else ('-1','')
  def capture(name,expected,w,h,lines,caret=None):
   key('s');end=time.monotonic()+90
   while True:
    if name!='initial':key('s')
    seq,text=state();parts=text.strip().split('/');values=[]
    try:values=[int(x) for x in parts[:4]] if mode=='pty' else [int(x) for x in parts[:-1]]+[parts[-1]=='true']
    except ValueError:pass
    public_good=len(values)>max(expected) and all(values[i]==v for i,v in expected.items())
    if public_good:
     control.sendall(b's');time.sleep(3)
     found=re.findall(r'PROFILE seq=(\d+) BEGIN\n(.*?)PROFILE_END',serial(),re.S);seq,text=found[-1] if found else ('-1','')
     matches=re.findall(r'GRID seq='+seq+r' phase=RUNNING path=/dev/vcsa1 n=(\d+) hex=([0-9a-f]*)',serial());raw=bytes.fromhex(matches[-1][1]) if matches else b'';body=b''.join(x.encode().ljust(w,b' ') for x in lines)
     if len(raw)==4+2*w*h and raw[:2]==bytes([h,w]) and raw[4::2]==body and (caret is None or raw[2:4]==bytes(caret)):break
    if time.monotonic()>end:raise AssertionError((name,text,expected))
   (p/(name+'-state.txt')).write_text(text);js(p/(name+'-native.json'),{'sequence':seq,'vcsa_hex':raw.hex(),'rows':h,'cols':w,'cursor':list(raw[2:4]),'body':raw[4::2].decode()})
   for frame in range(2):command('screendump',{'filename':str(p/(name+f'-{frame}.png')),'format':'png'});time.sleep(.15)
   stages.append({'name':name,'public_state':text,'grid_sequence':seq,'utc':utc()})
  if mode=='pty':
   capture('initial',{0:80,1:24,2:100,3:0},80,24,[f'r{i}' for i in range(24)]);key('down',100);capture('tail',{3:76},80,24,[f'r{i}' for i in range(76,100)]);control.sendall(b'r');capture('smaller',{0:40,1:10,3:76},40,10,[f'r{i}' for i in range(76,86)]);key('down',14);capture('smaller-tail',{3:90},40,10,[f'r{i}' for i in range(90,100)]);control.sendall(b'R');capture('restored',{0:80,1:24,3:76},80,24,[f'r{i}' for i in range(76,100)])
  else:
   capture('initial',{0:4,1:1,2:13,4:0},4,1,['abcd'],[0,0]);key('o');capture('old-caret',{0:4,4:9,6:3},4,1,['jkl '],[3,0])
   if mode=='same-turn':
    key('n')
    def callback():state();return 'CALLBACK_ENTER 4/9' in serial()
    wait(callback);control.sendall(b'2');capture('new-caret-resize',{0:2,4:1,6:1,7:True},2,1,['bc'],[1,0]);key('0');capture('manual-zero',{0:2,4:0,7:False},2,1,['ab'],[1,0])
   else:control.sendall(b'2');capture('natural-resize',{0:2,4:11,6:1,7:True},2,1,['l '],[1,0])
  key('q');wait(lambda:'PRODUCT_EXIT=' in serial());command('screendump',{'filename':str(p/'restored-session.png'),'format':'png'});rc=proc.wait(timeout=30);assert rc==0;wait(lambda:'EVIDENCE_TAR_BASE64_END' in serial());text=serial();assert 'PRODUCT_EXIT=0 raw_status=0' in text and 'termios_equal=1' in text and 'INIT_CHILD_EXIT=0' in text
  block=text.split('EVIDENCE_TAR_BASE64_BEGIN',1)[1].split('EVIDENCE_TAR_BASE64_END',1)[0];data=base64.b64decode(''.join(block.split()));(p/'guest-evidence.tar').write_bytes(data)
  with tarfile.open(fileobj=io.BytesIO(data)) as t:t.extractall(p/'evidence',filter='data')
  js(p/'stages.json',stages);meta.update(qemuExit=rc,productExit=0,termiosEqual=True,utcEnd=utc());js(p/'result.json',meta);summary.append({'mode':mode,'exit':rc,'productExit':0,'termios':True,'stages':len(stages)});print('kernel VT',mode,'actual collection0',flush=True)
 except BaseException as e:
  js(p/'failure.json',{'error':repr(e),'utc':utc()})
  try:
   key('q');proc.wait(timeout=90)
  except Exception:pass
  raise
 finally:
  if control:control.close()
  if q:q.close()
  if proc.poll() is None:proc.terminate();proc.wait(timeout=10)
js(R/'summary.json',summary)
