from pathlib import Path
import subprocess,json,hashlib,datetime
root=Path('/workspace/work/theme-glyph-tests/source')
base='b3b24f896672336797cec009cfe0cd830a955aa7'
out=Path('/workspace/work/theme-glyph-tests/raw')
hash=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
files=subprocess.check_output(['git','ls-tree','-r','--name-only',base,'--','tests/themes'],cwd=root,text=True).splitlines()
original=[]
for name in files:
    before=subprocess.check_output(['git','show',base+':'+name],cwd=root)
    after=(root/name).read_bytes()
    if before!=after:raise RuntimeError('original085 changed '+name)
    original.append({'path':name,'sha256':hash(root/name),'unchanged':True})
(out/'original085-preservation.json').write_text(json.dumps(original,indent=2)+'\n')
fixtures=[]
for p in sorted((root/'tests/themes/fixtures').glob('*.toml')):
    fixtures.append({'path':str(p.relative_to(root)),'bytes':p.stat().st_size,'sha256':hash(p)})
(out/'preset-fixtures.json').write_text(json.dumps(fixtures,indent=2)+'\n')
manifest={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'base':base,
 'test_sha':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),
 'raw':{str(p.relative_to(out)):hash(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='manifest.json'}}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('original085 files unchanged:',len(original))
print('negative fixtures:',len(list((root/'tests/themes/negative').glob('*.cj.txt'))))
print('raw manifest sha256:',hash(out/'manifest.json'))
