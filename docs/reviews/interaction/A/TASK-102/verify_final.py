from pathlib import Path
import hashlib,json,re,subprocess,datetime
B=Path('/workspace/work/interaction-acceptance');E=Path('/workspace/work/interaction-execution');R=Path('/workspace/work/terminal.ui');P='f8a028b39daf8a341576f304335d262544b9cca5';hs={};n=0

def rd(p):
 p=Path(p);assert '/interaction-implementation/'not in str(p);v=p.read_bytes();hs[str(p)]=hashlib.sha256(v).hexdigest();return v

def jo(p):
 def pairs(xs):
  d={}
  for k,v in xs:assert k not in d;d[k]=v
  return d
 return json.loads(rd(p),object_pairs_hook=pairs,parse_constant=lambda s:(_ for _ in ()).throw(ValueError(s)))

def ck(v,label):
 global n;n+=1;assert v,label

m=jo(E/'manifest.json');ck(hs[str(E/'manifest.json')]=='4fe928e0a973f3d034a40cbf8cbc7e98b99039e8dad39f56c57a369a9641f633','final manifest');ck(hashlib.sha256(rd(E/'report.md')).hexdigest()=='ffab6f895c85212f13fda69f9f415edcbdd2b8378d0832baadf0cd3d7f763be2','report')
seen=set()
for f in m['files']:
 p=Path(f['path']);ck(not p.is_absolute() and '..'not in p.parts and str(p)not in seen,'safe unique');seen.add(str(p));v=rd(E/p);ck(len(v)==f['bytes'] and hashlib.sha256(v).hexdigest()==f['sha256'],'manifest '+str(p))
 if p.suffix=='.json':jo(E/p)
idx=rd(E/'artifacts.sha256').decode().splitlines();ck(len(idx)==1595 and len(seen)==1594,'final count')
for l in idx:
 dig,name=l.split(None,1);ck(hashlib.sha256(rd(E/name.strip())).hexdigest()==dig,'index '+name)
prior={}
for name in ['partial-check.json','gui-check.json','vt-check.json']:
 for p,dig in jo(B/'raw'/name)['consumed_hashes'].items():
  if p in prior:ck(prior[p]==dig,'old inventory overlap')
  prior[p]=dig
for p,dig in prior.items():ck(hashlib.sha256(rd(p)).hexdigest()==dig,'original stable '+p)
env=jo(E/'raw/identity/environment-package.json');deps=jo(E/'raw/identity/runtime-dependencies.json')
ck(hashlib.sha256(rd(R/'openspec/changes/implement-public-interaction/design.md')).hexdigest()==env['canonical_design_sha256'],'design');ck(hashlib.sha256(rd(R/'docs/reviews/interaction/admission/interface-map.json')).hexdigest()==env['interface_map_sha256'],'map')
for f in env['configs']:ck(hashlib.sha256(rd(E/f['path'])).hexdigest()==f['sha256'],'host config')
ck(hashlib.sha256(rd(env['font']['file'])).hexdigest()==env['font']['sha256'],'font')
versions=subprocess.check_output(['dpkg-query','-W','-f=${Package}\t${Version}\n','fonts-dejavu-mono','libvte-2.91-0','xfce4-terminal','xserver-xorg-core'],text=True);ck('0.80.1-1'in versions and '1.1.4-1'in versions,'installed host versions')
xterm=subprocess.check_output(['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-version'],text=True).strip();ck(xterm==env['XTerm'],'xterm version')
for p,f in deps['binaries'].items():
 ck(hashlib.sha256(rd(E/p)).hexdigest()==f['sha256'],'actualELF')
 for lib,dig in f['runtime_hashes'].items():ck(hashlib.sha256(rd(lib)).hexdigest()==dig,'runtime')
for ref,key in [('dependency_baseline','baseline_sha256'),('official_stdx_baseline','stdx_baseline_sha256')]:ck(hashlib.sha256(rd(deps[ref])).hexdigest()==deps[key],'dependency baseline')
normal=jo(deps['dependency_baseline']);stdx=jo(deps['official_stdx_baseline'])
for f in normal:ck(hashlib.sha256(rd(Path('/workspace/work/linux-build-recon/cache')/f['path'])).hexdigest()==f['sha256'],'normal source')
for p,dig in stdx.items():ck(hashlib.sha256(rd(Path('/workspace/work/linux-build-recon/stdx-env/linux_x86_64_llvm')/p)).hexdigest()==dig,'stdx')
loaded=[]
for rel in ['gui-hosts2/xterm-visible','gui-hosts2/xterm-hidden','gui-hosts2/vte-visible','gui-hosts3/vte-hidden']:
 trace=rd(E/'raw'/rel/'product.strace').decode();found=[]
 for line in trace.splitlines():
  if 'openat('not in line or '= -1'in line:continue
  q=re.search(r'"((?:\\x[0-9a-f]{2})+)"',line)
  if q:
   path=bytes.fromhex(q[1].replace('\\x','')).decode(errors='replace')
   if path.endswith(('libcangjie-runtime.so','libboundscheck.so')):found.append(path);rd(path)
 ck(len(set(found))==2,'actual runtime loading');loaded.append({'run':rel,'loaded':sorted(set(found))})
commands=[];pre=jo(E/'raw/normal-device/pre-source.json')
for p in sorted((E/'raw').glob('*/command.json')):
 c=jo(p);ck(c['head']==P and c['utc']<c['end_utc'],'command source/time');ck(jo(p.parent/'pre-source.json')==jo(p.parent/'post-source.json')==pre,'command identity');commands.append(c|{'group':p.parent.name})
ck([c['group'] for c in commands if c['exit']!=0]==['gui','gui-collection','gui-collection2','kernel-vt'],'only classified collection failures')
ck(jo(E/'raw/affected-theme-integration/command.json')['exit']==0,'affectedTheme')
warnings=sum(len(re.findall(r'\bwarning:',re.sub(r'\x1b\[[0-9;]*m','',rd(E/'raw/bundle'/stream).decode()))) for stream in ['stdout','stderr']);ck(warnings==560,'mandatorywarnings both actual streams')
git=lambda *args:subprocess.check_output(['git','-C',str(R),*args])
ck(git('diff','--name-only','3755f579',P,'--','src/text','src/frame.cj','src/glyph_render_policy.cj','src/session_extension_state.cj')==b'','reused unchanged scopes');ck(git('diff','--name-only','6f0fcc4',P,'--','src','native').decode().strip()=='src/application.cj','runtimecore scoped delta')
for p in ['docs/tasks.md','docs/acceptance.md','docs/requirements.md','openspec/changes/implement-public-interaction/tasks.md','docs/product/interaction.md']:rd(R/p)
for p in (E/'product/tests/interaction_a/src').glob('*.cj'):ck(rd(p)==git('show',P+':tests/interaction_a/src/'+p.name),'formal oracle fixed')
res={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks_failed':0,'check_count':n,'final_execution_manifest_sha256':hs[str(E/'manifest.json')],'execution_content_files':1594,'execution_checksum_entries':1595,'previous_consumed_originals_unchanged':len(prior),'normal_dependency_sources':len(normal),'official_stdx_files':len(stdx),'mandatory_bundle_warnings':warnings,'host_version_observation':{'dpkg':versions,'XTerm':xterm,'timing':'Acceptance-time readonly version check, not retroactive pre-run identity'},'actual_runtime_loading':loaded,'ldd_limit':'Environment-free ldd says SDK libs not found; actual GUI openat and packed VT SDK bytes separately prove successful runtime resolution. No product build/run failure follows from ldd text.','commands':commands,'consumed_hashes':hs,'product_executed':False,'metadata_checks_are_not_product_test_count':True}
(B/'raw/final-identity-check.json').write_text(json.dumps(res,ensure_ascii=False,indent=2)+'\n');print(json.dumps({k:v for k,v in res.items() if k in ['checks_failed','check_count','execution_content_files','execution_checksum_entries','previous_consumed_originals_unchanged','normal_dependency_sources','official_stdx_files','mandatory_bundle_warnings']}))
