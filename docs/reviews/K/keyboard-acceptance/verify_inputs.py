"""TASK117 read-only provenance reconciliation; never executes product or tests."""
from pathlib import Path
import hashlib,json,subprocess,re,datetime
OUT=Path('/workspace/work/keyboard-acceptance')
BASE=Path('/workspace/work/keyboard-execution')
REPO=Path('/workspace/work/terminal.ui')
SHA='c3c4642d84df57bbd9550d222ed22f602acd13ef'
checks={}
def digest(data): return hashlib.sha256(data).hexdigest()
def verify(path,want=None,scope='selected original'):
 p=Path(path); data=p.read_bytes(); actual=digest(data)
 if want is not None: assert actual==want,(str(p),actual,want)
 checks[str(p)]={'path':str(p),'size':len(data),'sha256':actual,'verification':'fresh hash','scope':scope}
 return data
def readjson(path,want=None): return json.loads(verify(path,want))
stable=readjson(BASE/'stablemanifest.json','a035651ef9feb3373c1f419270005a96b18beb414f517048b0004a273c878af9')
verify(BASE/'report.md','6d68a1aaf18ccfa9a428075325d74f5df95e9c25de03feb366165197a1de98c4')
recorded={str(BASE/x['path']):x for x in stable['original_files']}
def original(path):
 p=Path(path); item=recorded[str(p)]; return verify(p,item['sha256'])
phases=[]
for name in stable['required_zero_exit_phases']:
 p=BASE/'raw'/name/'manifest.json'; d=json.loads(original(p)); assert d['exit']==0
 assert d.get('source_sha',SHA)==SHA
 phases.append({'name':name,'exit':d['exit'],'argv':d.get('argv')})
 for f in ['stdout','stderr']: original(p.parent/f)
for rel in ['raw/final-verification.json','raw/source-manifest.json','raw/reuse-scope.json','raw/host-qualification.json','raw/png-catalog.json','raw/binary-bindings.json','raw/integration-test-overlay/phase-index.json','raw/integration-original-binary.json','raw/clean-input-bindings.json','raw/independent-test-references.json','raw/package-audit-r2/manifest.json']:
 original(BASE/rel)
for r in [1,2,3]:
 root=Path(f'/workspace/work/keyboard-review/round-{r:02}')
 for line in verify(root/'manifest.sha256').decode().splitlines():
  h,n=line.split(None,1); verify(root/n.strip(),h,'independent source review')
for ref in json.loads((BASE/'raw/independent-test-references.json').read_text()): verify(ref['path'],ref['sha256'],'independent test diagnosis/overlay')
verify('/workspace/work/keyboard-tests/integration-profile-fix/change.patch','49f639adb891db1b69c0535d83f63829ed242c1e3b6fb602539298d7910ca817')
for p in (BASE/'raw/integration-test-overlay').iterdir():
 if p.is_file(): original(p)
for n in ['integration','real-vt-host','package-audit-command']:
 p=BASE/'raw'/n/'manifest.json'; d=json.loads(original(p)); assert d['exit']!=0
 for f in ['stdout','stderr']: original(p.parent/f)
contracts=['AGENTS.md','docs/acceptance.md','docs/requirements.md','openspec/changes/implement-linux-input-editing/design.md','openspec/changes/implement-linux-input-editing/tasks.md','openspec/changes/implement-linux-input-editing/specs/ui-runtime/spec.md','openspec/changes/fix-uncertain-glyph-advance/design.md','openspec/changes/implement-linux-vt-glyph-fallback/design.md','.superpowers/sdd/tasks-implement-linux-input-editing/task-117-brief.md']
for n in contracts: verify(REPO/n,scope='canonical requirement')
assert digest((REPO/contracts[3]).read_bytes())=='a2cef43376b24e9613a4a08f45890fb0e24689c2f93f3a30041b87810766df23'
source_manifest=json.loads((BASE/'raw/source-manifest.json').read_text())['files']
source_paths=['src/keyboard_decoder.cj','src/keyboard_batch.cj','src/keyboard_limits.cj','src/key_event.cj','src/keyboard_exception.cj','src/keyboard_diagnostic.cj','src/keyboard_issue.cj','src/application.cj','native/cjtui_terminal.c','src/terminal_bridge.cj','docs/product/keyboard-input.md','tests/keyboard/formal_pty.py','tests/keyboard/formal_device/src/main.cj','tests/keyboard/run.sh','tests/run-slice.sh','tests/integration/pty.mjs','tests/support/terminal_frames.mjs','examples/keyboard/src/main.cj']
source_paths += [str(p.relative_to(BASE/'source')) for p in (BASE/'source/tests/keyboard/src').glob('*.cj')]
for n in source_paths:
 data=verify(BASE/'source'/n,source_manifest[n],'fixed source/test/public document')
 blob=subprocess.check_output(['git','show',f'{SHA}:{n}'],cwd=REPO)
 assert data==blob,n
fixture=BASE/'source/tests/integration/fixture/src/main.cj'
verify(fixture,'1f7f815c93a4a29d49901436259917fab01a62766cb62fa0c05aa35d5b1a3f12','authorized test-only overlay')
original_fixture=subprocess.check_output(['git','show',f'{SHA}:tests/integration/fixture/src/main.cj'],cwd=REPO)
addition=b'    // The virtual terminal model supports logical Unicode clusters; this is not a host font claim.\n    app.glyphMode(GlyphMode.Unicode)\n'
assert fixture.read_bytes().replace(addition,b'')==original_fixture
assert "中文 👩‍💻 " in (BASE/"source/tests/integration/pty.mjs").read_text()
diag=readjson('/workspace/work/keyboard-tests/integration-diagnosis/evidence.json')
for n,v in diag['files'].items():
 for rev in [diag['accepted'],SHA]: assert digest(subprocess.check_output(['git','show',f'{rev}:{n}'],cwd=REPO))==v['fixed'],n
 if n!='tests/integration/fixture/src/main.cj': verify(BASE/'source'/n,v['fixed'],'unchanged glyph/fixture diagnosis')
for n,v in diag['application_glyph_snippets'].items():
 assert digest(v['fixed_text'].encode())==v['fixed_sha256']
 for rev in [diag['accepted'],SHA]: assert v['fixed_text'] in subprocess.check_output(['git','show',f'{rev}:src/application.cj'],cwd=REPO).decode()
for p,h in diag['raw_sha256'].items(): verify(p,h,'retained original integration failure')
for n,h in diag['contracts_sha256'].items(): verify(REPO/n,h,'glyph fixture governing contract')
formal=[]
for p in sorted((BASE/'raw/keyboard-suite/native/formal').glob('*/metadata.json')):
 d=json.loads(original(p)); assert d['exit']==0 and d['result']=='PASS'
 assert d['binary_pre_sha256']==d['binary_post_sha256']=='cb578fa38f6503688fdc292d9ef935afecbc8e56c8b01ae2e45a5bee2e7c7204'
 assert d['before_termios']==d['after_termios'] and d['summary']['resources']=='0/0/0/0'
 for f in p.parent.iterdir():
  if f.is_file(): original(f)
 formal.append({'mode':p.parent.name,'exit':d['exit'],'binary':d['binary_pre_sha256']})
assert len(formal)==27
for p in (BASE/'raw/keyboard-suite/k115-native').iterdir():
 if p.is_file(): original(p)
for n in ['host-xterm','host-vte','host-vt-r3']:
 folder=BASE/'raw'/n; index=json.loads(original(folder/'phase-index.json'))
 for f in folder.iterdir():
  if f.is_file(): original(f)
 d=json.loads((folder/'result.json').read_text()); term=d.get('terminal',d)
 assert term['product_exit']==0 and term['termios_equal']
for item in json.loads((BASE/'raw/png-catalog.json').read_text())['screenshots']: verify(BASE/item['path'],item['sha256'],'actual host PNG')
for item in json.loads((BASE/'raw/binary-bindings.json').read_text())['direct_binaries']: verify(BASE/item['path'],item['sha256'],'actual executed binary')
verify(BASE/'artifacts/cjtui-0.0.0.cjp','e3196fccc18ff3fe3889245ad46d789abf52af5f2384fe7b36444f685f8e00f9','normal bundle artifact')
for rel in ['raw/clean-keyboard-run/stdout','raw/clean-dispatch-run/stdout','raw/clean-example-run/stdout']: original(BASE/rel)
lint=Path('/workspace/work/keyboard-implementation/review-r2-lint-01')
assert verify(lint/'exit').decode().strip()=='0'
clean=re.sub(r'\x1b\[[0-9;]*m','',(verify(lint/'stdout')+verify(lint/'stderr')).decode())
errors=[x for x in clean.splitlines() if re.match(r'^\s*(?:fatal\s+)?error(?:\[|:|\s)',x,re.I)]
assert not errors,errors[:3]
summary={'task':'TASK117','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'fixed_product':SHA,'overlay':'daf99aa1f323929d09907d558623b3bb6a74cbbb','method':'Fresh selected-original hashes, manifest/exits/binary bindings and fixture semantic comparison; reused valid execution, no product/test execution or duplicate whole-asset audit.','fresh_hashes':len(checks),'required_exit_zero_phases':phases,'formal_native_modes':formal,'lint_error_severity_count':len(errors),'source_invariants':{'offset':'offset==Int64.Max closes before offset++; not exercised by fake enormous input','resident_storage':'batch relinquishes keys/issues; paste replaced on overflow/end/finish; sequence maxSequenceBytes+constant marker allowance; scalar metadata/endPrefix constant; SDK clear retention disassembly used by review','device_budget':'one byte per existing outer UI turn is <=4096; post/resize/stop pump retained','idle':'current decoder waitingIdle/drain plus monotonic100ms read loop source review; actual protocol-reply on fixed K; historical A idle oracle is not a new full-K executed proof'},'fixture_semantics':'Only explicit Unicode profile plus comment; original eight-by-three oracle/parser unchanged; product Auto conservative fallback unchanged in 16 files and three Application snippets. Original failed execution retained.','visual_inspection':'Viewed original resized XTerm, VTE, settled kernelVT PNGs; these show formal ready/A/B surface and do not independently prove behavior or complete display restoration.','fresh_originals':list(checks.values())}
(OUT/'verification.json').write_text(json.dumps(summary,indent=2)+'\n')
entries={str(BASE/x['path']):{'path':str(BASE/x['path']),'sha256':x['sha256'],'size':x['size'],'verification':'recorded immutable TASK116 original; valid result reused per AGENTS11.1'} for x in stable['original_files']}
entries.update(checks)
(OUT/'index.json').write_text(json.dumps({'task':'TASK117','product':SHA,'overlay':summary['overlay'],'execution_manifest':str(BASE/'stablemanifest.json'),'execution_manifest_sha256':digest((BASE/'stablemanifest.json').read_bytes()),'coverage_note':'All TASK116 original paths/hashes retained transitively, with fresh selective verification explicitly marked; no claim of fresh hashing every inherited asset. Independent review/contracts/test-diagnosis originals added.','files':list(entries.values())},indent=2)+'\n')
print(json.dumps({'fresh_hashes':len(checks),'indexed_paths':len(entries),'phases':len(phases),'formal_modes':len(formal),'lint_errors':len(errors),'result':'provenance checks passed'}))
