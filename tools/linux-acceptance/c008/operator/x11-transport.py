#!/usr/bin/env python3
"""Existing Xlib/XTest host plumbing, no terminal parser or expected data."""
import ctypes as C,hashlib,json,os,pathlib,re,subprocess as S,sys,time
from paste002_capture import capture,complete_capture,load_before,utc
r=json.loads(sys.argv[1]);out=pathlib.Path(r['dir']);op=r['op']
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1' and os.environ.get('C008_DISPLAY_OWNED')=='1'
if op=='paste002-before':
 print(json.dumps(capture(out,'gui-selection')));sys.exit()
def call(args,**kw):return S.run(args,check=True,capture_output=True,**kw).stdout
kind=os.environ['C008_HOST_KIND'];title={'xterm':'C008 owned xterm','vte':'C008 owned VTE','tmux':'C008 owned tmux','screen':'C008 owned screen','ssh':'C008 owned SSH'}[kind]
def find():
 tree=call(['xwininfo','-root','-tree']).decode();matches=[int(line.split()[0],16) for line in tree.splitlines() if '"'+title+'"' in line]
 assert len(matches)==1,('owned title must identify one window',matches);return matches[0]
if op=='capture':
 try:
  wid=find();name='original-'+str(time.time_ns())+'.png';call(['import','-window',hex(wid),str(out/name)]);print(json.dumps({'png':name,'sha256':hashlib.sha256((out/name).read_bytes()).hexdigest(),'window':hex(wid),'utc_ns':time.time_ns()}));sys.exit()
 except Exception as e:
  print(json.dumps({'captureUnavailable':str(e),'utc_ns':time.time_ns()}));sys.exit(3)
wid=find()
x=C.CDLL('libX11.so.6');t=C.CDLL('libXtst.so.6')
x.XOpenDisplay.argtypes=[C.c_char_p];x.XOpenDisplay.restype=C.c_void_p
x.XStringToKeysym.argtypes=[C.c_char_p];x.XStringToKeysym.restype=C.c_ulong
x.XKeysymToKeycode.argtypes=[C.c_void_p,C.c_ulong];x.XKeysymToKeycode.restype=C.c_uint
x.XSetInputFocus.argtypes=[C.c_void_p,C.c_ulong,C.c_int,C.c_ulong]
x.XSync.argtypes=[C.c_void_p,C.c_int];x.XResizeWindow.argtypes=[C.c_void_p,C.c_ulong,C.c_uint,C.c_uint]
x.XInternAtom.argtypes=[C.c_void_p,C.c_char_p,C.c_int];x.XInternAtom.restype=C.c_ulong
x.XGetSelectionOwner.argtypes=[C.c_void_p,C.c_ulong];x.XGetSelectionOwner.restype=C.c_ulong
x.XCloseDisplay.argtypes=[C.c_void_p];t.XTestFakeKeyEvent.argtypes=[C.c_void_p,C.c_uint,C.c_int,C.c_ulong]
d=x.XOpenDisplay(os.environ['DISPLAY'].encode());assert d
x.XSetInputFocus(d,wid,1,0);x.XSync(d,0)
def key(name,mods=()):
 codes=[x.XKeysymToKeycode(d,x.XStringToKeysym(v.encode())) for v in [*mods,name]];assert all(codes),(name,mods)
 for code in codes[:-1]:assert t.XTestFakeKeyEvent(d,code,1,0)
 assert t.XTestFakeKeyEvent(d,codes[-1],1,0);assert t.XTestFakeKeyEvent(d,codes[-1],0,0)
 for code in reversed(codes[:-1]):assert t.XTestFakeKeyEvent(d,code,0,0)
 x.XSync(d,0)
def dims():
 reader=os.environ.get('C008_DIMENSIONS_READER')
 value=call([reader,r['tty']] if reader else ['stty','-F',r['tty'],'size']).decode().split()
 return tuple(map(int,value))
try:
 if op=='identify':result={'window':hex(wid),'dimensions':dims(),'title':title}
 elif op=='resize':
  target=(r['rows'],r['cols']);before=dims()
  for attempt in range(16):
   current=dims()
   if current==target:break
   info=call(['xwininfo','-id',hex(wid)]).decode();w,h=[int(re.search(r'^  '+n+r': (\d+)',info,re.M).group(1)) for n in ['Width','Height']]
   x.XResizeWindow(d,wid,max(1,w+(target[1]-current[1])*max(1,w//current[1])),max(1,h+(target[0]-current[0])*max(1,h//current[0])));x.XSync(d,0)
   end=time.monotonic()+3
   while time.monotonic()<end and dims()==current:time.sleep(.02)
  assert dims()==target,('outer resize did not reach actual child PTY',target,dims())
  result={'before':before,'after':dims(),'window':hex(wid),'operation':'XResizeWindow only; no stty/ioctl/SIGWINCH mutation'}
 elif op=='input':
  s=bytes.fromhex(r['hex']).decode();actions=[]
  if r.get('paste002'):load_before(out,r['paste002']['before'],'gui-selection')
  paste_source=None;packet_observation=None
  sequences={'\x1bOP':('F1',()),'\x1bOQ':('F2',()),'\x1bOR':('F3',()),'\x1bOS':('F4',()),'\x1b[15~':('F5',()),'\x1b[17~':('F6',()),'\x1b[18~':('F7',()),'\x1b[19~':('F8',()),'\x1b[20~':('F9',()),'\x1b[21~':('F10',()),'\x1b[Z':('Tab',('Shift_L',)),'\x1b[A':('Up',()),'\x1b[B':('Down',()),'\x1b[C':('Right',()),'\x1b[D':('Left',()),'\x1b[H':('Home',()),'\x1b[F':('End',()),'\x1b[6~':('Next',()),'\x1b[1;2C':('Right',('Shift_L',)),'\x1b[1;2D':('Left',('Shift_L',))}
  while s:
   if s.startswith('\x1b[200~'):
    end=s.index('\x1b[201~');payload=s[6:end];s=s[end+6:]
    if r.get('paste002'):
     assert paste_source is None and payload.encode().hex()==r['paste002']['sourceHex'],'INSUFFICIENT_EVIDENCE PASTE002 selected source identity'
     paste_source={'sourceHex':payload.encode().hex(),'sourceSha256':hashlib.sha256(payload.encode()).hexdigest(),'route':'owned PRIMARY selection','selectedUTC':utc()}
    # Dedicated X server only. Own PRIMARY selection; read no prior selection.
    clipboard=os.environ['C008_CLIPBOARD_OWNER'];owner=S.Popen([clipboard,'-quiet','-selection','primary','-in'],stdin=S.PIPE,stdout=S.DEVNULL,stderr=S.DEVNULL)
    try:
     owner.stdin.write(payload.encode());owner.stdin.close()
     atom=x.XInternAtom(d,b'PRIMARY',0);deadline=time.monotonic()+3
     while not x.XGetSelectionOwner(d,atom) and time.monotonic()<deadline:time.sleep(.01)
     assert x.XGetSelectionOwner(d,atom),'owned PRIMARY selection unavailable'
     key('Insert',('Shift_L',))
     if r.get('paste002'):packet_observation=complete_capture(out,'gui-selection',r['paste002']['before'])
     else:
      deadline=time.monotonic()+5;input_path=out/'transport/input.raw'
      while time.monotonic()<deadline:
       if input_path.exists() and payload.encode() in input_path.read_bytes():break
       time.sleep(.02)
      else:raise RuntimeError('owned paste bytes not observed in actual input')
     actions.append({'pasteUtf8Hex':payload.encode().hex(),'selection':'owned PRIMARY','ownerPid':owner.pid})
    finally:
     owner.terminate()
     try:owner.wait(timeout=2)
     except S.TimeoutExpired:owner.kill();owner.wait(timeout=2)
    continue
   found=False
   for seq,(name,mods) in sorted(sequences.items(),key=lambda v:-len(v[0])):
    if s.startswith(seq):key(name,mods);actions.append([name,list(mods)]);s=s[len(seq):];found=True;break
   if found:continue
   ch=s[0];s=s[1:]
   if ch in '\x01\x19\x1a':name=chr(ord(ch)+96);mods=('Control_L',)
   elif ch in {'\t','\r','\n','\x1b','\x7f',' '}:name={'\t':'Tab','\r':'Return','\n':'Return','\x1b':'Escape','\x7f':'BackSpace',' ':'space'}[ch];mods=()
   elif ch.isascii() and ch.isalnum():name=ch.lower();mods=('Shift_L',) if ch.isupper() else ()
   elif ch=='!':name='1';mods=('Shift_L',)
   else:raise ValueError('unsupported actual key transport; no fallback direct PTY injection: '+repr(ch))
   key(name,mods);actions.append([name,list(mods)])
  result={'window':hex(wid),'actions':actions,'utc_ns':time.time_ns()}
  if r.get('paste002'):
   assert paste_source and packet_observation,'INSUFFICIENT_EVIDENCE PASTE002 native paste not performed'
   result.update(paste002=packet_observation,pasteSource=paste_source)
 else:raise ValueError(op)
 print(json.dumps(result))
finally:x.XCloseDisplay(d)
