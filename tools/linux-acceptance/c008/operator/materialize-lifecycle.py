#!/usr/bin/env python3
"""Transcribe only existing raw observations into frozen lifecycle schema."""
import hashlib,json,os,pathlib,re,sys
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1'
assert os.environ.get('C008_CAPTURE_FINALIZED')=='1','INSUFFICIENT_EVIDENCE producer completion required'
kind=sys.argv[1];session=pathlib.Path(sys.argv[2]);raw=pathlib.Path(sys.argv[3]);records=[];snapshots={}
def ref(k,p):
 p=pathlib.Path(p);assert p.is_file(),('INSUFFICIENT_EVIDENCE',str(p))
 if str(p) not in snapshots:
  content=p.read_bytes();target=session/'lifecycle-originals'/p.name;target.parent.mkdir(exist_ok=True);target.write_bytes(content)
  snapshots[str(p)]={'path':str(target.resolve()),'sha256':hashlib.sha256(content).hexdigest(),'original':str(p.resolve()),'bytes':len(content),'boundary':'producer-completed-before-copy'}
 row=snapshots[str(p)];records.append({'kind':k,'path':row['path'],'sha256':row['sha256']})
def state(v):return {'set':'KnownVisible','reset':'KnownHidden','unknown':'Unknown'}[v]
if kind=='pty':
 text=(raw/'inner-state.txt').read_text();tty=re.search(r'^tty=(.+)$',text,re.M)[1]
 before=re.search(r'^ready_termios=(.+)$',text,re.M)[1];after=re.search(r'^exit_termios=(.+)$',text,re.M)[1]
 old=json.loads((raw/'cursor-before.json').read_text());new=json.loads((raw/'cursor-after.json').read_text())
 initial=state(old['observations']['25']['state']);final=state(new['observations']['25']['state']);wire=(raw/'ansi.raw').read_bytes()
 if initial=='Unknown':
  assert not re.search(rb'\x1b\[\?25[hlsr]',wire),'INSUFFICIENT_EVIDENCE Unknown cursor had managed25 mutation'
  restored='PreservedUnknown'
 else:
  assert final==initial,'INSUFFICIENT_EVIDENCE genuine final cursor reply does not restore baseline';restored=final
 exit_value=int((raw/'app.exit').read_text());assert exit_value==0,'INSUFFICIENT_EVIDENCE nonzero/signal needs exact native exit interpretation'
 context={'appPid':int((raw/'app.pid').read_text()),'appTty':tty,'binary':os.environ['C008_BINARY'],'startUtc':(raw/'app-start.utc').read_text().strip(),'endUtc':(raw/'app-exit.utc').read_text().strip(),'beforeQuery':old,'afterQuery':new,'source':'existing host_probe.py on actual same inherited /dev/tty, no synthetic response'}
 original=raw/'lifecycle-context.json';original.write_text(json.dumps(context,indent=2)+'\n')
 for k,p in [('termios',raw/'inner-state.txt'),('exit',raw/'app.exit'),('cursor',raw/'cursor-before.json'),('cursor',raw/'cursor-after.json'),('input-wire',raw/'input.raw'),('input-wire',raw/'ansi.raw'),('termios',original),('exit',original),('input-wire',original)]:ref(k,p)
elif kind=='vt':
 text=(raw/'vt-serial.log').read_text(errors='replace')
 before=re.search(r'^STDOUT_TERMIOS phase=before (.+)$',text,re.M);after=re.search(r'^STDOUT_TERMIOS phase=after (.+)$',text,re.M)
 assert before and after,'INSUFFICIENT_EVIDENCE exact native stdout termios originals'
 before=before[1];after=after[1]
 exit_match=re.search(r'PRODUCT_EXIT=(\d+) raw_status=(\d+)',text);assert exit_match,'INSUFFICIENT_EVIDENCE actual native wait status'
 exit_value=int(exit_match[1]);wait_status=int(exit_match[2]);assert os.WIFEXITED(wait_status),'INSUFFICIENT_EVIDENCE direct signal'
 # Reuse actual original guest query observations if present; never infer Unknown
 # just from the hostKind or map. Until this raw record exists the field blocks.
 cursor=raw/'cursor-observations.json';assert cursor.is_file(),'INSUFFICIENT_EVIDENCE VT genuine cursor query/timeout observations required'
 c=json.loads(cursor.read_text());assert c['source']=='ACTUAL_TTY1_QUERY_OBSERVATIONS'
 initial=c['initialCursor'];restored=c['cursorRestore'];assert c['appTty']=='/dev/tty1' and c['queryHex']=='1b5b3f32352470' and c['utcStart'] and c['utcEnd']
 if initial=='Unknown':assert c['responseHex']=='' and c['deadlineMs']>=650 and restored=='PreservedUnknown'
 for k,p in [('termios',raw/'vt-serial.log'),('exit',raw/'vt-serial.log'),('cursor',cursor),('input-wire',session/'actual-input.raw'),('input-wire',session/'live-original.strace')]:ref(k,p)
else:raise ValueError(kind)
value={'beforeTermios':before,'afterTermios':after,'directExit':exit_value,'directSignal':None,'initialCursor':initial,'cursorRestore':restored,'syntheticReplyInjected':False,'evidence':records}
(session/'lifecycle-finalization.json').write_text(json.dumps({'producersComplete':True,'originals':list(snapshots.values())},indent=2)+'\n')
(session/'lifecycle-evidence.json').write_text(json.dumps(value,indent=2)+'\n')
