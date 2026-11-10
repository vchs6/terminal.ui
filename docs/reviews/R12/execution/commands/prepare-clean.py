from pathlib import Path
import subprocess,tarfile,io
base=Path('/workspace/work/runtime-execution')
manifest=list((base/'clean-product').glob('*/cjpm.toml'))
assert len(manifest)==1
product=manifest[0].parent
(base/'clean-product-path').write_text(str(product)+'\n')
consumers=base/'clean-consumers'; consumers.mkdir()
buf=subprocess.check_output(['git','-C',str(base/'source'),'archive','HEAD','tests/runtime'])
with tarfile.open(fileobj=io.BytesIO(buf)) as t:t.extractall(consumers,filter='data')
config=(base/'source/cangjie-repo.toml').read_text()
for root in [product,consumers]:
 for p in root.rglob('cjpm.toml'):(p.parent/'cangjie-repo.toml').write_text(config)
for rel in ['tests/runtime/cjpm.toml','tests/runtime/macros/positive/cjpm.toml']:
 p=consumers/rel
 text=p.read_text(); import re
 text,n=re.subn(r'cjtui = \{ path = "[^"]+" \}', 'cjtui = { path = "'+str(product)+'" }',text)
 assert n==1
 p.write_text(text)
