#!/usr/bin/env python3
"""Real consumer runner and regular-file I/O barrier controller (Linux)."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import selectors
import subprocess
import sys
import tempfile
import time
from generate_inputs import generate, literal

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
CASES={
    'lifecycle':set(),
    'session-fence':{('gate-old.toml',1)}, 'queued-restart':set(),
    'latest-success':{('gate-old.toml',1),('gate-fence.toml',1)},
    'candidate-order':set(),
    'latest-failure':{('gate-old.toml',1),('gate-fence.toml',1)},
    'pending-bound':{('gate-old.toml',1),('gate-pending-31.toml',1)},
    'post-capacity':set(), 'atomic-caches':set(),
    'reload-origin':{('gate-other.toml',1)},
    'relative-origin':{('gate-old.toml',1)},
    'observability':{('gate-observe.toml',1),('gate-background.toml',1)},
    'getter-reentry':set(), 'event-post':set(),
    'build-reentry':set(), 'synchronous-values':set(),
    'exception-boundary':set(), 'current-cache':{('gate-old.toml',1)},
    'background-race':{('gate-old.toml',1)},
    'multi-application':{('gate-app-a.toml',1),('gate-app-b.toml',1)},
    'cleanup':{('gate-old.toml',1)}, 'recoverable':set(),
    'infrastructure':{('gate-probe.toml',1)},
}

def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()

def run_controlled(binary, case, work, library, logs, sha, timeout):
    generate(work)
    control=work/'control';control.mkdir()
    for source in work.glob('gate-*.toml'):
        for occurrence in range(1,5):os.mkfifo(control/f'{source.name}.{occurrence}')
    initial={str(p.relative_to(work)):hashlib.sha256(p.read_bytes()).hexdigest() for p in work.rglob('*') if p.is_file()}
    (logs/f'{case}.initial-inputs.json').write_text(json.dumps(initial,indent=2)+'\n')
    env=os.environ.copy()
    env.update(LD_PRELOAD=str(library),THEME_GATE_ROOT=str(work),THEME_GATE_CONTROL=str(control))
    argv=[str(binary),case,str(work)]
    begin=utc();started=time.monotonic();deadline=started+timeout
    process=subprocess.Popen(argv,cwd=work,env=env,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,bufsize=0)
    selector=selectors.DefaultSelector()
    selector.register(process.stdout,selectors.EVENT_READ,'stdout')
    selector.register(process.stderr,selectors.EVENT_READ,'stderr')
    buffers={'stdout':b'','stderr':b''};raw={'stdout':bytearray(),'stderr':bytearray()}
    entered=set();released=set();active=set();writers={};pending=None;problem=None;events=[]
    def event(kind,**fields):events.append(dict(utc=utc(),elapsed=time.monotonic()-started,kind=kind,**fields))
    def answer():
        nonlocal pending
        if pending is None:return
        parts=pending.split(':')
        if parts[0]=='entered':
            key=(parts[1],int(parts[2]))
            if key not in entered:return
        elif parts[0]=='release':
            key=(parts[1],int(parts[2]))
            if key not in entered:raise RuntimeError(f'release without actual SDK I/O entry: {key}')
            if key in writers:raise RuntimeError(f'duplicate release: {key}')
            fd=os.open(control/f'{key[0]}.{key[1]}',os.O_RDWR|os.O_NONBLOCK)
            os.write(fd,b'R');writers[key]=fd
        elif parts[0]=='write':
            target=(work/parts[1]).resolve()
            if not target.is_relative_to(work):raise RuntimeError('fixture path escaped isolated directory')
            temporary=target.with_name(target.name+'.new')
            temporary.write_bytes(literal(parts[2]));os.replace(temporary,target)
        elif pending!='tick':raise RuntimeError(f'unknown synchronization command {pending}')
        event('barrier',command=pending)
        process.stdin.write(('OK '+pending+'\n').encode());process.stdin.flush();pending=None
    def line(stream,data):
        nonlocal pending
        value=data.decode('utf-8',errors='replace').rstrip('\r\n')
        if stream=='stdout' and value.startswith('SYNC '):
            if pending is not None:raise RuntimeError('overlapping child protocol commands')
            pending=value[5:];answer()
        if stream=='stderr' and value.startswith('THEME_GATE '):
            parts=value.split()
            if parts[1]=='ENTER':
                key=(parts[2],int(parts[3]))
                if key not in CASES[case]:raise RuntimeError(f'unexpected real file read {key}; obsolete/inactive work executed')
                if key in entered:raise RuntimeError(f'duplicate actual read gate {key}')
                if case!='multi-application' and active:raise RuntimeError(f'concurrent gated reads {active} and {key}')
                entered.add(key);active.add(key)
                event('io-enter',file=key[0],sequence=key[1],api=parts[4],tid=parts[5])
            elif parts[1]=='RELEASED':
                key=(parts[2],int(parts[3]));released.add(key);active.discard(key)
                if key in writers:os.close(writers.pop(key))
                event('io-released',file=key[0],sequence=key[1])
            else:raise RuntimeError(f'test interposer failed: {value}')
            answer()
    try:
        while selector.get_map():
            left=deadline-time.monotonic()
            if left<=0:raise TimeoutError(f'{case} deadlocked/non-completing; no timing-based success inference')
            for key,_ in selector.select(left):
                data=os.read(key.fileobj.fileno(),65536)
                if not data:selector.unregister(key.fileobj);continue
                stream=key.data;raw[stream].extend(data);buffers[stream]+=data
                while b'\n' in buffers[stream]:
                    item,buffers[stream]=buffers[stream].split(b'\n',1);line(stream,item+b'\n')
        process.wait(timeout=max(0.1,deadline-time.monotonic()))
        if process.returncode!=0:raise RuntimeError(f'{case} binary exit {process.returncode}')
        if entered!=CASES[case] or entered!=released:raise RuntimeError(f'incomplete real-I/O trace {entered}/{released}')
        if f'PASS CASE {case}'.encode() not in raw['stdout']:raise RuntimeError('child omitted completed-case sentinel')
    except Exception as error:
        problem=str(error)
        if process.poll() is None:process.kill()
        tail_out,tail_err=process.communicate(timeout=5)
        raw['stdout'].extend(tail_out);raw['stderr'].extend(tail_err)
    finally:
        for fd in writers.values():os.close(fd)
        selector.close()
        for stream,data in raw.items():(logs/f'{case}.{stream}').write_bytes(data)
        (logs/f'{case}.events.json').write_text(json.dumps(events,indent=2)+'\n')
        record=dict(name=case,utc=begin,command=argv,cwd=str(work),sha=sha,exit=process.returncode,controller_error=problem,
                    stdout=f'{case}.stdout',stderr=f'{case}.stderr',preload_sha256=hashlib.sha256(library.read_bytes()).hexdigest())
        with (logs/'commands.jsonl').open('a') as f:f.write(json.dumps(record)+'\n')
    if problem:raise RuntimeError(problem)
    print(f'{case}: exit {process.returncode}; all real-I/O barriers satisfied',flush=True)


def main():
    p=argparse.ArgumentParser()
    p.add_argument('mode',choices=['infrastructure','foundation','async-probe','all'],nargs='?',default='all')
    p.add_argument('--case',choices=[x for x in CASES if x!='infrastructure'],action='append')
    p.add_argument('--logs',type=Path)
    p.add_argument('--timeout',type=float,default=30)
    args=p.parse_args()
    logs=(args.logs or Path(tempfile.mkdtemp(prefix='cjtui-theme-load-evidence-'))).resolve();logs.mkdir(parents=True,exist_ok=True)
    sha=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
    tracked={str(x.relative_to(HERE)):hashlib.sha256(x.read_bytes()).hexdigest() for x in HERE.rglob('*') if x.is_file() and not any(v in x.parts for v in ['target','__pycache__']) and x.name not in ['cjpm.lock','cangjie-repo.toml']}
    (logs/'source-hashes.json').write_text(json.dumps(tracked,indent=2)+'\n')
    print(f'evidence: {logs}',flush=True)
    def command(name,argv,cwd):
        begin=utc();out=subprocess.run(argv,cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        (logs/f'{name}.stdout').write_bytes(out.stdout);(logs/f'{name}.stderr').write_bytes(out.stderr)
        with (logs/'commands.jsonl').open('a') as f:f.write(json.dumps(dict(name=name,utc=begin,command=argv,cwd=str(cwd),sha=sha,exit=out.returncode,stdout=f'{name}.stdout',stderr=f'{name}.stderr'))+'\n')
        print(f'{name}: exit {out.returncode}',flush=True)
        if out.returncode:sys.stderr.buffer.write(out.stderr)
        return out
    library=logs/'libtheme_io_gate.so'
    built=command('gate-build',['cc','-shared','-fPIC','-Wall','-Wextra','-Werror',str(HERE/'native/gate_wrap.c'),'-o',str(library),'-ldl','-pthread'],HERE)
    if built.returncode:raise SystemExit(built.returncode)
    if args.mode=='infrastructure':
        built=command('probe-build',['cjpm','build'],HERE/'probe')
        if built.returncode:raise SystemExit(built.returncode)
        run_controlled(HERE/'probe/target/release/bin/main','infrastructure',logs/'work-infrastructure',library,logs,sha,args.timeout)
        print('PASS synchronization infrastructure only; no Theme product behavior was run')
        return
    base=command('foundation-build',['cjpm','build'],HERE/'foundation')
    if base.returncode:
        print('BLOCKED foundation is not available; this is NOT async-only RED',flush=True)
        raise SystemExit(78)
    base=command('foundation-run',[str(HERE/'foundation/target/release/bin/main')],HERE/'foundation')
    if base.returncode:raise SystemExit(base.returncode)
    if args.mode=='foundation':return
    built=command('async-api-build',['cjpm','build'],HERE/'api-probe')
    if built.returncode:
        print('Async API probe build failed after real foundation gate; classify missing API from raw diagnostics',flush=True)
        raise SystemExit(built.returncode)
    if args.mode=='async-probe':
        print('Async API consumer compiles; behavioral execution not requested by probe mode',flush=True)
        return
    built=command('consumer-build',['cjpm','build'],HERE/'consumer')
    if built.returncode:raise SystemExit(built.returncode)
    for case in args.case or [x for x in CASES if x!='infrastructure']:
        run_controlled(HERE/'consumer/target/release/bin/main',case,logs/f'work-{case}',library,logs,sha,args.timeout)
    print('PASS selected public async theme loading cases',flush=True)

if __name__=='__main__':main()
