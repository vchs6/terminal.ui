"""Only changed fixture code/self-oracle controls, never product-A behavior."""
import argparse,copy,json,pathlib,subprocess
from pty_capture import Capture,QUERY,unknown_wire,restored
from native_cases import libraries,rows,failure_wire
from selftest import expect_rejected

def run(output):
    out=pathlib.Path(output);out.mkdir(parents=True,exist_ok=True)
    native=pathlib.Path(__file__).resolve().parents[1]/'native'
    libs=libraries(str(out));peer=out/'selector-selftest'
    subprocess.run(['cc','-std=c11','-Wall','-Wextra','-Werror','-O2',str(native/'selector_selftest.c'),'-o',str(peer)],check=True)
    negatives=[];observed=[]
    for kind in ('query','frame','caret-only','cleanup'):
        for mode in ('zero','partial'):
            directory=out/(kind+'-'+mode);directory.mkdir()
            arm=directory/'arm';arm.write_text('armed')
            trace=directory/'calls'
            cap=Capture([str(peer),kind],directory,{'LD_PRELOAD':str(libs/'write_fault.so'),'CJTUI_A_WRITE_MATCH':kind,'CJTUI_A_WRITE_FAULT':mode,'CJTUI_A_WRITE_ARM_FILE':str(arm),'CJTUI_A_WRITE_TRACE':str(trace)})
            meta=cap.finish(send_quit=False);restored(meta);assert meta['exit']==14
            values=rows(trace);failure_wire(values,kind,mode)
            assert len(cap.raw)==(0 if mode=='zero' else 1)
            observed.append(kind+'-'+mode)
    partial=rows(out/'query-partial/calls')
    bad=copy.deepcopy(partial);bad.append(dict(call=99,length=6,action='ok',result=6,data=b'\x1b[?25l'))
    negatives.append(expect_rejected(lambda:failure_wire(bad,'query','partial'),'unsafe-late-restore'))
    bad=copy.deepcopy(partial);bad[0]['data']=b'not-a-query'
    negatives.append(expect_rejected(lambda:failure_wire(bad,'query','partial'),'wrong-selected-boundary'))
    bad=copy.deepcopy(partial);bad.append(copy.deepcopy(bad[0]))
    negatives.append(expect_rejected(lambda:failure_wire(bad,'query','partial'),'duplicate-fault'))
    zero=[dict(call=1,length=7,action='zero',result=-1,data=b'\x1b[1;3H'),dict(call=2,length=6,action='ok',result=6,data=b'\x1b[?25h')]
    negatives.append(expect_rejected(lambda:failure_wire(zero,'caret-only','zero'),'zero-failure-wrong-restore'))
    unknown_wire(b'plain',queries=0)
    negatives.append(expect_rejected(lambda:unknown_wire(QUERY,queries=0),'pre-query-failure-must-not-query'))
    unknown_wire(QUERY+b'fixture')
    negatives.append(expect_rejected(lambda:unknown_wire(b'fixture'),'default-missing-query'))
    negatives.append(expect_rejected(lambda:unknown_wire(QUERY+b'\x1b[?25h'),'default-forbidden-show'))
    for mode in ('zero','partial'):
        directory=out/('legacy-index-'+mode);directory.mkdir()
        trace=directory/'calls'
        cap=Capture([str(peer),'query'],directory,{'LD_PRELOAD':str(libs/'write_fault.so'),'CJTUI_A_WRITE_FAIL_AT':'1','CJTUI_A_WRITE_FAULT':mode,'CJTUI_A_WRITE_TRACE':str(trace)})
        meta=cap.finish(send_quit=False);restored(meta);assert meta['exit']==14
        failure_wire(rows(trace),'query',mode)
        assert len(cap.raw)==(0 if mode=='zero' else 1)
        observed.append('legacy-index-'+mode)
    directory=out/'hup';directory.mkdir();arm=directory/'arm'
    cap=Capture([str(peer),'hup'],directory,{'LD_PRELOAD':str(libs/'input_hup.so'),'CJTUI_A_HUP_ARM_FILE':str(arm),'CJTUI_A_HUP_TRACE':str(directory/'calls')})
    cap.wait_bytes(b'READY');arm.write_text('armed')
    meta=cap.finish(send_quit=False);restored(meta);assert meta['exit']==0 and 'POLLHUP fd=0' in (directory/'calls').read_text()
    from matrix import executable
    vectors=json.loads((native.parent/'fixtures/vectors.json').read_text())['cases']
    active=[x for x in vectors if executable(x)];future=[x for x in vectors if not executable(x)]
    assert len(active)==87 and len(future)==7 and all(x['stage']=='future-Keyboard' for x in future)
    result=dict(scope='fixture-only; no cjtui A execution or decoder/policy peer',selected_boundaries=observed,negative_controls=negatives,poll_hup=True,executable_A_vectors=len(active),future_Keyboard_vectors=[x['id'] for x in future])
    (out/'result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',required=True);run(p.parse_args().output)
