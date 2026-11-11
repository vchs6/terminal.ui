from pathlib import Path
import json,hashlib,datetime,shutil,collections
B=Path('/workspace/work/theme-acceptance');E=Path('/workspace/work/theme-execution');R=Path('/workspace/work/terminal.ui');now=datetime.datetime.now(datetime.timezone.utc).isoformat()
def load(p):return json.loads(Path(p).read_text())
def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def put(p,d):Path(p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
for name in ['integrity','observations','metadata']:assert load(B/'raw'/f'{name}.json')['failed']==0
history=B/'preparation';history.mkdir(exist_ok=True)
for line in (B/'preparation-artifacts.sha256').read_text().splitlines():
 s,n=line.split(None,1);n=n.strip();target=history/n
 if not target.exists():assert h(B/n)==s;shutil.copyfile(B/n,target)
 assert h(target)==s
shutil.copyfile(B/'preparation-artifacts.sha256',history/'preparation-artifacts.sha256')
for name in ['integrity','observations']:
 d=load(B/'raw'/f'{name}.json');put(B/'raw'/f'{name}-summary.json',{k:v for k,v in d.items() if k!='checks'}|{'check_count':len(d['checks']),'full_local_result_sha256':h(B/'raw'/f'{name}.json'),'full_result_omitted_reason':'Repeated successful per-file assertions; original fixed087 manifest and runnable verifier retained, full result remains locally hash-addressed.'})
judgments=[
'338条执行前后源/tests/native记录等8d，16组实际命令/UTC；563原件copy及564index全同，环境375deps/371stdx核实。lock仅5条记录排序漂移另明示。',
'原085固定74b根正常build0、values因缺cjtui.theme exit1、negative门禁未进入；本次正式76文件对8d且原16negative/4preset字节同，新增合同断言未降级。',
'独立086完整原审→round1四项修复→8d删除4行无引用helper，最终source spec/quality PASS；未替代087实际证明。',
'最终values完整正向验证36typed keys、三态/相等/不可变查询；公开类型与访问限制结合固定源/复用真实编译负例成立。',
'最终values/integration新build/direct0。16同fixture的旧type/access错误及前置正向gate成立，相关公开声明未变；按限定scope复用，非8d新negative执行，C1缺pre-run身份仍保留。',
'正式来源/spacing/runtime断言通过：slots替换与解绑、getter Unset和删除区分、widthAuto/ValueAuto/Reset；单声明权威源码与086相符。',
'两个拒绝setter回归均真实执行，ReentrantEvaluation后原uniform padding仍更新到2,2、旧位置清空且mounted不变；源先checkDefinitionChange再slot改变。',
'17role schema及实际primitive检查通过，role挂载后拒改，不授予新kind能力；全局能力投影/named非法目标均正常公开测试。',
'integration手写逐字段来源golden通过；explicit/reversed styles/role/global/继承default共用resolver，数组copy/清空行为已证。',
'values/integration状态golden通过；每来源内Disabled→Selected→Focused→Normal，后named normal优先，Reset终止且false/0/Default保留。',
'真实Frame证明root8文本seed、父解析继承、子role覆盖/Reset默认；非文本属性不继承，公开文档已解释。',
'integration逐cell证明三种fill来源：root背景-only、本地完整Style、继承不fill；Classic空白inverse/underline兼容，hidden/clip有效。',
'同值background但fill来源变化及同值foreground显式mask变化均真实重新绘制；resolver/Runtime/LayoutNode/Frame保持唯一。',
'RichText公开回归和本次mask golden通过；本组件explicit/Reset压span，继承非explicit，span背景不填盒。',
'装饰cascade和旧decoration有效复用通过：派生border fg/Reset、ValueDefault、独立shadow槽、shadow便捷入口及极端偏移。',
'全部spacing正式Frame断言通过，四边pad/width/min/weight/gap/alignment有实际输出；sat/checked路径保持。',
'最终integration与clean同源consumer执行Row flex/Column约束宽重测，祖先高及兄弟位置golden通过；测量与paint共用allocateMain。',
'宽0硬行、CRLF、大簇独占裁剪行、无末尾假行、组合零宽簇及显式height/viewport测试通过。',
'最终offline/controlled/GUI证明真实ellipsis预算：ABC…与A...区分，0..4/整簇/exactfit/clip/垂直隐藏规则通过，未只验marker helper。',
'正式Glyph布局/cache/逻辑文件断言成功；同mounted root mode往返、分配宽/padding/span前缀以及device/offline隔离已证。',
'3输入control+7profile原件重断言，fd1 map仅controlled synthetic，缺marker104pair映射保持；实际A...→ABC…→A...且同setter无多余row。',
'最终values执行所有36property/17role/10variable kinds/4states、literal/reset/ref/unused-invalid/闭集错误，源码guard/schema单路径。',
'最终schema源类型/printable/name/Int64/Color等全部断言完成；原生date/time不冒string，无Float中转整数。',
'修复root优先及variable value/extra双向正式回归新执行成功；源声明序、syntax/version/rootrequired/forwardref按合同。',
'source/name/keyPath/Rune位置及ref值/nearest-parent允许fallback的正式断言通过，无伪造位置。',
'readFile有限读取、UTF8/空NUL、明确绝对来源与literal特殊路径、parse label不同文件的正式断言通过；不主张异步reload。',
'原全部联合预算及危险深输入通过；边界有些合法进入下游SyntaxError/UnknownKey，不伪称这些文档schema有效。',
'encoded-key151输入属于192个生成输入整体hash核对；6contexts×11spellings及103转义/直接/值comment控制按原断言成功，未改预算。',
'上游public Lexer原始token预算→Parser唯一语义路径；累积prefix/dotted/inline栈、comment计token和错误边界由源码审及本次正式实测支持。',
'4canonical/test/shippedTOML逐byte同，preset公开parse/schema路径与独立规则golden成功，source标签/只读bridge无cwd依赖。',
'最终四preset手写Frame颜色/空白/重用accent规则通过，Classic原默认像素保持；这是基础场景。',
'两真实GUI各4preset及各2Glyph mode共12原PNG，实际trace==stdout/native viewport、binaryhash、80×25/termios/exit通过；只接受当前基础场景。',
'仅样式/state/presence变更真实Frame更新且mounted回归通过；不将未来026主题提交/编辑全状态保持冒充本轮。',
'contract/layout/decoration/runtime-core/RichText原件按95执行前201来源复用；仅decoder4行无引用删除不同，新final positives重验受影响语义。274旧Glyph源及39PNG仅不变backend事实。',
'正常TOML0.2.3与官方stdx1.2.0-beta.02.1/SDK1.2证据，375deps及371stdx文件hash；单向包与Alignment根入口兼容，clean路径无作者target。',
'8d正常cjpm bundle0且491实际warning保留；wholechecker真实exit1保留OPEN_TASK023，不能把其themes拒绝变成通过或本轮漏交主题。',
'实际CJP SHA29ce7c…，175成员逐byte等8d及clean构建后源，四themes已交；安全/product-only边界独立检查，缺composition/benchmark仍后续。',
'实际解包source-only主库build0、完整正式integration源仅manifest dep路径改动、build/direct0；没有复制private cjtui target或隐藏stdx flags。',
'168strictJSON、563原件copy/564index/565files，无异常成员；12正常host与Xorg已退出后seal，原PNG不重画，1643省略生成件hash核实。',
'C1执行后hash不能追认pre-proof；95 pre201只按原范围复用；8d新执行单独338pre/post证明。早期lock记录和final锁仅依赖顺序差异，字节差异公开。',
'文档已解释visualStates外观/rootseed/encodedkey/stdx与后续加载；原AC013025及085–088有限foundation可接受，机械投影不改主仓。',
'T006–008/026/089异步、027全部控件showcase、TASK023 whole-release/完整Linux/M2/其他平台仍pending。']
matrix=load(B/'pending-matrix.json');assert len(judgments)==len(matrix['rows'])==42
for i,(row,j) in enumerate(zip(matrix['rows'],judgments),1):
 row.update(status='passed',judgment=j,received_evidence=['raw/integrity-summary.json','raw/observations-summary.json','raw/metadata.json'],within_current_scope=True)
 if i in [5,34]:row['status']='passed_with_scoped_reuse'
 if i==36:row['status']='passed_foundation_release_gate_open'
 if i==40:row['status']='provenance_limit_preserved'
 if i==42:row.update(status='excluded_followup_pending',within_current_scope=False)
matrix.update(utc=now,phase='final_independent_acceptance',acceptance_verdict='PASS_FOUNDATION_SCOPE',task088_ready=True,status_counts=dict(collections.Counter(r['status'] for r in matrix['rows'])))
put(B/'acceptance-matrix.json',matrix)
lines=['# TASK088 逐条验收矩阵','','结论 PASS_FOUNDATION_SCOPE。状态区分执行通过、限定复用、保留的最终发行门禁和后续排除范围；没有42项全平台通过含义。精确原件位于087 artifacts/raw，相应逐文件hash及命令见本验收raw摘要。','','| ID / 合同 | 义务 | 状态 | 最终独立判断 |','|---|---|---|---|']
for r in matrix['rows']:lines.append(f"| {r['id']} / {r['contract']} | {r['obligation']} | {r['status']} | {r['judgment']} |")
(B/'acceptance-matrix.md').write_text('\n'.join(lines)+'\n')
put(B/'findings.json',{'task':'TASK088','utc':now,'product':matrix['candidate'],'phase':'final_independent_acceptance','verdict':'PASS_FOUNDATION_SCOPE','assessment_complete':True,'task088_ready':True,'current_mustpass_product_findings':[],'current_scope_quality':{'critical':0,'important':0,'minor':0},'open_outside_foundation':[{'id':'T087-G01','status':'OPEN','scope':'TASK023 final integration/release gate','actual_exit':1,'observed':'Development/unexpected file in bundle: themes/light.toml','also_missing':['examples/composition/cjpm.toml','benchmarks/rendering/cjpm.toml'],'independent_disposition':'T010 requires themes; currentT012/AC087 normal bundle + clean SDK/stdx consumption proven. complete-linux023.a–d explicitly owns checker negative controls and final required deliverables. No release PASS.'}],'metadata_observations':[{'id':'T088-O01','kind':'scope-qualified reuse','text':'16 C1 compile-negatives retained with post-run source/uncaptured pre-run compiler limitation. Actual errors + exact fixtures + unchanged relevant public declarations + final new positive controls support this limited compile contract, not new8d execution.'},{'id':'T088-O02','kind':'external-lock-byte-order-drift','text':'Early lock d39e3d166dde08c5412838a6ff34fdfa931e0c40fb566e7fac670a9cb0086ee9 differs from final/current a29edd7f2ac024e90fc03c1e314ef0f054c9b1c2e7021176cc425d6a8ee3e6cf. Unique matching permutation of same five exact dependency records proves order-only difference; original metadata not rewritten, no historical pre-run proof inferred.'}],'limitations':['Async026/089 and full027 controls/showcase excluded.','FullLinux/M2/TASK023 release/other platforms pending.','Synthetic ioctl maps are controlled branches; no current Theme kernel VT execution claimed.','39 R16 PNGs reused only unchanged backend/font/kernel facts.','VTE native observer is viewport text, not full cell style metadata; explicit Unicode ZWJ may shape differently.','Actual serving model/effort independently unverified.']})
prep=load(B/'prepared-hashes.json');external=[]
for path in [E/'report.md',E/'findings.json',E/'scope.json',E/'manifest.json',E/'artifacts.sha256',R/'openspec/changes/implement-theme-styles/design.md',R/'openspec/changes/complete-linux-integration/tasks.md']:
 external.append({'path':str(path),'sha256':h(path),'bytes':path.stat().st_size})
for rec in prep['independent086']:assert h(rec['path'])==rec['sha256']
put(B/'reviewed-hashes.json',{'utc':now,'candidate':matrix['candidate'],'canonical_contract_sha256':prep['contract_sha256'],'external_final_inputs':external,'independent086':prep['independent086'],'prepared_fixed_git_inventory_sha256':h(B/'prepared-hashes.json'),'full_original087_manifest_sha256':h(E/'manifest.json'),'source_and_package_verification':'raw/integrity-summary.json','host_and_oracle_verification':'raw/observations-summary.json','metadata_scope_verification':'raw/metadata.json','read_boundary':'No author-directory reads. Author paths in copied raw metadata were inert labels only.'})
visuals={'gui/vte-Dark/preset.png':'dark底色/浅色x/蓝色粗体y；其余空白仅背景。','gui/vte-Light/preset.png':'白底深色x/蓝色粗体y。','gui/xterm-HighContrast/preset.png':'黑底白x/黄y，真实基本色映射。','gui/xterm-Classic/preset.png':'默认背景/正文与青色y，无额外边框。','gui-glyph/xterm-Ascii/preset.png':'宽0..4为空/./../.../A...；真实80列Row保留ABCDEq，不套用5列fixture。','gui-glyph/vte-Unicode/preset.png':'宽0..4为Unicode marker前缀；底部ZWJ呈现宿主shaping，不宣称每种簇物理advance。'}
put(B/'raw/visual-inspection.json',{'utc':now,'method':'Direct view_image of6 original087 PNGs; all12 original hashes/native/trace checked separately. No reconstruction.','images':[{'path':str(E/'raw'/p),'sha256':h(E/'raw'/p),'observation':s} for p,s in visuals.items()]})
put(B/'proposed-integration.json',{'utc':now,'proposal_only':True,'main_edited':False,'fixed_product':matrix['candidate'],'accept':{'AC013':'foundation typed cascade/actual layout/style updates','AC025':'foundation schema/diagnostics/budgets/presets','AC085':'fixed independent formal source/RED chain','AC086':'combined source spec/quality review','AC087':'foundation execution/package/clean public consumer with documented reuse limits','AC088':'PASS_FOUNDATION_SCOPE'},'keep_pending':['T006–008/026/089 async loading','027 full controls/showcase','TASK023 whole checker/release','fullLinux','M2','other platforms'],'keep_open':['T087-G01 themes checker allowlist and missing composition/benchmark'],'followup':'Root may mechanically project finite acceptance and admit next eligible task; this role does not edit status or start implementation.'})
print(json.dumps({'verdict':matrix['acceptance_verdict'],'rows':42,'statuses':matrix['status_counts']},ensure_ascii=False))
