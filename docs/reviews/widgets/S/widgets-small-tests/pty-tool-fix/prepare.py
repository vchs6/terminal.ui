from pathlib import Path
base=Path('/workspace/work/widgets-small-tests/pty-tool-fix');ev=base/'evidence';target=base/'source/tests/widgets_small/pty.py'
before=target.read_text();(ev/'before.py').write_text(before)
old_import='import argparse, errno, fcntl, hashlib, json, os, pty, select, signal, struct, subprocess, termios, time'
new_import='import argparse, errno, fcntl, hashlib, json, os, select, signal, struct, subprocess, termios, time'
old_call='    master, slave = pty.openpty()';new_call='    master, slave = os.openpty()'
assert before.count(old_import)==before.count(old_call)==1
assert before.count('pty.')==1
after=before.replace(old_import,new_import).replace(old_call,new_call)
assert after.replace(new_call,old_call).replace(new_import,old_import)==before
target.write_text(after);(ev/'after.py').write_text(after)
(ev/'raw/actual154-runner-focus.log').write_bytes(Path('/workspace/work/widgets-small-implementation/evidence/runner-focus.log').read_bytes())
# Tool-only helper does not emulate a product, screen, protocol, widget or backend.
(ev/'transport-helper.py').write_text('''import os,sys
assert os.isatty(0) and os.isatty(1)
os.write(1,b"TOOL_ONLY_READY\\n")
line=sys.stdin.buffer.readline()
assert line==b"transport-control\\n"
os.write(1,b"TOOL_ONLY_ACK:"+line)
''')
(base/'record.py').write_text(Path('/workspace/work/widgets-small-tests/contract-fix/record.py').read_text().replace('/workspace/work/widgets-small-tests/contract-fix/evidence','/workspace/work/widgets-small-tests/pty-tool-fix/evidence'))
