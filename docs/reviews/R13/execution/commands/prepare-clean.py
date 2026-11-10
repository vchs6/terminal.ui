from pathlib import Path
import subprocess,tarfile,io,re,json,hashlib
b=Path('/workspace/work/dynamic-execution');s=b/'source';dest=b/'clean-product';dest.mkdir(exist_ok=True)
with tarfile.open(s/'target/cjtui-0.0.0.cjp') as t:t.extractall(dest,filter='data')
products=list(dest.glob('*/cjpm.toml'));assert len(products)==1
p=products[0].parent;(b/'clean-product-path').write_text(str(p)+'\n')
c=b/'clean-consumers';c.mkdir(exist_ok=True)
a=subprocess.check_output(['git','-C',str(s),'archive','HEAD','tests/dynamic'])
with tarfile.open(fileobj=io.BytesIO(a)) as t:t.extractall(c,filter='data')
config='[repository.cache]\npath = "'+str(b/'clean-cache')+'"\n[repository.home]\nregistry = "http://127.0.0.1:18973"\nversion = 0\n'
for tree in [p,c]:
 for m in tree.rglob('cjpm.toml'):(m.parent/'cangjie-repo.toml').write_text(config)
m=c/'tests/dynamic/cjpm.toml';old=m.read_text();new,n=re.subn(r'cjtui = \{ path = "[^\"]+" \}', 'cjtui = { path = "'+str(p)+'" }',old);assert n==1;m.write_text(new)
comparison=[]
for prefix in ['src','native','examples/dynamic']:
 for f in (s/prefix).rglob('*'):
  if f.is_file() and f.name != '.gitkeep' and subprocess.run(['git','-C',str(s),'ls-files','--error-unmatch',str(f.relative_to(s))],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode==0:
   q=p/f.relative_to(s);comparison.append(dict(path=str(f.relative_to(s)),sha256=hashlib.sha256(f.read_bytes()).hexdigest(),equal=q.is_file() and f.read_bytes()==q.read_bytes()))
assert all(i['equal'] for i in comparison)
(b/'evidence/clean-source-comparison.json').write_text(json.dumps(comparison,indent=2)+'\n')
