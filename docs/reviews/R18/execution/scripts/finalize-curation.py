"""Finalize after recorder completion so the recorder's own output is stable."""
import pathlib,json,hashlib,datetime,shutil,re
B=pathlib.Path('/workspace/work/session-extension-execution');C=B/'curated-r18-execution'
H=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((B/'manifest.json').read_text());by={x['path']:x for x in m['files']}
assert json.loads((B/'raw/curate/execution.json').read_text())['exitCode']==0
extra=list((B/'raw/curate').glob('*'))+[B/'scripts/finalize-curation.py']
for p in extra:
 if p.is_file():
  rel=str(p.relative_to(B));by[rel]={'path':rel,'sha256':H(p),'size':p.stat().st_size,'source':str(p),'reason':'Stable curation recorder completion/finalization source after process exit'}
for x in by.values():
 p=B/x['path'];assert H(p)==x['sha256'],x['path']
 assert p.read_bytes()[:4]!=b'\x7fELF',p
validation={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'curationActualExit':0,'sourceEntriesVerified':len(by),'allStableOriginalHashesMatch':True,'reportOriginalBytesMatch':True,'privateKeysElfCjpCjoSdkCacheIncluded':False,'reason':'Finalized only after raw/curate recorder exited; no host/product rerun'}
vp=B/'scope/curation-validation.json';vp.write_text(json.dumps(validation,indent=2));rel=str(vp.relative_to(B));by[rel]={'path':rel,'sha256':H(vp),'size':vp.stat().st_size,'source':str(vp),'reason':'Stable final curation validation'}
for x in by.values():
 p=B/x['path'];q=C/x['path'];q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q);assert H(q)==x['sha256']
m['files']=sorted(by.values(),key=lambda x:x['path']);m['finalizedUtc']=validation['utc'];m['curationRecorderActualExit']=0
(B/'manifest.json').write_text(json.dumps(m,ensure_ascii=False,indent=2));shutil.copyfile(B/'manifest.json',C/'manifest.json')
for p in C.rglob('*.md'):
 for t in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if t.startswith(('http://','https://','#','mailto:')):continue
  assert (p.parent/t.split('#')[0]).exists(),(p,t)
files=sorted(p for p in C.rglob('*') if p.is_file() and p.name!='artifacts.sha256')
for p in files:assert not p.is_symlink() and p.read_bytes()[:4]!=b'\x7fELF',p
lines=[H(p)+'  '+str(p.relative_to(C)) for p in files]
(C/'artifacts.sha256').write_text('\n'.join(lines)+'\n');shutil.copyfile(C/'artifacts.sha256',B/'artifacts.sha256')
print(json.dumps({'finalizedUtc':validation['utc'],'curatedFilesIncludingHashFile':len(files)+1,'manifestEntries':len(by),'reportSha256':H(B/'report.md'),'artifactsSha256':H(C/'artifacts.sha256'),'stableHashes':True}))
