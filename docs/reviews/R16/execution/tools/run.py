import sys,subprocess,pathlib,json,datetime,os
base=pathlib.Path('/workspace/work/glyph-execution');label,cwd,cmd=sys.argv[1:]
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
p=base/'raw'/label;p.mkdir(parents=True,exist_ok=False)
meta={'command':cmd,'cwd':cwd,'start_utc':now()};(p/'meta.json').write_text(json.dumps(meta,indent=2))
env=os.environ.copy();env['CJTUI_UCD_ARCHIVE']='/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip';env['CJTUI_GLYPH_FILES']=str(base/'raw/logical-files');env['CJTUI_GLYPH_ARTIFACTS']=str(base/'raw/glyph-session');pathlib.Path(env['CJTUI_GLYPH_FILES']).mkdir(exist_ok=True)
with (p/'stdout.log').open('wb') as out,(p/'stderr.log').open('wb') as err:
 r=subprocess.run(['bash','-c','source /workspace/work/validation/sdk/cangjie/envsetup.sh\n'+cmd],cwd=cwd,env=env,stdout=out,stderr=err)
meta.update(end_utc=now(),exit=r.returncode);(p/'meta.json').write_text(json.dumps(meta,indent=2));print(label,'EXIT',r.returncode,flush=True)
for f in ['stdout.log','stderr.log']:
 print(f, (p/f).read_text(errors='replace')[-1800:])
sys.exit(r.returncode)
