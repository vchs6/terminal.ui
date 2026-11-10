#!/usr/bin/python3
"""Self-owned terminal content; no product code, clipboard, or ANSI renderer."""
import datetime, fcntl, json, os, pathlib, struct, sys, termios, time, tty

p = pathlib.Path(sys.argv[1])
def record(name, value):
    (p / (name + '.json')).write_text(json.dumps(value, ensure_ascii=False, indent=2, default=lambda b:b.hex()))
def utc(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
before = termios.tcgetattr(0)
record('child', {'pid':os.getpid(), 'tty':os.ttyname(0), 'TERM':os.environ.get('TERM'),
                 'rowsCols':list(struct.unpack('HHHH',fcntl.ioctl(0,termios.TIOCGWINSZ,b'\0'*8)))[:2],
                 'utc':utc(), 'termiosBefore':before})
payloads = [
    b'\x1b[2J\x1b[HNORMAL_SCREEN_OWNED\r\nSTALE_NORMAL\x1b[2K\rCURRENT_NORMAL\r\n'+ '中文 中😀 e\u0301\r\n'.encode() + b'\x1b[32mGREEN_NATIVE\x1b[0m\x1b[7;1HROW7_NORMAL',
    b'\x1b[?1049h\x1b[2J\x1b[HALTERNATE_SCREEN_OWNED\r\nSTALE_ALT\x1b[2K\rCURRENT_ALT\r\n'+ 'ALT 中文 中😀 e\u0301\r\n'.encode() + b'\x1b[31mRED_NATIVE\x1b[0m\x1b[28;1HBOTTOM_ROW28_ALT',
    b'\x1b[?1049l',
    b'\x1b[2J\x1b[H'+b''.join(('SCROLL_%02d\r\n'%i).encode() for i in range(1,41)),
]
try:
    tty.setraw(0)
    for index,payload in enumerate(payloads):
        while not (p / ('command-%d.json'%index)).exists(): time.sleep(.025)
        os.write(1,payload)
        with (p/'emitted.bin').open('ab') as f: f.write(payload)
        record('ack-%d'%index, {'utc':utc(),'bytes':len(payload),'hex':payload.hex()})
    while not (p/'exit-command.json').exists(): time.sleep(.025)
finally:
    termios.tcsetattr(0,termios.TCSANOW,before)
    record('exit', {'exitCode':0,'termiosAfter':termios.tcgetattr(0),'utc':utc()})
