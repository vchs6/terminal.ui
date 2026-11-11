from pathlib import Path
import json, hashlib, datetime, shutil, collections
B=Path('/workspace/work/glyph-acceptance')
E=Path('/workspace/work/glyph-execution/curated-r16-execution')
R=Path('/workspace/work/terminal.ui')
now=datetime.datetime.now(datetime.timezone.utc).isoformat()
def read(p): return json.loads(Path(p).read_text())
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def write(p,d): Path(p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
prep=read(B/'preparation-hashes.json')
for p in ['raw/integrity.json','raw/host-verification.json','raw/oracle-verification.json','raw/red-lineage-verification.json']:
 assert read(B/p)['failed']==0
assert sha(E/'artifacts.sha256')=='9e08fce5eccbb44c4a035a175c828667911cc19ecb157da2824e9920229eab43'
assert sha(E/'manifest.json')=='a1f9ff4cb1c7804d4e04c8e78c3060c7b1041e06cb9c2eefbb09cf0c3807f597'
visuals={
'gui/xterm/initial.png':'实际 GUI：红色中，é/中文/emoji，保守替换 ??，BOX 边框；字体绘制与字节层分开判断。',
'gui/vte/auto.png':'实际 GUI Auto：红色 ??，é/中文/emoji，保守替换与 BOX 保留。',
'vt/glyph-root-auto/initial.png':'实际 VT Auto：红色 ??，映射 é 保留，其余缺映射等宽问号；ASCII 共享边框及 BOX。',
'vt/glyph-root-unicode/initial.png':'显式 Unicode 原字符输出，当前 VGA 缺字方块可见；不宣称当前字体能绘制全部字符。',
'vt/glyph-root-deny-auto/initial.png':'受控 GIO EACCES 后 Auto 等宽 ASCII 与边框。',
'vt/session-wire/exit.png':'退出 native 屏幕仅 CJTUI_SESSION_READY，未见 OSC payload 文本。',
'vt/glyph-uid1000-auto/initial.png':'真正 UID/EUID1000 与 root Auto 相同替换、BOX 和边框。',
'vt/session-unknown-title/exit.png':'退出屏幕仅 CJTUI_SESSION_READY，无 title payload 泄漏。',
'vt/glyph-root-auto/narrow.png':'宽转窄 A 后无第二列残留，第二行和 BOX 保持。',
'gui/vte/narrow.png':'GUI 宽转窄 A 后无第二列残留，实际 viewport 的第二行和 BOX 保持。'}
write(B/'raw/visual-inspection.json',{'utc':now,'method':'Original PNGs displayed via view_image, independent visual inspection; no regenerated screenshots. All 39 originals hashed; 21 PPM/PNG decoded RGB equivalence separately checked.','images':[{'path':str(E/'raw'/p),'public_path':'docs/reviews/R16/execution/raw/'+p,'sha256':sha(E/'raw'/p),'observation':v} for p,v in visuals.items()]})
judgments=[
('原件完整链成立：固定 product/root/test 对象，475 execution source、296 dependency、36 external inputs 重算；无作者报告输入。','raw/integrity.json;preparation-hashes.json'),
('原正常根 build0；正式 API/internal 缺产品符号 RED1 原日志 hash 相符。两个独立 fixture 修复仅 getter/setter 与 serial holder，原字面量/oracle 不变，保留原设施失败。','raw/red-lineage-verification.json;docs/reviews/R16/test-supplements/observable-api/review;docs/reviews/R16/test-supplements/capture/review'),
('复用095独立 PASS_CODE_SCOPE / quality PASS，0 C/I/M；自有源核查与096实际证据补足执行范围。metadata纠正不改变code结果。','docs/reviews/R16/code-review/report.md;docs/reviews/R16/code-review/handoff-correction.md'),
('SDK1.2.0 正常根/API/public/rich build 与直接 binary 全0；公开构造、legacy参数和新API沿正式消费者验证。','execution/raw/root-build;execution/raw/glyph-api;execution/raw/glyph-public;execution/raw/glyph-rich;raw/integrity.json'),
('完整正向先成功，联合及六个 var-local 独立负例均编译拒绝；源码能力值 readonly、构造包内、无公共bitmap。','execution/raw/glyph-negative;source/src/terminal_glyph_capabilities.cj;raw/integrity.json'),
('25正式 raw 与真实Host显示 run一次 fd1 probe；Unicode/Ascii override不重探、不改caps；离线不探测、close后快照保留。','raw/oracle-verification.json;raw/host-verification.json'),
('真实 tty1 char4:1/KD_TEXT；formal alias/PTY/regular/nontext不读map。实际产品仅当前fd1，无额外VT/vcs读取。','raw/host-verification.json;raw/oracle-verification.json;source/native/cjtui_glyphs.c'),
('65535pair/262140bytes 单次有界读、8192bitmap与free路径由source/095及正式native日志验证；空map和65535重复pair不混淆。真实303pair与1212byte observer逐pair一致。','raw/native-map-crosscheck.json;raw/oracle-verification.json;source/native/cjtui_glyphs.c'),
('source/reason/errno/count 闭集及合成失败正确；真实kernel EACCES13只由self-launcher seccomp控制，不冒充普通用户自然失败。','raw/oracle-verification.json;raw/host-verification.json;execution/raw/vt/glyph-root-deny-auto'),
('唯一私有policy工厂、8192防御复制；width0/负值与正预算边界由13正式internal及源码验证，非固定<=2策略。','execution/raw/glyph-internal;source/src/glyph_render_policy.cj;docs/reviews/R16/code-review/report.md'),
('ASCII/mapped gate、BMP单列、组合/VS/ZWJ/nonBMP整体等宽投影由正式internal/session及实际VT raw验证，无NFC业务重写。','execution/raw/glyph-internal;raw/oracle-verification.json;raw/host-verification.json'),
('共享边框表及专用ASCII→?→space 有限链，empty/no-question/no-border原raw和diagnostic通过；真实BOX存在。','raw/oracle-verification.json;raw/visual-inspection.json;source/src/glyph_render_policy.cj'),
('G012优先：未知设备Auto conservativeUnicode逐scalar宽度和Cell预算相等才放行，超预算减法防溢；internal及GUI9stage验证保留/替换和零bytes。','execution/raw/glyph-internal;raw/host-verification.json;source/src/glyph_render_policy.cj'),
('generatedEllipsis实际纯接口及true/false宽策略、mapped/missing、预算边界由13internal和源码验证；字面…只按存储width投影。未实现真实TextOverflow。','execution/raw/glyph-internal;source/src/glyph_render_policy.cj'),
('Application设备private produce/离线入口向唯一RuntimeSession.renderLayout传同一policy；无第二Frame、snapshot或布局内核。','source/src/application.cj;source/src/runtime_session.cj;docs/reviews/R16/code-review/report.md'),
('marker字符串进入测量cache key；离线Auto/Unicode/Ascii交替和实际mounted模式切换正确。中途mounted交替的完整时序由源码及095证明，不伪称新增专门runtime case。','source/src/runtime_session.cj;execution/raw/glyph-public;raw/host-verification.json;docs/reviews/R16/code-review/report.md'),
('setter仅实际变化invalidate；run在pump前固定实际请求、成功后提交对应基线，中途变更下轮仍不等。源码/095证明时序，实际模式往返提供一般执行控制。','source/src/application.cj;docs/reviews/R16/code-review/report.md;raw/host-verification.json'),
('old/new各自profile投影后列/style等价才零写；真实VT前四p fence和GUI VS16/literal零增量，与正式单元/PTY一致。','raw/host-verification.json;raw/oracle-verification.json;execution/raw/glyph-internal'),
('正式frame检查宽→窄/缩短/尺寸/零面积，写成功才提交baseline；真实A窄化nativecells/PNG无尾列残留。故障语义沿既有writer复用，不宣称新增所有VT故障。','execution/raw/glyph-internal;raw/visual-inspection.json;source/src/application.cj;raw/oracle-verification.json'),
('真正plain/ANSI文件完整Unicode、30列数据匹配；默认/显式Auto离线Unicode，Ascii仅生成marker，设备map/最近profile不污染文件路径。','execution/raw/logical-files;raw/host-verification.json;execution/raw/glyph-public'),
('13 internal/25 Glyph/native-owner及setup-signal/36 focused Session和既有runtime/12PTY原件可复用；native session writer/encoding/color/unicode与BASE字节相同，不声称重新全830。','raw/oracle-verification.json;execution/raw/reused-prior;execution/raw/native-session;docs/reviews/R16/code-review/report.md'),
('正式allocation/read失败free、session部分写/未知前缀/主错误/恢复等36原件重新oracle断言；9正常真实host exit0/termios恢复及单一owner，不改错误优先级。','raw/oracle-verification.json;raw/host-verification.json;execution/raw/native-session'),
('QEMU TCG真实Linux6.12.107 tty1 80×25，新执行当前同binary；cpio内容及部署hash可追溯，旧权限失败与权限only25变更保留。','raw/host-verification.json;execution/raw/fixed-inputs-and-binaries.json;execution/raw/vt'),
('固定bootcmdline/sysfs default1/无codec或font变更链 + Unicode nativecells é、中、文及原PNG构成经验前置。IUTF8/fontmap不是输出UTF8证明；未查询每console当前codec。','raw/host-verification.json;raw/visual-inspection.json;execution/raw/vt/glyph-root-unicode'),
('同正式093未wrapper业务main的正常Application(root) Auto，root8stage、UID/EUID1000 Auto、Unicode/Ascii及controlleddeny均有实际fd1/源binary/map/native/raw/PNG/restore链。','raw/host-verification.json;raw/native-map-crosscheck.json;raw/visual-inspection.json'),
('真实XTerm398和VTE0.80.1各9stage，XTEST输入、实际stdout零写阶段、nativeprint/GTKviewport、原PNG、未知caps不变及termios恢复。VTE文本观察不冒充完整cell属性。','raw/host-verification.json;execution/raw/gui;raw/visual-inspection.json'),
('39原PNG逐hash核验，21PPM→PNG RGB一致，10代表图直接视觉核查；native数据与实际trace写/输入fence交叉验证，不使用作者自评或oracle重画。','raw/integrity.json;raw/host-verification.json;raw/visual-inspection.json'),
('P30新增有限通过：正式148 Direct mode0真实tty1 wire156bytes/unknown-title6，原verifyLive不改通过；native退出只READY无OSCpayload，termios/close0。copy/title SentUnconfirmed、icon Unsupported、restoreUnknownUnavailable；未覆盖所有路由/故障/输入resize。','raw/oracle-verification.json;raw/host-verification.json;execution/raw/vt/session-wire;execution/raw/vt/session-unknown-title'),
('正常cjpm bundle exit0，强制lint实际353warnings完整保留，无参数/配置禁lint。全checker exit1保留composition/benchmark不足，不升级发行。','raw/integrity.json;execution/raw/bundle;execution/raw/bundle-advisories.json;execution/raw/whole-bundle-check'),
('实际CJP143成员逐byte等固定product与clean构建后source；正常clean build及只改依赖路径的公开APIconsumer build/direct0。','raw/integrity.json;execution/raw/package-members.json;execution/raw/package-bytes;execution/raw/clean-api-build-run'),
('096 1389原件→副本、1390index含manifest、1391实际含index全同，206 strictJSON；封存晚于正常host全部reaped。失败原件仍在，无运行中logger封存。','raw/integrity.json;execution/manifest.json;execution/raw/seal-summary.json'),
('本轮提供真实generatedEllipsis接口、mode及policy输入。Theme085固定补充只是后续控制；013前缀预算/025实际ellipsis/088矩阵仍待root准入和执行。','source/src/glyph_render_policy.cj;docs/reviews/R15/glyph-refresh;preparation.md'),
('父041、008/020/030等未由本轮全关；wholeLinux/M2/fullrelease保持pending，wholebundle checker不足仍公开。此项为范围边界，不是当前有限Glyph缺陷。','execution/report.md;docs/reviews/R18/acceptance/report.md;proposed-integration.json')]
matrix=read(B/'pending-matrix.json')
for row,(judgment,evidence) in zip(matrix['rows'],judgments):
 row.update(status='passed',received_evidence=evidence.split(';'),judgment=judgment,within_current_scope=True)
 # Source paths are descriptive locations in own fixed source, public evidence paths relative to repository.
 if row['id']=='G97-28':row['status']='passed_finite_subset'
 if row['id']=='G97-32':row.update(status='interface_passed_layout_pending',within_current_scope='interface only; future Theme layout excluded')
 if row['id']=='G97-33':row.update(status='parent_scope_pending',within_current_scope=False)
matrix.update(phase='final_independent_acceptance',acceptance_verdict='PASS_FINITE_SCOPE',task097_ready=True,utc=now,evidence_prefixes={'execution/':'docs/reviews/R16/execution/','source/':'local fixed git source (omitted from archive)','raw/':'this acceptance archive/raw/'},status_counts=dict(collections.Counter(r['status'] for r in matrix['rows'])))
write(B/'acceptance-matrix.json',matrix)
lines=['# TASK097 逐 AC 验收矩阵','','结论 PASS_FINITE_SCOPE；30 项 passed、1 项有限 P30 passed、1 项接口通过/后续布局 pending、1 项父范围 pending。历史 pending-matrix 保持原字节。','', '证据 execution/ 表示 docs/reviews/R16/execution/，raw/ 为本报告原件，source/ 为固定 Git 对象的本地副本（不随归档）。','','| ID / 合同 | 义务 | 状态 | 独立判断与证据 |','|---|---|---|---|']
for r in matrix['rows']:lines.append('| '+r['id']+' / '+r['contract']+' | '+r['obligation']+' | '+r['status']+' | '+r['judgment']+'<br>'+ '; '.join(r['received_evidence'])+' |')
(B/'acceptance-matrix.md').write_text('\n'.join(lines)+'\n')
old=read(B/'findings.json')
if old.get('phase')=='read_only_preparation':write(B/'preparation-findings.json',old)
write(B/'findings.json',{'task':'TASK097','phase':'final_independent_acceptance','utc':now,'verdict':'PASS_FINITE_SCOPE','assessment_complete':True,'task097_ready':True,'quality':{'critical':0,'important':0,'minor':0},'findings':[],'observations':[{'id':'OBS-01','kind':'superseded_historical_contract_wording','text':'G012/A005明确覆盖旧Unknown→Unicode文字；设备Auto采用conservativeUnicode。无冻结合同阻断矛盾。'},{'id':'OBS-02','kind':'handoff_metadata_correction','text':'095原ENOENT属于root转述错路径；真实session-artifacts-sha256只覆盖25GlyphSession子树。未读作者目录；不定性为作者造假/产品缺陷。'},{'id':'OBS-03','kind':'helper_failures_retained','text':'096原helper/deployment/cache/wholechecker失败分类保留；097自有SGR计数、real场景无syscall文件、bytes/str helper错误的首次脚本与失败输出保留，修复仅核验器。一次终端摘要对list误用items亦仅展示失败，不影响任何已通过验收器。'}],'limitations':['Actual serving model/effort independently unverified.','UTF8 prerequisite empirically established only for recorded boot chain; IUTF8 and fontmap alone are insufficient.','P30 accepted only recorded current-binary kernel VT combinations, including Direct normal wire and unknown-title; full041/input/resize/all routes/all errors remain pending.','Theme real ellipsis/prefix layout and 085/088 future integration remain pending.','Whole bundle checker remains exit1 for composition/benchmark gaps; no whole Linux/M2/full release claim.','VTE native observer provides actual viewport text, not all cell attributes; XTerm printing may compose combining acute.','Source proof plus independent095 supports mid-pump cache/baseline details; no new dedicated dynamic case is claimed.']})
write(B/'proposed-integration.json',{'utc':now,'proposal_only':True,'main_product_tests_status_changed':False,'fixed_product':prep['product'],'fixed_root':prep['integrated_root'],'tasks':{'093':'accept fixed formal RED + bfd/dc6 independent fixture repairs','094':'accept finite Glyph implementation for fixed product only','095':'accept PASS_CODE_SCOPE / quality PASS, unchanged by handoff correction','096':'accept finite execution evidence, failures/limits preserved','097':'PASS_FINITE_SCOPE'},'P30':{'status':'PASS_FINITE_OBSERVED_SUBSET','accepted':['current product actual tty1 Glyph root/uid1000 Auto and recorded overrides/restoration','formal148 actual tty1 Direct mode0 wire156 and unknown-title6, no visible OSCpayload, exact statuses/termios'],'remaining':['full041','input/resize','all routes','all parent fault/error combinations','whole Linux/M2/full release']},'Theme':{'glyph_gate_satisfied_for_root_admission':True,'next_action':'root explicitly admits TASK013/025 with fixed085 additional tests; TASK097 does not start or mark Theme GREEN','still_pending':['actual ellipsis layout/prefix budget','088 matrix','full Theme acceptance']}})
external=[]
for p in [E/'report.md',E/'findings.json',E/'scope.json',E/'manifest.json',E/'artifacts.sha256',R/'docs/reviews/R16/code-review/handoff-correction.md',R/'docs/reviews/R16/code-review/handoff-correction.json',R/'docs/reviews/R16/test-supplements/capture/review/report.md',R/'docs/reviews/R16/test-supplements/observable-api/review/report.md']:
 external.append({'path':str(p),'sha256':sha(p),'bytes':p.stat().st_size})
write(B/'reviewed-hashes.json',{'utc':now,'fixed':{k:v for k,v in prep.items() if k in ['base','product','integrated_root','official_test_root','official_test_base','official_test_repairs']},'preparation_manifest_sha256':sha(B/'preparation-hashes.json'),'external_reports_and_indexes':external,'source_files':prep['source_files'],'additional_oracles':read(B/'raw/oracle-verification.json')['sourceHashes'],'full_execution_source_and_dependency_and_package_hash_evidence':'raw/integrity.json + external096 manifest/index','original_red_hash_evidence':'raw/red-lineage-verification.json','independence':'No reads from glyph-implementation; paths in copied metadata are inert strings.'})
write(B/'raw/command-record.json',{'utc':now,'cwd':str(B),'product_executed':False,'commands':[{'command':'python3 verify_integrity.py','exit':0,'result':'raw/integrity.json','result_recorded_utc':read(B/'raw/integrity.json')['utc']},{'command':'node verify_oracles.mjs','exit':0,'result':'raw/oracle-verification.json','result_recorded_utc':read(B/'raw/oracle-verification.json')['utc']},{'command':'python3 verify_hosts.py','exit':0,'result':'raw/host-verification.json','result_recorded_utc':read(B/'raw/host-verification.json')['utc']}],'timestamp_note':'Result timestamps are script-recorded UTC, not invented command start/end. Initial failed helper attempts remain in raw; terminal transcript also retains later read-only display-summary TypeError.'})
print('Final result documents written; sealing is separate after report review.')
