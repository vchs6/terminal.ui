import pathlib,tarfile,hashlib,json,sys,tomllib
B=pathlib.Path('/workspace/work/keyboard-execution');archive=B/'source/target/cjtui-0.0.0.cjp';out=B/'raw/package-audit';out.mkdir(exist_ok=False);members=[];root=None
with tarfile.open(archive,'r:gz') as t:
 for m in t.getmembers():
  p=pathlib.PurePosixPath(m.name);assert not p.is_absolute() and '..' not in p.parts and (m.isdir() or m.isfile()),m.name
  if not m.isfile():continue
  parts=p.parts;assert parts and parts[0]=='cjtui-0.0.0',m.name
  rel='/'.join(parts[1:]);assert rel and not any(x in ['target','node_modules','.git','cache','build-script-cache','tests','scripts','openspec'] or x.startswith('.') for x in parts[1:]),m.name
  assert p.suffix.lower() not in ['.a','.o','.so','.cjo','.cjp','.zip','.tar','.gz','.bc'],m.name
  assert p.name not in ['cjpm.lock','cangjie-repo.toml','AGENTS.md'],m.name
  data=t.extractfile(m).read();source=B/'source'/rel;assert source.is_file(),'missing source '+rel;assert data==source.read_bytes(),'source mismatch '+rel
  members.append(dict(path=m.name,source_path=str(source),size=len(data),sha256=hashlib.sha256(data).hexdigest()))
 names={x['path'].split('/',1)[1] for x in members}
 for required in ['cjpm.toml','src/keyboard_decoder.cj','src/keyboard_limits.cj','src/key_event.cj','native/cjtui_terminal.c','docs/product/keyboard.md','examples/keyboard/cjpm.toml','examples/keyboard/src/main.cj']:assert required in names,required
 dest=B/'clean-unpacked';dest.mkdir(exist_ok=False);t.extractall(dest,filter='data')
record=dict(archive=str(archive),archive_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),source_sha='c3c4642d84df57bbd9550d222ed22f602acd13ef',scope='TASK116 finite package member safety/source equality + clean Keyboard consumers; stale whole-product check-bundle/T087-G01 NOT invoked/passed; TASK023 remains',members=members)
(out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n');(out/'manifest.json').chmod(0o444)
product=B/'clean-unpacked/cjtui-0.0.0';config=(B/'cangjie-repo.toml').read_bytes()
for f in product.rglob('cjpm.toml'):(f.parent/'cangjie-repo.toml').write_bytes(config)
print('Safe members and exact source equality',len(members),'archive',record['archive_sha256'])
