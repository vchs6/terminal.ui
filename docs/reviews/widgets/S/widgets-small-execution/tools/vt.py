import os,pathlib,subprocess,time,socket,json,re,base64,tarfile,io,hashlib,sys,datetime
sys.path.insert(0,'/workspace/work/keyboard-execution/tools');from trace_bytes import extract
B=pathlib.Path('/workspace/work/widgets-small-execution');mode=sys.argv[1];suffix=sys.argv[2] if len(sys.argv)>2 else mode;out=B/'raw'/('host-vt-'+suffix);out.mkdir(exist_ok=False);host=pathlib.Path('/workspace/work/linux-console-hosts');initrd=B/'widgets-small-vt.cpio.gz';env=dict(os.environ,LD_LIBRARY_PATH=str(host/'hosts/debian/usr/lib/x86_64-linux-gnu'))
cmd=[str(host/'hosts/debian/usr/bin/qemu-system-x86_64'),'-accel','tcg','-cpu','max','-machine','pc','-m','512','-smp','1','-no-reboot','-nic','none','-L',str(host/'hosts/debian/usr/share/qemu'),'-bios',str(host/'hosts/debian/usr/share/seabios/bios-256k.bin'),'-device','VGA,romfile='+str(host/'hosts/debian/usr/share/seabios/vgabios-stdvga.bin'),'-vga','none','-display','none','-serial','file:'+str(out/'serial.log'),'-chardev','socket,id=probe,path='+str(out/'control.sock')+',server=on,wait=off','-serial','chardev:probe','-qmp','unix:'+str(out/'qmp.sock')+',server=on,wait=off','-kernel',str(host/'packages/linux'),'-initrd',str(initrd),'-append','console=tty0 console=ttyS0,115200 rdinit=/init nomodeset vga=normal loglevel=4 scene='+mode]
binary=B/'clean/cjtui-0.0.0'/('examples/widgets_small/target/release/bin/main' if mode=='example' else 'tests/widgets_small/device/target/release/bin/main')
(out/'launch.json').write_text(json.dumps(dict(argv=cmd,virtual_hardware=True,fixed_source_sha='1df1325f7b51777d8adab62f950c936051aa5876',binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),initrd_sha256=hashlib.sha256(initrd.read_bytes()).hexdigest(),kernel_sha256=hashlib.sha256((host/'packages/linux').read_bytes()).hexdigest(),utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),connection='QEMU TCG emulated keyboard → actual Linux kernel VT tty1; serial observer channel does not inject PTY bytes'),indent=2)+'\n')
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
 receive();command('qmp_capabilities');command('query-version');command('query-kvm');wait(lambda:'PRODUCT_OUTPUT_READY' in serial(),'actual product output');control=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);control.connect(str(out/'control.sock'))
 def key(*keys):
  for down,order in [(True,keys),(False,reversed(keys))]:
   for name in order:command('input-send-event',dict(events=[dict(type='key',data=dict(down=down,key=dict(type='qcode',data=name)))]))
  events.append(dict(keys=list(keys),monotonic_ns=time.monotonic_ns()));time.sleep(.25)
 def capture(name,phase='RUNNING'):
  time.sleep(1.0) # Allow actual TCG UI scheduling to paint before native observation.
  pattern=r'GRID seq=(\d+) phase='+phase+r' path=/dev/vcsa1 n=(\d+) hex=([0-9a-f]+)\r?\n';old=len(re.findall(pattern,serial()));control.sendall(b's' if phase=='RUNNING' else b'r');wait(lambda:len(re.findall(pattern,serial()))>old,'native cells '+name)
  seq,n,data=re.findall(pattern,serial())[-1];raw=bytes.fromhex(data);assert len(raw)==int(n);(out/(name+'-vcsa.bin')).write_bytes(raw);command('screendump',dict(filename=str(out/(name+'.png')),format='png'));events.append(dict(capture=name,monotonic_ns=time.monotonic_ns()));return raw
 marker=b'Small widgets' if mode=='example' else b'S_WIDGETS_READY'
 def visible():
  control.sendall(b's');time.sleep(.03);return any(marker in bytes.fromhex(x)[4::2] for x in re.findall(r'path=/dev/vcsa1 n=\d+ hex=([0-9a-f]+)\r?\n',serial()))
 wait(visible,'visible actual kernel cells');capture('running')
 def ack(name,value):
  def observed():
   control.sendall(b's');time.sleep(.04)
   return any(bytes.fromhex(x).decode()==value for x in re.findall(r'ACK seq=\d+ name='+name+r' hex=([0-9a-f]+)\r?\n',serial()))
  wait(observed,'actual frozen report '+name+'='+value)
 key('ret')
 if mode=='normal':ack('button','1')
 capture('button-enter');key('tab');capture('checkbox-focused');key('spc')
 if mode=='normal':ack('checkbox','1')
 capture('checkbox-request');key('tab');key('ret')
 if mode=='normal':ack('radio','1')
 capture('radio-selected');key('spc');capture('radio-already-selected');capture('resize-transition','RESIZED');capture('resized');key('q')
 wait(lambda:'EXIT_CAPTURE_BARRIER' in serial(),'actual exit and restore');command('screendump',dict(filename=str(out/'restored.png'),format='png'));control.sendall(b'e');wait(lambda:'EVIDENCE_TAR_BASE64_END' in serial(),'guest raw export',allow_exit=True);rc=p.wait(timeout=15);text=serial();block=text.split('EVIDENCE_TAR_BASE64_BEGIN',1)[1].split('EVIDENCE_TAR_BASE64_END',1)[0];data=base64.b64decode(''.join(block.split()));(out/'guest-evidence.tar').write_bytes(data)
 with tarfile.open(fileobj=io.BytesIO(data)) as archive:archive.extractall(out/'evidence',filter='data')
 trace=(out/'evidence'/(mode+'.strace')).read_text();guest_binary='/apps/'+('small-example' if mode=='example' else 'small-device');encoded=''.join('\\x%02x'%x for x in guest_binary.encode());m=re.search(r'^(\d+)\s+execve\("'+re.escape(encoded)+r'".* = 0$',trace,re.M);assert m,'direct exec pid';pid=m[1];ex=re.search(r'^'+pid+r'\s+\+\+\+ exited with (\d+) \+\+\+$',trace,re.M);assert ex,'actual product exit';inp,ins=extract(trace,0,'read');output,outs=extract(trace);(out/'input.raw').write_bytes(inp);(out/'output.raw').write_bytes(output);equal=(out/'evidence/termios-before.bin').read_bytes()==(out/'evidence/termios-after.bin').read_bytes()
 summary_path=out/'evidence/summary';summary=dict(x.split('=',1) for x in summary_path.read_text().splitlines()) if summary_path.exists() else {}
 if mode=='normal':
  expected=dict(clicks='1',boxRequests='1',checked='true',radioRequests='1',selected='true',cleanups='1',resources='0/0/0/0');assert summary==expected,(summary,expected)
 result=dict(qemu_exit=rc,product_exit=int(ex[1]),product_pid=int(pid),termios_equal=equal,virtual_hardware=True,events=events,wire_stats=dict(input=ins,output=outs),summary=summary,oracle_source='Unchanged tests/widgets_small/pty.py normal literal summary/key sequence; actual QMP generated kernel input, no new Cj oracle.',unicode='ASCII native fixture only; new S Unicode host caption projection not exercised; independent headless S and unchanged accepted E backend evidence remain distinct.',theme='Classic focus/selected native appearance only; disabled/explicit custom palette is headless S evidence, not new native proof.',resize='actual kernel VT_RESIZE60x12 to50x10 with native vcsa/readback',utc=datetime.datetime.now(datetime.timezone.utc).isoformat());(out/'result.json').write_text(json.dumps(result,indent=2)+'\n')
 if rc!=0 or int(ex[1])!=0 or not equal:raise RuntimeError('direct exit/termios failure '+str(result))
except BaseException as e:(out/'failure.json').write_text(json.dumps(dict(error=repr(e),events=events),indent=2)+'\n');raise
finally:
 if control:control.close()
 if q:q.close()
 if log:log.close()
 if p.poll() is None:p.terminate();p.wait(timeout=10)
print('Actual QEMU Linux VT editor observation captured',mode)
