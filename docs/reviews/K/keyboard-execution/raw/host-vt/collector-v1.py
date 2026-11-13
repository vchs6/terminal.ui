import os,pathlib,subprocess,time,socket,json,re,base64,tarfile,io,hashlib
from trace_bytes import extract
B=pathlib.Path('/workspace/work/keyboard-execution');out=B/'raw/host-vt';out.mkdir(exist_ok=False);host=pathlib.Path('/workspace/work/linux-console-hosts');initrd=B/'artifacts/keyboard-vt.cpio.gz';env=dict(os.environ,LD_LIBRARY_PATH=str(host/'hosts/debian/usr/lib/x86_64-linux-gnu'))
cmd=[str(host/'hosts/debian/usr/bin/qemu-system-x86_64'),'-accel','tcg','-cpu','max','-machine','pc','-m','512','-smp','1','-no-reboot','-nic','none','-L',str(host/'hosts/debian/usr/share/qemu'),'-bios',str(host/'hosts/debian/usr/share/seabios/bios-256k.bin'),'-device','VGA,romfile='+str(host/'hosts/debian/usr/share/seabios/vgabios-stdvga.bin'),'-vga','none','-display','none','-serial','file:'+str(out/'serial.log'),'-chardev','socket,id=probe,path='+str(out/'control.sock')+',server=on,wait=off','-serial','chardev:probe','-qmp','unix:'+str(out/'qmp.sock')+',server=on,wait=off','-kernel',str(host/'packages/linux'),'-initrd',str(initrd),'-append','console=tty0 console=ttyS0,115200 rdinit=/init nomodeset vga=normal loglevel=4 scene=host-observation']
(out/'launch.json').write_text(json.dumps(dict(argv=cmd,virtual_hardware=True,source_sha='c3c4642d84df57bbd9550d222ed22f602acd13ef',initrd_sha256=hashlib.sha256(initrd.read_bytes()).hexdigest(),kernel_sha256=hashlib.sha256((host/'packages/linux').read_bytes()).hexdigest()),indent=2)+'\n')
p=subprocess.Popen(cmd,env=env,stdout=(out/'qemu.stdout').open('wb'),stderr=(out/'qemu.stderr').open('wb'));q=None;control=None;log=None;events=[]
def serial():return(out/'serial.log').read_text(errors='replace') if(out/'serial.log').exists() else ''
def wait(fn,label,seconds=45,allow_exit=False):
 end=time.monotonic()+seconds
 while time.monotonic()<end:
  x=fn()
  if x:return x
  if p.poll() is not None and not allow_exit:raise RuntimeError('guest exit before '+label)
  time.sleep(.02)
 raise TimeoutError(label)
try:
 wait(lambda:(out/'qmp.sock').exists(),'QMP socket');q=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);q.settimeout(10);q.connect(str(out/'qmp.sock'));f=q.makefile('rwb',buffering=0);log=(out/'qmp.jsonl').open('w');seq=0
 def receive():
  d=json.loads(f.readline());log.write(json.dumps(dict(receive=d,monotonic_ns=time.monotonic_ns()))+'\n');log.flush();return d
 def command(name,args=None):
  global seq
  seq+=1;d=dict(execute=name,id=seq)
  if args:d['arguments']=args
  log.write(json.dumps(dict(send=d,monotonic_ns=time.monotonic_ns()))+'\n');log.flush();f.write((json.dumps(d)+'\n').encode())
  while True:
   r=receive()
   if r.get('id')==seq:
    if 'error' in r:raise RuntimeError(r)
    return r
 receive();command('qmp_capabilities');command('query-version');command('query-kvm');wait(lambda:'PRODUCT_OUTPUT_READY' in serial(),'actual product output')
 control=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);control.connect(str(out/'control.sock'))
 def key(*keys):
  for down,order in [(True,keys),(False,reversed(keys))]:
   for name in order:command('input-send-event',dict(events=[dict(type='key',data=dict(down=down,key=dict(type='qcode',data=name)))]))
  events.append(dict(keys=list(keys),monotonic_ns=time.monotonic_ns()));time.sleep(.08)
 def capture(name,phase='RUNNING'):
  pattern=r'GRID seq=(\d+) phase='+phase+r' path=/dev/vcsa1 n=(\d+) hex=([0-9a-f]+)'
  old=len(re.findall(pattern,serial()));control.sendall(b's' if phase=='RUNNING' else b'r');wait(lambda:len(re.findall(pattern,serial()))>old,'native cells '+name)
  seq,n,data=re.findall(pattern,serial())[-1];raw=bytes.fromhex(data);assert len(raw)==int(n);(out/(name+'-vcsa.bin')).write_bytes(raw)
  command('screendump',dict(filename=str(out/(name+'.png')),format='png'))
  return raw
 # Wait for visible original marker in native kernel cells; no guessed terminal emulator.
 def marker():
  control.sendall(b's');time.sleep(.03)
  return any(b'CJTUI_KEYBOARD_FORMAL_READY' in bytes.fromhex(x)[4::2] for x in re.findall(r'path=/dev/vcsa1 n=\d+ hex=([0-9a-f]+)',serial()))
 wait(marker,'visible kernel cells marker');capture('running')
 for keys in [('a',),('up',),('down',),('left',),('right',),('home',),('end',),('insert',),('delete',),('pgup',),('pgdn',),('f2',),('f5',),('f12',),('ctrl','left'),('shift','tab'),('alt','z')]:key(*keys)
 # This physical key chord is an observation, not a claim that kernel VT offers a clipboard/paste protocol.
 key('shift','insert');capture('keys');resized=capture('resized','RESIZED');assert resized[:2]==bytes([10,50]);key('q')
 wait(lambda:'EXIT_CAPTURE_BARRIER' in serial(),'actual exit and restore');command('screendump',dict(filename=str(out/'restored.png'),format='png'));control.sendall(b'e');wait(lambda:'EVIDENCE_TAR_BASE64_END' in serial(),'guest raw export',allow_exit=True)
 rc=p.wait(timeout=15);text=serial();assert rc==0 and 'PRODUCT_EXIT=0 raw_status=0' in text and 'termios_equal=1' in text
 block=text.split('EVIDENCE_TAR_BASE64_BEGIN',1)[1].split('EVIDENCE_TAR_BASE64_END',1)[0];data=base64.b64decode(''.join(block.split()));(out/'guest-evidence.tar').write_bytes(data)
 with tarfile.open(fileobj=io.BytesIO(data)) as archive:archive.extractall(out/'evidence',filter='data')
 trace=(out/'evidence/host-observation.strace').read_text();encoded=''.join('\\x%02x'%x for x in b'/apps/keyboard-formal');m=re.search(r'^(\d+)\s+execve\("'+re.escape(encoded)+r'".* = 0$',trace,re.M);assert m;pid=m[1];exitm=re.search(r'^'+pid+r'\s+\+\+\+ exited with (\d+) \+\+\+$',trace,re.M);assert exitm and exitm[1]=='0'
 inp,ins=extract(trace,0,'read');output,outs=extract(trace);(out/'input.raw').write_bytes(inp);(out/'output.raw').write_bytes(output)
 assert(out/'evidence/termios-before.bin').read_bytes()==(out/'evidence/termios-after.bin').read_bytes();summary=(out/'evidence/summary').read_text();assert 'resources=0/0/0/0' in summary
 (out/'result.json').write_text(json.dumps(dict(qemu_exit=rc,product_exit=int(exitm[1]),product_pid=int(pid),termios_equal=True,virtual_hardware=True,events=events,summary=summary,wire_stats=dict(input=ins,output=outs),paste_capability='UNKNOWN/UNSUPPORTED: real ShiftInsert keymap observation retained; no kernel clipboard or bracketed paste asserted',EOF='natural kernel-console EOF unexercised; real-pipe EOF covered by frozen formal suite',resize='actual kernel VT_RESIZE with TIOCGWINSZ/native vcsa size readback'),indent=2)+'\n')
except BaseException as e:(out/'failure.json').write_text(json.dumps(dict(error=repr(e),events=events),indent=2)+'\n');raise
finally:
 if control:control.close()
 if q:q.close()
 if log:log.close()
 if p.poll() is None:p.terminate();p.wait(timeout=10)
print('Actual QEMU LinuxVT keys, native resize, real binary exit/termios/PNG captured; console paste capability unknown')
