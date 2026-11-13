import os,pathlib,subprocess,time,json,shlex,signal,hashlib,re
from xtest import Keyboard
from xsize import hints,resize
from trace_bytes import extract
B=pathlib.Path('/workspace/work/keyboard-execution');binary=B/'source/tests/keyboard/formal_device/target/release/bin/main';tools=pathlib.Path(__file__).parent
for host in ['xterm','vte']:
 out=B/'raw'/('host-'+host);out.mkdir(exist_ok=False);home=out/'home';home.mkdir();env=dict(os.environ,DISPLAY=':199',HOME=str(home),XDG_CONFIG_HOME=str(home/'config'),XDG_CACHE_HOME=str(home/'cache'),LANG='C.UTF-8',LC_ALL='C.UTF-8')
 for k in ['XAUTHORITY','DBUS_SESSION_BUS_ADDRESS','SESSION_MANAGER','GTK_MODULES']:env.pop(k,None)
 os.environ['DISPLAY']=':199';keyboard=Keyboard();title='TASK116 keyboard '+host
 child=['python3',str(tools/'host-supervisor.py'),str(binary),str(out)]
 if host=='xterm':cmd=['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-geometry','60x12+20+20','-T',title,'-fa','DejaVu Sans Mono','-fs','16','-e',*child]
 else:cmd=['dbus-run-session','--','xfce4-terminal','--disable-server','--hide-menubar','--geometry=60x12+20+20','--title='+title,'--command='+shlex.join(child)]
 (out/'launch.json').write_text(json.dumps(dict(argv=cmd,env={k:env[k] for k in ['DISPLAY','HOME','XDG_CONFIG_HOME','XDG_CACHE_HOME']},source_sha='c3c4642d84df57bbd9550d222ed22f602acd13ef',binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest()),indent=2)+'\n')
 p=subprocess.Popen(cmd,env=env,stdout=(out/'host.stdout').open('wb'),stderr=(out/'host.stderr').open('wb'),start_new_session=True);clip=None;events=[]
 def raw():return extract((out/'product.strace').read_text(errors='replace'))[0] if (out/'product.strace').exists() else b''
 def wait(fn,label):
  end=time.monotonic()+20
  while time.monotonic()<end:
   if fn():return
   if p.poll() is not None:raise RuntimeError('host exited before '+label)
   time.sleep(.02)
  raise TimeoutError(label)
 def capture(name):subprocess.run(['import','-display',':199','-window',win,str(out/(name+'.png'))],check=True,timeout=10)
 def key(*names):keyboard.chord(*names);events.append(dict(key=list(names),monotonic_ns=time.monotonic_ns()))
 try:
  wait(lambda:b'CJTUI_KEYBOARD_FORMAL_READY' in raw(),'actual rendered frame')
  tree=subprocess.check_output(['xwininfo','-display',':199','-root','-tree'],text=True);(out/'window-tree.txt').write_text(tree);win=next(line.split()[0] for line in tree.splitlines() if title in line);keyboard.focus(win);capture('running')
  mapped=[]
  for row in subprocess.check_output(['ps','-eo','pid,comm,args'],text=True).splitlines():
   fields=row.strip().split(None,2)
   if len(fields)==3 and title in fields[2] and fields[1] in ['xterm','xfce4-terminal']:
    pid=int(fields[0]);exe=pathlib.Path('/proc',str(pid),'exe').resolve();maps=pathlib.Path('/proc',str(pid),'maps').read_text();libs=sorted(set(line.split()[-1] for line in maps.splitlines() if 'libvte-' in line))
    mapped.append(dict(pid=pid,exe=str(exe),exe_sha256=hashlib.sha256(exe.read_bytes()).hexdigest(),loaded_vte={v:hashlib.sha256(pathlib.Path(v).read_bytes()).hexdigest() for v in libs}))
  assert mapped
  (out/'host-identity.json').write_text(json.dumps(dict(host=host,mapped=mapped,version=subprocess.check_output([cmd[0],'-version'] if host=='xterm' else ['xfce4-terminal','--version'],env=env,text=True)),indent=2)+'\n')
  # Real XTEST key events enter the actual host; no byte injection on the PTY.
  for keys in [('a',),('Up',),('Down',),('Left',),('Right',),('Home',),('End',),('Insert',),('Delete',),('Prior',),('Next',),('F2',),('F5',),('F12',),('Control_L','Left'),('Shift_L','Tab'),('Alt_L','z')]:key(*keys)
  key('a')
  clip=subprocess.Popen(['/usr/bin/python3',str(tools/'clipboard-fixture.py'),str(out/'clipboard-ready')],env=env,stdout=(out/'clipboard.stdout').open('wb'),stderr=(out/'clipboard.stderr').open('wb'))
  wait(lambda:(out/'clipboard-ready').exists(),'external clipboard literal owner');key('Shift_L','Insert');wait(lambda:(out/'paste').exists(),'host bracketed paste callback');assert(out/'paste').read_text()=='A:HOST-PASTE-116;';capture('keys-paste')
  hi=hints(keyboard,win);pixels=resize(keyboard,win,50,10,hi);events.append(dict(resize_cells=[50,10],pixels=pixels));wait(lambda:'ws_row=10, ws_col=50' in (out/'product.strace').read_text(errors='replace'),'actual resize ioctl');capture('resized')
  key('q');wait(lambda:(out/'terminal-after.json').exists(),'actual binary exit');capture('restored');(out/'exit-release').write_text('release');rc=p.wait(timeout=10)
  result=json.loads((out/'terminal-after.json').read_text());assert result['product_exit']==0 and result['tracer_exit']==0 and result['termios_equal'];summary=(out/'summary').read_text();assert 'resources=0/0/0/0' in summary
  stdin,instats=extract((out/'product.strace').read_text(),0,'read');stdout,outstats=extract((out/'product.strace').read_text());(out/'input.raw').write_bytes(stdin);(out/'output.raw').write_bytes(stdout);assert b'\x1b[?2004h' in stdout and b'\x1b[?2004l' in stdout
  (out/'result.json').write_text(json.dumps(dict(host=host,frontend_exit=rc,terminal=result,events=events,summary=summary,wire_stats=dict(input=instats,output=outstats),paste='real ShiftInsert from external fixture; one frozen public callback A:HOST-PASTE-116;',key_scope='observed summary/raw only; frontend bindings and protocol limitations retained'),indent=2)+'\n')
 except BaseException as e:
  (out/'failure.json').write_text(json.dumps(dict(error=repr(e),events=events),indent=2)+'\n');raise
 finally:
  if clip and clip.poll() is None:clip.terminate();clip.wait(timeout=5)
  if p.poll() is None:os.killpg(p.pid,signal.SIGTERM);p.wait(timeout=5)
print('Actual XTerm/VTE keys, host paste, resize, direct exit and termios captured')
