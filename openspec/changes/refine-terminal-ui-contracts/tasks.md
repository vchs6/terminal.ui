# Tasks

> 本变更仅落实规格、必要隔离验证与独立审核，不进入产品 apply。适用 Superpowers writing-plans 的任务细化映射至本文件，不另建平行计划。目标：使本轮已确认文本终端契约可审查、可追踪。产品 L1 G-001 / L2 WP-001–005 保留，执行单位为下列 L3。

## 1. Contract revision

- [x] 1.1 TASK-033：同步长期需求、架构、构造契约、治理及七项 OpenSpec 场景；验收 AC-033：严格校验、引用与需求任务映射一致，无产品实现宣称。

### TASK-033

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / documentation |
| classification / basis | execution；用户已确认总体方向并授权规格修订；工程细化由 design D-009–016 记录 |
| requirement_refs / workflow_ref | REQ-001–010 / 本文件 |
| openspec_change_ref / planning_gaps | refine-terminal-ui-contracts / 本轮文档无准入缺口；产品签名不在本轮冻结 |
| objective / deliverables | 完整提案、设计、增量/主规格、长期文档、任务/验收及新旧规则一致 |
| scope / impact | docs、openspec、AGENTS、版本与必要依赖清单；无src/examples/benchmarks实现 |
| inputs / depends_on | 用户共识、基线文档、锁定工具 / 无 |
| preconditions | 本轮用户文档授权、OpenSpec1.14.3与必需技能可读可用 |
| acceptance / verification | AC-033：npm run check、git diff --check，人工需求/场景/任务覆盖、无过时约束与假已实现结论 |
| required_skills | openspec-propose / openspec-sync-specs；brainstorming / writing-plans；verification-before-completion；使用及工具证据见R5 |
| decision_refs / skill_evidence_refs | design D-009–016 / docs/reviews/R5/input.md |
| compatibility / quality_governance | 无已发布API；修订旧规划并保留历史；requirements为需求权威，OpenSpec投影；不新增并行状态或产品内核 |
| risks / blockers | 文档漂移、未测例误称能力；由一致性检查与独立审核处理 / 无文档外部阻塞 |
| status / evidence_refs | completed / docs/reviews/R5 |

L4：
1. TASK-033.S1：核对已确认需求与基线差异，记录设计取舍和授权；检查有稳定需求编号。
2. TASK-033.S2：同步规范与场景、退役冲突规划入口；检查新增行为都有任务及验收归属。
3. TASK-033.S3：执行严格静态校验与覆盖检查；保存命令/退出码，按审核修复相关内容。

## 2. Bounded feasibility evidence

- [x] 2.1 TASK-034：隔离验证SDK1.2.0语言构造，记录正反例和限制；验收AC-034：语言证据可重跑、结论范围准确，不将产品TASK-002/004勾完。

### TASK-034

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / investigation |
| classification / basis | decision；用真实证据判断原生构造能力，依赖选型已拆至TASK-036 |
| requirement_refs / workflow_ref | REQ-001.1/.2/.10 / 本文件 |
| openspec_change_ref / planning_gaps | refine-terminal-ui-contracts / 仅有界语言调查，不承诺完整平台/产品集成 |
| objective / deliverables | 可复现仓颉语言探针、负向诊断、初值/闭包及子元素收集边界 |
| scope / impact | 仓库外实验，版本化最小源码/脚本及日志于R5；不写产品目录、不打包原生二进制 |
| inputs / depends_on | tools.lock SDK1.2.0与官方尾随Lambda说明 / 无 |
| preconditions | 隔离实验获授权、官方来源与SDK摘要可核对 |
| acceptance / verification | AC-034：尾随块/链/嵌套/显式收集/条件循环/自定义回调、闭包与初值、负例错误定位；失败保留且不伪称完整DSL/框架 |
| required_skills | using-superpowers；systematic-debugging（遇失败）；verification-before-completion |
| decision_refs / skill_evidence_refs | D-010 / R5/input.md及evidence/README.md |
| compatibility / quality_governance | 构造探针不是产品节点实现；全局构造栈不作为生产架构，语言能力不冒充依赖追踪 |
| risks / blockers | 编译器差异、语言样本不足；未覆盖能力保持pending，不改产品验收结论 |
| status / evidence_refs | completed / docs/reviews/R5/evidence/ |

L4：
1. TASK-034.S1：校验安装SDK，运行语言正负例；检查真实源码、命令与返回码可恢复。
2. TASK-034.S2：核对普通初值、保存闭包、显式子元素收集差异；检查正反例均有源码及诊断。
3. TASK-034.S3：记录原生构造可行范围并同步契约；检查依赖追踪、完整DSL与产品验收未被误标完成。


## 3. Dependency selection evidence

- [x] 3.1 TASK-036：隔离评估三项直接及传递依赖，验证联合消费并记录原生/许可边界；验收AC-036：包摘要、正负结果和选型可恢复，不冒充产品集成通过。

### TASK-036

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / investigation |
| classification / basis | decision；从原TASK-034拆分，字符依赖选型独立于语言构造，由用户授权评估 |
| requirement_refs / workflow_ref | REQ-004.3/.4、REQ-005.1 / 本文件 |
| openspec_change_ref / planning_gaps | refine-terminal-ui-contracts / 仅本轮有界样本，无完整产品集成结论 |
| objective / deliverables | 中心仓元数据/摘要、Unicode分段/宽度及ANSI探针、联合消费、原生与许可缺口 |
| scope / impact | 隔离消费项目和R5最小证据；依赖选型清单/文档；不写产品源码或第三方算法 |
| inputs / depends_on | 锁定SDK1.2.0、用户指定unicode/unicodewidth/ansies / 无；复用SDK安装，不依赖TASK-034语言结论 |
| preconditions | 官方来源可核对、隔离调查授权及环境工具可用 |
| acceptance / verification | AC-036：四包摘要核对，三依赖分别及联合消费，保留unicode纯消费链接失败和有条件成功，分段/宽度差异与许可冲突可定位 |
| required_skills / skill_evidence_refs | systematic-debugging、verification-before-completion / R5/input.md及evidence/README.md |
| decision_refs / compatibility | D-016 / 清单为未实现开发选型，不承诺跨平台或干净制品通过 |
| quality_governance | unicodewidth唯一宽度、unicode分段/规范化、ansies实际ANSI能力；不建立平行内核，relay仅隔离网络工具 |
| risks / blockers | 原生数据构建/许可尚需产品任务解决；不阻塞记录有界调查事实，不标产品通过 |
| status / evidence_refs | completed / R5/evidence/ |

L4：
1. TASK-036.S1：核对官方包与索引摘要、传递依赖和许可声明；检查实际归档与来源一致，冲突保留。
2. TASK-036.S2：运行分段/宽度/ANSI正负及联合消费，检查原生链接前提和实际API，复用有效结果不重复全量。
3. TASK-036.S3：同步选型职责和正式集成门槛；检查产品AC-003/023仍pending，没有把许可或样本缺口改写为通过。

## 4. Independent design review

- [x] 4.1 TASK-035：未参与撰写的审核代理检查全部变更，处置并复核发现；验收 AC-035：固定受审版本、findings、修复及独立复核可定位，无未关闭必需文档缺陷。

### TASK-035

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / verification |
| classification / basis | execution；按用户要求和Battle协议独立审核已形成的文档及证据 |
| requirement_refs / workflow_ref | REQ-007 / 本文件 |
| openspec_change_ref / planning_gaps | refine-terminal-ui-contracts / 无审核输入缺口后执行 |
| objective / deliverables | R5/input.md、受审补丁/版本、findings.json、独立审核结果与修复复核 |
| scope / impact | 设计与规格一致性、证据充分性、DQ-01–14；不能判产品已实现 |
| inputs / depends_on | TASK-033/034/036交付与稳定受审快照 / TASK-033、TASK-034、TASK-036 |
| preconditions | 独立审核代理无撰写参与，输入包含验收、版本及限制 |
| acceptance / verification | AC-035：查需求覆盖/旧约束冲突/任务责任/终端边界/证据，修复必需发现并独立复核；最终严格检查 |
| required_skills | requesting-code-review、receiving-code-review（收到反馈）、verification-before-completion |
| decision_refs / skill_evidence_refs | D-009–016 / R5/input.md |
| compatibility / quality_governance | 不因审核引入未授权范围；必要修复到权威文档并同步投影，无独立产品功能 |
| risks / blockers | 审核不能代替真实运行；仅标design_reviewed，不称外部机构认证 |
| status / evidence_refs | completed / docs/reviews/R5 |

L4：
1. TASK-035.S1：固定完整补丁及摘要，交给独立审核者；检查输入可唯一恢复且覆盖新增文件。
2. TASK-035.S2：逐项核实/修复或有依据驳回；检查findings有契约、位置、严重性和复现方法。
3. TASK-035.S3：独立复核修复、保存结果、运行受影响检查；检查最终无未关闭必需问题并记录验证复用边界。

## Workflow follow-up

- 本轮完成仅表示文档与有界探针交付。未来产品任务见 docs/tasks.md TASK-001–032及TASK-037–041，均需产品实施授权、契约和DQ准入；不把这些未来任务复制为本变更已完成步骤。
- 审核完成后按用户授权直接提交并推送main；不创建PR、不发布、不以本次规格同步归档产品能力。

收尾结论：TASK-033/034/035/036仅本轮范围完成；实际验收见docs/acceptance.md。独立复核070623f1014a48bd559364747550c48332c16201为design_reviewed，原5项verified。产品任务和AC仍pending，未启动产品apply。

## 5. Cross-platform amendment R6

- [x] 5.1 TASK-042：补充REQ-011四OS/HarmonyOS规格、提案、后端及验收映射并核对官方资料；验收AC-042：严格规格/引用/依赖检查通过，平台实现证据不虚构。
- [x] 5.2 TASK-043：独立审核本轮跨平台补充并复核必需修复；验收AC-043：固定版本、可定位发现和design_reviewed结论，无未关闭必需文档缺陷。

### TASK-042

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / documentation |
| classification / basis | execution；用户新增跨平台及HarmonyOS需求，延伸已有平台后端方向；四目标矩阵为工程细化 |
| requirement_refs / workflow_ref | REQ-011、NFR-07 / 本文件 |
| openspec_change_ref / planning_gaps | refine-terminal-ui-contracts / 无文档准入缺口；目标设备运行不在本轮可声称范围 |
| objective / deliverables | 明确跨平台目标、统一API/后端职责、官方证据与必需任务/验收闭合 |
| scope / impact | 规格/提案/架构/任务/验收/治理及R6来源核对；不写平台实现或GUI宿主 |
| inputs / depends_on | 用户新增需求、f998e15基线及官方仓颉/鸿蒙资料 / 无 |
| preconditions | 既有文档修订授权、工具/Skill可用及明确字符终端边界 |
| acceptance / verification | AC-042：npm run check、check-consistency及平台依赖/覆盖检查，官方事实引用与未知清楚，四目标缺一不冒充完整支持 |
| required_skills / skill_evidence_refs | brainstorming、openspec-update-change/sync-specs、verification-before-completion / R6/input.md |
| decision_refs / compatibility | D-017 / 无已发布API，开发版本仍0.0.0 |
| quality_governance | 平台差异单一后端归属；不复制UI/Unicode内核，不以Linux-only旧限制覆盖新目标；无产品旧路径退役 |
| risks / blockers | 鸿蒙终端宿主/权限、SDK/原生ABI尚需产品实测；本轮只登记不伪造通过 |
| status / evidence_refs | completed / docs/reviews/R6 |

L4：1.核对官方工具链/宿主资料与现有边界，检查来源能证明的范围；2.修订REQ/场景/设计及任务矩阵，检查四OS有独立责任且无环；3.执行引用/严格校验与独立审核修复，检查产品pending不变。

### TASK-043

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / verification |
| classification / basis | execution；按既有独立审核要求审查新增规格，不重开已确认产品方向 |
| requirement_refs / workflow_ref | REQ-007、REQ-011 / 本文件 |
| openspec_change_ref / planning_gaps | refine-terminal-ui-contracts / TASK-042交付后固定输入 |
| objective / deliverables | R6独立发现、修复复核、DQ及设计结论 |
| scope / impact | 本轮跨平台文档、任务、官方证据及其与既有核心/可选边界一致性；不审为产品运行通过 |
| inputs / depends_on | 受审commit、REQ-011及R6证据 / TASK-042文档交付 |
| preconditions | 未参与撰写且不继承作者过程上下文的独立代理，输入可恢复 |
| acceptance / verification | AC-043：覆盖四OS/HarmonyOS实际运行门槛、SDK/ABI/宿主证据等级及任务闭合；必需发现修复后复核，结论仅design_reviewed |
| required_skills / skill_evidence_refs | requesting/receiving-code-review、verification-before-completion / R6/input.md |
| decision_refs / compatibility | D-017 / 不取消必需平台目标，不把可选扩展强制为核心 |
| quality_governance | 不引入额外GUI/PTY或审批平台；修复到权威需求并同步场景 |
| risks / blockers | 无真机/对应工具链不等于文档失败，但不得记平台通过 |
| status / evidence_refs | completed / docs/reviews/R6 |

L4：1.固定版本并独立审查；2.核实/修复或有依据驳回发现；3.复核版本和检查结果，记录真实结论。

R5完成记录只覆盖原范围。R6独立审查64418db53921895e43fe7d928f806507908cd087结论design_reviewed；此前R5结论不外推，R6结果见docs/reviews/R6/result.md；未来产品TASK-038–041仍planned。

## 6. Linux-first risk amendment R7

- [ ] 6.1 TASK-044：落实Linux优先依赖顺序并验证依赖风险根因、可行处理和剩余门槛；验收AC-044：规格/任务无环且非Linux不阻塞Linux，原生构建和许可结论有固定来源与可复现证据，不伪称风险全部消除。
- [ ] 6.2 TASK-045：独立审核本轮顺序与风险证据，修复并复核必需发现；验收AC-045：固定版本和可定位发现，产品仍pending，结论仅design_reviewed。

### TASK-044

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / investigation-documentation |
| classification / basis | execution：用户指定Linux优先；decision：原生构建与许可风险按证据选择处理 |
| requirement_refs / workflow_ref | REQ-007、REQ-011、REQ-004/005、NFR-07 / 本文件 |
| openspec_change_ref / planning_gaps | refine-terminal-ui-contracts / 无本轮调查准入缺口；完整产品集成不在本任务范围 |
| objective / deliverables | Linux优先规格/任务闭合；隔离干净原生构建证据、许可来源和风险处置表 |
| scope / impact | 长期契约与场景、任务/验收映射、治理、R7证据；不实现产品、不发布 |
| inputs / depends_on | 用户后续明确顺序和风险处理要求、533bb9b基线、固定依赖及SDK / 无 |
| preconditions | 已有授权与工具可用；子代理隔离工作，不改历史依赖缓存 |
| acceptance / verification | AC-044：npm run check、依赖无环/投影一致检查；可复现命令、失败根因与处理边界明确；许可有证据不足则保持发布阻塞，不假装风险关闭 |
| required_skills / skill_evidence_refs | OpenSpec update-change/sync-specs、systematic-debugging、dispatching-parallel-agents、verification-before-completion / R7/input.md |
| decision_refs / compatibility | D-018 / 现有产品未实现；保留未来required目标及0.0.0 |
| quality_governance | 平台和字符算法保持单一职责；只退役当前四后端先汇合的依赖顺序，不删除历史审核；无平行内核或新运行依赖 |
| risks / blockers | 上游许可及干净产品制品尚待验证；准确记录不等于已解决这些外部条件 |
| status / evidence_refs | in_progress / docs/reviews/R7 |

L4：1.核对实际包与工具，定位构建失败并隔离验证；2.核对授权来源，明确已解决/可处理/阻塞与解除条件；3.同步Linux顺序和任务依赖，执行静态一致性与独立审查修复。

### TASK-045

| 字段 | 定义 |
|---|---|
| level / parent / type | L3 / WP-001 / verification |
| classification / basis | execution；已有独立审查要求，覆盖本次增量 |
| requirement_refs / workflow_ref | REQ-007、REQ-011、AC-044 / 本文件 |
| openspec_change_ref / planning_gaps | refine-terminal-ui-contracts / TASK-044交付后固定输入 |
| objective / deliverables | R7独立发现、DQ检查与修复复核结论 |
| scope / impact | Linux顺序、依赖事实和风险边界；不审为产品运行通过 |
| inputs / depends_on | 固定受审commit及R7证据 / TASK-044 |
| preconditions | 独立审核者未参与撰写，不继承作者过程上下文 |
| acceptance / verification | AC-045：DQ01–14、本轮目标/证据/任务一致；必需缺陷修复复核，结论仅design_reviewed |
| required_skills / skill_evidence_refs | requesting/receiving-code-review、verification-before-completion / R7/input.md |
| decision_refs / compatibility | D-018 / 不取消未来平台、不缩减Linux必需功能 |
| quality_governance | 不修改历史R5/R6证据，不为通过而取消许可/产品验收门槛 |
| risks / blockers | 外部授权不能由AI审核代签；不足明确保留 |
| status / evidence_refs | planned / docs/reviews/R7 |

L4：1.固定受审版本与独立输入；2.复现发现并修复或有依据说明；3.独立复核最终版本，登记实际验收结果。
