from pathlib import Path
import json,hashlib,re,subprocess,datetime
B=Path('/workspace/work/theme-execution');R=Path('/workspace/work/terminal.ui');O=Path('/workspace/work/theme-acceptance');P='8d75233c664fd61be08d441f74d464cbcdff2d9c'
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p):return json.loads(Path(p).read_text())
def git(p,c=P):return subprocess.check_output(['git','-C',str(R),'show',c+':'+p])
result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'product_executed':False}
generated={}
for name in ['foundation-values','foundation-integration']:
 d=load(B/'raw'/name/'detail/generated-input-hashes.json')
 for p,s in d.items():assert h(B/'product/tests/themes/.scratch'/p)==s
 generated[name]=len(d)
result['generated_input_hashes_rechecked_without_copy']=generated
neg=load(B/'raw/reuse/negative-public-type-identity.json')
def declarations(blob):
 text=re.sub(r'/\*.*?\*/','',blob.decode(),flags=re.S);text=re.sub(r'//[^\n]*','',text)
 return [s.strip() for s in text.splitlines() if 'public ' in s]
for d in neg['files']:
 assert declarations(git(d['path'],'97df09638e2912cbee3313c23c4254e0a1708a5e'))==declarations(git(d['path']))
result['reused_negative_public_declaration_files']=5
old=[json.loads(x) for x in (B/'raw/reuse/historical-attempts/themes-c1-commands.jsonl').read_text().splitlines()]
gates=[d for d in old if d['name'] in ['values-build','values-run','integration-build','integration-run']]
assert len(gates)==4 and all(d['exit']==0 for d in gates)
assert max(d['utc'] for d in gates)<min(d['utc'] for d in old if d['name'].startswith('negative-'))
result['historical_positive_gates']=gates
result['negative_scope_limitation']='Exact fixtures/declarations and observed real type-access diagnostics support reuse; C1 product/compiler pre-run identity was not captured. No new-final negative run claimed.'
pub=R/'docs/reviews/R15/test-design';index=load(pub/'archive-index.json');entries=next(v for v in index.values() if isinstance(v,list) and v and isinstance(v[0],dict) and 'copy' in v[0])
selected=['commands.jsonl','raw/fixed-contract-root-normal-build.stdout','raw/fixed-contract-root-normal-build.stderr','raw/fixed-foundation-runner/values-build.stderr','raw/fixed-foundation-runner/commands.jsonl']
records=[]
for n in selected:
 p=pub/n;r=next(x for x in entries if x['copy']=='docs/reviews/R15/test-design/'+n);assert h(p)==r['sha256'];records.append({'path':str(p),'sha256':h(p)})
cmd=[json.loads(x) for x in (pub/'commands.jsonl').read_text().splitlines()];assert next(x for x in cmd if x['name']=='fixed-contract-root-normal-build')['exit']==0
red=[json.loads(x) for x in (pub/'raw/fixed-foundation-runner/commands.jsonl').read_text().splitlines()];assert len(red)==1 and red[0]['exit']==1
text=(pub/'raw/fixed-foundation-runner/values-build.stderr').read_text();assert 'cjtui.theme' in text
result['formal085_original_red']={'records':records,'root_build_exit':0,'values_missing_api_exit':1,'negative_gate_not_reached':True}
for family in ['gui','gui-glyph']:
 s=load(B/'raw'/family/'summary.json');assert all(r['hostExit']==0 and r['termiosEqual'] for r in s['runs']);assert s['utcEnd']<load(B/'manifest.json')['utc'];result[family+'_lifecycle']={'runs':len(s['runs']),'xorgExit':s['xorgExit'],'utcEnd':s['utcEnd']}
result['boundary_inputs']=[{'path':str(p),'sha256':h(p)} for p in [R/'openspec/changes/implement-theme-styles/design.md',R/'openspec/changes/implement-theme-styles/tasks.md',R/'openspec/changes/complete-linux-integration/tasks.md',R/'docs/acceptance.md',R/'scripts/check-bundle.mjs']]
result['whole_checker_independent_disposition']={'actual_exit':1,'open':True,'scope':'Final TASK023 integration/release gate','reason':'T010 requires themes delivery. Original currentAC087/T012 requires normal bundle and clean SDK/stdx public consumption, independently proven. complete-linux-integration023.a explicitly requires formal negative controls for outdated themes/showcase/benchmark checker;023.b–d owns release wiring/full gates. Full release not accepted.'}
result['failed']=0
(O/'raw/metadata.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'failed':0,'generated':generated,'original085_red':'verified','old_positive_gates':4,'negative_declaration_files':5,'whole_checker':'OPEN_TASK023'},ensure_ascii=False))
