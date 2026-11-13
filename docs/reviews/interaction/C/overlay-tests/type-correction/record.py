from pathlib import Path
import subprocess,json,datetime,sys
b=Path(__file__).parent;raw=b/'raw';name=sys.argv[1];args=['bash','-lc','source /workspace/work/interaction-a-tests/final/env.sh\nexec cjpm build'];cwd=b/'replay/tests/interaction_c';rec={'name':name,'cwd':str(cwd),'argv':args,'utc_start':datetime.datetime.now(datetime.timezone.utc).isoformat()}
with (raw/(name+'.stdout')).open('wb') as out,(raw/(name+'.stderr')).open('wb') as err:r=subprocess.run(args,cwd=cwd,stdout=out,stderr=err)
rec['exit']=r.returncode;rec['utc_end']=datetime.datetime.now(datetime.timezone.utc).isoformat();(raw/(name+'.exit')).write_text(str(r.returncode)+'\n');p=raw/'commands.json';records=json.loads(p.read_text()) if p.exists() else [];records.append(rec);p.write_text(json.dumps(records,indent=2)+'\n');print(name,'exit',r.returncode)
