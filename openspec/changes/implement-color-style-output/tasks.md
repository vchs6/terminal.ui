# Color style output implementation plan

Goal：在同一组件/Frame/ANSI路径完成TASK006，为主题提供可复用颜色/属性基础。
Spec：design.md精确API/投影/行为。Baseline96bdb9b。Stack：仓颉SDK1.2.0、原ansies/unicode/unicodewidth，产品0.0.0。

## Global constraints

主代理仅契约/文档/集成；独立测试设计→产品实现→审核→执行→验收，各自fresh上下文和目录，只交冻结产物，不交作者推理/预设通过结论。用户连续实施和direct-main授权有效。遵守AGENTS14包/实体文件与用户两份参考；不改变第三方代码/许可，不引入新运行依赖。
只改style/encoding/Frame输出diff/组件属性继承/App模式/示例和对应文档。不得另建ANSI/Unicode/Frame或持久投影内核；input/native/布局算法/D027恢复保持。既有8色/bold字节与全部R8/R9/060断言保留，不为新模式弱化oldtests。完整项目及其他平台未因此完成。

## 1. Independent test contract

- [x] 1.1 TASK-061：冻结独立public颜色/属性消费者、真实PTY例子/模式静默fixture及runner；AC061：缺新API真实RED、手算golden/明确模式/握手、旧断言不变。

## 2. Implementation

### Task 2: TASK-006 color and style output

- [x] 2.1 TASK-006：实现design全部Color/Style/ColorMode、组件布尔属性、能力映射及有效输出差分、Application模式与colors示例；AC006：默认/16/256/RGB按模式映射，组件不发ANSI，同一原始Style可多模式输出且不可见变化静默。

Files：src/style/color.cj/style.cj/new color_mode.cj、src/color_mapping.cj（纯内部策略建议）、src/exports.cj/ansi_encoding.cj/frame.cj/component.cj/layout.cj/application.cj、examples/colors与docs/product。每实体单文件；旧ansiColor与encodeStyle原路径直接扩展/替换，旧转换路径不得并存。依赖converter不被调用，真实依赖编码保留。L4：冻结061RED→模型/名义策略/共享继承→编码/有效diff与App已显示模式→公开例子和针对自测→提交审核。不写/改tests。

## 3. Quality gates

- [x] 3.1 TASK-062：独立整片spec/quality代码审核、真实反例及必要作者修复复核；AC062：固定完整diff+contract passed，无必需未决失败。
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
