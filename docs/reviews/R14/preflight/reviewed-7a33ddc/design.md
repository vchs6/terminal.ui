# ANSI 富文本正式候选契约

状态：主代理基于独立调查`/workspace/work/text-contract-audit/draft.md`采用并精确化，尚待独立builder/preflight准入。产品API均未实施，不能据此声称通过。产品基线6a7b240；运行时A+B正在独立实施，集成消费者必须等其固定输入。

## 1. 范围与路线

需求REQ001.4、REQ005.1–.4、TASK009。一个typed内容路径：String/RichText→整篇字符簇/样式→现LayoutNode/Frame→现后端；ANSI只是显式输入适配，绝不直接透传。Text(String)及Frame.put(String)保持严格纯文本行为。

直接借用ansies.StyledText不可行：片段私有且无结构化解析，先生成ANSI再解析会形成重复规则。新完整终端模拟器超范围。采用有界框定/SGR白名单薄适配，框定后调用已验`ansies.core.parseCSIParams(...,terms:"m")`；不复制Unicode表/分段/宽度/现有编码。

## 2. 精确公共值接口

均根包cjtui公开重导出，实体每文件一个；文本实体置cjtui.text，样式patch置cjtui.style。cjtui.text只依赖style/Unicode/SDK/ansies，不反向import根包。公开cjtui.text.validatePlainText(value:String):Unit并在根包重导出，语义/IllegalArgumentException与现validateText完全相同；唯一实现下沉src/text/validation.cj，根原validateText只委托。RichText、Frame、组件共享此验证，不增第二实现或公开可变内部状态。

```cangjie
public struct TextStylePatch <: Equatable<TextStylePatch> {
    public let foreground: ?Color
    public let background: ?Color
    public let bold: ?Bool
    public let dim: ?Bool
    public let italic: ?Bool
    public let underline: ?Bool
    public let inverse: ?Bool
    public let strikethrough: ?Bool
    public init(foreground!: ?Color = None, background!: ?Color = None,
        bold!: ?Bool = None, dim!: ?Bool = None, italic!: ?Bool = None,
        underline!: ?Bool = None, inverse!: ?Bool = None, strikethrough!: ?Bool = None)
    public func resolve(base: Style): Style
    public operator func ==(other: TextStylePatch): Bool
}
public struct TextSpan <: Equatable<TextSpan> {
    public let text: String
    public let style: TextStylePatch
    public init(text: String, style!: TextStylePatch = TextStylePatch())
    public operator func ==(other: TextSpan): Bool
}
public class RichText <: Equatable<RichText> {
    public init(value: String)
    public init(spans: Array<TextSpan>)
    public prop spans: Array<TextSpan> { get }
    public func toPlainText(): String
    public operator func ==(other: RichText): Bool
}
public func Text(value: RichText): Component
public func Text(value: () -> RichText): Component
```

现有Component新增成员（不是顶层text函数），非Text和UI域限制同runtime R009：

```cangjie
public func text(value: RichText): Component
public func text(value: () -> RichText): Component
```

现有Frame新增成员（不是顶层put函数）：

```cangjie
public func put(x: Int64, y: Int64, value: RichText, style!: Style = Style()): Unit
```

patch None=未设置，Some(Color.Default)/Some(false)=显式值，非主题Reset。resolve逐字段patch值优先base。TextSpan为惰性数据片段，不自行分段或单独执行换行合法性检查；RichText拷贝spans并按拼接全文调用唯一validatePlainText，允许跨span的CR+LF，禁止任何其他非法控制。空span消除，邻接相同patch合并，故RichText等价比较为规范化span序列（不是忽略样式比较纯文字）。String构造等价一个无patch span；spans getter返回副本，改输入/返回数组不改变RichText。

## 3. 样式、字符簇和绘制

整篇可见字符串一次调用唯一graphemeClusters，绝不各span断簇；一簇取其第一个scalar的patch。跨span组合音标、ZWJ、旗帜、CRLF不拆。无自动NFC/NFD，不改字符/空格、不加装饰。

高层逐字段优先：组件显式链值 > span patch > 组件复用/主题/继承基础值。组件foreground可统一覆盖ANSI已有前景；只改该字段，其他span属性保留。低层Frame.put的style是base，span覆盖base。复用与主题未来仍通过同一基础Style输入，不建富文本专用级联。最终Cell仍只有完整Style与原字符簇。Text绑定替换取消旧String/RichText getter订阅；相同规范值不生成新目标帧；仅span样式变化标paint，文字/换行变化标layout。

Frame.put(RichText)在任何写入前验证全值，通过同一Frame内部整簇写入/宽簇清除/裁剪，不用逐run的put拼画面。高低层在对应基础样式下同结果；原String的换行/零宽/越界规则不改。完整快照自然消费结果Frame，源ANSI不会重解释或复用为输出字节。

## 4. Decoder精确接口

```cangjie
public class AnsiTextLimits {
    public let maxSequenceBytes: Int64
    public let maxParameters: Int64
    public init(maxSequenceBytes!: Int64 = 4096, maxParameters!: Int64 = 64)
}
public enum AnsiTextIssue <: Equatable<AnsiTextIssue> {
    UnsupportedSequence | MalformedSequence | SequenceTooLong | IncompleteSequence
    public operator func ==(other: AnsiTextIssue): Bool
}
public class AnsiTextDiagnostic {
    public let kind: AnsiTextIssue
    public let offset: Int64
}
public class AnsiTextBatch {
    public prop spans: Array<TextSpan> { get }
    public prop diagnostics: Array<AnsiTextDiagnostic> { get }
}
public class AnsiTextResult {
    public let text: RichText
    public prop diagnostics: Array<AnsiTextDiagnostic> { get }
}
public class AnsiTextException <: Exception {
    public let code: String
    public init(code: String, message: String)
}
public class AnsiTextDecoder {
    public init(limits!: AnsiTextLimits = AnsiTextLimits())
    public func feed(chunk: Array<UInt8>): AnsiTextBatch
    public func finish(): AnsiTextBatch
}
public func parseAnsiText(value: String, limits!: AnsiTextLimits = AnsiTextLimits()): AnsiTextResult
```

Batch/Result/Diagnostic无公开构造，由decoder产生；数组均防别名修改。单decoder单调用线程拥有，非线程安全；无线程/日志/设备/组件依赖。feed可任意大，返回安全spans/本批逐事件diagnostics，不存全文或过去issue。finish消费残留、返回末批并关闭；此后feed/finish抛AnsiTextException(code:"DecoderClosed")。无reset；新文本用新decoder。parseAnsiText共享decoder逻辑、合并全部batch为不可变RichText，不自行解析第二遍。

limits正数且maxSequenceBytes≤1048576、maxParameters≤4096，违反抛IllegalArgumentException。所有CSI参数区连续十进制digit-run最多3digits（包括最终非m的CSI），第四digit到达即SequenceTooLong；所有计数/offset防Int64溢出，输入累计offset无法表示时fail-close抛AnsiTextException(code:"InputTooLarge")。资源上限是状态限制，不是业务全文大小。maxSequenceBytes按原始输入byte计，包含实际introducer和终止符：rawC1计1byte、UTF8C1计2bytes、ESC[计2bytes，不按规范7bit后的长度。maxParameters适用于全部CSI，按分号分隔字段数计（含空字段及38/48操作数），超出的第一个分号到达即判超限，不等待final确定是否SGR；ESC[m计一个隐式0。未知final不能覆盖先前资源首错。例ESC[1234在第四digit即TooLong，无论后续K或m；其余完整未知CSI仍Unsupported。

offset为从decoder第一个输入byte开始0基绝对位置，sequence问题指introducer首byte；孤立控制指该控制首byte。对所有feed及finish成功完成的同一完整流，不同分块归一化后内容/样式/issue(kind,offset)等价，允许batch run切分不同。异常流要求相同错误code与永久关闭，但之前成功batch已交付前缀可因分块不同，不承诺前缀等价或回滚（如A后非法byte整块失败不交付A，拆块可能先交付A）。无需回显原始设备payload。

## 5. ANSI支持矩阵

唯一执行效果是样式。完整7bit ESC[或scalar边界C1 CSI（raw9B或UTF8 U+009B）规范为7bit后，仅无private/intermediate、十进制与分号参数、final m，才调用ansies参数拆分。先检查/映射整条，再原子更新patch，未知/畸形不应用任何前半段。

| SGR | 结果 |
| --- | --- |
| 无参数、顶层空字段、0 | 全8字段显式Default/false；不是None |
| 1/2/3/4/7/9 | bold/dim/italic/underline/inverse/strikethrough=true |
| 22 | bold=false且dim=false |
| 23/24/27/29 | 对应false |
| 30–37/90–97，40–47/100–107 | 前景/背景16色 |
| 39/49 | 对应Color.Default |
| 38;5;n / 48;5;n | Indexed，n0–255 |
| 38;2;r;g;b / 48;2;r;g;b | Rgb，通道0–255 |

初始patch全None。颜色保留typed原值，只有现profile输出时自动降级。未知SGR/colon/private/intermediate完整序列=UnsupportedSequence，整条丢弃。38/48消费的mode/通道必须非空十进制（顶层空字段默认0不适用于这些操作数）；RGB/Indexed缺参数/空操作数/非法通道/非十进制=MalformedSequence；合法但不支持38/48模式=UnsupportedSequence。未知final的完整CSI=UnsupportedSequence。超过参数数目或byte/token资源上限=SequenceTooLong。同一byte既资源又语法故障先判资源；SGR完整语义映射按参数从左到右第一个失败确定kind，整条不部分应用。每序列首个语法/资源问题立即报一次，后取消或再次超限不重复该序列问题，闭合后也不另报Unsupported；finish仍未闭合可追加IncompleteSequence。完整未知而未有首错的序列在闭合时报UnsupportedSequence。

## 6. 安全边界与流状态

有效UTF8原文直接交spans，允许LF/CRLF；跨feed CR保留1byte待LF，孤立CR、HT、BS、BEL、其他C0/DEL/C1丢弃+UnsupportedSequence。任何错误不转换成可执行设备操作。未知完整ESC序列按ESC intermediate20–2F/final30–7E框定后丢弃，非合法顺序MalformedSequence；不改变字符集。

CSI采用参数30–3F、intermediate20–2F、final40–7E边界，非法排序/控制记MalformedSequence后drain至final。非控制串中遇新ESC取消当前残留（未报过首错才报MalformedSequence，已有语法/资源首错则不重复），从新ESC开始；绝不漏出剩余数字/final为正文。CUP/ED/EL/DECSET/DSR均不执行。

OSC由BEL或ST结束；DCS/SOS/PM/APC只有ST结束，BEL不能释放payload。ST包括ESC反斜杠和scalar边界raw9C/UTF8 U+009C。控制串payload永不缓存；遇超限只报一次SequenceTooLong并隔离到其合法终止符，不能回normal让后半串变正文。内部ESC非ST、CAN/SUB、嵌套CSI都继续隔离，不应用任何样式。完整未超限串报一次UnsupportedSequence；超限串不再报unsupported。finish未闭合报IncompleteSequence，丢弃全部残留。

UTF8有至多3尾bytes，合法scalar用SDK String.fromUtf8检查；无pending UTF8时才识别rawC1。合法多字节里的80–9F continuation永远是该字符数据（如D2 9B不是CSI）。UTF8编码C1按同control规则，跨块等价。控制串内也识别scalar边界以免把continuation9C误当结束，不需要存payload。非法UTF8/finish不完整UTF8抛AnsiTextException(code:"InvalidUtf8")并永久关闭decoder，本次batch不交付，之前已交付batch不回滚；一次parse整体失败无可用Result。不得unsafe造String或把非法byte重解释为控制后的正文。

decoder保留状态O(maxSequenceBytes+maxParameters+常数)，不留无限控制payload/诊断。输出/诊断batch内存O本次输入；后续feed不持有调用者chunk/batch。饱和计数只用于已超限隔离，不能整数回绕。

## 7. 兼容、职责与退出

Frame/Style/Unicode/ansies唯一规则不变；TextStylePatch是未解析内容覆盖，Style仍最终绘制值。后续theme的Unset/Value/Reset与本patch None/Value不是同一语义，不强迫span携带主题Reset，但逐字段解析复用。Component/LayoutNode仅增加typed内容/getter，不另建富文本渲染器。替换旧String内部表示允许统一为RichText单span，但公开签名、严格控制拒绝、所有旧断言/字节保留。

TASK009 parser完成不能提前关闭010可见层导出、008安全写失败或全部Linux。产品源码不运行Shell、不输出OSC/任意ANSI，不依赖开发probe。输入外部bytes不信任，限制/隔离/错误必须由独立golden验证，正常渲染程序员不手工处理终端降级。
