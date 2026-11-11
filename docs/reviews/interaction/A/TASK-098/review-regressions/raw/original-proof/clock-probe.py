import os,pty,subprocess,select,time,fcntl,termios,struct,json,datetime
from pathlib import Path
out=Path('/workspace/work/interaction-review/raw'); master,slave=pty.openpty()
fcntl.ioctl(slave,termios.TIOCSWINSZ,struct.pack('HHHH',2,10,0,0))
started=datetime.datetime.now(datetime.timezone.utc).isoformat(); events=[]; wire=bytearray()
p=subprocess.Popen(['/workspace/work/interaction-review/probe/target/release/bin/main','--clock'],stdin=slave,stdout=slave,stderr=subprocess.PIPE,env=dict(os.environ,TERM='xterm-256color'));os.close(slave)
def drain(duration):
 end=time.monotonic()+duration
 while time.monotonic()<end:
  ready,_,_=select.select([master],[],[],max(0,end-time.monotonic()))
  if ready:
   try: b=os.read(master,65536)
   except OSError:return
   if not b:return
   wire.extend(b)
drain(.2); initial=bytes(wire)
os.write(master,b'\x1b');t=time.monotonic();events.append({'input_hex':'1b','elapsed_ms':0});drain(.4)
escaped=p.poll() is not None; events.append({'after_escape_ms':round((time.monotonic()-t)*1000,3),'exited':escaped})
if not escaped:
 os.write(master,b'q');events.append({'input_hex':'71','elapsed_ms':round((time.monotonic()-t)*1000,3)});drain(.15)
 os.write(master,b'\x03');events.append({'input_hex':'03','elapsed_ms':round((time.monotonic()-t)*1000,3)});drain(.3)
try: rc=p.wait(timeout=2)
except subprocess.TimeoutExpired:p.kill();rc=p.wait();events.append({'forced_kill':True})
stderr=p.stderr.read();os.close(master)
(out/'clock.wire').write_bytes(wire);(out/'clock.stderr').write_bytes(stderr)
result={'started_utc':started,'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'command':['probe/target/release/bin/main','--clock'],'clock_wrap':'cjt_monotonic_ms always -1','initial_wire_hex':initial.hex(),'events':events,'exit':rc,'wire_repr':repr(bytes(wire))}
(out/'clock.result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
