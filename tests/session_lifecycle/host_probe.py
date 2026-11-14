"""Fixed actual-host DECRQM observations; no emulator or keyboard decoder.

Reads literal responses from /dev/tty. Never synthesizes a reply and restores
its own exact termios in finally. Missing/other responses remain Unknown.
"""
import json
import os
import pathlib
import select
import sys
import termios
import time
import tty


def probe(output):
    fd = os.open('/dev/tty', os.O_RDWR | os.O_NOCTTY)
    before = termios.tcgetattr(fd); observations = {}
    try:
        tty.setraw(fd, termios.TCSANOW)
        for mode in (25, 2004):
            query = f'\x1b[?{mode}$p'.encode(); os.write(fd, query)
            raw = bytearray(); deadline = time.monotonic() + .65
            while time.monotonic() < deadline:
                ready, _, _ = select.select([fd], [], [], max(0, deadline-time.monotonic()))
                if ready:
                    raw.extend(os.read(fd, 128))
                    if len(raw) > 128: break
            reply = bytes(raw)
            state = 'unknown'
            if reply == f'\x1b[?{mode};1$y'.encode(): state = 'set'
            elif reply == f'\x1b[?{mode};2$y'.encode(): state = 'reset'
            observations[str(mode)] = {'queryHex': query.hex(), 'responseHex': reply.hex(),
                'state': state, 'deadlineMs': 650, 'source': 'actual /dev/tty response; no injection'}
    finally:
        termios.tcsetattr(fd, termios.TCSANOW, before)
        after = termios.tcgetattr(fd); os.close(fd)
    assert before == after, 'host probe exact termios restore'
    pathlib.Path(output).write_text(json.dumps({'observations': observations,
        'before': before, 'after': after, 'utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())},
        indent=2, default=lambda value: {'hex': value.hex()}) + '\n')


if __name__ == '__main__': probe(sys.argv[1])
