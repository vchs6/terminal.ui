import json,pathlib,subprocess,sys,hashlib
base=pathlib.Path('/workspace/work/widgets-small-tests/contract-fix/evidence');name,cwd,command=sys.argv[1:4]
p=subprocess.run(['bash','-c',command],cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
raw={}
for label,data in [('stdout',p.stdout),('stderr',p.stderr)]:
 f=base/'raw'/(name+'.'+label);f.write_bytes(data);raw[label]={'path':str(f),'sha256':hashlib.sha256(data).hexdigest()}
f=base/'commands.json';rows=json.loads(f.read_text()) if f.exists() else [];row={'name':name,'cwd':cwd,'command':command,'exit':p.returncode,'raw':raw};rows.append(row);f.write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(row));print(p.stdout.decode(errors='replace')[-1500:]);print(p.stderr.decode(errors='replace')[-2000:]);sys.exit(p.returncode)
