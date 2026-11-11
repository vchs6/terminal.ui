from pathlib import Path
import datetime,hashlib,json,os,subprocess,sys
B=Path('/workspace/work/interaction-execution');R=B/'product';name,cwd,*cmd=sys.argv[1:];d=B/'raw'/name;d.mkdir(parents=True,exist_ok=False);h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def identity():
 paths=subprocess.check_output(['git','ls-files','src','native','build.cj','cjpm.toml','tests/interaction_a','examples/interaction_a'],cwd=R,text=True).splitlines()
 return {p:h(R/p) for p in paths if (R/p).is_file() and not any(x in p.split('/') for x in ['evidence'])}
(d/'pre-source.json').write_text(json.dumps(identity(),indent=2)+'\n')
envpaths=[B/'env.sh',B/'cangjie-repo.toml',Path('/workspace/work/validation/sdk/cangjie/envsetup.sh')]+[Path(subprocess.check_output(['which',n],text=True).strip()) for n in ['cjc','cjpm']]
(d/'pre-environment.json').write_text(json.dumps({'hashes':{str(p):h(p) for p in envpaths},'SDK':subprocess.check_output(['cjc','--version'],text=True),'stdx':os.getenv('CANGJIE_STDX_PATH'),'UCD':os.getenv('CJTUI_UCD_ARCHIVE'),'UCD_sha256':h(Path(os.environ['CJTUI_UCD_ARCHIVE']))},indent=2)+'\n')
r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'cwd':cwd,'argv':cmd,'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()}
with (d/'stdout').open('wb') as out,(d/'stderr').open('wb') as err:p=subprocess.run(cmd,cwd=cwd,stdout=out,stderr=err)
r.update(exit=p.returncode,end_utc=datetime.datetime.now(datetime.timezone.utc).isoformat());(d/'command.json').write_text(json.dumps(r,indent=2)+'\n');(d/'post-source.json').write_text(json.dumps(identity(),indent=2)+'\n');print(name,'exit',p.returncode,flush=True);sys.exit(p.returncode)
