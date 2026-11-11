from pathlib import Path
import shutil,json,hashlib,datetime
B=Path('/workspace/work/glyph-execution');C=B/'curated-r16-execution';C.mkdir(exist_ok=False);rows=[];omitted=[]
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def cp(src,rel):
 dst=C/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst);assert src.read_bytes()==dst.read_bytes();rows.append({'source':str(src),'curated':str(rel),'sha256':digest(dst),'size':dst.stat().st_size})
for name in ['report.md','findings.json','scope.json','preparation-notes.md','execution-ledger.md']:cp(B/name,Path(name))
for base in ['raw','tools']:
 for p in sorted((B/base).rglob('*')):
  if not p.is_file():continue
  rel=p.relative_to(B)
  if '__pycache__' in p.parts or 'node_modules' in p.parts or 'home' in p.parts or p.suffix in ['.so','.a','.o','.cjo','.cjp','.tar','.pyc'] or p.name.endswith('.cpio.gz'):
   omitted.append({'source':str(p),'sha256':digest(p),'size':p.stat().st_size,'reason':'duplicate archive/cache/binary/development-home omitted'});continue
  if p.read_bytes()[:4]==b'\x7fELF':raise AssertionError('Unexpected ELF '+str(p))
  cp(p,rel)
for rel in ['host-consumer/src/main.cj','host-consumer/cjpm.toml','host-consumer/cangjie-repo.toml']:
 cp(B/rel,Path('consumer-source')/Path(rel).relative_to('host-consumer'))
for p in (B/'packages').glob('*'):
 if p.is_file():omitted.append({'source':str(p),'sha256':digest(p),'size':p.stat().st_size,'reason':'self-owned VM initramfs input, omitted binary environment; per-file guest manifests retained'})
manifest={'task':'TASK096','curatedUtc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'product':'1f67e27358254e9daef637b5c2f5a93707ee7cef','integration':'b3b24f896672336797cec009cfe0cd830a955aa7','sourceToCurated':rows,'omitted':omitted,'omittedInputInventory':'raw/fixed-inputs-and-binaries.json','sourceInventory':'raw/source-inventory.json','note':'No ELF/CJP/CJO/SDK/cache/whole checkout/private key/whole original Markdown source copied. Only own reports/notes and execution fixture scripts plus raw evidence. Manifest and checksum index are envelope files, not recursive self-hash.'}
(C/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
files=sorted(p for p in C.rglob('*') if p.is_file());(C/'artifacts.sha256').write_text(''.join(digest(p)+'  '+str(p.relative_to(C))+'\n' for p in files))
(B/'manifest.json').write_text(json.dumps({'curated':str(C),'files':len(files),'sourceCopies':len(rows),'omittedInputs':len(omitted),'manifestSha256':digest(C/'manifest.json'),'artifactsSha256':digest(C/'artifacts.sha256'),'product':manifest['product'],'integration':manifest['integration']},indent=2))
shutil.copy2(C/'artifacts.sha256',B/'artifacts.sha256')
for row in rows:assert digest(Path(row['source']))==row['sha256'] and digest(C/row['curated'])==row['sha256']
for line in (C/'artifacts.sha256').read_text().splitlines():h,name=line.split(None,1);assert digest(C/name.strip())==h
print('curated payload files',len(rows),'envelope-indexed files',len(files),'omitted',len(omitted),'allsourcecopy/hash verified');print('artifacts SHA256',digest(C/'artifacts.sha256'))
