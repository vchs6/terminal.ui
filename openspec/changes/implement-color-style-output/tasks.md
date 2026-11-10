# Color style output implementation plan

Goal：在同一组件/Frame/ANSI路径完成TASK006，为主题提供可复用颜色/属性基础。
Spec：design.md精确API/投影/行为。Baseline96bdb9b。Stack：仓颉SDK1.2.0、原ansies/unicode/unicodewidth，产品0.0.0。

## Global constraints

主代理仅契约/文档/集成；独立测试设计→产品实现→审核→执行→验收，各自fresh上下文和目录，只交冻结产物，不交作者推理/预设通过结论。用户连续实施和direct-main授权有效。遵守AGENTS14包/实体文件与用户两份参考；不改变第三方代码/许可，不引入新运行依赖。
只改style/encoding/Frame输出diff/组件属性继承/App模式/示例和对应文档。不得另建ANSI/Unicode/Frame或持久投影内核；input/会话原生逻辑/布局算法/D027恢复保持；D031允许新增独立可选capability C模块和正常archive构建接入。既有8色/bold字节与全部R8/R9/060断言保留，不为新模式弱化oldtests。完整项目及其他平台未因此完成。

## 1. Independent test contract

- [ ] 1.1 TASK-061：冻结独立public颜色/属性消费者、真实PTY例子/模式静默fixture及runner；AC061：缺新API真实RED、手算golden/明确模式/握手、旧断言不变。

## 2. Implementation

### Task 2: TASK-006 color and style output

- [ ] 2.1 TASK-006：实现design全部Color/Style/ColorMode、组件布尔属性、能力映射及有效输出差分、Application模式与colors示例；AC006：默认/16/256/RGB按模式映射，组件不发ANSI，同一原始Style可多模式输出且不可见变化静默。

Files：src/style/color.cj/style.cj/new color_mode.cj、src/color_mapping.cj（纯内部策略建议）、src/exports.cj/ansi_encoding.cj/frame.cj/component.cj/layout.cj/application.cj、examples/colors与docs/product。每实体单文件；旧ansiColor与encodeStyle原路径直接扩展/替换，旧转换路径不得并存。依赖converter不被调用，真实依赖编码保留。L4：冻结061RED→模型/名义策略/共享继承→编码/有效diff与App已显示模式→公开例子和针对自测→提交审核。不写/改tests。

## 3. Quality gates

- [ ] 3.1 TASK-062：独立整片spec/quality代码审核、真实反例及必要作者修复复核；AC062：固定完整diff+contract passed，无必需未决失败。
- [ ] 3.2 TASK-063：独立cold slice/真实colors与静默PTY/标准bundle/clean consumer执行；AC063：实际退出/raw/hash齐全，完整release缺项不标pass。
- [ ] 3.3 TASK-064：独立有限需求及最终集成验收；AC064：代码/证据/状态一致，未重复功能测试，正常direct-main集成。

## L3 cards and preflight

唯一task状态为上面checkbox，docs/tasks只引用。TASK006稳定ID转入本变更，不创建重复实现状态。support061–064均L3，父WP005验证支持；006父WP002。schema skip_specs实现已存在REQ，不新增规格能力。

| task/type | inputs / depends_on | deliverable / acceptance | skills/quality/risks |
|---|---|---|---|
| 061 testing | design冻结/96b基线 / 无 | tests/colors、实际例子PTY、差分静默fixture、runner与RED / AC061 | Sol/high；TDD/verification/cangjie-coding；独立golden及事件握手，不看作者 |
| 006 implementation | 061冻结 + 已完成050/R9 + dependency-api事实 / 061 | 单共享输出路径及公开示例 / AC006 | Terra/high；TDD/debugging/verification/cangjie-coding；整数映射/属性完整性/字节兼容/写后提交 |
| 062 verification | fixed完整技术diff/design/tests / 006 | spec+quality verdict/findings及复核 / AC062 | 实际可用Codex gpt-5.6-terra/high；review/verification；不重复已证同源suite，新反例才probe；最多3轮复核/60min |
| 063 testing | reviewed fixed source/tests/environment / 062 | command/result/raw/hash/实际cjp消费 / AC063 | 实际可用Codex gpt-5.6-terra/medium；verification/debugging；build后直接binary、无私有flags、真实TTY恢复；正常bundle不skip |
| 064 acceptance | 原始执行及独立review/固定代码 / 063 | 逐AC映射及最终metadata核对 / AC064 | Sol/high；verification；按内容hash复用有效证据，no完整框架claim |

061L4：公共API预期→RED→freeze；062L4：读契约/diff→独立反例→固定修复复核；063L4：fresh clone→全入口/新PTY→正常bundle+clean消费→原始交接；064L4：核真实合同/raw/source→有限结论→核最终集成。基础package/API调查已独立完成，主仓源和共享缓存未动；必要工具已可用，不重装。

Preflight接口对：061→006（命名/模式/golden完全由design，未读实现）、006 style→共享Frame/继承（所有字段完整、不另建数据权威）、006投影→Application（旧新模式/写后基线成对）、006→062（完整fixeddiff）、062→063（reviewedcommit）、063→064（不可变raw/hash），相互一致。各task自检：061只测试、006只产品与使用文档、062只审核、063不改产品/冻结test、064只验收；无共享编辑，fixtures不引入产品hook。D028–030处理剩余工程默认，若SDK实际失败先报主代理并保留证据，不虚标ready。

## User steering: automatic device adaptation and cross-terminal evidence

用户新增明确约束：正常应用声明丰富Color/Style，由渲染自动识别终端并降级；不能要求程序员选择能力。测试须实际跨不同终端实现，报告附真实运行效果图并标来源。D029显式默认Basic16被此用户裁决覆盖；原187e126实现/审核/测试保留为可选手动override子路径证据，不外推自动默认已完成。006/061/062重新打开等待新契约与增量，063当前old冷入口可自然完成但不再启动旧包阶段，064保持pending。

- [x] 4.1 TASK-065：自动能力来源及实际跨终端宿主/截图的独立验证；AC065：用实际探针冻结能力来源/未知降级、可运行宿主矩阵与真实PNG证据要求，不把环境变量仿真当跨终端。

065为L3 investigation，父WP001及本change；inputs为用户新裁决、旧shared颜色/输出路径；depends_on无实现前置。独立auto-capability-recon和cross-terminal-recon分别处理API/能力来源与测试宿主，目录隔离，Codex5.6/high，主代理汇总契约。deliverable为隔离探针/raw/建议与可运行环境，不改主产品/冻结断言。技能brainstorming/writing-plans/cangjie-coding/verification，环境技能若读取缺失如实记录fallback；L4：调查API/宿主→实际probe/截图→主冻结设计/独立测试增量→产品实现→062delta review→063真实matrix/pack→064验收。风险：terminfo全局状态/环境提示可信度/不支持查询/真实console缺失；不得捏造能力或补产品GUI依赖，不发送上游消息。新需求优先于原默认工程选择，日后无需再次问是否继续。

### Automatic revision execution handoff

当前精确contract以design D031–33为准；旧explicit段落保留历史不作默认。061重冻Auto公共消费者/合成terminfo/native隔离失败/Basic8/离线快照预期，保留旧具体mode映射及060；006 fresh实现同一颜色pipeline上的Auto/profile/optional C模块，不替换input/session核心；062复核完整增量和新test；063最终固定源执行全部相关回归、真实宿主、PNG、正常bundle/clean消费；064核合同+范围+原始图/日志/状态。

- [ ] 4.2 TASK-066：独立编写真跨终端测试与原始截图采集程序；AC066：相同无override应用在真实xterm/XFCE-VTE运行，逐宿主原PNG/metadata/raw/能力来源/尺寸/恢复齐全。

066为L3 testing，父WP005；inputs为D031–33/065实际host探针，depends_on065；只改tests/terminals及其README/fixture/采集脚本，不改产品或其它冻结tests，不改tests/run-slice.sh避免与061共享编辑。独立Codex5.6/high，TDD/verification/cloud-runtime；L4：核host控制→写独立fixture与真实矩阵脚本→对旧显式默认真实RED→freeze→交063最终执行。正常slice回归入口包含061；真实host入口单列tests/terminals/run.sh，由063明确执行，缺宿主必须非零/insufficient_evidence，不能静默跳过标passed。GUI/recorders仅测试deps，采集源图不重绘；不得只换TERM数三独立终端。

006本轮新增文件建议：src/terminal_capabilities.cj（唯一公开诊断struct）、src/capability_detection.cj（纯解码/FFI入口）、native/cjtui_capabilities.c（私有namespace适配），已有build hook接入该对象；其余按D031共享Style/Frame/ColorMode/Application，具体文件最小充分且每实体一文件。native/构建变更须实际publicconsumer+标准bundle，不能私有link flags，Cg runtime的dlmopen独立probe等待报告补齐时有失败先反馈。独立实现作者不能写正式tests或看测试作者推理，只收冻结产品需求/API/用例。
