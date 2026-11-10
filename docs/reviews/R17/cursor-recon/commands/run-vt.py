import socket,json,pathlib,time,os,subprocess
b=pathlib.Path(__file__).resolve().parents[1]
for state in ['visible','hidden']:
 r=b/'raw/vt'/state;r.mkdir(parents=True);env={**os.environ,'VT_RUN_DIR':str(r),'VT_SCENE':state}
 p=subprocess.Popen(['/bin/sh',str(b/'commands/start-vt.sh')],env=env,stdout=open(r/'qemu.stdout','w'),stderr=open(r/'qemu.stderr','w'))
 try:
  def waitfor(t,seconds=30):
   end=time.monotonic()+seconds
   while time.monotonic()<end:
    if (r/'vt-serial.log').exists() and t in (r/'vt-serial.log').read_text(errors='replace'):return
    time.sleep(.03)
   raise RuntimeError('timeout '+t)
  waitfor('START pid=');s=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);s.settimeout(10);s.connect(str(r/'vt-qmp.sock'));f=s.makefile('rwb',buffering=0);log=open(r/'vt-qmp.jsonl','w');seq=0
  def read():
   d=json.loads(f.readline());log.write(json.dumps({'receive':d,'unix':time.time()})+'\n');log.flush();return d
  def cmd(c,a=None):
   global seq
   seq+=1;d={'execute':c,'id':seq}
   if a:d['arguments']=a
   log.write(json.dumps({'send':d,'unix':time.time()})+'\n');log.flush();f.write((json.dumps(d)+'\n').encode())
   while True:
    z=read()
    if z.get('id')==seq:
     if 'error'in z:raise RuntimeError(z)
     return z
  def capture(phase):
   for frame in range(7):
    cmd('screendump',{'filename':str(r/f'{phase}-{frame}.ppm')});time.sleep(.22)
  read();cmd('qmp_capabilities');cmd('query-version');cmd('query-status');cmd('query-kvm')
  for stage,phase in enumerate(['baseline','changed','restored']):
   waitfor('READY stage='+str(stage)+' ');capture(phase);cmd('send-key',{'keys':[{'type':'qcode','data':'n'}],'hold-time':50})
  waitfor('INIT_CHILD_EXIT=0');capture('exited');rc=p.wait(timeout=20);(r/'qemu-exit.txt').write_text(str(rc)+'\n');print('vt',state,'exit',rc,flush=True);s.close();log.close()
  subprocess.run(['python3',str(b/'commands/export-vt.py'),str(r)],check=True)
 finally:
  if p.poll() is None:p.terminate();p.wait(timeout=10)
