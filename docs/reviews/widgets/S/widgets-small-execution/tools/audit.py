import pathlib,tarfile,hashlib,json
B=pathlib.Path('/workspace/work/widgets-small-execution');src=B/'source';out=B/'raw/package-audit';out.mkdir(exist_ok=False);archive=src/'target/cjtui-0.0.0.cjp';rows=[]
with tarfile.open(archive,'r:gz') as t:
 for m in t.getmembers():
  p=pathlib.PurePosixPath(m.name);assert not p.is_absolute() and '..' not in p.parts and (m.isdir() or m.isfile()),m.name
  assert p.parts[0]=='cjtui-0.0.0'
  if not m.isfile():continue
  rel='/'.join(p.parts[1:]);assert rel and not any(x in ['target','node_modules','.git','cache','build-script-cache','tests','scripts','openspec'] or x.startswith('.') for x in p.parts[1:]),m.name
  assert p.suffix.lower() not in ['.a','.o','.so','.cjo','.cjp','.zip','.tar','.gz','.bc'],m.name
  assert p.name not in ['cjpm.lock','cangjie-repo.toml','AGENTS.md'],m.name
  data=t.extractfile(m).read();assert data==(src/rel).read_bytes(),m.name;rows.append(dict(path=m.name,size=len(data),sha256=hashlib.sha256(data).hexdigest()))
 names={x['path'].split('/',1)[1] for x in rows}
 for n in ['src/label.cj','src/button.cj','src/checkbox.cj','src/radio.cj','src/progress.cj','examples/widgets_small/src/main.cj','docs/product/widgets.md']:assert n in names,n
(out/'manifest.json').write_text(json.dumps(dict(source_sha='1df1325f7b51777d8adab62f950c936051aa5876',archive=str(archive),archive_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),members=rows,note='Finite S source boundary safety/equality only; stale whole checker T087 remains TASK023.'),indent=2)+'\n');print('SAFE/SOURCE_EQUAL',len(rows))
