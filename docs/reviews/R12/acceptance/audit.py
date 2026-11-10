from pathlib import Path
import hashlib,json,subprocess,tarfile,datetime
out=Path('/workspace/work/runtime-acceptance'); repo=Path('/workspace/work/terminal.ui'); ex=Path('/workspace/work/runtime-execution/r12-execution-draft')
def sha(b):return hashlib.sha256(b).hexdigest()
def git(*a):return subprocess.check_output(['git','-C',str(repo),*a])
def dump(n,x):(out/n).write_text(json.dumps(x,indent=2,ensure_ascii=False)+'\n')
checks={}; consumed={}
def digest(p):
 b=p.read_bytes();consumed[str(p)]=sha(b);return sha(b)
# Every execution artifact independently validated.
rows=[]
for l in (ex/'artifacts.sha256').read_text().splitlines():
 h,p=l.split(None,1); p=p.lstrip('*'); actual=digest(ex/p); rows.append({'path':p,'match':h==actual})
assert all(x['match'] for x in rows)
checks['execution_manifest']={'count':len(rows),'all_match':True,'sha256':digest(ex/'artifacts.sha256')}
# Independent review and independent test supplement archive originals and copies.
for sub in ['code-review','test-supplements']:
 p=repo/'docs/reviews/R12'/sub/'archive-index.json'; idx=json.loads(p.read_text()); rr=[]
 for e in idx['files']:
  copy=repo/e['copy']; original=Path(e['original']); rr.append({'copy':e['copy'],'copy_matches':digest(copy)==e['sha256'],'original_exists':original.exists(),'original_matches':digest(original)==e['sha256'] if original.exists() else False})
 assert all(x['copy_matches'] and x['original_matches'] for x in rr)
 dump('raw/'+sub+'-original-audit.json',rr);checks[sub+'_originals']={'count':len(rr),'all_match':True,'index_sha256':digest(p)}
# Original initial test files were archived without rewriting.
p=repo/'docs/reviews/R12/test-design'; rr=[]
for f in p.rglob('*'):
 if not f.is_file():continue
 rel=f.relative_to(p); src=Path('/workspace/work/runtime-tests')/rel
 if src.exists():rr.append({'path':str(rel),'matches':digest(f)==digest(src)})
assert all(x['matches'] for x in rr);checks['initial_test_originals']={'count':len(rr),'all_match':True}
# Fixed git content, source inventories and reuse.
cand=git('rev-parse','0912436').decode().strip(); old=git('rev-parse','c3d743d').decode().strip(); tests=git('rev-parse','6d703bf').decode().strip();head=git('rev-parse','HEAD').decode().strip()
prod=['src','native','build.cj','cjpm.toml','examples/reactive']
changed=git('diff','--name-only',old,cand,'--',*prod).decode().splitlines();assert changed==['native/cjtui_terminal.c','src/application.cj','src/terminal_bridge.cj']
assert not git('diff',cand,head,'--',*prod)
assert not git('diff','dddbdd9',tests,'--','tests/runtime','tests/resize-coherence','tests/support','tests/application-lifecycle','tests/integration')
assert not git('diff',old,cand,'--','tests/runtime')
checks['content']={'candidate':cand,'tests_through':tests,'executor_tests':git('rev-parse','dddbdd9').decode().strip(),'current_head':head,'current_product_equal':True,'test_scope_equal':True,'c3_to_candidate_changed_product':changed}
inv=json.loads((ex/'evidence/c3/source-inventory.json').read_text()); bad=[]
for p,h in inv['files'].items():
 if sha(git('show',old+':'+p))!=h:bad.append(p)
assert not bad;checks['c3_source_inventory']={'count':len(inv['files']),'all_match':True}
# Actual normal source cjp and extracted clean source verified against fixed blobs.
archive=Path('/workspace/work/runtime-execution/r019-source/target/cjtui-0.0.0.cjp');archivehash=digest(archive);assert archivehash=='045d4030cc461922a91a207a0bd268e610fcc52175c753dfcd39a6757ba9465d'
with tarfile.open(archive) as t:
 files={m.name:m for m in t.getmembers() if m.isfile()}; root=next(iter(files)).split('/')[0]; count=0
 for p in git('ls-tree','-r','--name-only',cand,'--',*prod).decode().splitlines():
  if p=='src/.gitkeep':continue
  found=[n for n in files if n==root+'/'+p];assert len(found)==1,(p,found)
  b=t.extractfile(files[found[0]]).read();assert b==git('show',cand+':'+p),p
  clean=Path('/workspace/work/runtime-execution/r019-clean/cjtui-0.0.0')/p;assert clean.read_bytes()==b,p
  consumed[str(clean)]=sha(b);count+=1
 assert not any('/target/' in n or '/cache/' in n or n.endswith(('.a','.so','.cjo')) for n in files)
checks['archive']={'sha256':archivehash,'product_and_example_files_equal_candidate_and_clean':count,'no_target_cache_binary':True,'full_release':False,'known_gap':'examples/composition/cjpm.toml'}
# Every command exit corresponds to historical audit, retained stdout/stderr, command and timestamps.
for epoch in ['c3','r019']:
 b=ex/'evidence'/epoch; audit=json.loads((b/'final-verification.json').read_text()); rr=[]
 for name,code in audit['statuses'].items():
  d=b/name;actual=int((d/'exit').read_text());assert actual==code
  required=['stdout','stderr','utc','head','evidence-sha256.txt','artifact-sha256.txt'] if name=='reused-macro-negatives' else ['command','stdout','stderr','start','end']
  assert all((d/n).exists() for n in required),(epoch,name)
  rr.append({'command':name,'exit':actual,'recorded_command':(d/'command').read_text().strip() if (d/'command').exists() else 'reused frozen macro diagnostic artifacts; original head/utc/manifests retained'})
 dump('raw/'+epoch+'-command-records.json',rr);checks[epoch+'_command_records']={'count':len(rr),'match':True}
checks['core_pass_count']=sum(l.startswith('PASS:') for l in (ex/'evidence/c3/runtime-core/stdout').read_text().splitlines());assert checks['core_pass_count']==255
checks['clean_core_pass_count']=sum(l.startswith('PASS:') for l in (ex/'evidence/c3/clean-core-direct/stdout').read_text().splitlines());assert checks['clean_core_pass_count']==255
checks['verified_at']=datetime.datetime.now(datetime.timezone.utc).isoformat()
dump('raw/integrity-audit.json',checks);dump('raw/consumed-files.json',consumed);print(json.dumps(checks,indent=2))
