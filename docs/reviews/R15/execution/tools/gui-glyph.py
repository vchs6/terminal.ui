import pathlib,os,subprocess as s,time,json,datetime,hashlib,signal,shlex
from xtest import Keyboard
from trace_bytes import extract
B=pathlib.Path('/workspace/work/theme-execution');R=B/'raw/gui-glyph';R.mkdir(exist_ok=False);BIN=B/'observation-glyph/target/release/bin/main';D=':188'
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def js(p,v):p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
def wait(fn,secs=20):
 end=time.monotonic()+secs
 while time.monotonic()<end:
  if fn():return
  time.sleep(.03)
 raise TimeoutError(str(fn))
def run(args,e):return s.check_output(args,env=e,stderr=s.STDOUT,text=True)
assert not os.path.lexists('/tmp/.X11-unix/X188') and not os.path.lexists('/tmp/.X188-lock')
e=os.environ.copy()
for k in ['DISPLAY','XAUTHORITY','DBUS_SESSION_BUS_ADDRESS','SESSION_MANAGER','GTK_MODULES','TMUX','STY']:e.pop(k,None)
e.update(DISPLAY=D,LANG='C.UTF-8',LC_ALL='C.UTF-8');os.environ['DISPLAY']=D
config='/workspace/work/terminal.ui/docs/reviews/R16/execution/raw/host-xorg-dummy.conf'
xcmd=['Xorg',D,'-config',config,'-nolisten','tcp','-noreset','-logfile',str(R/'xorg.log')]
xp=s.Popen(xcmd,env=e,stdout=(R/'xorg.stdout').open('wb'),stderr=s.STDOUT)
summary={'utcStart':utc(),'xorgPid':xp.pid,'display':D,'xorgArgv':xcmd,'runs':[]}
try:
 wait(lambda:s.run(['xdpyinfo','-display',D],stdout=s.DEVNULL,stderr=s.DEVNULL).returncode==0);keyboard=Keyboard()
 for host in ['xterm','vte']:
  for preset in ['Ascii','Unicode']:
   p=R/(host+'-'+preset);p.mkdir();home=p/'home';home.mkdir();ee=e.copy();ee.update(HOME=str(home),XDG_CONFIG_HOME=str(home/'config'),XDG_CACHE_HOME=str(home/'cache'),TASK087_PRESET=preset,CJTUI_THEME_GLYPH_MODE=preset);title='TASK087 Glyph '+host+' '+preset
   child=['python3',str(B/'tools/record-host-glyph.py'),str(BIN),str(p)]
   if host=='xterm':
    cmd=['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-geometry','80x25+20+20','-T',title,'-fa','DejaVu Sans Mono','-fs','12','-xrm','XTerm*printerCommand: /bin/cat >> '+str(p/'native-grid.ansi'),'-xrm','XTerm*printAttributes: 2','-xrm','XTerm*VT100.translations: #override <Key>F6: print()','-e',*child]
   else:
    cfg=home/'config/xfce4/terminal';cfg.mkdir(parents=True);(cfg/'terminalrc').write_text('[Configuration]\nFontName=DejaVu Sans Mono 12\nMiscAlwaysShowTabs=FALSE\nMiscMenubarDefault=TRUE\nMiscToolbarDefault=FALSE\n')
    module=B/'tools/vte-native-module.so';ee.update(GTK_MODULES=str(module),VTE_NATIVE_CAPTURE_DIR=str(p));cmd=['dbus-run-session','--','xfce4-terminal','--disable-server','--geometry=80x25+20+20','--title='+title,'--command='+shlex.join(child)]
   js(p/'launch.json',{'argv':cmd,'env':{k:ee[k] for k in ['DISPLAY','HOME','XDG_CONFIG_HOME','XDG_CACHE_HOME','LC_ALL','GTK_MODULES','VTE_NATIVE_CAPTURE_DIR','TASK087_PRESET'] if k in ee},'utc':utc(),'binarySha256':hashlib.sha256(BIN.read_bytes()).hexdigest()})
   hp=s.Popen(cmd,env=ee,stdout=(p/'host.stdout').open('wb'),stderr=(p/'host.stderr').open('wb'),start_new_session=True)
   try:
    wait(lambda:(p/'terminal-before.json').exists());time.sleep(.5)
    tree=run(['xwininfo','-root','-tree'],ee);(p/'window-tree.txt').write_text(tree);win=next(line.split()[0] for line in tree.splitlines() if title in line);(p/'window.txt').write_text(run(['xwininfo','-id',win,'-all'],ee));keyboard.focus(win)
    keyboard.chord('p');wait(lambda:(p/'profile.txt').exists());time.sleep(.15)
    screenshot=['import','-window',win,str(p/'preset.png')];run(screenshot,ee);js(p/'capture.json',{'utc':utc(),'argv':screenshot,'window':win})
    if host=='vte':
     (p/'native-request').write_text('0');wait(lambda:(p/'native-0-meta.json').exists())
    else:
     keyboard.chord('F6');wait(lambda:(p/'native-grid.ansi').exists());time.sleep(.15)
    keyboard.chord('q');rc=hp.wait(timeout=20);wait(lambda:(p/'terminal-after.json').exists());meta=json.loads((p/'terminal-after.json').read_text());assert meta['exit']==0 and meta['before']==meta['after'];assert rc==0
    raw,stats=extract((p/'product.strace').read_text(errors='replace'));(p/'stdout.raw').write_bytes(raw);js(p/'trace-extraction.json',stats)
    summary['runs'].append({'host':host,'preset':preset,'hostExit':rc,'termiosEqual':True,'utcEnd':utc()});print(host,preset,'collection exit 0',flush=True)
   except BaseException as err:
    js(p/'failure.json',{'error':repr(err),'utc':utc()});raise
   finally:
    if hp.poll() is None:os.killpg(hp.pid,signal.SIGTERM);hp.wait(timeout=10)
finally:
 xp.terminate();summary['xorgExit']=xp.wait(timeout=10);summary['utcEnd']=utc();js(R/'summary.json',summary)
