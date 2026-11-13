# 工程任务

> **For agentic workers:** Linux实施已授权；使用 superpowers:executing-plans及当前阶段适用技能，按具体L3契约和前置准入执行。

**Goal:** 开发 cjtui 的声明式用户构造能力并形成完整源码制品。

**Architecture:** 见 docs/architecture.md；语法先验证，依赖经薄适配边界，单一节点/渲染路径。

**Tech Stack:** 仓颉 SDK 验证版本 1.2.0；中心仓 ansies 1.3.113、unicode 0.1.0、unicodewidth 0.1.113。

**Spec:** [完整需求说明](requirements.md)及 openspec/specs/ 下对应场景投影；构造与接口输入见 [总体架构](architecture.md)和[用户构造设计](ui-construction.md)。执行治理继续遵循 AGENTS.md。

## 工程目标与工作包

L1 G-001：从零开发 cjtui 并形成可发布制品。

| L2 | 工作包 | L3 范围 |
|---|---|---|
| WP-001 | 平台、依赖与语法验证 | TASK-001–004 |
| WP-002 | 文本与渲染 | TASK-005–010 |
| WP-003 | 布局与组合 | TASK-011–014 |
| WP-004 | 状态、输入与覆盖层 | TASK-015–020 |
| WP-005 | 交付与整体集成 | TASK-021–024 |


## Global Constraints

- 当前产品实现任务保持 planned；2026-11-09 用户已进一步授权Linux ANSI优先实施和风险处理，其他OS在Linux全部验收后推进；本轮修订/调查/审查状态见活动变更，不等同产品通过。
- L1 G-001、L2 WP-001–005 由 docs/tasks.md 索引，不能直接编码。
- 未进入具体变更的项目任务状态由本文件维护；进入变更后按AGENTS10.1转移唯一状态权威并保留引用。复选框只标 L3 交付完成，不能以勾完 L4 代替验收。
- 近期 TASK-001–004 的完整产品验收仍未完成；R5仅提供部分输入证据。远期为 L3 候选，Linux实施已授权，仍需按前置契约渐进细化和DQ复核后方可ready。
- 代码质量、技能安装、任务分类和验证复用引用 AGENTS，不另立平行规则。

## Review Focus

1. 未经验证的组件块语法被误称已支持：TASK-002 须实际编译原始输入并保留错误定位。
2. 终端回复解析被误当完整 ANSI 解析：TASK-003/009 按支持矩阵测试跨块和非法输入。
3. 中文、emoji 裁剪导致孤立延续单元：TASK-005/012 验证边缘写入、移动与覆盖。
4. 弹窗关闭恢复过期帧或失效焦点：TASK-018 验证底层更新与触发节点卸载。
5. 制品中示例依赖包外目录：TASK-023 以真实 cjp 在干净目录构建和运行。

## 1. WP-001

- 1.1 TASK-001：产品平台与终端支持契约调查；验收 AC-001：形成 OS、终端、TTY/非 TTY、输入、缩放和模式恢复支持矩阵及限制证据。；唯一状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)，本文仅保留原范围/依赖定义。
- 1.2 TASK-002：验证仓颉声明式语法可编译性；验收 AC-002：分别证明组件块、链、状态、条件/列表、自定义组件与回调；记录失败定位与限制。；唯一状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)，本文仅保留原范围/依赖定义。
- 1.3 TASK-003：验证中心仓依赖与 SDK 适配边界；验收 AC-003：固定ansies、unicode、unicodewidth及传递依赖可解析；按分段/规范化、唯一宽度及ANSI职责验证，覆盖原生构建/干净消费、缺口和许可来源。；唯一状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)，本文仅保留原范围/依赖定义。
- 1.4 TASK-004：冻结首个公共构造切片契约；验收 AC-004：U1–U5 设计稿均可映射至语法规则、签名、模块归属和验收，不以设计稿冒充运行。；唯一状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)，本文仅保留原范围/依赖定义。
## 2. WP-002

- TASK-005：状态/准入/实际依赖转至[帧合成变更](../openspec/changes/implement-frame-composition/tasks.md)，保留 AC-005 及需求映射。
- TASK-006：状态/准入/实际依赖转至[颜色与样式变更](../openspec/changes/implement-color-style-output/tasks.md)，保留原AC-006及需求映射。
- TASK-007：状态/准入/实际依赖转至[帧合成变更](../openspec/changes/implement-frame-composition/tasks.md)，保留 AC-007 及需求映射。
- 2.8 TASK-008：差分提交与写失败恢复；验收 AC-008：无变化不输出；部分写失败不提交基线，安全重同步后完整重绘；无法确认时停止输出并报错。；唯一状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)，本文仅保留原范围/依赖定义。
- TASK-009：状态/准入/实际依赖转至[富文本变更](../openspec/changes/implement-rich-text/tasks.md)，保留原AC-009和需求映射。
- 2.10 TASK-010：完整彩色与纯文本快照；验收 AC-010：含覆盖层独立快照无需差分历史，纯文本无 ESC，写失败明确报告。；唯一状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)，本文仅保留原范围/依赖定义。
## 3. WP-003

- TASK-011：状态/准入/实际依赖已转至 [布局装饰变更](../openspec/changes/implement-layout-decoration/tasks.md)，保留原AC-011和需求映射。
- TASK-012：状态/准入/实际依赖已转至 [布局装饰变更](../openspec/changes/implement-layout-decoration/tasks.md)，保留原AC-012和需求映射。
- TASK-013：状态/准入/实际依赖转至[主题样式变更](../openspec/changes/implement-theme-styles/tasks.md)，保留原AC-013与需求映射。
- [x] 3.14 TASK-014：自定义组件跨容器复用；验收 AC-014：同组件用于普通容器与弹窗无需修改内核。
## 4. WP-004

- [ ] 4.15 TASK-015：稳定身份与卸载订阅释放；验收 AC-015：列表重排保留正确局部状态，卸载后订阅和引用失效。
- [ ] 4.16 TASK-016：状态批处理与 UI 调度；验收 AC-016：后台状态经过调度，批量修改合并刷新，长短文本切换无残留。
- [ ] 4.17 TASK-017：键盘导航和有效焦点；验收 AC-017：禁用、卸载和空焦点集合有确定行为，无失效引用。
- [x] 4.18 TASK-018：覆盖层嵌套与关闭恢复；验收 AC-018：父层关闭清子层、模态隔离，原焦点失效时回退且下层显示最新状态。
- TASK-019：状态/准入/实际依赖转至[标准控件变更](../openspec/changes/implement-standard-widgets/tasks.md)，保留原AC-019与需求映射。
- 4.20 TASK-020：应用退出与终端模式恢复；验收 AC-020：正常退出、异常和取消均恢复光标及终端模式。；唯一状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)，本文仅保留原范围/依赖定义。
## 5. WP-005

- 5.21 TASK-021：交付 U1–U5 公开接口示例；验收 AC-021：minimal/composition 独立项目构建；不同业务 U5 无内核特判。；唯一状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)，本文仅保留原范围/依赖定义。
- TASK-022：状态/准入/实际依赖转至[M2变更](../openspec/changes/implement-incremental-rendering/tasks.md)，保留原AC-022与需求映射。
- 5.23 TASK-023：验证最终源码制品可独立使用；验收 AC-023：实际 cjp 无开发资料；干净解包能构建主库及运行示例/基准，版本/许可证核对完整。；唯一状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)，本文仅保留原范围/依赖定义。
- 5.24 TASK-024：整体验收与发行准备；验收 AC-024：需求全部有证据，产品文档与制品一致；Battle 无未关闭必需失败。；唯一状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)，本文仅保留原范围/依赖定义。

## 近期 L3 任务卡

### TASK-001：产品平台与终端支持契约调查

以下为原任务定义的只读历史；唯一执行状态与当前收尾步骤已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)。不在本文维护第二份status。

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / investigation |
| classification / basis | decision；产品交互目标明确，需用证据确定可承诺的平台与终端边界 |
| openspec_change_ref / planning_gaps | null / 具体实施变更尚未启动，当前仅规划 |
| requirement_refs / workflow_ref | REQ-003、REQ-004、REQ-007 / 项目规划 docs/tasks.md |
| objective / deliverables | 当前Linux ANSI终端的OS/SDK/CPU/ABI/宿主矩阵、输入/尺寸/恢复及权限证据；其他OS在Linux全部验收后再调查 |
| scope / impact | 平台适配设计及docs/decisions；不实现正式内核；四平台目标由REQ-011确定，调查不得静默取消目标 |
| inputs / depends_on | docs/requirements.md、docs/architecture.md、目标环境说明 / 无 |
| preconditions | 用户已授权Linux优先及风险调查；实际所需工具和技能可用 |
| acceptance / verification | AC-001：形成 OS、终端、TTY/非 TTY、输入、缩放和模式恢复支持矩阵及限制证据；记录实测方法、结果和不可承诺项 |
| required_skills | using-superpowers、brainstorming、verification-before-completion；涉及环境失败时使用 systematic-debugging |
| skill_evidence_refs / decision_refs | 启动时记录安装与实际使用证据；架构 D-001 及平台适配约束 |
| compatibility | 不假设对任何现有产品/API 的兼容义务；变更产品目标须裁决 |
| quality_governance | 平台契约归平台适配模块；不建立重复输入/输出内核；不涉及替换退役，兼容例外不适用 |
| risks | 模式恢复、非 TTY 或特定输入序列不能可靠支持；必须记录限制而非猜测通过 |
| status / blockers | planned / Linux风险先行证据见R7，尚未完成本任务全部产品契约调查 |
| evidence_refs | 尚无该任务执行证据；SDK 可启动不等于终端契约成立 |

L4：

1. TASK-001.S1：列出候选 OS/终端及 TTY、输入、尺寸/resize、模式保存/恢复维度。检查结果：每个产品承诺都有可验证项目，不从 CI 主机推断全平台支持。
2. TASK-001.S2：在获授权的调查环境执行必要兼容性检查并保留结果。检查结果：可支持、受限和未知明确分开，失败不记通过。
3. TASK-001.S3：形成支持矩阵和推荐边界并进行针对性决策审查。检查结果：TASK-004 可据此冻结公开契约，改变用户目标的取舍不得先行实施。

### TASK-002：验证仓颉声明式语法可编译性

以下为原任务定义的只读历史；唯一执行状态与当前收尾步骤已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)。不在本文维护第二份status。

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / investigation 或 design |
| classification / basis | decision；所需语法已明确，但可编译实现路线仍有技术不确定性 |
| openspec_change_ref / planning_gaps | null / 具体实施变更尚未启动，当前仅规划 |
| requirement_refs / workflow_ref | REQ-001 / 项目规划 docs/tasks.md |
| objective / deliverables | 可复现的最小编译实验和语法路线结论 |
| scope / impact | 实验目录及构造契约；不扩展组件库，不以手工转换替代真实语法 |
| inputs / depends_on | TASK-001 平台调查结论、AGENTS 第 2/4 节、SDK 1.2.0 / TASK-001 |
| preconditions | Linux范围已获实施授权；所列前置交付、具体变更及技能环境仍须满足 |
| acceptance / verification | AC-002：分别证明组件块、链、状态、条件/列表、自定义组件与回调；记录失败定位与限制；以交付物、可复现命令和 Battle 结论核验 |
| required_skills | using-superpowers、brainstorming、writing-plans；涉及编译实验时按任务识别 systematic-debugging、verification-before-completion |
| skill_evidence_refs / decision_refs | 启动时记录实际安装/调用证据；现有 D-001–005 见 docs/architecture.md |
| compatibility | 不假设现有产品/API 的兼容义务；若改变明确用户目标须另裁决 |
| quality_governance | 权威归属为对应产品契约；不新增平行内核；本任务为新增调查或设计，不涉及替换退役或兼容例外 |
| risks | 工具限制、源码事实与文档不一致；出现失败保留真实证据 |
| status / blockers | planned / Linux实施已授权，尚待上列前置契约与具体变更准入 |
| evidence_refs | 尚无任务执行证据；环境配置不等于本任务完成 |

L4：

1. TASK-002.S1：在获授权的实验分支验证组件块与属性链原始源码。检查结果：记录源文件、工具版本、实际命令和原始错误。
2. TASK-002.S2：逐项验证状态、条件/列表、自定义组件及回调与诊断。检查结果：每项有可复现通过或失败结论，不能只写风格接近。
3. TASK-002.S3：比较现有语言能力/宏与必要的仓颉前端并完成决策 Battle。检查结果：冻结采用路线、源码形式与构建命令；目标变更交用户裁决。
### TASK-003：验证中心仓依赖与 SDK 适配边界

以下为原任务定义的只读历史；唯一执行状态与当前收尾步骤已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)。不在本文维护第二份status。

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / investigation 或 design |
| classification / basis | decision；中心仓选型和固定版本已定，但 API 与缺口需证据确认 |
| openspec_change_ref / planning_gaps | null / 具体实施变更尚未启动，当前仅规划 |
| requirement_refs / workflow_ref | REQ-004,REQ-005 / 项目规划 docs/tasks.md |
| objective / deliverables | 版本解析证据、能力缺口矩阵及必要适配设计 |
| scope / impact | 依赖解析、文本/输出适配契约；不复制第三方内核或修改产品范围 |
| inputs / depends_on | docs/development/central-packages.json、根 cjpm.toml、TASK-001 / TASK-001 |
| preconditions | Linux范围已获实施授权；所列前置交付、具体变更及技能环境仍须满足 |
| acceptance / verification | AC-003：固定ansies、unicode、unicodewidth及传递依赖可解析；按分段/规范化、唯一宽度及ANSI职责验证，覆盖原生构建/干净消费、缺口和许可来源；以交付物、可复现命令和 Battle 结论核验 |
| required_skills | using-superpowers、brainstorming、writing-plans；涉及编译实验时按任务识别 systematic-debugging、verification-before-completion |
| skill_evidence_refs / decision_refs | 启动时记录实际安装/调用证据；现有 D-001–005 见 docs/architecture.md |
| compatibility | 不假设现有产品/API 的兼容义务；若改变明确用户目标须另裁决 |
| quality_governance | 权威归属为对应产品契约；不新增平行内核；本任务为新增调查或设计，不涉及替换退役或兼容例外 |
| risks | 工具限制、源码事实与文档不一致；出现失败保留真实证据 |
| status / blockers | planned / Linux实施已授权，尚待上列前置契约与具体变更准入 |
| evidence_refs | 尚无任务执行证据；环境配置不等于本任务完成 |

L4：

1. TASK-003.S1：用实际 cjpm update/check 解析固定中心仓版本。检查结果：留存解析结果、传递依赖、实际摘要和 SDK 版本；失败记录阻塞。
2. TASK-003.S2：分别核对unicode分段/规范化、unicodewidth唯一宽度和ansies生成/解析；检查原生数据构建、显式链接、空串适配、Unicode数据及传递许可来源。检查结果：API/行为/缺口矩阵包含三项直接依赖及bitarray，干净消费可复现，未决许可不能记通过。
3. TASK-003.S3：验证必要最小适配并核对传递许可证。检查结果：形成映射、限制与回归输入集合，不以文档声明替代运行证据。
### TASK-004：冻结首个公共构造切片契约

以下为原任务定义的只读历史；唯一执行状态与当前收尾步骤已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)。不在本文维护第二份status。

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / investigation 或 design |
| classification / basis | decision；语法与依赖调查完成后，必须冻结可实施的公开构造契约 |
| openspec_change_ref / planning_gaps | null / 具体实施变更尚未启动，当前仅规划 |
| requirement_refs / workflow_ref | REQ-001,REQ-002 / 项目规划 docs/tasks.md |
| objective / deliverables | 精确语法/API 契约和后续任务输入 |
| scope / impact | docs/ui-construction.md 用户构造设计、OpenSpec 设计/API 契约；不实现正式内核 |
| inputs / depends_on | TASK-002 编译路线、TASK-003 缺口矩阵、U1–U5 / TASK-002,TASK-003 |
| preconditions | Linux范围已获实施授权；所列前置交付、具体变更及技能环境仍须满足 |
| acceptance / verification | AC-004：U1–U5 设计稿均可映射至语法规则、签名、模块归属和验收，不以设计稿冒充运行；以交付物、可复现命令和 Battle 结论核验 |
| required_skills | using-superpowers、brainstorming、writing-plans；涉及编译实验时按任务识别 systematic-debugging、verification-before-completion |
| skill_evidence_refs / decision_refs | 启动时记录实际安装/调用证据；现有 D-001–005 见 docs/architecture.md |
| compatibility | 不假设现有产品/API 的兼容义务；若改变明确用户目标须另裁决 |
| quality_governance | 权威归属为对应产品契约；不新增平行内核；本任务为新增调查或设计，不涉及替换退役或兼容例外 |
| risks | 工具限制、源码事实与文档不一致；出现失败保留真实证据 |
| status / blockers | planned / Linux实施已授权，尚待上列前置契约与具体变更准入 |
| evidence_refs | 尚无任务执行证据；环境配置不等于本任务完成 |

L4：

1. TASK-004.S1：为 U1–U5 映射语法规则、精确公开签名与组件生命周期。检查结果：每个场景可追踪至模块归属、输入输出及错误边界，并冻结平台/终端支持矩阵。
2. TASK-004.S2：进行构造便利性 Battle，比较可执行替代方案。检查结果：未引入手动刷新、私有接口或演示专用分支。
3. TASK-004.S3：冻结契约并按其细化 TASK-005 等下游卡片和 DQ。检查结果：下游输入可定位且通过准入；未解决部分不标 ready。

## 远期 L3 候选定义

尚未冻结类型与构建入口，不虚构精确函数签名。以下不具备 ready 条件；前置调查完成后必须补齐任务卡、必要 L4、具体命令及 DQ 记录。

| ID / 父项 | 需求 | 目标与交付物 | 依赖 | 验收 |
|---|---|---|---|---|
| TASK-005 / WP-002 | REQ-004 | 字符簇写入和边缘裁剪；统一文本适配与对应回归 | TASK-003,TASK-004 | AC-005：中文、组合符和 emoji 在边缘写入/覆盖/裁剪无半宽字符或孤立延续单元 |
| TASK-006 / WP-002 | REQ-005 | 结构化样式映射与 ANSI 编码；ansies 薄适配与编码矩阵 | 已完成TASK-050/R9，TASK-061；实际准入见颜色样式变更 | AC-006：默认/16/256/真彩色按能力映射，组件不直接发序列 |
| TASK-007 / WP-002 | REQ-004 | 完整目标帧与覆盖合成；合成帧实现与独立屏幕断言 | TASK-005,TASK-006 | AC-007：透明单元和带样式空格有区别，前后层按确定规则合成 |
| TASK-008 / WP-002 | REQ-004 | 差分提交与写失败恢复；差分后端及故障注入证据  状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)；| TASK-007 | AC-008：无变化不输出；部分写失败不提交基线，安全重同步后完整重绘；无法确认时停止输出并报错 |
| TASK-009 / WP-002 | REQ-005 | 有界增量 ANSI 输入适配；受限解析适配与负向输入证据 | TASK-003,TASK-006 | AC-009：跨块、畸形、超长、未知序列按支持矩阵处理，设备控制不越界透传 |
| TASK-010 / WP-002 | REQ-005 | 完整彩色与纯文本快照；文件导出 API 与独立消费验证  状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)；| TASK-007,TASK-009 | AC-010：含覆盖层独立快照无需差分历史，纯文本无 ESC，写失败明确报告 |
| TASK-011 / WP-003 | REQ-003 | 横纵与弹性尺寸协商；容器尺寸算法与边界回归 | 已完成TASK-050、TASK-054；当前准入见布局装饰变更 | AC-011：窄屏、零尺寸和非整除弹性分配有确定结果 |
| TASK-012 / WP-003 | REQ-003 | 圆角边框与阴影绘制区域；装饰实现与残留场景证据 | TASK-011、TASK-054；不以覆盖层007为本片前置 | AC-012：阴影只扩展绘制；移动/缩小清旧区，服从祖先裁剪 |
| TASK-013 / WP-003 | REQ-001 | 主题、样式复用及显式复位；主题 API 与冲突优先级证据 | TASK-006,TASK-011 | AC-013：四级优先顺序和继承/复位行为明确，运行时仅样式变化也更新 |
| TASK-014 / WP-003 | REQ-001 | 自定义组件跨容器复用；组件封装公共契约及组合验证 | TASK-004,TASK-011,TASK-013 | AC-014：同组件用于普通容器与弹窗无需修改内核 |
| TASK-015 / WP-004 | REQ-002 | 稳定身份与卸载订阅释放；节点生命周期与泄漏/重排验证 | TASK-004,TASK-014 | AC-015：列表重排保留正确局部状态，卸载后订阅和引用失效 |
| TASK-016 / WP-004 | REQ-002 | 状态批处理与 UI 调度；状态绑定与调度实现、U3 证据 | TASK-008,TASK-015 | AC-016：后台状态经过调度，批量修改合并刷新，长短文本切换无残留 |
| TASK-017 / WP-004 | REQ-003 | 键盘导航和有效焦点；输入路由和焦点契约验证 | TASK-015 | AC-017：禁用、卸载和空焦点集合有确定行为，无失效引用 |
| TASK-018 / WP-004 | REQ-003 | 覆盖层嵌套与关闭恢复；覆盖层公共接口及嵌套场景验证 | TASK-012,TASK-016,TASK-017 | AC-018：父层关闭清子层、模态隔离，原焦点失效时回退且下层显示最新状态 |
| TASK-019 / WP-004 | REQ-003 | 菜单与状态条组合行为；公共组件和 U2/U4 验证 | TASK-013,TASK-017,TASK-018 | AC-019：水平/弹出菜单导航、选择、取消、禁用与窄屏状态条可组合 |
| TASK-020 / WP-004 | REQ-004、REQ-011 | 应用退出与终端模式恢复；当前Linux会话集成，其他平台后续扩展  状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)；| TASK-008,TASK-017,TASK-041 | AC-020：正常退出、异常和取消均恢复光标及终端模式 |
| TASK-021 / WP-005 | REQ-001 | M1的U1–U5示例基线，不含四主题完整展示或M2；供TASK-027复用  状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)；| TASK-010,TASK-019,TASK-020 | AC-021：minimal/composition 独立项目构建；不同业务 U5 无内核特判 |
| TASK-022 / WP-005 | REQ-004 | 交付可重复渲染基准项目；独立 benchmarks/rendering 项目与产品基准方法 | TASK-008,TASK-011,TASK-016 | AC-022：固定尺寸、中文/emoji 和批更新负载可运行，记录环境与重复结果 |
| TASK-023 / WP-005 | REQ-006、REQ-008、REQ-011 | 验证最终源码制品可独立使用；包含四主题/展示、M2及混合操作交付的真实制品；不自动上传  状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)；| TASK-009,TASK-021,TASK-022,TASK-027,TASK-030,TASK-031,TASK-032 | AC-023：实际 cjp 无开发资料；干净解包能构建主库及运行示例/基准，版本/许可证核对完整 |
| TASK-024 / WP-005 | REQ-001–011（REQ-010按可选能力矩阵） | 整体验收与发行准备；整体验收、发行检查与归档准备结论  状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)；| TASK-023 | AC-024：需求全部有证据，产品文档与制品一致；Battle 无未关闭必需失败 |

所有候选的范围限于标题行为及其调用方、回归与产品文档；不包含无关重构。实现负责人先补齐 canonical_owner、旧路径处置与兼容例外、实际必需技能、L4 输入和输出；每项代码变更遵循 AGENTS 第 10.5 节。

## 分解质量检查

规划审查见 docs/reviews/R0/result.md。近期卡片 DQ-01–05、07–12、14 按定义审查；DQ-06/13 的执行前置仍未满足，不得进入 ready。远期候选 DQ-03/05/11/13 等待具体契约后检查，不将未检查记 pass。父目标完整映射见验收矩阵，候选未完成不构成父目标通过。

## Workflow follow-up

- Linux实施授权已具备；当前变更按实际交付同步规格，必需验收与独立审查完成后才归档其真实范围，不归档为尚未完成的产品。后续仅创建具体切片变更，不重建整项目提案。后续具体变更按 AGENTS 第 10.1 节建立任务映射。

## 开发治理变更映射

GOV-001 治理修订的任务状态见 [已归档变更](../openspec/changes/archive/2026-10-18-refine-development-governance/tasks.md)，复核证据见 [R4](reviews/R4/result.md)。该变更不启动任何产品任务。

## 6. 本轮新增产品候选（状态权威仍在本文）

新增项均为planned，不是本轮实施清单。所属L1仍为G-001。WP-002/003/004/005原有职责分别扩展至下列稳定编号。TASK-001/003的调查输入扩展至本地剪贴板/标题/图片图标能力和unicodewidth候选；R5探针不满足其完整产品验收。TASK-004冻结范围纳入REQ-001–010；TASK-021只交付M1的U1–U5示例基线；四主题及完整组件展示由后续TASK-027交付，复用而不反向成为TASK-021前置。TASK-023负责新增交付的制品集成，TASK-024负责全部必需需求及M2的整体验收。通用滚动另由TASK-037交付。

- TASK-025：状态/准入/实际依赖转至[主题样式变更](../openspec/changes/implement-theme-styles/tasks.md)，保留原AC-025与需求映射。
- TASK-026：状态/准入/实际依赖转至[主题样式变更](../openspec/changes/implement-theme-styles/tasks.md)，保留原AC-026与需求映射。
- TASK-027：状态/准入/实际依赖转至[主题样式变更](../openspec/changes/implement-theme-styles/tasks.md)，保留原AC-027与需求映射。
- TASK-028：状态/准入/实际依赖转至[输入编辑变更](../openspec/changes/implement-linux-input-editing/tasks.md)，保留原AC-028与需求映射。
- TASK-029：状态/准入/实际依赖转至[标准控件变更](../openspec/changes/implement-standard-widgets/tasks.md)，保留原AC-029与需求映射。
- [ ] 6.6 TASK-030：可选会话能力与本地剪贴板通道；验收 AC-030：SSH复制目标为用户本地，粘贴接收不主动读；标题/图片图标按支持证据，发送与确认分开；缺能力不影响核心。
- TASK-031：状态/准入/实际依赖转至[M2变更](../openspec/changes/implement-incremental-rendering/tasks.md)，保留原AC-031与需求映射。
- [ ] 6.8 TASK-032：混合子元素操作与定向通知集成；验收 AC-032：声明A/B/C中插X融合排序位置；显式移动/移除、无效锚点/卸载/重入操作有诊断；定向通知合批无手动flush。

### TASK-025：分类主题配置解析与诊断

| 字段 | 定义 |
|---|---|
| level / parent / type | L3候选 / WP-003 / implementation |
| classification / basis | execution候选；外部目标已确定，进入ready前依前置契约复核技术决策 |
| requirement_refs / workflow_ref | REQ-008 / docs/tasks.md |
| openspec_change_ref / planning_gaps | null；尚未启动该产品变更 / 主题schema、仓颉解析依赖及错误签名待冻结 |
| objective / acceptance | 合法单文件主题形成结构化配置；未知字段/非法值/坏引用带位置错误，不执行代码；AC-025 |
| scope / impact | 分类主题配置解析与诊断及其公开使用文档/必要回归；不实现其他候选能力 |
| inputs / depends_on | requirements、architecture、theme-config、terminal-session及TASK-004契约 / TASK-003、TASK-004 |
| preconditions / status | 前置验收、具体变更、适用技能与DQ复核及产品实施授权 / planned |
| deliverables / verification | 对应仓颉实现、公开使用证据和正常/失败用例；精确文件/命令/API随前置契约细化，不以未来测试替代当期验收 |
| required_skills / skill_evidence_refs | 进入ready前确定并验证阶段所需OpenSpec、实现、测试、审查技能 / 当前尚未调用产品实施技能 |
| decision_refs / compatibility | 本次变更design / 无已发布API迁移；未来冻结后不得静默改约 |
| quality_governance | 对应模块唯一职责；不另建节点/样式/Unicode内核；无旧产品源码需退役 |
| risks / evidence_refs | 主题schema、仓颉解析依赖及错误签名待冻结 / 当前只有R5规划与隔离探针，非产品通过证据 |

L4在进入ready前按冻结契约展开；本候选不具备直接编码准入。

### TASK-026：应用主动主题重载与原子替换

| 字段 | 定义 |
|---|---|
| level / parent / type | L3候选 / WP-003 / implementation |
| classification / basis | execution候选；外部目标已确定，进入ready前依前置契约复核技术决策 |
| requirement_refs / workflow_ref | REQ-008 / docs/tasks.md |
| openspec_change_ref / planning_gaps | null；尚未启动该产品变更 / 重载与调度精确接口待冻结 |
| objective / acceptance | 有效重载同批次生效；失败保留旧主题，旧请求不覆盖较新请求，状态/焦点保留；AC-026 |
| scope / impact | 应用主动主题重载与原子替换及其公开使用文档/必要回归；不实现其他候选能力 |
| inputs / depends_on | requirements、architecture、theme-config、terminal-session及TASK-004契约 / TASK-013、TASK-025、TASK-016 |
| preconditions / status | 前置验收、具体变更、适用技能与DQ复核及产品实施授权 / planned |
| deliverables / verification | 对应仓颉实现、公开使用证据和正常/失败用例；精确文件/命令/API随前置契约细化，不以未来测试替代当期验收 |
| required_skills / skill_evidence_refs | 进入ready前确定并验证阶段所需OpenSpec、实现、测试、审查技能 / 当前尚未调用产品实施技能 |
| decision_refs / compatibility | 本次变更design / 无已发布API迁移；未来冻结后不得静默改约 |
| quality_governance | 对应模块唯一职责；不另建节点/样式/Unicode内核；无旧产品源码需退役 |
| risks / evidence_refs | 重载与调度精确接口待冻结 / 当前只有R5规划与隔离探针，非产品通过证据 |

L4在进入ready前按冻结契约展开；本候选不具备直接编码准入。

### TASK-027：四套预置主题及统一组件展示

| 字段 | 定义 |
|---|---|
| level / parent / type | L3候选 / WP-005 / implementation |
| classification / basis | execution候选；外部目标已确定，进入ready前依前置契约复核技术决策 |
| requirement_refs / workflow_ref | REQ-008、REQ-006 / docs/tasks.md |
| openspec_change_ref / planning_gaps | null；尚未启动该产品变更 / 主题最终配色及展示代码待实现，打包接入TASK-023 |
| objective / acceptance | 深/浅/高对比/经典主题用同一展示应用，覆盖组件状态、受限色和窄屏；制品独立运行；AC-027 |
| scope / impact | 四套预置主题及统一组件展示及其公开使用文档/必要回归；不实现其他候选能力 |
| inputs / depends_on | requirements、architecture、theme-config、terminal-session及TASK-004契约 / TASK-021、TASK-026、TASK-028、TASK-029、TASK-037 |
| preconditions / status | 前置验收、具体变更、适用技能与DQ复核及产品实施授权 / planned |
| deliverables / verification | 对应仓颉实现、公开使用证据和正常/失败用例；精确文件/命令/API随前置契约细化，不以未来测试替代当期验收 |
| required_skills / skill_evidence_refs | 进入ready前确定并验证阶段所需OpenSpec、实现、测试、审查技能 / 当前尚未调用产品实施技能 |
| decision_refs / compatibility | 本次变更design / 无已发布API迁移；未来冻结后不得静默改约 |
| quality_governance | 对应模块唯一职责；不另建节点/样式/Unicode内核；无旧产品源码需退役 |
| risks / evidence_refs | 主题最终配色及展示代码待实现，打包接入TASK-023 / 当前只有R5规划与隔离探针，非产品通过证据 |

L4在进入ready前按冻结契约展开；本候选不具备直接编码准入。

### TASK-028：基础输入编辑与标准快捷操作

| 字段 | 定义 |
|---|---|
| level / parent / type | L3候选 / WP-004 / implementation |
| classification / basis | execution候选；外部目标已确定，进入ready前依前置契约复核技术决策 |
| requirement_refs / workflow_ref | REQ-001.8、REQ-009 / docs/tasks.md |
| openspec_change_ref / planning_gaps | null；尚未启动该产品变更 / 编辑状态/撤销边界、按键及输入策略精确签名待冻结；按可选能力降级不阻塞编辑 |
| objective / acceptance | 单/多行输入、Unicode簇级移动删除选择、剪贴板结果、撤销重做；Enter默认正确，坏粘贴不误提交；AC-028 |
| scope / impact | 基础输入编辑与标准快捷操作及其公开使用文档/必要回归；不实现其他候选能力 |
| inputs / depends_on | requirements、architecture、theme-config、terminal-session及TASK-004契约 / TASK-003、TASK-004、TASK-015、TASK-017、TASK-030 |
| preconditions / status | 前置验收、具体变更、适用技能与DQ复核及产品实施授权 / planned |
| deliverables / verification | 对应仓颉实现、公开使用证据和正常/失败用例；精确文件/命令/API随前置契约细化，不以未来测试替代当期验收 |
| required_skills / skill_evidence_refs | 进入ready前确定并验证阶段所需OpenSpec、实现、测试、审查技能 / 当前尚未调用产品实施技能 |
| decision_refs / compatibility | 本次变更design / 无已发布API迁移；未来冻结后不得静默改约 |
| quality_governance | 对应模块唯一职责；不另建节点/样式/Unicode内核；无旧产品源码需退役 |
| risks / evidence_refs | 编辑状态/撤销边界、按键及输入策略精确签名待冻结；按可选能力降级不阻塞编辑 / 当前只有R5规划与隔离探针，非产品通过证据 |

L4在进入ready前按冻结契约展开；本候选不具备直接编码准入。

### TASK-029：按钮标签与选择进度基础组件

| 字段 | 定义 |
|---|---|
| level / parent / type | L3候选 / WP-004 / implementation |
| classification / basis | execution候选；外部目标已确定，进入ready前依前置契约复核技术决策 |
| requirement_refs / workflow_ref | REQ-001.8、REQ-009 / docs/tasks.md |
| openspec_change_ref / planning_gaps | null；尚未启动该产品变更 / 基础组件参数/单选分组与进度范围待冻结；不含菜单/输入既有独立任务 |
| objective / acceptance | 标签/按钮/单选/复选/进度条通过公开接口组合，状态可控、事件一次、主题一致；AC-029 |
| scope / impact | 按钮标签与选择进度基础组件及其公开使用文档/必要回归；不实现其他候选能力 |
| inputs / depends_on | requirements、architecture、theme-config、terminal-session及TASK-004契约 / TASK-004、TASK-013、TASK-014、TASK-016、TASK-017 |
| preconditions / status | 前置验收、具体变更、适用技能与DQ复核及产品实施授权 / planned |
| deliverables / verification | 对应仓颉实现、公开使用证据和正常/失败用例；精确文件/命令/API随前置契约细化，不以未来测试替代当期验收 |
| required_skills / skill_evidence_refs | 进入ready前确定并验证阶段所需OpenSpec、实现、测试、审查技能 / 当前尚未调用产品实施技能 |
| decision_refs / compatibility | 本次变更design / 无已发布API迁移；未来冻结后不得静默改约 |
| quality_governance | 对应模块唯一职责；不另建节点/样式/Unicode内核；无旧产品源码需退役 |
| risks / evidence_refs | 基础组件参数/单选分组与进度范围待冻结；不含菜单/输入既有独立任务 / 当前只有R5规划与隔离探针，非产品通过证据 |

L4在进入ready前按冻结契约展开；本候选不具备直接编码准入。

### TASK-030：可选会话能力与本地剪贴板通道

| 字段 | 定义 |
|---|---|
| level / parent / type | L3候选 / WP-004 / implementation |
| classification / basis | execution候选；外部目标已确定，进入ready前依前置契约复核技术决策 |
| requirement_refs / workflow_ref | REQ-010 / docs/tasks.md |
| openspec_change_ref / planning_gaps | null；尚未启动该产品变更 / 具体宿主/协议/权限/上限及标题图标适配证据待调查；不能承诺通用图片图标支持 |
| objective / acceptance | SSH复制目标为用户本地，粘贴接收不主动读；标题/图片图标按支持证据，发送与确认分开；缺能力不影响核心；AC-030 |
| scope / impact | 可选会话能力与本地剪贴板通道及其公开使用文档/必要回归；不实现其他候选能力 |
| inputs / depends_on | requirements、architecture、theme-config、terminal-session及TASK-004契约 / TASK-001、TASK-003、TASK-004 |
| preconditions / status | 前置验收、具体变更、适用技能与DQ复核及产品实施授权 / planned |
| deliverables / verification | 对应仓颉实现、公开使用证据和正常/失败用例；精确文件/命令/API随前置契约细化，不以未来测试替代当期验收 |
| required_skills / skill_evidence_refs | 进入ready前确定并验证阶段所需OpenSpec、实现、测试、审查技能 / 当前尚未调用产品实施技能 |
| decision_refs / compatibility | 本次变更design / 无已发布API迁移；未来冻结后不得静默改约 |
| quality_governance | 对应模块唯一职责；不另建节点/样式/Unicode内核；无旧产品源码需退役 |
| risks / evidence_refs | 具体宿主/协议/权限/上限及标题图标适配证据待调查；不能承诺通用图片图标支持 / 当前只有R5规划与隔离探针，非产品通过证据 |

L4在进入ready前按冻结契约展开；本候选不具备直接编码准入。

### TASK-031：M2局部布局绘制及基线对照

| 字段 | 定义 |
|---|---|
| level / parent / type | L3候选 / WP-002 / implementation |
| classification / basis | execution候选；外部目标已确定，进入ready前依前置契约复核技术决策 |
| requirement_refs / workflow_ref | REQ-004.8 / docs/tasks.md |
| openspec_change_ref / planning_gaps | null；尚未启动该产品变更 / M1正确性与基准前置未完成，局部依赖/缓存策略由实测细化 |
| objective / acceptance | 局部负载减少无关工作，移动/遮挡/宽字符/resize与M1帧结果一致，记录CPU/分配/输出及大范围退化；AC-031 |
| scope / impact | M2局部布局绘制及基线对照及其公开使用文档/必要回归；不实现其他候选能力 |
| inputs / depends_on | requirements、architecture、theme-config、terminal-session及TASK-004契约 / TASK-005、TASK-007、TASK-008、TASK-011、TASK-012、TASK-016、TASK-018、TASK-020、TASK-022、TASK-037 |
| preconditions / status | 前置验收、具体变更、适用技能与DQ复核及产品实施授权 / planned |
| deliverables / verification | 对应仓颉实现、公开使用证据和正常/失败用例；精确文件/命令/API随前置契约细化，不以未来测试替代当期验收 |
| required_skills / skill_evidence_refs | 进入ready前确定并验证阶段所需OpenSpec、实现、测试、审查技能 / 当前尚未调用产品实施技能 |
| decision_refs / compatibility | 本次变更design / 无已发布API迁移；未来冻结后不得静默改约 |
| quality_governance | 对应模块唯一职责；不另建节点/样式/Unicode内核；无旧产品源码需退役 |
| risks / evidence_refs | M1正确性与基准前置未完成，局部依赖/缓存策略由实测细化 / 当前只有R5规划与隔离探针，非产品通过证据 |

L4在进入ready前按冻结契约展开；本候选不具备直接编码准入。

### TASK-032：混合子元素操作与定向通知集成

| 字段 | 定义 |
|---|---|
| level / parent / type | L3候选 / WP-004 / implementation |
| classification / basis | execution候选；外部目标已确定，进入ready前依前置契约复核技术决策 |
| requirement_refs / workflow_ref | REQ-001.9、REQ-002.7/.8 / docs/tasks.md |
| openspec_change_ref / planning_gaps | null；尚未启动该产品变更 / 统一节点操作/绑定通知批次及身份冲突契约待冻结 |
| objective / acceptance | 声明A/B/C中插X融合排序位置；显式移动/移除、无效锚点/卸载/重入操作有诊断；定向通知合批无手动flush；AC-032 |
| scope / impact | 混合子元素操作与定向通知集成及其公开使用文档/必要回归；不实现其他候选能力 |
| inputs / depends_on | requirements、architecture、theme-config、terminal-session及TASK-004契约 / TASK-004、TASK-014、TASK-015、TASK-016、TASK-017 |
| preconditions / status | 前置验收、具体变更、适用技能与DQ复核及产品实施授权 / planned |
| deliverables / verification | 对应仓颉实现、公开使用证据和正常/失败用例；精确文件/命令/API随前置契约细化，不以未来测试替代当期验收 |
| required_skills / skill_evidence_refs | 进入ready前确定并验证阶段所需OpenSpec、实现、测试、审查技能 / 当前尚未调用产品实施技能 |
| decision_refs / compatibility | 本次变更design / 无已发布API迁移；未来冻结后不得静默改约 |
| quality_governance | 对应模块唯一职责；不另建节点/样式/Unicode内核；无旧产品源码需退役 |
| risks / evidence_refs | 统一节点操作/绑定通知批次及身份冲突契约待冻结 / 当前只有R5规划与隔离探针，非产品通过证据 |

L4在进入ready前按冻结契约展开；本候选不具备直接编码准入。

## 本轮文档与有界验证任务映射

TASK-033（AC-033）、TASK-034（AC-034，语言）、TASK-035（AC-035）、TASK-036（AC-036，依赖）的状态权威已转至 [refine-terminal-ui-contracts/tasks.md](../openspec/changes/refine-terminal-ui-contracts/tasks.md)，本文不复制其状态。产品TASK-001–032不因此标完成。

## 7. 通用内容滚动候选

- [x] 7.1 TASK-037：通用纵向视口及表格横向滚动；验收 AC-037：100行内容可经键盘访问全部行，宽表可横向访问；宽字符裁剪完整，resize保留有效偏移与焦点。

### TASK-037：通用视口滚动

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-003 / implementation |
| classification / basis | execution；REQ-003.10/.11、REQ-009.1，独立承担内容访问 |
| workflow_ref / openspec_change_ref | docs/tasks.md / [implement-public-interaction](../openspec/changes/implement-public-interaction/tasks.md) Unit B；支持任务103–107状态只记该权威表 |
| objective / deliverables | 通用Column/Row/Canvas viewport、ScrollView公共组合、默认纵向根兜底、横向访问、ensureVisible及公开viewport例子 |
| scope / impact | 单节点offset/有限extent/统一坐标与整簇clip；业务排序、完整表格业务、完整编辑、C层与M2另行验收 |
| inputs / depends_on | TASK004/005/011/017及已接受Runtime/Rich/Theme/Session；确切固定源码及测试见B验收原件 |
| acceptance / verification | 原AC037：80×24访问100行、横向宽内容、宽字符完整、resize钳制及焦点保持；107已据真实PTY/XTerm/VTE/LinuxVT及公开消费者判定 |
| preconditions / status | 用户已授权Linux实施及main推送；passed（原037范围），B.1 getter/onMount axes的M01明确延期TASK024 |
| required_skills / skill_evidence_refs | Superpowers独立测试/实现/源码审核/执行/验收；[B有限验收](reviews/interaction/B/TASK-107/report.md) |
| quality_governance | 唯一Runtime/节点/viewport状态/Frame/resolver；I009最多两次根协商，Root min不强撑实际Frame；保M1完整参考 |
| risks / evidence_refs | 重要缺陷经原完整审核及两轮限定复核关闭；[原件及运行图](reviews/interaction/B/README.md)，有限验收不关闭C/Keyboard/M2/023/Linux |

产品原固定源62039552已机械整合为main9cfaaa24，源码/正式测试逐字节相同。TASK027继续完整主题展示，TASK031继续局部渲染，TASK023/024继续最终集成；M01关闭前不得宣称全部B.1满足。

## 8. 必需跨平台后端候选

先完成ANSI Linux全部功能、M1/M2和TASK-023/024阶段验收，再考虑其他平台。TASK-020当前只依赖Linux后端TASK-041及共同前置，038/039/040不阻塞Linux；其他后端在Linux全量验收后再启动并逐目标扩展相同验收。最终四OS各至少一个冻结且通过的配置，才可声称完整跨平台支持；不是对所有版本/CPU/终端的无条件保证。

- [ ] 8.1 TASK-038：Windows平台会话适配；验收AC-038：Windows终端输入/输出/尺寸/模式及取消恢复，目标原生依赖可构建链接。

### TASK-038：Windows平台会话适配

| 字段 | 定义 |
|---|---|
| level / parent / type | L3候选 / WP-004 / implementation |
| classification / basis | execution候选；REQ-011确定目标，平台接口/SDK/ABI/宿主经前置调查冻结后实施 |
| requirement_refs / workflow_ref | REQ-011、REQ-003、REQ-004、REQ-009 / docs/tasks.md |
| openspec_change_ref / planning_gaps | null；未启动该产品变更 / Windows目标版本/CPU/ABI/SDK、终端宿主/权限及精确平台接口尚未冻结 |
| objective / deliverables | Windows后端及可运行字符会话证据、依赖构建/链接配置与公开限制 |
| scope / impact | 单一OS平台适配及必要调用方/回归；不复制UI/业务、不实现GUI/PTY/Shell或替代OS目标 |
| inputs / depends_on | 目标矩阵、依赖消费契约及平台适配接口 / TASK-001、TASK-003、TASK-004、TASK-024（Linux阶段全部验收后） |
| preconditions / status | 前置证据、合法目标环境、具体变更、技能/DQ准入和产品实施授权 / planned |
| acceptance / verification | AC-038：Windows终端输入/输出/尺寸/模式及取消恢复，目标原生依赖可构建链接；至少同一核心场景的键盘/Unicode/布局/固定或变化尺寸、完整/部分输出及正常/取消/异常清理可判定；无目标环境记insufficient_evidence |
| required_skills / skill_evidence_refs | ready前确定实现/测试/审查及平台环境技能 / 当前无后端执行证据 |
| decision_refs / compatibility | 变更design D-017 / 统一公开API，不要求跨OS同一二进制 |
| quality_governance | 后端封装平台差异，核心合成与Unicode算法不分叉；无旧产品实现需退役 |
| risks / evidence_refs | 终端权限/模式/键盘差异、原生ABI和运行库；缺失可选宿主功能不等于核心失败 / R6仅文档与官方证据，不代表本后端通过 |

L4及精确实现文件/命令在ready前依冻结契约细化，当前不能直接编码。

- [ ] 8.2 TASK-039：macOS平台会话适配；验收AC-039：macOS字符终端输入/输出/尺寸/模式及取消恢复，目标原生依赖可构建链接。

### TASK-039：macOS平台会话适配

| 字段 | 定义 |
|---|---|
| level / parent / type | L3候选 / WP-004 / implementation |
| classification / basis | execution候选；REQ-011确定目标，平台接口/SDK/ABI/宿主经前置调查冻结后实施 |
| requirement_refs / workflow_ref | REQ-011、REQ-003、REQ-004、REQ-009 / docs/tasks.md |
| openspec_change_ref / planning_gaps | null；未启动该产品变更 / macOS目标版本/CPU/ABI/SDK、终端宿主/权限及精确平台接口尚未冻结 |
| objective / deliverables | macOS后端及可运行字符会话证据、依赖构建/链接配置与公开限制 |
| scope / impact | 单一OS平台适配及必要调用方/回归；不复制UI/业务、不实现GUI/PTY/Shell或替代OS目标 |
| inputs / depends_on | 目标矩阵、依赖消费契约及平台适配接口 / TASK-001、TASK-003、TASK-004、TASK-024（Linux阶段全部验收后） |
| preconditions / status | 前置证据、合法目标环境、具体变更、技能/DQ准入和产品实施授权 / planned |
| acceptance / verification | AC-039：macOS字符终端输入/输出/尺寸/模式及取消恢复，目标原生依赖可构建链接；至少同一核心场景的键盘/Unicode/布局/固定或变化尺寸、完整/部分输出及正常/取消/异常清理可判定；无目标环境记insufficient_evidence |
| required_skills / skill_evidence_refs | ready前确定实现/测试/审查及平台环境技能 / 当前无后端执行证据 |
| decision_refs / compatibility | 变更design D-017 / 统一公开API，不要求跨OS同一二进制 |
| quality_governance | 后端封装平台差异，核心合成与Unicode算法不分叉；无旧产品实现需退役 |
| risks / evidence_refs | 终端权限/模式/键盘差异、原生ABI和运行库；缺失可选宿主功能不等于核心失败 / R6仅文档与官方证据，不代表本后端通过 |

L4及精确实现文件/命令在ready前依冻结契约细化，当前不能直接编码。

- [ ] 8.3 TASK-040：HarmonyOS平台会话适配；验收AC-040：HarmonyOS实际字符终端宿主可交互运行、权限/尺寸/恢复及目标原生依赖通过；交叉编译或OpenHarmony/SSH客户端不替代。

### TASK-040：HarmonyOS平台会话适配

| 字段 | 定义 |
|---|---|
| level / parent / type | L3候选 / WP-004 / implementation |
| classification / basis | execution候选；REQ-011确定目标，平台接口/SDK/ABI/宿主经前置调查冻结后实施 |
| requirement_refs / workflow_ref | REQ-011、REQ-003、REQ-004、REQ-009 / docs/tasks.md |
| openspec_change_ref / planning_gaps | null；未启动该产品变更 / HarmonyOS目标版本/CPU/ABI/SDK、终端宿主/权限及精确平台接口尚未冻结 |
| objective / deliverables | HarmonyOS后端及可运行字符会话证据、依赖构建/链接配置与公开限制 |
| scope / impact | 单一OS平台适配及必要调用方/回归；不复制UI/业务、不实现GUI/PTY/Shell或替代OS目标 |
| inputs / depends_on | 目标矩阵、依赖消费契约及平台适配接口 / TASK-001、TASK-003、TASK-004、TASK-024（Linux阶段全部验收后） |
| preconditions / status | 前置证据、合法目标环境、具体变更、技能/DQ准入和产品实施授权 / planned |
| acceptance / verification | AC-040：HarmonyOS实际字符终端宿主可交互运行、权限/尺寸/恢复及目标原生依赖通过；交叉编译或OpenHarmony/SSH客户端不替代；至少同一核心场景的键盘/Unicode/布局/固定或变化尺寸、完整/部分输出及正常/取消/异常清理可判定；无目标环境记insufficient_evidence |
| required_skills / skill_evidence_refs | ready前确定实现/测试/审查及平台环境技能 / 当前无后端执行证据 |
| decision_refs / compatibility | 变更design D-017 / 统一公开API，不要求跨OS同一二进制 |
| quality_governance | 后端封装平台差异，核心合成与Unicode算法不分叉；无旧产品实现需退役 |
| risks / evidence_refs | 终端权限/模式/键盘差异、原生ABI和运行库；缺失可选宿主功能不等于核心失败 / R6仅文档与官方证据，不代表本后端通过 |

L4及精确实现文件/命令在ready前依冻结契约细化，当前不能直接编码。

- 8.4 TASK-041：Linux平台会话适配；验收AC-041：Linux字符终端（含固定视口无图形控制台）及模拟终端输入/输出/尺寸/恢复，目标原生依赖通过。；唯一状态已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)，本文仅保留原范围/依赖定义。

### TASK-041：Linux平台会话适配

以下为原任务定义的只读历史；唯一执行状态与当前收尾步骤已转[Linux收尾tasks](../openspec/changes/complete-linux-integration/tasks.md)。不在本文维护第二份status。

| 字段 | 定义 |
|---|---|
| level / parent / type | L3候选 / WP-004 / implementation |
| classification / basis | execution候选；REQ-011确定目标，平台接口/SDK/ABI/宿主经前置调查冻结后实施 |
| requirement_refs / workflow_ref | REQ-011、REQ-003、REQ-004、REQ-009 / docs/tasks.md |
| openspec_change_ref / planning_gaps | null；未启动该产品变更 / Linux目标版本/CPU/ABI/SDK、终端宿主/权限及精确平台接口尚未冻结 |
| objective / deliverables | Linux后端及可运行字符会话证据、依赖构建/链接配置与公开限制 |
| scope / impact | 单一OS平台适配及必要调用方/回归；不复制UI/业务、不实现GUI/PTY/Shell或替代OS目标 |
| inputs / depends_on | 目标矩阵、依赖消费契约及平台适配接口 / TASK-001、TASK-003、TASK-004 |
| preconditions / status | 前置证据、合法目标环境、具体变更、技能/DQ准入和产品实施授权 / planned |
| acceptance / verification | AC-041：Linux字符终端（含固定视口无图形控制台）及模拟终端输入/输出/尺寸/恢复，目标原生依赖通过；至少同一核心场景的键盘/Unicode/布局/固定或变化尺寸、完整/部分输出及正常/取消/异常清理可判定；无目标环境记insufficient_evidence |
| required_skills / skill_evidence_refs | ready前确定实现/测试/审查及平台环境技能 / 当前无后端执行证据 |
| decision_refs / compatibility | 变更design D-017 / 统一公开API，不要求跨OS同一二进制 |
| quality_governance | 后端封装平台差异，核心合成与Unicode算法不分叉；无旧产品实现需退役 |
| risks / evidence_refs | 终端权限/模式/键盘差异、原生ABI和运行库；缺失可选宿主功能不等于核心失败 / R6仅文档与官方证据，不代表本后端通过 |

L4及精确实现文件/命令在ready前依冻结契约细化，当前不能直接编码。


R6跨平台规格补充的TASK-042（AC-042）、TASK-043（AC-043）状态仅在[变更tasks.md](../openspec/changes/refine-terminal-ui-contracts/tasks.md)；R5已完成任务保持历史结论，不覆盖到新增平台契约。

R7 Linux顺序TASK-044（AC-044）、原生构建TASK-046（AC-046）、许可来源TASK-047（AC-047）及独立审核TASK-045（AC-045）的状态仅在同一变更tasks.md。风险调查不完成产品TASK-001/003/004或041。旧R6四后端先汇合顺序由用户后续Linux优先裁决替代；历史检查脚本只适用于其受审版本，当前使用R7核对。

## 首个Linux产品切片

用户要求停止停留于文档并交付代码。TASK-048测试契约、049正式构建、050首个运行切片、051独立审核、052独立测试执行、053独立验收的唯一状态在[切片tasks](../openspec/changes/implement-linux-first-slice/tasks.md)。这是既有产品任务的有限实现切片，不将001–004、005–032等全量任务直接勾完。

Linux布局/装饰实施：TASK-011/012状态及替代前置仅见[implement-layout-decoration](../openspec/changes/implement-layout-decoration/tasks.md)；TASK-054测试、055审核、056执行、057验收同变更记录。其余原任务/状态不因此完成。

用户新增源码组织TASK-058（AC-058）随[布局装饰变更](../openspec/changes/implement-layout-decoration/tasks.md)独立实施，复用其最终审核/执行，不新增平行状态。

正常bundle阻塞修复TASK-059/060状态与准入见[布局装饰变更](../openspec/changes/implement-layout-decoration/tasks.md)，独立060测试→059代码→055定点复核→056受影响验证→057验收。

颜色/属性实施TASK-006与独立测试061、审核062、执行063、验收064唯一状态见[颜色与样式变更](../openspec/changes/implement-color-style-output/tasks.md)。

自动终端能力与跨终端截图调查TASK-065随[颜色与样式变更](../openspec/changes/implement-color-style-output/tasks.md)，用户新裁决覆盖其旧显式默认；原实现记录不作新自动验收证据。

真实跨终端测试与截图采集TASK-066依[颜色样式D031–33](../openspec/changes/implement-color-style-output/design.md)独立测试角色编写，真实host执行由TASK063负责，状态只见该change。

## Linux 全阶段连续实施

持久运行时支持TASK071–080唯一状态在[reactive-runtime tasks](../openspec/changes/implement-reactive-runtime/tasks.md)。014/015/016/032本表原完整AC保持；构造/绑定子接口分阶段交付，列表/混合结构由R13验收；014跨弹窗已由C-05同类型组件普通/覆盖层两实例及干净公开例子验证，见C独立验收。精确接口与分段前置见该design第6节。

当前用户要求完成全部 Linux；[总执行计划](linux-completion-plan.md)与[恢复日志](../openspec/linux-completion-progress.md)协调全部稳定任务，不维护第二份完成复选框。TASK-067–070（测试/审核/执行/验收支持）唯一状态在[帧合成变更](../openspec/changes/implement-frame-composition/tasks.md)，对应 AC-067–070。TASK-010 唯一复选框与状态已转[complete-linux-integration tasks](../openspec/changes/complete-linux-integration/tasks.md)；本表只保留原范围/依赖与编号映射。文件原语和覆盖层相关既有证据按已接受范围复用，完整010汇合由该收尾变更维护。

有界富文本支持TASK081–084唯一状态在[implement-rich-text](../openspec/changes/implement-rich-text/tasks.md)，对应AC081–084；原009状态同变更，010仍保持实际可见层前置。

主题样式支持TASK085–092唯一状态在[implement-theme-styles](../openspec/changes/implement-theme-styles/tasks.md)，稳定013/025/026/027同变更；013/025及085–088基础范围已独立验收，089真实异步API RED已交，026实施中；027完整展示仍等全部控件，不将基础截图当完整展示。

Linux VT自动字形子接口支持TASK093–097唯一状态在[字形适配变更](../openspec/changes/implement-linux-vt-glyph-fallback/tasks.md)，追踪原041但不转移其全量验收；093–097已按R16有限验收；主题013消费已接受生成标记策略，真实ellipsis布局仍由013/085追加/088验收。

公共交互支持TASK098–112唯一状态在[public-interaction tasks](../openspec/changes/implement-public-interaction/tasks.md)：A绘制/焦点追踪017、B纵横视口追踪037、C覆盖层追踪018；三单位及098–112均完成有限验收，原014/018完整AC已由C-05及父018四项证据关闭；菜单/标准Modal、输入编辑、M2及完整Linux另阶段。

可选会话能力TASK148–152唯一状态在[session-extensions tasks](../openspec/changes/implement-session-extensions/tasks.md)，追踪030并联004/020/041既有接口；copyLocalText同步结果供028编辑消费，不另建剪贴板队列。完整030粘贴与真实SSH仍待实际证据，图片无adapter如实降级。

输入/编辑支持TASK113–122唯一状态在[linux-input-editing tasks](../openspec/changes/implement-linux-input-editing/tasks.md)，028同变更；归一化键盘/paste关联017/020/030/041子接口，152有限会话writer先于114，完整父项仍按实际汇合，019菜单/029小控件不混编号。

M2支持TASK123–147唯一状态在[incremental-rendering tasks](../openspec/changes/implement-incremental-rendering/tasks.md)，稳定031/022同变更；完整功能M1基线在全部组件/主题/输入/示例后固定，旧idle优化不冒称M2。控件支持TASK153–162唯一状态在[standard-widgets tasks](../openspec/changes/implement-standard-widgets/tasks.md)，稳定029/019同变更，SplitPane只公共Row/Column封装支持既有011，不重开已验布局；两控件单元均等117完整键盘。

Linux收尾原001/002/003/004/008/010/020/021/023/024/041的唯一复选框/状态在[complete-linux-integration tasks](../openspec/changes/complete-linux-integration/tasks.md)。原027继续theme，022/031继续incremental-rendering，030继续session/extensions与input的原父汇合；AC事实仍只在acceptance维护。规划preflight已独立复核59bea180，不等于产品ready或passed。

实际终端宽度冲突修复TASK163–167唯一状态在[fix-uncertain-glyph-advance tasks](../openspec/changes/fix-uncertain-glyph-advance/tasks.md)。R14T083001原实际GUI失败保留；同一G005/G007/G010私有owner的纯子接口先行，完整094 native/map/publicAPI仍后置，不造084↔094环。全部当前planned，独立preflight/正式RED/实现/审核/执行/验收按该change，不因仅逻辑grid通过关闭物理失败或041/Linux。
