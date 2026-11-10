from pathlib import Path
import hashlib,json,subprocess,os
b=Path('/workspace/work/dynamic-execution');s=b/'source';e=b/'evidence'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
binaries=[]
for tree in [s,b/'clean-consumers',b/'clean-product']:
 if tree.exists():
  for p in tree.rglob('target/release/bin/main'):
   binaries.append(dict(path=str(p),sha256=sha(p),bytes=p.stat().st_size))
(e/'executed-binaries.json').write_text(json.dumps(binaries,indent=2)+'\n')
deps={}
for cache in ['cache','clean-cache']:
 root=b/cache/'repository/source/default'
 if root.exists():deps[cache]={str(p.relative_to(root)):sha(p) for p in root.rglob('*') if p.is_file() and (p.suffix=='.cj' or p.name=='cjpm.toml')}
assert deps['cache']==deps['clean-cache']
oldroot=Path('/workspace/work/runtime-execution/cache/repository/source/default')
olddeps={str(p.relative_to(oldroot)):sha(p) for p in oldroot.rglob('*') if p.is_file() and (p.suffix=='.cj' or p.name=='cjpm.toml')}
assert olddeps==deps['cache']
(e/'reuse/dependency-content-equality.json').write_text(json.dumps(dict(old_cache=str(oldroot),current_cache=str(b/'cache'),equal=True,files=len(olddeps)),indent=2)+'\n')
(e/'dependency-content.json').write_text(json.dumps(deps,indent=2)+'\n')
files=[Path('/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip')]
sdk=Path('/workspace/work/validation/sdk/cangjie')
for rel in ['bin/cjc','tools/bin/cjpm','envsetup.sh']:
 p=sdk/rel
 if p.is_file():files.append(p)
(e/'sdk-ucd-sha256.json').write_text(json.dumps({str(p):sha(p) for p in files},indent=2)+'\n')
sessions=[]
for d in e.glob('cjtui-runtime-pty-*/*'):
 if not (d/'result.json').is_file():continue
 v=json.loads((d/'result.json').read_text());v['before']=(d/'before').read_text();v['after']=(d/'after').read_text();v['close_record']=(d/'close-record.txt').read_text();v['cleanup']=(d/'cleanup').read_text() if (d/'cleanup').exists() else None
 assert v['passed'] and v['before']==v['after'] and v['close_record'].count('real_result=0')==1
 pid=int((d/'pid').read_text());v['pid']=pid;v['process_alive']=Path(f'/proc/{pid}').exists();assert not v['process_alive']
 sessions.append(v)
assert len(sessions)==12
(e/'runtime-pty-summary.json').write_text(json.dumps(sessions,indent=2)+'\n')
checks={p.parent.name:int(p.read_text()) for p in e.glob('*/exit') if p.parent.name!='reuse'}
assert all(code==0 for name,code in checks.items() if name not in ['archive-boundary','clean-prepare']),checks
assert checks['archive-boundary']==1 and checks['clean-prepare']==1 and checks['clean-prepare-recheck']==0,checks
(e/'command-results.json').write_text(json.dumps(checks,indent=2)+'\n')
