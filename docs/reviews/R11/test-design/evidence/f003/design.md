# Frame composition contract

## Scope and ownership

本变更只扩展现有 cjtui.Frame/Cell 及产品说明，保持单一字符簇/宽度、样式和 ANSI 编码路径。既有调用及普通 Frame 字节不变。全阶段继续见 docs/linux-completion-plan.md；不创建独立 overlay Frame 类型或复制 Unicode 算法。

## Exact public API

所有类型仍在 package cjtui；每类型独立文件。Cell 增加 `public let isTransparent: Bool`，原字段及包内构造保留，用户不能创建不合法延续单元。

Frame 构造为 `public init(width: Int64, height: Int64, ambiguousWide!: Bool = false, transparent!: Bool = false, maxCells!: Int64 = 1048576)`。宽高必须非负，maxCells 必须正；乘法先检查溢出，正面积总单元数不得超过 maxCells；零面积的虚拟另一轴不受该预算拒绝，违规在分配前抛 IllegalArgumentException。零面积仍合法且 ANSI 为空，保留 Frame(0, Int64.Max) 与 Frame(Int64.Max, 0) 的既有构造/空操作契约。普通有限尺寸的纯文本换行规则保留；零宽 height>0 的纯文本有 height-1 个 LF，若该长度超过 maxCells，导出在生成/文件打开前抛 IllegalArgumentException。height=0 的纯文本为空。所有几何操作在合法性检查后对零面积短路，不遍历虚拟轴。

新增成员：

| 签名 | 契约 |
| --- | --- |
| `public func clear(rect: Rect, transparent!: Bool = false): Unit` | 清除矩形与帧的交集。被触及的旧宽字符整体清除；明确 transparent 参数决定整个被清除簇的空单元类型；不透明空格使用 Style() |
| `public func copy(rect: Rect): Frame` | 返回指定宽高独立帧；保持原宽度策略、默认空白类型和资源预算。矩形超出源的部分按默认空白填充；不共享可变 cells，交集内保留每个源单元的透明位 |
| `public func resized(width: Int64, height: Int64): Frame` | 返回新帧，原点不变，复制交集且遵守宽簇裁剪；新区域按原默认空白类型填充，交集内保留透明位，保留资源预算与宽度策略 |
| `public func composite(layer: Frame, x!: Int64 = 0, y!: Int64 = 0): Unit` | layer 局部原点放到目标 x/y，只改交集；透明跳过，不透明空格与背景覆盖；后调用的层在上方；不同实例时源保持不变；自身操作用开始时读取快照 |
| `public func writePlainText(path: String): Unit` | 将完整 toPlainText 的 UTF-8 字节写文件，无 BOM/额外尾 LF/ESC；失败抛出标准文件异常 |
| `public func writeAnsi(path: String, colorMode!: ColorMode = ColorMode.TrueColor): Unit` | 将完整纯快照 toAnsi 的 UTF-8 写文件，不探测终端；编码/初尾 reset 与现有导出一致；失败抛出文件异常 |

Rect 已负责非负宽高；x/y 允许负数。计算交集用现有饱和有符号坐标策略，Int64 极值不溢出、不形成巨量循环。copy/resized 的新尺寸同样受资源预算约束。不同宽度策略的参数校验先于无交集/零面积短路，即使空层也拒绝不匹配。给调用方更大的 maxCells 是显式高级选择，不改变默认有界策略。

预算依据：1048576 = 1024×1024 单元，约为已验 120×34 视口容量的 257 倍，容纳远大于常用字符终端的正面积同时阻止意外天文尺寸分配。这是可配置容量政策，不宣称等于固定内存字节或已测性能阈值。render 与 Application 当前调用默认 Frame，继承此默认正面积上限；本变更只在低层 Frame 提供显式预算，后续统一应用资源配置接入同一预算。兼容字节指新合法域内的旧调用，零面积历史极值例外已明确保留。

文件路径使用标准文件语义：不存在时创建；已存在普通文件替换并截断到准确字节数，包括空快照截断为零；不自动创建父目录。打开、实际写入或关闭失败传播标准库文件/I/O 异常（正常无效目标测试可捕获 std.fs.FSException），不吞错误。失败可能留下部分文件，不承诺原子替换、旧内容保留或落盘持久化。参数/预算验证在写入前完成，其 IllegalArgumentException 与 I/O 异常区分。

## Cell and wide-character rules

- 普通 Frame 初始为空格、width=1、continuation=false、Style()、isTransparent=false；透明 Frame 初始相同但 isTransparent=true。
- put、fillRect、边框及阴影写入的实际单元均不透明，包括 Style() 的空格；不以默认色或空格猜透明。put 原本的越界省略和定位语义不变。
- 透明单元始终规范化为空格、width=1、continuation=false、Style()；不能藏残留宽簇或样式。覆盖旧簇时 clearAt 用帧默认空白类型，clear(rect, transparent:...) 则用此次显式类型。
- copy/resized/composite 只完整复制可见的源簇。若源簇被左/右边界切断，交集中被该簇占用的源不透明单元变为同源 Style 的单列不透明空格；绝不复制孤立 continuation。composite 的透明源跳过；copy/resized 则保留源透明位，不能把 opaque 默认帧显式 clear 出的透明孔重新变为不透明。
- 目标已有宽簇与实际写入单元相交时，整簇先清除，再写入源；簇伙伴可以位于几何交集外，清除后按目标默认空白类型规范化，保持唯一宽簇不变量。
- 自身合成及重叠偏移须读取操作开始时源快照，不出现边读边写的拖影。不同 ambiguousWide 策略的帧合成在任何修改前抛 IllegalArgumentException；copy/resized 保留策略。
- 任何源/目标尺寸零时安全完成；普通有限尺寸纯文本包含完整列的空格，行间 LF、无尾 LF。透明帧单独导出时以默认空格扁平化，ANSI 不产生透明专用控制序列。

## Compatibility, verification and deferred integration

已有 Cell 字段、Frame.put/fillRect/drawBorder/drawShadow/toPlainText/toAnsi 及默认编码保留；只新增透明元数据和操作。默认正面积预算是 NFR-03 必需的分配前保护，不借机修改颜色或布局策略。资源边界测试不得真的尝试巨量分配。

独立 public consumer 覆盖透明/不透明样式空格、层次、负偏移/极值、宽簇左右切断、目标簇两侧覆盖、自身重叠、独立副本、透明 clear、扩缩、策略不匹配和文件错误。手算固定网格，不以同一 compositor 生成期望。旧 contract/coordinates/colors/layout/decoration 做受影响回归；最终全 Linux 集成再执行全入口与 release。

TASK-005/007 的完整 Frame 层 AC 可在独立验证后关闭；TASK-010 这里只交文件原语，实际应用可见覆盖层的捕获在 TASK-018 后汇合，原 AC 保持待验。没有像素后端或普通命令行一次性输出模式。

### Ruling F003：复制与合成的透明语义

copy/resized 是源数据复制，完整源交集包括 isTransparent；composite 是叠放，透明不覆盖目标。这一澄清替代初稿将三者共同描述为“透明跳过”的歧义，避免 opaque 默认层 clear 出的孔在复制后封闭。例：底层ABC、源层XYZ将中间clear透明，原层与其完整copy/同尺寸resized分别合成均须XBZ，而不是X空格Z。既有正常/透明默认帧字节和原断言不变，由独立新用例先证当前实现RED再修最小共享路径。
