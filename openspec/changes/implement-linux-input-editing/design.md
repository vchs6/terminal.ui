# Design

## Implementation status v1 — 2026-11-13

K001–K004已编译、独立审查/实际执行并获117 PASS_FINITE_K；接受源c3c4642对应main da9eaf40，原始设计字节保存在[有限K归档](../../../docs/reviews/K/controller/openspec/changes/implement-linux-input-editing/design.md)。本文冻结签名、语义及预算不变；正文过去的“未编译/候选”措辞按此状态说明理解：K已验证，E001–E005仍未编译/实现，118实际测试进行中、119–122未完成。完整Linux/父AC与整个OpenSpec变更未关闭；具体证据及宿主限制见[K归档](../../../docs/reviews/K/README.md)。

## Context

本件继承首次调查 原独立调查稿（`/workspace/work/input-contract-draft/design-draft.md`） 的源码事实，已按主代理最新裁决整理；首次调查的推荐顺序若与本件冲突，以本件为准。当前主仓KeyEvent已公开 `init(code:String,text!:String="")`，UIKeyEvent/NodeRef/dispatch在同Runtime；InputDecoder/native键盘覆盖尚如初稿，不因新runtime完成就已有paste或编辑。当前真实来源hash见独立工件，不依赖并发HEAD。

主代理已明确采纳：完整paste原子、开始锁目标、1MiB超限drain、100ms ESC、EOF区分；SentUnconfirmed剪切保留，Applied且revision匹配才删；copy可以独立发送；不做OSC52读取，用户宿主粘贴走标准paste。其他带候选签名的选择在freeze-checklist由主代理确认后才成为产品输入。

消费而不重定公共交互候选 `/workspace/work/interaction-contract-draft/openspec/changes/implement-public-interaction/design.md` I001–I010及主代理追加I011（原独立design-draft仅历史）：`Canvas(measure:(Constraints)->Size,draw:(PaintContext)->Unit)`；PaintContext.textWidth/put/fill/caret与selected样式；Component.focusable/enabled/viewport/defaultAction；NodeRef.ensureVisible/viewportSnapshot/application；DefaultActionPhase.Target/Ancestor。依赖实际交互产品固定提交，不能在编辑作者目录写临时Canvas/focus替代品。

## Goals / Non-Goals

两个可验交付：A完整归一化键盘/paste/设备收尾；B用公共primitive交付单多行基础编辑。B消费独立148–152 TASK030会话扩展的copyLocalText接口产品，不以假成功backend填前置。

不做标准Button/Checkbox/Radio/Menu/状态条（另阶段），不做富文本文档编辑、软换行、IME、BiDi、词法导航、自动缩进、鼠标、协同编辑或新平台协议。不新增对外任意ANSI发送、系统剪贴板查询、剪贴板shell命令或终端模拟器。

## Decisions

### K001 — 一个归一化事件与一个解码器

推荐扩展现KeyEvent并将现InputDecoder的唯一状态机升级为可供高级输入适配消费者使用的KeyboardDecoder。替代“另造编辑事件树”重复UIKeyEvent/焦点/模态；替代“各组件解码字节”无法保证paste隔离。新decoder和现AnsiTextDecoder服务不同输入职责：前者设备键盘，后者显式ANSI富文本；只共享现Unicode/SDK和适用的安全小函数，不复制宽度/输出内核，也不把键盘payload交RichText解释。

```cangjie
// 根包 cjtui；现消费者仍只需 import cjtui.*。
public class KeyEvent {
    public let code: String
    public let text: String
    public let ctrl: Bool
    public let alt: Bool
    public let shift: Bool
    public init(code: String, text!: String = "", ctrl!: Bool = false,
                alt!: Bool = false, shift!: Bool = false)
}
public class KeyboardLimits {
    public let maxPasteBytes: Int64
    public let maxSequenceBytes: Int64
    public init(maxPasteBytes!: Int64 = 1048576, maxSequenceBytes!: Int64 = 64)
}
public enum KeyboardIssue <: Equatable<KeyboardIssue> {
    | UnsupportedSequence | MalformedSequence | SequenceTooLong | InvalidUtf8
    | IncompleteInput | PasteTooLarge | InvalidPasteEncoding | IncompletePaste
    | PasteTargetUnavailable
    public operator func ==(other: KeyboardIssue): Bool
}
public class KeyboardDiagnostic {
    public let kind: KeyboardIssue
    public let offset: Int64
}
public class KeyboardBatch {
    public prop events: Array<KeyEvent> { get }
    public prop diagnostics: Array<KeyboardDiagnostic> { get }
}
public class KeyboardException <: Exception {
    public let code: String
    public init(code: String, message: String)
}
public class KeyboardDecoder {
    public init(limits!: KeyboardLimits = KeyboardLimits())
    public func feed(chunk: Array<UInt8>): KeyboardBatch
    public func timeout(): KeyboardBatch
    public func finish(): KeyboardBatch
}
// 两个现Application init追加，不替换limits/theme等已冻结参数。
// keyboardLimits!: KeyboardLimits = KeyboardLimits()
public func onKeyboardIssue(handler: (KeyboardDiagnostic) -> Unit): Application
```

起草时上列新增签名尚未编译；现K签名已在固定公共消费者验证，E签名仍未编译；public constructor默认命名参数/根包跨包可见性必须独立正常CJPM消费者验证。内部位置式旧KeyEvent调用迁移到现公开命名形式或保留原内部适配，不把兼容调用删坏。KeyEvent(code/text)原有含义和interrupt拼写不变。KeyboardDiagnostic/Batch无公开构造，数组防别名修改；不回显无界原始控制payload。KeyboardLimits正数且maxPasteBytes≤16777216、maxSequenceBytes≤4096，违反IllegalArgumentException。InputLimits不塞入RuntimeLimits节点预算。

decoder单调用线程拥有，不线程安全；feed不持有传入chunk或历史输出。内部持有O(maxPasteBytes+maxSequenceBytes+常数)状态，batch输出/诊断O本次输入。普通sequence预算按原始byte包含introducer与final；paste固定六byte分隔符是独立常数识别，不受普通sequence预算截断。timeout由适配器在输入空闲100ms后调用，本身不休眠；feed与timeout的调用序列相同时输出一致。finish丢弃未完整序列并关闭；其后feed/timeout/finish抛KeyboardException("DecoderClosed")，累计byte offset无法表示则fail-close InputTooLarge。偏移是原始流0基字节，序列问题指引导首字节；普通UTF8问题指坏前缀首字节；未完整paste指起始标记首字节。同完整流且相同timeout位置，规范化事件/诊断不因chunk切分改变。

公开decoder为第三方键盘byte源适配、离线按键重放/诊断消费提供同一有界解析规则，不只是测试hook；没有设备句柄、线程或自动事件循环。纯decoder不处理NodeRef或focus。设备适配复用同一状态转移并按流顺序读取内部“paste开始/结束”通知，在开始转移时捕获session目标；不能先整批解码再倒推目标。公开batch只有最终paste事件，不将开始/片段作为可编辑数据交业务。处理一批字节时，之前按键的dispatch/安全提交先于后续paste开始捕获；不同paste可锁不同目标。没有第二解析器。

### K002 — 规范化code与Linux支持闭集

| code/来源 | 精确结果 |
|---|---|
| 可打印ASCII/有效UTF8标量 | code=text，text=原标量；普通文本不从大小写猜shift |
| 完整合法括号paste | code=paste，text=完整原UTF8，修饰位false；整次一事件 |
| CR/LF | enter，不能区分CtrlM/CtrlJ；未标记CRLF是两次enter |
| BS/DEL；HT；单ESC | backspace（CtrlH别名）、tab（CtrlI别名）、escape（Ctrl[别名） |
| C0 01–1A，除BS/HT/LF/CR | code=a…z +ctrl=true,text空；03仍code=interrupt,ctrl=true |
| CSI/SS3 A/B/C/D | up/down/right/left |
| CSI H/F、SS3 H/F、CSI 1~/7~与4~/8~ | home/end |
| CSI 2~/3~/5~/6~ | insert/delete/pageup/pagedown |
| CSI Z | backtab+shift（保留交互I007的code）；旧无modifier的backtab仍表示后退Tab |
| CSI 1;m A/B/C/D/H/F，CSI n;m~（n仅上述tilde导航键） | m=1…8，m-1的bit0/1/2对应shift/alt/ctrl；其他参数不猜 |
| SS3 P/Q/R/S；CSI 11/12/13/14/15/17/18/19/20/21/23/24 ~ | f1…f12；Linux VT ESC[[A…E明确识别为f1…f5，不让最后字母漏成text |
| ESC+一个可打印ASCII/完整UTF8标量 | text+alt；CSI/SS3/控制串引导优先，不将该引导当Alt文本 |
| CSI 200~…CSI 201~ | 仅精确7位标记有括号paste语义 |

0x00/1C–1F没有标准快捷动作，丢弃+UnsupportedSequence。KeyUp、repeat、扫描码、Meta、CtrlShift字母、CtrlEnter、CtrlBackspace、Kitty/CSI-u不支持；shift=false对普通文本表示“协议未提供”，不是物理未按Shift。旧 `KeyEvent("interrupt")` 即使未传ctrl也保持退出默认，设备新事件才规范ctrl=true。旧 `KeyEvent("backtab")`保持后退焦点，显式注入tab+shift=true也作同一逻辑动作；一次输入只发一个事件，不同时发两个别名。应用自定义未知code可以dispatch，不拥有框架默认。

text/paste可带合法文字；保留导航/控制code要求text为空；paste修饰位必须false。向显式dispatch注入不合法保留组合先抛IllegalArgumentException。text可为多个有效非控制标量以便公共适配器一次提供文本；设备普通解码仍逐标量。输入法产出多字文本也只表示文本，不宣称完整IME协议。

未知ESC/CSI/SS3先框定，参数30–3F/intermediate20–2F/final40–7E，非法顺序MalformedSequence。超过maxSequenceBytes报一次SequenceTooLong并drain至final，不漏数字/final。非paste ESC/CSI/SS3空闲100ms：裸ESC发escape，其他丢弃并IncompleteInput；当前后续新ESC取消未完成非string序列并开始新引导。OSC由BEL/ST终止，DCS/SOS/PM/APC仅ST，payload始终丢弃、最多一次Unsupported/资源诊断，超时不释放控制payload；ST兼容原C1且必须在标量边界，不能把UTF8 continuation误认ST。普通坏UTF8丢弃坏前缀、重试当前独立字节，诊断InvalidUtf8；不输出替代符，不把坏续字节重解释为text。

普通非ESC文本的未完整UTF8尾在timeout保留（最多3byte），finish才IncompleteInput；ESC后Alt候选已有UTF8 lead却未完整时，100ms timeout丢弃整个Alt候选，按ESC首byte报IncompleteInput。两者分支固定，不把未完整Alt转成一半text。已超普通sequence预算的drain不会因100ms释放剩余payload；仅未超限的非string未完整序列适用前述超时回normal。

### K003 — paste原子、目标与drain（主代理已采纳）

精确start之后缓存payload/至多5字节终止前缀。任意chunk可分开标记/UTF8；不匹配终止前缀原样回payload；payload内start是普通数据，完整end是协议结束，不能转义表达同字节end内容。未完整前不产paste/text/enter/interrupt。

maxPasteBytes计原始payload byte，含待定终止前缀最终确认属于payload的部分，不含完整分隔符。恰等于合法；下一payload byte超限即释放缓存，PasteTooLarge一次，直到end保持drain，仍可处理resize/post/stop。无隐含paste超时；100ms空闲不恢复normal；EOF/stop/signal丢弃，不提交。过限/编码错后不再保留全文，计数饱和防回绕。完整payload无效UTF8整次InvalidPasteEncoding、无paste；普通decoder不对合法UTF8中控制字符执行动作，交一个paste供目标编辑器整体校验。0x03在paste/drain先按数据处理，不能走normal interrupt分支。

开始时捕获当前activeTarget的弱NodeRef完整代际和活动输入域。结束时同目标仍挂载、visible、enabled且仍允许在其域接收时才投递；单纯focus移到另一节点不把内容改投新目标。目标hidden/disabled/unmount、新modal隔离或旧session结束时丢弃并诊断PasteTargetUnavailable；不回落app/legacy。开始无目标则整次保持无目标并丢弃，不能等结束捡新目标。单纯滚出clip不等于hidden。headless直接dispatch(paste)使用指定目标，不能绕当前允许域。完整114准入消费交互102/107/112固定产物，不能用当前root-only状态代替正式focus/modal目标锁验收。

### K004 — native读取、预算和恢复

保留cjt_read既有-1无数据、-2外部SIGINT/SIGTERM、-3真实错误语义，新增-4 EOF。POLLIN+HUP先读已有字节，读0才EOF；HUP且尚有缓冲不能先报-3。建议内部有界块读取/缓存减少每byte poll，不改公开业务API；cjt_read可保留兼容薄包装，不保留第二读取权威。新内部ABI若采用需记录精确返回/容量并有C公开符号消费者，不由仓颉作者猜长度或unsafe越界。

每UI turn最多处理4096输入bytes，预算耗尽先完成已到达事件/依赖/设备更新并处理入口已排队post，继续剩余有界native缓冲；这不是丢输入或截paste。只读少量bytes不能把一长paste独占所有pump。过量设备输入由OS流控等待，不复制到无限内存队列。实际字节/事件顺序、paste开始锁、后台结果提交均以同Runtime安全边界排序。

EOF调用decoder.finish，只诊断未完整输入/paste，不发末尾escape或部分text；正常结束run恢复。外部signal不是UI按键，不允许preventDefault使进程无法退出；键盘normal 03仍经UIKeyEvent按R010可阻止。stop/信号/异常撤销pending paste与目标句柄，统一finally恢复termios、自己请求的2004与光标；没有修改的宿主扩展状态不乱恢复。新增2004模式由会话统一拥有，不由组件输出ANSI；初始化/恢复/部分写入沿原008/D027围栏，不能因为发送了disable就声称未知解析状态已恢复。

与030 S008集成时，outputUnsafe已闩住则2004/光标/title等清理全部禁止再发字节，只做静默native资源恢复并明确显示模式恢复不足；输入单元不得以disable-paste清理绕过同一停输门。149唯一实现扩展writer的计数/闩；其有限152验收先完成，114消费该已固定writer恢复接口，116补新增2004模式的正常/故障cleanup回归，不能绕过同一停输门。完整030粘贴/cut父AC在117/122后汇合，不要求152提前验未实现输入。

### E001 — 公共编辑入口与可选控制器

精确候选接口如下。工厂直接返回**一个Canvas根**而非外包Column；这个Canvas自身focusable，才能按交互合同获得caret。没有TextInput专用kind。控制器是可选弱句柄，使常规应用不必创建编辑模型或手写refresh。

```cangjie
public struct TextSelection <: Equatable<TextSelection> {
    public let anchor: Int64
    public let caret: Int64
    public init(anchor: Int64, caret: Int64)
    public operator func ==(other: TextSelection): Bool
}
public class TextEditLimits {
    public let maxTextBytes: Int64
    public let maxUndoEntries: Int64
    public let maxUndoBytes: Int64
    public init(maxTextBytes!: Int64 = 1048576, maxUndoEntries!: Int64 = 128,
                maxUndoBytes!: Int64 = 2097152)
}
public enum TextEditIssue <: Equatable<TextEditIssue> {
    | MultilinePasteRejected | ControlCharacterRejected | InputTooLarge
    | ClipboardUnavailable | PasteFromTerminalRequired | CutUnconfirmed | CutStale | ConcurrentValueChanged
    public operator func ==(other: TextEditIssue): Bool
}
public class TextEditSnapshot {
    public let text: String
    public let selection: TextSelection
    public let revision: UInt64
    public let selectionRevision: UInt64
    public let canUndo: Bool
    public let canRedo: Bool
}
public class TextEditController {
    public init()
    public func isValid(): Bool
    public func snapshot(): TextEditSnapshot
    public func select(selection: TextSelection): Unit
    public func selectAll(): Unit
    public func replaceSelection(text: String, ifUnchanged!: ?TextEditSnapshot = None): Bool
    public func undo(): Bool
    public func redo(): Bool
    public func copy(): ?SessionResult
    public func cut(): ?SessionResult
}
public func TextInput(value: Observable<String>, controller!: ?TextEditController = None,
    limits!: TextEditLimits = TextEditLimits(),
    onChange!: (String) -> Unit = {_ =>}, onSubmit!: (String) -> Unit = {_ =>},
    onIssue!: (TextEditIssue) -> Unit = {_ =>}): Component
public func TextArea(value: Observable<String>, controller!: ?TextEditController = None,
    limits!: TextEditLimits = TextEditLimits(),
    onChange!: (String) -> Unit = {_ =>},
    onIssue!: (TextEditIssue) -> Unit = {_ =>}): Component
```

新增类型各单文件；推荐根包cjtui（实现内部编辑纯数据可按职责下沉，但不能root↔text循环导入）；共享style/text类型只依赖其既有子包。SessionResult/SessionStatus/SessionOperation定义来自148–152会话扩展前置，119不复制，也不新增ClipboardRequest/队列。TextEditSnapshot无公开构造、不可变副本。TextSelection允许非负anchor/caret，超过当前N在select拒绝IllegalArgumentException，不静默造非法范围。limits均正数，maxTextBytes≤16777216，maxUndoEntries≤65536，maxUndoBytes≤67108864；满足上限的一个编辑可发生，即使该操作完整undo记录超过历史预算也只导致旧/该条记录不保留，不能截正文。

controller只持有当前挂载代际的非拥有访问；同时绑定两个活跃输入报AlreadyMounted，卸载后isValid=false（可跨线程），其他读写StaleReference；重新挂载绑定新代际并重置局部状态。snapshot同UI域可在只读求值使用并跟踪，只读最近已提交的编辑视图，不暗pump、不拿最新source版本给旧text盖章；其他变更只在事件/post/batch安全域。异session/后台/重入沿现UI错误。不给controller可变Frame或运行节点。没有传controller的调用同样完整可编辑；每视图创建独立运行局部state，同一Observable可绑定两视图但不共享caret/history/offset。

通用Observable的后台get/set/notify许可原样保留。编辑源可以被后台set，不把通用业务状态突然改成UI-only。初始/外部赋值须符合编辑组件的模式文本约束（LF规范、单行限制和限额），非法值按现文本属性校验明确报错，不在getter中悄改业务值。程序replaceSelection先规范CRLF/CR并校验；非法调用抛IllegalArgumentException且无副作用，键盘/paste则拒绝+onIssue，session继续。bool表示是否确实改变文本，no-op不入历史。

**并发提交候选**：在Observable自身唯一锁/版本权威中增加仅框架内部的原子(value,version)读取和按expectedVersion条件提交小操作；不新增公开CAS、不开放锁/observer列表，也不在TextEditSession建立第二source版本。UI编辑先取当前源快照，处理尚未同步的外部版本，锁外纯计算规范化新文本/selection/history，再条件写回。版本竞争时本次编辑不覆盖后台新值、不写本地undo/onChange，刷新为最新外部值并onIssue(ConcurrentValueChanged)；不自动把旧paste/删除意图重试到新位置。不在源锁内调用用户代码/Unicode遍历。单一helper负责写值+版本并锁外emit，局部编辑记录在当前UI安全批次发布，成功source版本作为自身写来源token；不能仅凭字符串相等识别自己的写。

上述内部集成必须经主代理冻结和Runtime owner审核；若不接受最小条件提交，应另选明确的TextEditModel承载该事务，不能用文档把原Observable后台许可撤销，也不能默默用get/set覆盖并发值。现公开Observable方法和绑定模型都不变。

TextEditSnapshot同时携带框架内部记录的、调用方不可伪造的mount/session/source-version身份；它不是新可变模型。`replaceSelection(text,ifUnchanged:Some(snapshot))` 在读最新源后同时校验该身份、全文revision及selectionRevision，再以源版本条件提交；不匹配返回false、不修改文字/selection/history，无隐式重试。该可选参数供应用在app.post/回调边界安全消费先前结果，普通编辑不必传。它不能只比较当前可见snapshot（该只读查询不pump，后台变化可能尚未投影到UI），必须核实际源版本。snapshot来自旧mount或不同controller同样拒绝false，不能命中一个新挂载的同文本。

成功编辑一次写value、一次onChange；用户回调抛错按既有清理，已写业务不回滚。外部set/notify（含同值通知）使各视图推进局部revision、清历史/未执行cut意图、钳制selection。自己的写来源token不清自己的undo；同一源随后后台写入的新版本正常作为外部替换。UInt64编辑revision耗尽CapacityExceeded，绝不回卷。
### E002 — 文本事务、Unicode与历史

paste先将CRLF/单CR规范成LF；单行含LF整次MultilinePasteRejected。HT及其余C0/DEL/C1整次ControlCharacterRejected；不把HT默默改空格，后续若支持tab另冻文本/绘制契约。多行只LF硬换行、首版不软换行；TextArea不接受静态Text.wrap/overflow/textAlign属性，按Theme T003明确InvalidProperty。没有NFC/NFD自动转换。

caret/anchor是全文字符簇间隙0…N，LF也是簇，半开选区[min,max)。String.size仅UTF8byte，Rune数也不是簇位置。用现graphemeClusters分段、用Constraints/PaintContext.textWidth取本次统一宽度，不自造算法或Unicode表。替换前按旧簇边界提UTF8片段；替换后重分整个新文本，连接处组合符/ZWJ/旗帜必须可重组。不能各自分簇后拼数组。新caret由插入末端byte位置向后吸附最近新簇间隙，anchor折叠同位。

每次键盘文字、删除、Enter或完整paste为一条undo；移动/选择/复制/no-op不记。undo/redo恢复文本与该视图selection，新文字编辑清redo；外部值替换清历史。预算按undo+redo合计条数，以及每条保留的before/after逻辑文本UTF8字节（不按输出buffer或字符数）加总；只淘汰最旧完整项，不留半记录。历史结构若共享不可变文本可减少实际内存，但预算按同口径，不用共享偷偷无限留版本。卸载丢局部历史，业务value仍在。复制外部效果不能被undo回滚。

### E003 — 标准快捷键与默认阶段

遵循交互候选的确切阶段：capture→bubble→允许的新app→legacy非interrupt→目标Target默认→框架interrupt/Escape/Tab→每个祖先的用户Ancestor槽、未prevent再尝试该节点标准viewport默认（I010）。已prevent则所有后续默认不执行，stop仅停传播；完成编辑/复制/导航时Target调用preventDefault，禁止外层二次滚。ScrollView不另注册重复滚动回调；默认context/currentTarget/过期由交互统一管理，119不得另造默认队列。

| 事件 | 目标默认 |
|---|---|
| text且无ctrl/alt | 替换选区/插入，成功一次变更；shift不改变text本身 |
| paste | 全文校验后一次替换选区，一条undo，不submit |
| enter | TextInput一次onSubmit且不改值；TextArea替换选区为LF；prevent可阻止两种默认 |
| left/right | 有选区先折叠相应端，否则移一簇；Shift保持anchor扩展 |
| home/end | 当前逻辑行首/末；Ctrl到全文首末；Shift扩展 |
| up/down | TextArea按preferred显示列移逻辑行，等距取较小列；TextInput无默认，允许外层滚 |
| pageup/down | TextArea移max(1,viewportHeight-1)逻辑行；Shift扩展；边界无位置变化时仍视作编辑器明确处理，不再滚祖先 |
| backspace/delete | 删选区或前/后一整簇；边界no-op仍消费，不触发外层编辑 |
| CtrlA | 全选 |
| CtrlZ/CtrlY | undo/redo；不可区分CtrlShiftZ不作为唯一重做入口 |
| interrupt(CtrlC)/CtrlInsert | 有选区copy并阻止应用退出；无选区interrupt仍按现R010退出；CtrlInsert无选区不操作 |
| CtrlX/ShiftDelete | cut，保守结果事务；有选区即消费，即使Unknown/Failed也不能把同键交业务再误删 |
| CtrlV/ShiftInsert | 不查询系统剪贴板。终端若拦截则发标准paste；若键到应用仅提示宿主粘贴边界并消费，不宣称已粘贴 |
| Tab/ShiftTab，Escape | 编辑器不清文、不写HT，不自处理，交框架焦点/层默认；应用可用前述handler重绑 |

方向/Home/End/Page的Shift语义一致；横移/编辑重置preferred列，连续纵移保持。无现有标准Ctrl词边界移动/删除；应用可用公开controller自行绑定。标准Button/Checkbox/Menu不在本变更展开。

### E004 — Canvas、Theme/RichText和唯一viewport

TextInput设置ThemeRole.TextInput，TextArea设置ThemeRole.TextArea；根为Canvas且focusable(true)，默认enabled(true)，主题disabled只是外观，不改行为。真实focused/disabled由交互I012统一resolver合成，输入控件不再用ref查询仿造另一份外观态；业务selected等声明状态沿同resolver合并，用户用普通显式样式/styles覆盖外观。选区用ctx.put/fill(selected:true)，底样式用同resolver；组件显式 > draw TextStylePatch > span patch > 复用/主题/继承/默认，不能把完整Style强行盖最上层。本文本是String编辑，不让paste ESC经parseAnsiText；公开RichText展示另由RichText合同实现。

每行绘制整簇，选区片段分界只在簇边界，可构造TextSpan/RichText共享已有完整值验证，不能在一个emoji中间分多个put。LF没有可见字形；被选中LF用行末一个selected空格标示，不复制该显示空格。组件背景/selected fill仍是有样式真实空格，不等于透明hole。

Canvas.measure读逻辑文本/本次宽度profile，draw读已计算行表、selection/caret/focus；依赖分类按交互A。首版全文重分/行表计算允许，M1完整render仍完整参考，不能宣称caret变化已不重测或M2性能通过；可缓存纯不可变行表使measure自身常数读取，缓存不是第二布局树。任何draw/measure不写Observable/请求滚动/改变focus。

单行.viewport(ScrollAxes.Horizontal)，多行.viewport(ScrollAxes.Both)。**offset只在NodeRef挂载viewport一处拥有**，编辑局部state不再保存另一个offsetX/topLine。Canvas extent每行含末端一格caret占位，contentWidth=max(line displayWidth+1)，contentHeight=max(1,lineCount)；测量有限、不分配文档大小Frame。draw按ctx.clip取可见行/完整簇；边缘宽簇不完整即留底色空格，绝不半字。

caret以逻辑内容列/行声明ctx.caret，只有当前focused Canvas可输出；零尺寸、clip外、被层覆盖/continuation格隐藏由公共caret统一判断。移动/编辑默认结束后在事件中请求ref.ensureVisible(rect:Some(Rect(caretX,caretY,1,1)))，框架布局后用新extent定位；不可在draw中调用ensureVisible。resize/content变短公共viewport钳制，focus保持。示例A中B列边界0/1/3/4，宽2无法完整展示“中”的窗口只留空格；逻辑caret仍在簇间隙。不自算与Frame相异的ambiguousWide开关。

### E005 — 消费148–152统一会话结果，默认cut保守

唯一前置为主代理指定 `/workspace/work/session-extension-contract/openspec/changes/implement-session-extensions/design.md` S002–S009：`Application.copyLocalText(text:String):SessionResult`、SessionStatus/SessionOperation/SessionCapabilities以及现post。其原TASK030产品149、独立执行151、验收152固定后才是119输入；118可先准备源，真正编辑RED不能由缺会话API冒充。旧异步ClipboardRequest提议只存history，不注册、不实施、不作前置。

copy是UI域同步typed结果，无第二请求/ticket/worker/clipboard队列。后台通过现app.post FIFO调用；post true只表示排队，不是复制成功。Unknown真实TTY的显式Direct best-effort请求允许发固定OSC52，完整写最多SessionStatus.SentUnconfirmed；headless/Disabled等按会话合同Unsupported，真实无确认协议不造Applied。普通copy可直接调用app.copyLocalText，完全独立于编辑器。

会话装配消费主代理指定交互A追加I011：`NodeRef.application():Application` 是同UI域只读查询，不pump；失效StaleReference，foreign活动域WrongUIContext，无Application关联SessionInactive。可在getter读关联但不因此取得副作用权限；后续copyLocalText仍守030操作域限制。标准输入与用户Canvas一律用 `ref.application().copyLocalText(selectedText)`，不新增NodeRef复制专用方法，不让业务向每个TextInput注入app回调，不私取runtime.app。Application引用可保存，但每次方法仍验证session/owner/stop/post约束。I011属于交互前置，未固定通过时119不能自补私有替代。

cut在同步copy前捕获节点代际、sessionId、全文源版本/编辑revision、selection revision、anchor/caret和选区内容；返回Applied且操作=CopyLocalText、会话相同且所有版本仍匹配才条件删除，新增一条undo。SentUnconfirmed/Unsupported/Unknown/Failed保留全部文字/selection/history，给onIssue/typed结果。同步writer耗时期间后台仍可修改业务Observable，故**同步返回也不能省略源版本条件检查**。选区移开再移回同坐标必须由selection revision识别，不仅比最终字符串/坐标。

应用若自行延后消费结果（例如app.post或业务callback），先保存controller.snapshot()及会话结果，仅Applied时在消费边界调用 `controller.replaceSelection("",ifUnchanged:Some(snapshot))`；该方法核代际/实际源版本/两类revision，false则保留并报告迟到结果。框架不为此增加异步clipboard协议。controller.cut本身同步收尾，没有cutPending字段或未完成ClipboardRequest。TextEditSnapshot.revision是全文编辑版本，selectionRevision只在选区实际变化时推进，供move-away-back安全检查；只读查询不暗pump。

现030版本没有真实Applied生产者；实际宿主主要证明SentUnconfirmed保留路径。Applied删除政策可用明确标注的纯值策略断言/独立审查核验，不能用假adapter声称确认协议或本地剪贴板已支持；将来真实adapter交付时补它的真实集成，不把未支持协议设为输入启动条件。

## Risks / Trade-offs

* [公共decoder/编辑controller新增签名] → 主代理逐签名冻结；正常SDK1.2公共CJPM消费者先编译，不以伪代码通过；无法保持typed/API时报主代理再冻结。
* [输入长paste饿死post或无终止时误释放] → 4096byte/turn、公平pump、1MiB+drain、不以poll结束paste；外部signal/stop仍有效。
* [控制串终止与UTF8 continuation混淆] → 明确标量边界，原decoder覆盖迁移并用原始byte golden；不复制RichText ANSI内核。
* [共享value的后台竞争] → 保留原Observable后台许可，用其唯一版本权威的内部条件提交防覆盖；竞争明确拒绝当前编辑，公开get/set不改，不引协作协议。
* [剪贴板支持不足] → 独立五态且真实写后仅Sent；缺能力继续编辑，同步或延后消费均版本检查，不删未确认内容。外部资源失败若导致设备失同步沿既有fatal恢复，不能当可恢复编辑校验错误。
* [主题/viewport写同文件] → runtime C/RichText/Theme/交互A+B各自固定集成后119才改；同Component/LayoutNode/exports/Application不并行产品写。

## Migration Plan

1. 主代理冻结本件、交互I011及148–152会话前置，解决freeze-checklist；独立preflight/DQ通过后转为正式OpenSpec路径/状态权威。
2. 113固定测试RED→114产品→115审核→116独立执行→117验收；原InputDecoder退役为唯一KeyboardDecoder，read/EOF包装只有一处权威，现KeyEvent/legacy兼容保留。
3. TASK030会话扩展148–152先独立产品/审核/执行/验收；既有主题/富文本/交互A+B固定通过后118正式RED→119→120→121→122。
4. 后续modal/动态重排、主题完整showcase、原020全部恢复、原030标题/图片图标、Linux041物理console与024最终汇合保持原AC。失败修复只重跑受影响证据，不以文档/新commit机械全冷重建。

起草时所有候选planned；当前K已登记/实施/有限验收，E实际118测试进行中、119–122未实施/验收。没有发布/不可逆持久数据迁移。

## F001 主代理最终工程裁决（优先于候选措辞）

采用K001–K004/E001–E005及freeze-checklist列出的精确API、预算和事务方案；公开KeyboardDecoder供高级输入适配/重放，共用唯一状态机，不作为专属测试hook。通用Observable后台get/set/notify许可不变，其唯一版本拥有者增加包内原子(value,version)读及expectedVersion条件写，计算与回调在锁外；不用新公开CAS/业务模型替代旧许可。editing自己的UInt64 revision与现Observable内部Int64版本是不同职责，不能混称相同计数或伪造新来源token。

执行顺序明确：有限会话148–152先于114，让唯一writer/partial unsafe门成为输入模式输出的实际前置；152本身不提前关闭完整030 paste/cut，故无语义环。114其余前置为080/交互102/107/112及113正式测试，119再等117、118、088/092、084、080、交互及152。共享源仅一个产品作者。新模式回归由116/121及最后Linux汇合覆盖。

消费交互最终I001–013（ScrollAxes.Off、I011应用只读服务、I012自动行为外观态）和会话S001–012最终合同，以主仓各change为权威，原独立绝对路径仅来源记录。Keyboard backtab规范继承交互既有code，兼容旧无modifier注入，Tab+shift别名不生成重复事件。所有新签名未实施，实际SDK微编译及独立preflight后才能固定正式测试准入；无需再向用户请求同目标确认。

## F002 C1字节矩阵与诊断边界（INPUT-PF-001）

K002“有效UTF8标量→text”仅指非C0/DEL/C1控制标量。下表在真实UTF8标量边界同时适用于单raw C1字节和对应U+0080–009F的完整UTF8编码；raw引导占1byte，UTF8引导占2byte，都按实际原始byte计预算/offset。有效多字节标量中的80–9F续字节永远不是C1。已有raw/UTF8 C1 CSI与控制串兼容保留。

| C1 | normal / 非string ESC序列中行为 | string / paste中行为 |
|---|---|---|
| 9B CSI | 相当于CSI引导，按K002导航矩阵；取消尚未完整非string序列并从当前C1首byte开始 | string中只作丢弃payload；paste中按原始payload |
| 90 DCS、98 SOS、9D OSC、9E PM、9F APC | 进入相应受隔离控制串，首引导即一份UnsupportedSequence | string中不嵌套；paste中为payload |
| 9C ST | normal/非string中一份UnsupportedSequence且丢弃，不产text；终止当前非string错误序列后恢复normal | 真标量边界终止控制串；paste中为payload |
| 其余C1（含8F） | 一份UnsupportedSequence且不产text；不新承诺C1 SS3，7位ESC O仍按K002 | string只丢弃；paste为payload |

CSI的200~/201~只有精确7位ESC [版本有paste意义，raw/UTF8 C1版本按不支持CSI完成序列诊断，不进入paste。未标记/未知协议粘贴不能被宣称原子粘贴。OSC由BEL或ST终止，DCS/SOS/PM/APC仅ST；ESC非ST、CAN/SUB及其它payload不释放串。控制串不缓存payload；首Unsupported之后至终止不重复Unsupported/SequenceTooLong，finish仍可另给IncompleteInput；其长度计数饱和，不为已丢弃payload分配内存。普通非string序列仍按K002首Malformed/SequenceTooLong一次并drain。

唯一键盘取消特例：不在paste或paste-drain时，raw0x03取消当前非paste解码状态（丢弃已收集片段）、发interrupt(ctrl=true)，其后字节作为新输入；这保留已有CtrlC退出优先。paste及其drain里的0x03始终数据/丢弃，不发interrupt。终端外部SIGINT/SIGTERM仍不成为可拦截UI按键。

## F003 回调阶段、流内顺序与非法注入（INPUT-PF-002）

KeyboardDecoder纯值批次的events与diagnostics各按发生顺序排列，不承诺这两个数组之间的交错编码。实际设备适配必须复用同一状态转移的内部有序通知（含原始stream位置），在消费后续byte/paste-start之前按流内顺序派发已经形成的event/diagnostic并完成其安全UI批次，不能先整read解完再倒推paste目标。诊断只有kind/offset，不把payload作为快捷键或文本。

onKeyboardIssue在所属Application owner UI普通callback域，自动包一个batch；没有UIKeyEvent target/capture/default，无prevent/consume语义，也不穿透转发原输入。该应用级诊断可在modal期间报告协议错误，但没有键盘payload或下层业务shortcut。handler允许Observable写入、正常focus/结构命令/post，末尾安全稳定提交；后续byte/paste开始捕获能看到已提交焦点。snapshot/dispatch/dispose等递归边界仍按R018拒绝，stop可请求；handler抛错保持原异常、清理当前session，后续输入不投递。

EOF先调用finish，在仍active的UI域依上述顺序报告末尾diagnostics并完成其批次，然后requestStop并cleanup；不再生成设备目标帧，不发末尾半事件。handler中post仍只是排队，随后EOF关闭会取消未运行项；不承诺post成功就执行。外部signal/stop直接清理取消paste，不额外执行合成键盘诊断回调。

成功编辑先条件提交源值，再发布该编辑的本地text/selection/revision/history，之后同步onChange一次，callback.snapshot可见这份已提交本地状态；无并发写时Observable.get同值，有并发业务写时不能保证仍同值。onSubmit看到最近稳定的本地文本且不改数据；onIssue在拒绝/no-op决定之后执行，拒绝本身不新增历史。callback可写Observable业务源（后续安全稳定按外部变更处理）、操作其它视图及post；同一editor自己的onChange/onSubmit/onIssue同步通知栈期间禁止再次调用其变更/undo/redo/copy/cut方法，报LifecycleReentry，只读snapshot/isValid允许。要再次编辑可post下一turn；不以无限递归回调实现用户输入。

显式dispatch先检查原owner/阶段，再在任何用户回调/业务副作用前验证保留code组合；无效组合抛IllegalArgumentException，外层直接调用的参数拒绝不结束健康session。若异常发生在用户已运行callback内且未捕获，仍沿原callback失败清理，不绕过R007/R018。decoder自己产生的事件必须始终满足同一校验。

## F004 copy/cut结果与issue精确映射（INPUT-PF-003）

controller.copy/cut无非空选区时返回Option.None，零会话输出、无issue/历史/数据变化；有选区时返回Some(实际SessionResult)，不得合成Applied。copy的Applied或SentUnconfirmed不报issue，Unsupported/Unknown/Failed报ClipboardUnavailable一次。copy不因源变化删除数据；正常外部变更仍按E001处理。

cut优先按结果分支，最多一个cut issue：

| 结果 | 本次cut行为 |
|---|---|
| Applied且节点/session/源版本/两revision/selection身份仍匹配，条件提交成功 | 删除捕获选区，一条undo，一次onChange，无cut issue |
| Applied但任一身份/版本不符或最终条件写竞争 | 不删除，CutStale一次 |
| SentUnconfirmed（不论同时是否有外部写） | 不删除，CutUnconfirmed一次 |
| Unsupported/Unknown/Failed（不论同时是否有外部写） | 不删除，ClipboardUnavailable一次 |

不叠加ConcurrentValueChanged到cut结果；外部写的正常同步/历史清理不是cut自身删除。设备fatal Failed仍由S008停止并抛首个设备错误，issue或后续callback异常不能盖掉首错，仍保留附加失败。CtrlV/ShiftInsert到达编辑器时发PasteFromTerminalRequired一次并消费，零剪贴板查询；如果终端已转换为paste事件则只走paste，不额外报该issue。

CtrlC无选区不消费、让原interrupt默认退出；CtrlInsert无选区消费但无输出；CtrlX/ShiftDelete无选区同样消费但无输出/issue。显式replaceSelection(ifUnchanged:Some(snapshot))不匹配返回false，不自行onIssue、不由该方法修改源/本地选区/历史，报告迟到结果由调用应用决定；已有外部源失效仍在正常后续安全边界投影。未传guard的普通编辑若源条件提交竞争，按E001刷新外部值并报ConcurrentValueChanged一次。

## F005 编辑初态、无文本变化与revision（INPUT-PF-004）

首次挂载与每次重挂载均anchor=caret=0、revision=0、selectionRevision=0、undo/redo空、viewport初始offset=0；先验证原业务初值，不触发onChange。后续focus/显式controller操作可改变局部选区，业务值不因挂载改变。旧快照由私有mount/source身份隔离，不能仅因两revision重置就匹配新挂载。

把非空选区替换成相同文本导致全文不变时，仍按插入末端重分/吸附并折叠选区；若anchor/caret实际变化，selectionRevision推进，绘制/光标相应失效。返回false（仅表示全文未变），不调用Observable.set、不推进text revision、不onChange、不新增历史、不清redo。完全无文本/选区变化的空操作也不推进revision。普通select/selectAll仅实际选区变化推进selectionRevision。外部同值set/notify仍按E001推进text revision并清历史，若钳制没有改变选区数值则selectionRevision不动。

两个UInt64局部revision都不得回卷。编辑器自己的文本/选择操作先预检本次确实需要推进的局部revision容量，再做源条件写与本地发布；已Max则在这些副作用前报UIException CapacityExceeded。外部set/notify或业务callback写源已完成后，UI同步若需要推进而耗尽，只在发布新的本地状态/来源token之前报错并沿Runtime终止清理；保留业务源已写值，不回滚、不伪造旧快照新token，也不撤销通用Observable后台许可。不可达超大计数场景可由固定源码不变量或实际生产pure helper同包边界证明，不能伪造已运行2^64次或新增public测试setter。现Observable内部Int64源版本不改成这两个编辑计数。

## F006 I015内部mode25查询的键盘继承边界

公开KeyboardDecoder默认无设备接点；精确ESC[?25;P$y仍UnsupportedSequence。设备run按interaction I015在同一decoder CSI路径接内部报告P=0..4，只有完整未被timeout/cancel打断的7bit九字节形态可消费；不产生业务key/issue、无独立parser/queue。Probe600ms截止不触发键盘timeout，不影响100ms真实idle；真正timeout后保留K002原normal/diagnostic，不长期重组。paste/string payload不识别报告；序列预算不豁免，maxSequenceBytes8可SequenceTooLong而不授权。F003输入位置/通知先后、F002 C1规则、K004每turn4096均保留。有限Session152现先于A，故114消费152和A的实际query/writer输入，不重复实现查询或partialunsafe闩。公开键盘签名无变化，完整113准入仍等实际交互/Session源。

## F007 非string序列取消不额外诊断

K002新ESC、F002标量边界新raw/UTF8 C1 CSI及非paste raw03取消已有未完整非string状态时，取消本身不额外产生IncompleteInput或MalformedSequence。先前已经报告的MalformedSequence/SequenceTooLong等保留，新引导自身诊断仍按原规则；这是与真实timeout/finish相区分的取消语义，不改变字符串隔离、UTF8边界或paste/drain内03为数据规则。字面例：ESC[12 ESC[A只产生新up；ESC[12 03 x产生interrupt(ctrl=true)、text x；ESC[1 raw9B A在标量边界只产生新up；各例没有取消附加issue。已被真实100ms timeout打断的旧序列已有IncompleteInput照常保留，不能事后撤销。
