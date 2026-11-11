from pathlib import Path
import json,hashlib,datetime
B=Path('/workspace/work/viewport-execution');H=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();row=lambda p:{'path':str(p.relative_to(B)),'bytes':p.stat().st_size,'sha256':H(p)}
# Reference only: never copy built binaries, package, runtime or VM closure into archive.
external=[]
for root in [B/'product',B/'clean-consumer']:
 for p in root.glob('**/target/release/bin/*'):
  if p.is_file():external.append(row(p))
 for p in root.glob('**/*.cjp'):
  if p.is_file():external.append(row(p))
for p in list((B/'packages').glob('*'))+list((B/'tools').glob('*.so'))+[B/'tools/vt-supervisor']+list((B/'raw').glob('**/guest-evidence.tar')):
 if p.is_file():external.append(row(p))
(B/'omitted-artifacts.json').write_text(json.dumps({'external_artifacts':external,'shared_dependencies':'raw/identity/dependencies-pre.json and dependencies-post.json bind375 source files and371 official stdx files; pre-environment binds SDK/compiler/cjpm/config/UCD. No SDK/cache/source-tree copies.','cache_generated_and_duplicate_export':'HOME/cache, __pycache__, guest-evidence.tar, ELF/.so/CJP/VM image remain external, original hashes retained; extracted guest evidence and serial original remain indexed.'},indent=2)+'\n')
files=[]
for root in [B/'raw',B/'tools']:
 for p in sorted(root.rglob('*')):
  if not p.is_file() or p.is_symlink():continue
  parts=p.relative_to(B).parts
  if '__pycache__' in parts or ('home' in parts and 'cache' in parts) or p.suffix in ['.so','.pyc'] or p.name in ['vt-supervisor','guest-evidence.tar']:continue
  files.append(row(p))
for name in ['report.md','findings.json','scope.json','omitted-artifacts.json','env.sh','cangjie-repo.toml']:
 files.append(row(B/name))
d={'source':'62039552a26da295dcd710d7cfc40cb9e43ca5fd','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'result':'PASS_SCOPED_EXECUTION','original_files':files,'no_copied_curated_tree':True,'stable_results':'raw/identity/completed-commands.json','host_mapping':'raw/identity/host-index.json','case_mapping':'scope.json','package_and_consumer':'raw/package','external_artifacts':'omitted-artifacts.json'}
(B/'manifest.json').write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
for r in files:assert H(B/r['path'])==r['sha256'],r['path']
(B/'artifacts.sha256').write_text(''.join(f'{H(B/n)}  {n}\n' for n in ['manifest.json','report.md','scope.json','findings.json','omitted-artifacts.json']))
print('manifest',H(B/'manifest.json'),'files',len(files),'bytes',sum(x['bytes'] for x in files));print('report',H(B/'report.md'));print('artifacts',H(B/'artifacts.sha256'))
