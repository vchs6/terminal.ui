#!/usr/bin/env python3
"""Real PTY evidence recorder. It does not emulate a terminal or judge a product grid."""
import argparse
import errno
import fcntl
import hashlib
import json
import os
from pathlib import Path
import pty
import select
import signal
import struct
import subprocess
import termios
import time


def dimensions(fd):
    rows, cols, _, _ = struct.unpack('HHHH', fcntl.ioctl(fd, termios.TIOCGWINSZ, bytes(8)))
    return [cols, rows]


def resize(fd, cols, rows):
    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack('HHHH', rows, cols, 0, 0))
    got = dimensions(fd)
    if got != [cols, rows]:
        raise RuntimeError(f'window readback {got} != {[cols, rows]}')
    return got


def attributes(fd):
    result = termios.tcgetattr(fd)
    result[-1] = [list(v) if isinstance(v, bytes) else v for v in result[-1]]
    return result


def drain(fd, seconds):
    end = time.monotonic() + seconds
    result = bytearray()
    while time.monotonic() < end:
        ready, _, _ = select.select([fd], [], [], max(0, end-time.monotonic()))
        if not ready:
            break
        try:
            block = os.read(fd, 65536)
        except OSError as exc:
            if exc.errno == errno.EIO:
                break
            raise
        if not block:
            break
        result.extend(block)
    return bytes(result)


def controlling_terminal(slave):
    os.setsid()
    fcntl.ioctl(slave, termios.TIOCSCTTY, 0)



def readiness_observed(raw,local_flags,markers):
    return not (local_flags & (termios.ICANON|termios.ECHO)) and b'\x1b[?25$p' in raw and all(x in raw for x in markers)

def wait_ready(child,master,slave,raw,markers,timeout=10):
    until=time.monotonic()+timeout
    while time.monotonic()<until:
        raw.extend(drain(master,.01));flags=termios.tcgetattr(slave)[3]
        if readiness_observed(raw,flags,markers):
            return dict(monotonic_ns=time.monotonic_ns(),local_flags=flags,wire_bytes=len(raw),markers_hex=[x.hex() for x in markers],query_seen=True,raw_mode=True)
        if child.poll() is not None:raise RuntimeError('product exited before raw-open/first-frame readiness: '+str(child.returncode))
    raise RuntimeError('product raw-open/first-frame readiness not observed')

def self_test():
    master, slave = pty.openpty()
    try:
        before = attributes(slave)
        assert resize(slave, 80, 24) == [80, 24]
        assert resize(master, 40, 10) == [40, 10]
        assert dimensions(slave) == [40, 10]
        assert attributes(slave) == before
        markers=(b'r0',b'r23');wire=b'\x1b[?25$p'+b'r0'+b'r23'
        assert readiness_observed(wire,0,markers)
        assert not readiness_observed(wire,termios.ICANON|termios.ECHO,markers)
        assert not readiness_observed(b'\x1b[?25$p',0,markers)
        assert not readiness_observed(b's',0,markers)
        # Negative control proves readback comparison can reject a wrong dimension.
        assert dimensions(slave) != [80, 24]
        print('HARNESS-ONLY: real PTY resize/readback and termios recording verified; no product run')
    finally:
        os.close(master)
        os.close(slave)


def run(binary, destination):
    if not binary.is_file():
        raise SystemExit('BLOCKED: actual built product fixture binary is missing')
    destination.mkdir(parents=True, exist_ok=True)
    master, slave = pty.openpty()
    child = None
    metadata = {'classification': 'public viewport dimensions/offset/activeTarget assertions plus raw damage evidence; no terminal emulator',
                'binary': str(binary.resolve()),
                'binary_sha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
                'TERM': os.environ.get('TERM', 'xterm-256color'), 'sizes': []}
    raw = bytearray()
    try:
        metadata['termios_before'] = attributes(slave)
        metadata['sizes'].append(resize(slave, 80, 24))
        env = dict(os.environ, CJTUI_VIEWPORT_CASE='pty', CJTUI_VIEWPORT_OUTPUT=str(destination.resolve()), TERM=metadata['TERM'])
        child = subprocess.Popen([str(binary.resolve())], stdin=slave, stdout=slave, stderr=slave,
                                 env=env, preexec_fn=lambda: controlling_terminal(slave), close_fds=True)
        metadata['readiness']=wait_ready(child,master,slave,raw,(b'r0',b'r23'))
        phases = [('initial', None, None, [80,24,100,0]),
                  ('tail', None, b'\x1b[B'*100, [80,24,100,76]),
                  ('smaller', (40,10), None, [40,10,100,76]),
                  ('smaller-tail', None, b'\x1b[B'*14, [40,10,100,90]),
                  ('restored', (80,24), None, [80,24,100,76]),
                  ('quit', None, b'q', None)]
        queries=0
        for name,size,keys,expected in phases:
            begin=len(raw)
            if size:
                metadata['sizes'].append(resize(slave,*size));os.killpg(child.pid,signal.SIGWINCH)
            if keys:os.write(master,keys)
            if expected is not None:
                until=time.monotonic()+10
                while time.monotonic()<until:
                    queries+=1;os.write(master,b's');statefile=destination/('state-'+str(queries))
                    while not statefile.exists() and time.monotonic()<until:raw.extend(drain(master,.01))
                    if not statefile.exists():raise RuntimeError('missing public viewport state')
                    value=statefile.read_text().split('/')
                    if len(value)!=6:continue
                    got=list(map(int,value[:4]))
                    if got[:2]!=expected[:2]:continue
                    assert got==expected and value[4:]==['true','true'],(name,value,expected)
                    metadata.setdefault('public_states',[]).append({'phase':name,'actual':value,'manual_expected':expected})
                    break
                else:raise RuntimeError('resize did not reach completed public geometry')
            raw.extend(drain(master,.02))
            (destination/f'{name}.raw').write_bytes(raw[begin:])
            if name=='initial':metadata['termios_during']=attributes(slave)
        metadata['exit'] = child.wait(timeout=5)
        raw.extend(drain(master, 0.1))
        metadata['termios_after'] = attributes(slave)
        metadata['termios_restored'] = metadata['termios_after'] == metadata['termios_before']
        if metadata['exit'] != 0 or not metadata['termios_restored']:
            raise RuntimeError('actual fixture exit/termios restoration failed; inspect metadata/raw')
    finally:
        if child is not None and child.poll() is None:
            os.killpg(child.pid, signal.SIGKILL)
            child.wait()
            metadata['forced_cleanup'] = True
        if child is not None:
            metadata.setdefault('exit',child.returncode)
            metadata.setdefault('termios_after',attributes(slave))
            metadata['termios_restored']=metadata['termios_after']==metadata['termios_before']
        (destination/'output.raw').write_bytes(raw)
        (destination/'metadata.json').write_text(json.dumps(metadata, indent=2)+'\n')
        os.close(master)
        os.close(slave)
    print('RECORDED: actual PTY bytes/resize/readback/termios; grid and focus admission still require independent review')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--self-test', action='store_true')
    parser.add_argument('--binary', type=Path)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    if args.self_test:
        self_test()
    elif args.binary and args.output:
        run(args.binary, args.output)
    else:
        parser.error('choose --self-test or --binary PATH --output DIR')
