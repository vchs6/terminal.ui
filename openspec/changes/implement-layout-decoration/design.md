# Design

## Context

基线c502c9fe64422095d7a37e741d8756af3bbc9873已有Frame、静态Text/Row/Column、Linux事件循环和独立R8证据。当前measure/draw只有内容尺寸，不能声明面板。此变更落实既有REQ-003.1/.2/.3/.9/.10，不增加GUI或CSS引擎。

## Goals / Non-Goals

Goals：同一声明树和同一Frame支持固定/最小/比例布局、间距对齐、边框和阴影；旧无布局参数示例保留可见内容和样式继承；实际视口优先，可构造真实分区示例。
Non-Goals：不实现滚动、主题配置/四主题、响应式、编辑、覆盖层、M2或其他OS；不改Linux输入/会话/native构建。它们的既定要求仍保留，不能用本片替代。

## Decisions

D-023（工程决定/执行准入）：复用已验证TASK050的Frame、Unicode和Component，而不等待尚无必要实现的完整覆盖层007；原TASK011/012状态转入本变更。此依赖细化不取消其他任务。替代独立画图/面板渲染器会重复Unicode/样式内核，不采用；只做底层而无声明式组合不能实现用户目标，也不采用。

D-024：一条measure→arrange→paint路径，内容度量应每次render一次递归而非为每个祖先反复扫描文本；内部临时布局记录不是第二套持久节点权威。全部位置/尺寸为行列整数；overflow不能绕回或导致遍历巨大不可见Rect。度量/游标累计可饱和到Int64.Max；比例所需总权重/基数若无法精确表示则诊断，不静默用浮点近似。比例乘除须防溢出（常见乘积可直接算，极值可安全整数mul/div），不新增依赖。

D-025：显式background填整个分配框（含padding/border底色），未指定则不画框底色，文字维持既有继承语义；显式Color.Default仍是有意复位/填充。边框/间距/padding/阴影不继承。只在应用显式调用时画装饰，不主动美化。

## Public contract: layout (TASK-011)

新增`public struct Rect`：`init(x: Int64, y: Int64, width: Int64, height: Int64)`，四个同名只读Int64字段；x/y可负，width/height必须非负，非法抛IllegalArgumentException。

新增`public enum Alignment { Start | Center | End | Stretch }`。

Component属性链均返回同一Component：

| 方法 | 默认与行为 |
|---|---|
| width(Int64), height(Int64) | 可选固定外框尺寸；非负，0是真正零尺寸 |
| widthAuto(), heightAuto() | 清除固定尺寸，恢复内容/父级分配 |
| minWidth(Int64), minHeight(Int64) | 非负，默认0；可满足时下限，实际祖先空间不足时降到可用尺寸 |
| layoutWeight(Int64) | 非负，默认0；仅在Row/Column主轴生效，0为非flex；正值的主轴固定尺寸/自然尺寸被最小值基数+比例分配取代，交叉轴仍按普通尺寸 |
| padding(Int64) | 非负，默认0；四边相同行列，作用于所有组件，内边距不继承 |
| gap(Int64) | 非负，默认0；仅容器，沿主轴相邻子项间距，无首尾间距 |
| alignItems(Alignment) | 仅容器交叉轴，默认Start；Center向下取整，End靠末，Stretch只拉伸auto交叉尺寸，固定交叉尺寸不被覆盖 |
| justifyContent(Alignment) | 仅容器主轴，默认Start，仅Start/Center/End；Stretch非法；剩余空间居中向下取整，不拉伸字符 |
| textAlign(Alignment) | 仅Text每行在内容框内Start/Center/End，默认Start；Stretch非法；超长行起始裁剪，不从中间截字 |

所有不合法值/目标种类在setter立即抛IllegalArgumentException且保留旧设置（Text上gap/alignItems/justifyContent及容器上textAlign均非法）。已有foreground/background/bold调用不变。

render(root,width,height)仍创建同尺寸Frame。根auto外框用实际视口，显式尺寸/最小尺寸也不超过视口；不强撑应用最小画布。子非flex主轴尺寸为固定或自然尺寸与min的较大值，并收敛至父内容主轴可用尺寸；放置按声明顺序，可见越界由祖先裁剪，不改显隐状态。多个非flex/间距合计溢出时不重排业务顺序，末尾内容裁剪；滚动后续另实现。

容器先扣固定/nonflex与gap占用，余量pool不小于0。flex子项先用各自min基数（先收敛至父可用轴）；min合计<=pool时，pool-min合计按权重分配，再加min。min合计>pool时仅将pool按min基数比例分配。整数份额按floor后把剩余逐一分配给小数余量最大的子项，余量相同按声明顺序；无浮点误差。flex主轴铺满它的pool；无flex时justify作用于真正剩余。交叉轴fixed/自然+min收敛至父内容交叉尺寸，Stretch拉伸auto；Center/End不足时偏移0。

外框包含边框与padding；内容可用尺寸不能负。Insets在不足时依左/上优先收敛（先扣左/上，再扣右/下），不溢出。所有文本即便零尺寸或完全裁剪仍验证C0/C1/ESC规则；多行LF/CRLF、Unicode完整簇和样式规则复用R8。没有新参数时旧公开回归必须通过。TASK011先实现padding与Rect，边框Insets由TASK012接入同路径。

## Public contract: decoration (TASK-012)

新增`public enum BorderStyle { None | Single | Rounded | Double | Ascii }`，无装饰为默认None。

Component新增：
- `border(value: BorderStyle): Component`；非None占外框每边一列/行。
- `borderColor(value: Color): Component`；默认未设，边框沿用该节点有效前景；不修改文字前景。
- `shadow(offsetX!: Int64 = 1, offsetY!: Int64 = 1, style!: Style = Style(), enabled!: Bool = true): Component`；偏移可正/负/0，enabled=false可移除。

Frame新增共享低层API（不要求高级用户构建组件）：
- `fillRect(rect: Rect, style!: Style = Style()): Unit`：绘制带样式空格，不是透明擦除。
- `drawBorder(rect: Rect, border!: BorderStyle = BorderStyle.Single, style!: Style = Style()): Unit`。
- `drawShadow(rect: Rect, offsetX!: Int64 = 1, offsetY!: Int64 = 1, style!: Style = Style()): Unit`。

Single为┌─┐│└┘，Rounded角╭╮╰╯，Double为╔═╗║╚╝，Ascii为+-|。零宽/高不画；1×1画ASCII +，宽1高>1仅竖线，高1宽>1仅横线；这些退化不画重叠角。阴影为偏移外框中不属于原外框的部分，用░，不增加布局/命中面积；偏移0/0无外露区域。任一边框字形在Frame宽度策略下非1列时整套回退Ascii，阴影░非1列时用ASCII .；不声称检测字体覆盖。

低层操作按原Rect几何画再裁剪，不把裁剪边缘重画成新边框；必须先裁剪可见迭代范围，极大/越界坐标有界完成，不通过整块虚拟Rect循环。它们与Text共用Frame宽字簇清理/样式，不复制屏幕或字符内核。

高层顺序为shadow→显式框背景→border→children/text。每个子节点阴影可越过自身外框，但必须服从祖先内容裁剪；本节点内容裁剪扣除自身border/padding。兄弟按声明顺序绘制，后绘覆盖前绘；没有显式框背景的空区域不写入。根阴影服从Frame边界。阴影样式完整使用传入Style，不悄悄继承或修改业务数据。旧新布局/阴影改变在M1完整目标帧中自然清残留，不能要求应用手动flush。

## Deliverable / verification

新增examples/layout真实程序，使用公开Component链构造有标题/主体/底栏、两个加权面板与圆角/阴影；可用UI回调切换阴影/边框观察旧区域清除，q退出，resize自动重排，不直接写ANSI/全屏坐标/flush。布局和装饰各自独立Cangjie外部消费者测试，runner仍build后直接binary。所有R8回归保留。独立执行actual例子与resize/切换/退出，cold源码包消费。公开API、Frame极值、裁剪/宽簇、整数余量和背景styled-space由独立测试作者冻结golden。

## Risks / Trade-offs

窄屏min可能不可满足→actual尺寸+确定裁剪/比例降级，不改业务显隐。大整数→安全算术/有界可见迭代，不能截断。背景新增框填充语义→显式记录，旧glyph继承及全部R8断言不变。装饰绕过裁剪/宽字→共享Frame路径与独立反例。将来M2/覆盖层→本片不另建绘制内核，布局框与绘制扩展仍分离。
