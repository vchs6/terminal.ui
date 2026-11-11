from pathlib import Path
import hashlib,json,subprocess
B=Path('/workspace/work/theme-load-execution');R=B/'product';C=B/'clean-consumer';lib=Path((B/'raw/package/library-path.txt').read_text().strip());cfg=(B/'cangjie-repo.toml').read_bytes();rows=[]
for rel in subprocess.check_output(['git','ls-files','tests/theme-loading/consumer'],cwd=R,text=True).splitlines():
 p=R/rel;q=C/rel;q.parent.mkdir(parents=True,exist_ok=True);data=p.read_bytes()
 if p.name=='cjpm.toml':
  before=data;data=data.replace(b'path = "../../.."',b'path = "../../../package/cjtui-0.0.0"');assert data!=before
 q.write_bytes(data);rows.append({'path':rel,'fixed_source_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'copied_sha256':hashlib.sha256(data).hexdigest(),'identical_source':p.name=='cjpm.toml' or p.read_bytes()==q.read_bytes(),'only_changed_manifest_field':'cjtui dependency path' if p.name=='cjpm.toml' else None})
for m in [lib/'cjpm.toml',C/'tests/theme-loading/consumer/cjpm.toml']:(m.parent/'cangjie-repo.toml').write_bytes(cfg)
assert not list(lib.rglob('target')) and not list(lib.rglob('*.a')) and not list(lib.rglob('*.cjo')) and not (C/'tests/theme-loading/consumer/target').exists()
(B/'raw/package/clean-consumer-source-identity.json').write_text(json.dumps({'full_formal_consumer_copied':True,'only_manifest_dependency_path_changed':True,'targets_native_objects_lock_not_copied':True,'files':rows,'controller':'unchanged fixed original run.py run_controlled()/generate_inputs; selected cases latest-success and atomic-caches; own original gate interposer reused by hash'},indent=2)+'\n');print('Prepared full fixed consumer, only dependency path changed; package has no prebuilt targets')
