"""TASK151 actual public consumer, owned Xorg/selection/mux/SSH only."""
import os,sys,pathlib,subprocess as s,time,json,hashlib,datetime,shlex,re,shutil,signal,socket
B=pathlib.Path('/workspace/work/session-extension-execution'); SRC=B/'source'; BIN=SRC/'tests/session_extensions/target/release/bin/main'
sys.path.insert(0,'/workspace/work/session-extension-recon/probes')
from xselection import Fixture
sys.path.insert(0,'/workspace/work/vte-grid-capture-recon/scripts')
from xtest import Keyboard
XT='/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm'; MX='/workspace/work/linux-console-hosts/hosts/debian/usr/bin/'
HOST=SRC/'tests/session_extensions/host-consumer.sh'; DENY='1,2,3,4,5,6,7,8,9,11,13,14,18,19,20,21,GetSelection,SetWinLines,SetXprop'
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def digest(p):return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def js(p,v):p.write_text(json.dumps(v,ensure_ascii=False,indent=2))
def wait(fn,seconds=15):
 end=time.monotonic()+seconds
 while time.monotonic()<end:
  value=fn()
  if value:return value
  time.sleep(.03)
 raise RuntimeError('timeout '+str(fn))
profiles=[
 dict(name='xterm-default'),dict(name='xterm-enabled',write=True),dict(name='xterm-titleoff',write=True,titleoff=True),
 dict(name='vte-default',vte=True),dict(name='vte-dynamic',vte=True,dynamic=True),
 dict(name='tmux-default',mux='tmux',write=True,stack=False),
 dict(name='tmux-allow',mux='tmux',write=True,opts=['set -s set-clipboard on','set -g set-titles on','set -g set-titles-string "#{pane_title}"']),
 dict(name='tmux-outer-deny',mux='tmux',opts=['set -s set-clipboard on'],stack=False),
 dict(name='tmux-pass-off',mux='tmux',write=True,route='TmuxPassthrough'),
 dict(name='tmux-pass-on',mux='tmux',write=True,route='TmuxPassthrough',opts=['set -g allow-passthrough on']),
 dict(name='screen-plain',mux='screen',write=True,stack=False),dict(name='screen-pass',mux='screen',write=True,route='ScreenPassthrough'),
 dict(name='ssh-enabled',ssh=True,write=True),dict(name='ssh-denied',ssh=True)]
if len(sys.argv)>1:profiles=[x for x in profiles if x['name'] in sys.argv[1].split(',')]
R=B/'raw'/os.environ.get('HOST_RUN','hosts');R.mkdir(exist_ok=False)
assert not os.path.lexists('/tmp/.X11-unix/X173') and not os.path.lexists('/tmp/.X173-lock'),'private display already occupied'
env=os.environ.copy()
for key in ['DISPLAY','XAUTHORITY','DBUS_SESSION_BUS_ADDRESS','SESSION_MANAGER','GTK_MODULES','TMUX','STY']:env.pop(key,None)
env.update(DISPLAY=':173',LC_ALL='C.UTF-8',LANG='C.UTF-8')
xp=s.Popen(['Xorg',':173','-config','/workspace/work/session-extension-recon/probes/xorg-dummy.conf','-nolisten','tcp','-noreset','-logfile',str(R/'xorg.log')],env=env,stdout=(R/'xorg.stdout').open('wb'),stderr=s.STDOUT)
def run(args,e=env,check=True):
 r=s.run(args,env=e,stdout=s.PIPE,stderr=s.STDOUT,text=True,timeout=20)
 if check and r.returncode:raise RuntimeError(str(args)+' '+r.stdout)
 return r.stdout
server=None;fix=None;results=[];summary={'start':utc(),'xorgPid':xp.pid}
try:
 wait(lambda:s.run(['xdpyinfo','-display',':173'],stdout=s.DEVNULL,stderr=s.DEVNULL).returncode==0)
 fix=Fixture(':173');os.environ['DISPLAY']=':173';keyboard=Keyboard()
 if any(x.get('ssh') for x in profiles):
  sock=socket.socket();sock.bind(('127.0.0.1',22473));sock.close()
  server=s.Popen(['/bin/sh','/workspace/work/session-extension-recon/ssh/probes/start-stock-sshd.sh'],stdout=(R/'sshd.stdout').open('wb'),stderr=(R/'sshd.log').open('wb'))
  def listening():
   try:
    with socket.create_connection(('127.0.0.1',22473),.1) as z:return z.recv(128).startswith(b'SSH-2.0-')
   except OSError:return False
  wait(listening)
  (R/'sshd-effective-config').write_text(run(['/usr/sbin/sshd','-T','-f','/workspace/work/session-extension-recon/ssh/sshd_config']))
 for profile in profiles:
  p=R/profile['name'];p.mkdir();home=B/'private-hosts'/R.name/profile['name'];home.mkdir(mode=0o700,parents=True)
  (home/'runtime').mkdir(mode=0o700)
  e=env.copy();e.update(HOME=str(home),XDG_CONFIG_HOME=str(home/'config'),XDG_CACHE_HOME=str(home/'cache'),XDG_RUNTIME_DIR=str(home/'runtime'))
  route=profile.get('route','Direct');stack=profile.get('stack',True);original='TASK151 '+profile['name'];mux=profile.get('mux');socketpath=None;hp=None
  child=[str(HOST),str(BIN),str(p/'consumer'),route,'declared' if stack else 'auto']
  config=p/'host.config';config.write_text(json.dumps(profile,indent=2)+'\n')
  if mux=='tmux':
   socketpath=str(home/'tmux.sock');config.write_text('\n'.join(profile.get('opts',[]))+'\n# private TASK151\n')
   child=[MX+'tmux','-S',socketpath,'-f',str(config),'new-session','-s','task151',shlex.join(child)]
  elif mux=='screen':
   (home/'screen').mkdir(mode=0o700);e['SCREENDIR']=str(home/'screen');config.write_text('startup_message off\n')
   child=[MX+'screen','-c',str(config),'-S','task151']+child
  sshobj=None
  if profile.get('ssh'):
   remote_child=shlex.join(['/bin/bash','-c','source /workspace/work/validation/sdk/cangjie/envsetup.sh; stty rows 28 cols 100; exec '+shlex.join(child)])
   remote=shlex.join(['/usr/bin/script','--quiet','--flush','--return','--log-out',str(p/'remote-pty-ansi.bin'),'--command',remote_child])
   keybase='/workspace/work/session-extension-recon/ssh/private/'
   child=['/usr/bin/ssh','-vvv','-E',str(p/'ssh-client.log'),'-F','/dev/null','-p','22473','-i',keybase+'client_ed25519','-o','IdentitiesOnly=yes','-o','BatchMode=yes','-o','StrictHostKeyChecking=yes','-o','UserKnownHostsFile='+keybase+'known_hosts','-o','GlobalKnownHostsFile=/dev/null','-o','ForwardAgent=no','-o','ForwardX11=no','-o','ClearAllForwardings=yes','-o','ControlMaster=no','-o','ProxyCommand=none','-T','agent@127.0.0.1',remote]
   sshobj={'topology':'stock OpenSSH loopback 127.0.0.1:22473, ssh -T + remote util-linux script PTY','clientLog':'ssh-client.log','remoteCommand':remote,'remoteGrid':[100,28]}
  rec=['script','--quiet','--flush','--return','--log-out',str(p/'outer-ansi.bin'),'--command',shlex.join(child)]
  if profile.get('vte'):
   cfg=home/'config/xfce4/terminal';cfg.mkdir(parents=True);(cfg/'terminalrc').write_text('[Configuration]\nFontName=DejaVu Sans Mono 12\nMiscAlwaysShowTabs=FALSE\nMiscMenubarDefault=TRUE\nMiscToolbarDefault=FALSE\n')
   module=home/'native-module.so';args=['gcc','-Wall','-Wextra','-Werror','-Wno-misleading-indentation','-fPIC','-shared','/workspace/work/vte-grid-capture-recon/scripts/native-module.c','-o',str(module),'-ldl']
   (p/'module-build.log').write_text(run(args));js(p/'module.json',{'argv':args,'sha256':digest(module),'sourceSha256':digest('/workspace/work/vte-grid-capture-recon/scripts/native-module.c'),'instrumented':True,'format':'native current viewport UTF8 text, not complete cell attributes'})
   e.update(GTK_MODULES=str(module),VTE_NATIVE_CAPTURE_DIR=str(p))
   titleargs=['--initial-title='+original,'--dynamic-title-mode=replace'] if profile.get('dynamic') else ['--title='+original]
   cmd=['dbus-run-session','--','xfce4-terminal','--disable-server','--geometry=100x28+20+20']+titleargs+['--command='+shlex.join(rec)]
  else:
   cmd=[XT,'-tn','xterm-256color','-geometry','100x28+20+20','-T',original,'-fa','Monospace','-fs','12','-xrm','XTerm*printerCommand: /bin/cat > '+shlex.quote(str(p/'native-grid.ansi')),'-xrm','XTerm*printAttributes: 2','-xrm','XTerm*VT100.translations: #override <Key>F6: print()']
   if profile.get('write'):cmd+=['-xrm','XTerm*allowWindowOps: false','-xrm','XTerm*disallowedWindowOps: '+DENY]
   if profile.get('titleoff'):cmd+=['-xrm','XTerm*allowTitleOps: false']
   cmd+=['-e']+rec
  start=utc();js(p/'launch.json',{'argv':cmd,'environment':{k:e[k] for k in ['DISPLAY','HOME','XDG_CONFIG_HOME','XDG_CACHE_HOME','XDG_RUNTIME_DIR','GTK_MODULES','VTE_NATIVE_CAPTURE_DIR'] if k in e},'utc':start,'profile':profile,'binary':str(BIN),'binarySha256':digest(BIN)})
  # Expected target values fixed from frozen permissions/path; never assigned from phase observations.
  titles={'initial':original,'A':'CJTUI_HOST_TITLE_A','B':'CJTUI_HOST_TITLE_B','restored':original}
  if profile.get('titleoff') or profile['name'] in ['vte-default','tmux-default','tmux-outer-deny','tmux-pass-off']:
   titles={phase:original for phase in ['initial','A','B','restored']}
  if profile['name']=='vte-dynamic':titles['restored']=''
  if profile['name']=='screen-plain':titles['restored']='CJTUI_HOST_TITLE_B'
  applied=profile['name'] in ['xterm-enabled','xterm-titleoff','tmux-allow','tmux-pass-on','screen-pass','ssh-enabled']
  seed='TASK151 own seed '+profile['name'];expected={'seedHex':seed.encode().hex(),'clipboardApplied':applied,'title':titles}
  try:
   hp=s.Popen(cmd,env=e,cwd=home,start_new_session=True,stdout=(p/'host.stdout').open('wb'),stderr=(p/'host.stderr').open('wb'))
   wait(lambda:(p/'consumer/before').exists())
   wait(lambda:'CJTUI_SESSION_READY'.encode() in (p/'outer-ansi.bin').read_bytes())
   tree=run(['xwininfo','-root','-tree'],e);(p/'initial-tree.txt').write_text(tree)
   win=next(line.split()[0] for line in tree.splitlines() if original in line or ('"XTerm"' in line and not profile.get('vte')))
   (p/'initial-window.txt').write_text(run(['xwininfo','-id',win,'-all'],e))
   if profile['name']=='tmux-allow':
    # Record pre-operation pane title independently as the title-stack target.
    pane=run([MX+'tmux','-S',socketpath,'display-message','-p','#{pane_title}'],e).strip()
    assert pane==os.uname().nodename,'initial tmux pane hostname assumption'
    titles['initial']=os.uname().nodename; titles['restored']=os.uname().nodename
   js(p/'expected.json',expected)
   fix.seed_clipboard(seed);before=fix.read_clipboard();assert before.get('hex')==expected['seedHex']
   keyboard.focus(win);keyboard.chord('p') # refresh real X server event timestamp after ownership
   observations={'title':{},'clipboardBeforeHex':before['hex']};screens=[]
   def capture(phase,index):
    time.sleep(1.15 if mux=='tmux' else .25)
    props=run(['xprop','-id',win,'WM_NAME','_NET_WM_NAME','WM_ICON_NAME','_NET_WM_ICON'],e);(p/(phase+'-xprop.txt')).write_text(props)
    raw=re.search(r'^WM_NAME\([^)]*\) = ?(.*)',props,re.M).group(1)
    observations['title'][phase]=json.loads(raw) if raw else ''
    icon=run(['xprop','-id',win,'_NET_WM_ICON'],e);(p/(phase+'-icon.txt')).write_text(icon)
    observations['iconBeforeSha256' if phase=='initial' else 'iconAfterSha256']=hashlib.sha256(icon.encode()).hexdigest()
    file=p/(phase+'.png');args=['import','-window',win,str(file)];run(args,e)
    screens.append({'file':file.name,'sha256':digest(file),'captureCommand':shlex.join(args),'windowId':win,'utc':utc()})
    if profile.get('vte'):
     (p/'native-request').write_text(str(index));wait(lambda:(p/f'native-{index}-meta.json').exists())
    if mux=='tmux':(p/(phase+'-pane-title.txt')).write_text(run([MX+'tmux','-S',socketpath,'display-message','-p','#{pane_title}'],e))
   capture('initial',0)
   for key,record,phase,index in [('c','host.copy',None,0),('a','host.title.A','A',1),('b','host.title.B','B',2),('r','host.restore','restored',3)]:
    keyboard.chord(key)
    wait(lambda: (p/'consumer/results.tsv').exists() and record+'\t' in (p/'consumer/results.tsv').read_text())
    if phase:capture(phase,index)
   after=fix.read_clipboard();observations['clipboardAfterHex']=after.get('hex');js(p/'clipboard.json',{'before':before,'after':after,'seed':seed,'expectedPayload':'CJTUI_HOST_中😀\nLOCAL'})
   if not profile.get('vte'):
    keyboard.chord('F6');wait(lambda:(p/'native-grid.ansi').exists() and (p/'native-grid.ansi').stat().st_size>0)
   if mux=='tmux':
    (p/'mux-grid.txt').write_text(run([MX+'tmux','-S',socketpath,'capture-pane','-p','-e'],e));(p/'mux-options.txt').write_text(run([MX+'tmux','-S',socketpath,'show-options','-g'],e))
   if mux=='screen':run([MX+'screen','-S','task151','-X','hardcopy',str(p/'mux-grid.txt')],e)
   # Actual product PID/executable/children snapshot, scoped to this run's exact executable.
   procs=[]
   for proc in pathlib.Path('/proc').iterdir():
    if not proc.name.isdigit():continue
    try:
     if (proc/'exe').resolve()==BIN:
      procs.append({'pid':int(proc.name),'exeSha256':digest(proc/'exe'),'cmdlineHex':(proc/'cmdline').read_bytes().hex(),'children':(proc/'task'/proc.name/'children').read_text()})
    except (OSError,RuntimeError):pass
   js(p/'product-processes.json',procs)
   keyboard.chord('q');rc=hp.wait(timeout=15)
   wait(lambda:(p/'consumer/after').exists())
   observations.update(termiosBefore=(p/'consumer/before').read_text().strip(),termiosAfter=(p/'consumer/after').read_text().strip(),exitCode=int((p/'consumer/exit').read_text()))
   js(p/'observations.json',observations)
   if sshobj:sshobj['remoteTty']=(p/'consumer/tty').read_text().strip()
   manifest={'kind':'cjtui-session-public-host-v1','profile':profile['name'],'sourceSha':'83094ca92acab37ed0a38042e2e40ead55049f41','binary':os.path.relpath(BIN,p),'binarySha256':digest(BIN),'host':{'name':'XFCE/VTE' if profile.get('vte') else 'XTerm'+('/'+mux if mux else ''),'version':'1.1.4/0.80.1' if profile.get('vte') else '398'+('/3.5a' if mux=='tmux' else '/4.09.01' if mux else ''),'configFile':'host.config','grid':list(reversed([int(n) for n in (p/'consumer/grid').read_text().split()]))},'route':route,'declareStack':stack,'utcStart':start,'utcEnd':utc(),'results':'consumer/results.tsv','operationWire':'consumer/wire.bin','fullStream':'outer-ansi.bin','nativeGrid':'native-2-visible.txt' if profile.get('vte') else 'native-grid.ansi','observations':'observations.json','expected':expected,'screenshots':screens}
   if sshobj:manifest['ssh']=sshobj
   js(p/'manifest.json',manifest)
   result=s.run(['node',str(SRC/'tests/session_extensions/host-oracle.mjs'),str(p/'manifest.json')],stdout=s.PIPE,stderr=s.PIPE,text=True)
   (p/'oracle.stdout').write_text(result.stdout);(p/'oracle.stderr').write_text(result.stderr)
   item={'profile':profile['name'],'hostExit':rc,'oracleExit':result.returncode,'utcEnd':utc()};results.append(item);print(json.dumps(item),flush=True)
  except BaseException as error:
   js(p/'failure.json',{'error':repr(error),'utc':utc()});results.append({'profile':profile['name'],'error':repr(error)});print(profile['name'],repr(error),flush=True)
  finally:
   if hp and hp.poll() is None:
    os.killpg(hp.pid,signal.SIGTERM)
    try:hp.wait(timeout=5)
    except s.TimeoutExpired:os.killpg(hp.pid,signal.SIGKILL);hp.wait(timeout=5)
   if socketpath:run([MX+'tmux','-S',socketpath,'kill-server'],e,False)
   shutil.rmtree(home)
finally:
 if fix:fix.close()
 if server:
  server.terminate();summary['sshdExit']=server.wait(timeout=5)
 xp.terminate();summary.update(xorgExit=xp.wait(timeout=5),end=utc(),displaySocketRemoved=not os.path.lexists('/tmp/.X11-unix/X173'),results=results)
 js(R/'summary.json',summary)
sys.exit(0 if all(x.get('oracleExit')==0 and x.get('hostExit')==0 for x in results) else 1)
