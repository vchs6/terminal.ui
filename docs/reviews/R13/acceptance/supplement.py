exec(open('/workspace/work/dynamic-acceptance/audit.py').read().split("files=manifest(A/'artifacts.sha256',A)")[0])
reviewed=json.loads((O/'reviewed-hashes.json').read_text()); out={}
for name,root,file in [('original_red',Path('/workspace/work/dynamic-tests/evidence/red-c3d743d'),'SHA256SUMS'),('nested_red',Path('/workspace/work/dynamic-regression-tests'),'raw/SHA256SUMS'),('review_fixed',Path('/workspace/work/dynamic-review'),'scoped-r1-manifest.sha256')]:
 out[name+'_hashes']=len(manifest(root/file,root))
for p in [Path('/workspace/work/dynamic-review/report.md'),Path('/workspace/work/dynamic-review/findings.json'),Path('/workspace/work/dynamic-review/scoped-r1.md'),Path('/workspace/work/dynamic-review/scoped-r1-findings.json'),Path('/workspace/work/runtime-acceptance/report.md'),Path('/workspace/work/terminal.ui/docs/acceptance.md'),Path('/workspace/work/terminal.ui/AGENTS.md')]:read(p)
for p in Path('/workspace/work/terminal.ui/openspec/changes/implement-reactive-runtime').glob('*.md'):read(p)
for p,digest in strict(E/'evidence/sdk-ucd-sha256.json').items():assert h(p)==digest
D=strict(E/'evidence/dependency-content.json');assert D['cache']==D['clean-cache']
for cache,entries in D.items():
 for name,digest in entries.items():assert h(E/cache/'repository/source/default'/name)==digest
for name,digest in D['cache'].items():assert h(Path('/workspace/work/runtime-execution/cache/repository/source/default')/name)==digest
out['dependencies']={'files_per_cache':len(D['cache']),'fresh_clean_and_previous_equal':True,'sdk_ucd_hashes':4}
for p in strict(E/'evidence/clean-consumer-source-equality.json'):
 assert h(S/p['path'])==p['sha256']==h(E/'clean-consumers'/p['path'])
out['clean_consumer_source_files']=14
# Exact original prefix proof and final metadata projection. Never overwrite upstream originals.
(O/'metadata').mkdir(exist_ok=True);issues=strict(O/'raw/metadata-prefix-audit.json');changes=[]
for profile in ['xterm-default','xfce-vte']:
 original=E/'evidence/gui-dynamic'/profile/'q/metadata.json';meta=strict(original);new=json.loads(json.dumps(meta));delta=[]
 for issue in issues:
  if issue['profile']!=profile:continue
  p=original.parent/issue['artifact'];b=read(p);n=issue['prefix_bytes'];assert n is not None
  assert hashlib.sha256(b[:n]).hexdigest()==issue['metadata_sha256'];assert hashlib.sha256(b).hexdigest()==issue['actual_sha256']
  assert b[n:].decode()==issue['appended_text'] and 'Server terminated successfully (0)' in issue['appended_text']
  new['artifacts'][issue['artifact']]=issue['actual_sha256'];delta.append(issue)
 dest=O/'metadata'/f'{profile}-metadata.final-artifacts.json';dest.write_text(json.dumps(new,ensure_ascii=False,indent=2)+'\n')
 changed=[k for k in meta if meta[k]!=new[k]];assert changed==['artifacts']
 assert [k for k in meta['artifacts'] if meta['artifacts'][k]!=new['artifacts'][k]]==['xorg.log','xorg.stdout']
 changes.append({'profile':profile,'original_path':str(original),'original_sha256':h(original),'projection_path':str(dest.relative_to(O)),'projection_sha256':h(dest),'projected_at_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'changed_fields':['artifacts.xorg.log','artifacts.xorg.stdout'],'capture_timestamp_preserved':True,'prefix_proofs':delta})
(O/'metadata/projection-provenance.json').write_text(json.dumps(changes,indent=2)+'\n')
out['metadata_projection']={'count':2,'fields_per_projection':2,'originals_preserved':True,'exact_old_prefixes_verified':4}
(O/'raw/supplement-audit.json').write_text(json.dumps(out,indent=2)+'\n');(O/'reviewed-hashes.json').write_text(json.dumps(reviewed,indent=2)+'\n');print(json.dumps(out,indent=2))
