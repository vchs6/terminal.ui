#!/usr/bin/env python3
"""Independent bounded CLI regressions. No builds, product imports or private hooks."""
import argparse
import csv
import errno
import fcntl
import gzip
import hashlib
import io
import json
import os
from pathlib import Path
import pty
import re
import select
import shutil
import signal
import struct
import subprocess
import termios
import time

STOP_FREE = 12 * 1024 * 1024
MAX_WIRE = 1024 * 1024
CUP = re.compile(rb"\x1b\[(\d+);(\d+)H")
CSI = re.compile(rb"\x1b\[[0-?]*[ -/]*[@-~]")
QUERY = b"\x1b[?25$p"
REPLY = b"\x1b[?25;1$y"


def sha(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(65536), b""):
            digest.update(block)
    return digest.hexdigest()


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n")


def terminal_attributes(descriptor):
    values = termios.tcgetattr(descriptor)
    return values[:6] + [[item.hex() if isinstance(item, bytes) else item for item in values[6]]]


def capacity():
    free = shutil.disk_usage("/workspace").free
    if free < STOP_FREE + MAX_WIRE:
        raise RuntimeError(f"capacity hard stop: free={free}; reserve={STOP_FREE}")
    return free


def record(checks, name, passed, **facts):
    checks.append({"name": name, "status": "PASS" if passed else "RED", **facts})


def command(binary, mode, scenario, run_id, output, updates):
    return [str(binary), "--mode", mode, "--scenario", scenario, "--width", "80",
            "--height", "24", "--seed", "143", "--warmup", "0", "--updates", str(updates),
            "--repetition", "0", "--run-id", run_id, "--csv", str(output)]


def execute(argv, directory, label, commands):
    capacity()
    with open(directory / f"{label}.stdout", "wb") as stdout, open(directory / f"{label}.stderr", "wb") as stderr:
        result = subprocess.run(argv, stdout=stdout, stderr=stderr, timeout=20, check=False)
    commands.append({"label": label, "argv": argv, "exit": result.returncode})
    if result.returncode:
        raise RuntimeError(f"normal CLI failed ({result.returncode}): {label}")


def row_payloads(data, row):
    matches = list(CUP.finditer(data))
    result = []
    for index, match in enumerate(matches):
        if int(match[1]) != row:
            continue
        end = matches[index + 1].start() if index + 1 < len(matches) else len(data)
        payload = CSI.sub(b"", data[match.end():end])
        if payload:
            result.append((int(match[2]), payload))
    return result


def glyph_terminal(binary, output, checks, commands):
    """A synthetic PTY with actual ioctl dimensions, never real-host evidence."""
    directory = output / "glyph"
    directory.mkdir()
    csv_path = directory / "samples.csv"
    argv = command(binary, "tty", "glyph_projection", "independent-145-glyph-w0", csv_path, 3)
    size = struct.pack("HHHH", 24, 80, 0, 0)
    capacity()
    pid, master = pty.fork()
    if pid == 0:
        try:
            fcntl.ioctl(0, termios.TIOCSWINSZ, size)
            geometry = struct.unpack("HHHH", fcntl.ioctl(0, termios.TIOCGWINSZ, bytes(8)))
            write_json(directory / "child-terminal.json", {"pid": os.getpid(), "stdin_tty": os.ttyname(0),
                       "rows": geometry[0], "columns": geometry[1], "before_termios": terminal_attributes(0)})
            error = os.open(directory / "stderr.log", os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
            os.dup2(error, 2)
            os.close(error)
            environment = dict(os.environ, TERM="xterm-256color", COLORTERM="", LC_ALL="C.UTF-8")
            os.execvpe(argv[0], argv, environment)
        finally:
            os._exit(127)
    os.set_blocking(master, False)
    fcntl.ioctl(master, termios.TIOCSWINSZ, size)
    actual = struct.unpack("HHHH", fcntl.ioctl(master, termios.TIOCGWINSZ, bytes(8)))
    wire = bytearray()
    events = []
    phases = []
    replied = False
    child_status = None

    def send(data, reason):
        os.write(master, data)
        events.append({"event": "input", "reason": reason, "hex": data.hex(), "wire_offset": len(wire)})

    def read_once(wait=0.02):
        nonlocal replied
        if select.select([master], [], [], wait)[0]:
            try:
                block = os.read(master, 65536)
            except OSError as error:
                if error.errno == errno.EIO:
                    return False
                raise
            if block:
                wire.extend(block)
                if len(wire) > MAX_WIRE:
                    raise RuntimeError("bounded wire capture exceeded 1 MiB")
                if not replied and QUERY in wire:
                    send(REPLY, "reply to actual DECRQM cursor query")
                    replied = True
                return True
        return False

    def until(predicate, label):
        deadline = time.monotonic() + 8
        while time.monotonic() < deadline:
            read_once()
            if predicate():
                events.append({"event": "observed", "label": label, "wire_offset": len(wire)})
                return
            finished, status = os.waitpid(pid, os.WNOHANG)
            if finished:
                raise RuntimeError(f"child exited before {label}: wait_status={status}")
        raise RuntimeError(f"transport/protocol watchdog: {label}")

    def ack(value):
        def received():
            try:
                return Path(str(csv_path) + ".ack").read_text().strip() == value
            except (FileNotFoundError, UnicodeDecodeError):
                return False
        until(received, f"ack {value}")

    def drain():
        while read_once(0):
            pass

    try:
        if actual[:2] != (24, 80):
            raise RuntimeError(f"wrong actual PTY geometry {actual}")
        # Positive target boundary: the second row CUP completes the first row.
        # No r/w/action key has been sent; only a response to an actual query.
        until(lambda: b"\x1b[2;1H" in wire, "initial first row complete before business keys")
        drain()
        initial = bytes(wire)
        initial_rows = row_payloads(initial, 1)
        expected = b"??" + b" " * 78
        record(checks, "F14502.initial_ascii_before_warmup_or_mutation",
               bool(initial_rows) and initial_rows[0] == (1, expected),
               expected_hex=expected.hex(), actual_first_row_hex=initial_rows[0][1].hex() if initial_rows else None)
        phases.append({"phase": "initial", "start": 0, "end": len(wire), "business_keys_sent": 0})
        start = len(wire)
        send(b"r", "setup"); ack("setup")
        send(b"r", "ready after prior normal render"); ack("ready")
        send(b"b", "begin with warmup0"); ack("begin")
        drain()
        phases.append({"phase": "setup-ready-begin", "start": start, "end": len(wire)})
        for action in range(1, 4):
            start = len(wire)
            send(b"a", f"business action {action}")
            send(b"f", f"fence after action {action} normal render")
            ack(f"fence:{action}")
            marker = b":" if action % 2 else b"."
            until(lambda: any(col == 1 and payload == b" " * 79 + marker
                              for col, payload in row_payloads(bytes(wire[start:]), 24)),
                  f"complete fence row {action}")
            send(b"k", f"acknowledge fence {action} normal render"); ack(f"presented:{action}")
            drain()
            phase = bytes(wire[start:])
            updates = row_payloads(phase, 1)
            record(checks, f"F14502.same_ascii_business_row_action_{action}", not updates,
                   expected="no first-row grid output; all logical values project to two question columns",
                   actual_first_row_updates=[{"column": col, "payload_hex": payload.hex()} for col, payload in updates])
            phases.append({"phase": f"action-fence-presented-{action}", "start": start, "end": len(wire),
                           "fence_row": 24, "business_row": 1})
        start = len(wire)
        send(b"e", "end and normal stop"); ack("end")
        deadline = time.monotonic() + 8
        while time.monotonic() < deadline:
            read_once()
            finished, status = os.waitpid(pid, os.WNOHANG)
            if finished:
                child_status = os.waitstatus_to_exitcode(status)
                break
        if child_status is None:
            raise RuntimeError("normal exit watchdog")
        drain()
        phases.append({"phase": "end-exit", "start": start, "end": len(wire)})
        if child_status:
            raise RuntimeError(f"normal CLI exited {child_status}")
        with open(csv_path, newline="") as stream:
            samples = list(csv.DictReader(stream))
        if len(samples) != 1 or samples[0]["glyph_mode"] != "Ascii":
            raise RuntimeError("missing ordinary Ascii-labeled sample")
        child_terminal = json.loads((directory / "child-terminal.json").read_text())
        record(checks, "synthetic_pty_normal_exit_and_mode_restore", terminal_attributes(master) == child_terminal["before_termios"],
               exit=child_status, actual_rows=actual[0], actual_columns=actual[1], query_replied=replied)
        commands.append({"label": "glyph-tty", "argv": argv, "exit": child_status,
                         "environment": {"TERM": "xterm-256color", "COLORTERM": "", "LC_ALL": "C.UTF-8"},
                         "facility": "synthetic PTY; actual ioctl80x24; no real-host or output-cost claim"})
    finally:
        if child_status is None:
            try:
                os.killpg(pid, signal.SIGKILL)
                os.waitpid(pid, 0)
            except ProcessLookupError:
                pass
        os.close(master)
        data = bytes(wire)
        with gzip.open(directory / "wire.raw.gz", "wb") as stream:
            stream.write(data)
        write_json(directory / "events.json", events)
        write_json(directory / "phases.json", phases)
        write_json(directory / "wire-binding.json", {"sha256_uncompressed": hashlib.sha256(data).hexdigest(),
                   "bytes_uncompressed": len(data), "compression": "lossless gzip", "not_native_write_calls": True})


def flex_cli(binary, output, checks, commands):
    directory = output / "flex"
    directory.mkdir()
    sample = directory / "timing.csv"
    execute(command(binary, "snapshot-headless", "row_flex_width", "independent-145-flex-dependencies", sample, 2),
            directory, "timing", commands)
    with open(sample, newline="") as stream:
        rows = list(csv.DictReader(stream))
    if len(rows) != 1:
        raise RuntimeError("expected one ordinary dependency observation row")
    actual = rows[0]
    # One changing first-width input; optional first-leaf text and color getters
    # add at most two subscriptions. Seven unchanged weighted siblings add none.
    for field in ("subscriptions_before", "subscriptions_after", "active_bindings_before", "active_bindings_after"):
        value = int(actual[field])
        record(checks, f"F14501.{field}", 1 <= value <= 3, actual=value,
               expected="1 first-width binding plus at most text/color; no sibling firstWidth subscriptions")
    record(checks, "F14501.direct_dirty_leaf_facts", int(actual["dirty_leaves"]) == 1,
           actual=int(actual["dirty_leaves"]), expected=1)
    cells = directory / "cells.csv"
    carets = directory / "caret.csv"
    argv = command(binary, "correctness", "row_flex_width", "independent-145-flex-geometry", directory / "correctness.csv", 2)
    argv += ["--cells-csv", str(cells), "--caret-csv", str(carets)]
    execute(argv, directory, "correctness", commands)
    mixed = [("41", "1", "false"), ("e4b8ad", "2", "false"), ("", "0", "true"),
             ("65cc81", "1", "false"), ("f09f91a9e2808df09f92bb", "2", "false"),
             ("", "0", "true"), ("f09f87a8f09f87b3", "2", "false"), ("", "0", "true")]
    widths = [(10, 10, 10, 10, 10, 10, 10, 10), (20, 9, 9, 9, 9, 8, 8, 8), (10, 10, 10, 10, 10, 10, 10, 10)]
    expected = []
    for allocation in widths:
        row = []
        for width in allocation:
            row.extend(mixed + [("20", "1", "false")] * (width - 8))
        expected.append(row)
    actual_rows = {}
    with open(cells, newline="") as stream:
        for cell in csv.DictReader(stream):
            if cell["path"] != "snapshot" or cell["y"] != "0":
                continue
            key = (int(cell["epoch"]), int(cell["x"]))
            if key in actual_rows:
                raise RuntimeError("duplicate first-row Cell")
            actual_rows[key] = cell
    mismatch = None
    for epoch, row in enumerate(expected):
        for x, want in enumerate(row):
            cell = actual_rows.get((epoch, x))
            got = tuple(cell[name] for name in ("grapheme_utf8_hex", "cell_width", "continuation")) if cell else None
            if got != want:
                mismatch = {"epoch": epoch, "x": x, "expected": want, "actual": got}
                break
        if mismatch:
            break
    record(checks, "F14501.manual_equal_weight_geometry", mismatch is None and len(actual_rows) == 240,
           expected_widths=widths, first_mismatch=mismatch,
           coverage="geometry alone does not distinguish explicit arithmetic from framework flex")
    for path in (cells, carets):
        with open(path, "rb") as source, gzip.open(str(path) + ".gz", "wb") as target:
            shutil.copyfileobj(source, target, 65536)
        path.unlink()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compat", type=Path, required=True)
    parser.add_argument("--compat-sha256", required=True)
    parser.add_argument("--diagnostic", type=Path, required=True)
    parser.add_argument("--diagnostic-sha256", required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    checks, commands = [], []
    start_free = capacity()
    try:
        for path, expected in ((args.compat, args.compat_sha256), (args.diagnostic, args.diagnostic_sha256)):
            if sha(path) != expected:
                raise RuntimeError(f"fixed ELF hash mismatch: {path}")
        glyph_terminal(args.compat.resolve(), args.out, checks, commands)
        flex_cli(args.compat.resolve(), args.out, checks, commands)
        status = 1 if any(check["status"] == "RED" for check in checks) else 0
        error = None
    except Exception as failure:
        status, error = 2, f"{type(failure).__name__}: {failure}"
    write_json(args.out / "commands.json", commands)
    write_json(args.out / "result.json", {"exit": status, "checks": checks, "harness_error": error,
               "start_free_bytes": start_free, "end_free_bytes": shutil.disk_usage("/workspace").free,
               "compat_sha256": sha(args.compat), "diagnostic_sha256": sha(args.diagnostic),
               "scope": "bounded80x24 normal CLI counterexamples only; no compile or performance evidence"})
    print(json.dumps({"exit": status, "red": [check["name"] for check in checks if check["status"] == "RED"],
                      "harness_error": error}))
    return status


if __name__ == "__main__":
    raise SystemExit(main())
