from pathlib import Path
import json,hashlib,datetime,shutil,re
B=Path('/workspace/work/theme-acceptance');C=B/'artifacts'
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p):return json.loads(Path(p).read_text())
def put(p,d):Path(p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
assert not C.exists(),'Never overwrite sealed evidence'
for n in ['integrity','observations','metadata']:assert load(B/'raw'/f'{n}.json')['failed']==0
for name in ['integrity','observations','metadata']:
 for ext in ['stdout','stderr']:shutil.copyfile(B/f'raw-{name}.{ext}',B/'raw'/f'{name}.{ext}')
commands={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'cwd':str(B),'product_executed':False,'commands':[{'command':'python3 '+script,'exit':0,'result':result,'result_utc':load(B/result)['utc']} for script,result in [('verify_evidence.py','raw/integrity.json'),('verify_observations.py','raw/observations.json'),('verify_metadata.py','raw/metadata.json')]],'timestamp_note':'UTC is actual verifier result timestamp, not invented process start/end. First two integrity attempts exited1 and are preserved; neither ran product.'}
put(B/'raw/commands.json',commands)
names=['report.md','findings.json','acceptance-matrix.md','acceptance-matrix.json','reviewed-hashes.json','proposed-integration.json','prepared-hashes.json','verify_evidence.py','verify_observations.py','verify_metadata.py','finalize.py','seal.py','raw/integrity-summary.json','raw/observations-summary.json','raw/metadata.json','raw/visual-inspection.json','raw/commands.json','raw/verify_evidence-attempt1.py','raw/verify_evidence-attempt2.py','raw/integrity-attempt1.stderr','raw/integrity-attempt2.stderr']
names += [str(p.relative_to(B)) for p in sorted((B/'preparation').iterdir()) if p.is_file()]
names += ['raw/'+name+'.'+ext for name in ['integrity','observations','metadata'] for ext in ['stdout','stderr']]
omitted=[]
for n in ['raw/integrity.json','raw/observations.json','raw/integrity-attempt1.json','raw/integrity-attempt2.json']:
 p=B/n;omitted.append({'path':str(p),'sha256':h(p),'bytes':p.stat().st_size,'reason':'Repeated per-file assertion lists; summary/full-result hash and runnable verifier included. Failure stderr/source preserved separately.'})
external=load(B/'reviewed-hashes.json')['external_final_inputs']
for f in external:assert h(f['path'])==f['sha256']
manifest={'task':'TASK088','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'verdict':'PASS_FOUNDATION_SCOPE','product':'8d75233c664fd61be08d441f74d464cbcdff2d9c','files':[{'source':str(B/n),'path':n,'sha256':h(B/n),'bytes':(B/n).stat().st_size} for n in names],'external_inputs':external,'local_omissions':omitted,'external_omissions':[{'path':'/workspace/work/theme-execution/artifacts','index_sha256':h('/workspace/work/theme-execution/artifacts/artifacts.sha256'),'manifest_sha256':h('/workspace/work/theme-execution/artifacts/manifest.json'),'reason':'Already sealed087 originals; PNG/native/trace/raw/source/dependency/config inventories referenced without duplicate copy.'},{'path':'/workspace/work/theme-execution/product/target/cjtui-0.0.0.cjp','sha256':'29ce7c64d16425c2a0f8350cb72d852a3e2a858fd423379bc0aad9fccd108fad','reason':'Actual175 members independently opened/hash-compared; archive/ELFs/SDK/stdx/cache/checkouts/generatedinputs not redistributed. Their1643/375/371 identities reside in087 original indexes.'}],'index_rule':'artifacts.sha256 covers all listed files plus manifest.json, excludes itself. seal-verification.json is an external receipt.'}
put(B/'manifest.json',manifest);names.append('manifest.json');C.mkdir()
for n in names:
 p=C/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(B/n,p)
index=''.join(h(C/n)+'  '+n+'\n' for n in sorted(names));(C/'artifacts.sha256').write_text(index);(B/'artifacts.sha256').write_text(index)
def strict(p):
 def pairs(items):
  d={}
  for k,v in items:
   assert k not in d;d[k]=v
  return d
 return json.loads(p.read_text(),object_pairs_hook=pairs,parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
for p in C.rglob('*.json'):strict(p)
for p in C.rglob('*.md'):
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if '://' not in target and not target.startswith('#'):assert (p.parent/target.split('#')[0]).exists(),(p,target)
for f in manifest['files']:assert h(C/f['path'])==f['sha256']==h(f['source'])
matrix=load(C/'acceptance-matrix.json');assert len(matrix['rows'])==42 and matrix['acceptance_verdict']=='PASS_FOUNDATION_SCOPE'
actual=list(p for p in C.rglob('*') if p.is_file());assert len(actual)==len(names)+1
receipt={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'verdict':'PASS_FOUNDATION_SCOPE','curated':str(C),'original_copies':len(manifest['files']),'checksum_entries':len(names),'actual_files':len(actual),'total_bytes':sum(p.stat().st_size for p in actual),'strict_json_files':len(list(C.rglob('*.json'))),'artifacts_sha256':h(C/'artifacts.sha256'),'manifest_sha256':h(C/'manifest.json'),'report_sha256':h(C/'report.md'),'failed':0}
put(B/'seal-verification.json',receipt);print(json.dumps(receipt,ensure_ascii=False,indent=2))
