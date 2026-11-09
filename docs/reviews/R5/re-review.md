# R5 独立复核

日期：2026-11-09；本轮第1次修复复核，未超出3次/60分钟预算。

初审版本：`21602ada8424bab266f2f2153e6fff5b126bf789`。修复受审版本：`070623f1014a48bd559364747550c48332c16201`。范围为原五项发现、response.md所述修复、修复影响及新增联合消费证据。使用与初审相同的独立审核角色、code-reviewer模板和verification-before-completion标准；未参与修订规格，未提交代码。

## 结论

**design_reviewed**。原5项必需发现均已验证修复，未发现新的必需问题。`findings.json`已由fixed更新为verified，填写完整fix_revision与本报告引用。原`initial-findings.json`和`independent-review.md`保持原貌；其中failed是初审历史，不是本次最终结论。

该结论仅覆盖文档设计、任务追踪和有界探针。产品AC-001–032及AC-037仍为pending；没有产品实现、真实终端/SSH/图标验证、完整Unicode验证、M2性能或发行许可通过声明。

## 原发现复核

| 发现 | 结果 | 原反例与修复证据 |
|---|---|---|
| R5-IR-001 | verified | `docs/tasks.md`的021明确为M1 U1–U5基线，027后置完整主题展示；023显式依赖027/031/032，024汇总全部需求。人工检查责任边界及自动遍历33个产品任务依赖均无环。原021↔027完成条件冲突消除。AC-021/023同步。 |
| R5-IR-002 | verified | 新TASK-037/AC-037明确承担通用视口纵向内容访问、表格横向、键盘滚动、宽字符裁剪及resize偏移/焦点；80×24访问100行是可判定反例。REQ-003.11映射到037，027/031依赖037，最终经023/024集成；不要求未来候选现在展开API/L4。 |
| R5-IR-003 | verified | `docs/architecture.md`§17明确M2必需，基准只决定缓存/索引策略和证明收益；REQ-004.5把完整帧阶段限定M1并回链REQ-004.8。与AGENTS及主/增量规格无冲突。 |
| R5-IR-004 | verified | TASK-003列表、卡片、L4及AC-003均覆盖ansies/unicode/unicodewidth和传递bitarray；分段/规范化、唯一宽度和ANSI职责分开，原生构建/干净消费/空串适配/许可仍作为后续门槛。 |
| R5-IR-005 | verified | TASK-034只承担语言构造调查，新增036独立承担依赖选型与有界证据；有独立AC、输入、L4和状态，036明确不依赖034语言结论。035依赖已同步为033/034/036，docs/tasks仅保留变更状态映射。 |

## DQ复核

以下pass是本轮文档与规划层判断，不授予未来产品候选ready状态。

| DQ | 结果 | 理由 |
|---|---|---|
| 01 | pass | 本轮仍为文档/调查/审核L3，无产品编码。 |
| 02 | pass | 034/036独立结果已拆分；033/035服务各自统一交付。 |
| 03 | pass | 修订任务卡与新增036信息可定位；037明确planned及待冻结缺口。 |
| 04 | pass | 修复未扩大GUI、业务表格功能或产品实施范围。 |
| 05 | pass | 原五项可逐项复核，037补了100行/宽表/裁剪/resize可观察判据；未来精确命令待准入细化。 |
| 06 | pass | 33个产品任务依赖无环；021/027完成边界已一致。 |
| 07 | pass | REQ-003.11补入037与AC-037，原父目标映射缺口关闭。 |
| 08 | pass | M1示例、主题展示、通用滚动、M2优化及最终集成责任区分，旧M2/两依赖冲突关闭。 |
| 09 | pass | 027/031等待037，023等待027/031/032，024承担最终完整验收。 |
| 10 | pass | 原生链接、许可、完整Unicode及终端能力未知继续显式保留。 |
| 11 | pass | 当前034/036的L4不再隐藏独立决策结果；未来037允许后续展开。 |
| 12 | pass | AC-003、034、036、037与任务/需求编号一致，文档状态和产品pending分开。 |
| 13 | pass | 变更/决策/技能引用继续有效，独立复核有固定版本；本次仅更新审核结果。 |
| 14 | pass | 责任归属和旧路径修订完整；新增证据复用外部算法，不引入平行产品内核。 |

## 本次实际验证

所有命令针对上述修复版本运行，检查退出码均为0：

- `node docs/reviews/R5/check-consistency.mjs`：33个产品任务依赖无环，滚动/最终集成依赖存在，25个delta Requirement匹配主规格，无产品源码变更。已阅读该脚本，并人工对照021/027/023/037的语义完成条件；没有只凭图无环代替责任审查。
- `node scripts/check-repository.mjs`：仓库、配置、链接及任务映射检查通过，工具自身明确不验证产品。
- `XDG_CONFIG_HOME=/workspace/work/tool-config OPENSPEC_TELEMETRY=0 /workspace/work/terminal.ui/node_modules/.bin/openspec validate --all --strict --no-interactive`：8项通过、0失败。
- `git diff --check 21602ada8424bab266f2f2153e6fff5b126bf789 070623f1014a48bd559364747550c48332c16201`：无空白错误。
- SDK环境下实际运行`/workspace/work/validation/replay-combined/target/release/bin/main`：输出`graphemes=5, per-cluster-width=9, whole-width=9, NFD-size=2`并退出0。
- `cmp`确认版本化combined源码与上述复跑源码一致；原生归档SHA256为`96f0552e197c0f02a7860f13cd0174617df639315252221828785103628e0c03`，与combined-environment.log一致；`bash -n docs/reviews/R5/evidence/run-combined.sh`通过。
- 初审报告及初始JSON与修复commit中对应文件字节一致，未覆写历史。

新增联合源码只导入unicode的分段/规范化与unicodewidth.StringWidth，避开双width扩展；已读取锁文件、清单、脚本、日志与证据README。该补充证明这两个字符库在记录环境和样本上可联合消费；ansies仍依据先前独立探针，没有假称本程序联合执行三库或验证通用宽度可加性。此处复跑已有二进制并复用有效编译日志，未声称重新全量构建依赖。

初审已核验的SDK/UCD/四包摘要、语言正负编译记录、原生失败/有条件成功及许可证缺口未改变，依据AGENTS §11和BATTLE §7复用，不重复下载/构建。新增脚本显式需要既有cache与libunicodedata.a，文档保留干净制品和跨平台消费未验证边界。

## 非阻断文字建议

`docs/acceptance.md`首段将“AC-037为产品滚动”与句尾“不是产品验收”连写，建议收尾时明确为“AC-033–036是本轮非产品验收；AC-037是后续产品滚动验收”。表格本身已明确037为产品pending，未改变实际完成门槛。初审提出的表格空行可读性建议仍为可选整理。

本次复核关闭原五项，不要求重跑未受影响的外部框架调查，也不把后续产品实现缺失、未ready候选或已披露许可限制升级为本轮失败。
