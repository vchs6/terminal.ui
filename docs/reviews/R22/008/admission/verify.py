from pathlib import Path
import json,hashlib,subprocess,datetime
out=Path(__file__).parent; root=Path('/workspace/work/terminal.ui')
def sha(b):return hashlib.sha256(b).hexdigest()
def git(*a):return subprocess.check_output(['git','-C',str(root),*a])
m=json.loads((out/'input-map.json').read_text());checks=[]
for x in m['references']:
 b=git('show',x['revision']+':'+x['repository_path']) if 'revision' in x else Path(x['path']).read_bytes()
 checks.append({'path':x['path'],'kind':'fixed Git input' if 'revision' in x else 'fixed external/public input','expected':x['sha256'],'actual':sha(b),'pass':sha(b)==x['sha256']})
dq=json.loads((out/'dq.json').read_text());rd=json.loads((out/'readiness-delta.json').read_text());tool=json.loads((out/'tool-readiness.json').read_text())
checks.extend([{'check':'exact14DQ unique and all pass for008formaltest admission only','pass':len(dq['checks'])==14 and len(set(x['id'] for x in dq['checks']))==14 and all(x['result']=='pass' for x in dq['checks'])},{'check':'report<=20lines','pass':len((out/'report.md').read_text().splitlines())<=20},{'check':'no missing public questions','pass':not rd['missing_public_questions']},{'check':'all read-only tool commands zero exit and paths available','pass':all(x['exit']==0 for x in tool['commands']) and all(x['exists'] for x in tool['paths'])},{'check':'accepted6e and fixedmainc5 relevant source scopes identical','pass':not git('diff','--name-only',m['accepted_combined_source'],m['current_main'],'--','src','native','tests','examples','cjpm.toml','build.cj').strip()},{'check':'three historical findings remain verified','pass':all(x['status']=='verified' for x in json.loads((out.parent/'scoped-r1/findings.json').read_text()))}])
fail=[x for x in checks if not x['pass']]
result={'UTC':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'artifact consistency/admission inputs only; no product tests or build','checks':checks,'failures':fail,'count':len(checks),'result':'PASS' if not fail else 'FAIL','current_head_observed':git('rev-parse','HEAD').decode().strip(),'workspace_status_observed':git('status','--short').decode(),'verification_command':'python3 /workspace/work/linux-closeout-preflight/admission-008-20261113/verify.py'}
(out/'verification.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:result[k] for k in ['result','count','failures','current_head_observed','workspace_status_observed']}))
assert not fail
