import socket,json,pathlib,time
b=pathlib.Path(__file__).resolve().parents[1]
s=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);s.settimeout(10);s.connect(str(b/'raw/vt-qmp.sock'));f=s.makefile('rwb',buffering=0)
log=open(b/'raw/vt-qmp.jsonl','w');i=0

def read():
 d=json.loads(f.readline());log.write(json.dumps({'receive':d})+'\n');log.flush();return d

def cmd(c,a=None):
 global i
 i+=1;d={'execute':c,'id':i}
 if a:d['arguments']=a
 log.write(json.dumps({'send':d})+'\n');log.flush();f.write((json.dumps(d)+'\n').encode())
 while True:
  r=read()
  if r.get('id')==i:
   if 'error'in r:raise Exception(r)
   return r
read();cmd('qmp_capabilities');cmd('query-version');cmd('query-status');cmd('query-kvm')
cmd('screendump',{'filename':str(b/'raw/vt-ready.ppm')})
for key,needle in [('p','INPUT 70'),('up','INPUT 41')]:
 cmd('send-key',{'keys':[{'type':'qcode','data':key}],'hold-time':50})
 end=time.monotonic()+10
 while time.monotonic()<end:
  if needle in (b/'raw/vt-serial.log').read_text(errors='replace'):break
  time.sleep(.05)
 else:raise Exception('input not ack '+key)
cmd('screendump',{'filename':str(b/'raw/vt-input.ppm')})
cmd('send-key',{'keys':[{'type':'qcode','data':'q'}],'hold-time':50})
end=time.monotonic()+2
while time.monotonic()<end:
 if 'PROBE_EXIT=0' in (b/'raw/vt-serial.log').read_text(errors='replace'):break
 time.sleep(.02)
else:raise Exception('exit missing')
cmd('screendump',{'filename':str(b/'raw/vt-exit.ppm')})
print('VGA screenshot+PS2 p/up/q+normal exit observed')
