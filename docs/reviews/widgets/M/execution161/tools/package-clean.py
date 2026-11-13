from pathlib import Path,PurePosixPath
import json,tarfile,hashlib,shutil,subprocess
B=Path('/workspace/work/widgets-composite-execution');src=B/'source';out=B/'raw/package-audit';out.mkdir(exist_ok=False);archive=src/'target/cjtui-0.0.0.cjp';rows=[]
with tarfile.open(archive,'r:gz') as t:
 for m in t.getmembers():
  p=PurePosixPath(m.name);assert not p.is_absolute() and '..' not in p.parts and (m.isdir() or m.isfile()),m.name;assert p.parts[0]=='cjtui-0.0.0'
  if not m.isfile():continue
  rel='/'.join(p.parts[1:]);assert rel and not any(x in ['target','node_modules','.git','cache','build-script-cache','tests','scripts','openspec'] or x.startswith('.') for x in p.parts[1:]),m.name
  assert p.suffix.lower() not in ['.a','.o','.so','.cjo','.cjp','.zip','.tar','.gz','.bc'],m.name;assert p.name not in ['cjpm.lock','cangjie-repo.toml','AGENTS.md'],m.name
  data=t.extractfile(m).read();assert data==(src/rel).read_bytes(),m.name;rows.append(dict(path=m.name,bytes=len(data),sha256=hashlib.sha256(data).hexdigest()))
 names={r['path'].split('/',1)[1] for r in rows}
 for n in ['src/menu_entry.cj','src/split_axis.cj','src/horizontal_menu.cj','src/popup_menu.cj','src/status_bar.cj','src/split_pane.cj','docs/product/widgets.md','examples/widgets_composition/src/main.cj','docs/product/README.md']:assert n in names,n
 dest=B/'clean';dest.mkdir(exist_ok=False);t.extractall(dest,filter='data')
product=dest/'cjtui-0.0.0';suite=product/'tests/widgets_composite';suite.parent.mkdir(exist_ok=True);shutil.copytree(src/'tests/widgets_composite',suite,ignore=shutil.ignore_patterns('target','build-script-cache','cjpm.lock','cangjie-repo.toml','__pycache__'));bindings=[]
for rel in subprocess.check_output(['git','-C',str(src),'ls-files','tests/widgets_composite'],text=True).splitlines():
 p=product/rel;assert p.read_bytes()==(src/rel).read_bytes();bindings.append(dict(path=rel,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
for p in product.rglob('cjpm.toml'):(p.parent/'cangjie-repo.toml').write_bytes((B/'cangjie-repo.toml').read_bytes())
(out/'manifest.json').write_text(json.dumps(dict(fixed_source='6e3f26aaaeee9442fde91ce31d720a841eeda473',archive=str(archive),archive_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),members=rows,external_frozen_inputs=bindings,scope='Finite M safe delivered-source equality and fresh public consumer. T087 theme allowlist failure remains final023; no whole-checker PASS or skipped mandatory bundle.'),indent=2)+'\n');print('SAFE_SOURCE_EQUAL',len(rows),'FROZEN_TEST_FILES',len(bindings))
