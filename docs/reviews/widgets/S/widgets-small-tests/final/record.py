import subprocess,pathlib,json,sys,hashlib,time
base=pathlib.Path('/workspace/work/widgets-small-tests/final/evidence')
name,cwd,command=sys.argv[1:4]
start=time.time()
p=subprocess.run(['bash','-c',command],cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
files={}
for stream,data in [('stdout',p.stdout),('stderr',p.stderr)]:
 f=base/'raw'/f'{name}.{stream}';f.write_bytes(data);files[stream]={'path':str(f),'sha256':hashlib.sha256(data).hexdigest()}
f=base/'commands.json';rows=json.loads(f.read_text()) if f.exists() else []
rows.append(dict(name=name,cwd=cwd,command=command,exit=p.returncode,elapsed_seconds=round(time.time()-start,3),raw=files));f.write_text(json.dumps(rows,indent=2)+'\n')
print(json.dumps(rows[-1]));print(p.stdout.decode(errors='replace')[-3000:]);print(p.stderr.decode(errors='replace')[-3000:]);sys.exit(p.returncode)
