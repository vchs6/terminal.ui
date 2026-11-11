import pathlib,os,subprocess as s,time,json,datetime,hashlib,signal,shlex
from xtest import Keyboard
from trace_bytes import extract
B=pathlib.Path('/workspace/work/interaction-execution');R=B/'raw/gui-hosts2';R.mkdir(exist_ok=False);BIN=B/'product/tests/interaction_a/target/release/bin/main';D=':194'
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def js(p,v):p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
def wait(fn,secs=20):
 end=time.monotonic()+secs
 while time.monotonic()<end:
  if fn():return
  time.sleep(.02)
 raise TimeoutError(str(fn))
def run(args,e):return s.check_output(args,env=e,stderr=s.STDOUT,text=True)
assert not os.path.lexists('/tmp/.X11-unix/X194') and not os.path.lexists('/tmp/.X194-lock')
e=os.environ.copy()
for k in ['DISPLAY','XAUTHORITY','DBUS_SESSION_BUS_ADDRESS','SESSION_MANAGER','GTK_MODULES','TMUX','STY']:e.pop(k,None)
e.update(DISPLAY=D,LANG='C.UTF-8',LC_ALL='C.UTF-8');os.environ['DISPLAY']=D
xcmd=['Xorg',D,'-config','/workspace/work/terminal.ui/docs/reviews/R16/execution/raw/host-xorg-dummy.conf','-nolisten','tcp','-noreset','-logfile',str(R/'xorg.log')];xp=s.Popen(xcmd,env=e,stdout=(R/'xorg.stdout').open('wb'),stderr=s.STDOUT);summary={'utcStart':utc(),'display':D,'xorgArgv':xcmd,'runs':[]}
try:
 wait(lambda:s.run(['xdpyinfo','-display',D],stdout=s.DEVNULL,stderr=s.DEVNULL).returncode==0);keyboard=Keyboard()
 for host in ['xterm','vte']:
  for initial in ['visible','hidden']:
   p=R/(host+'-'+initial);p.mkdir();home=p/'home';home.mkdir();ee=e.copy();ee.update(HOME=str(home),XDG_CONFIG_HOME=str(home/'config'),XDG_CACHE_HOME=str(home/'cache'));title='TASK101 '+host+' '+initial;child=['python3',str(B/'tools/record-host.py'),str(BIN),str(p),initial]
   if host=='xterm':cmd=['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-geometry','40x8+20+20','-T',title,'-fa','DejaVu Sans Mono','-fs','16','-xrm','XTerm*printerCommand: /bin/cat >> '+str(p/'native-grid.ansi'),'-xrm','XTerm*printAttributes: 2','-xrm','XTerm*VT100.translations: #override <Key>F6: print()','-e',*child]
   else:
    cfg=home/'config/xfce4/terminal';cfg.mkdir(parents=True);(cfg/'terminalrc').write_text('[Configuration]\nFontName=DejaVu Sans Mono 16\nMiscAlwaysShowTabs=FALSE\nMiscMenubarDefault=TRUE\nMiscToolbarDefault=FALSE\n');ee.update(GTK_MODULES=str(B/'tools/vte-native-module.so'),VTE_NATIVE_CAPTURE_DIR=str(p));cmd=['dbus-run-session','--','xfce4-terminal','--disable-server','--geometry=40x8+20+20','--title='+title,'--command='+shlex.join(child)]
   js(p/'launch.json',{'argv':cmd,'utc':utc(),'binarySha256':hashlib.sha256(BIN.read_bytes()).hexdigest(),'env':{k:ee[k] for k in ['DISPLAY','HOME','XDG_CONFIG_HOME','XDG_CACHE_HOME','LC_ALL','GTK_MODULES','VTE_NATIVE_CAPTURE_DIR'] if k in ee}});hp=s.Popen(cmd,env=ee,stdout=(p/'host.stdout').open('wb'),stderr=(p/'host.stderr').open('wb'),start_new_session=True)
   try:
    wait(lambda:(p/'terminal-before.json').exists());wait(lambda:(p/'product.strace').exists() and r'\x41\x41\x41\x41' in (p/'product.strace').read_text(errors='replace'));tree=run(['xwininfo','-root','-tree'],ee);(p/'window-tree.txt').write_text(tree);win=next(line.split()[0] for line in tree.splitlines() if title in line);keyboard.focus(win);(p/'window.txt').write_text(run(['xwininfo','-id',win,'-all'],ee));stages=[]
    for ix,(name,keys,focus,caret) in enumerate([('initial',[],'A','0,0,true'),('tab',['Tab'],'B','0,1,true'),('caret-only',['BACKTAB','m'],'A','2,0,true'),('logical-hidden',['h'],'A','0,0,false')]):
     for key in keys:keyboard.chord('Shift_L','Tab') if key=='BACKTAB' else keyboard.chord(key)
     keyboard.chord('s');wait(lambda:(p/'state').exists() and (p/'state').read_text().splitlines()[1]==focus and (p/'state').read_text().startswith('original-'+initial+'\n') and (p/'state').read_text().count('text:s|')>=ix+1)
     text=(p/'state').read_text();(p/(name+'-state.txt')).write_text(text);time.sleep(.12)
     for frame in range(3):
      capture=['import','-window',win,str(p/(name+f'-{frame}.png'))];run(capture,ee);time.sleep(.12)
     if host=='vte':(p/'native-request').write_text(str(ix));wait(lambda:(p/f'native-{ix}-meta.json').exists())
     else:
      file=p/'native-grid.ansi';offset=file.stat().st_size if file.exists() else 0;keyboard.chord('F6');wait(lambda:file.exists() and file.stat().st_size>offset);(p/(name+'-native.ansi')).write_bytes(file.read_bytes()[offset:])
     stages.append({'name':name,'keys':keys,'utc':utc(),'index':ix,'state':text})
    keyboard.chord('q');rc=hp.wait(timeout=20);wait(lambda:(p/'terminal-after.json').exists());meta=json.loads((p/'terminal-after.json').read_text());assert rc==0 and meta['exit']==0 and meta['before']==meta['after'] and meta['original_query']['reply_hex']==meta['restored_query']['reply_hex']
    trace=(p/'product.strace').read_text(errors='replace');out,stats=extract(trace);inp,readstats=extract(trace,fd=0,call='read');(p/'product-stdout.raw').write_bytes(out);(p/'product-input.raw').write_bytes(inp);js(p/'trace-extraction.json',{'write':stats,'read':readstats});assert out.count(b'\x1b[?25$p')==1
    js(p/'stages.json',stages);summary['runs'].append({'host':host,'initial':initial,'exit':rc,'termios':True,'original_mode_restored':True,'stages':len(stages),'PNGs':12});print(host,initial,'actualGUI collection0',flush=True)
   finally:
    if hp.poll() is None:os.killpg(hp.pid,signal.SIGTERM);hp.wait(timeout=10)
finally:
 xp.terminate();summary['xorgExit']=xp.wait(timeout=10);summary['utcEnd']=utc();js(R/'summary.json',summary)
