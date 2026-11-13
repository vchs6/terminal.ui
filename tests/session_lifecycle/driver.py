"""Prepared public Application.run consumer using the existing real PTY helper.

No driver runtime result exists until actual root GO and fixed accepted008 input.
This imports Capture only; it does not invoke A's native-building recipe paths.
"""
import sys
sys.dont_write_bytecode = True
import argparse
import hashlib
import json
import os
import pathlib
import signal
import time

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'interaction_a' / 'fixtures'))
from pty_capture import Capture, restored  # existing real PTY/termios/resource handling
from oracle import QUERY, verify_wire, verify_records, verify_native


def until(cap, predicate, label, timeout=4):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        cap.drain(.01)
        if predicate():
            return
        if cap.process.poll() is not None:
            break
    raise AssertionError('missing lifecycle barrier: ' + label)


def read(path):
    return path.read_text() if path.exists() else ''


def run(binary, out, case, cursor):
    out.mkdir(parents=True, exist_ok=False)
    native = out / 'native.tsv'
    cap = Capture([str(binary)], out, {
        'TERM': 'xterm-256color',
        'CJTUI_020_OUTPUT': str(out), 'CJTUI_020_CASE': case['id'],
        'CJTUI_SESSION_NATIVE': str(native),
        'CJTUI_SESSION_CLOSE_FAIL': '1' if case['close_failure'] else '0',
    })
    metadata = None
    finalized = False
    (out / 'launch.json').write_text(json.dumps({
        'binary': str(binary), 'binarySha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
        'case': case, 'cursor': cursor, 'original2004': 'unknown-unqueried',
        'admissionManifest': os.environ.get('CJTUI_020_ADMISSION'),
        'utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
    }, indent=2) + '\n')
    try:
        for run_number in (1, 2):
            until(cap, lambda: bytes(cap.raw).count(QUERY) == run_number, 'query ' + str(run_number))
            if cursor != 'unknown':
                cap.send(b'\x1b[?25;1$y' if cursor == 'visible' else b'\x1b[?25;2$y')
            # Query through the real public event handler; repeated r is a state
            # read, not a guessed sleep or an injected terminal probe result.
            expected = {'visible': 'original-visible', 'hidden': 'original-hidden', 'unknown': 'unknown-timeout'}[cursor]
            deadline = time.monotonic() + 3
            while read(out / f'probe-{run_number}') != expected and time.monotonic() < deadline:
                cap.send(b'r'); cap.drain(.03)
                if cap.process.poll() is not None:
                    break
            assert read(out / f'probe-{run_number}') == expected, 'actual I015 status'
            if run_number == 1:
                cap.send(b'o'); cap.wait_bytes(b'LAYER1')
            cap.send(b's')
            until(cap, lambda: read(out / f'state-{run_number}') == expected, 'focus/caret/query barrier')
            if run_number == 2:
                cap.send(b'q')
            elif case['id'] in ('callback', 'getter', 'draw', 'post', 'callback-cleanup', 'callback-close'):
                cap.send(b'x')
            elif case['id'] == 'signal-int':
                cap.process.send_signal(signal.SIGINT)
            elif case['id'] == 'signal-term':
                cap.process.send_signal(signal.SIGTERM)
            elif case['id'] in ('ctrl-c', 'prevented'):
                cap.send(b'\x03')
                if case['id'] == 'prevented':
                    until(cap, lambda: read(out / 'prevented') == 'yes', 'prevented Ctrl-C')
                    assert cap.process.poll() is None and not (out / 'closed-1').exists(), 'preventDefault kept session active'
                    cap.send(b'q')
            else:
                cap.send(b'q')
            until(cap, lambda: read(out / f'closed-{run_number}') == '0/0/0/0', 'closed ' + str(run_number))
        finalized = True
        metadata = cap.finish(send_quit=False)
        restored(metadata)
        assert metadata['exit'] == 0 and not metadata['timed_out'], 'direct consumer assertion exit'
        records = {p.name: p.read_text() for p in out.iterdir() if p.is_file() and p.name in {
            'complete', 'assertion', 'closed-1', 'closed-2', 'error-1', 'error-2',
            'primary-1', 'extras-1', 'prevented'}}
        verify_records(records, case)
        verify_wire(bytes(cap.raw), cursor)
        verify_native(read(native), case['close_failure'])
        (out / 'check.json').write_text(json.dumps({'passed': True, 'directExit': metadata['exit']}) + '\n')
    finally:
        if not finalized:
            # Existing helper retains raw + exact exit/termios even on failure.
            # Its forced timeout kill remains a failure, never a lifecycle PASS.
            cap.finish(send_quit=False)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--binary', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    parser.add_argument('--case')
    args = parser.parse_args()
    if os.environ.get('CJTUI_020_ROOT_GO') != '1' or not pathlib.Path(os.environ.get('CJTUI_020_ADMISSION', '')).is_file():
        parser.error('requires actual root GO and readable fixed admission manifest; preparation cannot execute')
    matrix = json.loads((HERE / 'cases.json').read_text())
    selected = [c for c in matrix['cases'] if args.case is None or c['id'] == args.case]
    assert selected, 'unknown case'
    assert args.binary.is_file() and os.access(args.binary, os.X_OK), 'actual executable required'
    for case in selected:
        for cursor in matrix['cursor_states']:
            run(args.binary.resolve(), args.output.resolve() / (case['id'] + '-' + cursor), case, cursor)
