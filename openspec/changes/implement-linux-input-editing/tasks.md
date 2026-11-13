# Linux keyboard and text editing implementation plan

当前控制器准入（2026-11-13）：PF001–004已独立限定闭合，F006/F007已独立复核，交互112与会话152等实际前置已接受。TASK113正式测试冻结c96cc601完成，114在独立产品工作区实施中；下列旧candidate/planned描述保留起草背景，不能代替逐任务的固定证据及勾选，也不代表115–122提前ready。

> **For agentic workers:** 本件仍为独立候选planned；主代理冻结并通过独立preflight后，按用户已选独立测试/产品/审查/执行/验收流程执行。REQUIRED SUB-SKILL: superpowers:subagent-driven-development；本起草角色不执行、不派代理。

**Goal:** 两个分别可验交付：完整有界键盘/paste；基于公共Canvas的单多行编辑。
**Architecture:** 一KeyboardDecoder→现KeyEvent/UIKeyEvent/Runtime；编辑组合Canvas/focus/defaultAction/viewport/统一主题与Unicode，copy消费148–152原TASK030会话扩展。
**Tech Stack:** SDK1.2.0、既有ansies/unicode/unicodewidth及已冻结runtime/theme/RichText；不新增产品Node/Python/GUI运行依赖，产品0.0.0。
**Spec:** design.md K001–K004/E001–E005、specs/ui-runtime/spec.md、148–152会话扩展前置与主代理冻结交互合同。

## Global Constraints

* 全部113–122是L3候选，状态planned；具体变更正式路径经主代理登记后才转状态权威，当前不改主仓docs/tasks/acceptance。
* 每类型一个小写下划线文件；公开旧KeyEvent/code/text/legacy行为和runtime生命周期保持。新签名未编译，不允许产品作者凭空修公共约。
* 保留唯一Component/Runtime/LayoutNode/Frame/Style/Unicode/ansies；控制器不持有可变全屏Frame，不加编辑kind，不实现标准Button/Checkbox/Menu。
* 113–117键盘；118–122编辑；TASK030会话扩展148–152已另案规划，152验收固定后119消费，不夹进本产品周期。
* 正式测试、产品、审核、执行、验收上下文/目录独立；只交合同/固定源/hash/raw，不传作者自评。普通可复用验证不重复冷跑；受影响/新失败才补跑。
* 模型指定：测试Sol/high，产品Terra/high或获准Sol/high，审核/验收Astra/high，确定命令执行Sol/medium；工具不能核serving时只记指定配置。
* 不主动读剪贴板、不发OSC52 '?'、不执行系统剪贴板命令，不假Applied；SentUnconfirmed cut保留全部文字/selection/history。

## Review Focus

1. 03/ESC/LF在paste/drain中不执行，超限/未闭合/EOF/目标卸载不放行后半段；113逐字节和超限golden负责。
2. decoder与设备桥接必须按流先dispatch旧key再锁新paste目标，POLLIN+HUP先读尾；113的PTY顺序/EOF样本负责。
3. UTF8/Rune/簇边界、跨事件组合/ZWJ接缝、反向选区不能混；118的独立簇/字节golden负责。
4. cut结果晚到、同值外部notify、选区移走再移回不能误删；118用公共操作与真实Sent结果/纯策略表区分负责。
5. Canvas目标、自身caret、实际clip/选区style、单一offset与默认动作一次性；118跨主题/窄屏/嵌套viewport样本负责。

## 1. Unit A — complete keyboard normalization and paste

- [x] 1.1 TASK-113：冻结公共KeyboardDecoder/KeyEvent与真实PTY输入测试，先取得正常构建基线和真实缺API RED；交test-only提交/raw/hash。
- [ ] 1.2 TASK-114：实现唯一decoder、设备读取/目标锁/公平pump/EOF和模式恢复桥接，公共消费者与固定113及受影响回归通过，交product-only提交和产品文档。
- [ ] 1.3 TASK-115：独立审固定合同/tests/product diff，交spec/quality双verdict，必需缺陷无未关闭项。
- [ ] 1.4 TASK-116：独立普通build、直接binary、PTY/宿主、normal bundle和干净消费者执行；交真实exit/raw/版本/PNG/hash。
- [ ] 1.5 TASK-117：逐K001–K004/原AC分段核对固定原件，给有限验收与缺环境清单，不关闭父完整AC。

## 2. Unit B — single-line and multiline text editing

- [ ] 2.1 TASK-118：冻结公共TextInput/TextArea/controller、Unicode事务/快捷键/主题视口/保守cut测试；所有前置实际API存在后取真正缺编辑API RED，交test-only版本。
- [ ] 2.2 TASK-119：通过公共Canvas/focus/viewport实现全部E001–E005和公开例子，消费已独立验收148–152会话扩展，固定118及受影响回归通过，交product-only提交。
- [ ] 2.3 TASK-120：独立审编辑固定diff与公共复用/结果真实性，交spec/quality双verdict，必需缺陷闭合。
- [ ] 2.4 TASK-121：独立执行公共CJPM消费者/Unicode/PTY/真实宿主/正常制品及干净消费，交真实exit/raw/PNG/hash，区分纯策略和宿主能力证据。
- [ ] 2.5 TASK-122：逐E001–E005与AC028核原件、公开文档和接口，交编辑有限验收；030全部宿主能力、020完整恢复、019菜单与027展示另汇合。

## L3 cards — shared fields and admission

以下字段与下表逐行合并构成每个L3的完整卡：level=L3，L1=G001；113/115/116/117/118/120/121/122父WP005，114/119父WP004。classification=execution候选（既定Linux目标内实现），本设计尚待主代理冻结+preflight，未ready；public签名、事务、资源预算的工程决策引用本design及主代理freeze记录。workflow_ref/openspec_change_ref指本候选目录，正式登记前不冒充主仓状态。evidence_refs当前仅本草稿/provenance，未来raw放主代理分配reviews目录，不先造通过日志。

requirement_refs：A=REQ009.1/.5、REQ010.1/.4输入侧、REQ011.2/003004边界；B=REQ001.8、REQ009.1–.5、REQ010.1/.4与REQ003.11。AC113–122仅支持步骤的交付证据别名，不取代原AC：114映射003/004归一化输入合同、017选目标桥接、030paste接收、020清理、041设备输入；119映射028编辑完整范围、030copy结果消费、020恢复集成，viewport原AC037仍交其单元。019/029不在范围。

required_skills：规划brainstorming/writing-plans/OpenSpec；测试与产品TDD、cangjie-coding按search_docs、verification-before-completion，故障触发systematic-debugging；审核requesting/receiving-code-review所需入口，执行/验收verification。来源/安装可复用R11技能记录，实际使用另在各角色progress登记；当前本起草角色只读取设计/计划/核对技能，不声称实现阶段TDD已经执行。独立preflight需逐DQ01–14填结果，未通过不派产品。

| ID / type | Objective / deliverables | Inputs / depends_on / blockers | Acceptance / verification |
|---|---|---|---|
| 113 / testing | 公开decoder字节golden及真实设备输入断言、缺API RED固定 | 主代理冻结K接口、原runtime固定源；可先写测试，正式RED不能靠语法错误/坏import | `tests/keyboard/run.sh`旧产品实际编译缺KeyboardDecoder/字段；期待序列/offset与自写golden，非产品生成 |
| 114 / implementation | 完整K产品及兼容文档，不含编辑/剪贴板写 | 113固定；Runtime C已固定；交互102/107/112含focus/activeTarget/modal域实际验收固定；会话152有限验收固定writer/unsafe门；同Application/native无其他并行产品写 | `bash tests/run-slice.sh keyboard`含公共构建/全部113；PTY恢复和输入公平性按L4；114自测不是独立验收 |
| 115 / verification | spec/quality独立审查+可复现findings | 114固定diff、113固定tests、主代理最终设计；不读作者自评 | 双verdict与具体行/反例；Critical/Important归属修复后定点复核，无改约降标准 |
| 116 / testing | 新环境普通构建、输入/模式/EOF、制品证据 | 115可执行固定源；自有SDK/cache；真实宿主/PTY可用性实际记录 | run.sh/direct binary真实exit；normal bundle无skip，干净源消费不依赖作者target或cjo；记录能力不足 |
| 117 / acceptance | 有限K验收、剩余父AC映射 | 116 raw/hash、固定合同/源、115结论；内容不变复用有效suite | 逐K项证据/元数据核对；011等非本范围不猜通过，真实console缺失列不足 |
| 118 / testing | 编辑公共测试、独立Unicode/选区/历史/Frame golden | 冻结E与SessionResult/copyLocalText公共API、交互A+B合同；实际RED等117+Theme/RichText/交互A+B(含I011)/030会话152均固定 | `tests/editing/run.sh`公共消费者真实缺TextInput/controller RED，不能用未实现会话/clipboard桩掩盖错误 |
| 119 / implementation | 完整TextInput/TextArea/controller及公开examples/editing | 118固定；117；Theme088/加载092按本次消费边界固定；RichText084；Runtime080；交互Canvas/focus/viewport独立验收固定；030会话152独立验收固定，当前皆按实际状态block | `bash tests/run-slice.sh editing`，用户只public import构造；标准快捷键/selection/copy结果完整，不加kind/private渲染 |
| 120 / verification | E全规格/质量/复用性固定diff审核 | 119固定源+118固定tests+前置固定hash，无作者结论 | typed/API/主题来源/单一offset/同步返回与延后消费cut/异常恢复均有检查，无必需未关项 |
| 121 / testing | 编辑/宿主/制品真实执行 | 120可执行固定源、自有SDK/cache、真实终端/连接/权限 | run.sh/direct binary/normal bundle/clean消费；文档例子实际跑；Sent真实路径与Applied不可用明确分开 |
| 122 / acceptance | 原AC028及E全部可交付范围核对 | 121原件/hash与120；Applied真实适配若无只验保守策略和不可用声明 | 逐REQ009/AC028：单多行/簇/选择/撤销/Enter/坏paste/剪贴板结果均可复核；不把未来真实Applied/完整030标题图标写成通过 |

## File ownership / L4 — unit A

113创建`tests/keyboard/cjpm.toml`、`src/main.cj`及单实体helper、`run.sh`、`pty.mjs`、README；主代理顺序接线`tests/run-slice.sh keyboard`，不抢其他测试作者接线。测试公共KeyboardDecoder而非复制源文件/反射私有解析器；PTY负责实际Application.run/timeout/目标顺序/native收尾。正常CJPM path依赖主库，产品编译可先成功，consumer真正缺API为RED，保留命令/exit/stdout/stderr/hash。

113.S1 固定逐条标准序列和精确code/text/ctrl/alt/shift/offset；每序列所有split、UTF8标量中80–9F续字节、ESC[[A、unknown/malformed/C1/control strings/drain、CSI Z仍backtab+shift与旧无modifier backtab焦点兼容等，golden来自冻结矩阵。113.S2 固定paste所有分隔split/UTF8split、恰1MiB/+1byte、无终止多poll、03/ESC/LF、finish/重复finish、limits、decoderclosed；预期事件数和内容独立手写。113.S3 PTY用真实同步管道/协议标记控制A/B焦点、begin时刻、unmount/newmodal、POLLIN+HUP尾数据、EOF/signal/stop、4096预算下post进度，未具备modal时该集成标缺前置，不用模拟业务桩声称通过。113.S4 提交test-only固定源，记录缺API RED，不改产品。

114文件：迁移`src/input_decoder.cj`至唯一`src/keyboard_decoder.cj`；新增`keyboard_limits.cj,keyboard_issue.cj,keyboard_diagnostic.cj,keyboard_batch.cj,keyboard_exception.cj`各实体；改现`key_event.cj,application.cj,terminal_bridge.cj,exports.cj`及`native/cjtui_terminal.c`必要读取/收尾。纯UTF8/序列辅助按内聚函数归decoder职责，绝不复制unicode表。新reader若块ABI需在此冻结并由C消费者验证，不由后续编辑临时改。

114.S1 实现K001/K002及公共消费者；保留旧code/构造/legacy断言，删除旧并行decoder活动引用。114.S2 实现K003状态/原子缓存/drain和流内begin锁目标；信号在paste隔离外，正常03在内。114.S3 实现K004读取预算、EOF/HUP、模式初始化/异常恢复，主循环只需一输入buffer/同Runtime pump。114.S4 固定113与受影响native/session/runtime/能力回归，`examples/keyboard`正常公共CJPM项目和`docs/product/keyboard.md`公开支持/限制/EOF/paste边界，产品only提交。

115审核关注5项Review Focus中1/2；116在独立环境运行冻结命令：`bash tests/keyboard/run.sh`、`bash tests/run-slice.sh keyboard`、`bash tests/run-slice.sh native-session`、受影响原`integration/application-lifecycle/runtime`按内容选最小充分；正常主库build→直接binary真exit→正常bundle→干净解包同公共测试仅改manifest path。实际选定脚本输出是退出判据，不因stdout出现PASS忽略退出1。117复用相同固定内容有效结果，检查命令/环境/受检源而非机械重跑。

## File ownership / L4 — unit B

118创建`tests/editing/cjpm.toml`、`src/main.cj`及单实体helper、`run.sh`、`pty.mjs`、README；顺序追加`tests/run-slice.sh editing`。公共测试通过TextInput/TextArea/controller和headless snapshot/dispatch，不访问内部editor状态；expected Frame/字符串/selection/revision与事件trace独立确定。会话实际API还不存在时只准备源，不能把缺SessionResult/copyLocalText而非缺编辑的编译错标成编辑RED。

118.S1 固定`e+combining`跨事件、中文、ZWJ/肤色/旗帜、反向选区、连接处重分、行首末/宽列上下/preferred、CtrlHome/End/Shift、CRLF正规化、单行LF/HT/ESC坏paste原子；预期onChange/onSubmit次数和撤销序列手工表。118.S2 固定128条/2MiB历史预算、文本限额、外部同值notify/共享value独立selection/实际后台set与条件提交竞争、controller旧代际/重复bind/重入/错误线程；所有边界不靠同产品分段函数生成期望。后台写竞争必须使用真实线程/可控握手，在源快照与条件提交之间实际产生版本变化并断言无覆盖/ConcurrentValueChanged；无真实交错的纯值表不能替代这项证据，不用固定sleep冒充同步。118.S3 固定030 SessionResult接口的Unsupported/SentUnconfirmed保留（Unknown Direct显式请求按030可能完整发送SentUnconfirmed）、copy独立调用、同步copy耗时期间后台源变化、应用post延后消费后文字/selection变化及move-away-back取消；Applied仅纯策略表或真实adapter存在时实测，不写返回Applied的假支持backend。118.S4 Theme四种角色/selected/explicit覆盖、Canvas自身focus/caret/clip/resize0宽、A中B宽2、嵌套viewport PageDown不双滚、onKey prevent/stop/default顺序与modal目标锁前置集成，交测试only固定源。

119文件：`src/text_selection.cj,text_edit_limits.cj,text_edit_issue.cj,text_edit_snapshot.cj,text_edit_controller.cj`各公开实体；`text_edit_session.cj`挂载局部owner、`text_edit_history.cj`完整记录、`text_edit_record.cj`若为独立类型单文件、`text_editing.cj`内聚纯操作、`text_input.cj/text_area.cj`工厂函数。职责明确后可减少无实际用途实体，不能把多类塞同文件；所有公开类型/工厂在`src/exports.cj`重导出（同根类型无需重复自import）；仅在`src/observable.cj`的既有锁/版本拥有者内增加内部快照/条件提交，公开方法/后台许可不变。不另造RenderFrame/Unicode宽度/viewport state。

119.S1 依E001实际消费者编译factory/可选controller、挂载代际、shared value来源token与原Observable唯一版本条件提交；初次mount/卸载后reset、typed属性不破现Theme。119.S2 E002/E003实现局部事务、whole-text分簇、history/标准键/唯一Target默认。119.S3 E004以公共Canvas/selected patch/自身caret/viewport接口绘制和ensureVisible；measure/draw纯查询，行表缓存只纯数据，不提交私有render分支。119.S4 消费030固定copy API完成E005，同步SessionResult或应用post延后消费边界复核session/owner/源revision/selection版本，只Applied删；不实现OSC或后台clipboard桩。119.S5 固定118与受影响runtime/theme/RichText/interaction/native回归，交`examples/editing`正常项目及`docs/product/text-editing.md`（包括支持矩阵/未知剪贴板/单行坏paste/后台source竞争拒绝策略），产品only提交。

120审核5项Review Focus中3/4/5及K→E跨界；121运行`bash tests/editing/run.sh`、`bash tests/run-slice.sh editing`、受影响公开interaction/theme/richtext/keyboard命令和normal bundle，不猜尚未冻结脚本名。固定源码重复验证可复用，若每类源码/环境一致不重建全部冷依赖。122按逐需求矩阵核对有限通过、实际宿主不足与父AC汇合，不以用例数替代语义证据。

## Real PTY / host acceptance

PTY证明原始byte到框架事件/默认/恢复的行为，不能代替实际终端实施按键生产或本地剪贴板效果。跨真实宿主至少覆盖冻结Linux console与真实ANSI模拟终端，其他宿主/复用器按已承诺矩阵；记录OS/ABI/SDK/宿主版本/连接/权限/TERM和实际尺寸/能力来源/源码SHA/UTC/命令/真exit/raw/原始PNG+hash。改变同PTY的TERM只算分支测试，不能算不同宿主；渲染生成图不当运行截图。

真实宿主验证标准按键/Shift导航/host paste/CtrlC、有无2004标记、中文组合emoji字形限制、resize/恢复；copy在SSH/tmux等路径必须分别显示SentUnconfirmed/Unknown证据和本地手工观察是否到达，不能以发OSC字节当本地Applied。缺物理console或某真实宿主时记insufficient_evidence，继续独立工作，但不关闭Linux041/024全范围。

## Quality / old path / DQ

必要性：原decoder无法标准编辑且paste误执行，Text/Row/Column不足展示selection/caret；canonical owner为KeyboardDecoder输入、Runtime路由、挂载TextEditSession局部编辑、既有Unicode分簇、Canvas绘制、NodeRef viewport偏移、单会话clipboard输出。旧InputDecoder/直觉CtrlC分支迁移到该唯一通路；String严格控制验证/RichText/Theme不另建平行版本。

兼容例外只有有明确现调用的KeyEvent旧字段/构造/legacy interrupt，未新增任意反射/私有开放；新增modifier不会承诺终端未提供的物理信息。TextEditController/历史/已有post意图各有真实公开用例和固定预算，不引文档模型、插件系统或未用扩展。offset不能在业务Observable与NodeRef复制；同值外部notify必须有来源/版本处理。

preflight需逐DQ01–14核：任务号/L2/原AC不改名；两结果可分别判；接口/误提交/异常/预算/来源合法；113/118预期独立与真正RED；148–152会话前置另验不成环；共享文件顺序写屏障；真实host与纯策略不同证据；旧路径退役和消费者兼容；skills来源/模型声明/命令/raw/hash；正文所有候选签名/预算由主代理确认。当前无这些通过结论，不能标ready。

## Workflow follow-up

* 主代理将实际接纳工件归入OpenSpec，登记113–122并引用会话扩展148–152；此目录不成为产品依赖或第二状态权威。
* 后续原017/018/019/020/027/028/030/037/041/024按原AC汇合；本件不归档全Linux或发布产品。

主代理F001最终采用上列工程候选并确定152→114，不提前关闭完整父030；行为外观态消费交互I012，无私有控件补洞。原028全量状态在本变更按122独立验收后投影，docs/tasks仅编号映射。

### Preflight补冻覆盖

F002–F005为113/118正式golden输入：raw/UTF8 C1全split及03非paste取消、diagnostic→焦点提交→pastebegin顺序、EOF callback收尾、编辑通知内snapshot与同editor重入、无效dispatch参数保留session、copy/cut互斥issue表与CtrlV提示、初态/remount0及同文本选区折叠/redo保留/selectionRevision边界。114/119按同一通道实现，115/120固定源码审这些不变量，116/121独立执行可达路径；不可达计数上限以诚实源码证明，不造运行次数。
