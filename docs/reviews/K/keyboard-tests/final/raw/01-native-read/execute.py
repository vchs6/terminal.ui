from pathlib import Path
import datetime,hashlib,json,subprocess,os,pty,termios,fcntl,select,time
b=Path(__file__).resolve().parent;binary=b/'pipe-probe';shim=b/'pipe-remap.so';records=[]
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();utc=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def attrs(fd):
 a=termios.tcgetattr(fd);a[-1]=[list(x) if isinstance(x,bytes) else x for x in a[-1]];return a
for mode in ['positive','contract','tty-control','tty-product']:
 record={'mode':mode,'argv':[str(binary),mode],'cwd':str(b),'utc_start':utc(),'binary_pre_sha256':h(binary)}
 if not mode.startswith('tty-'):
  result=subprocess.run(record['argv'],cwd=b,capture_output=True);data=result.stdout;err=result.stderr;record['exit']=result.returncode
 else:
  master,slave=pty.openpty();before=attrs(slave);fd,writer=os.pipe();os.write(writer,b'ABC');os.close(writer)
  trace=b/(mode+'.trace');env=dict(os.environ,LD_PRELOAD=str(shim),CJTUI_KEYBOARD_PIPE_FD=str(fd),CJTUI_KEYBOARD_PIPE_TRACE=str(trace))
  record['env']={k:env[k] for k in ['LD_PRELOAD','CJTUI_KEYBOARD_PIPE_FD','CJTUI_KEYBOARD_PIPE_TRACE']}
  def terminal():os.setsid();fcntl.ioctl(slave,termios.TIOCSCTTY,0)
  child=subprocess.Popen(record['argv'],cwd=b,stdin=slave,stdout=slave,stderr=subprocess.PIPE,env=env,pass_fds=(fd,),preexec_fn=terminal);data=bytearray();deadline=time.monotonic()+5
  while child.poll() is None and time.monotonic()<deadline:
   if select.select([master],[],[],.02)[0]:data.extend(os.read(master,65536))
  assert child.poll() is not None,'native pipe/realTTY probe watchdog';record['exit']=child.wait();err=child.stderr.read()
  while select.select([master],[],[],.01)[0]:data.extend(os.read(master,65536))
  record.update(before_termios=before,after_termios=attrs(slave));assert record['before_termios']==record['after_termios'];os.close(fd);os.close(master);os.close(slave)
 (b/(mode+'.stdout')).write_bytes(data);(b/(mode+'.stderr')).write_bytes(err);(b/(mode+'.exit')).write_text(str(record['exit'])+'\n')
 record.update(utc_end=utc(),binary_post_sha256=h(binary));assert record['binary_pre_sha256']==record['binary_post_sha256'];records.append(record)
 print(mode,'actual_exit',record['exit'],bytes(data).decode().strip())
assert [x['exit'] for x in records]==[0,1,0,1]
(b/'executions.json').write_text(json.dumps(records,indent=2)+'\n')
