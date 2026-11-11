from pathlib import Path
import hashlib,json,subprocess
B=Path('/workspace/work/interaction-execution');R=B/'product';C=B/'clean-consumer';cfg=(B/'cangjie-repo.toml').read_bytes();rows=[]
for old,new,sourcepath,newdep in [('tests/interaction_a','tests/interaction_a','../..','../../package/cjtui-0.0.0'),('examples/interaction_primitives','example-interaction','../..','../package/cjtui-0.0.0')]:
 paths=subprocess.check_output(['git','ls-files',old+'/src',old+'/cjpm.toml'],cwd=R,text=True).splitlines()
 for rel in paths:
  p=R/rel;q=C/new/p.relative_to(R/old);q.parent.mkdir(parents=True,exist_ok=True);data=p.read_bytes()
  if p.name=='cjpm.toml':
   before=data;data=data.replace(('path = "'+sourcepath+'"').encode(),('path = "'+newdep+'"').encode());assert data!=before
  q.write_bytes(data);rows.append({'source':rel,'copied':str(q.relative_to(B)),'original_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'copied_sha256':hashlib.sha256(data).hexdigest(),'only_dependency_path_edit':p.name=='cjpm.toml','source_bytes_equal':p.name=='cjpm.toml' or data==p.read_bytes()})
 (C/new/'cangjie-repo.toml').write_bytes(cfg)
lib=C/'package/cjtui-0.0.0';(lib/'cangjie-repo.toml').write_bytes(cfg);assert not list(lib.rglob('target')) and not list(lib.rglob('*.a')) and not list(lib.rglob('*.cjo'))
(B/'raw/package/clean-inputs.json').write_text(json.dumps({'files':rows,'no_binary_target_lock_copied':True,'only_manifest_path_changes':True},indent=2)+'\n');print('Prepared clean fixed normal public consumer and interaction example; path-only manifests')
