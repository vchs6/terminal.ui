import os,pty,termios,fcntl,struct,subprocess,sys,time,select,json,signal,pathlib
binary=sys.argv[1]; out=pathlib.Path(sys.argv[2]); out.mkdir(parents=True,exist_ok=True)
master,slave=pty.openpty(); fcntl.ioctl(slave,termios.TIOCSWINSZ,struct.pack('HHHH',6,40,0,0)); before=termios.tcgetattr(slave)
def setup():
 os.setsid(); fcntl.ioctl(0,termios.TIOCSCTTY,0)
env={**os.environ,'TERM':'xterm-256color','CJTUI_CONSUMER_OUTPUT':str(out),'CJTUI_CONSUMER_INTERACTIVE':'1'}
p=subprocess.Popen([binary],stdin=slave,stdout=slave,stderr=slave,env=env,preexec_fn=setup); data=b''
def until(predicate,label):
 global data
 deadline=time.monotonic()+10
 while time.monotonic()<deadline:
  if select.select([master],[],[],.05)[0]:
   try: data+=os.read(master,65536)
   except OSError: pass
  if predicate(): return
 raise RuntimeError('timeout '+label)
try:
 until(lambda: b'CLEAN-CONSUMER' in data,'initial render')
 initial=len(data); fcntl.ioctl(slave,termios.TIOCSWINSZ,struct.pack('HHHH',9,54,0,0)); os.killpg(p.pid,signal.SIGWINCH)
 until(lambda: len(data)>initial,'resize repaint')
 os.write(master,b'q'); until(lambda: p.poll() is not None,'q exit')
 result=p.wait(); after=termios.tcgetattr(slave)
 (out/'session.raw').write_bytes(data)
 (out/'pty-metadata.json').write_text(json.dumps({'binary':binary,'actual_exit':result,'initial_cells':'40x6','final_cells':'54x9','before_termios':repr(before),'after_termios':repr(after),'restored':before==after,'raw_bytes':len(data)},indent=2)+'\n')
 assert result==0, result
 assert before==after, 'termios not restored'
 assert b'\x1b[' in data, 'ANSI output absent'
 print('PASS clean consumer PTY: initial render, real resize, q exit=0, termios restored')
finally:
 if p.poll() is None: p.kill(); p.wait()
 (out/'session.raw').write_bytes(data)
 os.close(master); os.close(slave)
