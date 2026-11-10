"""Real PTY harness. Observes literal bytes; does not decode terminal input."""
from __future__ import annotations
import errno, fcntl, json, os, pathlib, pty, select, signal, struct, subprocess, termios, time
QUERY = b"\x1b[?25$p"
FORBIDDEN_UNKNOWN = (b"\x1b[?25h",b"\x1b[?25l",b"\x1b[?25s",b"\x1b[?25r")

class Capture:
    def __init__(self, command, directory, env=None):
        self.directory=pathlib.Path(directory); self.directory.mkdir(parents=True,exist_ok=True)
        self.master,self.slave=pty.openpty()
        fcntl.ioctl(self.slave,termios.TIOCSWINSZ,struct.pack("HHHH",4,12,0,0))
        self.before=termios.tcgetattr(self.slave); self.raw=bytearray(); self.sent=[]; self.started=time.monotonic()
        child_env=os.environ.copy(); child_env.update(env or {})
        child_env["CJTUI_INTERACTION_A_DEVICE"]=str(self.directory)
        self.process=subprocess.Popen(command,stdin=self.slave,stdout=self.slave,stderr=self.slave,env=child_env,start_new_session=True)
    def drain(self, seconds=0.05):
        until=time.monotonic()+seconds
        while time.monotonic()<until:
            ready,_,_=select.select([self.master],[],[],max(0,until-time.monotonic()))
            if not ready: break
            try:
                data=os.read(self.master,65536)
            except OSError as e:
                if e.errno==errno.EIO: break
                raise
            if not data: break
            self.raw.extend(data)
    def wait_bytes(self,value,timeout=3):
        until=time.monotonic()+timeout
        while value not in self.raw and time.monotonic()<until:
            self.drain(0.02)
            if self.process.poll() is not None: break
        if value not in self.raw: raise AssertionError(f"missing literal wire bytes {value!r}")
    def send(self,data):
        self.sent.append({"elapsed_ns":time.monotonic_ns(),"hex":data.hex()}); os.write(self.master,data)
    def state(self,predicate=lambda s:True,timeout=3):
        until=time.monotonic()+timeout
        while time.monotonic()<until:
            self.drain(0.01)
            p=self.directory/"state"
            if p.exists():
                value=p.read_text()
                if predicate(value): return value
        raise AssertionError("missing expected public state snapshot")
    def finish(self,send_quit=True):
        if send_quit and self.process.poll() is None: self.send(b"q")
        until=time.monotonic()+3
        while self.process.poll() is None and time.monotonic()<until: self.drain(0.02)
        timed_out=self.process.poll() is None
        if timed_out: os.killpg(self.process.pid,signal.SIGKILL)
        result=self.process.wait(); self.drain(0.05); self.after=termios.tcgetattr(self.slave)
        (self.directory/"wire.bin").write_bytes(self.raw)
        metadata={"command":self.process.args,"exit":result,"timed_out":timed_out,"size":[12,4],"before":self.before,"after":self.after,"inputs":self.sent}
        (self.directory/"capture.json").write_text(json.dumps(metadata,indent=2,default=lambda value:{"hex":value.hex()}))
        os.close(self.master); os.close(self.slave)
        if timed_out: raise AssertionError("child timed out")
        return metadata

def unknown_wire(raw):
    if raw.count(QUERY)!=1: raise AssertionError("query must be exactly once, exactly seven bytes")
    for forbidden in FORBIDDEN_UNKNOWN:
        if forbidden in raw: raise AssertionError(f"Unknown emitted forbidden visibility bytes {forbidden!r}")

def restored(metadata):
    if metadata["before"]!=metadata["after"]: raise AssertionError("termios not restored")
