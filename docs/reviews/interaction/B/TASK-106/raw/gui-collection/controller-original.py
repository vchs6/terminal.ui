from pathlib import Path
import os,subprocess as s,time,json,hashlib,signal,shlex,fcntl,struct,termios,re
from xtest import Keyboard,X
from xsize import hints,resize
from trace_bytes import extract
B=Path('/workspace/work/viewport-execution');R=B/'raw/gui-hosts';R.mkdir(exist_ok=False);BIN=B/'product/tests/interaction_b/target/release/bin/main';DISPLAY=':196'
def utc():return __import__('datetime').datetime.now(__import__('datetime').timezone.utc).isoformat()
def js(p,v):p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
def wait(fn,seconds=15):
 end=time.monotonic()+seconds
 while time.monotonic()<end:
  if fn():return
  time.sleep(.01)
 raise TimeoutError(str(fn))
def run(argv,env):return s.check_output(argv,env=env,stderr=s.STDOUT,text=True)
assert not os.path.lexists('/tmp/.X11-unix/X196')
env=os.environ.copy()
for k in ['DISPLAY','XAUTHORITY','DBUS_SESSION_BUS_ADDRESS','SESSION_MANAGER','GTK_MODULES','TMUX','STY']:env.pop(k,None)
env.update(DISPLAY=DISPLAY,LANG='C.UTF-8',LC_ALL='C.UTF-8');os.environ['DISPLAY']=DISPLAY
xcmd=['Xorg',DISPLAY,'-config','/workspace/work/terminal.ui/docs/reviews/R16/execution/raw/host-xorg-dummy.conf','-nolisten','tcp','-noreset','-logfile',str(R/'xorg.log')];xp=s.Popen(xcmd,env=env,stdout=(R/'xorg.stdout').open('wb'),stderr=s.STDOUT);summary=[]
try:
 wait(lambda:s.run(['xdpyinfo','-display',DISPLAY],stdout=s.DEVNULL,stderr=s.DEVNULL).returncode==0);keyboard=Keyboard()
 for host in os.environ.get('VIEWPORT_GUI_HOSTS','xterm,vte').split(','):
  for mode in os.environ.get('VIEWPORT_GUI_MODES','pty,caret-resize,same-turn,unicode').split(','):
   p=R/(host+'-'+mode);p.mkdir();home=p/'home';home.mkdir();ee=env.copy();ee.update(HOME=str(home),XDG_CONFIG_HOME=str(home/'config'),XDG_CACHE_HOME=str(home/'cache'),VIEWPORT_MODE=mode);title='TASK106 '+host+' '+mode
   cols,rows=(80,24) if mode=='pty' else (40,8) if mode=='unicode' else (4,1)
   child=['python3',str(B/'tools/record-host.py'),str(BIN),str(p),'visible']
   if host=='xterm':cmd=['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-geometry',f'{cols}x{rows}+20+20','-T',title,'-fa','DejaVu Sans Mono','-fs','16','-xrm','XTerm*printerCommand: /bin/cat >> '+str(p/'native-grid.ansi'),'-xrm','XTerm*printAttributes: 2','-xrm','XTerm*VT100.translations: #override <Key>F6: print()','-e',*child]
   else:
    cfg=home/'config/xfce4/terminal';cfg.mkdir(parents=True);(cfg/'terminalrc').write_text('[Configuration]\nFontName=DejaVu Sans Mono 16\nMiscAlwaysShowTabs=FALSE\nMiscMenubarDefault=FALSE\nMiscToolbarDefault=FALSE\n');ee.update(GTK_MODULES=str(B/'tools/vte-native-module.so'),VTE_NATIVE_CAPTURE_DIR=str(p));cmd=['dbus-run-session','--','xfce4-terminal','--disable-server','--hide-menubar',f'--geometry={cols}x{rows}+20+20','--title='+title,'--command='+shlex.join(child)]
   js(p/'launch.json',{'argv':cmd,'env':{k:ee[k] for k in ['DISPLAY','HOME','XDG_CONFIG_HOME','XDG_CACHE_HOME','VIEWPORT_MODE','GTK_MODULES','VTE_NATIVE_CAPTURE_DIR'] if k in ee},'utc':utc(),'binary_sha256':hashlib.sha256(BIN.read_bytes()).hexdigest()});hp=s.Popen(cmd,env=ee,stdout=(p/'host.stdout').open('wb'),stderr=(p/'host.stderr').open('wb'),start_new_session=True)
   try:
    wait(lambda:(p/'terminal-before.json').exists());before=json.loads((p/'terminal-before.json').read_text());tty_path=before['tty'];marker=b'r23' if mode=='pty' else b'#A !' if mode=='unicode' else b'abcd'
    def output():return extract((p/'product.strace').read_text(errors='replace'))[0] if (p/'product.strace').exists() else b''
    wait(lambda:marker in output());tree=run(['xwininfo','-root','-tree'],ee);(p/'window-tree.txt').write_text(tree);win=next(line.split()[0] for line in tree.splitlines() if title in line);keyboard.focus(win);info=hints(keyboard,win);js(p/'window-hints.json',info);(p/'window.txt').write_text(run(['xwininfo','-id',win,'-all'],ee));query_count=0;stages=[];events=[]
    def key(name,count=1):
     if count==1:keyboard.chord(name)
     else:
      for _ in range(count):keyboard.key(name,True);keyboard.key(name,False)
      X.XSync(keyboard.display,0)
     events.append({'key':name,'count':count,'utc':utc()})
    def dimensions():
     fd=os.open(tty_path,os.O_RDONLY|os.O_NOCTTY)
     try:r,c,_,_=struct.unpack('HHHH',fcntl.ioctl(fd,termios.TIOCGWINSZ,bytes(8)));return [c,r]
     finally:os.close(fd)
    def change_size(w,h):
     pixels=resize(keyboard,win,w,h,info);wait(lambda:dimensions()==[w,h]);events.append({'physical_resize':[w,h],'pixels':pixels,'readback':dimensions(),'utc':utc()})
    def query(expected):
     nonlocal_dummy=0
     global query_count
     end=time.monotonic()+12
     while time.monotonic()<end:
      query_count+=1;key('s');f=p/('state-'+str(query_count));wait(lambda:f.exists() and bool(f.read_text()))
      text=f.read_text();parts=text.split('/')
      try:values=[int(x) for x in parts[:-2]] if mode=='pty' else [int(x) for x in parts[:-1]]
      except ValueError:continue
      if all(values[i]==v for i,v in expected.items()):return text
     raise AssertionError(('public state',expected,text))
    def native(ix):
     if host=='vte':
      temp=p/'native-request.next';temp.write_text(str(ix));temp.replace(p/'native-request');wait(lambda:(p/f'native-{ix}-meta.json').exists() and (p/f'native-{ix}-meta.json').read_text().endswith('\n'));return (p/f'native-{ix}-range.txt').read_text().splitlines()
     old=p/'native-grid.ansi';offset=old.stat().st_size if old.exists() else 0;key('F6');wait(lambda:old.exists() and old.stat().st_size>offset);data=old.read_bytes()[offset:];(p/f'native-{ix}.ansi').write_bytes(data);return re.sub(r'\x1b(?:\[[0-?]*[ -/]*[@-~]|#[0-9])','',data.decode()).splitlines()
    def capture(name,expected,lines_expected):
     state=query(expected);ix=len(stages);end=time.monotonic()+12
     while True:
      lines=native(ix);stripped=[x.rstrip(' ') for x in lines]
      if stripped[:len(lines_expected)]==lines_expected:break
      if time.monotonic()>end:raise AssertionError((name,stripped,lines_expected))
      time.sleep(.03)
     (p/(name+'-state.txt')).write_text(state)
     for frame in range(2):run(['import','-window',win,str(p/(name+f'-{frame}.png'))],ee);time.sleep(.15)
     stages.append({'name':name,'public_state':state,'native_first_rows':stripped[:len(lines_expected)],'utc':utc()})
    if mode=='pty':
     capture('initial',{0:80,1:24,2:100,3:0},[f'r{i}' for i in range(24)]);key('Down',100);capture('tail',{0:80,1:24,2:100,3:76},[f'r{i}' for i in range(76,100)]);change_size(40,10);capture('smaller',{0:40,1:10,2:100,3:76},[f'r{i}' for i in range(76,86)]);key('Down',14);capture('smaller-tail',{0:40,1:10,2:100,3:90},[f'r{i}' for i in range(90,100)]);change_size(80,24);capture('restored',{0:80,1:24,2:100,3:76},[f'r{i}' for i in range(76,100)])
    elif mode=='unicode':
     capture('initial',{0:2,1:1,2:4,4:0},['#A !']);key('1');capture('offset1',{4:1},['#界!']);key('2');capture('offset2',{4:2},['# B!']);key('b');capture('shortened',{4:0},['#B !'])
    else:
     capture('initial',{0:4,1:1,2:13,4:0},['abcd']);key('o');capture('old-caret',{0:4,4:9,6:3},['jkl'])
     if mode=='same-turn':
      key('n');wait(lambda:(p/'callback-enter').exists());assert (p/'callback-enter').read_text()=='4/9';change_size(2,1);temp=p/'resize-ready.next';temp.write_text('actual2x1');temp.replace(p/'resize-ready');wait(lambda:(p/'callback-explicit').exists());capture('new-caret-resize',{0:2,4:1,6:1},['bc']);key('0');capture('manual-zero',{0:2,4:0},['ab'])
     else:change_size(2,1);capture('natural-resize',{0:2,4:11,6:1},['l'])
    key('q');rc=hp.wait(timeout=20);wait(lambda:(p/'terminal-after.json').exists());after=json.loads((p/'terminal-after.json').read_text());assert rc==0 and after['exit']==0 and before['before']==after['after'] and before['original_query']['reply_hex']==after['restored_query']['reply_hex'];out,stats=extract((p/'product.strace').read_text());assert out.count(b'\x1b[?25$p')==1;(p/'product-stdout.raw').write_bytes(out);js(p/'stages.json',stages);js(p/'events.json',events);summary.append({'host':host,'mode':mode,'exit':0,'termios':True,'mode_restored':True,'stages':len(stages)});print(host,mode,'physical0',flush=True)
   except BaseException as error:js(p/'failure.json',{'error':repr(error),'utc':utc()});raise
   finally:
    if hp.poll() is None:os.killpg(hp.pid,signal.SIGTERM);hp.wait(timeout=10)
finally:
 xp.terminate();xp.wait(timeout=10);js(R/'summary.json',summary)
