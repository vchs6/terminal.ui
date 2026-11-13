import os,json,hashlib,stat,time,collections
from pathlib import Path
base=Path('/workspace/work/editing-implementation/raw/resource-cleanup-3')
before=base/'before.json'
assert hashlib.sha256(before.read_bytes()).hexdigest()==(base/'before.sha256').read_text().split()[0]
data=json.loads(before.read_text()); active=[]; gaps=[]; opaque=[]
for d in Path('/proc').iterdir():
 if not d.name.isdigit(): continue
 vals=[]
 for k in ('cwd','exe'):
  try: vals.append(os.readlink(d/k))
  except OSError as e: gaps.append({'pid':d.name,'entry':k,'error':str(e)})
 active+=vals
 if not vals:
  try:
   status=(d/'status').read_text(); state=next((x for x in status.splitlines() if x.startswith('State:')),''); name=next((x for x in status.splitlines() if x.startswith('Name:')),''); parent=next((x for x in status.splitlines() if x.startswith('PPid:')),''); cmd=(d/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')
   if 'Z (zombie)' not in state: opaque.append({'pid':d.name,'state':state,'name':name,'parent':parent,'cmdline':cmd})
  except OSError: pass
ancestors=set(); pid=os.getpid()
while pid > 1:
 ancestors.add(str(pid))
 try:
  info=(Path('/proc')/str(pid)/'status').read_text(); pid=int(next(x.split()[1] for x in info.splitlines() if x.startswith('PPid:')))
 except (OSError,StopIteration,ValueError): break
for item in opaque:
 if item['pid'] in ancestors: continue
 cmd=item['cmdline']
 if '/workspace/work/editing-implementation/' in cmd or any(k in cmd for k in ('cjpm','cjc','cjlint')):
  raise SystemExit('opaque task/compiler process: '+repr(item))
removed=[];skipped=[]
for r in data['files']:
 p=Path(r['path']); project=r['project']
 if any(x==project or x.startswith(project+'/') for x in active): skipped.append({'path':str(p),'reason':'active'});continue
 try:
  fd=os.open(p,os.O_RDONLY|os.O_NOFOLLOW)
  try:
   st=os.fstat(fd); h=hashlib.sha256()
   while True:
    b=os.read(fd,1048576)
    if not b: break
    h.update(b)
   now=os.lstat(p)
   if not stat.S_ISREG(st.st_mode) or (st.st_ino,st.st_dev,st.st_size,st.st_mtime_ns,h.hexdigest()) != (r['inode'],r['device'],r['size'],r['mtime_ns'],r['sha256']) or (now.st_ino,now.st_dev)!=(st.st_ino,st.st_dev):
    skipped.append({'path':str(p),'reason':'identity changed'});continue
   os.unlink(p);removed.append(r)
  finally: os.close(fd)
 except OSError as e: skipped.append({'path':str(p),'reason':str(e)})
verify=[r['path'] for r in removed if os.path.lexists(r['path'])]
result={'time_ns':time.time_ns(),'proc_visibility_gaps':gaps,'nonzombie_opaque':opaque,'removed':removed,'skipped':skipped,'verify_still_present':verify,'freed_bytes':sum(r['size'] for r in removed)}
p=base/'deletion.json';p.write_text(json.dumps(result,indent=2)+'\n');os.chmod(p,0o444)
(base/'deletion.sha256').write_text(hashlib.sha256(p.read_bytes()).hexdigest()+'  deletion.json\n')
print('removed',len(removed),'bytes',result['freed_bytes'],'skipped',len(skipped),'remaining',len(verify),'opaque-nonzombie',len(opaque))
