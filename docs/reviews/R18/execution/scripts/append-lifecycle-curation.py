"""Append only new lifecycle evidence; preserve first sealed manifest/report externally."""
import pathlib,json,hashlib,datetime,shutil,re
from PIL import Image
B=pathlib.Path('/workspace/work/session-extension-execution');C=B/'curated-r18-execution'
H=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
old=json.loads((B/'initial/manifest.json').read_text());cur=json.loads((B/'manifest.json').read_text())
assert old==cur,'supplement must start from original sealed manifest'
initial=json.loads((B/'initial/snapshot.json').read_text())
for x in initial['files']:assert H(B/'initial'/x['name'])==x['sha256']
changed={'report.md','results.json','findings.json'}
for x in old['files']:
 if x['path'] not in changed:assert H(B/x['path'])==x['sha256'],x['path']
meta=json.loads((B/'raw/lifecycle-hosts/verification.json').read_text());assert meta['allAssertionsPassed'] and len(meta['cases'])==3
summary=json.loads((B/'raw/lifecycle-hosts/summary.json').read_text());assert summary['xorgExit']==0 and summary['displaySocketRemoved']
pngs=[]
for scenario in ['ledger-close','ledger-error','ledger-cancel']:
 p=B/'raw/lifecycle-hosts'/scenario
 for item in json.loads((p/'captures.json').read_text()):
  image=p/item['png'];assert H(image)==item['pngSha256']
  with Image.open(image) as im:assert im.size==(1004,536);im.verify()
  pngs.append(str(image.relative_to(B)))
assert len(pngs)==8
by={x['path']:x for x in old['files']}
extra=[B/x for x in changed]+[B/'scope/lifecycle-supplement.json',B/'initial/snapshot.json',B/'initial/README.md',B/'scripts/lifecycle-hosts.py',B/'scripts/verify-lifecycle.mjs',B/'scripts/append-lifecycle-curation.py']
for folder in ['raw/lifecycle-hosts','raw/lifecycle-host-launch','raw/lifecycle-verify']:
 extra.extend(p for p in (B/folder).rglob('*') if p.is_file())
for p in extra:
 assert not p.is_symlink() and p.read_bytes()[:4]!=b'\x7fELF',p
 assert p.suffix.lower() not in ['.cjp','.cjo','.o','.a','.so','.pyc'],p
 rel=str(p.relative_to(B));by[rel]={'path':rel,'source':str(p),'sha256':H(p),'size':p.stat().st_size,'reason':'TASK151 actual XTerm automatic lifecycle supplement, revised execution report, or original-byte snapshot index'}
# New manifest distinguishes first sealed provenance from the later supplement.
new={**old,'utcAfterHostExit':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':sorted(by.values(),key=lambda x:x['path']),'originalReportSha256':H(B/'report.md'),'firstSealedManifestSha256':H(B/'initial/manifest.json'),'firstSealedReportSha256':H(B/'initial/report.md'),'firstSealedArtifactHashesSha256':H(B/'initial/artifacts.sha256'),'supplement':'scope/lifecycle-supplement.json','independentAcceptance':'Pending TASK152 judgment','finalizedUtc':datetime.datetime.now(datetime.timezone.utc).isoformat()}
for x in initial['files']:
 new['omitted'].append({'source':str(B/'initial'/x['name']),'hash':x['sha256'],'hashKind':'sha256','reason':'Immutable first sealed original preserved externally; only exact-hash index curated. Original report Markdown links use its original base, so use the accurate initial/README.md wrapper.','retained':False})
for x in by.values():
 p=B/x['path'];assert H(p)==x['sha256'],x['path'];q=C/x['path'];q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q);assert H(q)==x['sha256']
(B/'manifest.json').write_text(json.dumps(new,ensure_ascii=False,indent=2));shutil.copyfile(B/'manifest.json',C/'manifest.json')
for p in C.rglob('*.md'):
 for t in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if t.startswith(('https://','http://','#','mailto:')):continue
  assert (p.parent/t.split('#')[0]).exists(),(p,t)
files=sorted(p for p in C.rglob('*') if p.is_file() and p.name!='artifacts.sha256')
for p in files:assert not p.is_symlink() and p.read_bytes()[:4]!=b'\x7fELF',p
(C/'artifacts.sha256').write_text('\n'.join(H(p)+'  '+str(p.relative_to(C)) for p in files)+'\n');shutil.copyfile(C/'artifacts.sha256',B/'artifacts.sha256')
# No files are written after final hashes. These are completion observations only.
print(json.dumps({'utc':new['finalizedUtc'],'curatedFilesIncludingHashFile':len(files)+1,'manifestEntries':len(by),'initialOriginalBytesUnchanged':True,'newLifecycleCases':3,'newPngCount':len(pngs),'totalPngCount':64,'reportSha256':H(B/'report.md'),'manifestSha256':H(B/'manifest.json'),'artifactsSha256':H(C/'artifacts.sha256'),'independentAcceptance':'pending TASK152'}))
