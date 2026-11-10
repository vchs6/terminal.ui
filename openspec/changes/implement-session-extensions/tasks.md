# Tasks

> **For agentic workers:** 独立五角色由主代理按已授权顺序派发；实施角色使用适用的subagent-driven-development/执行技能，但本草稿作者不派代理。步骤与正式任务状态只维护于本文件；具体技能版本/可用性证据在ready前由独立preflight登记。

**Goal:** 交付Application可选本地复制/标题/真实图片图标降级，并在统一Linux会话中诚实区分能力、发送和确认。

**Architecture:** 复用现有RuntimeSession、post FIFO、唯一native writer及R10恢复围栏；纯编码有界，title最多一个scope；无法确认parser同步的部分写入停止输出并保留进程期闩。

**Tech Stack:** 仓颉SDK1.2.0、现有CJPM/ANSI/Unicode依赖、现有Linux C bridge；新增产品依赖为零。

**Spec:** [design.md](design.md)、[terminal-session delta](specs/terminal-session/spec.md)。本文件是待冻结计划，所有任务planned，未编译签名不视为ready。独立目录只生成文档，没有正式测试/产品代码。

## 1. Global Constraints and Parent Mapping

- 继承design S001–S010全部精确值与边界：UTF8 65,536/1,024，icon 1,048,576，每序列wire 90,000，唯一title scope；不主动query/读clipboard/运行shell，OSC发送不可Applied。
- 主代理只协调/冻结/集成，五角色不同上下文与目录；输入只包含契约、固定版本产物/原始可复现证据，不包含产品作者自评/推理或预设通过结论。
- 原TASK-030的稳定父追踪保留，子角色148–152对应同一REQ010交付。正式工程层级仍G-001→WP-004→各可执行L3；`parent_task=TASK-030`表示父目标/验收追踪，不冒充L3中嵌套L3的工程层级。
- TASK-030不是一份额外并行实现状态；本增量角色状态由本文件权威，docs/tasks.md只映射。完整AC-030、AC-004/020/041不会因本草稿或子测试通过自动完成。
- 不修改/减弱已有R10原始断言和native围栏；Application/runtime共享编辑需与当前runtime/主题实施固定整合后顺序进行，不并行覆盖同一权威文件。
- 验证通过后才向产品文档标记可运行；无发布。真实host图片+版本/配置/grid/time/代码SHA/原始bytes对应，不能从ANSI重新画图当截图。

| 原任务/AC | 本增量消费/交付 | 剩余完整范围 |
|---|---|---|
| TASK-001 / AC001 | 独立XTerm398、VTE0.80.1、tmux3.5a、screen4.09.01原始宿主事实 | SSH、正式产品与全部Linux目标矩阵不能由host-only调查通过 |
| TASK-003 / AC003 | 现有SDK/ANSI/Unicode已验依赖，补严格UTF8/Base64可用API最小核对 | 全依赖/平台验收仍原任务负责 |
| TASK-004 / AC004 | 本design S002–S009是REQ010 Linux子接口冻结输入 | U1–U5及其他公共构造全量不能提前关闭 |
| TASK-020 / AC020 | 同一run正常/取消/异常/双失败资源围栏和title清理集成 | 全部终端模式/其他平台恢复仍未由此完成 |
| TASK-041 / AC041 | 复用Linux TTY/writer，补准确byte计数和unsafe闩 | raw/resize/固定控制台/全部输入粘贴、原生依赖完整矩阵仍须独立产品证据 |
| TASK-030 / AC030 | 148–152覆盖REQ010可选接口、拒绝/Unknown、真实host/SSH效果及恢复结果 | 粘贴安全与未来028 cut组合仍必须纳入原AC；未满足则父030保持待验 |
| TASK-028 / AC028 | S009可直接消费的copy结果规则 | 编辑选区/revision/undo、真实paste/cut全部由编辑任务实现验收，不在149隐含新增编辑器 |
| TASK-008 / AC008 | 复用停止/报告边界，对新OSC部分故障执行静默cleanup与再open拒绝 | 其他已证安全恢复不得删，完整重同步/重绘矩阵不在此冒充通过 |

## 2. Review Focus

| 最易遗漏输入/边界 | 对应正式验证归属 |
|---|---|
| Unknown默认可调用但不能升级Supported/Applied；override也不能确认 | 148 `auto_unknown`、`declared_not_applied`；151真实拒绝profile |
| clipboard里ESC/NUL/C1与title控制拒绝不同；UTF8字节边界 | 148 `clipboard_binary_scalars`、`title_controls`、`utf8_limits` |
| 完整push后set失败、重复set/restore、unknown栈不push | 148 `title_scope_ledger`、`save_set_failures`；151screen/VTE负例 |
| OSC/DCS任意偏移短写、UI清理再失败、同进程另一App重新open | 148 `partial_output_matrix`、`cleanup_aggregation`、`unsafe_reopen` |
| post排队成功但owner卸载/stop丢弃；未来cut迟到revision | 148 `owner_post_stop`、copy结果消费夹具；未来028负责真实编辑集成，152不得假关父AC |

## 3. Independent Test Contract

- [ ] 3.1 TASK-148：独立冻结公共消费者、wire/失败/host测试与真实RED；AC-148要求全部S002–S009正常、边界、故障有可定位断言及执行入口，旧产品因缺目标行为/API真实失败，夹具可自检。

| 字段 | 定义 |
|---|---|
| level / parent / parent_task / type | L3 / WP-004 / TASK-030 / verification（测试设计交付） |
| classification / basis | execution；主代理已冻结S001决策后按明确契约写独立断言，不另改产品契约 |
| requirement_refs / workflow_ref / openspec_change_ref | REQ-010.1–4、REQ-004失败、NFR03/04 / 本tasks / implement-session-extensions#3.1 |
| objective / scope | 独立可复现测试契约；包括公开CJPM消费者、手工golden、fault writer、真实host夹具；不改产品、不通过私有API模拟公共成功 |
| inputs / depends_on | 主代理固定合同SHA、独立preflight、固定旧产品SHA、host原始事实；TASK004本子合同、001独立host调查、003已验SDK输入 |
| preconditions / planning_gaps | 独立preflight需核S002 SDK类型/UTF8/Base64可用性与DQ、正式测试路径不冲突；当前未冻结故planned，不假定工具已验证 |
| deliverables | tests/session_extensions/{cjpm.toml,src/,run.sh,README.md,fixtures/}，必要native故障注入/独立host夹具；API/常量/断言清单、原始RED命令/输出/exit/SHA |
| acceptance / verification | AC148：合法Unicode精确bytes；全部禁用零输出；Applied不可达；未知栈无push；大小边界/short write/错误聚合/FIFO/reopen断言；正常CJPM消费者在旧产品真实RED，不能靠文本扫描替代 |
| impact / compatibility | 仅test及开发证据；保留现有测试，host工具绝不进入产品bundle |
| quality_governance | 必要：现有测试无REQ010消费；权威：正式独立test-only提交；旧路径：复用测试runner，不删旧断言；兼容例外无；复杂度：有界fault offsets+私有host夹具 |
| required_skills | OpenSpec apply、test-driven-development（真实RED）、verification-before-completion；故障出现才systematic-debugging；云runtime技能按实际环境 |
| skill_evidence_refs / decision_refs | ready前复用主仓已安装技能精确版本/读取记录，实际调用随test提交登记；决策S001–S010 |
| risks / blockers / evidence_refs | fixtures不能用产品encoder生成预期；SSH宿主未就绪不得伪造通过；当前证据无正式测试；status=planned |

L4：148.S1 按design精确签名/枚举/byte公式手写golden及上述case表，确认全覆盖和零写断言；148.S2 创建正常消费者和可注入现有native调用的隔离夹具，编译夹具自身并证明oracle能抓故意错误；148.S3 固定旧产品真实运行RED及日志（缺API编译错误与已有输出回归分开）；148.S4 冻结test-only SHA和执行README，不将测试作者自检冒充产品验收。

## 4. Product Delivery

- [ ] 4.1 TASK-149：在现有Application/session/native writer中实施并提供正常公共消费者；AC-149要求契约结果/字节/状态/清理符合148冻结断言，源码职责与旧路径处置可审，作者自测仅开发证据。

| 字段 | 定义 |
|---|---|
| level / parent / parent_task / type | L3 / WP-004 / TASK-030 / implementation |
| classification / basis | execution；冻结合同确定全部外部语义；SDK不可表达或新架构冲突回主代理定点裁决 |
| requirement_refs / workflow_ref / openspec_change_ref | REQ010、NFR03/04、REQ004失败 / 本tasks / implement-session-extensions#4.1 |
| objective / scope | 单一可选会话扩展交付，按design S010文件职责；不实现编辑器/第二会话/通用宿主图标/额外OS |
| inputs / depends_on | TASK148固定测试；004子合同；当前runtime已验固定整合版本；R10 native恢复围栏；003精确SDK/依赖API |
| preconditions / planning_gaps | 148冻结、独立preflight和共享Application/runtime写屏障解除；149开始前固定base/test/contract SHA；当前未满足，planned |
| deliverables | S010产品源码、docs/product/session.md及README链接、最小公共使用例；native计数与unsafe闩；开发原始命令/消费者/失败证据 |
| acceptance / verification | AC149：copy/title/icon入口正常CJPM消费者可编译；完整发送唯SentUnconfirmed；不query/shell；所有预算零输出拒绝；title一次scope；short write后close与reopen闩；无第二session/runtime；148相关tests及既有R10受影响回归成功 |
| impact / compatibility | Application/runtime/native共享文件，旧public API/颜色/帧行为保留；真实writer故障语义同源一致，不弱化既有可恢复保证 |
| quality_governance | 必要与复杂度见S010；权威writer仍原native；旧路径保留扩展无fallback内核；不增加第三方依赖/用户手动刷新；每类型独立文件 |
| required_skills | OpenSpec apply、using-git-worktrees或批准独立clone、test-driven-development、executing-plans、verification-before-completion；异常时systematic-debugging |
| skill_evidence_refs / decision_refs | 本任务ready及实际执行记录；S001–S010，148固定消费者 |
| risks / blockers / evidence_refs | 共享文件漂移/strict UTF8原生行为；Applied误报/unsafe闩绕过阻断交付；当前无产品证据；status=planned |

L4：149.S1 核固定合同/test/base及共享写屏障，按S010建每类型文件与公开签名，正常CJPM编译；149.S2 在唯一writer增加byte计数与闩并接入同步结果/stop/异常围栏，检查旧writer只有一条；149.S3 实施纯编码/声明快照/title ledger、接入现有post域和cleanup副本；149.S4 跑148及受影响R10回归，固定产品SHA/可运行说明，提交原始证据供独立角色选择，不能自标AC030通过。

## 5. Independent Review

- [ ] 5.1 TASK-150：独立审核固定产品/测试/合同；AC-150要求spec与quality分别判定，所有必修finding有可复核关闭证据，作者自评不作结论。

| 字段 | 定义 |
|---|---|
| level / parent / parent_task / type | L3 / WP-004 / TASK-030 / verification |
| classification / basis | execution；以冻结合同和真实技术diff审查，不改目标 |
| requirement_refs / workflow_ref / openspec_change_ref | REQ010及S010质量约束 / 本tasks / implement-session-extensions#5.1 |
| objective / scope | 审核公共便利性、结果可信度、上下文/队列、writer/异常/恢复/资源有界；不替代151测试执行或152验收 |
| inputs / depends_on / preconditions | TASK149固定产品SHA、148测试SHA、合同SHA，原始证据可选重现；不读取产品作者自评；独立目录/上下文；149交付后准入 |
| deliverables / acceptance | review.md、findings.json、技术diff与复现记录；AC150：无未关闭必修缺陷，明确Applied不可达/不依赖TERM/unsafe故障闩/R10保留，并核每类型文件及单一writer |
| verification | 独立读取固定源码与consumer；按实际疑点定点验证，不机械重复全部151命令；spec/quality分开结论 |
| impact / compatibility | 仅review证据，不编辑产品测试；发现通过主代理发回对应作者 |
| quality_governance | 必要：输出副作用及恢复跨边界；权威：Battle findings；旧路径核验必要；兼容例外需证据；不引入审查影子实现 |
| required_skills / skill_evidence_refs | requesting-code-review、verification-before-completion；定点故障systematic-debugging；ready/实际使用按独立报告记录 |
| decision_refs / risks / status | S001–S010；不能把declared profile当现实确认；无当前审查证据；planned |

L4：150.S1 固定三个SHA与许可输入，独立重建公开调用路径；150.S2 对S002–S010和Review Focus逐项审查，疑点定点复现；150.S3 形成分级finding，主代理转修后只复核影响范围；150.S4 冻结独立spec/quality结论与原始记录。

## 6. Independent Execution

- [ ] 6.1 TASK-151：在固定审核版本独立执行正常构建、正式测试及真实host/SSH；AC-151要求原始日志、实际exit、真实截图/属性/clipboard外部oracle与固定版本匹配，失败/缺环境不被摘要掩盖。

| 字段 | 定义 |
|---|---|
| level / parent / parent_task / type | L3 / WP-004 / TASK-030 / verification |
| classification / basis | execution；按148冻结命令和真实host矩阵运行，不改变断言 |
| requirement_refs / workflow_ref / openspec_change_ref | REQ010、REQ011 Linux限定、NFR02/03/04 / 本tasks / implement-session-extensions#6.1 |
| objective / scope | 同一正式产品二进制真实TTY/SSH/mux执行与资源/故障证据；不写产品、不把外部observer合入runtime |
| inputs / depends_on / preconditions | TASK150通过的固定产品、148固定测试/命令、合法隔离host环境；所有新实际环境记录版本/config；缺环境planned/blocked不得假pass |
| deliverables | 正常CJPM和消费构建、run.sh原始stdout/stderr/exit；wire与fault结果；产品真实host矩阵、PNG/xprop/private clipboard oracle、termios、process/syscall或等效无shell证据；文件hash |
| acceptance / verification | AC151：正式测试通过；至少XTerm398 default拒绝与enabled写入、VTE0.80.1默认/动态title、单层tmux/screen真实正负配置覆盖；正常/stop/回调异常/cleanup失败、short-write与再次open实测；真实SSH到用户本地终端验证，不用TERM模拟 |
| impact / compatibility | 全部host仅私有X/选区/配置/socket/SSH账号或自建合法临时服务，不能覆盖用户桌面/剪贴板；既有同版本原始host工具可复用但旧host-only结果不算产品通过 |
| quality_governance | 必要：wire不等于实际效果；权威原始事实；旧有效证据定界复用；无新产品依赖，夹具清理可复核 |
| required_skills / skill_evidence_refs | verification-before-completion、cloud-environment-runtime；失败时systematic-debugging；记录实际版本/使用，不声称已运行 |
| decision_refs / risks / status | S001–S010；SSH未备、宿主拒绝、部分失败夹具可信度；当前planned，无正式执行证据 |

L4：151.S1 固定base/test/contract/二进制SHA、SDK、命令及私有host隔离；151.S2 正常构建并一次执行冻结case与R10影响回归，保留失败原文；151.S3 在实际XTerm/VTE/tmux/screen及真实SSH链运行同产品，外部观测标题/剪贴板/恢复但断言产品仍SentUnconfirmed；151.S4 对fault/termios/stop/UIcleanup/再次open和无GUI降级采集可观察证据，清理夹具并冻结manifest。真实SSH可为私有loopback明确标记拓扑，不能因此声称跨网/所有客户端。

## 7. Independent Acceptance

- [ ] 7.1 TASK-152：独立按需求、接口、正式原始证据逐项验收；AC-152要求本增量pass/fail/insufficient_evidence可追踪，完整父030/004/020/041剩余范围明确，不以测试数量代替需求证据。

| 字段 | 定义 |
|---|---|
| level / parent / parent_task / type | L3 / WP-004 / TASK-030 / verification |
| classification / basis | execution；按冻结REQ010与S001–S010判定，无自行降格权限 |
| requirement_refs / workflow_ref / openspec_change_ref | REQ010、相关REQ009 cut/paste、REQ011 Linux / 本tasks / implement-session-extensions#7.1 |
| objective / scope | 对可选会话交付作独立证据充分性判定并维护父范围；不重写产品/测试，不拿作者自测或宿主调查代替产品 |
| inputs / depends_on / preconditions | TASK151固定原始事实、150固定review、产品/test/contract SHA、父映射；证据完整后进入verifying，缺证据明确列恢复条件 |
| deliverables / acceptance | report、逐REQ/AC矩阵、图/原始日志交叉核验、父项剩余列表；AC152：全部当期必需case具有真实证据，不产生无依据Applied或完整父完成结论 |
| verification | 独立核hash/命令/实际状态及代表截图，必要疑点定点复核；正式SSH、本地目标、未查询、title恢复限定、unsafe停止/资源恢复各有证据 |
| impact / compatibility | 仅验收证据与主代理集成映射；未证实平台/粘贴/cut继续pending |
| quality_governance | 必要：最终证据责任独立；权威acceptance矩阵不另立产品状态；旧证据限其配置；不引入实现 |
| required_skills / skill_evidence_refs | verification-before-completion；Battle与任务DQ复核；ready/使用记录定位于独立报告 |
| decision_refs / risks / status | S001–S010；父AC含paste/cut组合易误关；当前planned，无验收证据 |

L4：152.S1 验固定证据链与来源，拒绝环境模拟/生成图冒充host；152.S2 逐项REQ010/S002–S009核正常/拒绝/Unknown/失败/恢复/SSH；152.S3 将当前pass与030完整剩余、004/020/041范围分开，给出可定位insufficient_evidence；152.S4 交主代理集成最终矩阵，仅满足全部父AC后可关闭原030。

## 8. Draft DQ and Admission

此为作者自查，不是独立preflight通过。

| DQ | 草稿结果/理由 |
|---|---|
| 01/02 | pass（规划）：各可执行项L3，分别交付独立测试、一个产品增量、审核、执行、验收；030为原范围追踪 |
| 03/04 | pass（规划）：各卡字段/边界/共享文件与无新runtime明确；实际工具版本证据在ready补齐 |
| 05 | pass（规划）：每AC有可观察结果/入口，覆盖正常与失败，未拿未来测试当证据 |
| 06 | pass（规划）：148→149→150→151→152无环；149受当前runtime/Application固定版本屏障 |
| 07/09 | pass（规划映射）：原030全部scope可定位，paste/cut由后续父汇合不能提前关闭 |
| 08 | pass（规划）：单writer/session与状态权威；五角色不交叉改文件 |
| 10 | pass（显式未知）：无Applied adapter、SSH未备、SDK新签名未编译、host大负载未知均保留 |
| 11/12 | pass（规划）：每L4有检查点、固定SHA与原始证据；正式编号148–152需主代理核全局不冲突 |
| 13 | not_checked（准入）：独立preflight、正式技能版本/安装/SDK公开消费者尚未完成；各任务当前不ready |
| 14 | pass（规划）：必要性/职责/旧路径/兼容/复杂度已明示；unsafe闩需独立核原008/020合同，不能用草稿自评放行 |

角色模型按既有项目要求：148 Sol/high，149 Terra/high或适合仓颉的Sol/high，150 Astra/high，151 Sol/medium（故障复杂时按依据调整），152 Astra/high。此处为计划，不声称已实际派发或执行。草稿架构按本次父任务要求Astra/high，实际服务身份不能由本文件自证。

## Workflow follow-up

- 主代理冻结后将proposal/design/tasks/specs一次性集成正式change；独立preflight修补缺口，后续执行不再次询问用户许可菜单。
- 集成时将docs/terminal-session、requirements REQ010说明中“Unknown必然零输出”的旧歧义同步为显式尝试与结果分离；docs/tasks仅状态引用，acceptance保留完整父AC。
- 全部当期验收完成后按实际范围归档；不能把产品未实现、SSH证据不足或父粘贴/cut未汇合归档为全量030完成。

### L006后置交互的writer输入顺序

root按真实caret协议边界将有限148–152安排在RichText084后、Glyph/Theme/交互A前。149本来仅消费已接受runtime/148/004子合同/R10/003，不需A；152不关闭完整paste/cut030/020/041。未来A按I015使用本writer发单次mode25查询，该查询不是本可选clipboard/title/icon协议，S001/S010不主动query限制仍禁止本操作发OSC52?或新增宿主探测，不禁止独立核心caret契约。148/151原始golden按本操作事务识别，普通UI控制与未来caret查询不能伪装可选操作结果。S008唯一计数/unsafe闩由149实现，A/Keyboard复用，不加第二writer。
