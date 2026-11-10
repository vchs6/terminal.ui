from pathlib import Path
import subprocess,json,hashlib
b=Path('/workspace/work/runtime-execution');s=b/'r019-source';p=b/'r019-clean/cjtui-0.0.0'
files=subprocess.check_output(['git','-C',str(s),'ls-files','src','native'],text=True).splitlines();missing=[];diff=[];omitted=[]
for name in files:
 x=s/name;y=p/name
 if name=='src/.gitkeep' and not y.exists():omitted.append(name);continue
 if not y.is_file():missing.append(name)
 elif x.read_bytes()!=y.read_bytes():diff.append(name)
assert not missing and not diff
archive=s/'target/cjtui-0.0.0.cjp'
r={'candidate':subprocess.check_output(['git','-C',str(s),'rev-parse','HEAD'],text=True).strip(),'archiveOriginalPath':str(archive),'archiveSha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'productRoot':str(p),'srcNativeFileCount':len(files)-len(omitted),'omittedNonSourcePlaceholders':omitted,'missing':missing,'different':diff,'productTargetCacheCopied':False,'scope':'ordinary clean SDK native/root build/check plus unchanged packaged public reactive example'}
(b/'r019-evidence/clean-source-comparison.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
