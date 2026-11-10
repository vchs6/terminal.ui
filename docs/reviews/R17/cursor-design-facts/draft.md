# I015 候选：查询原显隐后管理 mode 25

状态：独立架构候选，2026-11-10。只输出本目录文档；未修改主仓、产品或正式 tests，未重跑探针/套件，不构成 A/020/008 产品验收。root 已确定的工程选择在下文明确标记；细节仍待 root 合入正式 OpenSpec 与独立 preflight。本作者不执行独立审查自己的候选。

## 约束、事实和假设

root 已确定：只有准确取得原显隐才发送 `CSI ?25h/l` 并在可安全输出时恢复原值；Unknown 自动保留显隐、仍可 CUP；逻辑 caret 与设备能力分开；应用无需选终端，不假定退出应 visible，不增加软件 cursor、第二 decoder/renderer/queue。

实测来源 `/workspace/work/cursor-capability-recon/report.md`：XTerm398/VTE0.80.1 原态分别回 `1b5b3f32353b312479` / `1b5b3f32353b322479`；真实 Linux VT 六次有界600ms查询没有回复，且25s/r不恢复原显隐。已直接读取两GUI各visible/hidden的baseline原bytes及VT两个空baseline文件。这个探针证明候选机制的宿主事实，不证明产品解码/恢复/异常路径通过。

源码事实：当前 InputDecoder 是唯一内部状态机，`feed(Int32):?KeyEvent`，CSI/SS3共享state2且只以parameter标志屏蔽未知序列；`timeout()`目前只处理裸ESC。Application.run每次readByte(100)，每byte交该decoder；cjt_read目前将EOF/HUP合并为-3。native open的TCSAFLUSH会丢弃原有未读输入；查询不得把这个既有scope误称为本轮新保证。现writer失败只返回-1，Application停止并清理，native close不发终端控制；尚无准确partial计数或跨run outputUnsafe闩。

原显隐“准确”是终端协议报告意义：同一会话独占终端输入/输出，收到匹配的合法报告；DECRQM没有nonce或认证，无法区别用户/其他进程注入的同字节串。禁止以TERM、terminfo、查询write成功、25s/r成功写出代替报告。外部进程并发改mode25不在可保证恢复模型内。

## 实际可行选项与推荐

| 选项 | 与现代码的实际接点 | 取舍 |
|---|---|---|
| 启动阻塞至600ms，缓存普通输入再派发 | 同decoder可解析，但需有限原始输入或有序通知缓存 | 明确初帧能力；缓存满必须提前结束探测并无损交回，不得丢弃，且缓存/回放/诊断时序增加复杂度。阻塞期间不能用普通callback消耗输入，否则实际上已是事件循环。 |
| **一次异步600ms窗口，正常UI立即运行** | 唯一decoder精确识别9byte回复；Application持有一次探测ledger | **推荐，root已认可**。无启动输入缓存和重放；Unknown阶段屏幕/逻辑caret正常，模式不改。收到及时1/2后补一次设备caret更新。 |
| 永远保留原显隐，不发查询 | 无输入协议改动 | 安全且最小，但GUI已有可验证能力也不能兑现管理显隐，不作为已选择路线的替代。 |

排除按TERM选25s/r、Unknown强行show/hide后默认show、额外decoder或读取线程。无需通用“终端协议管理器”、请求队列、订阅机制或重试策略。

## I015 精确候选条文

### 1. 生命周期与有界窗口

1. run取得唯一native设备、创建唯一decoder并装配包内mode25接收入口。startHeadless依I014完成挂载/稳定/首焦点；若此时已stop或失败，不发query，不改25。
2. 在首个设备目标输出之前，经唯一writer发送一次 **7 bytes** `ESC [ ? 2 5 $ p`。该次是独立完整输出事务，不拼入用户文本，不占mode25 saved slot；无后台线程。只有完整写成功才进入Pending。原frame baseline不因query提交。
3. 完整写后读取单调时间 `t0`，deadline=`t0+600ms`（检查加法）。在发送前也须确认单调时钟可用，若失败则不查询并保持UnknownClock；发送后读取失败同样UnknownClock。无墙钟/帧数推算。600是保守工程上限，沿用调查窗口；不是所有宿主的响应保证。
4. 立即进入既有UI/输入循环。Pending与Unknown均不得发25h/l；有效逻辑caret仍最终CUP定位。回复从原cjt_read→原decoder路径输入，普通键立即按现行安全边界派发，无查询缓存、无重放、无第二队列。
5. 每次可能读取之前、返回输入之后及安全UI边界检查时钟。`now >= deadline`首先将Pending终结为UnknownTimeout；只有完整reply最后字节在本机被处理时 `now < deadline`才可授权，等于截止也不接受。无法知道OS队列实际到达时刻，不据推测追溯授权。
6. 持续输入不延长deadline。poll超时取既有输入空闲/事件循环要求与剩余探测时间的最小值；探测deadline唤醒本身**不调用decoder.timeout**。100ms键盘idle以距上次实际输入计算，不能把20ms的probe唤醒误当100ms idle。无须等待600ms结束才显示第一帧。
7. 600ms只约束授权窗口；不承诺阻塞write、用户callback或OS调度在600ms内返回。即使UI被callback占用，恢复后先检查deadline，已迟到reply不能升级。单调时钟运行中失败终结Pending为UnknownClock，继续保守运行。
8. 时钟可复用SDK真实可用的monotonic源；若没有已验证API，最小内部FFI `cjt_monotonic_ms(): Int64`，CLOCK_MONOTONIC、非负毫秒、错误/溢出-1。不新增public计时或probe API；采用哪一实现须在preflight核实，不把本草案当已微编译。

### 2. 精确状态与限额

每run一个ledger：`NotProbed | Pending(deadline) | Known(originalVisible) | Unknown(reason) | Closed`；originalVisible只接受1/2后写一次。包内字段保留是否query已完整发送、最近完整成功的设备caret输出、是否曾完整成功改变显隐；数据量O(1)，不保留输入payload/报告历史。deadline只允许一次，不自动重试。

| 输入/事件 | 状态结果 | 输出权限 |
|---|---|---|
| 完整query写成功+可用时钟 | Pending | 仅原屏幕/CUP，不改25 |
| Pending内首个精确report `...;1$y` / `...;2$y`，完成时未到deadline | Known(true/false) | 下一安全设备边界管理显隐 |
| 精确status0/3/4 | 消费，保持Pending至正常deadline；可记一个bounded“已见不可用报告”位 | 不升级、不猜永久set/reset可改 |
| 错mode、额外参数、leading zero、非法status、SS3、非精确7bit introducer | 按原/后续Keyboard合同的未知/畸形分支 | 不升级；不误作成功report |
| Pending到期 | UnknownTimeout（可在内部原因附unusable-report） | 不改25 |
| Known后重复/矛盾精确report | 消费，保留首次original | 不覆盖恢复原态 |
| Unknown后迟到完整精确report | 消费，Unknown不再升级 | 不改25 |
| stop/signal/EOF/异常 | Closed；保留已有original供必要cleanup | 未知时没有25恢复输出 |

唯一decoder在既有CSI转移上增加固定精确路径 `ESC[?25;P$y`，P仅ASCII 0..4，总长9bytes。无需9bytes实际缓存，prefix index+单digit即可；候选匹配状态最多0..9，失配退回同CSI的既有框定/丢弃规则，**不再feed已消费byte、不向别处回放**。识别仅7bit ESC [，不能因现state2也代表SS3便接受ESC O；也不默许raw/UTF8 C1版本取得管理权。超长伪造参数走原/升级后的CSI有界drain，不积累数字，不留任意长“可能回复”buffer。

A现有状态机不另扩展完整Keyboard语义；只增加I007和本单一reply分支。mode25接收者是包内固定接点，不公开构造参数/事件类型：A可在final byte调用无用户回调的包内接收方法，只更新ledger并标设备caret需重算。它不输出、不更改逻辑焦点、不执行业务callback。因此无需通用通知容器/队列。将来Keyboard内部有序通知可承接同一固定分支，退役原InputDecoder时不得并存第二parser。

设备run安装此接点直到停止读输入，因此Pending结束后仍能吞掉完整回复。未来公开独立KeyboardDecoder没有会话接点/不发query，相同字节依其未知CSI规则给UnsupportedSequence；public KeyboardBatch不新增protocol事件。raw/UTF8 C1等其他形态维持F002既有规则。

### 3. 诊断顺序、真正timeout与分块

root明确采纳：600ms probe截止只关闭管理授权，不reset/feed/finish/timeout decoder。跨deadline仍是同一CSI，最后字节到期后完成则吞reply、无KeyEvent、无KeyboardDiagnostic、不能升级。1/2与0/3/4的精确报告在设备会话均视为protocol，不暴露业务输入；重复同理。

**“完整reply”限定同一未被键盘timeout/cancel打断的CSI。** 全Keyboard K002的100ms实际idle仍可对未完成CSI产生IncompleteInput并回normal；随后字节依normal解析，不声称任意间隔后拼起来像reply就能永久吞掉。裸ESC尤其无法与单Esc按键无歧义区分。禁止为此加入长期quarantine或改写K002计时。A当前CSI没有该timeout，升级后按K002新合同；A→Keyboard的测试应区分这一明确阶段差异，不能把A旧timeout实现当完整Keyboard最终语义。

F003的顺序保留：每个已形成key/issue先完成自身普通UI callback和稳定提交，再消费后续byte；probe内部final处理也在其真实流位置同步发生。精确protocol报告没有业务diagnostic callback，不产生新事件队列。坏/非精确CSI在完整Keyboard仍按K002/F002/F003诊断，这些callback可能改焦点，后续paste-start必须看到已提交结果。reply字样在paste/string payload中不能抢占原状态，paste保持原子与目标锁；仅在normal引导的CSI分支识别。

A不为了query引入KeyboardIssue公共接口。现有TCSAFLUSH开头丢输入是原native语义，**本候选“无丢失”只指查询不新增flush、缓存满丢弃、吞普通已读取按键或重新解码**。完整输入后续若承诺保留open前typeahead，应单独核改TCSAFLUSH，不能在本候选顺手扩大scope。

输入资源：query额外输入buffer=0、额外事件queue=0、matcher/ledger=O(1)。A原单byte读天然每轮≤1byte；Keyboard K004升级后每UI turn≤4096bytes，原post cutoff/安全提交和OS背压不变。未来Keyboard状态仍O(maxPasteBytes+maxSequenceBytes+常数)，该分支纳入普通sequence预算，不绕过用户很小maxSequenceBytes。默认64容纳9bytes；设置<9时可能SequenceTooLong→Unknown，不另设超预算协议例外。

### 4. 逻辑与物理输出

A.6的CaretSnapshot仍是“最近完成目标帧的逻辑请求”：owner、坐标、visible按焦点Canvas/clip/宽簇/遮挡判定，headless等价。I014初焦点不等probe。设备Pending/Unknown不把逻辑visible改false，也不靠它伪造物理能力。

在每个安全设备边界，用该时刻最新已完成目标caret生成输出；Known刚取得时强制考虑设备caret，即使网格不变。不保留旧reply时的逻辑坐标作为待执行命令。成功基线=完整成功写出的网格/profile+设备caret计划，只有全部字节成功才提交；失败不能提交部分caret。

Known模式：逻辑隐藏则25l；逻辑可见则最后CUP到合法单元并25h。可按既有渲染计划在重绘前临时hide，前提Known且整个计划归同一writer；成功后ledger记录最终模式。Unknown模式：**所有路径，包括首帧、重绘、caret-only、模式初始化和cleanup，均不得含25h/l、25s/r**。逻辑可见时在画面输出后CUP到最新坐标；逻辑隐藏无额外caret CUP，终端光标可能仍停在画面writer最后位置。未知原visible时无请求仍可能显示，原hidden时有请求也不会显现；这是公开自动降级限制，不是逻辑caret失败。

位置变化与能力变化可触发caret-only输出，不新增renderer。全局Frame导出不包含设备模式query和caret。root承诺的是显隐原态恢复，不声称恢复退出前原光标坐标/shape/blink；这些不能由本次mode25调查推导。

### 5. writer与退出：root已裁决依赖重排

当前源码的真实围栏只有write异常→停止run/报告→静默native close；没有partial/zero区分或跨run闩。A新增恢复字节后不能继续援引“沿原围栏”却在任何write错误后盲发25h/l。给A再写一套计数/闩会侵占149唯一权威；本候选不这样处理。

**root已采纳工程顺序：固定RichText084后，先有限Session148→149→150→151→152；再Glyph094–097/Theme088+load092；随后A098/099（080/084/088保留并新增152），再B/C/Keyboard。** 这是现授权内可逆工程编排，无需新用户许可；计划不等于ready。

依赖证据：session tasks §4 TASK149 inputs列148固定测试、004子合同、已验runtime固定整合、R10、003；没有A102/B107/C112。149.S2唯一实施native byte计数与unsafe闩。有限152不提前关闭paste/cut完整030、020或041，所以`152→A102→B/C→Keyboard114`无环。正式任务卡、Linux计划、输入F001均须由root同步此新前置，不能只改本文。

本候选消费S008实际固定交付：query/屏幕/25输出/cleanup串行同writer。query任何write失败按S008终止run、首错保留；部分失败闩outputUnsafe且后续屏幕/25/title/2004全部零输出；native termios/signal/buffer清理继续。分配失败属于零设备字节，不伪造已发送query；A可沿既有抛错路径结束且保持原态，不把AllocationFailed写成成功探测。

正常/应用异常/stop/signal/EOF退出：先停止input/probe授权，在唯一cleanup路径按**已经取得original且实际管理过mode25**记录恢复显隐；writer允许才发精确原25h或25l。恢复写成功只表示协议字节完整交付，真实host效果仍须产品证据。若没有实际改变原模式可不发冗余恢复；不得因logical caret曾变化就猜设备变过。任何outputUnsafe禁止恢复输出，报恢复不足并聚合首错，不能由termios成功推导显示模式恢复。零byte故障后的清理按S008既定允许范围；若设备不再可写则明确恢复失败，不能重试到无限循环。恢复自身失败同一闩/聚合，不二次“补救show”。

EOF在A继承现cjt_read -3错误路径也须cleanup；不得声称A已经有Keyboard -4 EOF新语义。K004新增EOF后按F003先finish/有序末尾diagnostics，再stop/cleanup且不生成新设备帧；晚到reply不能在关闭阶段取得授权。signal/stop不额外制造诊断回调。再run创建新ledger/decoder；native进程期unsafe闩不能被新run绕过。

### 6. 是否增加只读诊断

逻辑CaretSnapshot不能用于宣称物理可见。产品说明必须列Unknown的上述效果限制；现TerminalCapabilities只表达颜色，source/reason含已冻结颜色含义，不能静默改成cursor来源。

**建议root决定是否在既有TerminalCapabilities只添加一个只读 `cursorVisibilityStatus: String`（无新方法、构造器或设置入口）。** 建议闭集`not-probed / pending / original-visible / original-hidden / unknown-timeout / unknown-clock`；状态字符串是诊断，不供普通应用选择终端。known值记录原显隐，不声称当前像素/成功恢复。终结capability保留如现lastCapabilities；cleanup失败仍走现异常，不塞入该字段；headless首次None/新run重置需与现terminalCapabilities生命周期一致冻结。

增加理由是区分“逻辑visible但设备Unknown”和框架缺陷，满足现架构能力未知可诊断，而不污染颜色reason、不让应用改变策略。它是候选唯一公共增量，必须正常CJPM签名微编译+正式preflight后才能采纳。若root明确要求零公共增量，则只在产品能力文档/故障结果中说明，不能声称每次成功run的Unknown原因已经可由应用查询。绝不为本query引入公共probe、协议回调、超时参数或通用capability registry。

## 后续正式测试准入（此处不创建tests、不执行验收）

1. root正式冻结I015与A.6限定/任务前置、诊断决策，独立preflight核当前源码与候选；已验固定152和原080/084/088输入齐备后才让098准备正式RED，再099实现。新增clock/diagnostic若采用，SDK1.2正常CJPM/内部ABI可编译事实在ready前取得。
2. 纯状态/PTY输入：1/2分别取得原态；0/3/4、错mode、leading zero、额外参数、SS3、C1、非法status、超长、duplicate/conflict、unsolicited不升级。一次query确切7bytes，完整reply9bytes；每个切点分块；正常文本/UTF8/HT/backtab/interrupt在reply前后原顺序，无probe缓存/双派发。
3. 时间边界使用可控时钟/PTY独立oracle：599ms完成接受，600ms拒绝；持续大量输入仍按deadline结束；probe deadline在中间分块时不触发KeyboardDiagnostic或ESC；剩余probe20ms poll唤醒不能误触发100ms idle。**另外单列实际CSI idle100ms触发后续K002诊断/normal，不能混成跨deadline用例。** 无数据、UI callback跨deadline、单调clock失败都保守；不以墙钟sleep偶然速度作唯一oracle。
4. 跨版本：A仅现有输入+I007/reply路径；Keyboard正式升级继承该回复分支、4096预算、F003有序通知，独立公开KeyboardDecoder保持UnsupportedSequence、设备context吞精确report。paste/string含同字节不能执行mode25更新；Keyboard maxSequenceBytes=8/9/64及C1矩阵。
5. 正式产品使用真实XTerm/VTE/VT两种初始显隐；普通同一无override应用。已知宿主分别正常/取消/异常还原精确原值；VT Unknown全wire无25h/l/s/r，逻辑snapshot继续正确、有效caret CUP定位。真实PNG多帧避blink误判，原bytes、termios、退出码、宿主版本/配置、固定源码hash一起记录。原调查可复用环境事实，不能替代这些产品运行。
6. writer故障：query、首帧、caret-only、最后恢复逐必要边界zero/partial，S008 unsafe后严格零后续output、native资源恢复、首错和cleanup聚合、同进程reopen拒绝；整笔写成功前不能提交设备baseline。EOF/stop在无reply和已known阶段、挂载即stop、dispose回调异常、无caret画面都覆盖。复用有效S008既有证据，仅补caret/query新调用边界，不重跑无关全套。
7. 验收分开：逻辑caret正确、协议自动降级正确、真实设备管理/恢复、失败诚实报告。Unknown保留原态可PASS本分支，不能写成“所有宿主原生显隐控制PASS”；A/020/008完整范围按各自AC保留。

## 剩余待root冻结项

- 是否采用一个只读cursor诊断字段；若采用，精确名称/值/跨run及headless生命周期与正式SDK签名。
- Clock实现具体落点需按实际SDK验证；算法/600ms规则已在候选明确。
- 正式docs同步前置和K002断流限定后交另一角色独立审查；本文不是独立审查通过证明。
