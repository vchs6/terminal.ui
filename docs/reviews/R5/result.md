# R5 规格修订与隔离验证结果

## 结论与受审版本

本轮结论：**design_reviewed**。独立AI审核者（GPT-6 Astra，未参与撰写、未继承作者过程上下文）初审提出2项major、3项minor；全部修复并独立验证关闭，无未解决必需文档缺陷。这是独立代理审核，不是外部机构认证。

- 基线：b8ce41857e37186cadfbbbc3586a9f8f5e67ece4。
- 初审：21602ada8424bab266f2f2153e6fff5b126bf789，历史结论failed保留在[independent-review.md](independent-review.md)和[initial-findings.json](initial-findings.json)。
- 修复复核：070623f1014a48bd559364747550c48332c16201，最终独立结论见[re-review.md](re-review.md)，逐项状态见[findings.json](findings.json)，主代理处置见[response.md](response.md)。
- 此后收尾仅补充状态/报告引用、验证记录及排版，不改变复核通过的规格/架构/探针；以Git差异核对有效证据复用。

## 交付与授权边界

变更[refine-terminal-ui-contracts](../../../openspec/changes/refine-terminal-ui-contracts/proposal.md)交付提案、设计、七项增量规格及已同步主规格，修订REQ-001–010、组件/布局/输入/主题/会话契约、依赖选型与任务验收映射。版本使用三段数字，当前产品开发版本0.0.0。按用户和仓库授权直接提交推送main，不创建PR、不发布。

本轮TASK-033文档、034语言调查、036依赖调查和035独立审核完成；状态权威仅在变更tasks.md。产品TASK-001–032及037、AC-001–032及037仍pending，未实现产品框架、示例、基准或主题文件。OpenSpec文档同步和本轮任务勾选不代表产品apply完成或可归档为产品实现。

## 实际验证

| evidence_id | 范围 | 命令/方法与实际结果 |
|---|---|---|
| R5-E01 | 工具/流程 | npm ci --ignore-scripts --cache /workspace/work/npm-cache；XDG_CONFIG_HOME设workspace后dev:setup成功；OpenSpec1.14.3、本地Superpowers锁定revision可发现读取。环境只读home失败已定位，未修改工具锁或禁用摘要校验 |
| R5-E02 | AC-034 | SDK官方SHA核对，run-language.sh正例编译运行、两个负例按预期拒绝且定位源码；验证代理新目录重跑，主代理另在main-language-recheck重跑，均退出0 |
| R5-E03 | AC-036 | run-dependencies.sh分别消费、四包SHA、unicode纯消费失败及原生条件成功、Unicode样本/ANSI生成；验证代理在干净目录重跑退出0，独立审核核对源码/摘要并复跑已有二进制 |
| R5-E04 | AC-036 | run-combined.sh在同程序只导入unicode分段/规范化与unicodewidth宽度；5簇、逐簇/整体9列、NFD断言通过；主代理在main-combined-recheck额外重编译运行退出0，审核者独立源码比对及二进制复跑 |
| R5-E05 | AC-033 | npm run check：仓库配置/引用/任务映射及OpenSpec严格校验8项通过；check-consistency.mjs：33产品任务依赖无环、25增量要求与主规格一致、无产品源码变更 |
| R5-E06 | AC-035 | 独立初审/修复复核、DQ-01–14逐项理由、原五项verified；其实际验证与复用边界见re-review.md |

技术源码、脚本、元数据、摘要、正负日志和限制统一在[evidence/README.md](evidence/README.md)。完整最终静态输出见[validation-final.txt](validation-final.txt)，上一修复版本输出见[validation-revision.txt](validation-revision.txt)。没有运行无关产品构建或宣称尚无源码的产品测试通过。

## 保留的产品门槛

- 尾随Lambda只承载块语法；子元素收集、响应式依赖、稳定身份、卸载和宏诊断仍需完整产品验证。保存回调捕获可变局部var受编译器限制，已验证let绑定对象的替代路径。
- unicode需原生UCD数据生成与C/ASM归档显式链接；空字符串迭代额外空簇需要薄适配/上游处理。联合探针只证明记录Linux x64/SDK1.2.0样本，不证明干净产品制品或跨平台消费。
- unicodewidth为唯一显示宽度，unicode只分段/规范化；没有完整Unicode一致性、IME/BiDi、全部字形或终端宽度保证。
- bitarray许可声明冲突、归档缺少LICENSE文本及Unicode数据归属须在TASK-003/023解决；本轮没有许可发布通过结论。
- 真实终端/SSH剪贴板、标题/实际图片图标、主题重载、输入与滚动、M1/M2正确性和性能均待相应产品任务；图形宿主能力缺失不阻止核心字符界面设计。
