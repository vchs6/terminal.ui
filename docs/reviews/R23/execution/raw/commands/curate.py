from pathlib import Path
import hashlib,json,re,shutil
b=Path('/workspace/work/glyph-advance-execution');c=b/'r23-execution-draft'
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
files=[]
for p in b.iterdir():
 if p.is_file() and p.suffix in ['.md','.json','.sha256','.patch','.txt'] and p.name not in ['artifacts.sha256','artifact-counts.json']:files.append(p)
for d in ['raw','gui','provenance']:files+=sorted(p for p in (b/d).rglob('*') if p.is_file())
files=sorted(set(files));payload=[p for p in files if 'xdg-cache' not in p.relative_to(b).parts]
for p in payload:
 data=p.read_bytes();assert not data.startswith(b'\x7fELF'),p
 assert p.suffix not in ['.cjp','.a','.o','.so'],p
 assert not any(x in p.relative_to(b).parts for x in ['cache','clean-cache','source','package','target','node_modules','.git']),p
summary={'full_payload_files_excluding_manifest':len(files)+1,'curated_payload_files_excluding_manifest':len(payload)+1,'manifest_self_files_per_tree':1,'original_png_full':sum(p.suffix=='.png' for p in files),'original_png_curated':sum(p.suffix=='.png' for p in payload),'curated_excluded_xdg_cache_files':len(files)-len(payload),'source_checkout_cache_package_sdk_elf_in_curated':0,'status':'TASK166 independent execution PASS; acceptance167 remains separate'}
(b/'artifact-counts.json').write_text(json.dumps(summary,indent=2)+'\n');files.append(b/'artifact-counts.json');payload.append(b/'artifact-counts.json')
# Strict JSON: reject duplicate keys and non-finite constants.
def obj(pairs):
 d={}
 for k,v in pairs:
  assert k not in d,('duplicate JSON key',k)
  d[k]=v
 return d
for p in files:
 if p.suffix=='.json':json.loads(p.read_text(),object_pairs_hook=obj,parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
 if p.suffix=='.jsonl':
  for line in p.read_text().splitlines():json.loads(line,object_pairs_hook=obj)
# All report links resolve in both trees; folders are not used as evidence links.
for link in re.findall(r'\]\(([^)]+)\)',(b/'report.md').read_text()):
 assert (b/link).is_file(),link
 assert b/link in payload,('curated link missing',link)
if c.exists():
 # Only this task's reproducible draft is replaced; no original evidence removed.
 shutil.rmtree(c)
c.mkdir()
for p in payload:
 q=c/p.relative_to(b);q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q);assert sha(q)==sha(p)
(b/'artifacts.sha256').write_text(''.join(sha(p)+'  '+str(p.relative_to(b))+'\n' for p in sorted(files)))
(c/'artifacts.sha256').write_text(''.join(sha(p)+'  '+str(p.relative_to(b))+'\n' for p in sorted(payload)))
assert len(list(c.rglob('*.png')))==80
print(json.dumps(summary));print('curated_manifest_sha256',sha(c/'artifacts.sha256'))
