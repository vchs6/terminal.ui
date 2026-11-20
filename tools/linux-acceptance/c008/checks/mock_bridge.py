"""Execute the actual Python bridge with file-only fake device boundaries."""
import ctypes,hashlib,io,json,os,pathlib,runpy,socket,subprocess,sys,types
operator=pathlib.Path(__file__).resolve().parent.parent/'operator';sys.path.insert(0,str(operator))
request=json.loads(sys.argv[2]);out=pathlib.Path(request['dir']);route=sys.argv[1]
def append_input(data):
 if route=='gui-selection':
  with (out/'transport/input.raw').open('ab') as f:f.write(data)
 else:
  he=''.join('\\x%02x'%b for b in data);n=len(data)
  trace=f'123 1760000000.000001 read(0</dev/tty1<char 4:1>>, "{he}", {n}) = {n}\n'.encode()
  with (out/'vt-run/vt-serial.log').open('ab') as f:f.write(b'TRACE hex='+trace.hex().encode()+b'\n')
def fixture_wire(data):
 custom=os.environ.get('MOCK_PACKET_HEX')
 return bytes.fromhex(custom) if custom is not None else data.replace(b'\n',b'\r') if route=='gui-selection' else data
class Fn:
 def __init__(self,fn):self.fn=fn
 def __call__(self,*args):return self.fn(*args)
class Lib:
 def __init__(self):
  def sym(name):return int.from_bytes(name,'big')
  def event(display,code,down,delay):
   if code==sym(b'Insert') and not down:append_input(fixture_wire(b'\x1b[200~'+selection.getvalue()+b'\x1b[201~'))
   elif not down and code in [sym(b'Tab'),sym(b'a')]:append_input(b'\t' if code==sym(b'Tab') else b'\x01')
   return 1
  for name,fn in {'XOpenDisplay':lambda *_:1,'XStringToKeysym':sym,'XKeysymToKeycode':lambda d,v:v,'XSetInputFocus':lambda *_:1,'XSync':lambda *_:1,'XResizeWindow':lambda *_:1,'XInternAtom':lambda *_:1,'XGetSelectionOwner':lambda *_:55,'XCloseDisplay':lambda *_:1,'XTestFakeKeyEvent':event}.items():setattr(self,name,Fn(fn))
ctypes.CDLL=lambda _:Lib()
class KeepBytes(io.BytesIO):
 def close(self):pass
selection=KeepBytes()
class Clipboard:
 pid=456;stdin=selection
 def terminate(self):
  with (out/'mock-clipboard-cleanup.log').open('a') as f:f.write('terminate\n')
 def wait(self,timeout=None):
  with (out/'mock-clipboard-cleanup.log').open('a') as f:f.write('wait\n')
  return 0
 def kill(self):pass
subprocess.Popen=lambda *a,**k:Clipboard()
def run(argv,**kw):
 title={'xterm':'xterm','vte':'VTE','tmux':'tmux','screen':'screen','ssh':'SSH'}[os.environ.get('C008_HOST_KIND','xterm')]
 if argv[0]=='xwininfo':return types.SimpleNamespace(stdout=f'0x1 "C008 owned {title}"\n'.encode())
 if argv[0]=='stty':return types.SimpleNamespace(stdout=b'24 80\n')
 raise AssertionError('unexpected external command '+repr(argv))
subprocess.run=run
class Channel:
 def __init__(self):self.map=None;self.reply=0;self.qmp=False
 def __enter__(self):return self
 def __exit__(self,*args):pass
 def connect(self,path):self.qmp=path.endswith('vt-qmp.sock')
 def settimeout(self,*a):pass
 def sendall(self,data):
  assert data.startswith(b'm')
  payload=bytes.fromhex(data[1:].decode().strip());(out/'mock-map.raw').write_bytes(payload)
  with (out/'vt-run/vt-serial.log').open('ab') as f:f.write(f'MAP_READY seq=1 tty=/dev/tty1 keycode=88 func=11 controlled_bytes_hex={payload.hex()}\n'.encode())
 def makefile(self,*a,**k):return self
 def readline(self):
  if self.reply==0:self.reply=-1;return b'{"QMP":{}}\n'
  return json.dumps({'return':{},'id':self.reply}).encode()+b'\n'
 def write(self,data):
  req=json.loads(data);self.reply=req['id']
  if req['execute']=='send-key':append_input(fixture_wire((out/'mock-map.raw').read_bytes()))
socket.socket=lambda *a,**k:Channel()
os.environ.update(C008_ROOT_ACTUAL_GO='1',C008_DISPLAY_OWNED='1',DISPLAY='FIXTURE_ONLY',C008_CLIPBOARD_OWNER='FIXTURE_ONLY')
sys.argv=[str(operator/('x11-transport.py' if route=='gui-selection' else 'vt-transport.py')),json.dumps(request)]
runpy.run_path(sys.argv[0],run_name='__main__')
