from pathlib import Path
import hashlib,json,subprocess
B=Path('/workspace/work/theme-execution');R=B/'product';C=B/'clean-consumer';lib=Path((B/'raw/package/library-path.txt').read_text().strip());cfg=(B/'cangjie-repo.toml').read_bytes()
# Only actual fixed formal integration source. No target/lock/cache/native objects copied.
files=subprocess.check_output(['git','ls-files','tests/themes/integration'],cwd=R,text=True).splitlines();checks=[]
for rel in files:
 p=R/rel;q=C/rel;q.parent.mkdir(parents=True,exist_ok=True);data=p.read_bytes()
 if p.name=='cjpm.toml':
  original=data;data=data.replace(b'path = "../../.."',b'path = "../../../package/cjtui-0.0.0"');assert data!=original
 q.write_bytes(data);checks.append({'path':rel,'original_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'copied_sha256':hashlib.sha256(data).hexdigest(),'only_dependency_path_change':p.name=='cjpm.toml','identical_source':q.read_bytes()==p.read_bytes() if p.name!='cjpm.toml' else None})
for m in [lib/'cjpm.toml',C/'tests/themes/integration/cjpm.toml']:(m.parent/'cangjie-repo.toml').write_bytes(cfg)
assert not list(lib.rglob('target')) and not list(lib.rglob('*.a')) and not list(lib.rglob('*.cjo')) and not (C/'tests/themes/integration/target').exists()
(B/'raw/package/clean-consumer-source-identity.json').write_text(json.dumps({'consumer':'full fixed formal integration','manifest_only_edit':'cjtui dependency ../../../ -> ../../../package/cjtui-0.0.0','source_files':checks,'targets_and_native_objects_absent_before_build':True,'cache':'normal own registry source cache; no cjtui library prebuilt target'},indent=2)+'\n')
print('Prepared truly source-only extracted library and unchanged full integration source')
