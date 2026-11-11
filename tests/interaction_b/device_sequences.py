#!/usr/bin/env python3
"""Public B consumers on real PTYs. Literal numeric oracles, no terminal model."""
import argparse,json,os,pathlib,signal,subprocess,time,pty,hashlib
from pty_driver import resize,attributes,drain,controlling_terminal

def state_fields(value):
    parts=value.split('/')
    if len(parts)!=8 or parts[-1] not in ('true','false'):raise ValueError('incomplete public state')
    return list(map(int,parts[:7]))+[parts[-1]=='true']

def expect_state(actual,expected):
    for index,wanted in expected.items():assert actual[index]==wanted,(actual,expected)

class Sequence:
    def __init__(self,binary,out,mode):
        self.out=out;out.mkdir(parents=True);self.mode=mode;self.events=[];self.raw=bytearray();self.query_count=0
        self.master,self.slave=pty.openpty();resize(self.slave,4,1);self.before=attributes(self.slave)
        self.binary=pathlib.Path(binary).resolve()
        env=dict(os.environ,CJTUI_VIEWPORT_CASE=mode,CJTUI_VIEWPORT_OUTPUT=str(out),TERM='xterm-256color')
        self.child=subprocess.Popen([str(self.binary)],stdin=self.slave,stdout=self.slave,stderr=self.slave,env=env,preexec_fn=lambda:controlling_terminal(self.slave))
    def send(self,data):
        self.events.append(dict(input_hex=data.hex(),monotonic_ns=time.monotonic_ns()));os.write(self.master,data)
    def pump(self):self.raw.extend(drain(self.master,.005))
    def file(self,name):
        until=time.monotonic()+4;p=self.out/name
        while time.monotonic()<until:
            self.pump()
            if p.exists() and p.stat().st_size:return p.read_text()
            if self.child.poll() is not None:break
        raise AssertionError('missing public observation '+name)
    def query(self):
        self.query_count+=1;self.send(b's');name='state-'+str(self.query_count);until=time.monotonic()+4
        while time.monotonic()<until:
            value=self.file(name)
            try:result=state_fields(value);self.events.append(dict(query=name,state=result,wire_bytes=len(self.raw)));return result
            except ValueError:self.pump()
        raise AssertionError('incomplete public state '+name)
    def change_size(self,w,h):
        got=resize(self.slave,w,h);os.killpg(self.child.pid,signal.SIGWINCH)
        self.events.append(dict(actual_resize=got,monotonic_ns=time.monotonic_ns()))
    def finish(self):
        if self.child.poll() is None:self.send(b'q')
        until=time.monotonic()+4
        while self.child.poll() is None and time.monotonic()<until:self.pump()
        forced=self.child.poll() is None
        if forced:os.killpg(self.child.pid,signal.SIGKILL)
        code=self.child.wait();self.pump();after=attributes(self.slave)
        (self.out/'wire.bin').write_bytes(self.raw)
        meta=dict(mode=self.mode,binary=str(self.binary),binary_sha256=hashlib.sha256(self.binary.read_bytes()).hexdigest(),exit=code,forced=forced,before=self.before,after=after,events=self.events)
        (self.out/'capture.json').write_text(json.dumps(meta,indent=2)+'\n');os.close(self.master);os.close(self.slave)
        assert not forced and code==0 and self.before==after,meta

def completed_size(s,width,height):
    until=time.monotonic()+4
    while time.monotonic()<until:
        state=s.query()
        if state[:2]==[width,height]:return state
    raise AssertionError('actual resize did not produce completed public geometry')

def run_case(binary,out,mode):
    s=Sequence(binary,out/mode,mode)
    try:
        initial=s.query()
        if mode=='unicode':
            expect_state(initial,{0:2,1:1,2:4,4:0,5:0})
            for key,offset in [(b'1',1),(b'2',2),(b'b',0)]:
                s.send(key);expect_state(s.query(),{0:2,1:1,4:offset,5:0})
            # Full grapheme/style/continuation/chrome goldens are asserted by
            # unicodeViewportClipping; this raw stream is retained for damage review.
        else:
            expect_state(initial,{0:4,1:1,2:13,4:0})
            s.send(b'o');expect_state(s.query(),{0:4,4:9,6:3,7:True})
            if mode=='same-turn':
                s.send(b'n');assert s.file('callback-enter')=='4/9'
                s.change_size(2,1);(s.out/'resize-ready').write_text('actual2x1')
                assert s.file('callback-explicit')=='caret2/end'
                expect_state(s.query(),{0:2,1:1,2:13,4:1,6:1,7:True})
                s.send(b'0');expect_state(s.query(),{0:2,4:0,7:False})
                expect_state(s.query(),{0:2,4:0,7:False})
            else:
                s.change_size(2,1);expect_state(completed_size(s,2,1),{0:2,4:11,6:1,7:True})
        return dict(case=mode,result='public state PASS; raw wire requires independent damage review')
    finally:s.finish()

def self_test():
    # State oracle controls only, never a fake product or layout.
    expect_state(state_fields('2/1/13/1/1/0/1/true'),{0:2,4:1,6:1,7:True})
    for bad in ['2/1/13/1/11/0/1/true','2/1/13/1/0/0/0/false','4/1/13/1/1/0/1/true']:
        try:expect_state(state_fields(bad),{0:2,4:1,6:1,7:True})
        except AssertionError:pass
        else:raise AssertionError('weak caret/resize oracle')
    print('INFRA ONLY state oracle accepts new intent and rejects old caret/old width/wrong offset')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--binary',type=pathlib.Path);p.add_argument('--output',type=pathlib.Path);p.add_argument('--self-test',action='store_true');a=p.parse_args()
    if a.self_test:self_test()
    elif a.binary and a.output:
        if not a.binary.is_file():raise SystemExit('BLOCKED missing actual product binary')
        a.output.mkdir(parents=True,exist_ok=True)
        results=[run_case(a.binary,a.output,x) for x in ['caret-resize','same-turn','unicode']]
        (a.output/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    else:p.error('choose --self-test or --binary and --output')
