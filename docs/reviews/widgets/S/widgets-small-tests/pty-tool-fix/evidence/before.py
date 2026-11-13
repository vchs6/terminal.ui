#!/usr/bin/env python3
"""Real Linux PTY only; future product consumer. No emulator/backend/interposer."""
import argparse, errno, fcntl, hashlib, json, os, pty, select, signal, struct, subprocess, termios, time
from pathlib import Path

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def run(binary, output, mode):
    directory = output / mode
    directory.mkdir(parents=True, exist_ok=False)
    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 6, 40, 0, 0))
    before = subprocess.check_output(['stty', '-g'], stdin=slave).decode().strip()
    raw, sent, events = bytearray(), bytearray(), []
    env = dict(os.environ, TERM='xterm-256color', COLORTERM='', CJTUI_SMALL_OUTPUT=str(directory), CJTUI_SMALL_MODE=mode)
    def terminal():
        os.setsid()
        fcntl.ioctl(slave, termios.TIOCSCTTY, 0)
    binary_hash = sha(binary)
    metadata = dict(mode=mode, binary=str(binary), binary_sha256=binary_hash, cwd=str(Path.cwd()),
                    before_stty=before, route='real PTY stdin/stdout; no shim', events=events)
    with (directory / 'stderr.raw').open('wb') as err:
        child = subprocess.Popen([str(binary)], stdin=slave, stdout=slave, stderr=err, env=env, preexec_fn=terminal)
    def pump():
        if select.select([master], [], [], 0.02)[0]:
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
                raise AssertionError('product exited before ' + label)
        raise AssertionError('watchdog: ' + label)
    def text(name):
        p = directory / name
        return p.read_text() if p.exists() else ''
    def send(data):
        sent.extend(data)
        events.append(dict(input_hex=data.hex(), monotonic_ns=time.monotonic_ns()))
        view = memoryview(data)
        while view:
            view = view[os.write(master, view):]
    try:
        await_condition(lambda: b'S_WIDGETS_READY' in raw and b'\x1b[' in raw, 'actual native first frame')
        send(b'\r')
        if mode == 'normal':
            await_condition(lambda: text('button') == '1', 'actual Enter button callback')
            send(b'\t ')
            await_condition(lambda: text('checkbox') == '1', 'actual HT Space checkbox callback')
            send(b'\t\r')
            await_condition(lambda: text('radio') == '1', 'actual HT Enter radio callback')
            send(b' q')  # selected Radio Space consumes but requests zero; q exits.
        await_condition(lambda: child.poll() is not None, 'direct product exit', may_exit=True)
        pump()
        after = subprocess.check_output(['stty', '-g'], stdin=slave).decode().strip()
        metadata.update(exit=child.returncode, after_stty=after)
        assert after == before, 'exact stty restoration'
        summary = dict(line.split('=', 1) for line in text('summary').splitlines())
        metadata['summary'] = summary
        assert summary['resources'] == '0/0/0/0' and summary['cleanups'] == '1'
        assert child.returncode == {'normal': 0, 'callback-failure': 21, 'getter-failure': 22}[mode]
        if mode == 'normal':
            assert summary == dict(clicks='1', boxRequests='1', checked='true', radioRequests='1', selected='true', cleanups='1', resources='0/0/0/0')
            assert not text('error')
        else:
            assert {'callback-failure': 'S_NATIVE_CALLBACK_SENTINEL', 'getter-failure': 'S_NATIVE_GETTER_SENTINEL'}[mode] in text('error')
        assert raw.count(b'\x1b[?2004h') == 1 and raw.count(b'\x1b[?2004l') == 1, 'native bracketed-paste mode paired cleanup'
        assert sha(binary) == binary_hash
        metadata['result'] = 'PASS'
    except BaseException as error:
        metadata.update(result='FAIL', error=repr(error))
        raise
    finally:
        if child.poll() is None:
            os.killpg(child.pid, signal.SIGKILL)
            child.wait()
            metadata['forced_termination'] = True
        pump()
        metadata.setdefault('exit', child.returncode)
        metadata.setdefault('after_stty', subprocess.check_output(['stty', '-g'], stdin=slave).decode().strip())
        (directory / 'input.raw').write_bytes(sent)
        (directory / 'output.raw').write_bytes(raw)
        (directory / 'metadata.json').write_text(json.dumps(metadata, indent=2) + '\n')
        os.close(master)
        os.close(slave)
    print('PASS real small-widget PTY', mode)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    for mode in ['normal', 'callback-failure', 'getter-failure']:
        run(args.binary.resolve(), args.output.resolve(), mode)
