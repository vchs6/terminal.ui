import re

def extract(text,fd=1,call='write'):
 out=bytearray();pending={};stats={'complete':0,'resumed':0,'pending':0,'unparsedTarget':[]}
 for line in text.splitlines():
  m=re.match(r'\s*(\d+)\s+(.*)',line);pid,body=m.groups() if m else ('single',line)
  target=body.startswith(f'{call}({fd}, ')
  if target:
   data=re.search(r'"((?:\\x[0-9a-f]{2})*)"',body)
   if not data:
    stats['unparsedTarget'].append(line);continue
   raw=bytes.fromhex(data[1].replace('\\x',''))
   if '<unfinished ...>' in body:pending[pid]=raw;continue
   rc=re.search(r'= (-?\d+)(?:\s|$)',body)
   if rc:
    n=int(rc[1]);
    if n>0:out.extend(raw[:n])
    stats['complete']+=1
   else:stats['unparsedTarget'].append(line)
  elif body.startswith(f'<... {call} resumed>') and pid in pending:
   rc=re.search(r'= (-?\d+)(?:\s|$)',body);raw=pending.pop(pid)
   if rc:
    n=int(rc[1]);
    if n>0:out.extend(raw[:n])
    stats['resumed']+=1
   else:stats['unparsedTarget'].append(line)
 stats['pending']=len(pending);return bytes(out),stats
