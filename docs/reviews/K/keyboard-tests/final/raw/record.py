from pathlib import Path
import subprocess,json,datetime,sys
b=Path(__file__).resolve().parent.parent;raw=b/'raw';name=sys.argv[1];cwd=Path(sys.argv[2]);script='source '+str(raw/'env.sh')+'\n'+sys.argv[3];args=['bash','-lc',script]
rec={'name':name,'cwd':str(cwd),'argv':args,'utc_start':datetime.datetime.now(datetime.timezone.utc).isoformat()};out=raw/(name+'.stdout');out.parent.mkdir(parents=True,exist_ok=True)
with out.open('wb') as stdout,(raw/(name+'.stderr')).open('wb') as stderr:r=subprocess.run(args,cwd=cwd,stdout=stdout,stderr=stderr)
rec.update(exit=r.returncode,utc_end=datetime.datetime.now(datetime.timezone.utc).isoformat());(raw/(name+'.exit')).write_text(str(r.returncode)+'\n');p=raw/'commands.json';records=json.loads(p.read_text()) if p.exists() else [];records.append(rec);p.write_text(json.dumps(records,indent=2)+'\n');print(name,'actual_exit',r.returncode)
