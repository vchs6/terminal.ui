import pathlib,json,hashlib,datetime,shutil,subprocess,re
B=pathlib.Path('/workspace/work/session-extension-execution');C=B/'curated-r18-execution'
H=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
now=datetime.datetime.now(datetime.timezone.utc).isoformat()
# Enumerate retained finite evidence, never traverse any external credential directory.
keep=[B/'report.md',B/'findings.json',B/'results.json']
for name in ['scope','raw','scripts']:
 keep.extend(p for p in (B/name).rglob('*') if p.is_file() and '__pycache__' not in p.parts and p.suffix!='.pyc')
for p in keep:
 assert not p.is_symlink(),p
 assert p.read_bytes()[:4]!=b'\x7fELF',p
 assert p.suffix.lower() not in ['.cjp','.cjo','.o','.a','.so','.pyc'],p
 assert not any(x in p.parts for x in ['private','node_modules','.git']),p
entries=[{'path':str(p.relative_to(B)),'sha256':H(p),'size':p.stat().st_size,'source':str(p),'reason':'Original finite TASK151 evidence/report/script; retained bytes unchanged'} for p in sorted(keep)]
omitted=[]
def omission(source,sha,reason,kind='sha256'):
 omitted.append({'source':source,'hash':sha,'hashKind':kind,'reason':reason,'retained':False})
for label in ['source','clean-extract']:
 base=B/label
 # The complete filesystem omission inventory is hashes only, not copied checkout/artifacts.
 inventory=[]
 for p in sorted(base.rglob('*')):
  if not p.is_file() or '.git' in p.relative_to(base).parts:continue
  inventory.append({'path':str(p.relative_to(base)),'sha256':H(p),'size':p.stat().st_size})
 target=B/'scope'/f'omitted-{label}-files.json';target.write_text(json.dumps({'source':str(base),'files':inventory,'reason':'Whole checkout/extraction and compiled artifacts are local execution material, not curated'},indent=2))
 omission(str(base),H(target),'Full source/extracted package + generated ELF/CJO/native build output omitted; complete file hash map is scope/'+target.name,'inventory-sha256')
 entries.append({'path':str(target.relative_to(B)),'sha256':H(target),'size':target.stat().st_size,'source':str(target),'reason':'Hash-only omission inventory'})
for p in [B/'source/target/cjtui-0.0.0.cjp',B/'source/tests/session_extensions/target/release/bin/main',B/'clean-extract/cjtui-0.0.0/examples/session/target/release/bin/main']:
 omission(str(p),H(p),'Actual original CJP or ELF is external, identified by content hash, not committed')
for name in ['sdk','seed']:
 p=B/'scope'/f'{name}-files.json';data=json.loads(p.read_text());omission(data['source'],H(p),'External '+name+' directory omitted; complete file hashes retained in scope/'+p.name,'inventory-sha256')
for base in sorted(B.glob('cache-*')):
 inventory=[]
 for p in sorted(base.rglob('*')):
  if p.is_file():inventory.append({'path':str(p.relative_to(base)),'sha256':H(p),'size':p.stat().st_size})
 target=B/'scope'/('omitted-'+base.name+'.json');target.write_text(json.dumps({'source':str(base),'files':inventory,'reason':'Private writable dependency/build cache omitted'},indent=2))
 omission(str(base),H(target),'Private cache omitted; hash-only inventory '+str(target.relative_to(B)),'inventory-sha256')
 entries.append({'path':str(target.relative_to(B)),'sha256':H(target),'size':target.stat().st_size,'source':str(target),'reason':'Hash-only omission inventory'})
omission(str(B/'preparation-notes.md'),H(B/'preparation-notes.md'),'Pre-admission read-only note remains external; final report records admitted execution')
manifest={'task':'TASK151','utcAfterHostExit':now,'curatedRoot':str(C),'files':sorted(entries,key=lambda x:x['path']),'omitted':omitted,'externalCredentialPolicy':'SSH private keys are never read/copied/hashed/enumerated; existing path-only handoff is used by stock SSH. No private credential artifact is present.','curatedBinaryReferences':'Host manifests retain original execution layout for audit; ELF omitted by explicit source/hash map. Re-running host oracle requires the marked original external binary.','originalReportSha256':H(B/'report.md')}
(B/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
C.mkdir(exist_ok=False)
for x in entries:
 p=B/x['path'];dest=C/x['path'];dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dest);assert H(dest)==x['sha256']
shutil.copyfile(B/'manifest.json',C/'manifest.json')
# Markdown links must resolve within the finite retained tree; no renamed reports or removed checkout links.
for p in C.rglob('*.md'):
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if target.startswith(('https://','http://','#','mailto:')):continue
  target=target.split('#')[0]
  assert (p.parent/target).exists(),(p,target)
files=sorted(p for p in C.rglob('*') if p.is_file())
for p in files:
 assert p.read_bytes()[:4]!=b'\x7fELF',p
 assert not p.is_symlink(),p
assert H(C/'report.md')==H(B/'report.md')
lines=[H(p)+'  '+str(p.relative_to(C)) for p in files]
(C/'artifacts.sha256').write_text('\n'.join(lines)+'\n');shutil.copyfile(C/'artifacts.sha256',B/'artifacts.sha256')
print(json.dumps({'curated':str(C),'filesBeforeHashFile':len(files),'reportOriginalByteMatch':True,'elfCjpCjoCacheSdkPrivateKeysIncluded':False,'markdownLinksResolved':True,'utc':now}))
