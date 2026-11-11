from pathlib import Path
import os,subprocess,json,datetime
root=Path('/workspace/work/theme-glyph-tests/source')
logs=Path('/workspace/work/theme-glyph-tests/raw/remaining')
logs.mkdir(exist_ok=True)
sha=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
for name,folder in [('theme-target-build','glyph-target'),('theme-session-build','glyph-session')]:
    cwd=root/'tests/themes'/folder
    utc=datetime.datetime.now(datetime.timezone.utc).isoformat()
    result=subprocess.run(['cjpm','build'],cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    (logs/(name+'.stdout')).write_bytes(result.stdout)
    (logs/(name+'.stderr')).write_bytes(result.stderr)
    with (logs/'commands.jsonl').open('a') as stream:
        stream.write(json.dumps(dict(name=name,utc=utc,sha=sha,cwd=str(cwd),argv=['cjpm','build'],exit=result.returncode))+'\n')
    print(name,'exit',result.returncode,flush=True)
