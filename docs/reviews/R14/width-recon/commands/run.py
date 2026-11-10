#!/usr/bin/env python3
"""External native real-host probe driver; no clipboard or injected key input."""
import datetime, hashlib, json, os, pathlib, shutil, subprocess, time
ROOT=pathlib.Path('/workspace/work/terminal-width-recon')
HOSTS=pathlib.Path('/workspace/work/cross-terminal-recon')
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def run(args,**kw):return subprocess.run(args,check=True,**kw)
def prepare():
 p=ROOT/'fixtures/xterm-default'; initial=(p/'example-initial.raw').read_bytes()
 assert initial.startswith(b'Script started on ')
 initial=initial.split(b'\n',1)[1]
 (ROOT/'fixtures/initial.bin').write_bytes(initial)
 for color in ['green','red']:
  b=(p/f'example-{color}.raw').read_bytes(); assert b.count('👩‍💻'.encode())==1
  variants={'original':b,'replace_zwj_cjk':b.replace('👩‍💻'.encode(),'界'.encode()),'remove_zwj_only':b.replace('\u200d'.encode(),b''),'padding_minus2':b[:-6]+b[-4:]}
  assert variants['padding_minus2']==b.replace(b' '*89,b' '*87)
  for n,v in variants.items():(ROOT/f'fixtures/{n}-{color}.bin').write_bytes(v)
 (ROOT/'fixtures/transformations.json').write_text(json.dumps({'initial':'strip util-linux script header line only; all subsequent original ANSI preserved','original':'unchanged original green/red deltas','replace_zwj_cjk':'only entire woman-ZWJ-laptop sequence replaced with 界; padding unchanged','remove_zwj_only':'only U+200D removed; both emoji scalars preserved; padding unchanged','padding_minus2':'only two final padding spaces removed, 89 → 87; original Unicode preserved'},ensure_ascii=False,indent=2)+'\n')
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
  probe=str(ROOT/'source/width_probe')+' '+str(d)+' '+str(ROOT/'fixtures')
  if profile=='xterm-default':
   binary=str(HOSTS/'hosts/xterm/usr/bin/xterm')
   hargs=[binary,'-geometry','100x28+20+20','-fa','Monospace','-fs','12','-T',title,'-e',str(ROOT/'source/width_probe'),str(d),str(ROOT/'fixtures')]
   version=subprocess.run([binary,'-version'],env=env,capture_output=True).stdout.decode()
  else:
   binary=shutil.which('xfce4-terminal');env.update(XDG_CACHE_HOME=str(d/'xdg-cache'),XDG_CONFIG_HOME=str(d/'xdg-config'))
   pathlib.Path(env['XDG_CACHE_HOME']).mkdir();pathlib.Path(env['XDG_CONFIG_HOME']).mkdir()
   hargs=['dbus-run-session','--','env','-u','COLORTERM',binary,'--disable-server','--geometry=100x28+20+20','--title='+title,'--command='+probe]
   version=subprocess.run([binary,'--version'],env=env,capture_output=True).stdout.decode()
  (d/'host-version.txt').write_text(version)
  (d/'package-versions.txt').write_bytes(subprocess.check_output(['dpkg-query','-W','libvte-2.91-0','xfce4-terminal','xserver-xorg-core']))
  meta={'started_utc':now(),'host_command':hargs,'xorg_command':xargs,'locale':{k:env.get(k) for k in ['LANG','LC_ALL','COLORTERM']},'config':'same argv/font/geometry and initially empty per-session XDG dirs as TASK083; no modes changed','native_sha256':hashlib.sha256((ROOT/'source/width_probe').read_bytes()).hexdigest()}
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
prepare()
run(['cc','-O2','-Wall','-Wextra','-Werror',str(ROOT/'source/width_probe.c'),'-o',str(ROOT/'source/width_probe')])
for p,d in [('xterm-default',':211'),('xfce-vte',':212')]:host(p,d)
