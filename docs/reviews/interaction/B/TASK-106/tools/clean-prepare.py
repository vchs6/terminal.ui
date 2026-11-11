from pathlib import Path
import subprocess as s,json,hashlib
B=Path('/workspace/work/viewport-execution');R=B/'product';C=B/'clean-consumer';changes=[]
for group in ['tests/interaction_b','tests/node_reference_regression','tests/theme_canvas_integration','examples/viewport']:
 for rel in s.check_output(['git','ls-files',group],cwd=R,text=True).splitlines():
  p=C/rel;p.parent.mkdir(parents=True,exist_ok=True);data=(R/rel).read_bytes()
  if p.name=='cjpm.toml':
   old=data;depth=len(Path(rel).parent.parts);replacement=('../'*depth)+'package/cjtui-0.0.0';data=data.replace(b'path = "../.."',('path = "'+replacement+'"').encode());changes.append({'path':rel,'source_sha256':hashlib.sha256(old).hexdigest(),'consumer_sha256':hashlib.sha256(data).hexdigest(),'change':'dependency path only'})
  p.write_bytes(data)
  if (R/rel).stat().st_mode&0o111:p.chmod(0o755)
for d in [C/'package/cjtui-0.0.0',C/'tests/interaction_b',C/'tests/node_reference_regression',C/'tests/theme_canvas_integration',C/'examples/viewport']:(d/'cangjie-repo.toml').write_bytes((B/'cangjie-repo.toml').read_bytes())
(B/'raw/package/clean-inputs.json').write_text(json.dumps(changes,indent=2)+'\n')
