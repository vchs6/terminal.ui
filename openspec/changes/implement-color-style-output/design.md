# Color and style output contract

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
