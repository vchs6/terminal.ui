from pathlib import Path
import json,hashlib,subprocess,datetime
root=Path('/workspace/work/terminal.ui'); out=Path('/workspace/work/linux-closeout-preflight/admission-008-20261113'); prior=out.parent
rev='c5a875f09cbb4f6fdb49eefaff14343e0d519630'; accepted='6e3f26aaaeee9442fde91ce31d720a841eeda473'
def sha(b):return hashlib.sha256(b).hexdigest()
def save(n,d): (out/n).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
def git(*args):return subprocess.check_output(['git','-C',str(root),*args])
def fixed(p):return git('show',f'{rev}:{p}')
records={}
def add(p,role,expected=None,pin=False):
 p=Path(p); p=root/p if not p.is_absolute() else p
 rel=str(p.relative_to(root)) if p.is_relative_to(root) else None
 b=fixed(rel) if pin else p.read_bytes(); h=sha(b)
 if expected: assert h==expected,(str(p),h,expected)
 d={'path':str(p),'sha256':h,'bytes':len(b),'role':role}
 if pin:d.update(revision=rev,repository_path=rel,git_blob=git('rev-parse',f'{rev}:{rel}').decode().strip(),working_bytes_match=p.read_bytes()==b)
 records[str(p)]=d;return d
contracts=['AGENTS.md','ENGINEERING_TASK_DECOMPOSITION.md','BATTLE_PROTOCOL.md','openspec/changes/complete-linux-integration/design.md','openspec/changes/complete-linux-integration/tasks.md','openspec/changes/implement-session-extensions/design.md','openspec/changes/implement-public-interaction/design.md','docs/acceptance.md','docs/tasks.md']
for p in contracts:add(p,'canonical requirement/governance; selected008/common/shared-interface scope',pin=True)
for p in ['report.md','dq.json','reviewed-hashes.json','scoped-r1/report.md','scoped-r1/dq.json','scoped-r1/findings.json','scoped-r1/reviewed-hashes.json']: add(prior/p,'inherited original planning definitions/closed findings; no overwrite')
add(root/'.superpowers/sdd/tasks-complete-linux-integration/task-008-preflight-brief.md','root assigned scope and writer barrier')
m=json.loads(fixed('docs/reviews/widgets/M/input-manifest.json'));add('docs/reviews/widgets/M/input-manifest.json','historical upstream map only; old M gates superseded by actual162',pin=True)
up=[]
for a in m['accepted_upstream']:
 refs=[]
 for k in ['report','index']:
  x=a[k];p=x.get('repository_path') or x['path'];refs.append(add(p,'accepted upstream '+a['task']+' '+k,x['sha256']))
 up.append({'task':a['task'],'accepted_source':a['accepted_original_source'],'scope':a['scope'],'references':refs,'later_source_policy':'Historical accepted sources are not claimed individually identical after later accepted increments; current combined input bound separately.'})
s=m['accepted_S'];up.append({'task':'S157','verdict':s['verdict'],'references':[add(s[k]['repository_path'],'accepted S157 '+k,s[k]['sha256']) for k in ['acceptance_index','acceptance_report','execution_index']]})
for task,paths,source in [('Session152',['docs/reviews/R18/acceptance/report.md','docs/reviews/R18/acceptance/hash-manifest.json','docs/reviews/R18/acceptance/acceptance-matrix.json'],'83094ca92acab37ed0a38042e2e40ead55049f41'),('R10',['docs/reviews/R10/acceptance/report.md','docs/reviews/R10/acceptance/final-metadata-evidence.json','docs/reviews/R10/acceptance/verdicts.json'],'8af39f6c8882772b946ae1d9507361f8a6082388'),('070',['docs/reviews/R11/acceptance/final-verdict.json','docs/reviews/R11/acceptance/final-projection-report.md'],'5c2a7e7d956b5d8c0284e96514276608616bf8a6')]:
 up.append({'task':task,'accepted_source':source,'references':[add(p,'accepted '+task+' finite evidence',pin=True) for p in paths]})
mi=add('/workspace/work/widgets-composite-acceptance/index.json','actual162 authoritative admission prerequisite','b1c92e7440efbc3cf4b2688bb5d3c5c50a7262e3a24ad1123776cc9c8f64c5eb')
mx=add('/workspace/work/widgets-composite-execution/final-index.json','actual161 independent execution upstream','b126ef3d726c4b5e01a6d145e70f519d87bae210c26de68f60101c98f8b50d51')
up.append({'task':'M162','verdict':'PASS_FINITE_M','accepted_source':accepted,'references':[mi,mx,add('/workspace/work/widgets-composite-acceptance/ac-results.json','actual162 finite acceptance decisions'),add('/workspace/work/widgets-composite-acceptance/source-test-contract-receipts.json','actual162 fixed source/test references')]})
source_paths=['src/application.cj','src/frame.cj','src/terminal_bridge.cj','src/runtime_stats.cj','native/cjtui_terminal.c','src/caret_probe.cj','src/session_result.cj','src/session_options.cj','src/session_device_exception.cj','src/ui_cleanup_exception.cj','src/runtime_session.cj','cjpm.toml','build.cj']
for p in source_paths:add(p,'current signature/phase/owner readiness only, not source correctness review',pin=True)
fixtures=['tests/application-lifecycle/run.sh','tests/application-lifecycle/native/close_wrap.c','tests/application-lifecycle/pty.mjs','tests/session_extensions/run.sh','tests/session_extensions/native/session_fault.c','tests/interaction_a/run.sh','tests/interaction_a/native/write_fault.c','tests/keyboard/native/write_fault.c']
for p in fixtures:add(p,'existing native fault method and scoped reuse',pin=True)
for phase in ['normal-build','normal-bundle']:
 base=Path('/workspace/work/widgets-composite-execution/raw')/phase
 for name in ['phase-index.json','index.json','command.json']:add(base/name,'actual161 normal environment/build evidence reused')
profile=Path('/workspace/work/widgets-composite-implementation/source/cangjie-repo.toml')
if profile.exists():add(profile,'existing normal HTTPS registry configuration only; no author reasoning')
for p in ['/workspace/work/validation/sdk/cangjie/envsetup.sh','/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip']:add(p,'normal toolchain/data readiness')
paths=['src','native','tests','examples','cjpm.toml','build.cj'];diff=git('diff','--name-only',accepted,rev,'--',*paths).decode();assert not diff
save('input-map.json',{'task':'008','scope':'admission delta; prerequisite/public interface/native method availability only','current_main':rev,'accepted_combined_source':accepted,'equality':{'command':'git diff --name-only '+accepted+' '+rev+' -- '+' '.join(paths),'output':diff},'accepted_inputs':up,'references':list(records.values()),'producer_reports_used_as_verdict':False,'full_M_archive':'parallel metadata; not a capability prerequisite','missing_public_questions':[]})
old=json.loads((prior/'dq.json').read_text()); corrections=json.loads((prior/'scoped-r1/dq.json').read_text()); repaired={x['id'] for x in corrections['checks']}
reasons={
'DQ-01':'Original008 L3 under WP002/REQ004 retained; this role checks admission only.',
'DQ-02':'Single result remains AC008 output transaction/baseline; no future M2 or010/020 implementation absorbed.',
'DQ-03':'Common fields+008card+C002+fixed actual source/accepted-input map locate current test-author inputs. Frozen formal008 tests are the next deliverable, not required to author themselves.',
'DQ-04':'Only actual single Application/Frame/native owner and bounded test-only syscall/link seam; no second backend/API.',
'DQ-05':'Current public/raw/error/native phase observations suffice for fixed byte-prefix matrix and success-baseline proof; exact offsets belong to independent test author.',
'DQ-06':'070/R10/152/117/112/122/162 actual accepted inputs are available; supporting080/084/088/092/097/102/107/157 mapped. No fullM archive or futureM2 prerequisite.',
'DQ-07':'Original requirement mapping inherited unchanged; no parent/fullLinux acceptance inferred.',
'DQ-08':'008 writer producer,010 logical Frame consumer and020 cleanup consumer remain distinct; root serial product-author barrier retained.',
'DQ-09':'008 delivers M1 writer/failure input to020;010 and020 keep their own real-input gates. No future041 reverse gate.',
'DQ-10':'No missing public signature/tool question; run-time correctness and exhaustive actual offsets explicitly remain formal008 work, not assumed passed.',
'DQ-11':'008.a/b are now executable formal-test work; .c-.e still require frozen tests/fixed candidate/review/execution. No new task or fake RED.',
'DQ-12':'Pin c5/accepted6e equality and original M162/M161 hashes; old M status strings retained as historical only. Prior LC-PF001–003 stay verified.',
'DQ-13':'Execution classification and frozen C001/C002 unchanged. Current SDK1.2/native tools read-only checks succeed; role-specific skill use recorded at dispatch/execution, not preclaimed.',
'DQ-14':'Canonical writer and cleanup ownership retained; test shim calls real writer/open/close, no product instrumentation or compatibility exception required.'}
checks=[]
for a in old['checks']:
 checks.append({'id':a['id'],'original_result':a['result'],'inherited_result':'pass' if a['id'] in repaired else a['result'],'inherited_ref':'scoped-r1/dq.json' if a['id'] in repaired else 'dq.json','result':'pass','delta_scope':'TASK008 independent formal-test prerequisites only','reason':reasons[a['id']]})
save('dq.json',{'verdict':'READY_008_FORMAL_TEST_PRECONDITIONS','not_product_or_AC_acceptance':True,'definitions':'ENGINEERING_TASK_DECOMPOSITION §8.2; original14 checks reused without new rubric','checks':checks,'open_findings':[],'product_implementation_gate':'root publishes actual008 input manifest and independent formal008 tests first; this report does not authorize product edits','future_cards':'unchanged planned/gated; no complete futureM2 review'})
save('readiness-delta.json',{'verdict':'READY_008_FORMAL_TEST_PRECONDITIONS','task_self_table_definition':'Reuse original report.md 逐项核对与边界 (task/result/inputs/check entry); unchanged task rows inherited, not reevaluated.','task_self_delta':[{'task':'008','result':'ready for independent formal tests on accepted actual M1 inputs','inputs':'input-map.json','deliverable':'tests/output_recovery/run.sh and formal consumers/native fault fixture; root assigns separate test author','remaining':'Enumerate actual current sequences and expected complete prefixes; record real behavior without assuming failure or inventing RED.'},{'task':'010','result':'unchanged separately gated','interface_delta':'snapshot exact glyphMode default Unicode; Frame file methods unchanged; no device flush/output implied.'},{'task':'020','result':'unchanged separately gated; consumes008 actual output evidence','interface_delta':'Same Application/native owner; full modes/resources remain020;008 fault raw is producer input.'}], 'shared_interface_table_definition':'Reuse original report.md 重点依赖与现有123–162接口; producer/consumer responsibilities retained; only008-adjacent edges updated.','shared_interface_delta':[{'producer':'070/R10','consumer':'008','readiness':'accepted finite frame/baseline principles and lifecycle fence reused; old source does not prove new query/caret/2004/title failure boundaries.'},{'producer':'152/S008','consumer':'008 and020','readiness':'accepted byte counting/process unsafe/reopen and real native fault seam available; no unsafe CAN/ST recovery.'},{'producer':'102/I015 +112 +117 +122 +157 +162','consumer':'008','readiness':'actual caret/query/paste/editing/widget paths present on c5; test actual current generated sequences, no guessed offsets.'},{'producer':'008','consumer':'020/M1 freeze','readiness':'contract ready; actual008 output evidence still to be produced; not full020/041 completion.'},{'producer':'Application.snapshot/Frame','consumer':'010','readiness':'existing exact signatures preserved; no new export backend;010 own inputs remain gated.'},{'producer':'root shared-source barrier','consumer':'008/010/020 future authors','readiness':'root alone integrates/serializes product edits; current admission and parallel fullM archive are no-product-code work.'}], 'observability':[{'claim':'phase separation and actual emitted bytes','available':'public callbacks/post with file/control markers, real PTY all-wire, test-local syscall trace and public session results; capture lifecycle and failed phase before cleanup.'},{'claim':'successful device baseline','available':'same/changed/shortened/style/resize/profile public frame sequences + exact all-wire and controlled phase markers; independent source ordering for stopped branches.','limit':'RuntimeStats.frames measures frame generation, not successful device commits; zero-output alone is not baseline proof; memory replay is not realTTY recovery.'},{'claim':'fatal partial vs zero failure','available':'actual byte-prefix syscall returns, run error/cleanup results, same-process public run reopen, termios/signal/free trace; second app cannot clear process unsafe.'},{'claim':'query/caret modes','available':'Application.terminalCapabilities() immutable status plus caretSnapshot() logical coordinates and raw wire; Known/Unknown from actual protocol behavior, never assumed visible.'},{'claim':'primary and cleanup errors','available':'public exception/cleanup results plus real close wrapper return and native trace; preserve business-first/device-first ordering.'}], 'fault_method':{'reuse':'existing session_extensions --wrap=write/cjt_buffer_write/cjt_buffer_add/cjt_open/cjt_close/poll and interaction_a literal-transaction selector; real product writer/native ownership retained','required_formal_delta':'C002 zero/partial fatal, each actual CUP/SGR/UTF8/2004/title/caret/query/restoration prefix, successful short writes, EINTR, zero return and EIO; actual sequence-specific offsets frozen by independent author','R10_scope':'Original lifecycle wrapper and Cj consumer unchanged at current source; pty oracle changed to atomic resize/settled grid. Reuse unchanged accepted scenarios and actual later evidence; do not label all original R10 paths byte-identical.','no_probe_needed':True},'missing_public_questions':[],'known_nonblockers':['fullM archive pending mechanical publication','M160-S01 diagnostic precision suggestion remains open, no dispatch effect','B-M01→024 and T087→023 remain future mandatory'], 'scope_exclusions':['formal tests or test mutation','source correctness review','product/main edits','new APIs/test hooks','whole futureM2 plans or tests','cold builds or SDK/cache copies'], 'skill_use':{'using-superpowers':'read; subagent-stop applies','verification-before-completion':'read and applied to JSON/hash/scope checks; no functional success claims'}, 'role':'assigned independent admission judgment; actual serving-model identity not attested'})
report='''# TASK008 admission delta — READY for independent formal tests
Fixed input: accepted `6e3f26aaaeee9442fde91ce31d720a841eeda473` → main `c5a875f09cbb4f6fdb49eefaff14343e0d519630`; product/tests/native/examples/build scopes have zero Git diff.
Actual M162 `b1c92e7440efbc3cf4b2688bb5d3c5c50a7262e3a24ad1123776cc9c8f64c5eb` and M161 `b126ef3d726c4b5e01a6d145e70f519d87bae210c26de68f60101c98f8b50d51` supersede historical M-manifest gates; fullM archive is parallel metadata.
All named070/R10/152/117/112/122/162 prerequisites and supporting080/084/088/092/097/102/107/157 fixed acceptance references are in `input-map.json`; no author self-assessment is a verdict.
Original14DQ/task-self/shared-interface definitions and closed LC-PF001–003 at59bea are reused; originaldf9612e failure history and scoped-r1 are untouched.
Current Application/Frame public signatures, caret/status/session results and actual PTY/control phases suffice; no new product API or backend is needed.
RuntimeStats.frames is not a successful-device-commit counter: baseline proof combines controlled raw phases with independent source ordering where fatal stop prevents continuation.
Existing native fault seams retain real writer/open/close and support cumulative prefixes, EINTR, positive short success, zero-return/EIO, cleanup and same-process reopen observations.
Independent tests must enumerate actual current CUP/SGR/UTF8/2004/title/query/caret/restore sequences; this delta invents no exact offsets or product verdict.
Partial+fatal remains process-unsafe/no later terminal bytes; zero+fatal ends the run without invented partial-unsafe; no CAN/ST recovery or in-memory TTY claim.
R10 unchanged fence methods/scopes remain reusable; current writer/caret/input sequences require fixed008 evidence. Atomic-resize oracle changes are explicitly distinguished.
SDK1.2.0, gcc/ar, Node/Python, script/stty and normal stdx/UCD/warm-cache paths verified by read-only versions/path checks; no build or runtime probe.
Root retains the single product-author barrier and publishes the actual008 input manifest before assigning independent formal tests; product implementation still waits frozen tests.
010/020/021 retain their own gates; futureM2/027/041/fullLinux are outside this admission. B-M01→024 and T087→023 remain mandatory later.
No missing public question, new finding or blocker within this scope. M160-S01 remains a nonblocking diagnostic suggestion.
No tests/product/main edits, subagents, cold builds, new APIs or author reasoning used; only this new admission directory was written.
`dq.json` and `readiness-delta.json` contain bounded tables; `index.json` and `index.sha256` seal the report, input map and verification.
'''
(out/'report.md').write_text(report)
print('Prepared',len(records),'input references;',len(checks),'DQ rows;',len(report.splitlines()),'report lines')
