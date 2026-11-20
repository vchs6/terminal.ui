import socket,json,pathlib,time,os,sys
r=pathlib.Path(os.environ['VT_RUN_DIR']);scenario=os.environ.get('VT_ACTIONS','up,q').split(',')
s=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);s.settimeout(10);s.connect(str(r/'vt-qmp.sock'));f=s.makefile('rwb',buffering=0)
c=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);c.connect(str(r/'control.sock'))
log=open(r/'vt-qmp.jsonl','w');i=0;seq=1

def read():
 d=json.loads(f.readline());log.write(json.dumps({'receive':d})+'\n');log.flush();return d

def cmd(command,a=None):
 global i
 i+=1;d={'execute':command,'id':i}
 if a:d['arguments']=a
 log.write(json.dumps({'send':d,'utc':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime())})+'\n');log.flush();f.write((json.dumps(d)+'\n').encode())
 while True:
  z=read()
  if z.get('id')==i:
   if 'error' in z:raise Exception(z)
   return z

def waitfor(text,timeout=20):
 end=time.monotonic()+timeout
 while time.monotonic()<end:
  if text in (r/'vt-serial.log').read_text(errors='replace'):return
  time.sleep(.05)
 raise Exception('missing '+text)

def capture(name):
 global seq
 c.sendall(b's');waitfor('GRID seq='+str(seq)+' phase=RUNNING path=/dev/vcsu1');seq+=1
 cmd('screendump',{'filename':str(r/(name+'.ppm'))})
read();cmd('qmp_capabilities');cmd('query-version');cmd('query-status');cmd('query-kvm');waitfor('PRODUCT_STARTED');time.sleep(2);capture('ready')
for ix,key in enumerate(scenario):
 keys=[{'type':'qcode','data':k} for k in (['ctrl','c'] if key=='ctrl-c' else [key])]
 cmd('send-key',{'keys':keys,'hold-time':50})
 if key in ['q','ctrl-c','e']:
  waitfor('PRODUCT_EXIT=',25);cmd('screendump',{'filename':str(r/'exit.ppm')});break
 time.sleep(.6);capture('input-'+str(ix)+'-'+key)
print('QMP actions',scenario,'captured',r)
