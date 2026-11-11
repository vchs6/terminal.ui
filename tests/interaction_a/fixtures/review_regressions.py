"""Seven TASK100 findings only; exact public consumers and actual PTY idle proof."""
import argparse,json,os,pathlib,subprocess,time,traceback,datetime
from pty_capture import Capture,unknown_wire,restored
from native_cases import libraries
CASES=['I01','I02-focus','I02-constant','I02-getter','I03-focus-focus','I03-append-focus','I03-focus-append','I04','I06-node','I06-ancestor','I07-root','I07-nested']

def clock_idle(binary,out):
    out.mkdir(parents=True,exist_ok=True)
    clock=out/'clock';clock.write_text('-1\n');trace=out/'clock.calls';polls=out/'poll.calls'
    lib=libraries(str(out.parent))
    cap=Capture([str(binary)],out,{'CJTUI_A_CLOCK_FILE':str(clock),'CJTUI_A_CLOCK_TRACE':str(trace),'LD_PRELOAD':str(lib/'input_hup.so'),'CJTUI_A_POLL_TRACE':str(polls)})
    record={'scope':'actual public Application.run; host poll observes actual idle, cjt_monotonic_ms returns -1'}
    try:
        cap.wait_bytes(b'AAAA');cap.wait_bytes(b'BBBB')
        cap.send(b'b');initial=cap.state(lambda s:s.startswith('unknown-clock\n') and s.endswith('text:b|'))
        record['ordinary_input_positive']=initial
        cap.send(b'\x1b');sent=cap.sent[-1]['elapsed_ns']
        # Wait on the real libc poll completion, not an arbitrary sleep oracle.
        until=time.monotonic()+3;idle=None
        while time.monotonic()<until:
            cap.drain(.01)
            if polls.exists():
                for line in polls.read_text().splitlines():
                    fields=line.split()
                    if len(fields)!=5:continue
                    start,end,timeout,result,revents=map(int,fields)
                    if start>=sent and timeout==100 and result==0 and end-start>=100_000_000:
                        idle=dict(start_ns=start,end_ns=end,timeout_ms=timeout,result=result,revents=revents);break
            if idle:break
        assert idle,'fixture did not observe an actual completed 100ms stdin idle'
        record['actual_idle']=idle
        cap.send(b'xs');state=cap.state(lambda s:s.startswith('unknown-clock\n') and s.endswith('text:s|'))
        record['state_after_idle_and_text']=state
    finally:
        meta=cap.finish();record['capture']=meta
        record['closed_events']=(out/'closed-events').read_text() if (out/'closed-events').exists() else None
        record['closed_status']=(out/'closed-status').read_text() if (out/'closed-status').exists() else None
        (out/'observed.json').write_text(json.dumps(record,indent=2,default=lambda v:{'hex':v.hex()})+'\n')
    restored(meta);assert meta['exit']==0,meta
    unknown_wire(bytes(cap.raw),queries=0)
    assert trace.read_text().splitlines() and all(x=='-1' for x in trace.read_text().splitlines()),'clock seam was not exercised'
    assert record['closed_status']=='unknown-clock'
    assert record['closed_events']=='text:b|escape:|text:x|text:s|text:q|','I05 UnknownClock must retain bare ESC idle and subsequent ordinary keys; actual='+str(record['closed_events'])
    return record

def run(binary,out):
    binary=pathlib.Path(binary).resolve();out=pathlib.Path(out);out.mkdir(parents=True,exist_ok=True)
    results=[]
    for name in CASES:
        directory=out/name;directory.mkdir();env=os.environ.copy();env['CJTUI_INTERACTION_A_REGRESSION']=name
        argv=['timeout','60s',str(binary)];start=datetime.datetime.now(datetime.timezone.utc).isoformat()
        p=subprocess.run(argv,env=env,capture_output=True)
        for ext,data in [('stdout',p.stdout),('stderr',p.stderr)]: (directory/ext).write_bytes(data)
        (directory/'exit').write_text(str(p.returncode)+'\n')
        result=dict(case=name,argv=argv,env={'CJTUI_INTERACTION_A_REGRESSION':name},utc=start,exit=p.returncode);results.append(result);print(json.dumps(result),flush=True)
    start=datetime.datetime.now(datetime.timezone.utc).isoformat()
    try:clock_idle(binary,out/'I05');result=dict(case='I05',utc=start,exit=0)
    except Exception:
        (out/'I05/driver.stderr').write_text(traceback.format_exc());result=dict(case='I05',utc=start,exit=1)
    results.append(result);print(json.dumps(result),flush=True)
    (out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    return 1 if any(x['exit']!=0 for x in results) else 0
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--binary',required=True);p.add_argument('--output',required=True);a=p.parse_args();raise SystemExit(run(a.binary,a.output))
