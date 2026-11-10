# TASK-080 独立有限 C 验收

**结论：AC-076–080 在本次有限合同内 PASS；原 AC-015、AC-016、AC-032 的原文行为证据充分，可由 root 机械登记 passed。** 元数据已核验并准备最终日志哈希投影，root 归档该投影与原件后可完成 metadata readiness 登记。此结论不关闭 AC-014、TASK-018、完整 release 或 Linux 总目标。

固定产品 `216b2ab5f2315f4be19467b7e49f4047aec78ab9`，集成点 `5de716f`；正式测试 `3ee1a9b697db77ee6584905c10ba670ddfd06bff` + `10c4ee3bf94a63995c2ffa16cedd79c4905d6b73`。原 32 组期望未改，新增两组 DYN-F001 回归。产品版本 0.0.0，SDK cjc/cjpm 1.2.0，依赖未新增。指定角色 Astra/high，实际 serving variant/effort 不可独立核验。

执行型验收，独立目录 `/workspace/work/dynamic-acceptance`；无子代理，无产品作者沟通/推理/自评输入，无主仓、产品、正式测试或任务状态修改。已读取 verification-before-completion 技能，按 AGENTS 11.1 对有效执行证据重新核原件、源码、SHA、完整 ANSI 网格及必要语义，不重跑有效产品套件。using-superpowers 明确 subagent-stop，未重复启动其流程。

证据位置定义：E=`/workspace/work/dynamic-execution`，其归档草稿 `r13-execution-draft` 拟归档 `docs/reviews/R13/execution`；R=`/workspace/work/dynamic-review`；T=`/workspace/work/dynamic-tests/evidence/red-c3d743d`；TR=`/workspace/work/dynamic-regression-tests/raw`。A+B 前验收为 `/workspace/work/runtime-acceptance/report.md`（root 集成 `1d2af2c`）。本验收的原件摘要见 [reviewed-hashes.json](reviewed-hashes.json)。规范使用 main `openspec/changes/implement-reactive-runtime/design.md` 第 4、6 节 R001–019，以及 tasks 的 TASK080/Global constraints；原 AC 含义按 `docs/acceptance.md`，未编号替换。

## 有限任务与原 AC 判断

| 验收项 | 判定 | 完整依据 |
|---|---|---|
| AC-076 独立 golden/RED | PASS | T 的正常旧产品构建成功，正式消费者编译实际 exit1，缺 If/ForEach/ListItem/NodeRef.children 等 API；不是下载错误或声明替身运行。41 份 T 摘要核对；TR 24 份摘要核对，两正式 nested case 在 167 上都实际失败并共同返回1。手写字面网格/身份/局部状态/清理轨迹独立于产品期望生成。 |
| AC-077 动态及手动唯一序列 | PASS | 34 组固定公共消费者及两个真实宿主网格、公开示例/干净包消费支持第4节；源码只保留 RuntimeNode.sequence 中 MountedChild/GroupMarker 一份物理顺序，children/layout 消费同序列。不是把动态组包装成布局盒。 |
| AC-078 独立 spec/quality | PASS（有限） | R 初版 167 FAIL/DYN-F001 保留；scoped-r1 对216独立双 PASS，20项固定审核manifest重算通过；原独立probe断言不改，正常build/direct exit0。最终源码核对 recursive initialization、publication guard 和资源清理边界，无未决 Critical/Important。 |
| AC-079 独立执行/回归/包消费 | PASS（有限） | E 34组直接二进制、A+B255条PASS输出、12真实PTY、macro16、Layout114、decoration59；正常build/check/bundle、clean root/dynamic/example、两GUI实际运行。有效旧低层/宏negative仅按内容边界复用。 |
| AC-080 原 AC 与元数据 | PASS（有限；投影已就绪） | 本表下三行逐原文判断；627文件原件/manifest、49 strict JSON、9二进制、97包文件与元数据核对。唯一附带日志hash时间差有精确prefix证明与两份投影，非缺失运行证据。root 机械归档后登记 readiness。 |
| **原 AC-015 稳定身份与卸载订阅释放** | **PASS** | `identity_cases.cj` 在a局部值7后反排b/a并换新T，画面为Bee:0/Ay:7、sameNode保留、body/build各一次；删除再加a为New:0、新代际，旧ref不复活。If/父组卸载证明订阅下降、后台业务更新不触发旧组、owner post取消；dead断言当前nodes/bindings/subscriptions/posts归零。A+B lifetime/bindings/cleanup与弱句柄源码补足会话和引用释放；不把尚未实现的焦点/滚动状态当成本期已验。 |
| **原 AC-016 状态批处理与 UI 调度** | **PASS** | 原文为“后台状态经过调度，批量修改合并刷新，长短文本切换无残留”。A+B bindings 用真实spawn确认后台set/get/NodeRef.notify不运行UI getter，UI pump消费失效；同步竞态/70turn持续更新/满post队列不丢State均有新216 core输出。scheduler嵌套batch写1/2/3，最新值3、frames最多+1；lifetime A→BC→Z字面完整帧无残留。run同一pump/needsWork路径与真实GUI无需flush的显隐、删除、refill完整网格相互印证。headless检查不冒充真实设备运行；已有差分路径与本次真实设备结果合用。安全重同步完整矩阵仍属008，不由此关闭008。 |
| **原 AC-032 混合子元素操作与定向通知集成** | **PASS** | 原文为“A/B/C中插X融合排序位置；显式移动/移除、无效锚点/卸载/重入操作有诊断；定向通知合批无手动flush”。slot表逐项见下；手动remove不改items、不自发复活，Structure notify才新代际重建；显式命令先于本轮结构getter。stale-anchor、跨父、重复插入、removed move及各重入code有具体断言。A+B targeted Content/Style/Bindings及后台notify不扫无关getter，批处理/同一pump合并；动态Structure同批合并最新items。普通动态example回调只用公开state/结构操作，真实宿主自动更新，无flush。 |

## 合同语义核对

| 合同边界 | 原件与源码核验结果 |
|---|---|
| 槽位表与无盒组 | `slot_cases.cj` 字面断言 A X B C→C X B A、B X C、X、X D E、D X A B C；每组对应完整snapshot与children身份数组。marker不可见；移声明A到marker之外后溢出仍搜全父所属槽，清空再加E回marker前。If的P/A/Q直接同级与3个children明确检出多余盒。 |
| 多组与手动所有权 | `multipleGroupsAndManualOrder` 两组均有A/B却身份独立；把右组A移到左组前，与X/Y交错后各组只替换所属槽。清空左组保留右组、separator与manual相对顺序。不推断业务排序或manual跟随某key。 |
| 构造、键与根数 | ForEach先全量求key并检查非空/重复再调用新增body；同组所有新增body/build预验证后提交。0/2根ForEach、2根If、空If、普通if/for一次build均有断言。build/body错误保留用户异常、collector恢复、新body未半挂载。源码先prepare再commit，并在outer publication前递归initializeGroup；不能把失败session清理误判成事务回滚。 |
| 预算与发布 | structuralOps/mountedNodes/depth/shared initial budget均有代码责任位置；preflight计退休节点credit，staged mount预算仍有效。R独立fix review及其固定raw检查递归边界/等容量成功/初始化累计预算。34正式组中的structure-limits、synchronous-structural-loop验证CapacityExceeded/UnstableUpdate与释放；额外review探针不冒充正式组。 |
| DYN-F001 | 167正式RED输出manual old:active-parent:children=1，replacement old-text/old-row亦active-parent，exit1；216两组均仅stopped，failed assertions0，exit0。原R独立probe也从exit1→exit0。先递归验证完整新增子树、后publish/retire，失败不执行后续remove，不运行无效新mount，业务值保留，全部资源最终归零。 |
| 手动操作与读取 | 未提交insert无有效ref、children为独立已提交快照；同父move保身份、self/adjacent/end no-op验证后执行；先remove再insert同anchor为StaleAnchor，不能append；跨父CrossParentMove、已挂载AlreadyMounted、leaf InvalidParent、卸载后StaleReference。不存在跨父保生命周期搬迁承诺。 |
| A+B→C边界 | NodeRef实际WeakRef(EAGER)，id含session/unique runtime node身份；UI线程生命期token与session边界沿用。owner取消、孩子到父全部cleanup、首错/附加错误、snapshot/dispatch/结构getter/Observable写的上下文诊断、lifecycle只允许post下一turn由动态用例与新255 core/12PTY覆盖。源码内存非拥有证明不冒称新GC压力实验或真实线程id复用实验。 |
| 单一布局与设备路径 | 动态节点共享原LayoutNode/Frame/Unicode/Style/ANSI。R019同一次size snapshot及无idle全帧工作的路径未被C替换，源审查和075已有受控证明适用；新12PTY/GUI resize补充实际最终画面及恢复。没有另造terminal模拟产品或新私有flush。 |

## 原件、包与宿主

[只读重算结果](raw/integrity-semantic-audit.json) 核对 E 草稿 **627个受hash文件、连manifest共628文件**，与原始 E/evidence、commands逐件相等，strict JSON49份，归档无ELF。固定源清单5175项及tracked diff空、main5de716f相关产品内容一致；这包括固定仓内既有工件，不代表5175产品源码。9个实际native binary SHA对应source/clean消费者；命令start/end/cwd/argv/stdout/stderr/实际exit均存在且次序正确。按实际manifest统计，不预设数量。

正常 `.cjp` 原件SHA=`1c70bf78ee727d9922a32baf5044c5d3bf15cc828c3eea1c3b3dfd3e94947abb`；tar实际97个文件，61个src/native/build/manifest/dynamic-example文件逐字节对应固定源码与clean解包树。隐藏src/.gitkeep正常未入包。clean固定动态14个源码与原正式用例相等，仅consumer manifest dependency path改为解包产品；新clean-cache与主缓存/075缓存111个依赖源码/manifest摘要一致，SDK/UCD4项摘要重算相等。normal bundle保留lint warnings，没有skip lint。clean首次helper因.gitkeep比较失败的exit1保留；排除唯一占位后recheck0，随后普通root build/check、dynamic34 direct、公开example build/smoke全为0。没有复制target/native归档来补包的操作。

真实 XTerm398 和 XFCE1.1.4/VTE0.80.1 是两个实现，非同PTY换TERM。源码/二进制/driver hash、UTF-8 locale、实际100×28→120×34、host配置/version、UTC与PNG/raw都在E metadata/host provenance。独立重放 `v/i/r/e/e/v/resize` 的8阶段×2完整网格（含所有剩余空白），全部符合手写期望；resize允许合法旧在途帧，以最终settled完整网格判定。`q` inner/outer/app/host均实际exit0，before/after termios逐字节相同。XTerm reordered与VTE refilled原始PNG已目视核对。截图未重建、未重绘，旧c3截图没有标成216新测；公开例子不输出能力诊断，因此本次不扩称新全能力认证。

12个PTY原件逐份比before/after、result、session.raw和恰一次real_result=0。callback、cleanup、callback-cleanup、callback-cleanup-close、mount、bind的真实exit1是预期故障；其余6项exit0。注入close失败发生在真实成功close之后，不能删去作为“失败噪音”。新core255、macro16、Layout114、decoration59输出与固定源/命令对应，不只取报告数字。

旧15宏负例按fixture位置/所需诊断/实际非零exit逐项核对，macro源与fixture对f07ff633未变；低层Frame/Cell/ANSI/Color/Style/text对c3d743d内容未变，仅复用其direct Frame/color观察。旧R12 aggregate真实exit1保留，不将其整体算作当前PASS；render/RuntimeSession/Layout/decoration受影响部分取本轮新执行。

完整未改 `scripts/check-bundle.mjs` 已真实exit1，首先报缺 `examples/composition/cjpm.toml`，未来rendering benchmark亦未交。未声称完整check-product release执行成功或发布就绪。当前正常有限源码包消费不等于完整release验收。

## 元数据差异及机械交接

原metadata均是严格JSON；本验收发现两宿主各 `artifacts.xorg.log`、`artifacts.xorg.stdout` 共4个旧hash与最终原件不同。并非假定追加：[prefix证明](raw/metadata-prefix-audit.json) 重算旧hash恰等于原件前缀（XTerm log39309/stdout1441字节，VTE log39304/stdout1436字节）；剩余分别72/59字节，只是 `Server terminated successfully (0). Closing log file.`。PNG、ANSI raw、source、binary及所有其他artifact hash一致，627总manifest已使用最终完整原件hash。metadata 的 harness_source_sha256 是8个既有终端基础脚本/源码的带路径摘要聚合，已按同样格式重算；本轮适配driver/gui-key源码另由execution commands清单和reviewed-hashes固定，不误称该聚合字段单独覆盖适配driver。此为附带日志采样时点差异，行为结论不受损。

已准备两份只替换上述2字段的最终artifact哈希投影：[XTerm](metadata/xterm-default-metadata.final-artifacts.json)、[VTE](metadata/xfce-vte-metadata.final-artifacts.json)。[投影来源](metadata/projection-provenance.json) 列原metadata路径/hash、原/最终artifact hash、精确prefix、转换UTC、投影hash及修改字段。原captured_at_utc保持，不伪造新运行/截图；原metadata/日志/manifest全未修改。发现登记在 [findings.json](findings.json)，状态为已用可追溯附加投影解决、待机械归档。

root应机械归档本目录为R13/acceptance，并连同E原件、两投影/来源及prefix证明建立链接；随后登记AC076–080和原015/016/032的本报告结论。原初167 FAIL/DYN-F001/正式RED和最终修复审查全部保留。AC014跨popup仍等018，AC001–004/008/010/017等未由本验收关闭，主题/富文本/焦点/overlay/M2/完整release及其他Linux必需目标按依赖继续。**有限C结束后直接继续RichText，不以此停止Linux任务。**
