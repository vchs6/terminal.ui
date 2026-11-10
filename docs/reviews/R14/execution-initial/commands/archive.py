from pathlib import Path
import shutil,json,hashlib,re,datetime
b=Path('/workspace/work/rich-text-execution');out=b/'curated-r14-execution-draft';out.mkdir(exist_ok=True)
h=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
for name in ['report.md','scope.json']:(out/name).write_bytes((b/name).read_bytes())
for name in ['commands','evidence']:
 for f in sorted((b/name).rglob('*')):
  if not f.is_file() or f.is_symlink() or '__pycache__' in f.parts:continue
  rel=f.relative_to(b)
  if f.name in ['sdk-envsetup.sh','gui-key'] or 'xdg-cache' in f.parts:continue
  assert not f.read_bytes().startswith(b'\x7fELF'),str(rel)
  assert f.suffix not in ['.cjp','.cjo','.a','.o','.so','.cj'],str(rel)
  assert f.suffix!='.md',str(rel)
  p=out/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,p)
for f in out.rglob('*.json'):json.loads(f.read_text())
links=[]
for f in out.rglob('*.md'):
 for target in re.findall(r'\]\(([^)]+)\)',f.read_text()):
  if target.startswith(('https://','http://')):continue
  p=(f.parent/target.split('#')[0]);assert p.exists(),(f,target);links.append(dict(file=str(f.relative_to(out)),target=target,exists=True))
proof=out/'archive-proof.json'
files=[p for p in out.rglob('*') if p.is_file() and p.name not in ['artifacts.sha256','archive-proof.json']]
proof.write_text(json.dumps(dict(created_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),strict_json=True,no_elf=True,no_cjp_cache_sdk_checkout=True,markdown_links=links,manifest_entries=len(files)+1,manifest_self_included=False,files_including_manifest=len(files)+2,manifest_self_hash_location='../curated-draft-manifest.sha256'),indent=2)+'\n')
files=sorted(p for p in out.rglob('*') if p.is_file() and p.name!='artifacts.sha256')
(out/'artifacts.sha256').write_text(''.join(h(f)+'  '+str(f.relative_to(out))+'\n' for f in files))
(b/'curated-draft-manifest.sha256').write_text(h(out/'artifacts.sha256')+'  curated-r14-execution-draft/artifacts.sha256\n')
rootfiles=[b/'report.md',b/'scope.json']+[f for name in ['commands','evidence'] for f in (b/name).rglob('*') if f.is_file() and f.name!='gui-key' and '__pycache__' not in f.parts]
(b/'artifacts.sha256').write_text(''.join(h(f)+'  '+str(f.relative_to(b))+'\n' for f in sorted(rootfiles)))
print(json.dumps(dict(curated=str(out),manifest_entries=len(files),files_including_manifest=len(files)+1,manifest_sha256=h(out/'artifacts.sha256'))))
