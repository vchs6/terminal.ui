"""Actual PTY endpoint destruction. Never restores/replaces the endpoint.

This is separate from OSpipe read/poll routing and from actual terminal hosts.
The last master is closed after public UI readiness; post-HUP tcgetattr failure
is retained as unavailable restoration evidence, never replaced with a fake TTY.
"""
import sys
sys.dont_write_bytecode = True
import argparse
import errno
import hashlib
import json
import os
import pathlib
import signal
import termios
import time
from driver import Capture, until, read, QUERY


def main(binary, out):
    out.mkdir(parents=True, exist_ok=False)
    cap = Capture([str(binary)], out, {'TERM': 'xterm-256color',
        'CJTUI_020_OUTPUT': str(out), 'CJTUI_020_CASE': 'tty-hangup', 'CJTUI_020_HOST_AUTO': '0',
        'CJTUI_SESSION_NATIVE': str(out / 'native.tsv')})
    master_closed = False
    try:
        until(cap, lambda: QUERY in cap.raw, 'real query')
        # Withhold the reply: actual Unknown timeout, zero mode25 permission.
        deadline = time.monotonic() + 3
        while read(out / 'probe-1') != 'unknown-timeout' and time.monotonic() < deadline:
            cap.send(b'r'); cap.drain(.03)
        assert read(out / 'probe-1') == 'unknown-timeout'
        cap.send(b'o'); cap.wait_bytes(b'LAYER1')
        cap.send(b's')
        until(cap, lambda: read(out / 'state-1') == 'unknown-timeout', 'public ready')
        active = termios.tcgetattr(cap.slave)
        assert not active[3] & (termios.ECHO | termios.ICANON | termios.ISIG)
        cap.drain(.02)
        (out / 'wire-before-hup.bin').write_bytes(cap.raw)
        closed_ns = time.monotonic_ns()
        os.close(cap.master); master_closed = True
        try:
            result = cap.process.wait(timeout=4)
            timed_out = False
        except __import__('subprocess').TimeoutExpired:
            os.killpg(cap.process.pid, signal.SIGKILL)
            result = cap.process.wait(); timed_out = True
        after = None; after_error = None
        try: after = termios.tcgetattr(cap.slave)
        except termios.error as error: after_error = {'errno': error.args[0], 'message': str(error)}
        metadata = {'binary': str(binary), 'binarySha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
            'utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
            'exit': result, 'timed_out': timed_out, 'before': cap.before, 'active': active,
            'lastMasterClosedMonotonicNs': closed_ns, 'after': after, 'afterError': after_error,
            'inputs': cap.sent, 'sameEndpointRestart': 'ineligible: endpoint destroyed',
            'transport': 'actual last PTY master close; no FD repair/replacement; no actual terminal host'}
        (out / 'capture.json').write_text(json.dumps(metadata, indent=2, default=lambda value: {'hex': value.hex()}) + '\n')
        assert result == 0 and not timed_out, 'consumer must report expected HUP cleanup failure then exit'
        assert after is None and after_error['errno'] == errno.EIO, 'destroyed TTY restoration cannot be certified'
        assert read(out / 'complete') == 'yes' and read(out / 'closed-1') == '0/0/0/0'
        assert not (out / 'closed-2').exists(), 'no fake endpoint restart'
        native = read(out / 'native.tsv')
        title_error = 'host title restore failed; visual title state not confirmed'
        cleanup_tail = 'terminal write failed\nterminal restore failed\n'
        # K004 follows the real native result. Kernel endpoint closure may
        # deliver read0 or EIO, or become unavailable before the next size read.
        # Select a literal outcome only with matching real native evidence.
        if 'native-read\t-4\t0' in native:
            assert 'tty-read\t0\t0' in native, 'actual kernel TTY read0 required'
            primary, extras = title_error, cleanup_tail
            branch = 'read0/EOF (-4)'
        elif 'native-read\t-3\t0' in native:
            primary, extras = 'terminal input failed', title_error + '\n' + cleanup_tail
            branch = 'actual native input error (-3)'
        else:
            assert 'size-result\t-1\t' in native, 'actual size failure required'
            primary, extras = 'terminal size unavailable', title_error + '\n' + cleanup_tail
            branch = 'actual ioctl size error before next input read'
        assert read(out / 'primary-1') == primary, 'exact primary for observed kernel branch'
        assert read(out / 'extras-1') == extras, 'exact ordered title/paste/native cleanup failures'
        assert native.count('close\t-1\t0') == 1 and native.count('buffer-free\t') == 1
        assert native.count('signal-flags\t') == 3 and not any(row.endswith('\t0') for row in native.splitlines() if row.startswith('signal-flags'))
        assert native.count('buffer-released\t1') == 1
        assert not any(seq in cap.raw for seq in (b'\x1b[?25h', b'\x1b[?25l', b'\x1b[?25s', b'\x1b[?25r'))
        (out / 'check.json').write_text(json.dumps({'passed': True, 'directExit': result,
            'termiosRestoration': 'unavailable with explicit native failure; no success claim', 'kernelBranch': branch}) + '\n')
    finally:
        if cap.process.poll() is None:
            os.killpg(cap.process.pid, signal.SIGKILL); cap.process.wait()
        if not master_closed: os.close(cap.master)
        os.close(cap.slave)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(); parser.add_argument('--binary', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True); args = parser.parse_args()
    assert os.environ.get('CJTUI_020_ROOT_GO') == '1' and pathlib.Path(os.environ['CJTUI_020_ADMISSION']).is_file()
    main(args.binary.resolve(), args.output.resolve())
