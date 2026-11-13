import os,pathlib,subprocess,time,json,shlex,signal,hashlib,sys,datetime
sys.path.insert(0,'/workspace/work/keyboard-execution/tools');from xtest import Keyboard
from xsize import hints,resize
from trace_bytes import extract
B=pathlib.Path('/workspace/work/widgets-small-execution');host,mode=sys.argv[1:3];out=B/'raw'/('host-'+host+'-'+mode);out.mkdir(exist_ok=False);home=out/'home';home.mkdir();env=dict(os.environ,DISPLAY=':199',HOME=str(home),XDG_CONFIG_HOME=str(home/'config'),XDG_CACHE_HOME=str(home/'cache'),LANG='C.UTF-8',LC_ALL='C.UTF-8')
for k in ['XAUTHORITY','DBUS_SESSION_BUS_ADDRESS','SESSION_MANAGER','GTK_MODULES']:env.pop(k,None)
os.environ['DISPLAY']=':199';keyboard=Keyboard();title='TASK156 '+host+' '+mode
binary=B/'clean/cjtui-0.0.0'/('examples/widgets_small/target/release/bin/main' if mode=='example' else 'tests/widgets_small/device/target/release/bin/main');child=['python3',str(B/'tools/host-supervisor.py'),str(binary),str(out),mode]
cmd=['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-geometry','60x12+20+20','-T',title,'-fa','DejaVu Sans Mono','-fs','16','-e',*child] if host=='xterm' else ['dbus-run-session','--','xfce4-terminal','--disable-server','--hide-menubar','--geometry=60x12+20+20','--title='+title,'--command='+shlex.join(child)]
(out/'launch.json').write_text(json.dumps(dict(argv=cmd,fixed_source_sha='1df1325f7b51777d8adab62f950c936051aa5876',binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),uid=os.getuid(),connection='local X11 :199; XTEST keys→actual host PTY',config={k:env[k] for k in ['DISPLAY','HOME','XDG_CONFIG_HOME','XDG_CACHE_HOME']}),indent=2)+'\n')
p=subprocess.Popen(cmd,env=env,stdout=(out/'host.stdout').open('wb'),stderr=(out/'host.stderr').open('wb'),start_new_session=True);events=[]
def raw():return extract((out/'product.strace').read_text(errors='replace'))[0] if (out/'product.strace').exists() else b''
def wait(fn,label):
 end=time.monotonic()+25
 while time.monotonic()<end:
  if fn():return
  if p.poll() is not None:raise RuntimeError('host exited before '+label)
  time.sleep(.02)
 raise TimeoutError(label)
def key(*names):keyboard.chord(*names);events.append(dict(key=list(names),monotonic_ns=time.monotonic_ns()))
def quiet():
 end=time.monotonic()+8;last=None;since=time.monotonic()
 while time.monotonic()<end:
  now=raw()
  if now!=last:last=now;since=time.monotonic()
  elif time.monotonic()-since>.4:return
  time.sleep(.05)
def capture(name):
 quiet();subprocess.run(['import','-display',':199','-window',win,str(out/(name+'.png'))],env=env,check=True,timeout=10);events.append(dict(capture=name,monotonic_ns=time.monotonic_ns()))
def file(name):return (out/name).read_text() if (out/name).exists() else ''
try:
 wait(lambda:(b'Small widgets' if mode=='example' else b'S_WIDGETS_READY') in raw(),'actual native frame');tree=subprocess.check_output(['xwininfo','-display',':199','-root','-tree'],env=env,text=True);(out/'window-tree.txt').write_text(tree);win=next(line.split()[0] for line in tree.splitlines() if title in line);keyboard.focus(win);capture('running')
 identities=[]
 for row in subprocess.check_output(['ps','-eo','pid,comm,args'],text=True).splitlines():
  f=row.strip().split(None,2)
  if len(f)==3 and title in f[2] and f[1] in ['xterm','xfce4-terminal']:
   pid=int(f[0]);exe=pathlib.Path('/proc',str(pid),'exe').resolve();maps=pathlib.Path('/proc',str(pid),'maps').read_text();libs=sorted(set(x.split()[-1] for x in maps.splitlines() if 'libvte-' in x));identities.append(dict(pid=pid,exe=str(exe),exe_sha256=hashlib.sha256(exe.read_bytes()).hexdigest(),vte={v:hashlib.sha256(pathlib.Path(v).read_bytes()).hexdigest() for v in libs}))
 (out/'host-identity.json').write_text(json.dumps(dict(identities=identities,version=subprocess.check_output(['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-version'] if host=='xterm' else ['xfce4-terminal','--version'],env=env,text=True),capability_source='Actual TERM/TTY native detection with raw probes, classic default theme; no synthetic reply'),indent=2)+'\n')
 key('Return')
 if mode=='normal':wait(lambda:file('button')=='1','frozen Enter button callback1')
 capture('button-enter');key('Tab');capture('checkbox-focused');key('space')
 if mode=='normal':wait(lambda:file('checkbox')=='1','frozen Space checkbox callback1')
 capture('checkbox-request');key('Tab');key('Return')
 if mode=='normal':wait(lambda:file('radio')=='1','frozen Enter radio callback1')
 capture('radio-selected');key('space');capture('radio-already-selected')
 hi=hints(keyboard,win);pix=resize(keyboard,win,50,10,hi);events.append(dict(resize_cells=[50,10],pixels=pix));wait(lambda:'ws_row=10, ws_col=50' in (out/'product.strace').read_text(errors='replace'),'native resize50x10');capture('resized');key('q');wait(lambda:(out/'terminal-after.json').exists(),'direct exit');capture('restored');(out/'exit-release').write_text('release');rc=p.wait(timeout=10)
 result=json.loads((out/'terminal-after.json').read_text());trace=(out/'product.strace').read_text();inp,ins=extract(trace,0,'read');wire,outs=extract(trace);(out/'input.raw').write_bytes(inp);(out/'output.raw').write_bytes(wire);summary=dict(x.split('=',1) for x in file('summary').splitlines())
 if mode=='normal':
  expected=dict(clicks='1',boxRequests='1',checked='true',radioRequests='1',selected='true',cleanups='1',resources='0/0/0/0');assert summary==expected,(summary,expected)
 (out/'result.json').write_text(json.dumps(dict(host=host,mode=mode,frontend_exit=rc,terminal=result,events=events,summary=summary,wire_stats=[ins,outs],oracle_source='Unchanged tests/widgets_small/pty.py normal literal summary and native key sequence. Example is observational, no new Cj fixture.',unicode='Existing native example/device captions ASCII only; new S Unicode host captions unexercised; headless S literal Unicode and unchanged accepted E projection are separate evidence.',theme='Classic focused/selected appearance observed; disabled/explicit custom palette only frozen headless suite, not claimed new native evidence.'),indent=2)+'\n')
 assert result['product_exit']==0 and result['tracer_exit']==0 and result['termios_equal'],result
except BaseException as e:(out/'failure.json').write_text(json.dumps(dict(error=repr(e),events=events),indent=2)+'\n');raise
finally:
 if p.poll() is None:os.killpg(p.pid,signal.SIGTERM);p.wait(timeout=5)
print('Actual S host captured',host,mode)
