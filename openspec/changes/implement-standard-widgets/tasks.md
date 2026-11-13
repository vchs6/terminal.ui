# 标准控件支持任务候选

本文件为TASK029/019及153–162唯一任务状态入口，docs/tasks.md只保留编号映射。S01–S05的TASK153–157已完成：独立157为PASS_FINITE_S（spec/quality/evidence PASS），接受源1df1325f7b51777d8adab62f950c936051aa5876对应main 85998ead2b53cb8e6a6ab8c69e5e3efb8739411f；源码/native/构建/包配置/examples/tests/控件产品文档逐字节一致。[有限S原件与真实宿主图](../../../docs/reviews/widgets/S/README.md)。五个公开控件Label/Button/Checkbox/Radio/Progress已交付；155独立双审0具体缺陷，156普通制品/干净消费/真实XTerm、VTE、kernelVT执行已交付。M158为下一项正式独立测试工作，尚未冻结测试或取得实际前置RED；158–162均未交付。新native S只覆盖ASCII/default Classic；Unicode/disabled/explicit palette是headless S/source155及限定E后端机制复用，完整all-state/Unicode/four-theme展示仍属027/041。完整Linux/M/M1M2/父019/020/030/发布未关闭，B-M01→024、T087→023保留。

## Current admission — 2026-11-13

主代理冻结W001–W007及W006-S原文，包括最终axis在body前的SplitPane签名。独立增量preflight为READY_S_PRECONDITIONS：DQ01–14、十项任务自洽和45接口对已检查，无新必需冲突；既有WPF001/002均关闭。实际接受输入、来源及哈希见[最终S输入清单](../../../docs/reviews/widgets/S/input-manifest.json)；[独立准入表](../../../docs/reviews/widgets/S/admission/dq.md)与[接口检查](../../../docs/reviews/widgets/S/admission/sdd-preflight.md)。旧07/c732形状编译结果按宏/签名字节一致复用，不视为产品通过。以下历史候选措辞以当前准入说明为准。

## Admission

1. 主代理采纳W001–W006、采纳并验收G001/I012上游修正、冻结design/specs/tasks及输入manifest；全部新增签名经SDK1.2正常CJPM跨包消费者编译（含重载、默认参数、原始组件块），结果只证明语言/公开可见性。
2. 独立preflight逐DQ-01–14审核，待明确缺口不得not_checked升ready。上游受检源和接受结论固定SHA/哈希：Runtime C080、RichText084、Theme基础088、glyph097、交互A102与完整键盘117；菜单另等viewport107/overlay112及S157。数字表示接受任务引用，不等于当前已完成。
3. 主代理最终裁决：S153–157也等待完整键盘117固定接受源，S/M从第一次实现就共享完整ctrl/alt/shift排除条件，不保留先code/text、后由M补语义的实施分支。117自身只需公共Text/Canvas focus fixture，不依赖标准控件，因此不存在语义依赖环。
4. `docs/reviews/widgets/<S|M>/input-manifest.json`固定所有输入、源/测试hash、SDK/命令/原始日志、角色工作区和来源；实际路径映射定位现有public exports、primitive/主题状态缺口解决源、回归命令。上游未交付文件用对应接受任务清单定位，不创建替身生产代码。
5. 每单元测试作者先冻结手工期望与RED；产品只消费固定测试，不修改正式预期；审查→执行→验收分别独立上下文及目录。后续只接固定产物和契约，不接作者推理或预设通过。失败回主代理，由对应作者定点修复后复核受影响范围，AGENTS11有效证据按hash复用。

## 共同L3字段（与各卡合并为完整定义）

- level=L3；classification=execution（用户标准控件目标已定，本候选工程决策经主代理冻结后执行）；openspec_change_ref=implement-standard-widgets；workflow_ref=本tasks.md；decision_refs=design W001–W006/W006-S及G001/I012上游接受记录；goal=G-001。
- scope.includes=各卡指定单元交付及必要公开消费者/回归/文档；scope.excludes=输入编辑算法、runtime/layout/decoder/第二renderer、鼠标/拖动/虚拟化、完整四主题展示、跨平台/发布。S/M只消费117已验KeyEvent字段，不实现decoder。
- status=153–157 complete（有限S正式测试/产品/独立双审/独立执行/独立验收已交付）；158 next/planned（独立正式测试待冻结及实际前置RED），159–162 planned；planning_gaps=M正式测试和后续独立交付未完成，027/041整体展示与完整Linux保留；evidence_refs=最终S输入清单、独立157与有限S归档。
- preconditions=Admission与本卡依赖全部满足；required_skills=测试角色TDD+verification、产品TDD+executing-plans+verification、审核requesting-code-review+verification、执行/验收verification；失败按需systematic-debugging，修复反馈按receiving-code-review。适用OpenSpec工作流及仓颉规范从实际环境读取，skill_evidence_refs在ready时记录来源/版本/可用性至该卡证据目录，当前未伪造已使用记录。
- compatibility=所有已有公共primitive/组件块入口保留，同槽后写替换不改变；没有已发布本件widget API需兼容；公开callbacks异常/代际和主题优先级继承上游。quality_governance.compatibility_exceptions=[LEGACY-PROP-001：保持已接受layout旧常量快捷入口IllegalArgumentException；typed/getter/样式能力检查严格InvalidProperty，见design限定裁决]。
- quality_governance.necessity=已要求控件缺公开可用组合与独立证据；canonical_owner=业务checked/radio/menu顺序归应用，公开控件工厂组合行为，Runtime/focus/overlay/layout/Theme/Unicode仍原唯一权威；old_path_disposition=无旧widget公开实现需退役，沿用primitive，不增兼容别名；complexity_delta=有限工厂/一份菜单own refs索引，禁止第二业务状态或内核。非产品角色只写证据不改运行路径。
- impact=单元文件表、公开使用指南及受影响回归；risks=主题状态G001、事件重复/资格时序、ForEach旧值闭包、窄屏/零宽、回调失败恢复、独立角色混写；该卡AC覆盖对应风险。
- models为调度建议而非实际serving认证：测试Sol/high、产品Terra/high、审核/验收Astra/high、确定命令执行Sol/medium。各卡执行记录实际工具能确认的信息，不猜模型。
- verification入口均为**计划**：S `bash tests/widgets_small/run.sh`，M `bash tests/widgets_composite/run.sh`；脚本由测试作者创建，含正常cjpm消费者、独立断言和PTY用例。独立执行需记录精确工作目录/环境/命令/退出码/日志/hash，未存在入口不能当已运行。产品构建使用固定源仓库正式cjpm入口，独立bundle消费入口由测试者写入README；不预报未执行命令通过。

## 文件职责

| 单元 | 产品拟新增 | 独立测试/公开例子/文档 | 沿用与限制 |
|---|---|---|---|
| S | src/label.cj,button.cj,checkbox.cj,radio.cj,progress.cj；内聚纯函数src/widget_caption.cj,widget_activation.cj；根exports | tests/widgets_small/{cjpm.toml,src/main.cj,run.sh,README.md}，examples/widgets_small/，docs/product/widgets.md | 普通Text/Canvas与public API，无改私有RuntimeNode/renderer；新类型若确需增加必须单类型单文件 |
| M | src/menu_entry.cj,split_axis.cj；工厂horizontal_menu.cj,popup_menu.cj,status_bar.cj,split_pane.cj；共用菜单组合纯函数menu_composition.cj及需要时单独own-ref索引类型文件；exports | tests/widgets_composite/{cjpm.toml,src/main.cj,run.sh,README.md}，examples/widgets_composition/；续同指南 | 只公有ForEach/ListItem/ref/defaultAction/overlay；沿用S首次已消费117的完整公共activation条件，不能改decoder |

短文件名均相对src/。纯函数按职责内聚，不机械一个函数一文件；MenuEntry/SplitAxis等实体各独立文件。实际跨包组织在固定输入映射按现Cangjie package规则确定；不得为了编译把内部runtime公开。测试/产品/审查不交叉编辑。主代理顺序集成后同步产品README，原TASK019/029及AC矩阵只在完整范围证据满足时转移/闭合。

## 验收目录

| ID | 条件/动作 → 可观察结果 | 必需证据 |
|---|---|---|
| S01 | 五控件正常公开构造、常量/getter/命名label/原始块与链→编译并同一Runtime正确呈现，无private/kind/ANSI | 独立正常CJPM源码、干净bundle消费者、代码边界审查 |
| S02 | Enter/Space、未聚焦目标、disabled祖先、capture/bubble/app prevent与stop→回调精确0/1；Checkbox应用不写则值不变，Radio已选0次，重复label不分组 | 手工事件trace/模型断言；真实HT/Enter/Space输入及退出 |
| S03 | getter替换/长短Unicode/空label/非法控制与换行→最新值与整簇裁剪，规定错误；主题focused/selected/disabled及显式覆盖 | 手工Frame/Style期望；I012修订后detached/mounted、祖先disabled、后链enabled、显式false不能屏蔽真实态的精确golden |
| S04 | fraction=0,0.5,1、-0，w=0/1/20、h=0/1/2、主题尺寸/padding/viewport→精确'='/'-'列数，默认自然20×1；非finite/范围外即使零宽也拒绝 | 手工期待条、异常码、paint-only依赖观察；不假设M1 measure调用不增 |
| S05 | 回调/getter抛错、控件卸载重挂/后台post/同模型多视图→资源清理一次、旧ref不复活、业务数据保留、正常native恢复 | 生命周期/公开stats、原始PTY退出恢复/错误记录 |
| M01 | items同key换值/重排、禁用/删除、重复key→保正确ref/最新label/enabled，错误批不部分挂载、不改源数组 | 独立对象/顺序/错误/引用断言 |
| M02 | horizontal左/右、popup上/下、Home/End、循环/单项/空/全禁用、手动同父move→只导航eligible own entries，Enter/Space仅请求key一次；Tab不trap | 精确focus/key trace、公开children顺序；共享117完整无修饰条件及S必要回归 |
| M03 | 真overlay中Popup与内联Popup、嵌套modal、Esc阻断/取消、onChoose明确close、owner/anchor失效→公共C关闭/焦点恢复、无新Application | 独立层/焦点/底层最新frame及真实终端键盘 |
| M04 | Row自然StatusBar空/单/多行、主题height1与显式覆盖、极窄与零屏；两轴SplitPane嵌套权重/奇数余量→严格原布局，不贴底、不私改visible | 手工精确网格，原TASK011布局回归复用 |
| M05 | 同自定义面板两个实例普通/层共享model、菜单+ScrollView+StatusBar+四角色样式→可组合与最新状态，无私有kind；错误回调恢复 | 公开消费者/代码审查/PTY；只本单元局部主题集成，不冒充TASK027完整展示 |

## 完整L3卡

### TASK-153：编写小控件独立测试

| 字段 | 值 |
|---|---|
| level / parent / parent_task | L3 / WP-004 / TASK-029 |
| type / unit / title | test-design / S / 编写小控件独立测试 |
| requirement_refs | REQ-001.4–.8、REQ-002.2–.6/.9、REQ-008、REQ-009 |
| objective | 按冻结契约形成可失败、手工期望且与产品无共享推导的测试包 |
| inputs / depends_on | design/specs本单元和Admission固定输入；080,084,088,097,102,117和G001/I012修正已验的固定输入 |
| deliverables | 测试源码、预期帧/trace、正常消费者、RED日志与测试hash |
| acceptance / verification | S01–S05：采用验收目录的条件→结果→证据；S计划运行入口及本卡角色职责，不把未执行计划当通过 |
| scope / impact | 仅S文件表及本角色产物；共同字段排除项有效 |
| status / blockers / evidence_refs | complete / 本单元已独立有限验收；完整Linux另汇合 / 1df1325f/main85998ead、157 PASS_FINITE_S、最终S输入清单及有限S归档 |

L4（本有限S角色步骤已交付，原件见归档）：

- [x] TASK-153.S1：逐项映射S01–S05并编写常量/getter/回调/原始组件块公开消费者。检查结果：coverage表含正常、非法caption、0/1/20宽和异常恢复，未访问私有符号。
- [x] TASK-153.S2：手写controlled-state、Radio已选、事件阻断/stop、theme-disabled及卸载的预期。检查结果：预期值独立列出；不得import产品helper生成oracle。
- [x] TASK-153.S3：在固定前置源运行并记录RED原因，冻结脚本与输入哈希。检查结果：失败证明新API/行为尚缺或已有明确对照，语言缺SDK单列insufficient_evidence。

### TASK-154：以公开能力实现小控件

| 字段 | 值 |
|---|---|
| level / parent / parent_task | L3 / WP-004 / TASK-029 |
| type / unit / title | implementation / S / 以公开能力实现小控件 |
| requirement_refs | REQ-001.4–.8、REQ-002.2–.6/.9、REQ-008、REQ-009 |
| objective | 实现五控件而保持业务状态和公共渲染权威唯一 |
| inputs / depends_on | design/specs本单元和Admission固定输入；TASK-153固定测试+S所有上游接受源 |
| deliverables | 产品提交、公开例子/指南、必要开发验证日志与源码hash |
| acceptance / verification | S01–S05：采用验收目录的条件→结果→证据；S计划运行入口及本卡角色职责，不把未执行计划当通过 |
| scope / impact | 仅S文件表及本角色产物；共同字段排除项有效 |
| status / blockers / evidence_refs | complete / 本单元已独立有限验收；完整Linux另汇合 / 1df1325f/main85998ead、157 PASS_FINITE_S、最终S输入清单及有限S归档 |

L4（本有限S角色步骤已交付，原件见归档）：

- [x] TASK-154.S1：定位固定上游公开符号和collector根登记，完成实际输入/文件清单。检查结果：工厂恰一个root；没有运行时/主题私有访问和新kind。
- [x] TASK-154.S2：实现caption/getter、once Target请求、ASCII标记与Canvas纯paint进度；按G001已接受方案接主题状态。检查结果：checked/radio不私写；Progress measure不读fraction；样式只有统一resolver。
- [x] TASK-154.S3：同步用户组件块例子、覆写槽/Status范围指南并运行必要开发验证。检查结果：固定153测试不被修改；列出受影响回归及未通过项。

### TASK-155：独立审核小控件固定提交

| 字段 | 值 |
|---|---|
| level / parent / parent_task | L3 / WP-004 / TASK-029 |
| type / unit / title | review / S / 独立审核小控件固定提交 |
| requirement_refs | REQ-001.4–.8、REQ-002.2–.6/.9、REQ-008、REQ-009 |
| objective | 从合同独立审查边界、正确性和测试盲区 |
| inputs / depends_on | design/specs本单元和Admission固定输入；TASK-154源码hash+TASK-153测试hash |
| deliverables | 审查report/findings、固定源hash、逐AC结论 |
| acceptance / verification | S01–S05：采用验收目录的条件→结果→证据；S计划运行入口及本卡角色职责，不把未执行计划当通过 |
| scope / impact | 仅S文件表及本角色产物；共同字段排除项有效 |
| status / blockers / evidence_refs | complete / 本单元已独立有限验收；完整Linux另汇合 / 1df1325f/main85998ead、157 PASS_FINITE_S、最终S输入清单及有限S归档 |

L4（本有限S角色步骤已交付，原件见归档）：

- [x] TASK-155.S1：只接固定契约/源/测试而非作者自评，审查公共依赖与变更必要性。检查结果：无私有内核读取、重复状态、重复默认动作或未退役分支。
- [x] TASK-155.S2：审核事件/主题/G001、数值边界与非法输入测试可判定性。检查结果：每个缺陷有可达触发与合同引用，不以测试数量判通过。
- [x] TASK-155.S3：报告阻塞项并交主代理分派修复；对修订hash复核受影响部分。检查结果：未解决缺陷不写通过；记录证据复用条件。

### TASK-156：独立构建执行小控件测试

| 字段 | 值 |
|---|---|
| level / parent / parent_task | L3 / WP-004 / TASK-029 |
| type / unit / title | verification / S / 独立构建执行小控件测试 |
| requirement_refs | REQ-001.4–.8、REQ-002.2–.6/.9、REQ-008、REQ-009 |
| objective | 独立复现公开消费者、帧/事件/错误与终端行为 |
| inputs / depends_on | design/specs本单元和Admission固定输入；TASK-155可执行审核结论+固定154/153产物 |
| deliverables | 命令/环境/退出码/原始日志及hash、执行结论 |
| acceptance / verification | S01–S05：采用验收目录的条件→结果→证据；S计划运行入口及本卡角色职责，不把未执行计划当通过 |
| scope / impact | 仅S文件表及本角色产物；共同字段排除项有效 |
| status / blockers / evidence_refs | complete / 本单元已独立有限验收；完整Linux另汇合 / 1df1325f/main85998ead、157 PASS_FINITE_S、最终S输入清单及有限S归档 |

L4（本有限S角色步骤已交付，原件见归档）：

- [x] TASK-156.S1：隔离检出受检源码与测试hash，记录SDK和依赖固定清单。检查结果：环境和内容与审核对象一致，未使用产品作者输出代替。
- [x] TASK-156.S2：执行widgets_small/run.sh、干净bundle消费者及必需已有回归/PTY。检查结果：S01–S05逐项有原始结果；缺真实终端范围记insufficient_evidence。
- [x] TASK-156.S3：固定所有日志与失败复现并回传主代理。检查结果：不能修产品或改预期；失败不反复重跑同一未改原因。

### TASK-157：独立验收小控件单元

| 字段 | 值 |
|---|---|
| level / parent / parent_task | L3 / WP-004 / TASK-029 |
| type / unit / title | acceptance / S / 独立验收小控件单元 |
| requirement_refs | REQ-001.4–.8、REQ-002.2–.6/.9、REQ-008、REQ-009 |
| objective | 判断TASK029局部/全范围证据是否足够，并发布后续M可消费接受输入 |
| inputs / depends_on | design/specs本单元和Admission固定输入；TASK-155审核+TASK-156执行固定证据 |
| deliverables | 逐需求AC证据矩阵、接受或拒绝报告、固定可消费源清单 |
| acceptance / verification | S01–S05：采用验收目录的条件→结果→证据；S计划运行入口及本卡角色职责，不把未执行计划当通过 |
| scope / impact | 仅S文件表及本角色产物；共同字段排除项有效 |
| status / blockers / evidence_refs | complete / 本单元已独立有限验收；完整Linux另汇合 / 1df1325f/main85998ead、157 PASS_FINITE_S、最终S输入清单及有限S归档 |

L4（本有限S角色步骤已交付，原件见归档）：

- [x] TASK-157.S1：核对153测试、154源码、155审核、156执行的同内容链。检查结果：不存在相邻HEAD替代、作者自测代替独立执行。
- [x] TASK-157.S2：独立复核controlled callback、主题G001、数字边界和真实键输入/恢复证据。检查结果：S01–S05均可判定；missing evidence明确拒绝完整接受。
- [x] TASK-157.S3：输出可消费固定源和父029覆盖/剩余项给主代理。检查结果：不自动关闭其他父项或TASK027，不擅改主仓状态。

### TASK-158：编写菜单状态分区独立测试

| 字段 | 值 |
|---|---|
| level / parent / parent_task | L3 / WP-004；Split关联WP-003 / TASK-019；关联TASK-011 |
| type / unit / title | test-design / M / 编写菜单状态分区独立测试 |
| requirement_refs | REQ-001.8、REQ-001.5、REQ-002.2–.4/.8–.9、REQ-003.1/.11、REQ-008、REQ-009 |
| objective | 形成菜单身份/导航/overlay与布局组合的独立测试包 |
| inputs / depends_on | design/specs本单元和Admission固定输入；TASK-157+107+112+117及M上游固定接受源 |
| deliverables | 测试源码、手工帧/焦点trace、RED和hash |
| acceptance / verification | M01–M05及受影响S02回归：采用验收目录的条件→结果→证据；M计划运行入口及本卡角色职责，不把未执行计划当通过 |
| scope / impact | 仅M文件表及本角色产物；共同字段排除项有效 |
| status / blockers / evidence_refs | planned（next） / S157已接受；M正式测试、实际前置验证与RED仍待交付 / 有限S157归档；M尚无测试冻结结论 |

L4（每步均未执行）：

- [ ] TASK-158.S1：映射M01–M05并构造items替换/duplicate/disabled/remove/manual move案例。检查结果：业务顺序不被改、ForEach retained值可观察，预期不来自实现。
- [ ] TASK-158.S2：编写overlay真实键取消/恢复与Status自然Row/Split权重窄屏精确期望。检查结果：内联不假关层；空/全disabled可Esc；无截图代替原始行为。
- [ ] TASK-158.S3：覆盖S已采用的modified Space/Enter排除及必要S回归，冻结RED产物。检查结果：S/M激活规则同一公共helper合同，不引入第二decoder。

### TASK-159：公共组合菜单状态分区

| 字段 | 值 |
|---|---|
| level / parent / parent_task | L3 / WP-004；Split关联WP-003 / TASK-019；关联TASK-011 |
| type / unit / title | implementation / M / 公共组合菜单状态分区 |
| requirement_refs | REQ-001.8、REQ-001.5、REQ-002.2–.4/.8–.9、REQ-003.1/.11、REQ-008、REQ-009 |
| objective | 交付菜单、状态栏和薄分区工厂及普通/overlay复用 |
| inputs / depends_on | design/specs本单元和Admission固定输入；TASK-158固定测试+M全部上游接受源 |
| deliverables | 产品固定提交、组合例子、指南、开发验证 |
| acceptance / verification | M01–M05及受影响S02回归：采用验收目录的条件→结果→证据；M计划运行入口及本卡角色职责，不把未执行计划当通过 |
| scope / impact | 仅M文件表及本角色产物；共同字段排除项有效 |
| status / blockers / evidence_refs | planned / 共同Admission与上述依赖未核验 / [] |

L4（每步均未执行）：

- [ ] TASK-159.S1：实现MenuEntry与ForEach retained slot、own ref生命周期和Ancestor导航。检查结果：当前数据/实际children顺序正确；不扫描私有树或排序业务。
- [ ] TASK-159.S2：实现Popup公开overlay消费示例、Status自然Row、SplitPane两轴；复用S已经接受的117完整激活条件。检查结果：没有第二Application、私有intrinsic、鼠标/分隔绘制新增范围。
- [ ] TASK-159.S3：同步公开指南与S/M必要回归并提交固定源。检查结果：158正式测试不修改，输入/导出/依赖变动全部可追踪。

### TASK-160：独立审核组合控件

| 字段 | 值 |
|---|---|
| level / parent / parent_task | L3 / WP-004；Split关联WP-003 / TASK-019；关联TASK-011 |
| type / unit / title | review / M / 独立审核组合控件 |
| requirement_refs | REQ-001.8、REQ-001.5、REQ-002.2–.4/.8–.9、REQ-003.1/.11、REQ-008、REQ-009 |
| objective | 独立核查公开组合、实际导航和原父范围覆盖 |
| inputs / depends_on | design/specs本单元和Admission固定输入；TASK-159源码hash+TASK-158测试hash |
| deliverables | 审查findings/逐AC结果/固定源hash |
| acceptance / verification | M01–M05及受影响S02回归：采用验收目录的条件→结果→证据；M计划运行入口及本卡角色职责，不把未执行计划当通过 |
| scope / impact | 仅M文件表及本角色产物；共同字段排除项有效 |
| status / blockers / evidence_refs | planned / 共同Admission与上述依赖未核验 / [] |

L4（每步均未执行）：

- [ ] TASK-160.S1：审核菜单只读业务数据、身份/回调一次、Tab及箭头默认槽。检查结果：ForEach不捕获旧值，无私有runtime/新kind，无双dispatch。
- [ ] TASK-160.S2：审核Popup所有权/取消、Status自然高及Split原布局复用。检查结果：不借019重写布局，不压主题height，不暗中自动close。
- [ ] TASK-160.S3：复核修订对S/M共用activation的回归影响。检查结果：所有阻塞缺陷通过主代理反馈，不直接改源测试。

### TASK-161：独立执行组合控件测试

| 字段 | 值 |
|---|---|
| level / parent / parent_task | L3 / WP-004；Split关联WP-003 / TASK-019；关联TASK-011 |
| type / unit / title | verification / M / 独立执行组合控件测试 |
| requirement_refs | REQ-001.8、REQ-001.5、REQ-002.2–.4/.8–.9、REQ-003.1/.11、REQ-008、REQ-009 |
| objective | 独立复现菜单keyboard/overlay和窄屏布局集成 |
| inputs / depends_on | design/specs本单元和Admission固定输入；TASK-160可执行审核结论+159/158固定产物 |
| deliverables | 命令/环境/原始PTY和日志/hash、执行结果 |
| acceptance / verification | M01–M05及受影响S02回归：采用验收目录的条件→结果→证据；M计划运行入口及本卡角色职责，不把未执行计划当通过 |
| scope / impact | 仅M文件表及本角色产物；共同字段排除项有效 |
| status / blockers / evidence_refs | planned / 共同Admission与上述依赖未核验 / [] |

L4（每步均未执行）：

- [ ] TASK-161.S1：隔离固定源/测试/依赖输入，验证公共bundle消费者入口。检查结果：所有依赖来自接受源，不以当前共享HEAD当固定输入。
- [ ] TASK-161.S2：执行widgets_composite/run.sh及受影响S回归、原布局/overlay必要检查。检查结果：菜单导航真实键含循环/Home/End/Esc/Tab，精确帧与模型可复核。
- [ ] TASK-161.S3：输出原始退出恢复与故障结果，标明未获环境证据。检查结果：不以截图或合成按键日志冒充真实终端，不越权修测试。

### TASK-162：独立验收组合控件

| 字段 | 值 |
|---|---|
| level / parent / parent_task | L3 / WP-004；Split关联WP-003 / TASK-019；关联TASK-011 |
| type / unit / title | acceptance / M / 独立验收组合控件 |
| requirement_refs | REQ-001.8、REQ-001.5、REQ-002.2–.4/.8–.9、REQ-003.1/.11、REQ-008、REQ-009 |
| objective | 判断AC019与Split薄组合证据并形成下游集成输入 |
| inputs / depends_on | design/specs本单元和Admission固定输入；TASK-160审核+TASK-161执行固定证据 |
| deliverables | 接受/拒绝报告、父范围矩阵、固定源manifest |
| acceptance / verification | M01–M05及受影响S02回归：采用验收目录的条件→结果→证据；M计划运行入口及本卡角色职责，不把未执行计划当通过 |
| scope / impact | 仅M文件表及本角色产物；共同字段排除项有效 |
| status / blockers / evidence_refs | planned / 共同Admission与上述依赖未核验 / [] |

L4（每步均未执行）：

- [ ] TASK-162.S1：对齐158–161内容hash和独立角色链，检查全部M与S受影响AC。检查结果：源/测试/命令与审核结论严格对应。
- [ ] TASK-162.S2：复核真实输入、业务顺序、popup focus/cancel与窄屏手工预期。检查结果：缺任一必需证据不标完整接受，不凭截图或数量代替。
- [ ] TASK-162.S3：交接固定源及U2/U4/U5、TASK027后续集成边界。检查结果：只给主代理状态同步建议；不自动宣布Linux整体/主题展示完成。

## DQ初始状态及父项闭合

DQ-01–14全部not_checked，待独立preflight逐项给证据；本作者不自行授予pass。DQ05必检，G001/签名/前置未解决使DQ06/10/13不能ready。所有卡字段通过共同字段+本卡+AC目录组成，并非只标题复选框。

157负责S本单元接受，162负责M本单元及受影响S集成接受（沿用S首次已消费的117条件）；TASK029/019完整关闭须主代理对原AC范围核验，TASK011只记录Split薄组合追加证据。U2/U4/U5完整场景、四主题展示027、全Linux整体验收在原独立父项继续，不能支持任务全部勾选即自动关闭。

W007最终SplitPane签名及isVisible菜单资格与153/158正式测试同步；SDKshape成功仅证明语法，实际产品依赖未取得不能升execution ready。
