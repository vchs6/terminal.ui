import os,pty,termios,fcntl,struct,pathlib,time,select,subprocess,json,errno
b=pathlib.Path(__file__).resolve().parents[1]
for host in ['tmux','screen']:
 env=os.environ.copy();env.update(TERM='xterm-256color',LC_ALL='C.UTF-8',MUX_HOST=host,SCREENDIR=str(b/'raw/screen-sockets'))
 pathlib.Path(env['SCREENDIR']).mkdir(mode=0o700,exist_ok=True)
 exe=str(b/'hosts/debian/usr/bin'/host)
 args=([exe,'-L','cjtui-readiness','-f','/dev/null','new-session','-s','readiness',str(b/'probes/mux-scene.sh')] if host=='tmux' else [exe,'-c','/dev/null','-S','readiness',str(b/'probes/mux-scene.sh')])
 childlog=b/f'raw/{host}-child.log'
 if childlog.exists():childlog.unlink()
 gate_read,gate_write=os.pipe()
 pid,fd=pty.fork()
 if not pid:
  os.close(gate_write);os.read(gate_read,1);os.close(gate_read)
  fcntl.ioctl(0,termios.TIOCSWINSZ,struct.pack('HHHH',28,100,0,0));os.execve(exe,args,env)
 os.close(gate_read);before=termios.tcgetattr(fd);os.write(gate_write,b'1');os.close(gate_write);raw=open(b/f'raw/{host}-outer-ansi.bin','wb')
 def pump():
  if select.select([fd],[],[],.02)[0]:
   try:raw.write(os.read(fd,65536));raw.flush()
   except OSError as e:
    if e.errno!=errno.EIO:raise
 def wait(needle):
  until=time.monotonic()+15
  while time.monotonic()<until:
   pump()
   if childlog.exists() and needle in childlog.read_text():return
  raise Exception(f'{host} missing {needle}; outer={pathlib.Path(raw.name).read_bytes()[-1000:]}')
 wait('READY');os.write(fd,b'p');wait('INPUT=p')
 if host=='tmux':
  r=subprocess.run([exe,'-L','cjtui-readiness','capture-pane','-p','-e','-t','readiness'],env=env,capture_output=True,check=True);(b/'raw/tmux-grid-ansi.txt').write_bytes(r.stdout)
 else:subprocess.run([exe,'-S','readiness','-X','hardcopy',str(b/'raw/screen-grid.txt')],env=env,check=True)
 os.write(fd,b'q');wait('EXIT=0')
 until=time.monotonic()+10
 while time.monotonic()<until:
  pump();done,status=os.waitpid(pid,os.WNOHANG)
  if done:break
 else:os.kill(pid,15);raise Exception(host+' did not exit')
 after=termios.tcgetattr(fd)
 result={'command':args,'pid':pid,'outer_exit':os.waitstatus_to_exitcode(status),'outer_termios_before':before,'outer_termios_after':after,'outer_termios_equal':before==after}
 (b/f'raw/{host}-host.json').write_text(json.dumps(result,indent=2,default=lambda x:x.hex()));raw.close();os.close(fd)
 print(host,json.dumps(result,default=lambda x:x.hex()));print(childlog.read_text())
