# Color and style output contract

> 用户最新裁决优先：正常应用面向完整Color/Style模型，渲染自动识别目标终端并降级，不能要求程序员选择支持模式；跨终端须真实实现分别运行，报告附真实效果截图。下面D029“默认Basic16/不读宿主信息”和Application/例子手动能力流程是187e126历史切片，已被覆盖，不作为新默认实现或验收契约。原色表/显式override/6属性共享路径继续适用。自动识别精确API与来源优先级已据TASK065实际探针冻结于D031–33；尚未验证部分不冒充实现。


## Context / scope

Baseline96bdb9b7c5b1f58c5ec223a0475be3d86cfae660（R9已推送）。当前Color仅8色、Style仅bold。此片完成既有TASK006，不实现TASK013主题配置/状态主题、富文本ANSI解析、滚动、焦点、M2或其他OS。Linux ANSI字符终端，不承诺字体/字形外观检测。

## Decisions / admission

D028：先006再013，复用已完成050及R9单Frame/Style/声明树。原006完整003/004调查不作为这一已确认公开切片的重复阻塞；其他未覆盖要求保留。对比“先写主题再补色”会建错基础，“另造ANSI编码器”重复依赖职责；选共享模型与ansies薄适配。用户已授权按依赖连续实施和main推送、无需再次询问工程默认。

D029：应用显式颜色模式，默认Basic16；不猜TERM/COLORTERM、不探测/修改终端调色板、不输出OSC。原始颜色保存在Style/Cell中，仅在输出映射。能力模式及名义调色表不是终端实际配色的检测保证。优先现有ansies编码，不使用实测错误的最近邻converter；其静态可变表也不作为框架权威。最小本地策略为下列16色常量+标准色立方/灰阶公式及整数距离，不复制库/Unicode/数据表或第二ANSI内核。

D030：M1仍完整目标Frame后差分，比较有效输出样式。颜色降级相同或Monochrome丢弃的仅颜色变化不能发送行更新；模式变化也只更新实际受影响行，不无条件全屏重绘。每个输出会话保存已成功显示基线的模式，完整写成功后才一起提交Frame/模式。样式投影为临时输出计算，不创建第二持久组件/帧权威。性能：相同原始Style/模式的重复单元不重复最近邻计算，至少按相邻样式run复用；保留默认旧8色快路径。无任意新基准阈值。

## Public models / package organization

src/style/color.cj继续public enum Color <: Equatable<Color>，保留Default/Black/Red/Green/Yellow/Blue/Magenta/Cyan/White，增加BrightBlack/BrightRed/BrightGreen/BrightYellow/BrightBlue/BrightMagenta/BrightCyan/BrightWhite、Indexed(UInt8)、Rgb(UInt8, UInt8, UInt8)。值域由UInt8类型约束；==/!=区分构造器与全部通道。原始色不同仍不相等，输出等价另算。

新增src/style/color_mode.cj，public enum ColorMode <: Equatable<ColorMode> { Basic16 | Indexed256 | TrueColor | Monochrome }，根exports明确重新导出。保留import cjtui.*及已有构造调用。每类/结构/接口/枚举单文件，文件/包小写下划线；纯映射函数可在根包color_mapping.cj，共享渲染边界，不强行扩大子包内部可见性。新增源码及实际修改源码cjfmt，用户两份仓颉参考按AGENTS14适用。

Style增加public只读Bool dim/italic/underline/inverse/strikethrough；init除既有foreground!/background!/bold!外追加同名命名可选Bool（默认false）；Eq包含全部字段。原有默认值和参数保持。六属性统一为bold、dim、italic、underline、inverse、strikethrough。

Component保留bold(): Component，新增bold(value: Bool): Component；其余dim/italic/underline/inverse/strikethrough各提供零参和一个Bool位置参的同名重载，均返回同一receiver。零参相当于true。SDK1.2不支持普通位置参数默认值，不能将伪签名value: Bool = true当作有效源码；实际调用仍为.bold()/.bold(false)等。false是显式关闭，覆盖父文本属性；未设置继续继承。颜色属性接口不变。所有六属性均按现有文本继承规则传播到文本、显式背景及边框；borderColor只换前景，不丢其他属性。阴影仍只用传入完整Style，不额外继承。padding/gap/布局/边框/阴影不因此继承。

Frame.toAnsi(colorMode!: ColorMode = ColorMode.Basic16): String；不改构造/put/cellAt/toPlainText，逻辑单元保留原Style。toPlainText不受模式影响。空尺寸仍返回空ANSI，宽簇规则不变。

Application.init(root: Component, colorMode!: ColorMode = ColorMode.Basic16)；新增public colorMode(value: ColorMode): Application，同receiver，可在onKey回调中切换，无需flush。原onKey/run/stop及异常清理D027保持。内部差分可调整签名以同时比较旧/新输出模式；无须增加公开Frame差分API。应用显式声明能力，不读取环境或修改全局配置。

## Deterministic projection

名义16色索引0..15按顺序为Black,Red,Green,Yellow,Blue,Magenta,Cyan,White,BrightBlack,BrightRed,BrightGreen,BrightYellow,BrightBlue,BrightMagenta,BrightCyan,BrightWhite。RGB参考值依次：

(0,0,0), (128,0,0), (0,128,0), (128,128,0), (0,0,128), (128,0,128), (0,128,128), (192,192,192), (128,128,128), (255,0,0), (0,255,0), (255,255,0), (0,0,255), (255,0,255), (0,255,255), (255,255,255)。这是确定性降级参考，不设置宿主配色。

256索引0..15沿用上表；16..231为6×6×6立方，idx=16+36*r+6*g+b，各通道level=[0,95,135,175,215,255]；232..255灰阶为8+10*(idx-232)。RGB最近邻用三通道平方距离之和，整数精确，平局较小索引。允许等价优化，但结果必须等于枚举指定候选。不得调用依赖错误converter或读其可变colorTable。

- Default所有模式仍Default。
- 所有命名16色在Basic16/Indexed256/TrueColor中原样；Monochrome转Default。
- Indexed(0..15)在前三模式统一规范成对应命名色，以保持输出等价及避免别名导致无效行刷新；Indexed(16..255)在Indexed256/TrueColor保留，在Basic16先解出名义RGB再匹配16色。
- Rgb在TrueColor原样；在Indexed256匹配全部256参考色，再把0..15规范成命名色；在Basic16匹配16色；在Monochrome转Default。
- Mono只丢弃颜色选择，保留六种属性；全复位SGR0仍是快照/行输出边界。投影从不改Frame中的原始Color。

已知golden：Rgb(250,0,0)降级为BrightRed（Basic16与Indexed256），Indexed(17)降级Basic16为Blue；Rgb(1,128,254)→Indexed256的33；Rgb(64,0,0)→Basic16的Black（与Red等距，较小索引）；Rgb(128,128,128)→Indexed256的BrightBlack（多个相同RGB选8）；Rgb(238,238,238)→Indexed256的255。测试作者须独立核算，不依实现产物生成期望。

## Encoding / comparison

全部ANSI颜色和属性由ansies公开AnsiColor/Color.foreground/background、AnsiStyle/Style.set生成；坐标仍CUP，reset仍SGR(["0"])。固定编码顺序reset0、非Default前景、非Default背景、bold/dim/italic/underline/inverse/strikethrough，false不emit。关闭属性依完整reset0后重建，不使用依赖reset(BOLD)的21m；不得手写第二ESC生成器或OSC改全局调色板。

同一有效Style只需在变化时emit，行/快照reset与原R9字节边界保持；旧8色+bold默认输出必须逐字节回归不变。差分以字簇/延续/宽度和投影Style判断；同模式且原Style相等可跳过投影。新旧模式分别投影同一逻辑单元后比较，只有有效改变的行输出；模式变化对无色或等价基础色没有额外更新。实际写成功才提交模式/Frame；失败沿用D027停止并报告/恢复，输入/native不改。

## Example and verification

examples/colors为独立公开API示例：16色、索引色、RGB及六属性，通过组件块/属性链/原生仓颉回调组合；初始Basic16，c按Basic16→Indexed256→TrueColor→Monochrome→Basic16循环，t切换示例文本属性，q退出，resize正常。状态类型若有单独文件，不堆入main.cj；不写ANSI/手算屏幕/flush。不把它称为四主题。

独立tests/colors公共消费者覆盖Color/Style Eq、所有通道边界、映射/平局、原始单元不变、前/背景/重置、样式继承和显式false、边框/阴影完整Style。实际PTY检查例子模式与属性切换、resize/termios；另固定公共fixture用事件握手验证降级等价/Monochrome仅颜色变化/等价模式变化静默、实际模式或属性变化更新。不要仅凭固定sleep推测事件处理完成，可用第二个公共onKey事件在上一轮渲染后写文件作为握手；无产品测试hook。保留所有R8/R9/生命周期回归，build后直接binary（cjpm run不作exit oracle）。完整slice冷入口、正常bundle、有限包边界/clean consumer独立执行；完整release仍缺composition/benchmark，不伪造pass。冻结代码后按相关内容hash复用，角色变化不触发重复功能验证。

## Risks / retained scope

真实终端palette可能自定义、样式/字体能力不一致→只承诺标准SGR与明确降级，不声称像素一致/检测成功。依赖converter有已证缺陷→仅隔离能力策略，保持固定依赖版本/许可证原文，不引入上游调查阻塞。未来主题必须复用原始Color/Style及此输出策略；本片不设置主题或业务状态。M2、全部Linux/跨平台完成条件仍待后续。

## User-directed automatic output and cross-terminal visual evidence

默认设备渲染必须自动适配，应用只声明丰富样式；可选手动override仅用于高级覆盖或诊断，不能成为正常示例的必需步骤。原始Color/Style保持，设备输出映射与离线完整彩色快照的目标边界须在TASK065后明确，不因当前宿主较弱而永久损失原色。未知能力必须保守处理并保留可诊断来源，不能把环境提示或缺少回复冒充硬件验证成功；具体host/terminfo/可选有界协议来源先实测。

跨终端验收以不同真实实现运行相同应用和用例为准，至少覆盖有意义的不同终端内核/能力等级；环境提示分支测试单列，不替代真实宿主证据。候选xterm、VTE及可用终端层由环境probe决定，实际Linux console无设备时明确pending，不能冒充已测。每个host验证自动能力来源与降级、原色/属性、可见/静默刷新、Unicode、resize、退出与termios；矩阵写明实现、版本、配置、后端、受检SHA及结果。

报告PNG必须由实际运行窗口/终端内核捕获，记录终端/版本/字符网格尺寸/场景/受检代码SHA/采集时间/原始日志和图片hash。保留原始图，不用绘制或生成图代替运行效果，不根据截图单独判定输入、刷新或清理正确。截图工具和GUI宿主只属测试环境，不成为产品依赖。

## D031–D033: revised automatic-device implementation contract

此节依据用户新裁决和TASK065实际探针，覆盖前述历史手动默认/API/例子条目。原16/256/RGB名义映射、六属性模型、原色保留、ansies编码、有效diff和旧调用兼容继续适用。

### Automatic application and pure snapshots

ColorMode新增Basic8，属于具体输出等级；不新增Auto枚举值。Basic8候选仅名义表0..7，Bright命名色也按该参考RGB匹配8色，不额外用bold模拟亮色。已有4具体mode不改。

Application提供两个公开构造重载：init(root: Component)默认自动；init(root: Component, colorMode!: ColorMode)是可选高级颜色override（命名参数必填无默认，SDK1.2已验证）。现有colorMode(value)仍设override，新增colorModeAuto(): Application清override，均返回同receiver。普通App/示例无需这些能力选择调用。

新增只读public struct TerminalCapabilities，独立src/terminal_capabilities.cj、package cjtui。公开只读字段：colorMode: ColorMode（已解析，unknown映射Monochrome）、colorKnown: Bool、terminfoKnown: Bool、supportsBold/supportsDim/supportsItalic/supportsUnderline/supportsInverse/supportsStrikethrough: Bool、noColorVideo: Int64（未声明为-1）、source: String、reason: String。构造仅包内使用，不给用户设置检测结果。Application新增terminalCapabilities(): ?TerminalCapabilities，首次成功取得会话并检测前None，之后返回最后一次会话检测快照，仅为可选诊断，不参与应用必需流程。

每次run成功open后，在已有try/finally内自动检测一次；检测失败返回保守profile，不抛出、不跳过D027清理。profile在本次session内固定；colorModeAuto复用该检测值，下一次run重新检测。手动override仅覆盖颜色等级，属性仍按自动profile约束。新旧有效mode与同一profile投影后比较，仅实际变化行输出；成功完整写后才提交rawFrame+实际mode。原始Style/Cell不改，投影缓存按run保留而非每单元重复最近邻。这里run表示相邻样式run，不是第二持久状态。

Frame.toAnsi(colorMode!: ColorMode = ColorMode.TrueColor)现在明确为无设备目标的纯完整彩色快照：默认保留RGB和六属性，不查询TTY/环境、不悄悄因导出主机变色。显式mode只用于离线颜色预览，仍不裁六属性。旧8色/bold默认字节不变。实际Application设备输出调用共享内部profile投影/编码，不另建Frame或ANSI内核。

### Linux capability sources and safe optional adapter

native新增小型可选探测模块，通过glibc dlmopen(LM_ID_NEWLM, libtinfo.so.6, RTLD_NOW|RTLD_LOCAL)在私有namespace加载一次，私有handle+mutex复用。不得直接base namespace setupterm污染宿主ncurses，不要求程序员加锁/初始化。当前Linux/glibc实测通过；其它libc、缺函数/库/符号/条目等均保守失败。只支持已验证.so.6，不泛称全部ABI。不得用shell/tput子进程、完整自写terminfo parser或产品GUI依赖。动态加载符号采用可选绑定，不给普通消费者增加私有链接flags；必要native archive对象由现有build hook正常构建。仅测试宿主允许GUI/recorder。

TERM从环境读取，必须非空、非dumb、长度<=128，字符仅ASCII字母数字及_+.-，否则返回unknown/Monochrome且无属性，分别reason term-unset/term-dumb/term-invalid。TERM是查表键，不把它叫物理硬件探测。COLORTERM大小写无关仅truecolor/24bit视为宿主直接色声明；其它值不推测。合法TERM的可选terminfo读取成功时，colors小于8→Monochrome，8..15→Basic8，16..255→Basic16，>=256→Indexed256；colors>=16777216或RGB/Tc布尔flag==1→TrueColor。COLORTERM的强直接色声明也可升级为TrueColor，记明来源，不据此声明字体/所有属性；即使terminfo不可用，合法非dumb TERM+有效COLORTERM仍可确认声明的颜色支持，属性未知则裁掉。来源是宿主声明/数据库，不保证恶意或错误宿主配置真实。

颜色无确认来源时colorKnown=false、colorMode=Monochrome；成功条目即使无colors也可colorKnown=true/Monochrome。terminfoKnown只表示该条目查询成功。source固定为terminfo、terminfo+COLORTERM、COLORTERM或unknown。reason成功为空；失败分类为term-unset、term-dumb、term-invalid、unsupported-platform、terminfo-library-unavailable、terminfo-symbol-unavailable、terminfo-entry-unavailable、terminfo-database-unavailable。若有COLORTERM颜色证据但terminfo失败，保留失败reason和source=COLORTERM，不能把属性未知写成支持。

six属性分别查bold/dim/sitm/smul/rev/smxx。只接受已验证标准SGR能力（各自1/2/3/4/7/9；可去除合法ncurses padding后精确对应），缺失、invalid、未知/参数化/非对应序列都不支持；不透传任意terminfo字符串，实际编码仍ansies。smxx仅是条目确有SGR9时支持的strikeout扩展。reset继续SGR0，禁止库reset(BOLD)21m。

设备输出先映射颜色，再裁不支持属性；有显式非Default前/背景时执行颜色优先NCV策略：ncv位2裁underline、4裁inverse、16裁dim、32裁bold；未声明(-1)或0无额外限制。若正ncv还含未建模位，彩色组合保守裁全部六属性，不宣称未知组合安全。无显式颜色（含Monochrome投影）仍按单项能力保留属性。raw Style所有值不变。

### Private ABI and failure visibility

私有FFI唯一入口int64_t cjt_capabilities_detect(void)，返回非负位字，不存第二全局可变检测结果。位0..2等级：0unknown、1mono、2Basic8、3Basic16、4Indexed256、5TrueColor；位3..8依次六支持属性；位9terminfoKnown，位10有效COLORTERM声明；位11..15reason：0none/1unset/2dumb/3invalid/4platform/5library/6symbol/7entry/8database；位16..47保存非负ncv数值，位48标ncv已声明，否则解码-1，其余位0。C/Cangjie使用具名常量和共享文档，不散落魔法数。等级0之外颜色视为known，source由位9/10和等级推导；invalidTERM时忽略COLORTERM。C侧未知/错误不得输出终端控制或fatal退出，释放每次临时TERMINAL且私有namespace状态恢复。

### Revised examples, tests and real-terminal matrix

examples/colors默认Application(root)，删除必需的mode判断/选择流程。c循环三种样例RGB（1,128,254）→（250,0,0）→（238,238,238）→首项；t继续已有六属性逐项开启/关闭示范；q退出。能力选择只在高级override fixture中存在，不作为正常例子。至少一行包含中文、组合符和emoji以观察终端文字布局，不能承诺宿主字体字形覆盖。

独立测试先冻结新增Auto/Basic8/profile/纯快照预期和真实RED：采用测试terminfo数据库夹具覆盖8/16/256/direct/unknown、六能力裁剪、NCV18及未知位、非SGR能力不透传、原色保留、default profile和diagnostic来源、显式override及回Auto、无效变化静默；合成条目只算分支测试。保留原显式映射/属性/handshake断言，修改默认snapshot和普通example相关预期必须标用户裁决，不降低其它门槛。私有namespace与外部cur_term隔离用独立native检验证据，不能改产品加test hook；可在测试链接wrap已存在动态加载符号覆盖失败，原库/cache不改。

正式跨终端使用相同无override二进制/应用：真实XFCE/VTE默认truecolor声明、真实xterm默认TERM=xterm，以及可行xterm -tn xterm-256color额外配置。后两项是一种实现的两配置，报告不算三独立内核。每项验证实际声明来源/profile、SGR和降级、关键文本/刷新、resize、q/CtrlC/错误恢复及termios；采用Xorg中真实窗口PNG，原始字节可由宿主内script透明TTY记录，不能变成产品PTY后端。真实物理Linux console、tmux/screen无环境的项保持pending，不由TERM=linux的合成夹具代替。截图标窗口/版本/尺寸/阶段/受检SHA/时间/hash，旧shell scene宿主probe图只证明环境可用，不能当框架Auto效果图。
