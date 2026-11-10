from pathlib import Path
import tarfile,re,json,hashlib,shutil,subprocess
b=Path('/workspace/work/rich-text-execution');s=b/'source';dest=b/'clean-product';dest.mkdir()
with tarfile.open(s/'target/cjtui-0.0.0.cjp') as t:
 members=t.getmembers()
 assert all(m.isfile() or m.isdir() for m in members)
 t.extractall(dest,filter='data')
products=list(dest.glob('*/cjpm.toml'));assert len(products)==1
p=products[0].parent;(b/'clean-product-path').write_text(str(p)+'\n')
inventory=json.loads((b/'evidence/source-inventory.json').read_text());comparison=[]
for f in sorted(p.rglob('*')):
 if f.is_file():
  r=str(f.relative_to(p));h=hashlib.sha256(f.read_bytes()).hexdigest()
  comparison.append(dict(path=r,sha256=h,tracked_source_sha256=inventory.get(r),equal=h==inventory.get(r)))
assert all(i['equal'] for i in comparison),[i for i in comparison if not i['equal']]
productPaths=[r for r in inventory if r=='build.cj' or r=='cjpm.toml' or r in ['README.md','README_zh.md','LICENSE','NOTICE','CHANGELOG.md'] or r.startswith(('src/','native/','examples/','benchmarks/','docs/product/','third_party/licenses/'))]
omitted=sorted(set(productPaths)-{i['path'] for i in comparison});assert all(x.endswith('/.gitkeep') for x in omitted),omitted
(b/'evidence/clean-package-source-equality.json').write_text(json.dumps(dict(files=comparison,nonproduct_gitkeep_omissions=omitted,all_file_bytes_equal=True),indent=2)+'\n')
c=b/'clean-consumers/tests/rich-text';shutil.copytree(s/'tests/rich-text',c,ignore=shutil.ignore_patterns('target','cangjie-repo.toml','cjpm.lock'))
m=c/'cjpm.toml';old=m.read_text();new,n=re.subn(r'cjtui = \{ path = "[^\"]+" \}', 'cjtui = { path = "'+str(p)+'" }',old);assert n==1;m.write_text(new)
checks=[]
for f in sorted(c.rglob('*')):
 if f.is_file():
  q=s/'tests/rich-text'/f.relative_to(c);checks.append(dict(path=str(f.relative_to(c)),equal=f.read_bytes()==q.read_bytes(),manifest_path_only=f==m and f.read_text()==new))
assert all(i['equal'] or i['manifest_path_only'] for i in checks)
(b/'evidence/clean-consumer-source-equality.json').write_text(json.dumps(checks,indent=2)+'\n')
shutil.copytree('/workspace/work/validation/replay-dependencies/cache',b/'clean-cache')
config='[repository.cache]\npath = "'+str(b/'clean-cache')+'"\n[repository.home]\nregistry = "http://127.0.0.1:18973"\nversion = 0\n'
for tree in [p,b/'clean-consumers']:
 for m in tree.rglob('cjpm.toml'):(m.parent/'cangjie-repo.toml').write_text(config)
