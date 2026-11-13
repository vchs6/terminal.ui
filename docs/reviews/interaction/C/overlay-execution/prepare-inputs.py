"""Read-only input preparation plus own sparse checkout/config; never builds."""
import datetime,hashlib,json,pathlib,subprocess
B=pathlib.Path('/workspace/work/overlay-execution');R=B/'input-preparation';R.mkdir(exist_ok=True)
SOURCE=pathlib.Path('/workspace/work/terminal.ui');P=B/'product';FIXED='f8f0493a7f5aa3b74bd59bdc7e6d82af6696426d'
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''):h.update(chunk)
    return h.hexdigest()
def save(name,value):(R/(name+'.json')).write_text(json.dumps(value,indent=2)+'\n')
def run(name,argv,cwd=B,input=None):
    start=now();p=subprocess.run(argv,cwd=cwd,input=input,capture_output=True);(R/(name+'.stdout')).write_bytes(p.stdout);(R/(name+'.stderr')).write_bytes(p.stderr);save(name,dict(argv=argv,cwd=str(cwd),utcStart=start,utcEnd=now(),exit=p.returncode));assert p.returncode==0,(name,p.stderr.decode());return p.stdout
assert not P.exists(),'Do not overwrite an existing isolated checkout'
run('clone',['git','clone','--shared','--no-checkout',str(SOURCE),str(P)])
patterns=['/*','!/*/','/src/','/native/','/third_party/licenses/','/themes/','/examples/','/benchmarks/','/tests/','/scripts/','/docs/product/','/docs/requirements.md','/docs/ui-construction.md','/docs/architecture.md','/docs/acceptance.md','/docs/development/dependencies.md','/docs/development/cangjie-conventions.md','/openspec/changes/implement-public-interaction/','/openspec/specs/']
for rel in ['R13/acceptance/report.md','R14/acceptance/report.md','R15/acceptance/report.md','R18/acceptance/report.md','interaction/A/TASK-102/report.md','interaction/B/TASK-107/report.md','interaction/admission/interface-map-C.json','interaction/admission/interface-map.json']:patterns.append('/docs/reviews/'+rel)
run('sparse-init',['git','sparse-checkout','init','--no-cone'],P)
run('sparse-set',['git','sparse-checkout','set','--no-cone','--stdin'],P,('\n'.join(patterns)+'\n').encode())
run('checkout',['git','checkout','--detach',FIXED],P)
run('fixed-head',['git','rev-parse','HEAD'],P);run('base-changes',['git','diff','--name-status','fd286',FIXED],P)
cache='/workspace/work/viewport-tests/cache'
config='[repository.cache]\npath = "'+cache+'"\n[repository.home]\nregistry = "http://127.0.0.1:18973"\nversion = 0\n'
(B/'cangjie-repo.toml').write_text(config)
consumers=[P,*sorted({p.parent for p in (P/'tests').rglob('cjpm.toml')}),*sorted({p.parent for p in (P/'examples').rglob('cjpm.toml')}),*sorted({p.parent for p in (P/'benchmarks').rglob('cjpm.toml')})]
for directory in consumers:(directory/'cangjie-repo.toml').write_text(config)
(B/'env.sh').write_text('source /workspace/work/validation/sdk/cangjie/envsetup.sh\nexport CANGJIE_STDX_PATH=/workspace/work/linux-build-recon/stdx-env\nexport CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip\n')
run('tool-versions',['bash','-c','source /workspace/work/overlay-execution/env.sh\ncjc --version\ncjpm --version'],B)
def inventory(root):
    return [dict(path=str(p.relative_to(root)),bytes=p.stat().st_size,sha256=sha(p)) for p in sorted(root.rglob('*')) if p.is_file() and '.git' not in p.relative_to(root).parts and '__pycache__' not in p.parts]
save('checkout-prehash',dict(fixed=FIXED,files=inventory(P)))
save('config-prehash',dict(files=[dict(path=str(p),sha256=sha(p)) for p in [B/'env.sh',B/'cangjie-repo.toml',*[d/'cangjie-repo.toml' for d in consumers]]],cache_mode='Shared existing source cache; no service started; own build outputs only; do not use author target.'))
depbase=pathlib.Path('/workspace/work/theme-execution/raw/dependency-source-hashes.json');deps=json.loads(depbase.read_text());depresults=[]
for d in deps:
    p=pathlib.Path(cache)/d['path'];actual=sha(p);depresults.append(dict(path=str(p),expected=d['sha256'],sha256=actual,equal=actual==d['sha256']))
save('dependencies375-prehash',dict(baseline=str(depbase),baseline_sha256=sha(depbase),count=len(depresults),all_equal=all(d['equal'] for d in depresults),files=depresults))
stdxbase=pathlib.Path('/workspace/work/theme-execution/raw/stdx-hashes.json');stdx=pathlib.Path('/workspace/work/linux-build-recon/stdx-env/linux_x86_64_llvm').resolve();stdxresults=[]
for name,expected in json.loads(stdxbase.read_text()).items():
    p=stdx/name;actual=sha(p);stdxresults.append(dict(path=str(p),expected=expected,sha256=actual,equal=actual==expected))
save('stdx371-prehash',dict(root=str(stdx),baseline=str(stdxbase),baseline_sha256=sha(stdxbase),count=len(stdxresults),all_equal=all(d['equal'] for d in stdxresults),files=stdxresults))
sdk=pathlib.Path('/workspace/work/validation/sdk/cangjie');save('sdk-prehash',dict(root=str(sdk),files=inventory(sdk)))
ucd=pathlib.Path('/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip');save('ucd-prehash',dict(path=str(ucd),bytes=ucd.stat().st_size,sha256=sha(ucd)))
save('collectors-prehash',dict(files=inventory(B/'tools')))
rows=[]
for line in (P/'tests/interaction_c/admission.current.tsv').read_text().splitlines()[1:]:
    gate,status,commit,evidence=line.split('\t');r=subprocess.run(['git','merge-base','--is-ancestor',commit,FIXED],cwd=P);ep=P/evidence;rows.append(dict(gate=gate,status=status,source=commit,ancestorExit=r.returncode,evidence=evidence,present=ep.is_file(),sha256=sha(ep) if ep.is_file() else None))
save('admission-eight-precheck',dict(fixed=FIXED,rows=rows,note='Read-only table/ancestor/path check; not formal entrance execution or QA acceptance'))
assert len(rows)==8 and all(d['status']=='ACCEPTED' and d['ancestorExit']==0 and d['present'] for d in rows)
assert len(depresults)==375 and all(d['equal'] for d in depresults)
assert len(stdxresults)==371 and all(d['equal'] for d in stdxresults)
run('checkout-status',['git','status','--short'],P)
print('Prepared isolated sparse source, existing SDK/cache prehash; no build or candidate execution')
