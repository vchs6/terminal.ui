# 主题与样式正式候选契约

主代理根据独立草稿采用并冻结工程选择；当前尚待独立builder/preflight，不是产品实现通过。第10节为精确裁决，优先于前述方案比较/建议语气；不存在让实现者自行选回落或请求顺序的留白。基线为6a7b240产品与runtime/RichText已冻结前置合同，正式产品实施等它们固定集成。来源：/workspace/work/theme-contract-draft/design-draft.md（原草稿SHA256 a1d72a030e2daaf975714d43ae53dcbefcb8ec069731f4396dea1e2405d6a949），TOML正常包证据R11/build-recon、资源微验证/workspace/work/theme-parser-safety/report.md。所有新签名尚待正式正常CJPM消费者验证，不以已有局部机制冒充API通过。

## 1. 范围、事实与推荐

需求已确定：分类单文件 TOML、变量/命名样式、四套预置、逐属性来源显式 > 复用 > 主题 > 默认、显式复位、状态禁用 > 选中 > 聚焦 > 正常、只有公开文本属性继承、应用主动加载/切换/重载、失败保留旧主题、请求有序、节点与编辑/焦点不重建。没有 CSS、文件 include/extends、脚本、自动监听、主题控制业务状态或网络资源。

现代码事实：`Style` 是八个完整文本绘制属性；`Color`/`BorderStyle`/`Alignment` 已公开。`Component` 的颜色/文本 Bool 是 Option，但 padding/gap/border/min/weight 等已将“未设置”压成具体值，不能直接实现主题级联。`LayoutNode`/`paint` 当前直接读 Component 字段，父的八个文本属性沿 paint 传播，显式背景才填整个盒子。新 runtime R009 提供 typed getter，R014 要求保留唯一 LayoutNode/Frame 路径。主题必须在该路径增加解析值，不能建立第二组件树或把控件变成 renderer 专用 kind。

推荐组合：保留 Style 为最终绘制值；增加 typed 部分声明和一个确定的 resolver；TOML 薄适配只输出同一声明类型；主题快照不可变，在 UI turn 安全边界替换引用。静态配置、程序化复用和组件链式属性全部走同一 resolver。

| 方案 | 适用性与风险 | 建议 |
|---|---|---|
| 修改 Style 为全 Option/带状态 | 破坏 Cell/Frame/ANSI 及现消费者；绘制不应携带“尚未解析”值 | 不选 |
| 给 Theme 增独立解析与绘制对象 | 初期容易，却重复宽度/继承/裁剪和失效规则 | 不选 |
| 保留 Style，typed partial + 单 resolver | 兼容既有绘制 API、可逐属性 reset，也便于富文本共用 | 推荐 |
| 所有主题文件先转自制 JSON/逐行切 TOML | 失去 TOML 语义和位置；重复已解决依赖工作 | 不选 |
| 中心仓 cangjie_toml 0.2.3 + 官方 stdx | 已有正常构建、解析、解包消费者证据；尚需本 schema 的验证 | 推荐，不重复做依赖探针 |

TASK-013 交声明/解析/继承与更新；025 交 schema/诊断；026 交请求/原子提交；027 交四主题完整展示；029 及其他控件只消费统一 role/state/样式，不拥有主题引擎。025 可以独立验证全 schema；本变更同时把全文本wrap/ellipsis接入唯一布局路径；它们不属于TASK008（008是差分失败恢复）。不能只解析字段却不渲染。

## 2. 推荐公开类型与调用形状

以下是精确的 API 形状建议，而非已编译仓颉代码。类型各自单文件，底层值放 `cjtui.style`，主题配置/加载类型放 `cjtui.theme`，Component/Application 方法在根包；根 `exports.cj` 可显式重导出常用类型，实际跨包可见性由最小正常 CJPM 消费者确认。

### 2.1 部分值、键与复用

```cangjie
public enum StyleValue<T> { | Unset | Value(T) | Reset }
public enum VisualState { | Normal | Focused | Selected | Disabled }
public struct VisualStates {
    public let focused: Bool
    public let selected: Bool
    public let disabled: Bool
    public init(focused!: Bool = false, selected!: Bool = false, disabled!: Bool = false)
}
// 无公开构造器，框架发布的 typed singleton；不能以 String 构造任意键。
public class StyleKey<T> { }
public class StyleKeys { /* 第4节每行定义一个 public static let */ }

// 不可变值，with 返回新值；不共享可变 HashMap 给调用者。
public struct StyleRule {
    public init()
    public func with<T>(key: StyleKey<T>, value: StyleValue<T>,
        state!: VisualState = VisualState.Normal): StyleRule
}
public enum StyleUse { | Named(String) | Inline(StyleRule) }
public enum ThemeRole {
    | Generic | Text | Row | Column | Label | Button | Radio | Checkbox
    | Progress | TextInput | TextArea | HorizontalMenu | PopupMenu | MenuItem
    | StatusBar | Modal | SplitPane
}
public enum TextWrap { | None | Grapheme }
public enum TextOverflow { | Clip | Ellipsis }
public enum Dimension { | Auto | Cells(Int64) }

// Component 新增；原已公布常量及 runtime R009 getter 重载不变。
public func setStyle<T>(key: StyleKey<T>, value: StyleValue<T>,
    state!: VisualState = VisualState.Normal): Component
public func setStyle<T>(key: StyleKey<T>, value: () -> StyleValue<T>,
    state!: VisualState = VisualState.Normal): Component
public func styles(value: Array<StyleUse>): Component
public func styles(value: () -> Array<StyleUse>): Component
public func themeRole(value: ThemeRole): Component
public func visualStates(value: VisualStates): Component
public func visualStates(value: () -> VisualStates): Component
```

`StyleKeys` 不是反射机制：`foreground:StyleKey<Color>` 不接受 Bool，padding 不接受 Color；键有不可伪造的内部编号，合法范围仍须在运行时验证。泛型访问器避免给每个属性添加独立 reset/clear/状态的三套方法，原 `.foreground(v)` 等仍是最简正常入口。SDK 尚未实际编译此 generic singleton/with/setStyle 组合；若仓颉不能保持类型安全，实现应改成按具体类型的重载或命名方法，不能退为 `Any`/String 属性袋而冒充 typed。

原 `.foreground(v)` 等同于在 Normal 写 `Value(v)`；最后写入同一 `(key,state)` 替换旧常量/getter与依赖。`setStyle(key, Unset)` 清除此槽并解除 getter，下一来源可接管；Reset 是占位声明并终止回落，值不是 Color.Default 的别名。getter 返回 Unset 不等于删除 getter，下一次依赖变化仍会求值。widthAuto/heightAuto 按 runtime 已冻结契约清除对应 getter与显式宽高槽，恢复来源回落；若要强制 auto，显式 `Value(Dimension.Auto)`；若要忽略主题强制框架 auto，用 Reset。原 `.shadow(...)` 一次写 enabled/offset/八个 shadow 样式的 Normal 槽；原 `.padding(n)` 一次写四边；不得以完整 Style 默认值污染本次未写的其他槽。

`styles` 每次替换整份有序列表，复制数组；空列表清空。Named 必须非空且符合第3节名称规则，绑定求值只运行在 runtime 正常阶段；缺名/非法目标是 `UIException("InvalidProperty", ...)`，不默默删除命名样式。主题提交时候选缺失活动节点当前引用的名称，也应失败保留旧主题，详见第7节。Inline 不属于主题文件，不随主题替换而改变。

role 是单个语义样式标签，只有匹配/默认投影用途，不改变布局、事件、组件身份。Text/Row/Column 工厂设置相应角色，用户组件默认为 Generic；基础控件构造根设置 Button 等角色，允许用户组合组件使用同一公共接口。role 在第一次挂载前可改，挂载后修改拒绝 InvalidProperty，避免主题加载改变组件类别。角色与布局能力分开：Button 不需要新增 renderer kind。容器和文本叶等能力由通用节点结构确定，见4.4。

visualStates 仅传递组件已有状态的外观投影，不执行 focus、select、disable 操作。正常永远参与回落。标准控件由已有的单一状态权威导出此投影：焦点管理器给 focused、控件/业务槽给 selected/disabled；不得维护另一个会反向覆盖业务的选中槽。自定义组件可将自身已有状态绑定该方法。单靠 visualStates(disabled:true) 不禁用事件，公开说明必须明确。

示意（未编译）：

```cangjie
let emphasis = StyleRule()
    .with(StyleKeys.bold, StyleValue<Bool>.Value(true))
Text("Hello")
    .styles([StyleUse.Named("emphasis"), StyleUse.Inline(emphasis)])
    .foreground(Color.Cyan)
    .setStyle(StyleKeys.background, StyleValue<Color>.Reset)
```

### 2.2 不可变主题、同步解析、请求结果

```cangjie
public enum ThemePreset { | Dark | Light | HighContrast | Classic }
public class Theme {
    // 无 public init，无可变表外泄；成功 factory 返回经校验的完整候选。
    public static func preset(value: ThemePreset): Theme
    public static func parse(text: String, sourceName!: String = "<memory>"): Theme
    public static func readFile(path: String): Theme
    public prop name: String { get }
    public prop schemaVersion: Int64 { get }
}
public enum ThemeSource { | Preset(ThemePreset) | File(String) | Prepared(Theme) }
public enum ThemeResult {
    | Applied(UInt64)        // 已提交 revision，非“设备已显示”
    | Failed(ThemeDiagnostic)
    | Superseded(UInt64)     // 淘汰它的较新 request id
    | SessionClosed
}
public class ThemeRequest {
    public prop id: UInt64 { get }
    public func result(): ?ThemeResult   // 任意线程、非阻塞，终态不可改变
}
public class ThemeInfo {
    public prop name: String { get }
    public prop revision: UInt64 { get }
    public prop requestId: UInt64 { get }
    public prop source: ThemeSource { get }
}
// 两个现有 Application init 均追加命名参数：
// theme!: Theme = Theme.preset(ThemePreset.Classic)
public func loadTheme(source: ThemeSource): ThemeRequest
public func reloadTheme(): ThemeRequest
public func themeInfo(): ThemeInfo
```

`parse/readFile` 同步，失败抛 `ThemeException`（带下述 diagnostic），不改变任何应用。可在 Application 初始化前读取文件，然后传入 theme；readFile 所得 Theme 保留本次冻结的绝对来源路径，parse 为内存来源。Prepared(readFile 结果) 初始路径可供 reload；Prepared(parse 结果) 无文件来源。parse 不是把文本当路径。每个 Application 自己拥有活动 Theme 快照与 revision，多个应用可共享不可变 Theme 值但不共享请求计数/活动版本。

loadTheme/reloadTheme 可从任意线程调用，分配请求 id 后立即返回；实际读取/解析在线程任务中完成，提交在目标 Application UI 域。API 不提供阻塞 wait，避免 UI 自己等待自己；应用可在已有事件/post 周期调用 result，首版不添加另一套 Future/callback 调度体系。headless 用现有 snapshot/dispatch/batch 安全边界处理已经完成的提交任务，不暗示 result() 自行驱动 UI。请求结果可供后台逻辑读取；如应用需一次性通知可由任务完成后主动 post，后续增加 callback 也不能改变提交语义。

load/reload 要求活动 session；非活动返回已经终结的 SessionClosed 请求，不启动文件 I/O。主题初始化通过构造参数。dispose 终结全部未完成请求，不把旧 session 任务带到下一次 start。themeInfo 任意线程返回独立快照；未 start 返回初始主题、revision=0、requestId=0。已提交 revision 每次成功递增，即使内容相同；视觉相同可以不生成新帧。request id 生命周期归 Application，不在重启复用；UInt64 耗尽时抛 UIException CapacityExceeded，不回卷。revision 溢出同样失败，保留旧主题。

本 API 有意不承诺 cancel：新请求/关闭 session 已有确定的淘汰行为，首版无必要再加入“取消是否回滚”协议。

## 3. TOML v1 完整语法形状

首版 schema 的根键 **只有** `schema_version,name,variables,text,decoration,spacing,components,styles`。schema_version 必需为 TOML integer 1，name 必需为非空可打印字符串（去空白后不可空，但保存原文本）；其余可省略。空文件不是默认主题。根表缺失可省略，显式空合法 table 等价无声明。根级 extends/include/import、未知键以及已知键拼错均错误。

标识符用于 variable/style 名：ASCII `[A-Za-z_][A-Za-z0-9_-]*`，1–128 字节，大小写敏感，不去空格，不允许点/路径/冒号；TOML 引号不放宽语义名称。name 是展示名，不是标识符或文件路径。字面 key、quoted key、dotted key、inline table、普通 table 只要解析后的树完全相同就语义相同，不另建词法解析器。多行字符串按 TOML 解析，但该字段仍受自身值域约束。

结构定义：

```text
root.text                  = TextProperties
root.decoration            = DecorationProperties
root.spacing               = SpacingProperties
root.variables.<name>      = { type = <ValueType>, value = <literal> }
root.styles.<name>         = Rule
root.components.<role>     = Rule
Rule                       = { text?, decoration?, spacing?, states? }
Rule.states.<state>        = { text?, decoration?, spacing? }
state                      = normal | focused | selected | disabled
```

Rule 的直属 text/decoration/spacing 就是 normal 的简写。为消除重复语义，同一 Rule 中若同一属性在直属分类与 `states.normal` 都定义，报 DuplicateProperty，即使值相等也不接受；不同属性可以分散声明。根级不允许 states；通用状态通过命名样式或各角色声明，首版不新增 CSS 式全组件状态选择器。states 本身是 table，不能是数组或字符串。

role 字面值穷举：`generic,text,row,column,label,button,radio,checkbox,progress,text_input,text_area,horizontal_menu,popup_menu,menu_item,status_bar,modal,split_pane`，分别对应 ThemeRole。不同 role 不互为继承；不存在“button 自动继承 label 规则”。Generic 仅匹配 Generic，不是通配符。

任何属性值都仅有三种形状：

1. 对应类型的 literal（见第4节）。
2. 单成员记录 `{ ref = "variable_name" }`。
3. 单成员记录 `{ reset = true }`。

省略 = Unset。TOML 无 null；`null` 本身是语法错误，`"null"` 只会被按所属 literal 枚举检验，绝不视为空。`{}`、`{reset=false}`、ref空串、ref与reset共存、reset与literal字段混合、任何未知成员均错误。Color 的 `{indexed=...}` 是下述独立 literal 形状，不能带 ref/reset。不可用空串清空颜色/枚举；需要清除声明就删除键，需要强制默认就 reset。false、0、"auto"、"none"、"default" 都是实际 Value，不能当缺省。

变量 type 穷举：`color,bool,cells,offset,dimension,alignment,text_alignment,border,wrap,overflow`。值必须是该类型 literal；禁止 ref、reset、数组套值、变量互相引用。cells 与 offset 即使同为 integer 也不能跨类型引用；alignment 与 text_alignment 即使同为"start"也不同类型。每个属性只能引用表4相同 ValueType，不做字符串转数值、Bool转数值、Float转整数或 Color降级。未使用的变量/命名样式也全部验证，不以“暂时没用”掩盖坏配置。

### 完整形状示例（合法建议配置，尚未产品解析实证）

```toml
schema_version = 1
name = "Example dark"

[variables]
accent = { type = "color", value = "#66CCFF" }
surface = { type = "color", value = "#101820" }
pad = { type = "cells", value = 1 }

[text]
foreground = "#E8EDF2"
background = { ref = "surface" }

[decoration]
border = "none"
shadow_enabled = false

[spacing]
padding_left = 0
padding_right = 0
padding_top = 0
padding_bottom = 0

[styles.emphasis.text]
foreground = { ref = "accent" }
bold = true

[styles.emphasis.states.disabled.text]
bold = { reset = true }

[components.button.decoration]
border = "rounded"

[components.button.spacing]
padding_left = { ref = "pad" }
padding_right = { ref = "pad" }

[components.button.states.focused.text]
underline = true

[components.button.states.selected.text]
inverse = true

[components.button.states.disabled.text]
foreground = "bright-black"
```

## 4. v1 逐属性闭集、默认值、范围与影响

本节穷尽 v1 字段；不在表中者一律未知/不支持，不接受后静默无效。TOML 用 snake_case，typed singleton 用对应 lowerCamelCase。下述 keys 的完整名称就是该 camelCase 版本；文本属性例如 foreground，装饰为 border / borderForeground / shadowForeground，间距为 paddingLeft。重复名称不存在。

### 4.1 文本分类

| TOML字段 / StyleKeys | typed T / ValueType | 框架默认 | 继承 | 失效 |
|---|---|---|---|---|
| foreground | Color / color | Color.Default | 是 | paint |
| background | Color / color | Color.Default | 是 | paint |
| bold,dim,italic,underline,inverse,strikethrough（六个独立键） | Bool / bool | false | 是 | paint |
| align / textAlign | Alignment / text_alignment | Start | 否 | paint；不改变自然尺寸 |
| wrap / textWrap | TextWrap / wrap | None | 否 | measure/layout/paint |
| overflow / textOverflow | TextOverflow / overflow | Clip | 否 | paint；若某后续测量算法需要则连带 measure |

bool 仅 TOML true/false。text_alignment 仅 `start,center,end`，不接受 stretch。wrap 仅 `none,grapheme`；overflow 仅 `clip,ellipsis`。wrap none 保留显式换行；grapheme 按统一字符簇/显示列换行，不拆宽字符，单簇宽于内容区时按既有完整簇裁剪规则，不死循环。ellipsis 每个被水平截断的可见行在最右可用显示列放 U+2026；ASCII 回退用`...`，空间不足取可容纳的点数；预留标记宽度后才选完整源簇，内容区为0不绘制。ellipsis不代表隐藏的后续垂直行数量提示。这些是文本引擎待实现输入，不得在主题适配器重复实现字符算法。

color literal：`default,black,red,green,yellow,blue,magenta,cyan,white,bright-black,bright-red,bright-green,bright-yellow,bright-blue,bright-magenta,bright-cyan,bright-white`；或恰为`#RRGGBB`的6位十六进制字符串（数字大小写均可）；或单成员`{ indexed = N }`，N 为 integer 0..255。颜色名称只认小写；无 #RGB、透明度、CSS名、rgb()、逗号串、alpha。Color.Default 是终端默认通道，不是透明，也不是 Reset。RGB 用 UInt8 构造前验证范围；保留原始值，能力映射留给现有 terminalRenderProfile/ANSI。

### 4.2 装饰分类

| TOML字段 | typed T / ValueType | 框架默认 | 失效 |
|---|---|---|---|
| border | BorderStyle / border | None | None 与有边框切换改布局；其他边框变换 paint |
| border_foreground | Color / color | 本节点最终 foreground | paint |
| shadow_enabled | Bool / bool | false | paint bounds，含旧新范围 |
| shadow_offset_x,shadow_offset_y | Int64 / offset | 1 | paint bounds |
| shadow_foreground,shadow_background | Color / color | Color.Default | paint |
| shadow_bold,shadow_dim,shadow_italic,shadow_underline,shadow_inverse,shadow_strikethrough | Bool / bool | false | paint |

border 仅`none,single,rounded,double,ascii`。所有装饰属性不继承。border_foreground 的框架默认是派生函数“本节点解析后的文本 foreground”，与现代码一致；Reset 会直接选此默认函数，显式`"default"`反而指定终端默认色。shadow八属性形成现有 Style，默认不从文字 style 隐式拷贝。阴影是矩形边界扩展，偏移可为负；不改变布局/命中。字符回退服从运行配置，不允许主题偷偷修改 TerminalCapabilities 或字体。

### 4.3 间距与对齐分类

| TOML字段 / 特殊 typed key名 | typed T / ValueType | 默认 |
|---|---|---|
| width,height | Dimension / dimension | Auto |
| min_width,min_height | Int64 / cells | 0 |
| weight / layoutWeight | Int64 / cells | 0 |
| padding_left,padding_right,padding_top,padding_bottom | Int64 / cells | 0 |
| gap | Int64 / cells | 0 |
| align_items | Alignment / alignment | Start |
| justify_content | Alignment / text_alignment | Start |

全部不继承，改变时 layout/paint。alignment 接受`start,center,end,stretch`；text_alignment不接受stretch。dimension literal 是`"auto"`或非负 TOML integer；无百分比、浮点、px、fr、max_*。尺寸0合法，weight0表示非弹性。横向是显示列、纵向是行，gap 是该容器主轴单位。

cells 合法 0..9223372036854775807；offset 合法 -9223372036854775808..9223372036854775807。整数必须经解析器的整数模型读取，先验证其 signed64 范围再任何转换，绝不 Float 中转；超界不能截断、wrap或clamp。+号/下划线/进制等 TOML 合法写法交上游解析，其数值落同一范围；v1不增加一套主题词法。bool/float/date/time/string数值全部拒绝。公式必须使用已有饱和/checked算术；极端偏移在与可见矩形求交前不能执行会溢出的坐标相加。width与minWidth按既有布局 `max(width,min)` 再实际终端裁剪，不新加两者冲突错误。各节点 weight 合计仍受现布局checked和限制，候选主题导致溢出时提交前失败。

### 4.4 适用目标与无效属性

八个可继承文本绘制属性、四边padding、width/height/min/weight、装饰对全部框架节点合法。textAlign/textWrap/textOverflow 仅对有文本排版能力的叶/公开文字 primitive 生效。gap/alignItems/justifyContent 仅对公开布局容器生效。组合角色 Button/Label 等对其根传来的外观值应通过控件公开构造转给文字 primitive；根本身不拥有文字排版能力时，不假装直接渲染该属性。

根`[text]`中八个绘制属性为根文本默认种子；三个文字排版键作为各文本 primitive 的全局主题默认，不继承。根`[decoration]`与`[spacing]`按目标能力投影到各节点，例如全局gap只投到容器，不是对Text执行非法gap调用。已知组件表若配置其公开角色不支持的属性则 UnsupportedProperty；命名样式无固定目标，但在应用于节点时检查能力，不支持则InvalidProperty。**角色能力矩阵必须与后续控件契约一起冻结**：当前已知Text与Row/Column能给准确矩阵，其余角色本草稿不伪称已经有实现；实现允许组合组件明确转发上述三项文字排版键，禁止默默丢弃。

## 5. 来源、状态、继承、reset的确定算法

对每节点每属性p：

1. 显式来源中按活动 Disabled → Selected → Focused → Normal 取第一个非Unset。
2. 若无，从 styles 最后一个到第一个查；每个样式内部按上述状态顺序。某个后声明样式的normal可以盖过早样式的disabled，因为多个样式后声明优先在前。不要先把所有样式disabled并起来。
3. 若仍无，查本节点 components.<role>，同样按状态序；再查适用于该属性的全局非继承默认（装饰、间距、三个排版键）。这些仍属于主题来源。
4. 八个可继承文本属性：没有自身前三来源时取父已解析的该属性；逻辑根取全局[text]的对应属性，最后取框架默认。非继承属性直接取框架默认。

遇 Value 立即结束。遇 Reset 立即用表4框架默认，不继承、不查较低状态/样式/来源；复位后的具体文本值可以成为后代的继承值。global[text] 中Reset也用框架默认。全部没有声明则8文本默认是Style()，其余为表4。正常总参与，即使disabled/selected/focused都false。

**继承的关键推荐裁决**：根级[text]是全树文本的根种子，不在每个Text上重复注入同样foreground；否则四套完整预置会让`Column{Text(...) }.foreground(Red)`失去原有传播效果。组件自身的主题规则仍能覆盖继承，所以 `components.text.text.foreground=Blue` 将让该Text为蓝，符合“自身来源先于默认继承”。这把继承定位为默认层，不让父显式值凌驾子显式/复用/主题。文档应把此规则写明，不能仅说“类似CSS”。

替代方案为“全局text作用每个节点，父文本仅最后fallback”，更机械但常令自动继承无实际作用；或“父显式来源也算子显式层”，会使父显式盖过子复用/主题，破坏来源直觉。推荐根种子方案，主代理可有据改选，但必须以同一批优先级例子冻结。

最小冲突例（均为待验证契约，不是已通过测试）：

| 声明 | 结果 |
|---|---|
| explicit fg红；named bg蓝；theme fg绿/bg白 | 红前景、蓝背景 |
| explicit normal fg红；theme disabled fg灰 | 即使disabled，前景仍红 |
| selected fg红；focused bg蓝；同时selected+focused | 红前景、蓝背景 |
| 后named normal bold=false；前named disabled bold=true | false |
| explicit disabled fg Reset；explicit normal fg红 | 框架默认fg，不取红 |
| 删除上一Reset键 | 回落显式normal红 |
| 父explicit fg红；子无自身声明；global text fg白 | 子红 |
| 父explicit fg红；子role主题fg蓝 | 子蓝 |
| 父border=Double/padding=3/shadow=true | 子三项均不继承 |

背景必须分开记录“文字单元背景”与“整个盒子填充意图”。继承到 background 不自动令每个子容器填满空白，保留现paint语义。本节点任何来源显式声明 background（Value或Reset）则本节点盒子有填充意图；逻辑根全局[text].background也有。只有继承/纯框架默认者没有额外整盒填充。Color.Default依然是实画终端默认背景，绝非透明。这个来源bit应由resolver生成，不能再用`c.bg!=None`判断，否则主题background对空白区域无效。

## 6. 解析、诊断、路径与边界

```cangjie
public struct ThemeLocation {
    public let line: Int64           // 从1开始
    public let column: Int64         // 从1开始，Unicode rune列
    public let runeStart: Int64      // 从0开始；非UTF-8 byte offset
    public let runeLength: Int64
}
public struct ThemeDiagnostic {
    public let code: String
    public let source: String
    public let keyPath: String
    public let message: String
    public let location: ?ThemeLocation
    public let locationScope: String // "value" | "table" | "document" | "unavailable"
}
public class ThemeException <: Exception {
    public let diagnostic: ThemeDiagnostic
    public init(diagnostic: ThemeDiagnostic)
}
```

错误code闭集建议：ReadFailed、InvalidUtf8、SyntaxError、UnsupportedVersion、MissingRequired、UnknownKey、UnknownRole、UnknownState、UnsupportedProperty、InvalidType、InvalidValue、OutOfRange、InvalidName、DuplicateProperty、UnknownReference、ReferenceTypeMismatch、MissingStyle、InvalidPath、CapacityExceeded、NoFileSource、InvalidCandidate。重复TOML键属于SyntaxError；归一化后的normal重复才DuplicateProperty。错误文本不作为机器分支键；code/keyPath是稳定接口。异步生命周期终态是ThemeResult，不伪造成TOML错误。

首版只保证稳定的**首条错误**，不是全错误聚合：先语法，再schema/version/根必需，再按源码声明顺序检查未知/值域/引用；metadata无法确定顺序的合成错误按完整keyPath字典序。语法错误由上游抛出即停。引用先收集全变量再解引用，允许前向引用；变量不可引用变量，所以没有循环求值图。引用错误位置定位到ref值而非变量声明；无metadata时选最近有位置父table并标scope，否则None+unavailable，绝不伪造line=1 col=1。读取错误source为请求路径，keyPath为空，location=None。

适配器调用已验证的 `cangjie_toml.cangjie_toml.*`/`.parser.*` 与 `stdx.serialization.serialization.*`。Parser.parse/result、keyInfo/orderedKeys/implicitKeys提供模型和位置；位置的start/len是Rune范围，成功keyInfo需withCol处理；这里只沿用已测API，不假定能取得完整键声明区间。严格检查DataModel变体后再deserialize；禁止默认反序列化器吞未知字段。解析器异常统一映射ThemeException，保留原说明作为message的上下文。

readFile/loadTheme(File)接受明确路径字符串：非空、不得有NUL；相对路径在**发请求时**相对于当时进程cwd解析并冻结为绝对路径；reload用上次已提交主题的冻结绝对路径，不受后续cwd变化影响。允许普通OS符号链接与绝对路径，不增加未经要求的沙箱；每次reload重新打开该路径，文件原子替换可生效。`~`、`$HOME`、`${...}`不展开，URI当普通文件名处理；不联网、不找默认文件、不递归扫描、不解释include。诊断保存调用者展示路径和冻结source身份的实现可以分开，至少source应能指认被读取文件。

建议首版资源边界：主题UTF-8最多1MiB、variables最多4096个、styles最多4096个；schema自身深度固定，不允许无限嵌套；达到上限合法，超过返回CapacityExceeded。这是配置资源保护不是业务数据限制，主代理可按需求调整再冻结。文件先有界读取至上限+1再解析，不能先无限读入。parser仍须在深度/恶意嵌套上有界：若上游没有可配深度且实测危险，先记录证据并采用上游支持的修复/最小薄防护，不写第二TOML解析器。本角色未验证该抗极端输入能力，不能把1MiB当栈安全证明。

## 7. 加载顺序、事务边界与运行时集成

推荐 **latest requested wins**，比仅“最新成功请求优先”更能避免旧意图复活：同Application接收每次load/reload时原子分配递增id并更新latestRequested，立即将此前尚未终结请求标为Superseded(newId)。即使新请求最终失败，旧请求也不能后来提交；当前已提交主题继续保留。

| 事件顺序 | 最终主题与结果 |
|---|---|
| A已提交；R1慢，R2快且合法 | R2 Applied；R1 Superseded；最终R2 |
| A已提交；R1慢合法，R2快但非法 | R2 Failed；R1 Superseded；最终仍A |
| R1已Applied后才接收R2，R2失败 | 保留R1；R1终态不改成Superseded |
| R1准备好但尚未UI提交；此时接收R2 | R1必须在提交锁下复核id，不能提交 |
| 关闭session后旧读取结束 | SessionClosed或原已存在Superseded，终态只写一次；不得污染新session |

同步请求发起的“被接收”与UI提交共用短临界区排序：若R1提交锁先取得，R1可提交后再接收R2；若R2接收在先，R1不能提交。不得在锁内读取文件、运行用户getter、回调或布局。每个请求带session nonce。I/O读取失败、类型错误、候选验证失败、UI提交队列拒绝都不替换活动主题。

候选路径：冻结source/id → 有界读取 → 上游TOML解析 → 全schema/引用/范围校验 → 不可变Theme → 投递UI提交 → 对当前真实树验证引用与适用性/候选布局可计算 → 同安全批次交换活动Theme与已准备解析缓存 → 标记受影响节点 → 目标帧生成。候选验证只读当前已稳定的typed显式/复用/状态缓存，不另跑业务getter/build/mount；如运行时在准备期间有变更，则在最后UI域以最新树再检查。候选中的named缺失、对当前节点不适用、合计weight溢出等返回Failed(InvalidCandidate或对应code)。正式修改前必须完成所有可预期失败的准备，不能先改主题再发现解析失败。

提交只替换样式相关值/缓存/版本，业务对象、Component实例、NodeRef/session代际、焦点、selected、编辑内容、滚动状态保持。改间距引起布局移动不等于节点重建。主题不重跑build、不清空控件状态、不变更children序列。继承文本变化向实际受影响子树传播；color/属性只paint，border有无/spacing/dimension/wrap触发布局，shadow使旧新paint bounds失效。缓存key至少包含theme revision、role、visual state、styles列表版本、显式版本、父继承文本版本；不把降级色保存回主题。

整个更新批次/输出目标帧使用同一主题版本；不允许逐节点边画边切主题。render(root,...)保持runtime R004的完整M1参考路径，读取同一次已提交主题；Application.snapshot返回独立Frame。detached全局render默认Classic；若要离线外部主题，可加显式`render(root,width,height,theme!:Theme=...)`命名参数，但不得对活动session调用时覆盖其主题：活动root使用该session主题，额外theme参数若不同必须诊断，避免隐藏改状态。更简洁的首版做法是只允许Application(theme:...).startHeadless/snapshot导出自选主题，暂不加render重载。

ThemeResult.Applied仅表示UI提交完成。随后设备输出失败走既有baseline/restore契约，不能回滚业务或假装主题未接受；在出错前ThemeInfo仍指已提交主题。候选schema失败属于可恢复主题请求失败，不触发runtime普通回调异常导致整session退出。真正内存耗尽/内部不变量失败不伪装成用户主题错误。

后台加载不应为每个连续请求无上限开线程。建议每Application只保留一个执行中读取与一个最新待处理请求：新请求立即淘汰旧结果，但不能假定OS读取可取消；完成旧读取后处理最新项。普通文件解析可短任务池实现，数量有界。若需慢读与新请求并行，固定小并发上限并保留latestRequested校验，不能因仅串行实现就删除乱序用例。提交信箱每Application至多一份最新候选；与runtime现有调度共用唤醒，不能绕过post容量形成无限队列。

reloadTheme在调用瞬间捕获**已提交**主题的文件来源；若当前是Preset或parse内存Theme，则请求终态Failed(NoFileSource)。某个File请求仍在进行时调用reload，不猜测其未提交路径：仍reload当前已提交源。失败File不改变reload目标。成功Preset则清除文件来源。文件内容外部修改本身无任何动作。

## 8. 四主题、组件展示与分阶段适用

四个preset名称固定为 dark/light/high-contrast/classic，对应ThemePreset；初始默认Classic保持终端默认配色且不添加未声明边框/阴影。预置Theme与外部schema模型完全相同，不有隐藏控件特殊分支；建议把随包主题文本嵌入资源/生成常量以便运行无需cwd查文件，同时交付可编辑的等价TOML。资源打包具体方式必须真实CJPM解包消费者验证，不能依赖开发目录路径。

下表为建议配色基线，视觉验证前不可宣传最终可读性已通过：

| preset | root foreground/background | accent / muted | 控件边框 |
|---|---|---|---|
| dark | #E8EDF2 / #101820 | #66CCFF / #8B98A5 | 仅需要边界的控件rounded |
| light | #18212B / #F7F9FC | #005EA8 / #586575 | single或rounded，非机械反色 |
| high-contrast | bright-white / black | bright-yellow / white | double或ASCII适配 |
| classic | default / default | cyan / bright-black | ascii；保持无边框控件默认none |

聚焦推荐underline+可见焦点标记，选中推荐inverse+选中标记，禁用推荐有明确禁用文字/字符提示，dark/light可加dim但不能只靠dim/颜色。字符标记属于公开控件行为（例如焦点`>`、选择`*`、禁用`-`或等价标签），不是theme改变业务text或塞数据。若终端不支持underline/inverse/色，标记仍要可见；标记布局与ASCII回退由029/017/019等控件契约确定，不能仅凭此色表给027通过。

统一展示必须用同一组件树/数据，切换四主题；包含Text/富文本、TextInput/TextArea、Label、水平/弹出菜单、Button、Radio/Checkbox、Progress、StatusBar、SplitPane、Modal，正常/聚焦/选中/禁用及组合、窄屏、仅基本色、ASCII回退、外部好/坏重载与输入焦点保留。027依赖完整控件/覆盖层/滚动，不在此次主题核心通过时提前关闭其AC。029必须证明控件组合通过公共setStyle/styles/themeRole/visualStates使用主题，不读取private主题表、不直接ANSI。


## 9. 富文本草稿的并行接口输入（主代理在本任务期间转达）

后续富文本建议 `TextStylePatch` 使用可选 Color/六个 Bool，表示span未设置或给值。这与本草稿三态 `StyleValue<T>` 的用途不同：span无需theme Reset，不应把它扩成主题声明袋；也不应改动完整的 `Style`。可共用Color/Bool键描述、范围检查和逐属性选值的小函数，避免再实现第二套颜色/继承内核。

推荐合成的精确边界：先对组件每属性取得**带来源标签**的解析结果，保留“是否由该组件显式层决定”；span有值时，仅覆盖该属性的非组件显式来源。于是顺序为组件显式（含Reset） > span patch > 组件复用/主题/继承/默认。不能把span简单merge到最终Style最上层，否则会盖掉组件显式；也不能只传resolved Style丢失来源，再猜哪个值来自显式层。span Unset使用组件解析值；false/Color.Default都是span真实值。span的paint范围只在该span字符单元，不能因span background触发整个组件盒子填充。此补充是与并行richtext草稿的接口建议，尚待主代理统一冻结。

这里“组件显式”只指拥有该span的当前文本组件；从父节点继承来的颜色即使最初由父显式声明，在当前文本节点也必须标为Inherited，span可覆盖它。来源标签用于解释与解析，不是把祖先优先级跨节点搬运。

## 10. 主代理精确裁决（优先于比较/建议）

T001：采用上述typed partial+单resolver、中心仓TOML方案。所有已列v1属性均在本变更真正接入（包括四边padding、grapheme wrap和ellipsis），不能只接受字段不生效。根[text]八绘制属性为逻辑根默认种子，三个文本排版键是静态文字primitive的全局默认；后named的normal可盖前named的disabled；Reset终止回落；背景fill意图单独保留来源bit。四来源/状态/继承/富文本按5/9节表精确执行。

T002：Style仍完整最终绘制值。StyleValue<T>三态是声明，不含布局/渲染线程；StyleRule不可变、以内容比较相等；StyleUse及所有用于属性值的枚举/struct（VisualState/VisualStates/ThemeRole/TextWrap/TextOverflow/Dimension/ThemePreset）提供Equatable<Self>与==。StyleRule也提供Equatable<StyleRule>；StyleValue<T>在T可比较时提供相等。StyleKey<T>不能由应用创建，with/setStyle保持T匹配，禁止Any或字符串属性袋。泛型方法若SDK迫使语法调整先报主代理，以正常公开消费者为准，不用未编译示例宣称支持。内部存储可用已闭集类型的专属槽/安全typed accessor，不用unsafe downcast规避类型检查。

T003：Component.themeRole只改样式标签，挂载后拒改，永远不改布局kind。Text/Label/Button/Radio/Checkbox/MenuItem的首版构造根为文字primitive；Row/Column/HorizontalMenu/PopupMenu/StatusBar/Modal/SplitPane为容器；Progress/TextInput/TextArea为后续受控绘制primitive，只接受通用绘制/尺寸/装饰属性，不接受静态文字wrap/ellipsis/align键。Generic按实际primitive能力。自定义组件选择角色不能使其原primitive突然获得新能力；应用命名样式/组件角色主题时对实际节点验证，不支持则明确失败，禁止悄悄忽略。角色配置静态校验按上述内置矩阵；Generic允许闭集全部键但应用时核实际能力。全局默认只投影到有该能力的primitive，不能因全局gap让Text报错。基础控件尚未交付时，对配置模型的验证不是控件外观已通过；027等全部控件后汇合。

T004：新增便捷成员`Component.wrap(value:TextWrap):Component`/`() -> TextWrap`、`overflow(value:TextOverflow):Component`/`() -> TextOverflow`，只静态Text排版primitive合法，语义同对应StyleKeys值。增加`padding(left!:Int64=0,top!:Int64=0,right!:Int64=0,bottom!:Int64=0):Component`，一次显式写4边；旧padding(Int64/getter)写4边相同值、原签名保留。旧shadow(offsetX/offsetY/style/enabled)仍一次显式写其全部shadow槽，Style()默认值只作用shadow八属性，绝不污染本节点正文Style。四边padding/border尺寸饱和加法和实际clip同原规则。

T005：wrap=Grapheme必须根据实际分配内容宽度测量，增加行数会影响祖先自然高及兄弟位置；不得只在paint换行却保留旧高度。文本width0不产生换行死循环，保留逻辑内容且无绘制；宽1而簇宽2，簇按整簇裁剪但消耗该位置并向前推进，绝不拆簇。显式LF/CRLF仍按硬换行。布局同时处理Row弹性分配/Column可用横向宽/固定与最小尺寸，受实际viewport约束，使用同LayoutNode协商，不建第二文本布局树或无限稳定循环。ellipsis按4.1，统一Unicode宽度/ASCII回退策略，替代文本只影响画面不改逻辑文本/复制值。wrap后只在仍被水平裁剪的行用ellipsis，不能用标记暗指垂直隐藏行。

T006：采用latest-requested-wins和一Application最多一个执行中任务+一个最新待处理请求+一个最新候选信箱；不为每次load无限spawn。新请求在短锁内分配id并淘汰尚未终态旧请求，worker锁外读/parse，UI域提交前重核id/session。预置/Prepared仍经相同UI提交信箱（不做文件IO）；同步Theme.parse/readFile不改变应用。ThemeRequest.result及Application.themeInfo为可跟踪只读查询，可被绑定自动观察结果/版本，后台读不建依赖。不得在属性/结构求值中load/reload改变应用，按既有重入错误拒绝；普通事件/任务可调用。worker完成信箱独立有限，不受post队列满丢失，但不能绕过容量形成无限积压。

T007：ThemeInfo revision和requestId属于Application且跨session不复用；dispose保留已接受主题与历史终态，不把旧worker提交到新session。themeInfo在dispose后可读最后已接受值，下一start沿用其Theme；未start为构造给定theme/revision0/requestId0。reload只捕获当前已接受绝对File源，预置/内存无File则Failed(NoFileSource)，失败请求不能变更reload源。result终态只写一次，Superseded保留第一次淘汰它的较新id，之后更晚请求不改历史终态。不新增cancel/wait/自动监听。

T008：所有可预期候选解析/类型/引用/范围/节点适用性/有效布局值失败均在提交前处理，Failed保留旧theme且session继续。提交前读取已稳定的属性缓存，不重跑用户getter/build/mount。当前树中引用MissingStyle、weight合计溢出、已解析布局非法均拒候选。业务回调/自定义绘制随后抛错仍归runtime异常路径，不宣称能回滚任意用户副作用。设备输出失败不回滚已接受ThemeInfo，按原后端失同步/恢复契约停止并报错。

T009：输入资源固定预算（不是TOML标准上限）：UTF8≤1048576bytes，variables≤4096、styles≤4096；先复用上游public Lexer.nextToken()对同一不可变输入做预算扫描，再调用原Parser，禁止自己数原字符串括号/点。值容器深度≤16、累计有效键路径≤16段、总tokens≤65536、key/table声明总数≤16384、单key段UTF8≤1024bytes。所有预算同时生效，达到合法，超过ThemeDiagnostic CapacityExceeded。真实token处理字符串/quoted-key/注释，绝不复制TOML词法。有效路径须累计当前绝对table prefix+dotted key+嵌套inline上下文，数组/inline进入离开用显式栈保存路径；不能只限制每局部key段数。此guard只计结构/预算，不解码值、不构建第二语义树、不判重复键，Parser仍负责正式TOML语义。

上游资源补证表明约1KiB深inline/dotted即可显著占CPU/RSS，1MiB文件限额不足；公开Lexer全部新增样本≤0.033秒并正确忽略四种字符串/注释内括号，故本最小预检有真实必要性。Budget/lexical Err可能先于Parser完整语法错误返回，此时明示token位置，不承诺不安全超限输入也先跑语法。合法预算内仍按6节语法→schema→类型/引用优先。UTF8非法/文件超限在lexer前失败。不得以后台线程timeout假装能终止无界Parser；不引辅助进程、Shell或新依赖。

T010：完整preset为Dark/Light/HighContrast/Classic，初始Classic保持正文Color.Default/背景Default、无自动边框/阴影，既有Text/Row/Column应用无需主动设主题仍保持原默认像素。Dark根fg=#E8EDF2/bg=#101820/accent=#66CCFF；Light根fg=#182028/bg=#FFFFFF/accent=#005A9C；HighContrast根fg=bright-white/bg=black/accent=bright-yellow；Classic根fg/bg=default/accent=cyan。组件focus至少underline或inverse的非纯颜色提示，selected至少inverse，disabled至少dim（自动降级照既有profile，不修改业务状态）。完整展示须等全部组件后冻结实际布局与截图，不在本轮假闭合027。

内置preset的源码静态TOML常量为权威，Theme.preset共享同parse/schema/resolver；随包`themes/{dark,light,high-contrast,classic}.toml`是可编辑等价配置，正式测试解析并逐属性比较，禁止主题专用renderer特判。库运行不依赖cwd读取这些示例文件；清单include新增/themes保证制品交付，应用load其明确路径才跟随外部文件。预置完整字段/状态设置在测试前冻结文件字节，不让实现者自由挑不同配色掩盖问题。

T011：当前Component原声明字段→presence-aware StyleRule/getter槽为唯一声明权威；Node解析结果缓存可保留旧layout/paint所需标量，但不能再从旧默认字段走第二级联。resolver产完整Style、布局/装饰和来源/fill/explicit属性mask，布局绘制只消费该结果；富文本按explicit mask与span合成。旧paint的临时fg??inherited不再独立解析主题。M1仍同Runtime全参考路径，M2随后按dirty/bounds优化，不影响公开API。

T012：依赖精确固定cangjie_toml0.2.3+官方stdx1.2.0-beta.02.1，hash/布局与普通bundle传递证据见R11/build-recon。实施把实际stdx前置写入产品说明/清单/bin-dependencies，不能隐藏在作者cache或修改上游。正常SDK/CJPM构建、bundle不skip、仅路径依赖的干净解包消费者要真实通过；许可只保留实际归属，用户已裁决不以声明冲突自设阻塞。其他平台仍后续，不让其阻塞Linux。

T013：包依赖必须单向。Alignment迁至cjtui.style/alignment.cj并由根包重导出，原src/alignment.cj定义退役，保持所有现源码消费者的cjtui.Alignment入口，不声称已发布二进制ABI兼容。StyleRule/Key/Keys仅依赖style基础值，Theme纯值/schema/parser仅依赖style/SDK/TOML。ThemeRequest和关联Observable/Runtime的loader在根包各自文件实现，不能让cjtui.theme反向import cjtui。ThemeResult/Source/Info/Diagnostic等纯数据留theme，根包重导出。

StyleKey<T>增加公开只读`name:String`（固定lowerCamelCase键名、无公开构造），StyleRule增加`public func value<T>(key:StyleKey<T>,state!:VisualState=VisualState.Normal):StyleValue<T>`只读查询该指定state原声明，未设置返回Unset；它不自行执行跨来源/状态级联。两项是typed规则可检查性与跨包纯resolver输入，不公开可变表/Any。Root的唯一resolver可用这些纯查询计算结果，无需子包读Component。无效数值的程序化StyleRule.with抛IllegalArgumentException，主题文件则由schema映射ThemeDiagnostic；缺名/不适用节点仍按正文UIException(InvalidProperty)。

候选/绑定结果相等比较必须包含source explicit mask与fill意图，不能只比8字段Style：例如base本为Default，当前文本span为红，新增组件显式foreground(Default)会改变最终画面，虽base颜色数值未变也必须标paint。Inherited来源不当本组件explicit；反之显式Reset必须压过span。preset固定设计输入在fixtures/themes，产品输出解析值逐字段相等而非要求SDK格式化后字节同一；产品可编辑TOML应直接复制设计输入字节，不擅自换值。

T014（独立preflight只读桥/行高修订）：Theme新增纯只读方法`textDefaults():StyleRule`、`decorationDefaults():StyleRule`、`spacingDefaults():StyleRule`、`componentRule(role:ThemeRole):StyleRule`、`namedStyle(name:String):?StyleRule`；缺角色返回空rule，named未找到（含不合法名字）返回None，由Component.styles负责名字/缺失诊断。增加只读`sourcePath:?String`与`sourceName:String`：readFile的path为请求时冻结绝对路径、sourceName同绝对路径；parse的path=None、sourceName为参数（即使看似路径也不作文件来源）；preset path=None、sourceName为`<preset:dark>`等固定slug标签。以上返回不可变值/防别名，root无需反向导入或窥私有map即可resolver/reload。

wrap的自然行高精确规则：分配内容宽度0时，每个硬行仍占1行，包括空硬行；内容全裁剪，不依文字长度新增软行。正宽而单簇宽大于可用宽时，该簇独占一个裁剪视觉行，下个正宽簇另起行；不在末尾额外生成空软行。宽1下`A中B`为A/空/B三行，`中`为一个空视觉行，`中\n`为两行。零宽簇不单独新增软行（仍保留硬行至少1）；显式height/minHeight及祖先可用空间最后按原约束裁剪。Row弹性后按实际分配宽重测相关text高度，Column按分配横向内容宽测；不得凭未约束自然宽直接沿用旧高度。

T015（独立preflight Classic兼容修订）：背景填充区分无fill、根全局种子background fill、节点本地background fill三种来源，不能只记Bool后无条件使用节点最终Style。逻辑根仅因global[text].background获得fill时，使用`Style(background:已解析种子background)`填根分配盒（其余7字段框架默认），不继承根组件显式/复用/role的foreground/inverse/underline等；它是背景底色，不把文本效果扩散到空白。非background的全局seed文本效果仍正常用于实际文字/边框，不自行增加空白效果。

若本节点在显式/复用/本role主题来源声明background Value或Reset，则本地fill优先，按该节点完整最终Style填盒，保持旧`.background(...).inverse(...)`等行为。继承background不自行fill。global seed fill只在可见根按其分配盒/clip绘制，隐藏根不绘制；无额外“Classic renderer”分支。于是Classic文件保留background="default"仍使`Text("x").inverse(true)`宽3仅x反显、其余2格默认，underline同理；Root本地background声明仍可令全盒有该效果。新fill来源/独立fillStyle纳入缓存相等与dirty比较，不覆盖span局部背景。

