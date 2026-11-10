from pathlib import Path
import json
base=Path('/workspace/work/auto-final-execution')
for scope in ['consumer-snapshots','consumer-pty']:
 p=base/'artifacts'/scope; plain=(p/'snapshot.txt').read_bytes(); ansi=(p/'snapshot.ansi').read_bytes()
 assert b'\x1b' not in plain
 assert 'CLEAN-CONSUMER' in plain.decode() and 'RGB 中 👩‍💻' in plain.decode()
 assert len(plain.decode().split('\n'))==6
 assert b'\x1b[' in ansi and b'38;2;250;0;0m' in ansi
 assert b'\x1b[1m' in ansi and b'\x1b[3m' in ansi
 print('PASS public consumer plain/ANSI',scope,'plain bytes',len(plain),'ANSI bytes',len(ansi))
meta=json.loads((base/'artifacts/consumer-pty/pty-metadata.json').read_text()); assert meta['actual_exit']==0 and meta['restored']
print('PASS public consumer real PTY exit and exact termios restoration')
