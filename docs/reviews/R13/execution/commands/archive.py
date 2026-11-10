from pathlib import Path
import shutil,json,hashlib,re,subprocess
b=Path('/workspace/work/dynamic-execution');d=b/'r13-execution-draft';d.mkdir(exist_ok=True)
c=b/'commands';c.mkdir(exist_ok=True)
for p in b.iterdir():
 if p.is_file() and p.suffix in ['.py','.sh','.c']:shutil.copy2(p,c/p.name)
shutil.copy2(b/'report.md',d/'report.md');shutil.copytree(c,d/'commands',dirs_exist_ok=True)
def ignore(path,names):return [n for n in names if n in ['xdg-cache','cache','target','node_modules','source','clean-product','clean-consumers','privatekeys','x11-xtest-interrupt'] or n.endswith(('.cjp','.a','.o'))]
shutil.copytree(b/'evidence',d/'evidence',dirs_exist_ok=True,ignore=ignore)
(d/'scope.json').write_text(json.dumps(dict(destination='docs/reviews/R13/execution',source_checkout_external=str(b/'source'),original_bundle_external=str(b/'source/target/cjtui-0.0.0.cjp'),binary_source_cache_policy='Excluded: executables, .cjp, target, native archives, caches, source snapshots, private keys',copy='Copy this directory contents mechanically to docs/reviews/R13/execution; all Markdown artifact links are relative and resolve there.'),indent=2)+'\n')
for p in d.rglob('*.json'):json.loads(p.read_text())
for p in d.rglob('*.md'):
 for label,target in re.findall(r'\[([^\]]+)\]\(([^)]+)\)',p.read_text()):
  if '://' not in target:assert (p.parent/target.split('#')[0]).exists(),(p,target)
for p in d.rglob('*'):
 assert not p.is_symlink(),p
 if p.is_file():
  assert p.read_bytes()[:4]!=b'\x7fELF',p
  assert p.suffix not in ['.cjp','.o','.a'],p
files=sorted(p for p in d.rglob('*') if p.is_file() and p.name!='artifacts.sha256')
(d/'artifacts.sha256').write_text(''.join(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+str(p.relative_to(d))+'\n' for p in files))
result=subprocess.run(['sha256sum','-c','artifacts.sha256'],cwd=d,capture_output=True,text=True);assert result.returncode==0,result.stderr
(b/'archive-hash-verification.txt').write_text(result.stdout)
print(json.dumps(dict(archive=str(d),files=len(files),bytes=sum(p.stat().st_size for p in files),hashes_valid=True,markdown_links_resolve=True,strict_json=True),indent=2))
