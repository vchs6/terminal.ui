import os,pathlib,subprocess,time,json,shlex,signal,hashlib,sys,datetime
sys.path.insert(0,'/workspace/work/keyboard-execution/tools')
from xtest import Keyboard
from xsize import hints,resize
from trace_bytes import extract
B=pathlib.Path('/workspace/work/editing-execution');host,mode=sys.argv[1:3];out=B/'raw'/('host-'+host+'-'+mode);out.mkdir(exist_ok=False);home=out/'home';home.mkdir();env=dict(os.environ,DISPLAY=':199',HOME=str(home),XDG_CONFIG_HOME=str(home/'config'),XDG_CACHE_HOME=str(home/'cache'),LANG='C.UTF-8',LC_ALL='C.UTF-8')
for k in ['XAUTHORITY','DBUS_SESSION_BUS_ADDRESS','SESSION_MANAGER','GTK_MODULES']:env.pop(k,None)
os.environ['DISPLAY']=':199';keyboard=Keyboard();title='TASK121 '+host+' '+mode
binary=B/'clean-unpacked/cjtui-0.0.0'/('examples/editing/target/release/bin/main' if mode=='example' else 'tests/editing/target/release/bin/main')
child=['python3',str(B/'tools/host-supervisor.py'),str(binary),str(out),mode]
if host=='xterm':cmd=['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-geometry','60x12+20+20','-T',title,'-fa','DejaVu Sans Mono','-fs','16','-xrm','XTerm*allowWindowOps: true','-e',*child]
else:cmd=['dbus-run-session','--','xfce4-terminal','--disable-server','--hide-menubar','--geometry=60x12+20+20','--title='+title,'--command='+shlex.join(child)]
(out/'launch.json').write_text(json.dumps(dict(argv=cmd,env={k:env[k] for k in ['DISPLAY','HOME','XDG_CONFIG_HOME','XDG_CACHE_HOME']},fixed_source_sha='22ca8cf7c756c5185064a6f8bc7e9f2c58d4f167',binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),connection='local X11 :199; actual XTEST key events, host-produced PTY input'),indent=2)+'\n')
p=subprocess.Popen(cmd,env=env,stdout=(out/'host.stdout').open('wb'),stderr=(out/'host.stderr').open('wb'),start_new_session=True);clip=None;events=[]
def raw():return extract((out/'product.strace').read_text(errors='replace'))[0] if (out/'product.strace').exists() else b''
def wait(fn,label):
 end=time.monotonic()+25
 while time.monotonic()<end:
  if fn():return
  if p.poll() is not None:raise RuntimeError('host exited before '+label)
  time.sleep(.02)
 raise TimeoutError(label)
def key(*names):keyboard.chord(*names);events.append(dict(key=list(names),monotonic_ns=time.monotonic_ns()))
def capture(name):
 subprocess.run(['import','-display',':199','-window',win,str(out/(name+'.png'))],env=env,check=True,timeout=10)
 events.append(dict(capture=name,monotonic_ns=time.monotonic_ns()))
def seed(text,name):
 global clip
 if clip and clip.poll() is None:clip.terminate();clip.wait(timeout=5)
 f=out/(name+'.literal');f.write_text(text);ready=out/(name+'.ready');clip=subprocess.Popen(['/usr/bin/python3',str(B/'tools/clipboard-fixture.py'),str(f),str(ready)],env=env,stdout=(out/(name+'.stdout')).open('wb'),stderr=(out/(name+'.stderr')).open('wb'));wait(ready.exists,'external clipboard fixture '+name)
def observe(name):
 r=subprocess.run(['/usr/bin/python3',str(B/'tools/clipboard-observe.py')],env=env,capture_output=True,timeout=15);(out/(name+'.json')).write_bytes(r.stdout);(out/(name+'.stderr')).write_bytes(r.stderr);events.append(dict(clipboard_external_observer=name,exit=r.returncode))
try:
 marker=b'Tab changes focus' if mode=='example' else b'CJTUI_EDITING_READY';wait(lambda:marker in raw(),'actual rendered frame')
 tree=subprocess.check_output(['xwininfo','-display',':199','-root','-tree'],env=env,text=True);(out/'window-tree.txt').write_text(tree);win=next(line.split()[0] for line in tree.splitlines() if title in line);keyboard.focus(win);capture('running')
 mapped=[]
 for row in subprocess.check_output(['ps','-eo','pid,comm,args'],text=True).splitlines():
  fields=row.strip().split(None,2)
  if len(fields)==3 and title in fields[2] and fields[1] in ['xterm','xfce4-terminal']:
   pid=int(fields[0]);exe=pathlib.Path('/proc',str(pid),'exe').resolve();maps=pathlib.Path('/proc',str(pid),'maps').read_text();libs=sorted(set(line.split()[-1] for line in maps.splitlines() if 'libvte-' in line));mapped.append(dict(pid=pid,exe=str(exe),exe_sha256=hashlib.sha256(exe.read_bytes()).hexdigest(),loaded_vte={v:hashlib.sha256(pathlib.Path(v).read_bytes()).hexdigest() for v in libs}))
 (out/'host-identity.json').write_text(json.dumps(dict(host=host,mapped=mapped,version=subprocess.check_output(['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-version'] if host=='xterm' else ['xfce4-terminal','--version'],env=env,text=True),capability_source='actual TTY and TERM plus product-native detection; raw probe traffic retained; explicit route Direct only in frozen test modes'),indent=2)+'\n')
 if mode=='example':
  for ch in 'abc':key(ch)
  key('Shift_L','Left');capture('single-selection')
  seed('EXTERNAL-SENTINEL','sentinel');key('Control_L','c');observe('clipboard-after-copy');capture('single-copy')
  key('Control_L','x');capture('single-cut-retained')
  seed('e\u0301中👩\u200d💻\nrow','unicode');key('Shift_L','Insert');capture('single-reject-multiline')
  key('Tab');key('Shift_L','Insert');capture('area-unicode-paste')
  key('Control_L','z');capture('area-undo');key('Control_L','y');capture('area-redo')
  for names in [('Home',),('Shift_L','End'),('Up',),('Down',),('Control_L','Home'),('Control_L','End')]:key(*names)
  capture('area-navigation')
  hi=hints(keyboard,win);pixels=resize(keyboard,win,50,10,hi);events.append(dict(resize_cells=[50,10],pixels=pixels));wait(lambda:'ws_row=10, ws_col=50' in (out/'product.strace').read_text(errors='replace'),'actual resize ioctl');time.sleep(.2);capture('resized')
  key('Right');key('Control_L','c')
 elif mode=='sent':
  seed('EXTERNAL-SENTINEL','sentinel');key('c')
 elif mode=='paste':
  seed('A\n中','golden-paste');key('Shift_L','Insert');wait(lambda:(out/'changed').exists(),'frozen paste onChange');capture('pasted');key('u');wait(lambda:(out/'undone').exists(),'frozen undo redo golden');capture('undo-redo');key('q')
 wait(lambda:(out/'terminal-after.json').exists(),'actual binary exit');capture('restored')
 if mode=='sent':observe('clipboard-after-independent-direct-copy')
 (out/'exit-release').write_text('release');rc=p.wait(timeout=10);result=json.loads((out/'terminal-after.json').read_text())
 trace=(out/'product.strace').read_text();inp,ins=extract(trace,0,'read');output,outs=extract(trace);(out/'input.raw').write_bytes(inp);(out/'output.raw').write_bytes(output)
 summary=(out/'summary').read_text() if (out/'summary').exists() else None
 (out/'result.json').write_text(json.dumps(dict(host=host,mode=mode,frontend_exit=rc,terminal=result,events=events,summary=summary,wire_stats=dict(input=ins,output=outs),scope='Unchanged packaged public example observation or frozen independent golden; product Sent status is never promoted by external delivery observation',utc=datetime.datetime.now(datetime.timezone.utc).isoformat()),indent=2)+'\n')
 if result['product_exit']!=0 or result['tracer_exit']!=0 or not result['termios_equal']:raise RuntimeError('direct exit/termios failure '+str(result))
except BaseException as e:
 (out/'failure.json').write_text(json.dumps(dict(error=repr(e),events=events),indent=2)+'\n');raise
finally:
 if clip and clip.poll() is None:clip.terminate();clip.wait(timeout=5)
 if p.poll() is None:os.killpg(p.pid,signal.SIGTERM);p.wait(timeout=5)
print('Actual host observation captured',host,mode)
