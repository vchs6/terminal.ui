#!/usr/bin/env python3
"""Public Application.run regression through the normal benchmark CLI and a PTY."""
import argparse
import array
import ast
import csv
from decimal import Decimal
import errno
import fcntl
import gzip
import hashlib
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
import uuid

QUERY = b"\x1b[?25$p"
REPORT = b"\x1b[?25;1$y"
PROTOCOL_ERROR = b"benchmark: invalid terminal protocol key or phase"
TRACE = "read,ioctl,write,writev,poll,clone,clone3,execve,execveat,exit,exit_group"
FLAGS = ["-ff", "-ttt", "-yy", "-v", "-e", "abbrev=execve,execveat",
         "-s", "128", "-e", "trace=" + TRACE]
MAX_CAPTURE = 4 * 1024 * 1024


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def size(fd):
    rows, cols, _, _ = struct.unpack("HHHH", fcntl.ioctl(fd, termios.TIOCGWINSZ, b"\0" * 8))
    return [cols, rows]


def resize(fd, cols, rows):
    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols, 0, 0))


def attributes(fd):
    values = termios.tcgetattr(fd)
    values[-1] = [item.hex() if isinstance(item, bytes) else item for item in values[-1]]
    return values


def input_bytes(records):
    result = bytearray()
    for record in records:
        match = re.search(r'read\(0<.*?>, ("(?:\\.|[^"\\])*")?, \d+\) = (\d+)$', record["body"])
        if match and match[1]:
            value = ast.literal_eval(match[1]).encode("latin1")
            if len(value) == int(match[2]):
                result.extend(value)
    return bytes(result)


class Device:
    def __init__(self, args):
        self.args, self.out = args, args.out.resolve()
        self.out.mkdir(parents=True, exist_ok=False)
        self.master, self.slave = pty.openpty()
        resize(self.slave, 126 if args.case == "queued" else 160, 40 if args.case == "queued" else 48)
        self.raw, self.events, self.native = bytearray(), [], []
        self.replied = self.resized = self.queue_proved = False
        self.before = attributes(self.slave)
        self.child = None
        self.meta = dict(case=args.case, binary=str(args.binary), binary_sha256=sha(args.binary),
                         fixture_sha256=sha(Path(__file__)), tty=os.ttyname(self.slave),
                         tty_device=os.fstat(self.slave).st_rdev, before_termios=self.before)

    def event(self, kind, **fields):
        self.events.append(dict(kind=kind, utc_ns=time.time_ns(), monotonic_ns=time.monotonic_ns(),
                                size=size(self.slave), raw_bytes=len(self.raw), **fields))

    def records(self):
        result = []
        for path in sorted(self.out.glob("native.[0-9]*")):
            for ordinal, line in enumerate(path.read_text(errors="replace").splitlines(), 1):
                stamp, _, body = line.partition(" ")
                if re.fullmatch(r"\d+\.\d+", stamp):
                    result.append(dict(time_us=int(Decimal(stamp) * 1000000),
                                       stream=path.name, ordinal=ordinal, body=body))
        return sorted(result, key=lambda item: (item["time_us"], item["stream"], item["ordinal"]))

    def send(self, data, kind="protocol_key"):
        count = os.write(self.master, data)
        if count != len(data):
            raise RuntimeError("short test input write")
        self.event(kind, input_hex=data.hex(), actual_written=count)

    def pump(self):
        if select.select([self.master], [], [], .003)[0]:
            try:
                self.raw.extend(os.read(self.master, 65536))
            except OSError as error:
                if error.errno != errno.EIO:
                    raise
        if len(self.raw) + sum(p.stat().st_size for p in self.out.glob("native.[0-9]*")) > MAX_CAPTURE:
            raise RuntimeError("bounded capture reserve exceeded")
        if QUERY in self.raw and not self.replied:
            self.send(REPORT, "atomic_cursor_report")
            self.replied = True
        if self.replied and not self.queue_proved:
            queued = array.array("i", [0])
            fcntl.ioctl(self.slave, termios.FIONREAD, queued, True)
            if queued[0] >= len(REPORT):
                self.event("queued_report", available_bytes=queued[0], readable=bool(select.select([self.slave], [], [], 0)[0]))
                self.queue_proved = True
        if self.args.case == "queued" and self.replied and not self.resized:
            records = self.records()
            query = next((i for i, r in enumerate(records) if 'write(1<' in r["body"] and '?25$p' in r["body"]), None)
            if query is not None and any('TIOCGWINSZ, {ws_row=40, ws_col=126,' in r["body"] for r in records[query + 1:]):
                self.event("resize_before", initial_snapshot_observed=True)
                resize(self.slave, 160, 48)
                self.event("resize_after")
                self.resized = True

    def wait(self, predicate, label, seconds=12):
        deadline = time.monotonic() + seconds
        while time.monotonic() < deadline:
            self.pump()
            if predicate():
                return
            if self.child.poll() is not None:
                self.pump()
                raise ChildProcessError("product exited before " + label)
        raise TimeoutError(label)

    def ack(self, value):
        path = self.out / "samples.csv.ack"
        self.wait(lambda: path.exists() and path.read_text().strip() == value, "ack " + value)
        self.event("ack", value=value)

    def key(self, value, ack):
        self.send(value.encode())
        self.ack(ack)

    def settle(self):
        deadline = time.monotonic() + .15
        while time.monotonic() < deadline:
            self.pump()

    def launch(self):
        argv = [str(self.args.binary), "--mode", "tty", "--scenario", "vertical_panels",
                "--width", "160", "--height", "48", "--seed", "143", "--warmup", "2",
                "--updates", "2", "--repetition", "0", "--run-id", "queued-" + uuid.uuid4().hex,
                "--csv", str(self.out / "samples.csv")]
        command = [str(self.args.strace)] + FLAGS + ["-o", str(self.out / "native")] + argv
        env = dict(os.environ, TERM="xterm-256color")
        env.pop("COLORTERM", None)
        self.meta.update(argv=argv, launch=command, initial_size=size(self.slave),
                         strace_sha256=sha(self.args.strace), strace_version=subprocess.check_output([str(self.args.strace), "-V"], text=True).splitlines()[0])
        def terminal():
            os.setsid()
            fcntl.ioctl(self.slave, termios.TIOCSCTTY, 0)
        self.child = subprocess.Popen(command, stdin=self.slave, stdout=self.slave, stderr=self.slave,
                                      env=env, preexec_fn=terminal)
        self.meta["tracer_pid"] = self.child.pid

    def exercise(self):
        self.wait(lambda: self.replied and b"\x1b[1;1H" in self.raw and
                  (self.args.case != "queued" or self.resized), "pending report and first target")
        if size(self.slave) != [160, 48]:
            raise RuntimeError("actual target size mismatch")
        self.key("r", "setup")
        self.key("r", "ready")
        if self.args.case == "idle-escape":
            self.send(b"\x1b", "bare_escape")
            self.wait(lambda: self.child.poll() is not None, "actual idle Escape dispatch")
            return
        for count in (1, 2):
            self.key("w", "warmup:" + str(count))
            self.key("r", "ready")
        self.key("b", "begin")
        for count in (1, 2):
            self.send(b"a")
            self.settle()
            self.key("f", "fence:" + str(count))
            self.settle()
            self.key("k", "presented:" + str(count))
        self.key("e", "end")
        self.wait(lambda: self.child.poll() is not None, "normal exit")

    def classify(self):
        records = self.records()
        self.native = records
        consumed = input_bytes(records)
        self.meta["actual_input_hex"] = consumed.hex()
        leaders = [r["stream"] for r in records if r["body"].startswith('execve("' + str(self.args.binary) + '",')]
        self.meta["product_leader_streams"] = leaders
        self.meta["native_exits"] = [r for r in records if re.fullmatch(r'\+\+\+ exited with \d+ \+\+\+', r["body"])]
        if self.meta.get("forced_cleanup"):
            return 2, "INFRASTRUCTURE_FAILURE"
        if self.args.case == "queued":
            pressure = []
            for i, record in enumerate(records):
                if 'TIOCGWINSZ, {ws_row=48, ws_col=160,' in record["body"]:
                    painted = next((r for r in records[i + 1:] if r["stream"] == record["stream"] and
                                    'write(1<' in r["body"] and r'\33[1;1H' in r["body"]), None)
                    if painted:
                        pressure.append(painted["time_us"] - record["time_us"])
            queued = any(e["kind"] == "queued_report" and e["available_bytes"] >= len(REPORT) and e["readable"] for e in self.events)
            available = queued or consumed.startswith(REPORT)
            original = any('TIOCGWINSZ, {ws_row=40, ws_col=126,' in r["body"] for r in records)
            self.meta["fixture"] = dict(whole_report_queued=queued, whole_report_already_consumed=consumed.startswith(REPORT), initial126_snapshot=original,
                                        resized=self.resized, target_render_intervals_us=pressure)
            if not (available and original and self.resized and pressure and max(pressure) >= 100000):
                return 77, "FIXTURE_NOT_EXERCISED"
            if self.child.returncode == 1 and PROTOCOL_ERROR in self.raw:
                return 1, "FAIL_CONTROL_SEQUENCE_REACHED_KEY_HANDLER"
            complete = self.child.returncode == 0 and (self.out / "samples.csv").is_file()
            if complete:
                with (self.out / "samples.csv").open(newline="") as stream:
                    sample = list(csv.DictReader(stream))
                expected = dict(run_id=self.meta["argv"][-3], mode="tty", scenario="vertical_panels", epoch_first="3", epoch_last="4")
                complete = len(sample) == 1 and all(sample[0].get(k) == v for k, v in expected.items()) and any(e["kind"] == "ack" and e.get("value") == "end" for e in self.events)
            return (0, "PASS_QUEUED_CONTROL_AND_NORMAL_COMPLETION") if complete else (2, "UNEXPECTED_PRODUCT_OR_PROTOCOL_FAILURE")
        sent = next((e["utc_ns"] // 1000 for e in self.events if e["kind"] == "bare_escape"), None)
        idle = sent is not None and any(r["time_us"] >= sent and 'poll(' in r["body"] and 'POLLIN' in r["body"] and re.search(r', [1-9]\d*\) = 0(?: \(Timeout\))?$', r["body"]) for r in records)
        self.meta["fixture"] = dict(actual_positive_timeout_poll_returned_idle=idle)
        if not idle:
            return 77, "FIXTURE_NOT_EXERCISED"
        expected = self.child.returncode == 1 and PROTOCOL_ERROR in self.raw and any(e["kind"] == "bare_escape" for e in self.events)
        return (0, "PASS_TRUE_IDLE_ESCAPE_REMAINS_OBSERVABLE") if expected else (1, "FAIL_TRUE_IDLE_ESCAPE_NOT_OBSERVABLE")

    def close(self):
        if self.child is not None and self.child.poll() is None:
            os.killpg(self.child.pid, signal.SIGKILL)
            self.child.wait()
            self.meta["forced_cleanup"] = True
        while select.select([self.master], [], [], 0)[0]:
            try:
                chunk = os.read(self.master, 65536)
                if not chunk:
                    break
                self.raw.extend(chunk)
            except OSError as error:
                if error.errno != errno.EIO:
                    raise
                break
        self.meta.update(actual_exit=self.child.returncode if self.child else None,
                         after_termios=attributes(self.slave), final_size=size(self.slave),
                         binary_post_sha256=sha(self.args.binary))
        self.meta["termios_restored"] = self.before == self.meta["after_termios"]
        os.close(self.master)
        os.close(self.slave)

    def retain(self):
        save(self.out / "events.json", self.events)
        save(self.out / "native-records.json", self.native)
        with gzip.open(self.out / "terminal.raw.gz", "wb") as stream:
            stream.write(self.raw)
        for path in self.out.glob("native.[0-9]*"):
            with gzip.open(str(path) + ".gz", "wb") as stream:
                stream.write(path.read_bytes())
            path.unlink()
        self.meta["files"] = {p.name: dict(bytes=p.stat().st_size, sha256=sha(p))
                              for p in self.out.iterdir() if p.is_file()}
        save(self.out / "result.json", self.meta)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", required=True, type=Path)
    parser.add_argument("--binary-sha256", required=True)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--case", choices=("queued", "idle-escape"), default="queued")
    parser.add_argument("--strace", type=Path, default=Path("/usr/bin/strace"))
    args = parser.parse_args()
    args.binary, args.strace = args.binary.resolve(), args.strace.resolve()
    if sha(args.binary) != args.binary_sha256:
        parser.error("normal binary SHA256 mismatch")
    if shutil.disk_usage(args.out.parent).free < 12 * 1024 * 1024 + MAX_CAPTURE:
        parser.error("insufficient capture reserve")
    device = Device(args)
    try:
        device.launch()
        device.exercise()
    except (ChildProcessError, TimeoutError, OSError, RuntimeError) as error:
        device.meta["observation"] = repr(error)
    finally:
        device.close()
    code, status = device.classify()
    if device.meta["binary_post_sha256"] != args.binary_sha256 or not device.meta["termios_restored"]:
        code, status = 2, "IDENTITY_OR_TERMINAL_RESTORATION_FAILURE"
    device.meta.update(test_exit=code, status=status)
    device.retain()
    print(status + ": " + str(device.out))
    return code


if __name__ == "__main__":
    raise SystemExit(main())
