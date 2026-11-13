import pathlib,tarfile,hashlib,json,subprocess,shutil
B=pathlib.Path('/workspace/work/editing-execution');src=B/'source';out=B/'raw/package-audit';out.mkdir(exist_ok=False);archive=src/'target/cjtui-0.0.0.cjp';rows=[]
with tarfile.open(archive,'r:gz') as t:
 for m in t.getmembers():
  p=pathlib.PurePosixPath(m.name);assert not p.is_absolute() and '..' not in p.parts and (m.isdir() or m.isfile()),m.name
  assert p.parts[0]=='cjtui-0.0.0'
  if not m.isfile():continue
  rel='/'.join(p.parts[1:]);assert rel and not any(x in ['target','node_modules','.git','cache','build-script-cache','tests','scripts','openspec'] or x.startswith('.') for x in p.parts[1:]),m.name
  assert p.suffix.lower() not in ['.a','.o','.so','.cjo','.cjp','.zip','.tar','.gz','.bc'],m.name
  assert p.name not in ['cjpm.lock','cangjie-repo.toml','AGENTS.md'],m.name
  data=t.extractfile(m).read();original=src/rel;assert original.is_file() and data==original.read_bytes(),m.name
  rows.append(dict(path=m.name,size=len(data),sha256=hashlib.sha256(data).hexdigest()))
 names={x['path'].split('/',1)[1] for x in rows}
 for name in ['cjpm.toml','src/text_input.cj','src/text_area.cj','src/text_edit_controller.cj','native/cjtui_terminal.c','docs/product/text-editing.md','examples/editing/cjpm.toml','examples/editing/src/main.cj']:assert name in names,name
 dest=B/'clean-unpacked';dest.mkdir(exist_ok=False);t.extractall(dest,filter='data')
product=dest/'cjtui-0.0.0';bindings=[]
for rel in ['tests/editing','tests/keyboard/native/pipe_remap.c','tests/run-slice.sh']:
 path=src/rel;target=product/rel
 if path.is_dir():shutil.copytree(path,target)
 else:target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(path,target)
for p in (product/'tests').rglob('*'):
 if p.is_file() and p.name!='cangjie-repo.toml':
  rel=str(p.relative_to(product));assert p.read_bytes()==(src/rel).read_bytes();bindings.append(dict(path=rel,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
for p in product.rglob('cjpm.toml'):(p.parent/'cangjie-repo.toml').write_bytes((B/'cangjie-repo.toml').read_bytes())
record=dict(source_sha='22ca8cf7c756c5185064a6f8bc7e9f2c58d4f167',archive=str(archive),archive_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),members=rows,external_frozen_test_overlay=bindings,note='Archive exact-source audit only; T087-G01 remains TASK023. Clean root contains unpacked delivery plus byte-equal independent tests as public path consumers; no author target/SDK/cache copied.')
(out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n');print(len(rows),'safe source-equal archive files;',len(bindings),'frozen external test inputs')
