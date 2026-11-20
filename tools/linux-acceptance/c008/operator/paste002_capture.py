"""PASTE002 immutable input snapshots; transport framing only, no wire oracle."""
import datetime,hashlib,json,pathlib,time,uuid
from vt_records import wire

OPEN=bytes.fromhex('1b5b3230307e');CLOSE=bytes.fromhex('1b5b3230317e')
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='milliseconds').replace('+00:00','Z')
def sha(data):return hashlib.sha256(data).hexdigest()
def capture(out,kind):
 out=pathlib.Path(out).resolve()
 source=out/('transport/input.raw' if kind=='gui-selection' else 'vt-run/vt-serial.log')
 original=source.read_bytes() # Missing original must fail, never substitute empty input.
 raw=original if kind=='gui-selection' else wire(original.decode('utf8'),False)[2]
 folder=out/'paste002-originals'/uuid.uuid4().hex;folder.mkdir(parents=True)
 (folder/'source.raw').write_bytes(original);(folder/'input.raw').write_bytes(raw)
 value={'kind':kind,'capturedUTC':utc(),'source':str(source),'sourceSnapshot':str(folder/'source.raw'),'sourceSha256':sha(original),'sourceBytes':len(original),'rawPath':str(folder/'input.raw'),'rawSha256':sha(raw),'rawBytes':len(raw)}
 (folder/'capture.json').write_text(json.dumps(value,indent=2)+'\n')
 return value

def load_before(out,value,kind):
 path=pathlib.Path(value['rawPath']).resolve();root=(pathlib.Path(out)/'paste002-originals').resolve()
 assert path.is_relative_to(root),'INSUFFICIENT_EVIDENCE PASTE002 foreign before snapshot'
 stored=json.loads((path.parent/'capture.json').read_text())
 assert value==stored and value['kind']==kind,'INSUFFICIENT_EVIDENCE PASTE002 altered before capture'
 raw=path.read_bytes();original=pathlib.Path(value['sourceSnapshot']).read_bytes()
 assert sha(raw)==value['rawSha256'] and sha(original)==value['sourceSha256'],'INSUFFICIENT_EVIDENCE PASTE002 changed before original'
 return raw,original

def complete_capture(out,kind,before,timeout=5):
 previous,source_prefix=load_before(out,before,kind);end=time.monotonic()+timeout
 source=pathlib.Path(before['source'])
 while True:
  original=source.read_bytes()
  assert original.startswith(source_prefix),'INSUFFICIENT_EVIDENCE PASTE002 source prefix changed'
  raw=original if kind=='gui-selection' else wire(original.decode('utf8'),False)[2]
  assert raw.startswith(previous),'INSUFFICIENT_EVIDENCE PASTE002 input prefix changed'
  window=raw[len(previous):]
  # Completion boundary only. Exact bytes/counts/policy remain the frozen Node verifier's job.
  if CLOSE in window:break
  if time.monotonic()>=end:break # Preserve incomplete/wrong wire for the fixed verifier too.
  time.sleep(.02)
 after=capture(out,kind);actual=pathlib.Path(after['rawPath']).read_bytes();window=actual[len(previous):]
 start=window.find(OPEN);close=window.find(CLOSE)
 return {'before':before,'after':after,'beforeOffset':len(previous),'afterOffset':len(actual),'packetStart':len(previous)+max(start,0),'packetEnd':len(actual) if close<0 else len(previous)+close+len(CLOSE),'completionDelimiterObserved':close>=0}
