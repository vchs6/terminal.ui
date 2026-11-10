import os,pathlib,subprocess,time,json,hashlib,signal
b=pathlib.Path(__file__).resolve().parents[1]
def wait(pred,label,timeout=20):
 end=time.monotonic()+timeout
 while time.monotonic()<end:
  if pred():return
  time.sleep(.04)
 raise RuntimeError('timeout '+label)
def capture(d,r,w,phase):
 for frame in range(7):
  p=r/f'{phase}-{frame}.png';t=time.time();subprocess.run(['import','-window',w,str(p)],env={**os.environ,'DISPLAY':d},check=True)
  with open(r/'capture-times.jsonl','a') as f:f.write(json.dumps({'phase':phase,'frame':frame,'unix':t,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})+'\n')
  time.sleep(.22)
for ix,profile in enumerate(['xterm','xfce-vte']):
 for j,state in enumerate(['visible','hidden']):
  r=b/'raw'/profile/state;r.mkdir(parents=True);d=':'+str(310+ix*2+j);title='CursorRecon-'+profile+'-'+state
  log=open(r/'xorg.stdout','w');xp=subprocess.Popen(['Xorg',d,'-config','/workspace/work/cross-terminal-recon/probes/xorg-dummy.conf','-nolisten','tcp','-noreset','-logfile',str(r/'xorg.log')],stdout=log,stderr=subprocess.STDOUT)
  hp=None
  try:
   wait(lambda:subprocess.run(['xdpyinfo'],env={**os.environ,'DISPLAY':d},stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode==0,'Xorg')
   env={**os.environ,'DISPLAY':d,'CURSOR_RUN':str(r),'CURSOR_STATE':state,'XDG_CACHE_HOME':str(r/'cache'),'XDG_CONFIG_HOME':str(r/'config')};env.pop('COLORTERM',None)
   cmd=['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-geometry','80x25+20+20','-fa','Monospace','-fs','12','-T',title,'-e','/bin/sh',str(b/'commands/gui-wrapper.sh')] if profile=='xterm' else ['dbus-run-session','--','xfce4-terminal','--disable-server','--geometry=80x25+20+20','--title='+title,'--command=/bin/sh '+str(b/'commands/gui-wrapper.sh')]
   (r/'command.json').write_text(json.dumps(cmd));version=subprocess.run([cmd[0],'-version'],env=env,capture_output=True) if profile=='xterm' else subprocess.run(['xfce4-terminal','--version'],env=env,capture_output=True)
   (r/'version.txt').write_bytes(version.stdout+version.stderr)
   hp=subprocess.Popen(cmd,env=env,stdout=open(r/'host.stdout','w'),stderr=open(r/'host.stderr','w'),start_new_session=True)
   wait(lambda:(r/'events.log').exists() and 'READY stage=0' in (r/'events.log').read_text(),'fixture ready')
   tree=subprocess.check_output(['xwininfo','-root','-tree'],env=env).decode();(r/'window-tree.txt').write_text(tree)
   w=next(line.split()[0] for line in tree.splitlines() if title in line)
   (r/'window-info.txt').write_bytes(subprocess.check_output(['xwininfo','-id',w,'-all'],env=env))
   for stage,phase in enumerate(['baseline','changed','restored']):
    wait(lambda:'READY stage='+str(stage)+' ' in (r/'events.log').read_text(),phase)
    capture(d,r,w,phase);(r/f'ack-{stage}').touch()
   wait(lambda:(r/'fixture-exit.txt').exists(),'fixture exit');capture(d,r,w,'exited');(r/'ack-exit').touch()
   rc=hp.wait(timeout=10);(r/'host-exit.txt').write_text(str(rc)+'\n');print(profile,state,'exit',rc,flush=True)
  finally:
   if hp is not None and hp.poll() is None:os.killpg(hp.pid,signal.SIGTERM);hp.wait(timeout=10)
   xp.terminate();xp.wait(timeout=10);log.close()
