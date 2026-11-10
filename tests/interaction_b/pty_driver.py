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


def self_test():
    master, slave = pty.openpty()
    try:
        before = attributes(slave)
        assert resize(slave, 80, 24) == [80, 24]
        assert resize(master, 40, 10) == [40, 10]
        assert dimensions(slave) == [40, 10]
        assert attributes(slave) == before
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
    metadata = {'classification': 'product-run-recording-needs-independent-oracle',
                'binary': str(binary.resolve()),
                'binary_sha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
                'TERM': os.environ.get('TERM', 'xterm-256color'), 'sizes': []}
    raw = bytearray()
    try:
        metadata['termios_before'] = attributes(slave)
        metadata['sizes'].append(resize(slave, 80, 24))
        env = dict(os.environ, CJTUI_VIEWPORT_CASE='pty', TERM=metadata['TERM'])
        child = subprocess.Popen([str(binary.resolve())], stdin=slave, stdout=slave, stderr=slave,
                                 env=env, preexec_fn=lambda: controlling_terminal(slave), close_fds=True)
        phases = [('initial', None, None), ('tail', None, b'\x1b[B'*100),
                  ('smaller', (40, 10), None), ('restored', (80, 24), None), ('quit', None, b'q')]
        for name, size, keys in phases:
            if size:
                metadata['sizes'].append(resize(slave, *size))
                os.killpg(child.pid, signal.SIGWINCH)
            if keys:
                os.write(master, keys)
            block = drain(master, 0.85 if name == 'initial' else 0.35)
            raw.extend(block)
            (destination/f'{name}.raw').write_bytes(block)
            if name == 'initial':
                metadata['termios_during'] = attributes(slave)
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
