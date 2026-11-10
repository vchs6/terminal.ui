# Linux VT glyph adaptation design — freeze candidate

## G001 范围、事实和准入

本设计采用主代理裁决A：保守整簇等宽ASCII。参考核心固定19b620f206e37be42ef387020ee8b441b27246f3；接口接线只读参考0912436b647f701e1de607fe03ce1bfba6a9bbf4。实施者在080/084最终固定源集成后复核路径，不读取作者推理替代合同。LinuxVT真实map原件、NFC反证和hash见本调查raw/sourcehash。当前无可用字素NFC：不实现、不硬编码、不扩大依赖调查。用户前置是支持UTF-8的文本终端；本增量不查询/更改console解码模式，不以键盘KDGKBMODE声称输出UTF8已证实。

不新增GUI、fontconfig、fontload、字体家族/字号API，不翻译中文、不复制Unicode数据或分段/宽度算法，不另造Frame/布局树/ANSI内核。本子增量成功不关闭完整041。

## G002 最小公共API（精确签名）

`GlyphMode`定义于`src/style/glyph_mode.cj`，package `cjtui.style`，由根`cjtui`统一reexport，与ColorMode同向依赖。它实现`Equatable<GlyphMode>`，三个值：

```cangjie
public enum GlyphMode <: Equatable<GlyphMode> {
    | Auto | Unicode | Ascii
    public operator func ==(other: GlyphMode): Bool
}
```

`TerminalGlyphCapabilities`定义于根`cjtui`，各字段只读、构造包内：

```cangjie
public struct TerminalGlyphCapabilities {
    public let nativeVt: Bool
    public let mapKnown: Bool
    public let entryCount: Int64
    public let source: String
    public let reason: String
    public let nativeError: Int64
}
```

`nativeVt=true`表示实际stdout已确证具体Linux文本VT；false不等于证明是某种模拟器。`mapKnown=true`仅说明完整有界BMP映射读取成功，绝不说明精准glyph/非BMP/组合能力。entryCount成功为0..65535（原pair数，允许重复unicode）；失败0。nativeError为原errno，非syscall失败为0。该snapshot不公开bitmap，不因override改写检测事实。

在现有两个Application构造上**各追加**同一个可选命名参数，保留其余所有签名/默认值；不是新增构造家族：

```cangjie
public init(root: Component, limits!: RuntimeLimits = RuntimeLimits(),
    glyphMode!: GlyphMode = GlyphMode.Auto)
public init(root: Component, colorMode!: ColorMode, limits!: RuntimeLimits = RuntimeLimits(),
    glyphMode!: GlyphMode = GlyphMode.Auto)
public func glyphMode(value: GlyphMode): Application
public func glyphMode(): GlyphMode
public func terminalGlyphCapabilities(): ?TerminalGlyphCapabilities
public func snapshot(width: Int64, height: Int64,
    glyphMode!: GlyphMode = GlyphMode.Unicode): Frame
public func render(root: Component, width: Int64, height: Int64,
    glyphMode!: GlyphMode = GlyphMode.Unicode): Frame
```

上列render为现有顶层函数，其他方法归Application。后续theme085合同给两个init追加的`theme!`参数原样合并，不能因列出本草稿形状移除/重命名/改变该theme参数；没有第三个init、没有新公共policy类型、没有Frame导出mode API要求。

正常`Application(root)`零配置；强制Unicode/Ascii是高级选择。setter返回this；getter返回所选值（包括Auto），不是自动解析后的模式；`glyphMode(Auto)`即恢复自动，不另加glyphModeAuto方法。diagnostics与R10一样：首次成功会话探测前None，之后保留最近一次只读原始探测snapshot；startHeadless、render、snapshot不触发探测，不污染last值。固定snapshot只描述能力，不持有活fd。

setter与现颜色配置同一同步/调用约定：启动前或现UI执行域调用，可在现事件/post中变更；不新建异步setter/后台信箱或等待协议，不扩大现colorMode跨线程承诺。活动会话变更即记录当前配置并标记**输出profile重评估+布局缓存失效**（同值无动作），在下一安全刷新边界生效；不能只改mode字段却让needsWork为false。锁只保护短状态，不在锁内调用布局/用户回调。headless离线布局由snapshot参数决定，Application设备配置改变不能偷偷影响其默认Unicode语义。

上述命名参数、重载、getter/setter与enum相等运算已在SDK1.2.0 shape-only stub项目正常编译运行；见api-probe与raw/api-*.log。只证明签名语言可行，不证明cjtui产品集成/运行已实现；实际跨包可见性仍由093/094正常包消费者核验。

## G003 模式语义与诊断

| 请求/上下文 | 有效策略 |
|---|---|
| 设备Unicode | 原Unicode簇输出；不宣称设备实际支持每glyph；检测仍按run生命周期执行并记录 |
| 设备Ascii | 原始可打印ASCII单列原样，其余整簇ASCII回退；生成标记按ASCII |
| 设备Auto，已证实具体文本VT且map成功 | 单BMP、单列、可打印且mapped候选可原样；其它整簇ASCII；生成标记通过同候选判断 |
| 设备Auto，已证实具体文本VT、map失败 | 保守Ascii；diagnostic保留失败 |
| 设备Auto，未知PTY/其它宿主/身份未确证 | Unicode透出，coverage unknown；不能凭TERM报支持 |
| 离线snapshot/render Unicode或Auto | Unicode生成策略，不探测/引用任何设备/最近run能力；Auto确定等同Unicode |
| 离线snapshot/render Ascii | ASCII生成策略；原始文本/逻辑Frame仍Unicode，不是“所有原文字节变ASCII”的导出器 |

source取值闭集：`linux-vt-unimap`（nativeVt=true,mapKnown=true）、`linux-vt-unavailable`（nativeVt=true,mapKnown=false）、`unknown`。成功且备用字符可用时reason空；map成功但`?`不可映射时reason=`ascii-fallback-unavailable`（mapKnown仍true、nativeError=0）；其他失败reason闭集：`not-tty`、`not-concrete-linux-vt`、`vt-query-failed`、`not-text-mode`、`map-query-failed`、`map-allocation-failed`、`map-invalid`、`unsupported-platform`。只有完整验证VT文本模式后nativeVt才true；此前失败留unknown，不猜测。ASCII基础字符在map不可读时属基础字符终端约定，不能记录为逐字已证。当前字形source/reason不得塞入已有颜色source/reason改变其语义。

## G004 原生实际fd只读探测

每次run成功open后在既有cleanup围栏内检测一次（与R10同生命周期）；Unicode/Ascii override不跳过事实记录。所有分支无terminal控制输出、不fatal、不提权。用**实际STDOUT fd**的fstat/isatty、major4/minor1..63、VT_GETMODE和KDGETMODE==KD_TEXT确证具体VT，不能用stdin或TERM替代。具体设备判据未满足（包括/dev/tty、/dev/tty0、/dev/console别名）保守unknown；不打开另一个控制台探测。

GIO_UNIMAP使用同fd、最大65535个unipair一次分配一次读取，临时上界262140bytes；成功复制为8192bytes BMP bitmap后释放临时表。所有长度核对在使用前完成；成功0条代表known空map。bitmap本次会话不可变，无第二全局native缓存、不按cell做ioctl。errno/分配/权限/无VT失败形成上述诊断，不循环扩容/重试。产品只使用读取ioctl；不读取屏幕vcs设备、不调用PIO/KDSET、不扫描字体系统。

GIO_UNIMAP的unicode是u16，不能表示非BMP。mapped可存在别名（原始证据À→A、ã→a）；只说有内核槽位映射，不宣称视觉精准/像素非空/shaping。fontmap不证明console当前UTF8解码开关；沿G001既有支持前置。不自动监控外部改字体；下次run重探，当前会话snapshot限制写产品文档。

## G005 单一投影与装饰回退

内部只增加一个不可变`GlyphRenderPolicy`（包内，一类型一文件）：解析后的Unicode/Ascii/LinuxVtMapped三种策略及可选有界bitmap。命名可由实现沿现风格细化，但不得增加公共policy家族。TerminalRenderProfile含该policy；Application仅解析一次请求→策略，Frame和布局生成标记消费同一值。

生产用纯函数边界（包内，可由同package单测合法调用）：

```cangjie
func projectTerminalGlyph(grapheme: String, width: Int64,
    policy: GlyphRenderPolicy): String
func generatedEllipsis(policy: GlyphRenderPolicy, availableColumns: Int64,
    ambiguousWide!: Bool = false): String
```

这些函数用于实际编码/未来唯一文本布局，不是专属测试入口。bitmap的生产构造只验证8192长度并冻结副本；测试可按同生产值构造合成coverage，不靠公开测试setter、环境变量、全局注入或伪造TerminalGlyphCapabilities。包内测试由正常cjpm test支持的同package测试文件调用；可从tests/glyphs脚本在独立临时副本编译生产源加同包测试，不改产品可见性/主仓接口、无修改源码hook。

projectTerminalGlyph消费现起始Cell.grapheme和Cell.width，不重分段/计算布局。Unicode原样；Ascii只放行单可打印ASCII且width1；mapped策略只放行单可打印BMP、width1、有map条目。所有其他正宽簇输出恰好width个`?`，w2→`??`；零宽簇沿当前Frame.put被跳过，不新增列。续格不另输出，替代在原簇单位一次产生，保留现宽簇覆盖/裁剪/组合不变量。

装饰符号回退复用现borderClipped的角/横/竖与Ascii对应数据，统一抽取其小型装饰组作为生产数据源；不造全Unicode替换字表，不增加Frame用途tag。各单列角→`+`、横→现Ascii横`-`、竖→`|`，现未定义专用fallback的shadow等用通用占位。字面业务中同码点使用相同映射，不推断业务含义。成功map中备用字符也应mapped；`?`缺失时按空格保持列并在诊断产品说明记录fallback不可见，不宣称字形完整。边框fallback字符缺失先用通用`?`，再空格；不增加无限fallback链。

组合、多码点emoji/VS/ZWJ不因所有成员有map就放行；整个簇走占位。单BMP预组合é mapped且单列可输出；e+acute默认`?`，不删重音、不做NFC。宽簇即使BMP map有条目也不以font槽位证明设备推进w列，保守等宽ASCII。

## G006 生成省略号与低层投影严格分工

`generatedEllipsis`选择**布局前**的生成标记：Unicode策略且`displayWidth("…", ambiguousWide: ambiguousWide)==1`时选`…`；mapped策略还需…为mapped单列候选；其余选ASCII `...`。调用者必须传入该次布局/Frame使用的实际ambiguousWide，不能以函数默认false替代会话true；policy只持字形证据，不复制Unicode宽度。当前runtime若只支持false即明确传false，不为本增量新增公共宽度模式。availableColumns<=0返回空；ASCII候选在1/2/3+可用列分别返回`.`/`..`/`...`。宽度仍调用现displayWidth，无第二宽度规则。它不消费/截断业务原文，不决定前缀，也不调用layout/Frame/terminal探测。

Theme013现唯一文本布局在分配内容宽得到后，把现同一文本/Frame宽度策略ambiguousWide显式传入该函数，先按标记现displayWidth预留列，再选择完整原簇前缀，最后一次排版；不得先用一列`…`布局，设备编码时换成三列`...`。比如截断ASCII源`abcdef`，可用5列：Unicode为`abcd…`，Ascii为`ab...`；可用2列分别`a…`与`..`，可用1列分别`…`与`.`，0列不绘制。上述Unicode例子以ambiguousWide=false为前提；ambiguousWide=true时U2026按现依赖为2列，Unicode/Auto也回ASCII点串（可用5列截断同样`ab...`，2列`..`、1列`.`），与theme“统一Unicode宽度/ASCII回退、先预留标记”的现承诺相容，不把两列U2026硬塞一列。无截断时不加标记；仍不为垂直隐藏行加标记，wrap/样式和裁剪契约保持theme085设计。

**文字原文中的U2026**不属于生成标记：Frame.put("…")的w1缺字只可投影`?`，绝不能变为3列。由此generated/layout改变的是框架构造的显示文本选择，低层projection始终维持既定w。

本增量在093–097只交上述真实生产用policy/marker函数和render/snapshot上下文/缓存接线；当前产品尚无TextOverflow，不能新增/修改085冻结TextOverflow/Component API抢先实现ellipsis。Theme013消费本接口完成前缀预算、重排与实际绘制，085追加Ascii/Auto场景（保留原Unicodegolden），088验收完整ellipsis。本函数不是空stub，策略结果由内部纯函数用例独立可验；设备文字与边框投影在094本身即有真实可验价值。097不能据marker函数单测声称完整ellipsis排版通过。

## G007 布局上下文、缓存、无循环依赖

数据方向唯一：Application请求+只读探测→内部policy→RuntimeSession.produce/现renderLayout与Frame终端profile。文本布局消费纯marker函数；函数不导入Runtime、Application或native。类型置根cjtui或既有style叶包的单向层次；不能让cjtui.text回导根cjtui，也不能为跨包可见性公开可变bitmap。

设备run使用内部`produce`/设备snapshot路径传入已解析policy；**不得调用新增默认Unicode的公开snapshot导致丢失设备策略**。公开snapshot/render显式参数在入口解析为离线policy，Auto==Unicode，绝不读取lastCapabilities。两者仍使用同produce/renderLayout，不建第二snapshot内核。headless与run不能同时独立启动同一活动session，沿既有生命周期。

RuntimeSession缓存键在现width/height/dirty之外加入影响生成标记的policy值（至少marker选择结果；比较内容而非仅对象identity）。交替offlineUnicode/deviceAscii或snapshotAscii时不得重用错误cached Frame；每次调用结果是对应policy下的逻辑Frame。无需持久保存两套Frame；可替换现单个缓存。GlyphMode setter同时使profile与布局失效；即使有效marker相同也可保守重排，但不可见结果相同仍零终端字节。用户节点/绑定/焦点/编辑原文身份不重建，模式只影响现布局/输出。

## G008 差分与输出成功边界

相同尺寸时比较新logicalFrame+新profile与旧成功logicalFrame+旧profile的**设备投影结果**；删去当前raw grapheme/width/continuation直接判行changed的分支。可复用同一canonical encodedRowForTerminal比较临时row String；样式投影/有效run合并一致。不是再建terminal Frame或另一个持久屏幕缓冲。

`中→文`、`中→??`在同样style且都投影两列`??`时零屏幕更新；raw簇结构不同不能误报。mode/profile变更也只在投影结果不同才更新；profile未变且raw相等可优化跳过。新旧必须各用自己profile。纯逻辑颜色变化也沿现style投影比较。宽簇→短ASCII、文本缩短仍以完整逻辑行输出清残留，不遗续格。

循环wake判据包括glyph配置/有效layout policy变化，不能只有color mode。输出完整成功才提交logicalFrame+完整profile；失败/部分输出沿现停止/恢复边界，不提交placeholder Frame。尺寸变化沿现完整重绘。不得为glyph变更改变已验颜色属性/NCV、控制安全或R10纯快照语义。

## G009 离线导出、兼容与验收边界

Frame.toPlainText/writePlainText/toAnsi/writeAnsi不新增必需参数，不查询设备，不应用terminal glyph policy，默认logical Unicode；ANSI保留现默认颜色属性。`snapshot(...glyphMode:Ascii)`仅让**框架生成标记**按Ascii语义选择，返回Frame中的业务Unicode不替换；导出该Frame自然包含调用者明确要求的生成点号。应用设备Ascii设置不暗改默认snapshot的Unicode省略号。说明设备画面与默认离线快照可不同；想对齐生成标记须显式snapshot/render Ascii，但仍不是全ASCII转码/翻译工具。

旧无参数Application/render/snapshot消费者继续编译、默认未知模拟器画面保持；knownVT的自动显示由本需求改善。Theme085冻结API/fixtures不改；新增模式场景是追加验收而非降低现断言。无用户持久数据迁移。

本增量覆盖原AC041中glyph子接口、真实fd探测/降级与有限输出兼容。真实VT必须留版本/视口/字体map来源/受检SHA/原始日志/PNG+hash；正常权限/映射失败是各自明确分支。未知PTY保留Unicode需用真实VTE/xterm或已有有效证据，换TERM不算真实实现。输入/resize/恢复/故障/全组件/M2/制品及全部宿主的完整AC041仍由后续最终汇合判定；缺环境记insufficient_evidence。

## G010 包内纯策略工厂与测试构造边界（最终补充）

为消除正式独立测试依赖未指定构造形状，根cjtui包内`class GlyphRenderPolicy`固定三个package可见生产工厂：`static func unicode(): GlyphRenderPolicy`、`static func ascii(): GlyphRenderPolicy`、`static func mapped(bitmap: Array<UInt8>): GlyphRenderPolicy`。它们也是真实设备/离线解析路径的构造入口，不是测试hook；不向消费者公开policy/bitmap。mapped只接受8192字节，否则IllegalArgumentException，成功冻结防御复制，调用方之后修改原数组不改变policy。其它字段/构造内部形状由实现按职责决定。

`projectTerminalGlyph`的width=0返回空、width<0抛IllegalArgumentException；正width由已验证Frame的起始Cell提供，并受所属Frame配置的maxCells实际预算约束。不能假设所有合法复杂簇width<=2，也不能新增固定宽度上界拒绝既有合法Frame。093所谓超预算拒绝指真实Frame尺寸/配置预算，不要求对私有helper传Int64.Max分配字符串或构造不可达OOM。现有控制安全仍由Frame文本验证负责；此工厂不绕过原Unicode/宽簇权威。

现包内`TerminalRenderProfile.init`在所有旧参数之后追加`glyphPolicy!: GlyphRenderPolicy = GlyphRenderPolicy.unicode()`，保存同名只读`let glyphPolicy: GlyphRenderPolicy`。旧纯snapshotProfile及颜色调用因默认值保持兼容，设备profile实际显式传入本会话解析策略。这是唯一生产profile归属，不是专属测试接口；合法同包测试可固定策略直接验证Frame投影后差分，真实PTY与实际VT仍不可被该单测替代。

## G011 原生诊断分支精确映射

为使独立原生测试不猜测errno分类，以下表细化G003/G004；nativeError只承载表中异常读取返回的errno，不把正常识别结果或分配器errno冒充syscall异常。

| 观测 | source / reason | nativeVt / mapKnown / nativeError |
|---|---|---|
| isatty(stdout)==0 | unknown / not-tty | false / false / 0 |
| fstat失败 | unknown / vt-query-failed | false / false / 原errno |
| 已是TTY但设备号/具体VT判据不符（含别名） | unknown / not-concrete-linux-vt | false / false / 0 |
| VT_GETMODE或KDGETMODE失败 | unknown / vt-query-failed | false / false / 原errno |
| KDGETMODE成功但非KD_TEXT | unknown / not-text-mode | false / false / 0 |
| 已确证文本VT后，临时内存分配失败 | linux-vt-unavailable / map-allocation-failed | true / false / 0 |
| 同fd GIO_UNIMAP返回-1 | linux-vt-unavailable / map-query-failed | true / false / 原errno |
| map数据长度等内部校验不符 | linux-vt-unavailable / map-invalid | true / false / 0 |
| 完整有界map成功（可0条） | linux-vt-unimap / 空reason | true / true / 0 |
| 编译目标无该实现 | unknown / unsupported-platform | false / false / 0 |

失败entryCount=0，成功为实际pair数而非bitmap置位数；重复unicode映射不会把读取失败伪装成成功。仅对已确证文本VT尝试分配/读取map，未知PTY不得触发该读取。
