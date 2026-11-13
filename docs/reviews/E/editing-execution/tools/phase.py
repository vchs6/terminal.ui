import pathlib,subprocess,sys,json,datetime,hashlib,os
B=pathlib.Path('/workspace/work/editing-execution'); name,cwd,command=sys.argv[1:4];out=B/'raw'/name;out.mkdir(exist_ok=False)
r=dict(command=command,cwd=cwd,source_sha='22ca8cf7c756c5185064a6f8bc7e9f2c58d4f167',utc_start=datetime.datetime.now(datetime.timezone.utc).isoformat())
with (out/'stdout').open('wb') as so,(out/'stderr').open('wb') as se:p=subprocess.run(['bash','-lc','source /workspace/work/editing-execution/env.sh\n'+command],cwd=cwd,stdout=so,stderr=se)
r.update(exit=p.returncode,utc_end=datetime.datetime.now(datetime.timezone.utc).isoformat());(out/'command.json').write_text(json.dumps(r,indent=2)+'\n');files={str(p.relative_to(out)):hashlib.sha256(p.read_bytes()).hexdigest() for p in out.rglob('*') if p.is_file()};(out/'index.json').write_text(json.dumps(dict(receipt=r,sha256=files),indent=2)+'\n');print(json.dumps(r));sys.exit(p.returncode)
