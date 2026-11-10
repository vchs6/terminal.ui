"""Execute prepared I015 vectors through the public device consumer.

Requires a real product binary linked with the test-only cjt_monotonic_ms wrap.
This drives bytes and observes public files/wire; it is not a second decoder.
Future Keyboard vectors remain explicitly blocked and are never simulated.
"""
import argparse,json,os,pathlib,time
from pty_capture import Capture,QUERY,unknown_wire,restored

class MatrixSession:
    def __init__(self,binary,out,initial=1000):
        self.out=pathlib.Path(out);self.out.mkdir(parents=True,exist_ok=True)
        self.clock=self.out/'clock.txt';self.trace=self.out/'clock.calls';self.set_time(initial)
        self.cap=Capture([str(pathlib.Path(binary).resolve())],self.out,{
            'CJTUI_A_CLOCK_FILE':str(self.clock),'CJTUI_A_CLOCK_TRACE':str(self.trace)})
    def set_time(self,value):
        temp=self.clock.with_suffix('.next');temp.write_text(str(value)+'\n');temp.replace(self.clock)
    def ready(self):
        self.cap.wait_bytes(QUERY)
        end=time.monotonic()+3
        while time.monotonic()<end:
            if self.trace.exists() and len(self.trace.read_text().splitlines())>=2: return
            self.cap.drain(.01)
        raise AssertionError('controlled-clock wrapper not linked or t0 not sampled')
    def status(self,want):
        self.cap.send(b's')
        return self.cap.state(lambda s:s.startswith(want+'\n'))
    def close(self):
        meta=self.cap.finish();restored(meta)
        assert meta['exit']==0,meta
        return meta

def run_case(binary,out,case):
    name=case['id'];s=MatrixSession(binary,pathlib.Path(out)/name)
    cap=s.cap
    try:
        s.ready()
        if name.startswith('report-'):
            for chunk in case['chunks_hex']:cap.send(bytes.fromhex(chunk));cap.drain(.002)
            state=s.status(case['expected_status']);assert state.splitlines()[-1]=='text:s|',state
        elif name.startswith('reject-'):
            cap.send(bytes.fromhex(case['input_hex']));s.status('pending')
        elif name in ('deadline-599','deadline-600','late-never-upgrade'):
            s.set_time(case['final_ms']);cap.send(b'\x1b[?25;1$y');s.status(case['expected_status'])
        elif name=='cross-deadline':
            s.set_time(1580);cap.send(bytes.fromhex(case['chunks_hex'][0]));cap.drain(.01)
            s.set_time(1600);cap.drain(.03) # probe wakeup must not timeout the same CSI
            s.set_time(1610);cap.send(bytes.fromhex(case['chunks_hex'][1]));state=s.status('unknown-timeout')
            assert state.splitlines()[-1]=='text:s|',state
        elif name=='continuous-input':
            for at in case['input_times_ms']:
                s.set_time(at);cap.send(b'a');cap.drain(.002)
            state=s.status('unknown-timeout');assert state.count('text:a|')==8,state
        elif name=='duplicate-opposite':
            cap.send(b'\x1b[?25;1$y');s.status('original-visible')
            cap.send(b'\x1b[?25;2$y');s.status('original-visible')
        elif name=='order-text-report-tab-utf8-backtab':
            cap.send(bytes.fromhex(case['input_hex']));state=s.status('original-visible')
            assert state.splitlines()[-1]=='text:a|tab:|text:界|backtab:|text:s|',state
        elif name=='csi-real-idle-A':
            s.set_time(1100);cap.send(bytes.fromhex(case['chunks_hex'][0]));cap.drain(.13)
            s.set_time(1201);cap.send(bytes.fromhex(case['chunks_hex'][1]));state=s.status('original-visible')
            assert state.splitlines()[-1]=='text:s|',state
        elif name=='bare-escape-real-idle':
            s.set_time(1001);cap.send(b'\x1b');cap.drain(.13)
            s.set_time(1101);cap.send(bytes.fromhex(case['chunks_hex'][1]));state=s.status('pending')
            assert state.splitlines()[-1].startswith('escape:|'),state
        else:
            raise ValueError('case has no executable A runner: '+name)
        status=(s.out/'state').read_text().splitlines()[0]
    finally:
        s.close()
    if status in ('pending','unknown-timeout','unknown-clock'):unknown_wire(cap.raw)
    if name=='duplicate-opposite':assert bytes(cap.raw).rfind(b'\x1b[?25h')>bytes(cap.raw).rfind(b'\x1b[?25l')
    return {'id':name,'result':'PASS','scope':'public product controlled-clock PTY','raw':str(s.out/'wire.bin')}

def executable(case):
    return case['id'].startswith(('report-','reject-')) or case['id'] in {
        'deadline-599','deadline-600','late-never-upgrade','cross-deadline','continuous-input',
        'duplicate-opposite','order-text-report-tab-utf8-backtab','csi-real-idle-A','bare-escape-real-idle'}

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--binary',required=True);p.add_argument('--output',required=True);p.add_argument('--case');a=p.parse_args()
    vectors=json.loads((pathlib.Path(__file__).parent/'vectors.json').read_text())['cases']
    chosen=[c for c in vectors if executable(c) and (a.case is None or c['id']==a.case)]
    if not chosen:raise SystemExit('no executable A vector selected')
    results=[run_case(a.binary,a.output,c) for c in chosen]
    pending=[c['id'] for c in vectors if not executable(c)]
    print(json.dumps({'executed':results,'explicitly_not_executed':pending},indent=2))
