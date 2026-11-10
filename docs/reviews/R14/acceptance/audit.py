import hashlib,json,pathlib,subprocess,datetime
OUT=pathlib.Path('/workspace/work/rich-text-acceptance')
REPO=pathlib.Path('/workspace/work/terminal.ui')
FIXED='199f00076c1a79cfa6d0be92e7be09366e1a06af'
records={};checks=[]
def digest(p):
 p=pathlib.Path(p);b=p.read_bytes();h=hashlib.sha256(b).hexdigest();records[str(p)]={'path':str(p),'sha256':h,'bytes':len(b)};return h
def check(name,ok,**kw):
 checks.append({'check':name,'ok':bool(ok),**kw})
def manifest(p):
 p=pathlib.Path(p);digest(p);n=0
 for line in p.read_text().splitlines():
  if not line.strip():continue
  h,rel=line.split(None,1);q=pathlib.Path(rel.lstrip('*'));q=q if q.is_absolute() else p.parent/q
  check('manifest member',q.is_file() and digest(q)==h,manifest=str(p),path=str(q));n+=1
 return n
scoped=pathlib.Path('/workspace/work/rich-text-execution-scoped')
d=json.loads((scoped/'hashes.json').read_text());digest(scoped/'hashes.json')
for p,h in d['hashes'].items():check('083 final hash reference',digest(p)==h,path=p)
counts={}
for p in ['/workspace/work/glyph-advance-execution/artifacts.sha256','/workspace/work/glyph-advance-acceptance/artifacts.sha256','/workspace/work/colors-resize-fixture-review/scoped-r1/review-artifacts.sha256']:
 counts[p]=manifest(p)
check('083 final finite PASS',json.loads((scoped/'findings.json').read_text())['status']=='PASS_FINITE')
check('167 final finite PASS',json.load(open('/workspace/work/glyph-advance-acceptance/findings.json'))['verdict']=='PASS_FINITE')
# Final new colors inputs: overlay bytes and actual unchanged binaries.
e=pathlib.Path('/workspace/work/glyph-advance-execution')
for item in json.load(open(e/'colors-test-overlay.json'))['files']:
 p=e/'source'/item['path'];h=digest(p);g=subprocess.check_output(['git','-C',str(REPO),'show','0d46c35456db148f08bd407825a4fd559467249a:'+item['path']]);check('corrected colors overlay',h==item['sha256']==hashlib.sha256(g).hexdigest(),path=str(p))
for item in json.load(open(e/'colors-final-binaries.json'))['after_execution']:
 check('actual199 colors binary preserved',digest(e/'source'/item['path'])==item['binary_sha256'],path=item['path'])
for name in ['26-final-stop-controls','27-final-resize-controls','28-final-colors-actual']:
 p=e/'raw'/name/'exit';check('new colors command actual exit',p.read_text().strip()=='0',command=name)
# Root changes after integration remain outside the accepted product path.
for rev in ['b08c92d130f8d066a6db11c9ca1bf4c9af17e3f0','216bb9f35bdf70b621a0d30a4df32fe3c267f90b']:
 diff=subprocess.check_output(['git','-C',str(REPO),'diff','--name-only',FIXED,rev,'--','src','native','examples/rich-text','tests/rich-text','tests/glyph_advance','cjpm.toml']);check('fixed product integration identity',not diff.strip(),revision=rev)
# Bind formal contract and reviewed immutable source without reading author reports.
for rel in ['AGENTS.md','docs/acceptance.md','openspec/changes/implement-rich-text/design.md','openspec/changes/implement-rich-text/tasks.md','openspec/changes/implement-rich-text/specs/terminal-output/spec.md']:
 digest(REPO/rel)
for p in (pathlib.Path('/workspace/work/glyph-advance-acceptance/source')/'src').rglob('*.cj'):digest(p)
for base,names in {
 'docs/reviews/R14/code-review':['report.md','findings.json','scoped-r1.md','scoped-r1-findings.json','SHA256SUMS','scoped-r1-SHA256SUMS','archive-index.json'],
 'docs/reviews/R14/regression-test':['report.md','archive-index.json','raw/initial-consumer-direct.log','raw/initial-consumer-direct.exit'],
 'docs/reviews/R14/test-design':['archive-index.json','evidence/handoff.md','evidence/freeze-red.exit','evidence/freeze-red.stderr'],
 'docs/reviews/R14/execution-initial':['report.md','archive-index.json','artifacts.sha256','evidence/rich-direct/stdout','evidence/rich-direct/exit','evidence/clean-rich-direct/stdout','evidence/clean-rich-direct/exit']}.items():
 for name in names:digest(REPO/base/name)
summary={'generated_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Final dependency closure/hash audit only; no product suites, builds, GUI sessions or PNG transformation','checks':len(checks),'failures':[x for x in checks if not x['ok']],'manifest_entries':counts,'details':checks}
(OUT/'raw/final-audit.json').write_text(json.dumps(summary,indent=2)+'\n')
(OUT/'reviewed-hashes.json').write_text(json.dumps({'generated_utc':summary['generated_utc'],'fixed_product':FIXED,'files':list(records.values())},indent=2)+'\n')
print(json.dumps({k:summary[k] for k in ['checks','failures','manifest_entries']}))
raise SystemExit(bool(summary['failures']))
