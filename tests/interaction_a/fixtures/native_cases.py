"""Remaining A recipes, driven only through a real public product and real PTY.

Seven Keyboard recipes deliberately have no A execution route. Transaction
faults select actual armed literal buffers, never a guessed write-call index.
"""
import functools,json,pathlib,signal,subprocess,time,sys
from pty_capture import QUERY,unknown_wire,restored

NATIVE_IDS={'clock-before-query','clock-after-query','clock-pending-fails','clock-deadline-overflow',
 'cancel-before-query','cancel-after-known','interrupt-before-report','readonly-headless','readonly-rerun'}
def is_native_recipe(case):return case['id'] in NATIVE_IDS or case['id'].startswith('writer-')

def rows(path):
    if not pathlib.Path(path).exists():return []
    answer=[]
    for line in pathlib.Path(path).read_text().splitlines():
        fields=line.split()
        answer.append(dict(call=int(fields[0]),length=int(fields[1]),action=fields[2],result=int(fields[3]),data=bytes.fromhex(fields[4]) if len(fields)>4 else b''))
    return answer

def boundary_matches(data,kind):
    if kind=='query':return data==QUERY
    if kind=='frame':return b'AAAA' in data or b'BBBB' in data
    if kind=='caret-only':return b'\x1b[1;3H' in data and b'AAAA' not in data and b'BBBB' not in data
    if kind=='cleanup':return b'\x1b[?25l' in data
    return False

def failure_wire(trace,kind,mode):
    selected=[r for r in trace if r['action'] in ('zero','partial')]
    assert len(selected)==1,'one actual selected writer boundary must be injected'
    hit=selected[0];assert boundary_matches(hit['data'],kind),'fault did not target its declared transaction'
    assert hit['length']>=len(hit['data'])
    later=[r for r in trace if r['call']>hit['call']]
    if mode=='partial':
        assert hit['result']==1,'exactly one device byte must precede fatal failure'
        assert later and later[0]['action']=='partial-fatal' and later[0]['result']==-1
        assert not any(r['result']>0 for r in later),'unsafe path emitted later stdout bytes'
    else:
        assert hit['result']==-1
        delivered=[r for r in later if r['result']>0]
        if kind=='caret-only':
            assert len(delivered)<=1 and all(r['data']==b'\x1b[?25l' for r in delivered),'zero-byte failure allows only original-hidden cleanup'
        else:assert not delivered,'fatal query/frame/cleanup emitted later device output'
    return hit['call']

@functools.lru_cache(maxsize=None)
def libraries(output):
    output=pathlib.Path(output)/'_native';output.mkdir(parents=True,exist_ok=True)
    native=pathlib.Path(__file__).resolve().parents[1]/'native'
    records=[]
    for name in ('write_fault','input_hup'):
        argv=['cc','-std=c11','-Wall','-Wextra','-Werror','-O2','-fPIC','-shared',str(native/(name+'.c')),'-ldl','-o',str(output/(name+'.so'))]
        run=subprocess.run(argv,capture_output=True)
        records.append({'argv':argv,'exit':run.returncode,'stdout':run.stdout.decode(),'stderr':run.stderr.decode()})
        (output/'build.json').write_text(json.dumps(records,indent=2)+'\n')
        assert run.returncode==0,records[-1]
    return output

def wait_file(cap,path):
    until=time.monotonic()+3
    while not pathlib.Path(path).exists() and time.monotonic()<until:
        cap.drain(.01)
        if cap.process.poll() is not None:break
    assert pathlib.Path(path).exists(),'missing public consumer observation '+str(path)

def ended(session):
    aborting=sys.exc_info()[0] is not None
    try:
        meta=session.cap.finish(send_quit=aborting);restored(meta);assert meta['exit']==0
        return meta
    except Exception:
        if not aborting:raise

def known_hidden(session):
    session.ready();session.cap.wait_bytes(b'AAAA');session.cap.wait_bytes(b'BBBB')
    session.cap.send(b'\x1b[?25;2$y');session.status('original-hidden')
    session.cap.wait_bytes(b'\x1b[?25h') # actual managed change, making restoration necessary

def error_files(out,sentinel=None):
    error=(out/'error').read_text();primary=(out/'primary').read_text()
    assert error and primary and error.startswith(primary),'first error must remain primary'
    if sentinel:assert sentinel in primary
    assert (out/'failure-resources').read_text()=='0/0/0/0','failed run leaked runtime resources'
    assert (out/'closed-cleanup').read_text()=='1','cleanup must occur exactly once'

def cancel_known(binary,out,Session):
    results=[];native=libraries(str(out.parent))
    # Existing A -3 input error is a controlled poll HUP, not Keyboard -4 EOF.
    for action in ('stop','signal','eof','callback','draw','cleanup'):
        directory=out/action;directory.mkdir(parents=True,exist_ok=True)
        extra={}
        if action in ('eof','callback','draw','cleanup'):extra['CJTUI_INTERACTION_A_EXPECT_ERROR']='1'
        if action=='cleanup':extra['CJTUI_INTERACTION_A_EXIT']='cleanup-error'
        if action=='eof':extra.update(LD_PRELOAD=str(native/'input_hup.so'),CJTUI_A_HUP_ARM_FILE=str(directory/'hup.arm'),CJTUI_A_HUP_TRACE=str(directory/'hup.calls'))
        s=Session(binary,directory,extra=extra)
        try:
            known_hidden(s)
            if action=='stop' or action=='cleanup':s.cap.send(b'q')
            elif action=='signal':s.cap.process.send_signal(signal.SIGTERM)
            elif action=='eof':(directory/'hup.arm').write_text('armed\n')
            elif action=='callback':s.cap.send(b'e')
            else:s.cap.send(b'd')
        finally:ended(s)
        assert bytes(s.cap.raw).count(QUERY)==1
        assert bytes(s.cap.raw).rfind(b'\x1b[?25l')>bytes(s.cap.raw).rfind(b'\x1b[?25h'),'original-hidden restore must follow managed visible state'
        if action in ('eof','callback','draw','cleanup'):
            marker={'eof':None,'callback':'DEVICE_CALLBACK_SENTINEL','draw':'DEVICE_DRAW_SENTINEL','cleanup':'DEVICE_CLEANUP_SENTINEL'}[action]
            error_files(directory,marker)
        assert (directory/'closed-status').read_text()=='original-hidden'
        results.append(action)
    return results

def writer_case(binary,out,case,Session):
    kind=case['boundary'];mode=case['fault'];native=libraries(str(out.parent))
    arm=out/'writer.arm';trace=out/'write.calls';out.mkdir(parents=True,exist_ok=True)
    extra={'LD_PRELOAD':str(native/'write_fault.so'),'CJTUI_A_WRITE_MATCH':kind,'CJTUI_A_WRITE_ARM_FILE':str(arm),
           'CJTUI_A_WRITE_FAULT':mode,'CJTUI_A_WRITE_TRACE':str(trace),'CJTUI_INTERACTION_A_EXPECT_ERROR':'1'}
    if mode=='partial':extra['CJTUI_INTERACTION_A_TRY_UNSAFE_REOPEN']='1'
    if kind=='caret-only':extra['CJTUI_INTERACTION_A_EXIT']='cleanup-error' # write primary + UI cleanup extra
    if kind in ('query','frame'):arm.write_text('armed\n')
    s=Session(binary,out,extra=extra)
    try:
        if kind in ('caret-only','cleanup'):
            known_hidden(s);arm.write_text('armed\n');s.cap.send(b'm' if kind=='caret-only' else b'q')
        wait_file(s.cap,out/'error')
    finally:ended(s)
    error_files(out)
    index=failure_wire(rows(trace),kind,mode)
    if mode=='partial':
        reopened=(out/'reopen').read_text()
        assert reopened.startswith('true\n') and 'ParserUnsynchronized' in reopened,'partial write must latch refusal across reopen'
    if kind=='caret-only':
        assert 'DEVICE_CLEANUP_SENTINEL' not in (out/'primary').read_text()
        assert 'DEVICE_CLEANUP_SENTINEL' in (out/'extras').read_text(),'cleanup failure must remain additional'
    return {'selected_physical_call':index,'boundary':kind,'fault':mode}

def run_native_recipe(binary,output,case,Session):
    name=case['id'];out=pathlib.Path(output)/name;out.mkdir(parents=True,exist_ok=True)
    detail={}
    if name.startswith('writer-'):detail=writer_case(binary,out,case,Session)
    elif name=='cancel-after-known':detail={'actions':cancel_known(binary,out,Session)}
    else:
        extra={};script=None
        if name.startswith('clock-'):script=case['clock']
        if name=='cancel-before-query':extra['CJTUI_INTERACTION_A_EXIT']='mount-stop'
        if name=='readonly-headless':extra['CJTUI_INTERACTION_A_PRE_HEADLESS']='1'
        if name=='readonly-rerun':extra['CJTUI_INTERACTION_A_RERUN']='1'
        s=Session(binary,out,extra=extra,script=script)
        try:
            if name.startswith('clock-'):
                s.cap.wait_bytes(b'AAAA');s.status('unknown-clock');s.cap.send(b'q')
            elif name=='cancel-before-query':wait_file(s.cap,out/'closed-cleanup')
            elif name=='interrupt-before-report':s.ready();s.cap.send(b'\x03\x1b[?25;1$y')
            else:
                s.ready();s.cap.send(b'\x1b[?25;1$y');s.status('original-visible')
                if name=='readonly-headless':assert (out/'first-headless').read_text()=='none'
                s.cap.send(b'q')
                if name=='readonly-rerun':
                    wait_file(s.cap,out/'rerun-ready')
                    until=time.monotonic()+3
                    while bytes(s.cap.raw).count(QUERY)<2 and time.monotonic()<until:s.cap.drain(.01)
                    assert bytes(s.cap.raw).count(QUERY)==2,'new run must query again'
                    s.status('pending');s.cap.send(b'q')
        finally:ended(s)
        wire=bytes(s.cap.raw)
        if name.startswith('clock-'):
            unknown_wire(wire,queries=case['query_count'])
            calls=[int(x) for x in s.trace.read_text().splitlines()]
            assert calls[:len(script)]==script,'controlled clock script was not sampled'
        elif name=='cancel-before-query':unknown_wire(wire,queries=0);assert (out/'closed-cleanup').read_text()=='1'
        elif name=='interrupt-before-report':
            unknown_wire(wire);assert (out/'closed-events').read_text()=='interrupt:|'
            assert (out/'closed-status').read_text()=='pending','post-stop report must never authorize'
        elif name=='readonly-headless':
            assert (out/'closed-status').read_text()=='original-visible'
            assert (out/'closed-cleanup').read_text()=='2' and (out/'cleanup').read_text()=='3'
        elif name=='readonly-rerun':
            assert (out/'closed-status').read_text()=='original-visible' and (out/'second-closed-status').read_text()=='pending'
            tail=wire[wire.rfind(QUERY):];unknown_wire(tail)
    result={'id':name,'result':'PASS','scope':'actual public product controlled PTY; no physical host pixel claim','details':detail}
    (out/'recipe-result.json').write_text(json.dumps(result,indent=2)+'\n')
    return result
