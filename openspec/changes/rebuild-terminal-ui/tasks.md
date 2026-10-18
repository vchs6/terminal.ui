# Tasks

> **For agentic workers:** 后续获授权后使用 superpowers:executing-plans；按阶段使用适用技能，不自动启动本计划。

**Goal:** 按规范重建 terminal.ui 的用户构造能力并形成完整源码制品。

**Architecture:** 见 design.md；语法先验证，依赖经薄适配边界，单一节点/渲染路径。

**Tech Stack:** 仓颉 SDK 验证基线 1.2.0；中心仓 ansies 1.3.113、unicode 0.1.0。

**Spec:** specs/ 下五类规格；已有更细边界继续引用根 AGENTS.md 第 1–9 节。

## Global Constraints

- 本轮仅规划和仓库配置，不执行下列任务，所有功能任务状态为 planned。
- L1 G-001、L2 WP-001–005 由 docs/tasks.md 索引，不能直接编码。
- 本文件是任务状态唯一权威，复选框只标 L3 交付完成，不能以勾完 L4 代替验收。
- 近期 TASK-001–004 定义完整；远期为 L3 候选，需要按前置契约渐进细化、DQ 复核和实施授权后方可 ready。
- 代码质量、技能安装、任务分类和验证复用引用 AGENTS，不另立平行规则。

## Review Focus

1. 未经验证的组件块语法被误称已支持：TASK-002 须实际编译原始输入并保留错误定位。
2. 终端回复解析被误当完整 ANSI 解析：TASK-003/009 按支持矩阵测试跨块和非法输入。
3. 中文、emoji 裁剪导致孤立延续单元：TASK-005/012 验证边缘写入、移动与覆盖。
4. 弹窗关闭恢复过期帧或失效焦点：TASK-018 验证底层更新与触发节点卸载。
5. 制品中示例依赖包外目录：TASK-023 以真实 cjp 在干净目录构建和运行。

## 1. WP-001

- [ ] 1.1 TASK-001：旧行为与退役边界盘点；验收 AC-001：从 legacy 清单标出必须保留的外部行为和不保留内部 API，确认无活动入口。
- [ ] 1.2 TASK-002：验证仓颉声明式语法可编译性；验收 AC-002：分别证明组件块、链、状态、条件/列表、自定义组件与回调；记录失败定位与限制。
- [ ] 1.3 TASK-003：验证中心仓依赖与 SDK 适配边界；验收 AC-003：固定两项依赖可解析；核对 Unicode API、ANSI 生成/解析缺口及传递许可证。
- [ ] 1.4 TASK-004：冻结首个公共构造切片契约；验收 AC-004：U1–U5 设计稿均可映射至语法规则、签名、模块归属和验收，不以设计稿冒充运行。
## 2. WP-002

- [ ] 2.5 TASK-005：字符簇写入和边缘裁剪；验收 AC-005：中文、组合符和 emoji 在边缘写入/覆盖/裁剪无半宽字符或孤立延续单元。
- [ ] 2.6 TASK-006：结构化样式映射与 ANSI 编码；验收 AC-006：默认/16/256/真彩色按能力映射，组件不直接发序列。
- [ ] 2.7 TASK-007：完整目标帧与覆盖合成；验收 AC-007：透明单元和带样式空格有区别，前后层按确定规则合成。
- [ ] 2.8 TASK-008：差分提交与写失败恢复；验收 AC-008：无变化不输出；部分写失败不提交基线，下一次完整重绘。
- [ ] 2.9 TASK-009：有界增量 ANSI 输入适配；验收 AC-009：跨块、畸形、超长、未知序列按支持矩阵处理，设备控制不越界透传。
- [ ] 2.10 TASK-010：完整彩色与纯文本快照；验收 AC-010：含覆盖层独立快照无需差分历史，纯文本无 ESC，写失败明确报告。
## 3. WP-003

- [ ] 3.11 TASK-011：横纵与弹性尺寸协商；验收 AC-011：窄屏、零尺寸和非整除弹性分配有确定结果。
- [ ] 3.12 TASK-012：圆角边框与阴影绘制区域；验收 AC-012：阴影只扩展绘制；移动/缩小清旧区，服从祖先裁剪。
- [ ] 3.13 TASK-013：主题、样式复用及显式复位；验收 AC-013：四级优先顺序和继承/复位行为明确，运行时仅样式变化也更新。
- [ ] 3.14 TASK-014：自定义组件跨容器复用；验收 AC-014：同组件用于普通容器与弹窗无需修改内核。
## 4. WP-004

- [ ] 4.15 TASK-015：稳定身份与卸载订阅释放；验收 AC-015：列表重排保留正确局部状态，卸载后订阅和引用失效。
- [ ] 4.16 TASK-016：状态批处理与 UI 调度；验收 AC-016：后台状态经过调度，批量修改合并刷新，长短文本切换无残留。
- [ ] 4.17 TASK-017：键盘导航和有效焦点；验收 AC-017：禁用、卸载和空焦点集合有确定行为，无失效引用。
- [ ] 4.18 TASK-018：覆盖层嵌套与关闭恢复；验收 AC-018：父层关闭清子层、模态隔离，原焦点失效时回退且下层显示最新状态。
- [ ] 4.19 TASK-019：菜单与状态条组合行为；验收 AC-019：水平/弹出菜单导航、选择、取消、禁用与窄屏状态条可组合。
- [ ] 4.20 TASK-020：应用退出与终端模式恢复；验收 AC-020：正常退出、异常和取消均恢复光标及终端模式。
## 5. WP-005

- [ ] 5.21 TASK-021：交付 U1–U5 公开接口示例；验收 AC-021：minimal/composition 独立项目构建；不同业务 U5 无内核特判。
- [ ] 5.22 TASK-022：交付可重复渲染基准项目；验收 AC-022：固定尺寸、中文/emoji 和批更新负载可运行，记录环境与重复结果。
- [ ] 5.23 TASK-023：验证最终源码制品可独立使用；验收 AC-023：实际 cjp 无开发资料；干净解包能构建主库及运行示例/基准，版本/许可证核对完整。
- [ ] 5.24 TASK-024：整体验收与历史路径最终退役；验收 AC-024：需求全部有证据，移除 legacy 后无引用；Battle 无未关闭必需失败。

## 近期 L3 任务卡

### TASK-001：旧行为与退役边界盘点

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / investigation 或 design |
| classification / basis | decision；重建方向已定，但需要确定旧外部行为与退役范围 |
| requirement_refs / change | REQ-001 / rebuild-terminal-ui |
| objective / deliverables | 行为/入口/归属/处置表、平台/终端支持调查与引用证据 |
| scope / impact | legacy/**、docs/decisions；不修改新内核，不运行旧程序冒充新验收 |
| inputs / depends_on | legacy 文件清单、AGENTS 第 1–9 节、源码与规范基线 SHA / 无 |
| preconditions | 后续用户明确授权实施；所列前置交付及技能环境可用 |
| acceptance / verification | AC-001：从 legacy 清单标出必须保留的外部行为和不保留内部 API，确认无活动入口；以交付物、可复现命令和 Battle 结论核验 |
| required_skills | using-superpowers、brainstorming、writing-plans；涉及编译实验时按任务识别 systematic-debugging、verification-before-completion |
| skill_evidence_refs / decision_refs | 启动时记录实际安装/调用证据；现有 D-001–005 见 design.md |
| compatibility | 不承诺旧内部 API；若改变明确用户目标须另裁决 |
| quality_governance | 权威归属为对应 OpenSpec 契约；不新增活动平行内核；旧路径按 D-001；不适用兼容例外，不引入产品复杂度 |
| risks | 工具限制、源码事实与文档不一致；出现失败保留真实证据 |
| status / blockers | planned / 本轮不授权实施；另受上列依赖约束 |
| evidence_refs | 尚无任务执行证据；环境配置不等于本任务完成 |

L4：

1. TASK-001.S1：枚举 legacy 源码、导入和配置入口，并调查目标 OS、TTY/非 TTY、键盘输入、raw mode、resize 和恢复边界。检查结果：形成可定位的主路径、被调用方、历史 API 列表和待冻结平台/终端支持矩阵。
2. TASK-001.S2：将公开可观察行为逐项对照新规范并标注保留/重建/不承诺。检查结果：每项有依据，不将内部类名作为兼容证据。
3. TASK-001.S3：检查根清单、CI 和文档引用是否仍指向历史构建。检查结果：记录静态引用及仍需动态验证边界，产出处置表。
### TASK-002：验证仓颉声明式语法可编译性

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / investigation 或 design |
| classification / basis | decision；所需语法已明确，但可编译实现路线仍有技术不确定性 |
| requirement_refs / change | REQ-001 / rebuild-terminal-ui |
| objective / deliverables | 可复现的最小编译实验和语法路线结论 |
| scope / impact | 实验目录及构造契约；不扩展组件库，不以手工转换替代真实语法 |
| inputs / depends_on | TASK-001 处置表、AGENTS 第 2/4 节、SDK 1.2.0 / TASK-001 |
| preconditions | 后续用户明确授权实施；所列前置交付及技能环境可用 |
| acceptance / verification | AC-002：分别证明组件块、链、状态、条件/列表、自定义组件与回调；记录失败定位与限制；以交付物、可复现命令和 Battle 结论核验 |
| required_skills | using-superpowers、brainstorming、writing-plans；涉及编译实验时按任务识别 systematic-debugging、verification-before-completion |
| skill_evidence_refs / decision_refs | 启动时记录实际安装/调用证据；现有 D-001–005 见 design.md |
| compatibility | 不承诺旧内部 API；若改变明确用户目标须另裁决 |
| quality_governance | 权威归属为对应 OpenSpec 契约；不新增活动平行内核；旧路径按 D-001；不适用兼容例外，不引入产品复杂度 |
| risks | 工具限制、源码事实与文档不一致；出现失败保留真实证据 |
| status / blockers | planned / 本轮不授权实施；另受上列依赖约束 |
| evidence_refs | 尚无任务执行证据；环境配置不等于本任务完成 |

L4：

1. TASK-002.S1：在获授权的实验分支验证组件块与属性链原始源码。检查结果：记录源文件、工具版本、实际命令和原始错误。
2. TASK-002.S2：逐项验证状态、条件/列表、自定义组件及回调与诊断。检查结果：每项有可复现通过或失败结论，不能只写风格接近。
3. TASK-002.S3：比较现有语言能力/宏与必要的仓颉前端并完成决策 Battle。检查结果：冻结采用路线、源码形式与构建命令；目标变更交用户裁决。
### TASK-003：验证中心仓依赖与 SDK 适配边界

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / investigation 或 design |
| classification / basis | decision；中心仓选型和固定版本已定，但 API 与缺口需证据确认 |
| requirement_refs / change | REQ-004,REQ-005 / rebuild-terminal-ui |
| objective / deliverables | 版本解析证据、能力缺口矩阵及必要适配设计 |
| scope / impact | 依赖解析、文本/输出适配契约；不复制第三方内核或修改产品范围 |
| inputs / depends_on | docs/development/central-packages.json、根 cjpm.toml、TASK-001 / TASK-001 |
| preconditions | 后续用户明确授权实施；所列前置交付及技能环境可用 |
| acceptance / verification | AC-003：固定两项依赖可解析；核对 Unicode API、ANSI 生成/解析缺口及传递许可证；以交付物、可复现命令和 Battle 结论核验 |
| required_skills | using-superpowers、brainstorming、writing-plans；涉及编译实验时按任务识别 systematic-debugging、verification-before-completion |
| skill_evidence_refs / decision_refs | 启动时记录实际安装/调用证据；现有 D-001–005 见 design.md |
| compatibility | 不承诺旧内部 API；若改变明确用户目标须另裁决 |
| quality_governance | 权威归属为对应 OpenSpec 契约；不新增活动平行内核；旧路径按 D-001；不适用兼容例外，不引入产品复杂度 |
| risks | 工具限制、源码事实与文档不一致；出现失败保留真实证据 |
| status / blockers | planned / 本轮不授权实施；另受上列依赖约束 |
| evidence_refs | 尚无任务执行证据；环境配置不等于本任务完成 |

L4：

1. TASK-003.S1：用实际 cjpm update/check 解析固定中心仓版本。检查结果：留存解析结果、传递依赖、实际摘要和 SDK 版本；失败记录阻塞。
2. TASK-003.S2：核对 unicode 字符簇/宽度接口及 ansies 生成/解析接口。检查结果：产出 API/行为/缺口矩阵，分清回复解析与富文本解析。
3. TASK-003.S3：验证必要最小适配并核对传递许可证。检查结果：形成映射、限制与回归输入集合，不以文档声明替代运行证据。
### TASK-004：冻结首个公共构造切片契约

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / investigation 或 design |
| classification / basis | decision；语法与依赖调查完成后，必须冻结可实施的公开构造契约 |
| requirement_refs / change | REQ-001,REQ-002 / rebuild-terminal-ui |
| objective / deliverables | 精确语法/API 契约和后续任务输入 |
| scope / impact | docs/ui-construction 索引、OpenSpec 设计/API 契约；不实现正式内核 |
| inputs / depends_on | TASK-002 编译路线、TASK-003 缺口矩阵、U1–U5 / TASK-002,TASK-003 |
| preconditions | 后续用户明确授权实施；所列前置交付及技能环境可用 |
| acceptance / verification | AC-004：U1–U5 设计稿均可映射至语法规则、签名、模块归属和验收，不以设计稿冒充运行；以交付物、可复现命令和 Battle 结论核验 |
| required_skills | using-superpowers、brainstorming、writing-plans；涉及编译实验时按任务识别 systematic-debugging、verification-before-completion |
| skill_evidence_refs / decision_refs | 启动时记录实际安装/调用证据；现有 D-001–005 见 design.md |
| compatibility | 不承诺旧内部 API；若改变明确用户目标须另裁决 |
| quality_governance | 权威归属为对应 OpenSpec 契约；不新增活动平行内核；旧路径按 D-001；不适用兼容例外，不引入产品复杂度 |
| risks | 工具限制、源码事实与文档不一致；出现失败保留真实证据 |
| status / blockers | planned / 本轮不授权实施；另受上列依赖约束 |
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
| TASK-006 / WP-002 | REQ-005 | 结构化样式映射与 ANSI 编码；ansies 薄适配与编码矩阵 | TASK-003,TASK-004 | AC-006：默认/16/256/真彩色按能力映射，组件不直接发序列 |
| TASK-007 / WP-002 | REQ-004 | 完整目标帧与覆盖合成；合成帧实现与独立屏幕断言 | TASK-005,TASK-006 | AC-007：透明单元和带样式空格有区别，前后层按确定规则合成 |
| TASK-008 / WP-002 | REQ-004 | 差分提交与写失败恢复；差分后端及故障注入证据 | TASK-007 | AC-008：无变化不输出；部分写失败不提交基线，下一次完整重绘 |
| TASK-009 / WP-002 | REQ-005 | 有界增量 ANSI 输入适配；受限解析适配与负向输入证据 | TASK-003,TASK-006 | AC-009：跨块、畸形、超长、未知序列按支持矩阵处理，设备控制不越界透传 |
| TASK-010 / WP-002 | REQ-005 | 完整彩色与纯文本快照；文件导出 API 与独立消费验证 | TASK-007,TASK-009 | AC-010：含覆盖层独立快照无需差分历史，纯文本无 ESC，写失败明确报告 |
| TASK-011 / WP-003 | REQ-003 | 横纵与弹性尺寸协商；容器尺寸算法与边界回归 | TASK-004,TASK-005 | AC-011：窄屏、零尺寸和非整除弹性分配有确定结果 |
| TASK-012 / WP-003 | REQ-003 | 圆角边框与阴影绘制区域；装饰实现与残留场景证据 | TASK-007,TASK-011 | AC-012：阴影只扩展绘制；移动/缩小清旧区，服从祖先裁剪 |
| TASK-013 / WP-003 | REQ-001 | 主题、样式复用及显式复位；主题 API 与冲突优先级证据 | TASK-006,TASK-011 | AC-013：四级优先顺序和继承/复位行为明确，运行时仅样式变化也更新 |
| TASK-014 / WP-003 | REQ-001 | 自定义组件跨容器复用；组件封装公共契约及组合验证 | TASK-004,TASK-011,TASK-013 | AC-014：同组件用于普通容器与弹窗无需修改内核 |
| TASK-015 / WP-004 | REQ-002 | 稳定身份与卸载订阅释放；节点生命周期与泄漏/重排验证 | TASK-004,TASK-014 | AC-015：列表重排保留正确局部状态，卸载后订阅和引用失效 |
| TASK-016 / WP-004 | REQ-002 | 状态批处理与 UI 调度；状态绑定与调度实现、U3 证据 | TASK-008,TASK-015 | AC-016：后台状态经过调度，批量修改合并刷新，长短文本切换无残留 |
| TASK-017 / WP-004 | REQ-003 | 键盘导航和有效焦点；输入路由和焦点契约验证 | TASK-015 | AC-017：禁用、卸载和空焦点集合有确定行为，无失效引用 |
| TASK-018 / WP-004 | REQ-003 | 覆盖层嵌套与关闭恢复；覆盖层公共接口及嵌套场景验证 | TASK-012,TASK-016,TASK-017 | AC-018：父层关闭清子层、模态隔离，原焦点失效时回退且下层显示最新状态 |
| TASK-019 / WP-004 | REQ-003 | 菜单与状态条组合行为；公共组件和 U2/U4 验证 | TASK-013,TASK-017,TASK-018 | AC-019：水平/弹出菜单导航、选择、取消、禁用与窄屏状态条可组合 |
| TASK-020 / WP-004 | REQ-004 | 应用退出与终端模式恢复；统一应用入口和退出路径证据 | TASK-008,TASK-017 | AC-020：正常退出、异常和取消均恢复光标及终端模式 |
| TASK-021 / WP-005 | REQ-001 | 交付 U1–U5 公开接口示例；可运行示例、产品使用说明与构造便利性证据 | TASK-010,TASK-019,TASK-020 | AC-021：minimal/composition 独立项目构建；不同业务 U5 无内核特判 |
| TASK-022 / WP-005 | REQ-004 | 交付可重复渲染基准项目；独立 benchmarks/rendering 项目与产品基准方法 | TASK-008,TASK-011,TASK-016 | AC-022：固定尺寸、中文/emoji 和批更新负载可运行，记录环境与重复结果 |
| TASK-023 / WP-005 | REQ-006 | 验证最终源码制品可独立使用；制品清单、解包证据、最终发布候选；不自动上传 | TASK-021,TASK-022 | AC-023：实际 cjp 无开发资料；干净解包能构建主库及运行示例/基准，版本/许可证核对完整 |
| TASK-024 / WP-005 | REQ-001,REQ-006,REQ-007 | 整体验收与历史路径最终退役；整体验收、退役证据、归档准备结论 | TASK-023 | AC-024：需求全部有证据，移除 legacy 后无引用；Battle 无未关闭必需失败 |

所有候选的范围限于标题行为及其调用方、回归与产品文档；不包含无关重构。实现负责人先补齐 canonical_owner、旧路径处置与兼容例外、实际必需技能、L4 输入和输出；每项代码变更遵循 AGENTS 第 10.5 节。

## 分解质量检查

规划审查见 docs/reviews/R0/result.md。近期卡片 DQ-01–05、07–12、14 按定义审查；DQ-06/13 的执行前置仍未满足，不得进入 ready。远期候选 DQ-03/05/11/13 等待具体契约后检查，不将未检查记 pass。父目标完整映射见验收矩阵，候选未完成不构成父目标通过。

## Workflow follow-up

- 只有后续实施授权、必需验收及独立审查完成后，才执行适用 OpenSpec sync/archive；本轮不归档为产品完成。
