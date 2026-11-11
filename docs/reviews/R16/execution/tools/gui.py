import pathlib,os,sys,subprocess as s,time,json,datetime,hashlib,signal,re,shlex
from xtest import Keyboard
B=pathlib.Path('/workspace/work/glyph-execution');R=B/'raw/gui';R.mkdir(exist_ok=False);BIN=B/'host-consumer/target/release/bin/main';D=':196'
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def js(p,v):p.write_text(json.dumps(v,ensure_ascii=False,indent=2))
def wait(fn,secs=20):
 end=time.monotonic()+secs
 while time.monotonic()<end:
  if fn():return
  time.sleep(.03)
 raise TimeoutError(str(fn))
def run(args,e):return s.check_output(args,env=e,stderr=s.STDOUT,text=True)
from trace_bytes import extract
def output(p):return extract(p.read_text(errors='replace') if p.exists() else '')[0]
assert not os.path.lexists('/tmp/.X11-unix/X196') and not os.path.lexists('/tmp/.X196-lock')
e=os.environ.copy()
for k in ['DISPLAY','XAUTHORITY','DBUS_SESSION_BUS_ADDRESS','SESSION_MANAGER','GTK_MODULES','TMUX','STY']:e.pop(k,None)
e.update(DISPLAY=D,LANG='C.UTF-8',LC_ALL='C.UTF-8');os.environ['DISPLAY']=D
xp=s.Popen(['Xorg',D,'-config','/workspace/work/session-extension-recon/probes/xorg-dummy.conf','-nolisten','tcp','-noreset','-logfile',str(R/'xorg.log')],env=e,stdout=(R/'xorg.stdout').open('wb'),stderr=s.STDOUT)
summary={'utcStart':utc(),'xorgPid':xp.pid,'display':D,'runs':[]}
try:
 wait(lambda:s.run(['xdpyinfo','-display',D],stdout=s.DEVNULL,stderr=s.DEVNULL).returncode==0);keyboard=Keyboard()
 for host in ['xterm','vte']:
  p=R/host;p.mkdir();home=p/'home';home.mkdir();ee=e.copy();ee.update(HOME=str(home),XDG_CONFIG_HOME=str(home/'config'),XDG_CACHE_HOME=str(home/'cache'));title='TASK096 '+host
  child=['python3',str(B/'tools/record-host.py'),str(BIN),str(p)]
  if host=='xterm':
   cmd=['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-geometry','80x25+20+20','-T',title,'-fa','Monospace','-fs','12','-xrm','XTerm*printerCommand: /bin/cat >> '+str(p/'native-grid.ansi'),'-xrm','XTerm*printAttributes: 2','-xrm','XTerm*VT100.translations: #override <Key>F6: print()','-e',*child]
  else:
   cfg=home/'config/xfce4/terminal';cfg.mkdir(parents=True);(cfg/'terminalrc').write_text('[Configuration]\nFontName=DejaVu Sans Mono 12\nMiscAlwaysShowTabs=FALSE\nMiscMenubarDefault=TRUE\nMiscToolbarDefault=FALSE\n')
   module=B/'tools/vte-native-module.so';args=['gcc','-Wall','-Wextra','-Werror','-Wno-misleading-indentation','-fPIC','-shared',str(B/'tools/vte-native-module.c'),'-o',str(module),'-ldl'];s.run(args,check=True);ee.update(GTK_MODULES=str(module),VTE_NATIVE_CAPTURE_DIR=str(p));cmd=['dbus-run-session','--','xfce4-terminal','--disable-server','--geometry=80x25+20+20','--title='+title,'--command='+shlex.join(child)]
  js(p/'launch.json',{'argv':cmd,'env':{k:ee[k] for k in ['DISPLAY','HOME','XDG_CONFIG_HOME','XDG_CACHE_HOME','LC_ALL','GTK_MODULES','VTE_NATIVE_CAPTURE_DIR'] if k in ee},'utc':utc(),'binarySha256':hashlib.sha256(BIN.read_bytes()).hexdigest()})
  hp=s.Popen(cmd,env=ee,stdout=(p/'host.stdout').open('wb'),stderr=(p/'host.stderr').open('wb'),start_new_session=True);serial=0;stages=[]
  try:
   wait(lambda:(p/'terminal-before.json').exists());wait(lambda:b'\x1b[25;1H' in output(p/'product.strace'));time.sleep(.1)
   tree=run(['xwininfo','-root','-tree'],ee);(p/'window-tree.txt').write_text(tree);win=next(line.split()[0] for line in tree.splitlines() if title in line);(p/'window.txt').write_text(run(['xwininfo','-id',win,'-all'],ee));keyboard.focus(win)
   for ix,(name,key) in enumerate([('initial',''),('zwj','z'),('vs16','h'),('literal','t'),('unicode','u'),('auto','o'),('ascii','a'),('auto-return','o'),('narrow','n')]):
    before=output(p/'product.strace');serial+=1
    if key:keyboard.chord(key)
    keyboard.chord('p');wait(lambda:(p/'profile.txt').exists() and f'serial={serial}\n' in (p/'profile.txt').read_text());time.sleep(.15)
    (p/(name+'-profile.txt')).write_bytes((p/'profile.txt').read_bytes());after=output(p/'product.strace');(p/(name+'-stdout.delta')).write_bytes(after[len(before):]);(p/(name+'-stdout-through.raw')).write_bytes(after)
    run(['import','-window',win,str(p/(name+'.png'))],ee)
    if host=='vte':
     (p/'native-request').write_text(str(ix));wait(lambda:(p/f'native-{ix}-meta.json').exists())
    else:
     native=p/'native-grid.ansi';offset=native.stat().st_size if native.exists() else 0;keyboard.chord('F6');wait(lambda:native.exists() and native.stat().st_size>offset);time.sleep(.1);(p/(name+'-native.ansi')).write_bytes(native.read_bytes()[offset:])
    stages.append({'name':name,'key':key,'index':ix,'serial':serial,'stdoutBytes':len(after),'deltaBytes':len(after)-len(before),'utc':utc(),'png':name+'.png','window':win})
   keyboard.chord('q');rc=hp.wait(timeout=20);wait(lambda:(p/'terminal-after.json').exists());meta=json.loads((p/'terminal-after.json').read_text());assert meta['exit']==0 and meta['before']==meta['after'];assert rc==0
   (p/'stdout-raw.ansi').write_bytes(output(p/'product.strace'));js(p/'stages.json',stages);summary['runs'].append({'host':host,'hostExit':rc,'termiosEqual':True,'stages':len(stages),'utcEnd':utc()});print(host,'PASS collection',flush=True)
  except BaseException as err:
   js(p/'failure.json',{'error':repr(err),'utc':utc()});raise
  finally:
   if hp.poll() is None:
    os.killpg(hp.pid,signal.SIGTERM);hp.wait(timeout=10)
finally:
 xp.terminate();summary['xorgExit']=xp.wait(timeout=10);summary['utcEnd']=utc();js(R/'summary.json',summary)
