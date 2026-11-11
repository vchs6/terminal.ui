from pathlib import Path
import json,hashlib,shutil,datetime,re
B=Path('/workspace/work/glyph-acceptance');C=B/'curated-r16-acceptance'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def put(p,d):Path(p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
def strict(p):
 def obj(pairs):
  d={}
  for k,v in pairs:
   if k in d:raise ValueError('duplicate '+k)
   d[k]=v
  return d
 return json.loads(Path(p).read_text(),object_pairs_hook=obj,parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
assert not C.exists(),'Refuse to overwrite sealed directory'
names=['report.md','findings.json','acceptance-matrix.md','acceptance-matrix.json','reviewed-hashes.json','proposed-integration.json','preparation.md','preparation-findings.json','pending-matrix.md','pending-matrix.json','preparation-hashes.json','prepare.mjs','verify_integrity.py','verify_hosts.py','verify_oracles.mjs','finalize.py','seal.py','README.md']
names += [str(p.relative_to(B)) for p in sorted((B/'raw').iterdir()) if p.is_file()]
for n in names:assert (B/n).is_file(),n
for n in names:
 if n.endswith('.json'):strict(B/n)
matrix=strict(B/'acceptance-matrix.json');assert len(matrix['rows'])==33
assert matrix['status_counts']=={'passed':30,'passed_finite_subset':1,'interface_passed_layout_pending':1,'parent_scope_pending':1}
assert strict(B/'findings.json')['verdict']=='PASS_FINITE_SCOPE'
prep=strict(B/'preparation-hashes.json')
for item in prep['source_files']:assert sha(B/'source'/item['path'])==item['sha256']
external=strict(B/'reviewed-hashes.json')['external_reports_and_indexes']
for item in external:assert sha(item['path'])==item['sha256']
manifest={'task':'TASK097','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'verdict':'PASS_FINITE_SCOPE','source_copy_policy':'Only acceptance-owned reports/scripts/results/historical preparation; no product/source tree, SDK, ELF, CJP, cache or author reports.','copied_files':[{'source':str(B/n),'curated':n,'bytes':(B/n).stat().st_size,'sha256':sha(B/n)} for n in names],'external_inputs':external,'omitted':[{'path':str(B/'source'),'reason':'Fixed Git local analysis copy; exact145 hashes in preparation/reviewed-hashes plus 3 Session oracle hashes in raw/oracle-verification. Recreate from stated commits, not archived as a workspace.'},{'path':'/workspace/work/glyph-execution','reason':'Independent096 already publicly archived at docs/reviews/R16/execution; all1389 source copies verified. Original PNG/native/trace/config/source/binaries available through its fixed manifest/index; no duplicated SDK/cache/CJP/ELF.'}],'retained_failures':'raw/*attempt1* contain original097 helper failures. Historical preparation pending state is not current verdict. 096 original failures remain in external immutable096 archive.','index_rule':'artifacts.sha256 covers listed copies plus hash-manifest.json; excludes itself. Root artifacts.sha256 is exact copy of curated index.'}
put(B/'hash-manifest.json',manifest)
names+=['hash-manifest.json']
C.mkdir()
for n in names:
 dst=C/n;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(B/n,dst)
idx=''.join(sha(C/n)+'  '+n+'\n' for n in sorted(names))
(C/'artifacts.sha256').write_text(idx);(B/'artifacts.sha256').write_text(idx)
for p in C.rglob('*.json'):strict(p)
for p in C.rglob('*.md'):
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if '://' not in target and not target.startswith('#'):assert (p.parent/target.split('#')[0]).exists(),(p,target)
for item in manifest['copied_files']:assert sha(C/item['curated'])==sha(item['source'])==item['sha256']
assert len(list(p for p in C.rglob('*') if p.is_file()))==len(names)+1
summary={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'verdict':'PASS_FINITE_SCOPE','curated':str(C),'copied_own_files':len(manifest['copied_files']),'checksum_entries':len(names),'actual_files':len(names)+1,'artifacts_sha256':sha(C/'artifacts.sha256'),'hash_manifest_sha256':sha(C/'hash-manifest.json'),'report_sha256':sha(C/'report.md'),'strict_json_files':len(list(C.rglob('*.json'))),'failures':0,'wrapper_note':'This seal-verification.json is an external handoff receipt, not inside the curated archive; every curated file is indexed except the index itself.'}
put(B/'seal-verification.json',summary)
print(json.dumps(summary,ensure_ascii=False,indent=2))
