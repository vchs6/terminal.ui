"""Pure framing/readiness around actual supervisor records; no device access."""
import re
from trace_wire import decode

def ready(text):
 if 'TRANSPORT_ERROR' in text:raise ValueError('explicit guest transport error')
 return bool(re.search(r'TTY=/dev/tty1 TERM=\S+ GRID=80x25 winsize_rc=0 VT_GETSTATE_rc=0 active=1 ',text) and
  'TRANSPORT_TRACE read_write_ioctl_only=1 exec_env_tracing=0' in text and
  re.search(r'STDOUT_IDENTITY fd=1 tty=/dev/tty1 .*VT_GETSTATE_rc=0 active=1 KDGETMODE_rc=0 mode=0 TIOCGWINSZ_rc=0 cols=80 rows=25',text) and
  'PRODUCT_STARTED pid=' in text)

def wire(text,complete=False):
 trace=bytearray()
 for line in text.splitlines(keepends=True):
  if not line.startswith('TRACE hex='):continue
  if not line.endswith('\n'):
   if complete:raise ValueError('truncated final serial trace frame')
   continue
  match=re.fullmatch(r'TRACE hex=([0-9a-f]+)\r?\n',line)
  if not match or len(match[1])%2:raise ValueError('malformed original trace hex frame')
  trace.extend(bytes.fromhex(match[1]))
 output,inputs,inventory=decode(bytes(trace),complete)
 return bytes(trace),output,inputs,inventory
