#!/usr/bin/env python3
"""Check the PTY capture tool only; this child is not a product fixture."""
import os
import select
import subprocess
import sys
import termios
import time

CHILD = r'''
import os, sys, termios, tty
fd = sys.stdin.fileno()
before = termios.tcgetattr(fd)
try:
    tty.setraw(fd)
    os.write(1, b"READY\x1b[?1049h\x1b[?25l")
    data = os.read(fd, 64)
    os.write(1, b"KEY:" + data.hex().encode())
finally:
    os.write(1, b"\x1b[?25h\x1b[?1049l")
    termios.tcsetattr(fd, termios.TCSADRAIN, before)
'''


def collect(master, wanted, timeout=5):
    data = bytearray()
    deadline = time.monotonic() + timeout
    while wanted not in data:
        remaining = deadline - time.monotonic()
        if remaining <= 0 or not select.select([master], [], [], remaining)[0]:
            raise AssertionError(f"PTY timeout waiting for {wanted!r}; got {bytes(data)!r}")
        try:
            chunk = os.read(master, 4096)
        except OSError:
            break
        if not chunk:
            break
        data.extend(chunk)
    return bytes(data)


def main():
    master, slave = os.openpty()
    original = termios.tcgetattr(slave)
    try:
        child = subprocess.Popen([sys.executable, "-c", CHILD], stdin=slave, stdout=slave, stderr=slave)
        first = collect(master, b"READY")
        raw_key = b"\x1b[A \r\x1b"
        os.write(master, raw_key)
        second = collect(master, b"\x1b[?1049l")
        status = child.wait(timeout=5)
        observed = first + second
        assert status == 0, status
        assert b"KEY:" + raw_key.hex().encode() in observed, observed
        assert observed.index(b"\x1b[?1049h") < observed.index(b"\x1b[?1049l")
        assert observed.index(b"\x1b[?25l") < observed.index(b"\x1b[?25h")
        assert termios.tcgetattr(slave) == original, "termios restore"
        print(f"PTY_TOOL_SELF_TEST_OK bytes={len(observed)} input={raw_key.hex()} exit={status}")
    finally:
        os.close(master)
        os.close(slave)


if __name__ == "__main__":
    main()
