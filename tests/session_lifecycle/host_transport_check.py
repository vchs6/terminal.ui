"""Real nested-PTY validation of the frozen host runner/probe/oracle transport.

Protocol replies below are explicitly emulated PTYwire fixture input, never
actual XTerm/VTE/VT acknowledgement or actual-host evidence. Both outer script
and application endpoints are real kernel PTYs. The negative control changes
only the child post-close ECHO bit and must fail despite outer restoration.
"""
import sys
sys.dont_write_bytecode = True
import argparse
import hashlib
import json
import os
import pathlib
import time
from driver import Capture, read, restored
from oracle import QUERY, verify_termios_snapshots


def run(binary, output, cursor, declared=False, negative=False):
    output.mkdir(parents=True, exist_ok=False)
    child = output / 'child'
    shim = 'import fcntl,os,sys,termios; fcntl.ioctl(0,termios.TIOCSCTTY,0); os.execvp(sys.argv[1],sys.argv[1:])'
    cap = Capture([sys.executable, '-c', shim, 'bash', str(pathlib.Path(__file__).with_name('host_run.sh')),
                   str(binary), str(child), 'stop'], output / 'outer', {
        'TERM': 'xterm-256color', 'CJTUI_020_HOST_TITLE_STRESS': '1' if declared else '0',
        'CJTUI_020_NEGATIVE_CHILD_DRIFT': '1' if negative else '0'})
    seen = {25: 0, 2004: 0}; responses = []; steps = {1: 0, 2: 0}; last_r = 0
    expected = {'visible': 'original-visible', 'hidden': 'original-hidden', 'unknown': 'unknown-timeout'}[cursor]
    finalized = False
    try:
        deadline = time.monotonic() + 20
        while cap.process.poll() is None and time.monotonic() < deadline:
            cap.drain(.01)
            for mode, query in [(25, QUERY), (2004, b'\x1b[?2004$p')]:
                amount = bytes(cap.raw).count(query)
                while seen[mode] < amount:
                    seen[mode] += 1
                    reply = b''
                    if mode == 2004: reply = b'\x1b[?2004;1$y' if seen[mode] == 1 else b'\x1b[?2004;2$y'
                    elif cursor != 'unknown': reply = b'\x1b[?25;1$y' if cursor == 'visible' else b'\x1b[?25;2$y'
                    if reply: cap.send(reply)
                    responses.append({'mode': mode, 'request': seen[mode], 'responseHex': reply.hex(),
                                      'classification': 'emulated PTYwire; not actual host acknowledgement'})
            for number in (1, 2):
                if number == 2 and not (child / 'closed-1').exists(): continue
                if seen[25] < number + 1: continue
                if steps[number] == 0:
                    if read(child / f'probe-{number}') == expected:
                        if number == 1: cap.send(b'o'); steps[number] = 1
                        else: cap.send(b's'); steps[number] = 2
                    elif time.monotonic() - last_r > .03:
                        cap.send(b'r'); last_r = time.monotonic()
                elif steps[number] == 1 and b'LAYER1' in cap.raw:
                    cap.send(b's'); steps[number] = 2
                elif steps[number] == 2 and read(child / f'state-{number}') == expected:
                    cap.send(b'q'); steps[number] = 3
        finalized = True
        metadata = cap.finish(send_quit=False); restored(metadata)
        assert not metadata['timed_out'] and steps == {1: 3, 2: 3}, 'both real child sessions exercised'
        assert seen == {25: 4, 2004: 2}, 'baseline/application1/application2/final probes actually transported'
        assert read(child / 'direct.exit').strip() == '0', 'direct application succeeded before host oracle'
        assert read(child / 'outer-termios-before') == read(child / 'outer-termios-after'), 'script outer endpoint equality'
        if negative:
            assert metadata['exit'] == 1 and not (child / 'host-check.json').exists(), 'wrong child post-state must fail host runner'
            assert b'same child exact termios restored after each close' in cap.raw, 'failure comes from same-child restoration oracle'
            before = json.loads((child / 'native-termios-before-1.json').read_text())
            after = json.loads((child / 'native-termios-after-1.json').read_text())
            assert before['endpoint'] == after['endpoint'] and before['fields'] != after['fields'], 'actual wrong same-child state retained'
        else:
            assert metadata['exit'] == 0 and json.loads((child / 'host-check.json').read_text())['passed']
            verify_termios_snapshots(child)
        (output / 'transport-check.json').write_text(json.dumps({'passed': True, 'expectedNegative': negative,
            'runnerExit': metadata['exit'], 'directApplicationExit': 0, 'cursor': cursor, 'declaredTitleStress': declared,
            'binarySha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
            'transport': 'actual kernel outer+application PTYs; emulated mode replies, zero actual host runs',
            'responses': responses}, indent=2) + '\n')
    finally:
        if not finalized: cap.finish(send_quit=False)


if __name__ == '__main__':
    p = argparse.ArgumentParser(); p.add_argument('--binary', type=pathlib.Path, required=True)
    p.add_argument('--output', type=pathlib.Path, required=True); a = p.parse_args()
    assert os.environ.get('CJTUI_020_ROOT_GO') == '1' and pathlib.Path(os.environ['CJTUI_020_ADMISSION']).is_file()
    for cursor in ['visible', 'hidden', 'unknown']:
        run(a.binary.resolve(), a.output.resolve() / ('auto-' + cursor), cursor)
    run(a.binary.resolve(), a.output.resolve() / 'declared-hidden', 'hidden', declared=True)
    run(a.binary.resolve(), a.output.resolve() / 'negative-child-drift', 'visible', negative=True)
