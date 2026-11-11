from pathlib import Path
import json,hashlib,datetime,subprocess
B=Path('/workspace/work/interaction-execution');R=B/'product';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();omitted=[]
# Keep original full VM files; select a byte-exact native prefix instead of duplicating tar/base64 payloads.
for serial in (B/'raw').glob('vt-hosts*/*/vt-serial.log'):
 data=serial.read_bytes();marker=data.find(b'EVIDENCE_TAR_BASE64_BEGIN')
 if marker>=0:
  out=serial.parent/'serial-native-prefix.txt'
  if not out.exists():out.write_bytes(data[:marker])
  identity=serial.parent/'serial-original-identity.json'
  if not identity.exists():identity.write_text(json.dumps({'path':str(serial.relative_to(B)),'sha256':h(serial),'bytes':len(data),'native_prefix_end_offset':marker,'omission':'base64 repeats extracted pure evidence; full original retained'},indent=2)+'\n')
# All original files are indexed in place: no duplicate archive or checkout materialization.
selected=[B/'report.md',B/'findings.json',B/'scope.json']
for root in [B/'raw',B/'tools']:
 for p in root.rglob('*'):
  if not p.is_file() or p.is_symlink() or '__pycache__' in p.parts:continue
  rel=p.relative_to(B)
  with p.open('rb') as f:magic=f.read(4)
  skip=magic==b'\x7fELF' or p.suffix in ['.o','.so','.a','.cjo','.bc','.cjp','.tar'] or p.name=='vt-serial.log'
  if root.name=='tools' and p.suffix not in ['.py','.c','.sh']:skip=True
  if skip:omitted.append({'path':str(rel),'bytes':p.stat().st_size,'sha256':h(p),'reason':'binary or duplicate fullVM payload/container; original retained outside curated file set'})
  else:selected.append(p)
for root in [R,B/'clean-consumer',B/'packages']:
 for p in root.rglob('*'):
  if not p.is_file() or p.is_symlink() or '.git' in p.parts:continue
  if p.suffix in ['.o','.so','.a','.cjo','.bc','.cjp','.gz'] or 'target' in p.parts or 'build-script-cache' in p.parts:
   omitted.append({'path':str(p.relative_to(B)),'bytes':p.stat().st_size,'sha256':h(p),'reason':'external generated native/build/deploy artifact; source/command/identity retained, not included in A archive'})
excluded=B/'omitted-artifacts.json';excluded.write_text(json.dumps({'generated_or_duplicate_originals':omitted,'already_cleaned_own_intermediates':'raw/staging/*-cleanup.json records each removed hash','other_exclusions':'whole source checkout/SDK/cache/upstream source and Markdown snapshots omitted; fixedgit source hashes and prior dependency inventories referenced; no private keys read'},indent=2)+'\n');selected.append(excluded)
assert subprocess.check_output(['git','status','--short'],cwd=R,text=True)==''
files=[{'path':str(p.relative_to(B)),'bytes':p.stat().st_size,'sha256':h(p)} for p in sorted(set(selected))]
m={'task':'TASK101','source':'f8a028b39daf8a341576f304335d262544b9cca5','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'result':'PASSED_CURRENT_A_EXECUTION_SCOPE','delivery':'stable minimal original-file inventory; no duplicate wholeA archive; root archives once after102','files':files,'out_of_scope':'TASK102/wholeLinux/Keyboard7/B/C/fullwidgets/M2/release acceptance'}
(B/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');checksum=''.join(row['sha256']+'  '+row['path']+'\n' for row in files);checksum+=h(B/'manifest.json')+'  manifest.json\n';(B/'artifacts.sha256').write_text(checksum)
for p in set(selected)|{B/'manifest.json',B/'artifacts.sha256'}:p.chmod(0o444)
print('Stable inventory',len(files),'files',sum(x['bytes'] for x in files),'bytes; external identities',len(omitted));print('manifest',h(B/'manifest.json'));print('report',h(B/'report.md'))
