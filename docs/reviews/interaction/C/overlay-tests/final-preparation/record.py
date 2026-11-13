import subprocess,pathlib,json,datetime,sys
base=pathlib.Path(__file__).parent;raw=base/'raw';name=sys.argv[1];cwd=sys.argv[2];args=sys.argv[3:]
rec={'name':name,'cwd':cwd,'argv':args,'utc_start':datetime.datetime.now(datetime.timezone.utc).isoformat()}
with (raw/(name+'.stdout')).open('wb') as out,(raw/(name+'.stderr')).open('wb') as err:r=subprocess.run(args,cwd=cwd,stdout=out,stderr=err)
rec['exit']=r.returncode;rec['utc_end']=datetime.datetime.now(datetime.timezone.utc).isoformat();(raw/(name+'.exit')).write_text(str(r.returncode)+'\n')
p=raw/'commands.json';records=json.loads(p.read_text()) if p.exists() else [];records.append(rec);p.write_text(json.dumps(records,indent=2)+'\n');print(name,'exit',r.returncode)
