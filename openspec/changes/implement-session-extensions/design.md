# Design

状态：**可冻结草稿，尚未主代理冻结；全部新公共签名/示例未编译，未实施、未正式测试。** 原始宿主事实来自独立调查，不能当作本产品 API 或效果确认能力。主代理冻结后另派独立 preflight。

## Context

动机见 proposal.md。本次只读源基线为 `acd8a1568b1007ba684a032836d8593c63ad6a10`；主仓在并行演进，实施前需固定集成输入。`Application.run()` 是唯一 Linux TTY 入口，`RuntimeSession` 已拥有 UI thread/nonce、post FIFO、stop/dispose；`terminal_bridge.cj`/`native/cjtui_terminal.c` 是唯一输出通道。当前 native `cjt_buffer_write()` 仅返回 0/-1，丢失部分写入字节数；R10 围栏保证检测/回调异常后仍 dispose、聚合异常并执行 native close，**它没有证明任意 OSC/DCS 中断后的 parser 重同步**。

已读 AGENTS、工程任务分解、Battle、整体提案/架构/用户构造、requirements、terminal-session、TASK-004/020/030/041，以及相关 runtime/颜色冻结合同。独立 host 输入为 `/workspace/work/session-extension-recon/report.md` 和 `raw/final/`；没有依赖产品作者自评判定支持。

| 实测事实 | 合同含义 |
|---|---|
| XTerm398 默认 OSC52 被拒，显式 SetSelection 可写入；标题禁用与剪贴板权限独立 | 写成功不是 Applied；能力逐项，不能从 OSC2 推 OSC52 |
| XTerm398 可两层 title push/pop；screen 默认 OSC2 生效但栈不恢复 | 标题与栈能力分开 |
| VTE 动态标题 A/B/A 后原值为空；tmux set-titles 恢复 pane_title 非外层原标题 | 不泛称“恢复标题成功”，必须标明目标和完整路径 |
| 单层 tmux/screen 显式透传在冻结配置可到外层 XTerm | 只提供有类型的一层高级配置，不自动推测多层包装 |
| 尚无图片图标 adapter，无真实 SSH/Wayland/大负载证据 | 图片接口诚实 Unsupported；未知实际环境不提升 Supported |

## Goals / Non-Goals

目标：普通应用在既有 Application 回调中调用一次公共方法，获得可安全消费的结果；缺能力不阻塞核心；现有 TTY 恢复围栏不被可选操作绕开。给未来编辑 cut 明确“确认且版本未变才删除”的约束。

不增加 clipboard read、shell/工具进程、任意 ANSI 透传、通用图片图标协议、第二 session/event loop/worker pool。此增量不实现 TASK-028 编辑器、TASK-041 完整输入/粘贴、TASK-008 所有 parser 恢复；这些父范围继续待验。

## Decisions

### S001 — 有限决策 Battle 与采用路线

本草稿为 decision；下列是作者分角色检查与推荐，不冒充独立 Battle。协调者已采纳 Unknown 显式 Direct 尝试的推荐；最终冻结仍以主代理产物为准。

| 决策 | 可执行方案 | 推荐及依据 |
|---|---|---|
| Unknown 默认 | A：Unknown 一律零输出；B：只在显式调用时发送固定 Direct 候选；C：TERM 白名单当 Supported | 采用 B。A 使普通复制/标题必须配置；C 被真实权限负例否定。B 把通道选择与支持/确认分开，没有请求绝不发送 |
| 调度 | A：UI owner 同步返回、后台 app.post；B：另建异步请求队列/ticket | 采用 A，复用现有 FIFO/边界，避免重复生命周期；复制不承诺硬实时 |
| 标题恢复 | A：每次设置 push；B：每会话第一次修改前至多一个栈 scope；C：启动时读原标题 | 采用 B。A 容易栈泄漏；C 引入回复解析且无可靠跨 host 语义。不 query 原值，未知栈不 push/pop |
| 失败后 parser | A：盲发 CAN/ST 继续；B：失败停止输出，独立 native 清理；C：新增完整终端模拟/parser | 采用 B。A 未验证 DCS/mux/UTF8 各位置，C 越界；本增量不声称自动重同步 |
| mux | A：根据环境猜包装；B：高级 typed 单层路径；C：任意 nesting/原始escape | 采用 B。只负责固定编码，权限仍由用户控制，普通 Auto 不要求高级配置 |
| 图标 | A：OSC1；B：空壳公共降级入口；C：直接X11/Wayland库 | 采用 B。A 不满足真实图片要求；C 不适合 SSH 且增加非必需依赖 |

检查维度：用户构造便利、远端本地目标、能力事实与配置声明分离、parser 安全、清理/所有权、上限可测试、线程与并发、现有接口兼容、可独立验收。未虚构独立通过结论。

### S002 — 公共接口签名（全部未编译）

归属 `cjtui` 根公共入口；纯值类型可置 `cjtui.session` 并由根重导出，不能反向依赖 RuntimeSession。每个类型独立文件。以下是待正式 SDK 消费者验证的仓颉签名设计，无示意实现体。

```cangjie
// Application additions; signatures only, NOT COMPILED
public func sessionOptions(options: SessionOptions): Application
public func sessionCapabilities(): ?SessionCapabilities
public func copyLocalText(text: String): SessionResult
public func setHostTitle(title: String): SessionResult
public func restoreHostTitle(): SessionResult
public func setHostImageIcon(png: Array<UInt8>): SessionResult
public func sessionCleanupResults(): Array<SessionResult>

public enum SessionSupport { Supported | Unsupported | Unknown }
public enum SessionStatus { Applied | SentUnconfirmed | Unsupported | Unknown | Failed }
public enum SessionOperation { CopyLocalText | SetHostTitle | SaveHostTitle | RestoreHostTitle | SetHostImageIcon }
public enum SessionBasis { NoEvidence | ExplicitConfiguration | KnownUnavailable | VerifiedAdapter }
public enum SessionPolicy { Auto | Disabled | DeclaredSupported }
public enum SessionRoute { Direct | TmuxPassthrough | ScreenPassthrough }
public enum TitleRestoreState { NotNeeded | Unavailable | SaveSentUnconfirmed | RestoreSentUnconfirmed | RestoreConfirmed | Failed }
public enum SessionIssue {
    NoIssue | InvalidUtf8 | ForbiddenControl | PayloadTooLarge | WireTooLarge |
    Disabled | NoDevice | NoImageAdapter | NoSavedTitle | InvalidContext |
    SessionInactive | Cancelled | AllocationFailed | WriteFailed |
    ParserUnsynchronized | RestoreUnavailable | UnsupportedRoute
}

public class SessionOptions {
    public init(route!: SessionRoute = SessionRoute.Direct,
        clipboard!: SessionPolicy = SessionPolicy.Auto,
        title!: SessionPolicy = SessionPolicy.Auto,
        titleStack!: SessionPolicy = SessionPolicy.Auto)
}
```

下表精确冻结记录字段；构造器内部可见，字段 `public let`，数组/选项对象深度不可变或返回防御性副本。类型实现均未编译；不能把此表标作运行成功。

| 类型 | 全部公共字段 |
|---|---|
| SessionCapability | `support: SessionSupport`, `basis: SessionBasis`, `reason: SessionIssue`, `route: SessionRoute`, `candidate: String` |
| SessionCapabilities | `sessionId: Int64`, `clipboard: SessionCapability`, `title: SessionCapability`, `titleStack: SessionCapability`, `imageIcon: SessionCapability` |
| SessionStepResult | `operation: SessionOperation`, `status: SessionStatus`, `emittedBytes: Int64`, `issue: SessionIssue` |
| SessionResult | `sessionId: Int64`, `operation: SessionOperation`, `status: SessionStatus`, `capability: SessionCapability`, `emittedBytes: Int64`, `issue: SessionIssue`, `errorByteOffset: Int64`, `restore: TitleRestoreState`, `steps: Array<SessionStepResult>` |

`SessionOptions`四个参数保存在同名内部只读字段，构造后不提供setter。`candidate` 只能是框架常量 `osc52-c`、`osc2`、`xterm-title-stack-window`、`none`，不是用户原始命令。`errorByteOffset` 是源 UTF-8 首个无效/被拒标量的零基 byte offset；不适用为 -1，超限为允许字节数（第一超限字节）。禁止把剪贴板内容、标题或图片字节写进诊断。`emittedBytes` 是此次 API 各步骤实际写入的 wire bytes 合计，非 payload 长度、非宿主消费计数。

普通使用草稿：`let result = app.copyLocalText(selectedText)`；`app.setHostTitle("构建进度")`。不要求先 query capability、不要求程序员发送 ANSI/flush。返回值用于显示“已发送，终端可能拒绝”等状态。后台使用现有 `app.post({ => let result = app.copyLocalText(capturedText); /* 在此消费结果 */ })`；`post` 返回 false 时该 closure 未排队。

### S003 — 自动能力、候选通道和执行结果

每次 run 成功 open 后、挂载回调之前建立本次不可变 snapshot；startHeadless 建立 NoDevice snapshot。首次会话前 `sessionCapabilities=None`，停止后保留最后 snapshot 作诊断，`sessionId` 防跨 run 混淆。能力 getter 可跨线程读防御性快照；它不触发探测或终端写入。`sessionOptions` 仅 inactive 时允许修改，活动时抛现有 `UIException("LifecycleReentry", ...)`；同一 run 的通道/策略不可变。

Auto 的检测是现有设备绑定/是否 TTY、框架已知开关、是否存在已验证 adapter 的自动评估，**不启动进程、不发任何设备 query、不给 TERM/COLORTERM/TMUX/STY 或 terminfo 名称证明权**。这一版本没有能确认真实权限的自动协议；因此真实 TTY 的 clipboard/title/titleStack Auto 均 Unknown/NoEvidence。TERM 信息可以成为外部诊断线索但不改变本表。

| 条件 | capability | 显式操作 |
|---|---|---|
| Auto，真实 TTY，Direct | Unknown/NoEvidence；candidate 固定协议 | copy/title 可尝试，完整发送 SentUnconfirmed；stack Unknown 不发 push/pop |
| Disabled | Unsupported/KnownUnavailable | 零输出 Unsupported/Disabled |
| DeclaredSupported | Supported/ExplicitConfiguration | 表示应用声明，非运行时实测；完整发送仍 SentUnconfirmed |
| headless/无设备 | Unsupported/KnownUnavailable | 零输出 Unsupported/NoDevice；不误开TTY |
| 图片图标（本版任何配置） | Unsupported/KnownUnavailable | 零输出 Unsupported/NoImageAdapter |

Typed mux route 必须由高级 `sessionOptions` 显式选择；选择 route 只是编码目的地，不将 Auto 支持变为 Supported。`titleStack=DeclaredSupported` 是声明完整所选路径支持 window-title 栈，允许尝试一次保存/恢复；用户声明不能消除 host 拒绝风险。所有条件均没有 Applied 回路；VerifiedAdapter/Applied/RestoreConfirmed 为诚实模型保留，**此版本不得由 override、发送数、回显文本、定时器或 host 探针历史生成**。

`Unknown` 执行状态用于没有安全动作的未知恢复（NoSavedTitle/RestoreUnavailable）；它不表示“已经发送但不确定”。忽略 OSC 的终端仍是 SentUnconfirmed，不等待不存在的 ack 或把超时当 Failed。无请求的普通应用不得收到启动 title/clipboard/icon 控制序列。

### S004 — 输入、字节与资源边界

本节上限是框架有界资源政策，**不是实测所有终端能接收的上限**。不提高为宿主兼容性承诺；超出不得截断、分多次覆盖剪贴板或悄悄改编码。

| 内容 | 冻结值/处理 |
|---|---|
| copy 原始文本 | 最多 65,536 UTF-8 bytes；包含 0 字节长度允许，表示显式清空 CLIPBOARD |
| title 原始文本 | 最多 1,024 UTF-8 bytes；空字符串允许 |
| icon 输入 | 最多 1,048,576 bytes；超限 Failed/PayloadTooLarge，其余不解码直接 Unsupported/NoImageAdapter |
| Base64 | 标准 RFC4648 字母表，必需 padding，无换行；长度 `4*ceil(n/3)`，n=65536 时87,384 |
| 总 wire bytes | 每个生成序列含 wrapper 最多 90,000 bytes；全部长度计算先检查溢出，先完整编码再输出 |
| 保存条目 | 每设备会话至多一个 title scope，无用户任意栈深度 |
| 诊断保留 | 最后会话 cleanup 结果最多1项（title）；其他native/UI清理错误沿用异常聚合；不累计每次copy历史；每正常操作steps最多2（save+set） |

首先做生命周期/线程检查，然后检查 UTF-8、长度、title控制字符，再检查能力/路由，最后分配编码和输出；因此 Disabled 的非法 title 仍 Failed/ForbiddenControl，合法 title 才 Unsupported。String 若SDK允许构造非法 UTF-8，拒绝 overlong、surrogate、>U+10FFFF、不完整序列，且零输出；不得通过替换字符“修复”。无需另建 Unicode 分段内核，优先SDK严格解码，实际 API在148消费者冻结前验证。

title 拒绝全部 U+0000–001F、U+007F–009F（含ESC/BEL/NUL/C1/ST/换行/tab）；首个非法 byte offset 保留；其他有效 Unicode 原样UTF-8，不归一化或改变字簇。copy 接受所有有效 Unicode，包括 CR/LF/tab、NUL、ESC/C1，**只作为Base64数据**，不会成为OSC语法；这不改变输入组件/粘贴自己的验证规则。copy不是显示Text的控制规则。

固定直接帧（此处 `ESC`、`BEL` 为单个控制字节）：

- copy：`ESC ] 52 ; c ; <base64> BEL`；空文本严格为`ESC ] 52 ; c ; BEL`，不得发 `?`，selection固定c、不允许选择primary等任意selector。
- title：`ESC ] 2 ; <strict UTF-8> BEL`；不发OSC0或OSC1。
- save/pop：`ESC [ 22 ; 2 t` / `ESC [ 23 ; 2 t`，只窗口标题，不碰icon-name。

长度公式：copy直接长度 `8+4*ceil(n/3)`，title直接长度`5+n`，save/pop各7。同一set API若需save，分别形成两个完整序列；校验和分配两个序列均须在第一字节输出前成功，避免save后编码异常泄漏scope。

### S005 — 有类型的一层 mux 包装

Direct 默认没有额外包装；SSH 只是已绑定TTY连接，不需要产品开SSH连接。tmux/screen普通转发可能生效或拒绝，返回程度不变。

TmuxPassthrough：`ESC P tmux ;` + inner中每个ESC加倍 + ST（精确两字节hex `1B 5C`）；输出长度`n+ESC_count+9`。ScreenPassthrough：`ESC P` + inner + 同一ST两字节；长度`n+4`。inner只来自S004固定生成器，OSC用BEL，无内部ST；不接受任意bytes。一次只能选一层，Options无递归路径输入。不可用该wrapper包装屏幕帧、任意ANSI或输入数据。

只声明实际调查的一层路径/配置可尝试，不自动运行 tmux/screen 命令修改 set-clipboard、set-titles、allow-passthrough；不访问 mux socket。完整路径权限/版本仍可未知。title-stack声明须是所选终点，不能把pane_title恢复冒充外层caption恢复。

### S006 — UI域、顺序、取消与队列

copy/title/restore/icon只在当前 Application 活动会话的 owner UI 域可调用：允许普通事件回调、post closure、外层UI操作和batch内；禁止绑定getter/build/evaluation、mount/cleanup、不同会话active上下文以及后台线程直接调用。错误与已有requireOwner/requireContext语义一致，返回 `Failed/InvalidContext`、零输出；无active会话为`Failed/SessionInactive`，sessionId=0。不通过隐式线程跳转将错误调用变成功。

不新增队列。同步方法在当前UI turn形成完整序列并交给现有唯一writer；帧/模式/扩展序列之间串行，序列中禁止另一输出插入。copy调用不使界面脏，也不改变frame baseline。FIFO、pendingPosts=4096默认、owner NodeRef失效丢弃、turn入口截止与post中新post下一turn完全复用现有runtime。后台捕获字符串为不可变value；不能向callback传借用的临时buffer。

停止发生在第一次native write前：零输出Failed/Cancelled。已开始写则不因stop拆开逻辑帧；按原有EINTR/interrupted规则结束，若中断造成短写，按S008 Failed处理；不承诺“取消就没发生副作用”。已完成写后才观察到stop仍SentUnconfirmed，不改成Cancelled。stop之后未运行post按现有close丢弃，不执行其copy，也不额外回调；排队成功不是复制成功。每次方法同步返回唯一一次结果；用户后台若需完成通知须自己持有状态并处理post false/停止，不能假设被丢弃closure完成。

### S007 — 标题保存/恢复 ledger

title设置支持与titleStack支持独立。默认允许发送title但预先/返回标明`restore=Unavailable`；不读取原标题，不猜默认标题。只有stack Supported（当前仅高级ExplicitConfiguration）才在第一次有效set之前push一次；save写完整只记录SaveSentUnconfirmed，不称保存已确认。

状态流程：无scope → （完整save）拥有scope → 任意数量set → （完整pop）scope释放。set验证/编码失败不push；save失败不set。完整push即产生需要释放的scope，即使后续set零字节失败也需在安全输出条件下pop配平；这属于清理由本会话创建的栈资源。重复set不再push。完整pop只记RestoreSentUnconfirmed、不可再pop；显式restore后下一set可重新建一scope。未创建scope的restore零输出：本会话未尝试过title为Unknown/NoSavedTitle+NotNeeded，曾修改但不能保存为Unknown/RestoreUnavailable+Unavailable。

一次set的status指set动作；steps记录实际save/set动作；例如save完整、set零字节失败返回Failed并保留save步骤SentUnconfirmed，emittedBytes含save。不会因save成功把失败set说成成功。能力Disabled/参数错误不制造cleanup项。没有scope但曾发送title，关闭时保存一项RestoreHostTitle/Unknown/RestoreUnavailable（零bytes），明确无法保证原值。

正常退出、stop/取消、输入失败、可处理回调异常共同执行最多一次pop尝试。只有scope已完整push且输出仍可同步时才尝试；原值不明不发替代标题。标题恢复失败不能跳过dispose余项、termios或signal handler恢复。cleanup结果在close完成后可通过Application读取不可变副本；异常仍按R10主错误+cleanup错误聚合，不能仅因记录结果吞错误。普通Unknown/Unsupported不是异常；恢复I/O失败是cleanup错误。

### S008 — 输出统计、部分写入与R10围栏

`cjt_buffer_write`必须在既有writer里增加此次准确bytes-written结果，不暴露第二writer或应用直接ANSI入口。允许新增私有getter/返回结构，但64位长度/计数不能截断Int32；边界对0、short、EINTR、EAGAIN、allocation、永久失败分别测试。native allocation失败发生在输出前不污染parser；write失败无论零或部分仍使设备会话停止，屏幕baseline不提交。扩展方法先记录首个设备故障并requestStop，再同步返回Failed；本回调其余代码可观察结果，但后续设备请求零输出Cancelled，回到最外层安全UI边界立刻关闭，不等下一次poll。run最终必须抛出首个设备错误，即使用户忽略Failed；UI清理及title/native错误以现有UICleanupException聚合，不覆盖首错。部分失败时result.issue=ParserUnsynchronized、实际步骤issue=WriteFailed；零字节失败result.issue=WriteFailed。参数/Unsupported/Unknown/AllocationFailed在没有设备write前不终止健康会话。

部分OSC/DCS是不可安全恢复的parser状态：立刻停止屏幕/模式/可选控制输出，取消后续post，记录Failed/WriteFailed和ParserUnsynchronized；**不盲发CAN、SUB、ST、BEL、reset或title-pop**。当前实际`cjt_close`只调用tcsetattr/sigaction/free并释放active，不含任何转义输出；扩展后须保持在outputUnsafe时的静默native终止路径，未来光标/alt-screen清理也不得绕过此门。本增量的恢复保证是停止并报告，同时执行非输出的独立资源清理（termios、signal恢复、buffer释放、runtime cleanup）。明确诊断视觉状态/显示模式未获恢复，不能由termios成功推导所有显示模式恢复。不因屏幕看似正常就继续。未来TASK008若新增已独立验证的精确恢复路径，另行冻结后才能替换停止策略；本选择不削减既有正常或已证可恢复失败保证。

为避免同进程重新run把open误当parser同步，native唯一设备拥有者保存`outputUnsafe`闩：发生任何部分write失败后保持到进程终止，后续cjt_open拒绝并诊断ParserUnsynchronized，不因cjt_close清空buffer/active重置该闩。不新增“忽略错误继续”公共开关；零字节write失败可在本run停止并close后重试新run，因为没有注入不完整序列。此闩同样作用于已有屏幕writer的部分失败，避免第二Application绕过。进程重启不构成终端恢复承诺，文档指明先由终端/用户恢复连接。本选择保守且有明确可观察结果，独立preflight必须核对其和TASK008/041后续集成。

R10围栏次序保持：成功native open后马上进入受保护路径；检测、挂载、业务、编码都在其中；停止→停止接受post→dispose全部资源→安全时可选title cleanup→无条件native close→聚合原始与cleanup失败。实现者可按既有close结构安置title项，但不得让UI cleanup异常跨越native close，也不得在native close之后写title。新snapshot在onMount之前准备，但onMount不能发会话操作。不可捕获终止/设备永久失效仍不承诺恢复。

### S009 — 未来cut与输入集成

本变更只交付copyLocalText结果，剪切删除仍由TASK028编辑事务负责。编辑器发起copy前捕获选区、文本版本revision、sessionId和选区身份；返回Applied且**同一编辑对象仍有效、revision与选区身份仍匹配、session未替换**时才在UI域删除捕获选区并生成一条撤销记录。所有其他结果（尤其SentUnconfirmed）默认保留文本/选区，无删除撤销条目；迟到确认不得删除用户随后编辑的文本。

现版OSC不会返回Applied，所以默认cut保留原文并可提示已发送未确认；不得为了“cut看起来能用”把SentUnconfirmed改名Applied。本合同不增加危险的delete-on-unconfirmed默认或暗中内部clipboard兜底。输入粘贴通过既有/后续归一化输入路径，绝不主动OSC52问号；括号粘贴完整内容与快捷键区分仍由TASK041/028验收，030完整AC包含这项集成前不能关闭。

### S010 — 源码职责、替换与依赖

| 文件区域（拟） | 职责/兼容 |
|---|---|
| src/application.cj | 上述公共入口、配置/最近快照、现有run围栏；不新建session |
| src/runtime_session.cj | 在已有owner/context/stop上托管小型session-extension ledger；不改变post FIFO |
| src/session/*.cj + src/exports.cj | S002每类型一文件；根API保持现有消费者写法；纯值层不依赖runtime |
| src/session_encoding.cj | 严格payload预算+固定协议包装；生成器唯一，不复制ANSI/Unicode通用库 |
| src/session_extension_state.cj | 如实体必要，内部ledger一个类一文件；不拥有线程/TTY/输入循环 |
| src/terminal_bridge.cj、native/cjtui_terminal.c | 唯一writer计数/故障闩、native清理，保持现有调用兼容 |
| docs/product/session.md、产品README | 可用签名、结果解释、权限/恢复/默认cut限制；仅正式通过后写为可运行 |
| tests/session_extensions/ | 独立角色148编写的正常CJPM消费者、wire/故障/真实host入口；不是产品依赖 |

必要性：当前Application缺少REQ010入口，native缺部分计数，既有组件Text不能代表设备操作。旧session/runtime/core writer保留并扩展，禁止平行路径。无已发布扩展API要退役；R10既有异常语义必须回归。复杂度增加四项能力快照、最多一scope、一个native安全闩和纯编码，不增加后台队列。Base64优先SDK已提供实现，若SDK无法满足仅允许最小标准Base64编码，不引入shell或复制依赖通用功能；准入阶段做真实SDK/API检查，不留编码选择给实施者猜。

## Risks / Trade-offs

- Unknown 显式尝试可能被终端忽略或输出可见文本 → 调用本身是用户意图；默认无扩展请求无输出；状态永不假报成功，高级Disabled可禁止。
- OSC52与标题没有回执 → Applied不可达、默认cut保留；真实host外部观察是验收证据，不是runtime能力。
- 65,536字节仅资源政策，某host限额更小 → 仍SentUnconfirmed；正式大小边界验证编码而非假定宿主全量接受。
- titleStack显式声明可能不真实 → 记录ExplicitConfiguration与未确认save/pop，不承诺还原标题。
- 中途写失败无法通用重同步 → 停止输出+持久故障闩；尽量非输出清理；不能把未知变成恢复成功。
- 原host调查没有SSH → 151必须建立私有合法SSH链实际产品测试，不能复用本地tmux当SSH；缺环境则AC030相关项insufficient_evidence。
- 当前读取基线仍在演进 → 149等待runtime/主题等共享Application写屏障，151/152只消费固定整合版本。

## Migration Plan

主代理冻结设计及delta，更新docs/tasks为单状态引用；独立preflight检查DQ与S002可实现性；148冻结正式测试与真实RED；149在隔离目录实现；150独立审查固定提交；151独立构建/真实host/故障执行；152逐项验收。主代理仅集成与裁决。失败在对应任务修复，不删原AC、不覆盖原始证据。文档/制品公开入口仅在正常消费者编译通过后更新。无发布动作。

## S011 构造名称兼容

SessionIssue的无问题值最终为NoIssue，不是草稿None。独立交互SDK微验证已证明根包None枚举构造污染既有裸Option None，因此本尚未实现API沿同一源码兼容规则避免冲突，不提供None alias。后续148正常消费者必须同时覆盖现有裸None用法；这一修正不改变任何执行结果/能力语义。
