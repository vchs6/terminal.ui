from pathlib import Path
import json,hashlib,datetime,subprocess
B=Path('/workspace/work/theme-load-acceptance'); E=Path('/workspace/work/theme-load-execution'); R=Path('/workspace/work/terminal.ui'); P='fa6a46ec339ea0f098dea521c814226a7a373c7e'
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def put(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n')
def strict(p):
 def pairs(xs):
  d={}
  for k,v in xs:
   assert k not in d,(p,k)
   d[k]=v
  return d
 return json.loads(p.read_text(),object_pairs_hook=pairs,parse_constant=lambda s:(_ for _ in ()).throw(ValueError(s)))
now=datetime.datetime.now(datetime.timezone.utc).isoformat()
V=strict(B/'raw/verification.json');assert V['failed']==0 and V['check_count']==2252
for p,x in V['consumed_hashes'].items():assert h(Path(p))==x,p
M=strict(E/'manifest.json');assert h(E/'manifest.json')=='e7fc2d30586e99ab4236eb9455be98842c5de5f347f2e442a581cd1207b529a4'
seen=set()
for f in M['files']:
 q=Path(f['path']);assert not q.is_absolute() and '..' not in q.parts and str(q) not in seen;seen.add(str(q))
 for base in [E,E/'artifacts']:
  p=base/q;assert not p.is_symlink() and p.stat().st_size==f['bytes'] and h(p)==f['sha256'],p
  if p.suffix=='.json':strict(p)
assert len(seen)==276
idx=(E/'artifacts.sha256').read_text().splitlines();assert len(idx)==277
for line in idx:
 digest,name=line.split(None,1);assert h(E/'artifacts'/name.strip())==digest
assert (E/'manifest.json').read_bytes()==(E/'artifacts/manifest.json').read_bytes()
assert (E/'artifacts.sha256').read_bytes()==(E/'artifacts/artifacts.sha256').read_bytes()
assert len([p for p in (E/'artifacts').rglob('*') if p.is_file()])==278
assert (E/'raw/device-build/driver-source.cj').read_text().replace('repeat:None','repeat:Option<ThemeRequest>.None')==(E/'device-observation/src/main.cj').read_text()
extras={str(E/f['path']):f['sha256'] for f in M['files']}
for p in [E/'manifest.json',E/'artifacts.sha256',E/'post-seal-cleanup.json']:extras[str(p)]=h(p)
red=R/'docs/reviews/R15/async-red/raw'
f=[json.loads(s) for s in (red/'foundation/commands.jsonl').read_text().splitlines()];a=[json.loads(s) for s in (red/'async-probe/commands.jsonl').read_text().splitlines()]
assert all(x['exit']==0 for x in f) and [x['exit'] for x in a]==[0,0,0,1]
assert f[-1]['utc']<a[-1]['utc'] and "'loadTheme' is not a member" in (red/'async-probe/async-api-build.stderr').read_text()
for rel in ['foundation/commands.jsonl','foundation/foundation-run.stdout','async-probe/commands.jsonl','async-probe/async-api-build.stderr','git-identity.json']:extras[str(red/rel)]=h(red/rel)
# Preserve the complete preparation checkpoint, including its valid relative hash index.
prep=B/'preparation';prep.mkdir(exist_ok=True)
for name in ['findings.json','pending-matrix.json','pending-matrix.md','preparation.md','prepare.py','prepared-hashes.json','preparation-artifacts.sha256']:
 (B/name).rename(prep/name)
for line in (prep/'preparation-artifacts.sha256').read_text().splitlines():
 digest,name=line.split(None,1);assert h(prep/name.strip())==digest
base=strict(prep/'pending-matrix.json'); prepared=strict(prep/'prepared-hashes.json')
for f in prepared['inputs']:assert h(Path(f['path']))==f['sha256'];extras[f['path']]=f['sha256']
judgments=[
('PASS','091 manifest/command pre-post + own raw/verification.json','14组命令的274源记录稳定；final源/78正式输入/11环境文件/375依赖与371 stdx/ELF绑定核对，276原件和副本逐字节封存。'),
('PASS_REUSED','R15/async-red/raw/{foundation,async-probe}/commands.jsonl; E:raw/async-all','旧8d foundation实际0后async API缺失RED1；本轮foundation/API实际0和22行为case完成。all模式不额外执行独立infrastructure case，不虚增计数。'),
('PASS','090 report + round1/report + round2/report; E:raw/async-all/detail/atomic-caches.stdout','两轮I01修复与M01文档闭环；final双PASS、0 C/I/M，与本轮实际原件相互印证。'),
('PASS','fixed src/theme_request.cj, src/theme_loader.cj, src/application.cj; E:raw/async-all/detail/async-api-build.*','只读公开异步接口与root所有权符合冻结契约；实际公共API编译通过，包消费者亦通过。'),
('PASS','E:raw/async-all/detail/{lifecycle,queued-restart}.*','初态、inactive立即终态、dispose保留accepted历史及重启单调id/revision均有实际断言。'),
('PASS','E:raw/async-all/detail/{latest-success,candidate-order}.*','真实文件gate及UI提交前换代证据；旧请求Superseded首个新id稳定，最新意图独占提交。'),
('PASS','E:raw/async-all/detail/latest-failure.*','较新失败淘汰旧合法slow结果且不复活；已接受主题/终态保留。'),
('PASS','E:raw/async-all/detail/{session-fence,queued-restart,cleanup}.*','阻塞IO与排队Prepared跨关闭立即终结，旧worker晚到被session fence拒绝。'),
('PASS_SOURCE_AND_RUNTIME','090 final source; E:raw/async-all/detail/{pending-bound,session-fence}.*','精确1active+1pending+1candidate由源码证明；32文件请求实际只进入old和最新pending31，晚到worker仍占槽。无内部计数实测声称。'),
('PASS','E:raw/async-all/detail/post-capacity.*','普通post溢出拒绝，独立有界theme mailbox仍提交一次。'),
('PASS_SOURCE_AND_RUNTIME','090 final source; fixed theme_loader/application; E:raw/async-all/detail/{getter-reentry,build-reentry,current-cache}.*','检查锁序、锁外IO/parse/用户通知及提交前session/id重核；运行证据不冒穷举调度证明。'),
('PASS','E:raw/async-all/detail/{candidate-order,atomic-caches,recoverable}.*','missing/inapplicable/weight/schema等可预见失败先于theme/cache提交，旧frame与session保留。'),
('PASS_SOURCE_AND_RUNTIME','090 round1+round2; E:raw/async-all/detail/atomic-caches.stdout','final实际direct Row最小值溢出拒绝与finite clip成功；Column同checked allocator预检按轴一致源码与090证据闭环，不声称本轮新增Column用例。'),
('PASS','E:raw/async-all/detail/atomic-caches.stdout; fixed src/layout.cj','实际mounted subtree 1×1处理候选仍使用root Max×0；InvalidCandidate、旧Info0/0、节点/状态/getter/mount/frame保留。root identity guard不会被subtree改写。'),
('PASS','E:raw/async-all/detail/{current-cache,atomic-caches}.*','IO期间变化的当前stable样式缓存参与最后验证；原子布局/frame/revision及M1对照实际通过。'),
('PASS_FINITE_APIS','E:raw/async-all/detail/{atomic-caches,lifecycle,current-cache}.*','Component/NodeRef/Observable业务状态与订阅身份保持；仅当前API，未把缺席的完整focus/edit/scroll控件算通过。'),
('PASS_SOURCE_AND_RUNTIME','090 preview/cache analysis; E:raw/{async-all,layout,theme-integration}','paint-only保留live测量缓存、geometry清理；preview独立树不写Frame且无getter/build/mount重放；preview仍有CPU开销。受影响layout/Theme新跑0。'),
('PASS','E:raw/async-all/detail/reload-origin.*','reload只冻结accepted File；失败/进行中File不替换来源，memory/preset清源，Prepared(readFile)保留来源。'),
('PASS','E:raw/async-all/detail/{relative-origin,synchronous-values,reload-origin}.*','cwd请求时冻结、sourceName不冒文件、同步解析不自动提交的实际断言通过。'),
('PASS','E:raw/async-all/detail/observability.*','UI只读查询自动依赖/失效；background查询不绑定UI、不执行getter、不pump提交。'),
('PASS','E:raw/async-all/detail/{event-post,getter-reentry,build-reentry}.*','callback/post正常提交；getter/structure中load/reload预先ReentrantEvaluation，id及已接受主题保持。'),
('PASS','E:raw/async-all/detail/{multi-application,background-race}.*','两个App同时进入各自真实gate，八后台请求id唯一且max提交；不夸大为任意并发穷举。'),
('PASS','E:raw/async-all/detail/cleanup.*; E:raw/device-pty-bound','cleanup异常聚合、关闭pending、引用/订阅/绑定/posts释放；真实PTY失败后资源全0。'),
('PASS','E:raw/async-all/detail/{recoverable,exception-boundary}.*','读取/格式/容量失败可恢复；accept后业务异常按runtime清理且Applied/info不回滚。'),
('PASS_CONTROLLED_REAL_PTY','E:raw/device-pty-bound; E:device-observation; raw/verification.json detail.device','真实PTY先正常frame后接受主题，writer实际4字节再受控EIO；Applied1/info1保留，termios/3 handlers/close恢复，资源0。ParserUnsynchronized、visual state not restored明确保留；非自然故障或GUI视觉证明。'),
('PASS_SOURCE_ONLY','090 final source; fixed theme_loader/theme_request','UInt64上界检查先于请求/版本变更，禁止wrap；没有public seed，不伪造遍历计数上界实跑。'),
('PASS','E:raw/async-all/detail/commands.jsonl + per-case stdout/stderr/events; raw/verification.json','全部22 actualexit0、sentinel正确、controller_error null、真实gate顺序/enter/release完整；另clean2条为重复代表case，不作24唯一用例。'),
('PASS_SCOPED_REUSE','E:raw/reuse; previous080084088152097 accepted records','211/213与213/213及早期6路径差异有明确对照；旧无pending候选行为有限复用，当前22/layout/Theme/device覆盖新路径；未冷跑旧suite/PNG。旧C1时序限制不变。'),
('PASS','E:raw/bundle; E:raw/package/member-inventory.json; raw/verification.json detail.package','正常mandatorylint bundle0，508 warnings原样保留；实际打开CJP全部184文件字节==fa==clean展开后源，四preset包含。整包checker另项仍OPEN。'),
('PASS_FINITE_PACKAGE_RUN','E:raw/{clean-library-build,clean-consumer-build,clean-async}; E:tools/clean-run.py','clean库与完整正式public consumer各build0，仅依赖路径变；正式run_controlled+同gate实际latest-success/atomic-caches各0，未称clean重跑全部22。'),
('PASS','raw/final-metadata.json; E:raw/device-build; E:manifest.json','strictJSON/原件hash/exit/身份分别核；初始None harness编译1保留，sole Option资格修正后0；2252元数据/原始断言复核不当成2252产品测试。'),
('PASS','fixed docs/product/theme.md; canonical design; this report/matrix','产品说明同步值与load/request/info/acceptedFile边界一致；允许root投影026及089–092有限完成，当前pending状态等待机械投影而非功能缺陷；本角色不改主仓。'),
('EXCLUDED_OPEN','TASK092 brief; prior088 T087-G01; E:raw/identity/fixed-inputs.json + raw/package/member-inventory.json','T010要求themes，与旧023 checker allowlist冲突及composition/benchmark缺项仍OPEN；027全控件展示、wholeLinux/M2/release未验收。')]
assert len(judgments)==len(base['rows'])==33
for row,(status,evidence,judgment) in zip(base['rows'],judgments):row.update(status=status,evidence=evidence,judgment=judgment)
base.update(utc=now,phase='final_independent_acceptance',acceptance_verdict='PASS_ASYNC_SCOPE',task092_ready=True,pending_mustpass=0,evidence_aliases={'E':str(E),'090':'/workspace/work/theme-load-review','fixed':P},product_executed=False)
put(B/'acceptance-matrix.json',base)
(B/'acceptance-matrix.md').write_text('# TASK092 独立逐项验收\n\nPASS_ASYNC_SCOPE；32项当前义务满足，1项后续范围排除且保持OPEN。E = `/workspace/work/theme-load-execution`；090 = `/workspace/work/theme-load-review`；fixed = fa6a46e。证据路径的花括号表示并列文件，不代表新增执行。\n\n| ID / 合同 | 义务 | 结论 | 原件与判断 |\n|---|---|---|---|\n'+''.join(f"| {r['id']} / {r['contract']} | {r['obligation']} | {r['status']} | {r['evidence']}；{r['judgment']} |\n" for r in base['rows']))
meta={'utc':now,'failed':0,'consumed_originals_rehashed':len(V['consumed_hashes']),'execution_manifest_sha256':h(E/'manifest.json'),'execution_manifest_contents':276,'source_and_curated_hash_checks':552,'execution_checksum_entries':277,'execution_curated_physical_files':278,'count_definition':'276 content + manifest =277 indexed; checksum index itself gives278 physical files','historical_red_verified':True,'harness_only_qualification_verified':True,'strict_json_checked':True,'product_executed':False}
put(B/'raw/final-metadata.json',meta)
put(B/'reviewed-hashes.json',{'utc':now,'source':P,'preparation_inventory':'preparation/prepared-hashes.json','raw_consumed_inventory':'raw/verification.json#consumed_hashes','final_extra_inputs':extras,'limits':'Hash equality establishes identity, not behavior. Actual command/raw assertions and source review are assessed separately in acceptance-matrix.json.'})
put(B/'findings.json',{'task':'TASK092','utc':now,'candidate':P,'verdict':'PASS_ASYNC_SCOPE','current_findings':[],'severity_counts':{'Critical':0,'Important':0,'Minor':0},'accepted_rows':32,'excluded_rows':1,'pending_current_mustpass':0,'open_followup':[{'id':'T087-G01','owner':'TASK023','status':'OPEN','reason':'whole checker rejects required themes; composition/benchmark absent'}],'limits':['UInt64/locks/exact internal capacities use source proof','current Component/NodeRef/Observable APIs, not full future controls','real PTY controlled EIO preserves Applied/history; unsafe visual state remains unrestored','clean package actual2 representative cases, full22 executed from fixed source','old087 C1 temporal identity caveat retained','027, wholeLinux, M2 and release excluded'],'product_executed_by_acceptor':False,'main_modified':False,'author_selfassessment_used':False,'subagents':False})
