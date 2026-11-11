import datetime,hashlib,json,os,subprocess,sys
from pathlib import Path
B=Path('/workspace/work/theme-load-execution');R=B/'product';name,cwd,*cmd=sys.argv[1:];d=B/'raw'/name;d.mkdir(parents=True,exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def identity():
 paths=subprocess.check_output(['git','ls-files','src','native','build.cj','cjpm.toml','tests/theme-loading','tests/layout','tests/themes/integration','tests/runtime','tests/native-session'],cwd=R,text=True).splitlines()
 return {p:h(R/p) for p in paths if '/evidence/' not in p and (R/p).is_file()}
(d/'pre-source.json').write_text(json.dumps(identity(),indent=2)+'\n')
configs=[B/'env.sh',B/'cangjie-repo.toml',Path('/workspace/work/validation/sdk/cangjie/envsetup.sh')]+[p for p in R.rglob('cangjie-repo.toml') if 'docs' not in p.relative_to(R).parts]
configs+=[Path(subprocess.check_output(['which',x],text=True).strip()) for x in ['cjc','cjpm']]
(d/'pre-environment.json').write_text(json.dumps({'hashes':{str(p):h(p) for p in configs},'CANGJIE_STDX_PATH':os.getenv('CANGJIE_STDX_PATH'),'cjc_version':subprocess.check_output(['cjc','--version'],text=True),'cjpm_version':subprocess.check_output(['cjpm','--version'],text=True)},indent=2)+'\n')
r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'cwd':cwd,'argv':cmd,'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()}
with (d/'stdout').open('wb') as out,(d/'stderr').open('wb') as err:p=subprocess.run(cmd,cwd=cwd,stdout=out,stderr=err)
r.update(exit=p.returncode,end_utc=datetime.datetime.now(datetime.timezone.utc).isoformat());(d/'command.json').write_text(json.dumps(r,indent=2)+'\n');(d/'post-source.json').write_text(json.dumps(identity(),indent=2)+'\n');print(name,'exit',p.returncode,flush=True);sys.exit(p.returncode)
