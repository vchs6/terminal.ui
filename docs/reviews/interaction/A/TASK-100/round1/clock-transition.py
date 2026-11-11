from pathlib import Path
import sys,time,json,hashlib,datetime
sys.path.insert(0,'/workspace/work/terminal.ui/tests/interaction_a/fixtures')
from pty_capture import Capture,restored
r=Path('/workspace/work/interaction-review/round1')
binary=r/'probe/target/release/bin/main'
all_results=[]
for failure in [False,True]:
 out=r/'raw'/('clock-transition' if failure else 'clock-control');out.mkdir(parents=True,exist_ok=True)
 clock=out/'clock';trace=out/'clock.calls';clock.write_text('1000\n')
 start=datetime.datetime.now(datetime.timezone.utc).isoformat()
 cap=Capture([str(binary)],out,{'TERM':'xterm-256color','CJTUI_A_CLOCK_FILE':str(clock),'CJTUI_A_CLOCK_TRACE':str(trace)})
 record={'utc':start,'clock_failure_after_escape_before_suffix':failure,'binary_sha256':hashlib.sha256(binary.read_bytes()).hexdigest()}
 try:
  cap.wait_bytes(b'\x1b[?25$p');cap.send(b'\x1b[?25;1$y');cap.wait_bytes(b'\x1b[?25l')
  count=len(trace.read_text().splitlines());cap.send(b'\x1b');sent=cap.sent[-1]['elapsed_ns']
  limit=time.monotonic()+1
  while len(trace.read_text().splitlines())<count+2 and time.monotonic()<limit:cap.drain(.001)
  calls=trace.read_text().splitlines();assert len(calls)>=count+2,'ESC lastInput/pre-read samples not observed'
  record['samples_before_suffix']=calls[count:]
  if failure:
   nextfile=out/'clock.next';nextfile.write_text('-1\n');nextfile.replace(clock)
  cap.send(b'[A');gap=cap.sent[-1]['elapsed_ns']-sent;record['escape_to_suffix_ns']=gap
  assert gap<100_000_000,'fixture suffix did not arrive within100ms'
  cap.drain(.03)
 finally:
  meta=cap.finish();record['capture']=meta
 restored(meta)
 record['wire_repr']=repr(bytes(cap.raw));record['exit']=meta['exit']
 record['expected_events']='EVENTS=up:|text:q|'
 record['matches_expected']=b'EVENTS=up:|text:q|' in cap.raw
 (out/'result.json').write_text(json.dumps(record,indent=2,default=lambda x:{"hex":x.hex()})+'\n');all_results.append(record)
print(json.dumps(all_results,indent=2,default=lambda x:{"hex":x.hex()}))
(r/'raw/clock-transition-results.json').write_text(json.dumps(all_results,indent=2,default=lambda x:{"hex":x.hex()})+'\n')
