import sys,pathlib,subprocess,json,datetime,os
b=pathlib.Path('/workspace/work/session-extension-execution')
name,cwd,command=sys.argv[1:4]
p=b/'raw'/name;p.mkdir(exist_ok=False)
meta={'command':command,'cwd':cwd,'utcStart':datetime.datetime.now(datetime.timezone.utc).isoformat()}
(p/'command.json').write_text(json.dumps(meta,indent=2))
env=os.environ.copy();env['CJTUI_UCD_ARCHIVE']='/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip'
env['CJTUI_SESSION_ARTIFACTS']=str(b/'raw/session-matrix')
with (p/'stdout').open('wb') as out,(p/'stderr').open('wb') as err:
 r=subprocess.run(['bash','-c','source /workspace/work/validation/sdk/cangjie/envsetup.sh\n'+command],cwd=cwd,env=env,stdout=out,stderr=err)
meta.update(exitCode=r.returncode,utcEnd=datetime.datetime.now(datetime.timezone.utc).isoformat())
(p/'execution.json').write_text(json.dumps(meta,indent=2));(p/'exit').write_text(str(r.returncode)+'\n')
print(json.dumps(meta),flush=True)
sys.exit(r.returncode)
