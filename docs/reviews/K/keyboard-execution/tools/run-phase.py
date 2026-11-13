import sys,os,subprocess,pathlib,json,datetime,hashlib
phase,cwd,*argv=sys.argv[1:];out=pathlib.Path('/workspace/work/keyboard-execution/raw')/phase;out.mkdir(exist_ok=False)
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
start=now()
with (out/'stdout').open('wb') as stdout,(out/'stderr').open('wb') as stderr:
 p=subprocess.run(argv,cwd=cwd,stdout=stdout,stderr=stderr)
record=dict(phase=phase,source_sha='c3c4642d84df57bbd9550d222ed22f602acd13ef',cwd=cwd,argv=argv,start=start,end=now(),exit=p.returncode,env={k:os.environ.get(k) for k in ['CANGJIE_STDX_PATH','CJTUI_UCD_ARCHIVE','CJTUI_K115_ARTIFACTS']},files={})
for f in sorted(out.rglob('*')):
 if f.is_file():record['files'][str(f.relative_to(out))]=dict(size=f.stat().st_size,sha256=hashlib.sha256(f.read_bytes()).hexdigest())
(out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n');(out/'manifest.json').chmod(0o444)
print(json.dumps(dict(phase=phase,exit=p.returncode,manifest=str(out/'manifest.json'))),flush=True)
sys.exit(p.returncode)
