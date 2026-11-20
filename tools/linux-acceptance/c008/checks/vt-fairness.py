"""Owned FIFO/pipe tools only. No framework, terminal, VM, app or network run."""
import hashlib,json,os,pathlib,subprocess,sys
source=pathlib.Path(__file__).resolve().parents[1]
root=source.parent;out=pathlib.Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=False)
base=root/'fix-round1/snapshot/operator';operator=source/'operator'
commands=[]
def sha(data):return hashlib.sha256(data).hexdigest()
def run(argv,expected=0,env=None):
 p=subprocess.run([str(v) for v in argv],capture_output=True,text=True,timeout=15,env=env)
 commands.append({'argv':[str(v) for v in argv],'exit':p.returncode,'expectedExit':expected,'stdout':p.stdout,'stderr':p.stderr})
 assert p.returncode==expected,(argv,p.returncode,p.stdout,p.stderr)
 return p
old=(base/'vt-supervisor-transport.h').read_text();start=old.index('static void tr_drain(void){');end=old.index('\nstatic int tr_nibble',start)
(out/'old-drain.h').write_text(old[start:end]+'\n')
new=(operator/'vt-supervisor-transport.h').read_text();start=new.index('static void tr_die(');end=new.index('\nstatic void tr_write',start)
(out/'native-fatal.h').write_text(new[start:end]+'\n')
fixture=out/'input.raw';fixture.write_bytes(bytes(range(256))*2048)
compiler=['cc','-std=c11','-O2','-Wall','-Wextra','-Werror']
common=compiler+['-I'+str(out),'-I'+str(operator),source/'checks/vt-fairness.c']
run(common+['-DOLD_BASE','-o',out/'old-harness'])
run(common+['-DNATIVE_FATAL','-o',out/'new-harness'])
derived=out/'derived';run(['python3',operator/'derive-vt-supervisor.py','--source-only'],env={**os.environ,'C008_VT_OPERATOR_BUILD':str(derived)})
run(compiler+[derived/'vt-product-supervisor.c','-o',out/'derived-supervisor-NOT-RUN'])
cases=[]
for binary,mode in [('old','normal'),('new','normal'),('new','archive-backpressure'),('new','partial'),('new','eintr-budget'),('new','archive-error'),('new','serial-error'),('new','read-error'),('new','zero-write')]:
 case=out/(binary+'-'+mode);case.mkdir()
 error=mode in ['archive-error','serial-error','read-error','zero-write'];expected=3 if error else 1 if binary=='old' else 0
 p=run([out/(binary+'-harness'),mode,fixture,case],expected)
 (case/'stdout.txt').write_text(p.stdout);(case/'stderr.txt').write_text(p.stderr)
 archive=(case/'archive.raw').read_bytes();assert fixture.read_bytes().startswith(archive),'archive prefix/order survives actual failure'
 if error:
  failure=(case/'fatal.raw').read_text();operation='trace-log-write' if mode=='serial-error' else 'trace-read' if mode=='read-error' else 'trace-archive-write'
  assert failure=='TRANSPORT_ERROR operation='+operation+' errno=5\n'
  cases.append({'binary':binary,'mode':mode,'exit':p.returncode,'failure':failure,'archivePrefixBytes':len(archive)})
  continue
 telemetry=json.loads(p.stdout);assert telemetry['observedFinalEOF'] and telemetry['generatedBytes']==fixture.stat().st_size
 if binary=='old':assert not telemetry['controlBeforeTraceEOF'] and not telemetry['reapBeforeTraceEOF'] and telemetry['maxActiveIOAttempts']>8
 else:
  assert telemetry['controlBeforeTraceEOF'] and telemetry['reapBeforeTraceEOF'] and telemetry['maxActiveIOAttempts']<=8
  assert telemetry['generatedBeforeFinish']<fixture.stat().st_size and telemetry['finalIOAttempts']>8,'final flush must continue across quotas'
 lines=(case/'serial.raw').read_bytes().splitlines()
 traces=[line[10:] for line in lines if line.startswith(b'TRACE hex=')]
 assert traces and all(len(he)%2==0 and all(c in b'0123456789abcdef' for c in he) for he in traces),'complete unmixed frames'
 received=b''.join(bytes.fromhex(he.decode()) for he in traces)
 assert received==archive==fixture.read_bytes(),'all original bytes/order survive archive and serialized framing'
 assert [line for line in lines if not line.startswith(b'TRACE hex=')]==[b'CONTROL_SERVICED',b'REAP_SERVICED'],'status order/frames retained'
 cases.append({'binary':binary,'mode':mode,'exit':p.returncode,'telemetry':telemetry,'inputSha256':sha(fixture.read_bytes()),'archiveSha256':sha(archive),'decodedTraceSha256':sha(received)})
(out/'verification.json').write_text(json.dumps({'status':'TOOL_ONLY_NATIVE_FAIRNESS_CHECKS_PASS_NOT_REAL_VT','commands':commands,'cases':cases,'sourceFiles':[{'path':str(p),'sha256':sha(p.read_bytes())} for p in [source/'checks/vt-fairness.c',pathlib.Path(__file__),operator/'vt-trace-pump.h',operator/'vt-supervisor-transport.h',operator/'derive-vt-supervisor.py',base/'vt-supervisor-transport.h']],'limits':['Owned FIFO on-demand continuous feed and controlled owned child; not an actual tracer/app/VT','Error helper is the exact native fatal function with only its evidence-file destination mapped into the owned tool directory','Observed tool timings do not establish guest wall-clock ACK bounds or original MAP_READY timeout cause','Regular archive writes can still stall in the OS; no arbitrary disk/scheduler hard-time guarantee']},indent=2)+'\n')
(out/'verification.txt').write_text(''.join('COMMAND '+json.dumps(c['argv'])+'\nEXIT '+str(c['exit'])+'\nSTDOUT\n'+c['stdout']+'STDERR\n'+c['stderr'] for c in commands))
print('PASS native fairness: old backlog RED;4 new exact512KiB archive/frame/EOF/control/reap cases;4 native fatal error cases; strict old/new harness and derived-supervisor compilation. No actual VT/app/VM/network.')
