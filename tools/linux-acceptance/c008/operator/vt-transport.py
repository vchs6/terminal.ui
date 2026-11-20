#!/usr/bin/env python3
"""Actual QMP keyboard/VGA plus original syscall-byte extraction, no screen parser."""
import base64,hashlib,json,os,pathlib,re,socket,subprocess as S,sys,time
from vt_records import ready,wire as decode_wire
from paste002_capture import capture,complete_capture,load_before,utc
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1'
r=json.loads(sys.argv[1]);out=pathlib.Path(r['dir']);run=out/'vt-run';op=r['op']
serial=run/'vt-serial.log'
if op=='paste002-before':
 print(json.dumps(capture(out,'controlled-keyboard-raw')));sys.exit()
def text():return serial.read_text(errors='replace') if serial.exists() else ''
def wait(predicate,label):
 end=time.monotonic()+30
 while time.monotonic()<end:
  s=text()
  if 'TRANSPORT_ERROR' in s:raise RuntimeError(s[s.index('TRANSPORT_ERROR'):][-1000:])
  value=predicate(s)
  if value:return value
  time.sleep(.02)
 raise RuntimeError('VT transport timeout: '+label)
def qmp(command,args):
 with socket.socket(socket.AF_UNIX,socket.SOCK_STREAM) as sock:
  sock.settimeout(15);sock.connect(str(run/'vt-qmp.sock'));f=sock.makefile('rwb',buffering=0)
  log=(run/'operator-qmp.jsonl').open('a')
  def receive():
   d=json.loads(f.readline());log.write(json.dumps({'receive':d,'utc_ns':time.time_ns()})+'\n');log.flush();return d
  receive()
  for n,(name,params) in enumerate([('qmp_capabilities',{}),(command,args)],1):
   req={'execute':name,'id':n,'arguments':params};log.write(json.dumps({'send':req,'utc_ns':time.time_ns()})+'\n');log.flush();f.write((json.dumps(req)+'\n').encode())
   while True:
    reply=receive()
    if reply.get('id')==n:
     assert 'error' not in reply,reply;break
  log.close();return reply
if op=='identify':
 wait(ready,'complete tty1 identity/trace/product readiness set')
 result={'tty':'/dev/tty1','dimensions':[25,80],'source':'complete actual supervisor readiness set'}
elif op=='fixture':
 payload=bytes.fromhex(r['hex']);assert len(payload)<=8192
 wait(lambda s:'FIXTURE_WAIT target=/evidence/selected.toml' in s or 'PRODUCT_STARTED pid=' in s,'owned fixture control readiness')
 old=max([int(v) for v in re.findall(r'FIXTURE_READY seq=(\d+)',text())] or [0])
 with socket.socket(socket.AF_UNIX,socket.SOCK_STREAM) as control:
  control.connect(str(run/'control.sock'));control.sendall(b'f'+payload.hex().encode()+b'\n')
 wait(lambda s:re.search(r'FIXTURE_READY seq='+str(old+1)+r' bytes='+str(len(payload))+r' hex='+payload.hex()+r'\n',s),'exact owned fixture write ACK')
 result={'guestPath':'/evidence/selected.toml','bytes':len(payload),'sha256':hashlib.sha256(payload).hexdigest(),'sequence':old+1}
elif op=='stop':
 with socket.socket(socket.AF_UNIX,socket.SOCK_STREAM) as control:
  control.connect(str(run/'control.sock'));control.sendall(b'k')
 result={'request':'owned tracee group SIGTERM via supervisor; restoration not assumed'}
elif op=='input':
 payload=bytes.fromhex(r['hex']);assert payload and len(payload)<=511 and b'\0' not in payload
 if r.get('paste002'):
  load_before(out,r['paste002']['before'],'controlled-keyboard-raw')
  start=payload.index(b'\x1b[200~')+6;end=payload.index(b'\x1b[201~',start);source=payload[start:end]
  assert source.hex()==r['paste002']['sourceHex'],'INSUFFICIENT_EVIDENCE PASTE002 controlled source identity'
  paste_source={'sourceHex':source.hex(),'sourceSha256':hashlib.sha256(source).hexdigest(),'route':'kernel keyboard controlled raw function string','selectedUTC':utc()}
 # Mapping is controlled fixed test data; tty1 input itself comes from QMP F12.
 oldseq=max([int(v) for v in re.findall(r'MAP_READY seq=(\d+)',text())] or [0])
 with socket.socket(socket.AF_UNIX,socket.SOCK_STREAM) as control:
  control.connect(str(run/'control.sock'));control.sendall(b'm'+payload.hex().encode()+b'\n')
 ack=wait(lambda s:re.search(r'MAP_READY seq='+str(oldseq+1)+r' tty=/dev/tty1 keycode=88 func=11 controlled_bytes_hex='+payload.hex()+r'\n',s),'kernel function-string readback ACK')
 qmp('send-key',{'keys':[{'type':'qcode','data':'f12'}],'hold-time':50})
 result={'method':'kernel KDSKBSENT/KDSKBENT readback then real QMP f12','map_seq':oldseq+1,'hex':payload.hex(),'clipboard_support':'not claimed','utc_ns':time.time_ns()}
 if r.get('paste002'):result.update(paste002=complete_capture(out,'controlled-keyboard-raw',r['paste002']['before']),pasteSource=paste_source)
elif op=='wire':
 s=text();complete=bool(re.search(r'PRODUCT_EXIT=\d+ raw_status=\d+',s))
 trace,output,inputs,inventory=decode_wire(s,complete)
 (out/'live-original.strace').write_bytes(trace);(out/'actual-input.raw').write_bytes(inputs)
 (out/'syscall-inventory.json').write_text(json.dumps(inventory,indent=2)+'\n')
 exit_match=re.search(r'PRODUCT_EXIT=(\d+) raw_status=',s)
 if exit_match:
  observations={}
  for match in re.finditer(r'^CURSOR_OBSERVATION phase=(before|after) tty=(\S+) query_hex=(\S+) response_hex=([0-9a-f]*) deadline_ms=(\d+) start_ns=(\d+) end_ns=(\d+) probe_termios_restored=1 source=actual_tty_no_injection$',s,re.M):
   phase,tty,query,response,deadline,start,end=match.groups();observations[phase]={'tty':tty,'queryHex':query,'responseHex':response,'deadlineMs':int(deadline),'startNs':int(start),'endNs':int(end)}
  assert set(observations)=={'before','after'},'INSUFFICIENT_EVIDENCE genuine VT cursor observations'
  def cursor_state(he):return {'1b5b3f32353b312479':'KnownVisible','1b5b3f32353b322479':'KnownHidden'}.get(he,'Unknown')
  first,last=observations['before'],observations['after'];initial=cursor_state(first['responseHex']);final=cursor_state(last['responseHex'])
  if initial=='Unknown':assert not re.search(rb'\x1b\[\?25[hlsr]',output),'Unknown cursor25 modified';restored='PreservedUnknown'
  else:assert final==initial,'genuine VT cursor restoration mismatch';restored=final
  cursor={'source':'ACTUAL_TTY1_QUERY_OBSERVATIONS','appTty':first['tty'],'queryHex':first['queryHex'],'responseHex':first['responseHex'],'deadlineMs':first['deadlineMs'],'utcStart':first['startNs'],'utcEnd':last['endNs'],'initialCursor':initial,'cursorRestore':restored,'observations':observations,'rawSource':str(serial)}
  (run/'cursor-observations.json').write_text(json.dumps(cursor,indent=2)+'\n');(out/'lifecycle-output.raw').write_bytes(output)

 result={'wireBase64':base64.b64encode(output).decode(),'directExit':int(exit_match[1]) if exit_match else None,'keyboardRestored':'KEYBOARD_RESTORED original_string_equal=1 original_key_equal=1' in s,'traceRule':'reviewed E146 per-TID unfinished/resumed semantics plus complete annotated tty read/write/readv/writev payloads'}
elif op=='capture':
 name='original-'+str(time.time_ns());ppm=run/(name+'.ppm');png=run/(name+'.png')
 qmp('screendump',{'filename':str(ppm)});S.run(['convert',str(ppm),str(png)],check=True,capture_output=True)
 result={'ppm':str(ppm),'png':str(png),'ppmSha256':hashlib.sha256(ppm.read_bytes()).hexdigest(),'pngSha256':hashlib.sha256(png.read_bytes()).hexdigest(),'original':'actual VGA QMP screendump; lossless convert; PPM retained'}
elif op=='resize':
 assert (r['rows'],r['cols'])==(25,80),'real VT fixed80x25: changing size is inadmissible; frozen dimension contract required'
 result={'before':[25,80],'after':[25,80],'fixedKernelVT':True}
else:raise ValueError(op)
print(json.dumps(result))
