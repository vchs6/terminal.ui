#!/usr/bin/env python3
"""Real Application.run vectors; no editor model or fake clipboard adapter.
Reuse the accepted keyboard test's OSpipe read/poll remap for precise prefix/EOF
receipts. termios, output and size remain an actual PTY. Python is a test driver.
"""
import argparse, base64, datetime, errno, fcntl, hashlib, json, os, pty, select, signal, struct, subprocess, termios, time
from pathlib import Path

MODES = ['paste', 'reject', 'focus', 'unmount', 'modal', 'eof', 'sent', 'cut-race']
START, END = b'\x1b[200~', b'\x1b[201~'

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def utc(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def attrs(fd):
    result = termios.tcgetattr(fd)
    result[-1] = [list(x) if isinstance(x, bytes) else x for x in result[-1]]
    return result

def run(binary, base, shim, mode):
    out = base / mode
    out.mkdir(parents=True, exist_ok=False)
    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 6, 40, 0, 0))
    before = attrs(slave)
    reader, writer = os.pipe()
    os.mkfifo(out / 'release.fifo'); os.mkfifo(out / 'ack.fifo')
    ack = os.open(out / 'ack.fifo', os.O_RDONLY | os.O_NONBLOCK)
    raw, sent, events = bytearray(), bytearray(), []
    closed = False
    env = dict(os.environ, TERM='xterm-256color', LD_PRELOAD=str(shim),
        CJTUI_KEYBOARD_PIPE_FD=str(reader), CJTUI_KEYBOARD_PIPE_TRACE=str(out/'native.trace'),
        CJTUI_EDITING_OUTPUT=str(out), CJTUI_EDITING_MODE=mode)
    def terminal():
        os.setsid(); fcntl.ioctl(slave, termios.TIOCSCTTY, 0)
    metadata = dict(mode=mode, utc_start=utc(), binary_sha256=sha(binary), shim_sha256=sha(shim),
        argv=[str(binary)], cwd=str(Path.cwd()), before_termios=before, events=events)
    with (out/'stderr').open('wb') as err:
        child = subprocess.Popen([str(binary)], stdin=slave, stdout=slave, stderr=err,
            pass_fds=(reader,), env=env, preexec_fn=terminal)
    def text(name):
        p = out/name
        return p.read_text() if p.is_file() else ''
    def pump(maximum=65536):
        if select.select([master], [], [], .01)[0]:
            try: raw.extend(os.read(master, maximum))
            except OSError as e:
                if e.errno != errno.EIO: raise
    def wait(predicate, label, maximum=65536):
        deadline = time.monotonic()+15
        while time.monotonic() < deadline:
            pump(maximum)
            if predicate(): return
            if child.poll() is not None: raise AssertionError('child exited before '+label)
        raise AssertionError('watchdog '+label)
    def write(data):
        sent.extend(data); events.append(dict(input_hex=data.hex(), monotonic_ns=time.monotonic_ns()))
        view = memoryview(data)
        while view: view = view[os.write(writer, view):]
    def idle():
        amount = len(sent)
        wait(lambda: any('poll ' in row and 'actual_result=0 ' in row and f'total={amount} ' in row
            for row in text('native.trace').splitlines()), 'actual poll after consumed prefix')
        events.append(dict(actual_consumed_prefix=amount, monotonic_ns=time.monotonic_ns()))
    def release(command):
        with (out/'release.fifo').open('wb', buffering=0) as gate: gate.write(command)
        events.append(dict(fifo_command=command.decode(), monotonic_ns=time.monotonic_ns()))
    try:
        wait(lambda: b'CJTUI_EDITING_READY' in raw, 'actual first frame'); idle()
        if mode == 'paste':
            for fragment in [START[:3], START[3:]+b'A\r', b'\n'+ '中'.encode()[:1], '中'.encode()[1:]+END]: write(fragment)
            wait(lambda: text('changed') == 'yes', 'actual paste transaction')
            write(b'u'); wait(lambda: bool(text('undone')), 'actual one-step undo/redo'); write(b'q')
        elif mode == 'reject':
            write(START+b'A\x1b[31m'+END)
            wait(lambda: text('editor-issue') == 'ControlCharacterRejected;', 'atomic bad paste rejection'); write(b'q')
        elif mode in ['focus', 'unmount', 'modal']:
            write(START+b'X'); idle(); release(b'mutate')
            wait(lambda: text('mutated') == mode, 'actual post mutation'); write(END)
            wait(lambda: text('changed') == 'yes' if mode == 'focus' else text('keyboard-issue') == 'PasteTargetUnavailable;', 'locked target outcome')
            write(b'q')
        elif mode == 'eof':
            write(START+b'tail'); os.close(writer); closed=True
            events.append(dict(actual_pipe_eof=True, monotonic_ns=time.monotonic_ns()))
        elif mode == 'sent': write(b'c')
        elif mode == 'cut-race':
            write(b'c')
            # Read exactly through the first OSC52 prefix. The 87384-byte payload
            # cannot fit in the real PTY queue; draining is held until source.set ACK.
            prefix = b'\x1b]52;c;'
            wait(lambda: raw.endswith(prefix), 'real copy prefix before sink backpressure', maximum=1)
            events.append(dict(osc_prefix_seen=True, output_bytes=len(raw), monotonic_ns=time.monotonic_ns()))
            assert text('copy-returned') == '', 'copy must still be in flight before background write'
            release(b'source')
            deadline = time.monotonic()+10; confirmation=b''
            while time.monotonic()<deadline and confirmation != b'set':
                if select.select([ack], [], [], .01)[0]: confirmation += os.read(ack, 3-len(confirmation))
            assert confirmation == b'set', 'actual background set before releasing output sink'
            assert text('copy-returned') == '', 'copy must still be in flight after source-set ACK'
            events.append(dict(worker_source_set_ack=True, monotonic_ns=time.monotonic_ns()))
        deadline=time.monotonic()+15
        while child.poll() is None and time.monotonic()<deadline: pump()
        assert child.poll() is not None, 'product direct exit timeout'
        pump(); metadata.update(exit=child.returncode, after_termios=attrs(slave))
        assert child.returncode == 0 and metadata['after_termios'] == before
        assert text('returned') == 'normal', text('summary')
        assert raw.count(b'\x1b[?2004h') == 1 and raw.count(b'\x1b[?2004l') == 1
        if mode == 'sent':
            for expected in [b'copy', b'copy', b'direct']:
                needle=b'\x1b]52;c;'+base64.b64encode(expected)+b'\x07'
                assert needle in raw
            assert raw.count(b'\x1b]52;c;') == 3
        if mode == 'cut-race':
            assert b'\x1b]52;c;'+base64.b64encode(b'x'*65536)+b'\x07' in raw
            assert 'issues=CutUnconfirmed;' in text('summary') and 'source=worker' in text('summary')
        metadata.update(result='PASS', summary=text('summary'))
    except BaseException as error:
        metadata.update(result='FAIL', error=repr(error)); raise
    finally:
        if child.poll() is None: os.killpg(child.pid, signal.SIGKILL); child.wait(); metadata['forced']=True
        pump(); metadata.setdefault('exit', child.returncode)
        metadata.update(utc_end=utc(), after_termios=attrs(slave), binary_post_sha256=sha(binary))
        (out/'input.raw').write_bytes(sent); (out/'output.raw').write_bytes(raw)
        (out/'metadata.json').write_text(json.dumps(metadata, indent=2)+'\n')
        if not closed: os.close(writer)
        for fd in [reader, ack, master, slave]: os.close(fd)
    print('PASS actual editing PTY', mode)

if __name__ == '__main__':
    p=argparse.ArgumentParser(); p.add_argument('--binary', required=True, type=Path)
    p.add_argument('--output', required=True, type=Path); p.add_argument('--shim', required=True, type=Path)
    p.add_argument('modes', nargs='*'); args=p.parse_args(); args.output.mkdir(parents=True, exist_ok=True)
    for mode in args.modes or MODES:
        assert mode in MODES
        run(args.binary.resolve(), args.output.resolve(), args.shim.resolve(), mode)
