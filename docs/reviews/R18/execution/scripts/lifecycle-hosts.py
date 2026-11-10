"""Fresh actual XTerm automatic scope cleanup; frozen consumer/modes untouched."""
import os,pathlib,json,hashlib,datetime,subprocess as s,time,sys,re,shlex,shutil,signal
B=pathlib.Path('/workspace/work/session-extension-execution');S=B/'source';BIN=S/'tests/session_extensions/target/release/bin/main';R=B/'raw/lifecycle-hosts';R.mkdir(exist_ok=False)
sys.path.insert(0,'/workspace/work/vte-grid-capture-recon/scripts')
from xtest import Keyboard
XT='/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm'
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def js(p,v):p.write_text(json.dumps(v,ensure_ascii=False,indent=2))
def wait(fn,label,timeout=15):
 end=time.monotonic()+timeout
 while time.monotonic()<end:
  val=fn()
  if val:return val
  time.sleep(.01)
 raise RuntimeError('timeout '+label)
assert h(BIN)=='dc5c0dde2548b9bd9ac74d5a390e82b6a2ee65cdf5777eb6668e2fda74a3677a'
assert not os.path.lexists('/tmp/.X11-unix/X173') and not os.path.lexists('/tmp/.X173-lock')
env=os.environ.copy()
for key in ['DISPLAY','XAUTHORITY','SESSION_MANAGER','DBUS_SESSION_BUS_ADDRESS','GTK_MODULES','TMUX','STY']:env.pop(key,None)
env.update(DISPLAY=':173',LC_ALL='C.UTF-8',LANG='C.UTF-8')
xp=s.Popen(['Xorg',':173','-config','/workspace/work/session-extension-recon/probes/xorg-dummy.conf','-nolisten','tcp','-noreset','-logfile',str(R/'xorg.log')],env=env,stdout=(R/'xorg.stdout').open('wb'),stderr=s.STDOUT)
summary={'utcStart':utc(),'xorgPid':xp.pid,'cases':[]}
def run(args,e):
 result=s.run(args,env=e,stdout=s.PIPE,stderr=s.STDOUT,text=True,timeout=15)
 if result.returncode:raise RuntimeError(str(args)+' '+result.stdout)
 return result.stdout
try:
 wait(lambda:s.run(['xdpyinfo','-display',':173'],stdout=s.DEVNULL,stderr=s.DEVNULL).returncode==0,'private Xorg ready')
 os.environ['DISPLAY']=':173';keys=Keyboard()
 for scenario in ['ledger-close','ledger-error','ledger-cancel']:
  p=R/scenario;p.mkdir();home=B/'private-lifecycle'/scenario;home.mkdir(mode=0o700,parents=True);(home/'runtime').mkdir(mode=0o700)
  e=env.copy();e.update(HOME=str(home),XDG_CONFIG_HOME=str(home/'config'),XDG_CACHE_HOME=str(home/'cache'),XDG_RUNTIME_DIR=str(home/'runtime'),CJTUI_SESSION_HOST_SCENARIO=scenario,CJTUI_SESSION_UI_FAIL='1' if scenario=='ledger-error' else '0',CJTUI_SESSION_CLOSE_FAIL='1' if scenario=='ledger-error' else '0')
  original='TASK151 automatic '+scenario
  cfg=p/'host.config';cfg.write_text('XTerm398 frozen private profile\ngeometry=100x28\nTERM=xterm-256color actual XTerm launch\nroute=Direct\ntitleStack=DeclaredSupported\nOSC52 default denied\nallowTitleOps default\nscenario='+scenario+'\n')
  child=[str(S/'tests/session_extensions/host-consumer.sh'),str(BIN),str(p/'consumer'),'Direct','declared']
  wrapper=p/'child-wrapper.sh'
  wrapper.write_text('#!/bin/bash\n'+shlex.join(child)+'\nstatus=$?\nprintf "%s\\n" "$status" > '+shlex.quote(str(p/'child-exit'))+'\nwhile [[ ! -f '+shlex.quote(str(p/'release-window'))+' ]]; do sleep 0.02; done\nexit "$status"\n')
  rec=['script','--quiet','--flush','--return','--log-out',str(p/'outer-ansi.bin'),'--command',shlex.join(['/bin/bash',str(wrapper)])]
  args=[XT,'-tn','xterm-256color','-geometry','100x28+20+20','-T',original,'-fa','Monospace','-fs','12','-xrm','XTerm*printerCommand: /bin/cat > '+shlex.quote(str(p/'native-grid.ansi')),'-xrm','XTerm*printAttributes: 2','-xrm','XTerm*VT100.translations: #override <Key>F6: print()','-e']+rec
  launch={'utcStart':utc(),'scenario':scenario,'argv':args,'environment':{k:e[k] for k in ['DISPLAY','HOME','XDG_CONFIG_HOME','XDG_CACHE_HOME','XDG_RUNTIME_DIR','CJTUI_SESSION_HOST_SCENARIO','CJTUI_SESSION_UI_FAIL','CJTUI_SESSION_CLOSE_FAIL']},'binary':str(BIN),'binarySha256':h(BIN),'xtermSha256':h(pathlib.Path(XT)),'source':'83094ca92acab37ed0a38042e2e40ead55049f41','test':'f8b95815616c850145b647aae57e082c7915dab0','expectedInitialTitle':original,'expectedFinalTitle':original,'expectedWireHex':(b'\x1b[22;2t\x1b]2;A\x07\x1b]2;B\x07\x1b[23;2t').hex(),'expectedRuntimeFailure':scenario=='ledger-error','expectedCallbackPrimary':'SESSION_CALLBACK_SENTINEL' if scenario=='ledger-error' else None,'noExplicitRestoreEvent':True}
  js(p/'launch.json',launch);hp=None;events=[];captures=[]
  try:
   hp=s.Popen(args,env=e,cwd=home,start_new_session=True,stdout=(p/'host.stdout').open('wb'),stderr=(p/'host.stderr').open('wb'));launch['hostPid']=hp.pid;js(p/'launch.json',launch)
   wait(lambda:(p/'consumer/before').exists(),'consumer native before')
   wait(lambda:(p/'outer-ansi.bin').exists() and b'CJTUI_SESSION_READY' in (p/'outer-ansi.bin').read_bytes(),'consumer real first frame')
   tree=run(['xwininfo','-root','-tree'],e);(p/'window-tree.txt').write_text(tree)
   win=next(line.split()[0] for line in tree.splitlines() if original in line)
   (p/'window-info.txt').write_text(run(['xwininfo','-id',win,'-all'],e))
   # The real XTerm PID is independently observable and owned by this launcher.
   pidprop=run(['xprop','-id',win,'_NET_WM_PID'],e);(p/'window-pid.txt').write_text(pidprop)
   def snap(name):
    before=utc();props=run(['xprop','-id',win,'WM_NAME','_NET_WM_NAME','WM_ICON_NAME','_NET_WM_ICON'],e);(p/(name+'-xprop.txt')).write_text(props)
    raw=re.search(r'^WM_NAME\([^)]*\) = ?(.*)',props,re.M).group(1);title=json.loads(raw) if raw else ''
    image=p/(name+'.png');cmd=['import','-window',win,str(image)];run(cmd,e)
    prev=(p/'native-grid.ansi').stat().st_mtime_ns if (p/'native-grid.ansi').exists() else -1
    keys.focus(win);keys.chord('F6')
    wait(lambda:(p/'native-grid.ansi').exists() and (p/'native-grid.ansi').stat().st_size>0 and (p/'native-grid.ansi').stat().st_mtime_ns>prev,'native XTerm print '+name)
    grid=p/(name+'-native-grid.ansi');shutil.copyfile(p/'native-grid.ansi',grid)
    item={'phase':name,'utcStart':before,'utcEnd':utc(),'windowId':win,'title':title,'png':image.name,'pngSha256':h(image),'captureCommand':shlex.join(cmd),'xprop':name+'-xprop.txt','nativeGrid':grid.name,'nativeGridSha256':h(grid)};captures.append(item);js(p/'captures.json',captures)
   keys.focus(win);snap('before')
   events.append({'utc':utc(),'XTEST':['x'],'meaning':'execute frozen lifecycle mode; no r input'})
   keys.chord('x')
   if scenario!='ledger-close':
    wait(lambda:(p/'consumer/wire.bin').exists() and (p/'consumer/wire.bin').stat().st_size==19,'complete owned save+titleA+titleB')
    wait(lambda:' = "B"' in run(['xprop','-id',win,'WM_NAME'],e),'actual owned title B')
    snap('owned-before-exit')
    if scenario=='ledger-error':keys.chord('e');events.append({'utc':utc(),'XTEST':['e'],'meaning':'frozen consumer callback Exception; UI/native close fault env recorded'})
    else:keys.chord('Control_L','c');events.append({'utc':utc(),'XTEST':['Control_L','c'],'meaning':'real keyboard cancellation byte0x03; no host kill'})
   wait(lambda:(p/'child-exit').exists(),'actual consumer returned and native termios collected')
   # Keep only the surrounding shell/XTerm alive for host observation after consumer run.
   wait(lambda:original in run(['xprop','-id',win,'WM_NAME'],e),'actual automatic restoration to initial title')
   snap('after-automatic-cleanup');js(p/'input-events.json',events)
   js(p/'consumer-exit-observation.json',{'utc':utc(),'consumerExit':int((p/'child-exit').read_text()),'actualNativeBefore':(p/'consumer/before').read_text().strip(),'actualNativeAfter':(p/'consumer/after').read_text().strip(),'scopeWasNotExplicitlyRestored':True,'windowKeptAliveBy':'outer shell waits without terminal output after formal host-consumer.sh returns'})
   (p/'release-window').write_text(utc());rc=hp.wait(timeout=10)
   launch.update(utcEnd=utc(),hostExitCode=rc);js(p/'launch.json',launch)
   summary['cases'].append({'scenario':scenario,'hostExit':rc,'consumerExit':int((p/'child-exit').read_text()),'captures':len(captures),'directory':str(p)})
   print(json.dumps(summary['cases'][-1]),flush=True)
  except BaseException as err:
   js(p/'failure.json',{'error':repr(err),'utc':utc()});raise
  finally:
   if hp and hp.poll() is None:
    os.killpg(hp.pid,signal.SIGTERM)
    try:hp.wait(timeout=5)
    except s.TimeoutExpired:os.killpg(hp.pid,signal.SIGKILL);hp.wait(timeout=5)
   shutil.rmtree(home)
finally:
 xp.terminate();summary.update(xorgExit=xp.wait(timeout=5),utcEnd=utc(),displaySocketRemoved=not os.path.lexists('/tmp/.X11-unix/X173'));js(R/'summary.json',summary)
