#!/usr/bin/env python3
"""Real Linux PTY exercise of Application.run; no emulator or product stand-in."""
import argparse
import errno
import fcntl
import hashlib
import json
import os
import re
import select
import signal
import struct
import subprocess
import termios
import time
from pathlib import Path


def assert_unanswered_probe_modes(raw, sent):
    """Wire oracle for this no-reply fixture only; not a Known-mode matrix."""
    query = b"\x1b[?25$p"
    assert raw.count(query) == 1, "one exact mode25 DECRQM request"
    requests = re.findall(rb"\x1b\[\?([0-9;]+)\$p", raw)
    assert sum(25 in [int(p or b"0") for p in params.split(b";")] for params in requests) == 1, "no repeated mode25 query"
    assert not re.search(rb"\x1b\[\?25;[0-4]\$y", sent), "fixture must not send a valid mode25 protocol report"
    controls = re.findall(rb"\x1b\[\?([0-9;]*)([hlsr])", raw)

    def count(mode, action):
        return sum(mode in [int(p or b"0") for p in params.split(b";")] and final == action
                   for params, final in controls)

    for action in [b"h", b"l", b"s", b"r"]:
        assert count(25, action) == 0, "unanswered probe: no mode25 change/save/restore"
    for action in [b"h", b"l"]:
        assert count(1049, action) == 0, "fixture never enters or exits alternate screen"
    enable, disable = b"\x1b[?2004h", b"\x1b[?2004l"
    assert raw.count(enable) == 1 and raw.count(disable) == 1, "paste mode paired cleanup"
    assert count(2004, b"h") == 1 and count(2004, b"l") == 1, "no extra combined paste mode transitions"
    assert raw.index(enable) < raw.index(disable), "paste mode enable precedes cleanup"
    return dict(query_count=1, valid_input_reports=0, mode25_hlsr=[0, 0, 0, 0],
                alternate1049_hl=[0, 0], paste2004_hl=[1, 1], reply_fixture="unanswered; Pending/Unknown wire policy")


def run(binary, output, mode):
    directory = output / mode
    directory.mkdir(parents=True, exist_ok=False)
    master, slave = os.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 6, 40, 0, 0))
    before = termios.tcgetattr(slave)
    raw, sent, events = bytearray(), bytearray(), []
    env = dict(os.environ, TERM="xterm-256color", COLORTERM="", CJTUI_COMPOSITE_OUTPUT=str(directory), CJTUI_COMPOSITE_MODE=mode)
    metadata = dict(mode=mode, binary=str(binary), binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),
                    cwd=str(Path.cwd()), before_termios=before, events=events, route="real PTY; direct product binary")

    def terminal():
        os.setsid()
        fcntl.ioctl(slave, termios.TIOCSCTTY, 0)

    with (directory / "stderr.raw").open("wb") as err:
        child = subprocess.Popen([str(binary)], stdin=slave, stdout=slave, stderr=err, env=env, preexec_fn=terminal)

    def pump():
        if select.select([master], [], [], .02)[0]:
            try:
                raw.extend(os.read(master, 65536))
            except OSError as error:
                if error.errno != errno.EIO:
                    raise

    def await_condition(test, label, may_exit=False):
        deadline = time.monotonic() + 15
        while time.monotonic() < deadline:
            pump()
            if test():
                events.append(dict(observed=label, monotonic_ns=time.monotonic_ns()))
                return
            if child.poll() is not None and not may_exit:
                raise AssertionError("product exited before " + label)
        raise AssertionError("watchdog: " + label)

    def text(name):
        path = directory / name
        return path.read_text() if path.exists() else ""

    def send(data):
        sent.extend(data)
        events.append(dict(input_hex=data.hex(), monotonic_ns=time.monotonic_ns()))
        view = memoryview(data)
        while view:
            view = view[os.write(master, view):]

    focus_expected = []
    escape_expected = [0]

    def fence(want):
        focus_expected.append(want)
        send(b"#")
        expected = ";".join(focus_expected) + ";"
        await_condition(lambda: text("focus") == expected, "public focus trace " + expected)

    def escape():
        escape_expected[0] += 1
        expected = str(escape_expected[0])
        send(b"\x1b")
        await_condition(lambda: text("escape_seen") == expected, "standalone Escape decoded")

    try:
        await_condition(lambda: b"M_WIDGETS_READY" in raw and b"\x1b[" in raw, "actual native first frame")
        if mode == "callback-failure":
            send(b"\r")
        elif mode == "getter-failure":
            send(b"g")
        else:
            fence("a")
            for key, want in [(b"\x1b[C", "c"), (b"\x1b[C", "a"), (b"\x1b[F", "c"),
                              (b"\x1b[H", "a"), (b"\x1b[D", "c"), (b"\x1b[H", "a")]:
                send(key)
                fence(want)
            send(b"\r ")
            await_condition(lambda: text("chosen") == "h:a;h:a;", "Enter and Space each choose once")
            send(b"\x1b ")  # accepted Alt+Space, not ASCII Space
            send(b"\x1b[200~ \x1b[201~")  # atomic bracketed paste
            fence("a")
            assert text("chosen") == "h:a;h:a;", "modified/paste activation excluded"
            send(b"\t")
            fence("c")
            send(b"o")
            fence("p")
            send(b"\x1b[B")
            fence("r")
            send(b"\x1b[A")
            fence("p")
            send(b"\x1b[F")
            fence("r")
            send(b"\r")
            fence("r")
            assert text("chosen") == "h:a;h:a;p:r;" and text("open") == "true", "choose leaves actual layer open"
            escape()
            fence("c")
            assert text("open") == "false" and text("reason") == "Escape"
            send(b"o")
            fence("p")
            send(b"n")
            fence("n")
            escape()
            fence("p")
            assert text("open") == "true", "nested Escape keeps parent"
            escape()
            fence("c")
            send(b"u")
            send(b"o")
            fence("p")
            send(b"c")
            fence("c")
            assert text("reason") == "Requested"
            send(b"e")
            fence("p")
            send(b"\r")
            fence("c")
            assert text("open") == "false" and text("reason") == "Requested", "business onChoose explicitly closes"
            send(b"q")
        await_condition(lambda: child.poll() is not None, "direct product exit", may_exit=True)
        pump()
        after = termios.tcgetattr(slave)
        metadata.update(exit=child.returncode, after_termios=after, focus_trace=focus_expected)
        assert after == before, "exact termios restoration"
        summary = dict(line.split("=", 1) for line in text("summary").splitlines())
        metadata["summary"] = summary
        assert child.returncode == {"normal": 0, "callback-failure": 21, "getter-failure": 22}[mode]
        assert summary["resources"] == "0/0/0/0" and summary["cleanups"] == "1"
        if mode == "normal":
            assert summary == dict(calls="4", chosen="h:a;h:a;p:r;p:p;", model="NEW", cleanups="1", resources="0/0/0/0")
            assert not text("error")
        else:
            assert {"callback-failure": "M_NATIVE_CALLBACK_SENTINEL", "getter-failure": "M_NATIVE_GETTER_SENTINEL"}[mode] in text("error")
        metadata["mode_oracle"] = assert_unanswered_probe_modes(bytes(raw), bytes(sent))
        metadata["result"] = "PASS"
    except BaseException as error:
        metadata.update(result="FAIL", error=repr(error))
        raise
    finally:
        if child.poll() is None:
            os.killpg(child.pid, signal.SIGKILL)
            child.wait()
        metadata["exit"] = child.returncode
        (directory / "stdout.raw").write_bytes(raw)
        (directory / "stdin.raw").write_bytes(sent)
        (directory / "metadata.json").write_text(json.dumps(metadata, indent=2, default=lambda value: list(value) if isinstance(value, bytes) else str(value)) + "\n")
        os.close(master)
        os.close(slave)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    for mode in ["normal", "callback-failure", "getter-failure"]:
        run(args.binary.resolve(), args.output.resolve(), mode)
    print("TASK158_REAL_PTY_PASS normal/callback-failure/getter-failure")


if __name__ == "__main__":
    main()
