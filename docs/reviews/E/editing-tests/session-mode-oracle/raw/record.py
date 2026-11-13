from pathlib import Path
import subprocess,json,datetime,sys
b=Path(__file__).resolve().parent.parent;raw=b/'raw';name=sys.argv[1];cwd=sys.argv[2];argv=sys.argv[3:];rec={'name':name,'cwd':cwd,'argv':argv,'utc_start':datetime.datetime.now(datetime.timezone.utc).isoformat()}
with (raw/(name+'.stdout')).open('wb') as out,(raw/(name+'.stderr')).open('wb') as err:r=subprocess.run(argv,cwd=cwd,stdout=out,stderr=err)
rec.update(exit=r.returncode,utc_end=datetime.datetime.now(datetime.timezone.utc).isoformat());(raw/(name+'.exit')).write_text(str(r.returncode)+'\n');p=raw/'commands.json';records=json.loads(p.read_text()) if p.exists() else [];records.append(rec);p.write_text(json.dumps(records,indent=2)+'\n');print(name,'actual_exit',r.returncode)
