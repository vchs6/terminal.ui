#!/usr/bin/env python3
import datetime, hashlib, json, os, pathlib, shutil, subprocess, time
ROOT=None
KIND=None
BINARY=None
HOSTS=pathlib.Path('/workspace/work/cross-terminal-recon')
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def run(args,**kw):return subprocess.run(args,check=True,**kw)
def host(profile,display):
 d=ROOT/'raw'/profile;d.mkdir(parents=True,exist_ok=False)
 env=os.environ.copy();env.update(DISPLAY=display,LANG='C.UTF-8',LC_ALL='C.UTF-8');env.pop('COLORTERM',None)
 config=HOSTS/'probes/xorg-dummy.conf';shutil.copy2(config,d/'xorg-dummy.conf')
 xargs=['Xorg',display,'-config',str(config),'-nolisten','tcp','-noreset','-logfile',str(d/'xorg.log')]
 x=subprocess.Popen(xargs,stdout=open(d/'xorg.stdout','wb'),stderr=subprocess.STDOUT)
 h=None
 try:
  for _ in range(150):
   if subprocess.run(['xdpyinfo'],env=env,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode==0:break
   time.sleep(.1)
  else:raise RuntimeError('Xorg timeout')
  title='WIDTH RECON '+profile
  frames=ROOT/'frames'/profile
  probe=str(BINARY)+' '+str(d)+' '+str(frames)+' '+KIND
  if profile=='xterm-default':
   binary=str(HOSTS/'hosts/xterm/usr/bin/xterm')
   hargs=[binary,'-geometry','100x28+20+20','-fa','Monospace','-fs','12','-T',title,'-e',str(BINARY),str(d),str(frames),KIND]
   version=subprocess.run([binary,'-version'],env=env,capture_output=True).stdout.decode()
  else:
   binary=shutil.which('xfce4-terminal');env.update(XDG_CACHE_HOME=str(d/'xdg-cache'),XDG_CONFIG_HOME=str(d/'xdg-config'))
   pathlib.Path(env['XDG_CACHE_HOME']).mkdir();pathlib.Path(env['XDG_CONFIG_HOME']).mkdir()
   hargs=['dbus-run-session','--','env','-u','COLORTERM',binary,'--disable-server','--geometry=100x28+20+20','--title='+title,'--command='+probe]
   version=subprocess.run([binary,'--version'],env=env,capture_output=True).stdout.decode()
  (d/'host-version.txt').write_text(version)
  (d/'package-versions.txt').write_bytes(subprocess.check_output(['dpkg-query','-W','libvte-2.91-0','xfce4-terminal','xserver-xorg-core']))
  meta={'started_utc':now(),'host_command':hargs,'xorg_command':xargs,'locale':{k:env.get(k) for k in ['LANG','LC_ALL','COLORTERM']},'config':'same argv/font/geometry and initially empty per-session XDG dirs as TASK083; only native raw input for complete DSR; no advanced terminal mode change','native_sha256':hashlib.sha256(BINARY.read_bytes()).hexdigest()}
  (d/'metadata.json').write_text(json.dumps(meta,indent=2)+'\n')
  h=subprocess.Popen(hargs,env=env,stdout=open(d/'host.stdout','wb'),stderr=open(d/'host.stderr','wb'))
  seen=set();deadline=time.monotonic()+150
  while h.poll() is None:
   if time.monotonic()>deadline:raise RuntimeError('host deadline')
   if (d/'stage').exists():
    name=(d/'stage').read_text().strip()
    if name and name not in seen:
     tree=subprocess.check_output(['xwininfo','-root','-tree'],env=env,text=True)
     (d/'window-tree.txt').write_text(tree)
     rows=[r for r in tree.splitlines() if title in r]
     if not rows:time.sleep(.05);continue
     wid=rows[0].strip().split()[0]
     info=subprocess.check_output(['xwininfo','-id',wid,'-all'],env=env)
     (d/'window.txt').write_bytes(info)
     # DSR response is emitted after the terminal parses all preceding output.
     # Allow rendering to paint before unmodified X11 window pixel capture.
     time.sleep(.12)
     run(['import','-window',wid,str(d/f'{name}.png')],env=env)
     (d/f'{name}-utc.txt').write_text(now()+'\n')
     (d/'ack.tmp').write_text(name+'\n');os.replace(d/'ack.tmp',d/'ack');seen.add(name)
   time.sleep(.03)
  meta.update(ended_utc=now(),host_exit=h.wait(),captures=sorted(seen))
  (d/'metadata.json').write_text(json.dumps(meta,indent=2)+'\n')
  if meta['host_exit']!=0 or not (d/'exit.txt').exists():raise RuntimeError('native did not finish')
 finally:
  if h is not None and h.poll() is None:h.terminate();h.wait(timeout=5)
  x.terminate();x.wait(timeout=5)
  (d/'driver-exit-utc.txt').write_text(now()+'\n')

if __name__ == '__main__':
 import argparse, tempfile
 parser=argparse.ArgumentParser()
 parser.add_argument('--captures',type=pathlib.Path,required=True,help='directory containing <profile>/q/example-{initial,green,red}.raw or fixture original083/<profile>/example-*.raw')
 parser.add_argument('--kind',choices=['zwj','vs16'],required=True)
 parser.add_argument('--out',type=pathlib.Path,required=True,help='fresh directory')
 args=parser.parse_args(); ROOT=args.out.resolve(); KIND=args.kind
 ROOT.mkdir(parents=True,exist_ok=False)
 entries=[]
 for profile in ['xterm-default','xfce-vte']:
  source=args.captures/profile
  if (source/'q').is_dir(): source=source/'q'
  frames=ROOT/'frames'/profile;frames.mkdir(parents=True)
  for stage in ['initial','green','red']:
   origin=source/f'example-{stage}.raw'; data=origin.read_bytes()
   if stage=='initial' and data.startswith(b'Script started on '):data=data.split(b'\n',1)[1]
   target=frames/f'{stage}.bin';target.write_bytes(data)
   entries.append(dict(original=str(origin.resolve()),original_sha256=hashlib.sha256(origin.read_bytes()).hexdigest(),
                       derived=str(target),derived_sha256=hashlib.sha256(data).hexdigest(),
                       transform='strip script header line for initial only; otherwise exact bytes'))
 (ROOT/'frame-origins.json').write_text(json.dumps(entries,indent=2)+'\n')
 with tempfile.TemporaryDirectory(prefix='cjtui-dsr-driver.') as temp:
  BINARY=pathlib.Path(temp)/'replay_probe'
  run(['cc','-O2','-Wall','-Wextra','-Werror',str(pathlib.Path(__file__).with_name('replay_probe.c')),'-o',str(BINARY)])
  for profile,display in [('xterm-default',':241'),('xfce-vte',':242')]:host(profile,display)
