"""Single-stream -f framing around reviewed E146 per-TID record semantics.
Raw trace bytes are never screen data; only complete successful tty syscalls are.
"""
from decimal import Decimal
import hashlib,pathlib,re
import reviewed_trace_output as reviewed
assert hashlib.sha256(pathlib.Path(reviewed.__file__).read_bytes()).hexdigest()=='3d888264a919849b74564d40b1181bc9cbd87c34d12dcaada71f4361eb78e513'
class Memory:
 def __init__(self,data,name):self.data=data;self.name=name
 def read_bytes(self):return self.data

def annotation_identity(target):
 """Decode only a strict strace -xx fd path, never payloads or other syntax."""
 match=re.fullmatch(r'(.*)<char (\d+):(\d+)>',target)
 if not match:return None
 path,major,minor=match.groups()
 if '\\' in path:
  if not re.fullmatch(r'(?:\\x[0-9a-fA-F]{2})+',path):raise ValueError('malformed escaped fd path')
  raw=bytes.fromhex(path.replace('\\x',''))
  try:path=raw.decode('ascii')
  except UnicodeDecodeError:raise ValueError('non-ASCII canonical fd path')
 if not re.fullmatch(r'/[^\x00-\x20\\<>"]+',path):raise ValueError('invalid canonical fd path')
 return path,int(major),int(minor)

def decode(data,complete=False,*,expected_tty='/dev/tty1',expected_device=(4,1)):

 if complete and data and not data.endswith(b'\n'):raise ValueError('truncated trace line at completion')
 lines=data.splitlines(keepends=True);streams={};original={};pending={}
 for ordinal,line in enumerate(lines,1):
  if not line.endswith(b'\n'):continue
  match=re.fullmatch(rb'(\d+) +(\d+\.\d+) +(.*)\n',line)
  if not match:raise ValueError('unrecognized original -f/-ttt line '+str(ordinal))
  pid,stamp,body=match.groups();tid=int(pid);body=body.decode();normalized=stamp+b' '+match[3]+b'\n'
  index=len(streams.setdefault(tid,[]));streams[tid].append(normalized);original[tid,index+1]=ordinal
  if '<unfinished ...>' in body:
   if tid in pending or not body.endswith('<unfinished ...>'):raise ValueError('ambiguous unfinished record')
   pending[tid]=index
  elif re.match(r'<\.\.\. \w+ resumed>',body):
   if tid not in pending:raise ValueError('unpaired resumed record')
   del pending[tid]
  elif tid in pending and not body.startswith(('--- ','+++ ')):raise ValueError('interleaved unfinished record')
 records=[]
 for tid,parts in streams.items():
  if tid in pending:
   if complete:raise ValueError('unfinished syscall at completion')
   parts=parts[:pending[tid]]
  if parts:
   for row in reviewed.records(Memory(b''.join(parts),'tid-'+str(tid)),tid):
    row['original_ordinals']=[original[tid,n] for n in row['ordinals']];records.append(row)
 # Completion order is observable; unresolved overlapping tty writes fail below.
 records.sort(key=lambda row:max(row['original_ordinals']))
 output=bytearray();inputs=bytearray();inventory=[];last_write_end=0
 for row in records:
  body=row['body'];call=re.match(r'(readv?|writev?)\(',body)
  if not call:continue
  name=call[1];proxy=dict(row,body=re.sub(r'^read','write',body))
  kind,fd,target,args,result,tail=reviewed.write_record(proxy)
  identity=annotation_identity(target)
  terminal=identity==(expected_tty,*expected_device)
  if (name.startswith('write') and fd==1 or name.startswith('read') and fd==0) and not terminal:raise ValueError('declared tty fd target unknown/changed')
  if not terminal:continue
  item={'tid':row['tid'],'original_ordinals':row['original_ordinals'],'syscall':name,'fd':fd,'target':target,'normalizedTarget':identity,'result':result};inventory.append(item)
  if result<0:continue
  if name.endswith('v'):
   suffix=re.search(r', (\d+)$',args);assert suffix,'incomplete iovec count'
   vec=re.findall(r'\{iov_base="((?:\\x[0-9a-fA-F]{2})*)", iov_len=(\d+)\}',args)
   assert len(vec)==int(suffix[1]),'incomplete/truncated iovec'
   clean=re.sub(r'\{iov_base="(?:\\x[0-9a-fA-F]{2})*", iov_len=\d+\}', '{}',args)
   assert re.fullmatch(r'\[(?:\{\}(?:, )?)*\], \d+',clean),'unparsed iovec data'
   pieces=[bytes.fromhex(he.replace('\\x','')) for he,n in vec];requested=sum(int(n) for he,n in vec)
   if name=='writev':assert all(len(v)==int(n) for v,(he,n) in zip(pieces,vec)),'truncated writev payload'
   payload=b''.join(pieces)
  else:
   payload_match=re.fullmatch(r'"((?:\\x[0-9a-fA-F]{2})*)", (\d+)',args);assert payload_match,'incomplete/truncated syscall string'
   payload=bytes.fromhex(payload_match[1].replace('\\x',''));requested=int(payload_match[2])
   if name=='write':assert len(payload)==requested,'truncated write payload'
  assert 0<=result<=requested and len(payload)>=result,'successful bytes absent/truncated'
  item['requested']=requested;item['captured_successful_bytes']=result
  if name.startswith('write'):
   start,end=min(row['original_ordinals']),max(row['original_ordinals']);assert start>last_write_end,'overlapping tty write order unresolved'
   # No pending earlier tty write may be bypassed by another writer.
   for tid,index in pending.items():
    if original[tid,index+1]<end and re.match(rb'\d+\.\d+ writev?\(',streams[tid][index]):raise ValueError('pending writer makes live ordering ambiguous')
   output.extend(payload[:result]);last_write_end=end
  else:inputs.extend(payload[:result])
 return bytes(output),bytes(inputs),inventory
