import os,pathlib,pty,fcntl,termios,struct,subprocess,select,time,hashlib,json,sys,signal
binary=pathlib.Path(sys.argv[1]).resolve();out=pathlib.Path(sys.argv[2]);out.mkdir(exist_ok=False);master,slave=pty.openpty();fcntl.ioctl(slave,termios.TIOCSWINSZ,struct.pack('HHHH',8,50,0,0));before=termios.tcgetattr(slave);raw=bytearray()
def setup():os.setsid();fcntl.ioctl(slave,termios.TIOCSCTTY,0)
def pump():
 if select.select([master],[],[],.02)[0]:
  try:raw.extend(os.read(master,65536))
  except OSError:pass
with (out/'stderr').open('wb') as err:p=subprocess.Popen([str(binary)],stdin=slave,stdout=slave,stderr=err,env=dict(os.environ,TERM='xterm-256color'),preexec_fn=setup)
try:
 end=time.monotonic()+15
 while b'Type keys; press q to quit' not in raw and time.monotonic()<end and p.poll() is None:pump()
 assert b'Type keys; press q to quit' in raw,'public example ready';os.write(master,b'q');(out/'input.raw').write_bytes(b'q')
 end=time.monotonic()+10
 while p.poll() is None and time.monotonic()<end:pump()
 assert p.poll() is not None,'public example exited';pump();after=termios.tcgetattr(slave);assert p.returncode==0 and before==after and b'\x1b[?2004h' in raw and b'\x1b[?2004l' in raw
 def encode(v):return [*v[:6],[x.hex() if isinstance(x,bytes) else x for x in v[6]]]
 (out/'result.json').write_text(json.dumps(dict(binary=str(binary),binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),direct_exit=p.returncode,before_termios=encode(before),after_termios=encode(after),termios_equal=before==after,scope='Normal bundled public keyboard example; no smoke source edits or synthetic host replies'),indent=2)+'\n');print('Bundled public example direct exit0 and exact termios restore')
finally:
 (out/'output.raw').write_bytes(raw)
 if p.poll() is None:p.kill();p.wait()
 os.close(master);os.close(slave)
