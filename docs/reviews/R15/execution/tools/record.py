#!/usr/bin/env python3
import datetime,hashlib,json,os,subprocess,sys
from pathlib import Path
B=Path('/workspace/work/theme-execution'); R=B/'product'
name,cwd,*cmd=sys.argv[1:]; d=B/'raw'/name; d.mkdir(parents=True,exist_ok=True)
def identity():
 paths=subprocess.check_output(['git','ls-files','src','native','build.cj','cjpm.toml','tests/themes','tests/glyphs','tests/contract','tests/runtime','tests/rich-text','tests/layout','tests/decoration'],cwd=R,text=True).splitlines()
 return {p:hashlib.sha256((R/p).read_bytes()).hexdigest() for p in paths if (R/p).is_file()}
(d/'pre-source.json').write_text(json.dumps(identity(),indent=2)+'\n')
r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'cwd':cwd,'argv':cmd,'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()}
with (d/'stdout').open('wb') as out,(d/'stderr').open('wb') as err:
 p=subprocess.run(cmd,cwd=cwd,stdout=out,stderr=err)
r.update(exit=p.returncode,end_utc=datetime.datetime.now(datetime.timezone.utc).isoformat());(d/'command.json').write_text(json.dumps(r,indent=2)+'\n');(d/'post-source.json').write_text(json.dumps(identity(),indent=2)+'\n')
print(name, 'exit',p.returncode,flush=True);sys.exit(p.returncode)
