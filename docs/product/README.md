# 产品说明

当前已接受公共 Canvas/焦点/caret、视口滚动与覆盖层，使用方法见[交互原语](interaction.md)，独立证据分别见[A绘制与焦点](../reviews/interaction/A/README.md)、[B视口与滚动](../reviews/interaction/B/README.md)、[C覆盖层](../reviews/interaction/C/README.md)。归一化键盘/paste已获[有限K验收](../reviews/K/README.md)；单/多行[TextInput/TextArea](text-editing.md)已获[有限E验收](../reviews/E/README.md)。这些已接受范围不等于完整Linux验收。

键盘事件、粘贴与限制见[键盘输入](keyboard-input.md)，示例位于 `examples/keyboard`。主题配置、解析和显式加载见[主题配置](theme.md)。可选剪贴板复制、宿主标题与恢复结果见[会话扩展](session.md)，正常公共调用示例位于 `examples/session`；这些可选操作完整发送后仍仅返回 `SentUnconfirmed`，不确认宿主效果，不返回 `Applied` 或 `RestoreConfirmed`。图片图标返回 `Unsupported/NoImageAdapter`。

cjtui 0.0.0 的历史首个切片提供 Linux ANSI TTY 文本界面：`Text`、`Row`、`Column` 组件块及前景色、背景色和粗体属性，Unicode 字符网格、纯文本与 ANSI 快照、键盘回调和终端尺寸变化时重排。普通应用无需发送 ANSI 或手动刷新。

使用仓颉 SDK 1.2.0，在 Linux ANSI 终端中从源码运行最小示例：

```sh
cd examples/minimal
cjpm run
```

按 `q` 退出，Ctrl-C 取消；程序需要实际 TTY。构建依赖及可选离线 Unicode 数据输入见 [原生构建](native-build.md)。

当前依赖采用 `ansies` 1.3.113、`unicode` 0.1.0 和 `unicodewidth` 0.1.113。基础五控件已获[有限S验收](../reviews/widgets/S/README.md)，新native S证据仅覆盖ASCII/default Classic；Unicode/disabled/explicit palette另有headless与源码证据。菜单/状态栏/分区的[正式测试158已固定，159实际实现中](../reviews/widgets/M/README.md)。M2局部布局与局部绘制尚未实现或验收，不能把现有失效通知和完整帧差分输出当作M2；完整M1集成、027/041展示及最终Linux验收仍待汇合。Windows、macOS、HarmonyOS尚未实现，当前未发布发行版。

低层可用 `Frame(width, height)` 和 `put(x, y, text, style: Style(...))` 写入网格，`cellAt` 查询，`toPlainText` 和 `toAnsi` 导出完整快照。负尺寸与越界查询报错；写入按边界裁剪，拒绝除换行外的控制字符。`render(root, width, height)` 使用同一网格渲染组件树。`Application(root).onKey { event => ... }.run()` 负责终端会话；文本按 Unicode 字符提供，`stop()` 可从回调退出。

低层帧支持 `Frame(width, height, transparent: true)` 创建透明底层，`composite` 按偏移叠加：透明单元跳过，带样式空格覆盖。`clear`、`copy` 和 `resized` 保持宽字符完整；截断的宽字符片段变为保留样式的空格。复制和缩放保留源单元的透明位，新增区域使用源帧的默认空白类型。`writePlainText(path)` 和 `writeAnsi(path)` 写入完整 UTF-8 快照，已有文件会被截断；文件错误向调用方传播。正面积默认最多 1048576 单元，可通过 `maxCells` 显式调整；零面积保留，零宽文本的换行数量也受预算限制。不同字符宽度策略的帧不能合成。

布局可通过组件属性链设置 `width`、`height`、`minWidth`、`minHeight`、`layoutWeight`、`padding`；`widthAuto`、`heightAuto` 清除固定尺寸。`Row` 和 `Column` 还支持 `gap`、`alignItems` 和 `justifyContent`，`Text` 支持逐行 `textAlign`。尺寸与间距以字符列和行为单位，必须非负；实际视口及祖先内容区域限制绘制。正权重在容器主轴上分配剩余空间，余数按最大余数及声明顺序确定。`Alignment` 提供 `Start`、`Center`、`End`、`Stretch`，其中 `Stretch` 仅用于交叉轴对齐。显式背景填充组件外框；文本、裁剪及宽字符使用同一 Frame 规则。

组件可通过 `border(BorderStyle.Rounded)`、`borderColor(Color.Cyan)` 和 `shadow()` 设置字符装饰；`border(BorderStyle.None)` 与 `shadow(enabled: false)` 分别移除效果。边框占外框每边一行或一列，阴影仅扩展绘制范围、不改变布局，并受祖先内容区裁剪。阴影可指定正负偏移及完整 `Style`。未设置边框颜色时使用节点有效前景色；显式背景包含边框与内边距。`BorderStyle` 还提供 `Single`、`Double` 和 `Ascii`；终端宽度策略无法以一列显示某个边框字符时整套回退 ASCII。阴影字符 `░` 非一列时回退 `.`，这不代表检测了字体覆盖。

低层 `Frame.fillRect`、`drawBorder` 和 `drawShadow` 使用相同字符宽度、样式和裁剪规则；填充写入带样式的空格，边框按原矩形几何裁剪。`examples/layout` 展示标题、加权面板和底栏；按 `d` 切换边框及阴影，按 `q` 退出，终端改变尺寸时自动重排。

颜色提供 16 种命名色、`Color.Indexed(UInt8)` 和 `Color.Rgb(UInt8, UInt8, UInt8)`。`Application(root)` 在每次会话开始时依据 TERM 的 terminfo 条目和 COLORTERM 声明自动选择颜色等级与可用属性；未知能力保守降级。高级用途可用 `Application(root, colorMode: ColorMode.Basic16)` 或 `app.colorMode(...)` 覆盖颜色等级，`app.colorModeAuto()` 恢复自动选择；属性仍受检测结果约束。`app.terminalCapabilities()` 可选查询最近一次检测的诊断快照，首次检测前为 `None`。声明与数据库不保证宿主的实际配置和字形覆盖。

颜色等级包括 `Basic8`、`Basic16`、`Indexed256`、`TrueColor` 和 `Monochrome`。降级使用固定名义调色板的 RGB 平方距离，距离相同时选择较小索引；实际终端可能使用自定义调色板。`Frame.toAnsi()` 默认导出完整真彩色及六种属性的离线快照，也可通过 `colorMode` 指定颜色预览；网格保留原始颜色和样式。

应用正常使用 `Application(root).run()`，框架每次启动会话读取实际标准输出设备的字形事实。确认是 Linux 文本 VT 且读取映射成功时，单个、单列、可打印并在 BMP 映射中的字符保留；其他字符簇按原列数回退为 ASCII。映射不可读时使用保守 ASCII，未知终端则采用保守 Unicode：逐标量显示宽度之和与原簇列数相等时保留，否则整簇替为等宽 `?`。单列边框回退复用 ASCII 边框字符。映射中缺少 `?` 时使用空格维持列数。已读取的映射在本次会话内固定；外部改变字体后，下次运行才重新探测。映射只表明内核槽位，不保证视觉字形或组合效果；终端需支持 UTF-8。

高级用途可用 `app.glyphMode(GlyphMode.Unicode)` 强制原 Unicode、`GlyphMode.Ascii` 强制 ASCII 投影，`GlyphMode.Auto` 恢复自动选择。`app.terminalGlyphCapabilities()` 返回最近一次设备探测的只读事实，首次运行前为 `None`；覆盖模式不会改变事实。设备投影不改变业务文本、`Frame.cellAt` 或默认纯文本和 ANSI 快照。`snapshot` 和顶层 `render` 可指定 `glyphMode` 控制框架生成标记，默认为离线 Unicode，离线 Auto 也等同 Unicode；Ascii 不把业务文本转码。静态文字可用 `.wrap(TextWrap.Grapheme)` 按实际内容宽度整簇换行，或用 `.overflow(TextOverflow.Ellipsis)` 在水平截断时显示省略标记；显式 Ascii 使用可容纳的点号。四边内边距可分别以 `padding(left: ..., top: ..., right: ..., bottom: ...)` 设置。

未知终端的保守规则针对 XTerm 398 和 XFCE4 Terminal 1.1.4 / VTE 0.80.1 观察到的字符簇推进差异，不检测字体，也不保证任意宿主、字体或 Unicode 版本的实际推进；库内两种宽度计算一致仅是保留条件。

文本属性包括 `bold`、`dim`、`italic`、`underline`、`inverse` 和 `strikethrough`。组件属性链如 `.italic()` 启用属性，`.italic(false)` 显式关闭继承值；`Style` 对应参数默认为 false。文本、显式背景和边框继承这些属性，阴影使用传入的完整 Style。

`examples/colors` 展示命名色、索引色、RGB 和文本属性；在终端中按 `c` 循环三种 RGB 样例，按 `t` 切换属性，按 `q` 退出。


可观察状态与持久组件示例位于 `examples/reactive`。在 SDK 1.2.0 环境中运行 `cd examples/reactive && cjpm run`；按任意键递增，Ctrl-C 退出。源码同时导入 `cjtui`、`cjtui.*` 和 `cjtui.macros.*`，使用 `@Component`、带显式类型和初值的 `@State` 与 `@Bind` 声明绑定。普通表达式按初值求取；对自动更新的属性使用 `@Bind(expr)` 或类型明确的 `{ => expr }` getter。

`Observable<T>` 可由多个视图共享；`set` 和 `notify` 可从后台线程调用，框架在 UI 会话处理绑定。终端循环在无阻塞用户回调时最多每 100 毫秒检查一次更新。可变对象内部的更改由应用同步，并显式调用 `notify`。`Application.post` 将回调投递到会话，`batch` 合并 UI 变更；`startHeadless`、`snapshot` 和 `dispose` 支持无终端消费。`visible(false)` 保留节点与状态但不占布局。`render` 是无终端的完整帧导出，脱离活动会话导出时不运行挂载副作用。焦点、默认动作路由、视口滚动与覆盖层已有上述独立接受的公共实现，具体边界见[交互原语](interaction.md)。


`If(condition, thenBody, elseBody: ...)` 和 `ForEach<T>(items, key, body)` 提供响应式条件与列表；普通 `if` / `for` 只在组件首次构造时执行。它们没有额外布局盒，生成的组件直接进入父节点。`If` 活跃分支可以为空，最多一个根；`ForEach` 每个 key 必须有一个根，复合项使用 `Column` 或 `Row`。key 必须非空且在本组唯一；框架保留数据顺序，不推断排序或数据保留规则。

列表 body 接收 `ListItem<T>`，其中 `key` 固定，`value` 是只读可观察值槽。使用 `Text({ => item.value.name })` 一类 getter，在相同 key 的数据对象替换后自动更新；保留项的节点身份与局部状态不变。删除再加入同一 key 会创建新节点。

在 UI 事件、`post` 或 `app.batch` 中，可通过父组件的 `reference()` 调用 `children()`、`append(child)`、`insertBefore(anchor, child)`、`moveBefore(childRef, anchor)`、`moveToEnd(childRef)` 和 `remove(childRef)`。`children()` 返回已提交直接孩子的独立快照，不暴露内部 marker；批内新插入组件的 `reference()` 要等提交后取得。插入描述须未挂载，同父移动保留身份，跨父移动被拒绝。生命周期回调如需修改结构，通过 `post` 安排下一轮。

显式命令先提交，再协调本轮失效的动态组。协调按组当前占用的物理槽位依数据顺序替换，手动节点与其他组的相对次序保持。例如 `A X B C` 中 `X` 为手动节点，列表反转后为 `C X B A`，删除 `A` 后为 `B X C`；清空后剩 `X`，再加入 `D/E` 为 `X D E`。手动移除声明节点不会修改业务数据，只有后续数据失效或父引用 `notify(ChangeKind.Structure)` 才按最新数据重建。

`examples/dynamic` 是公开 API 的可运行混合构造示例：`cjpm run` 启动终端应用，`target/release/bin/main --smoke` 在无终端模式执行插入、重排及快照。结构错误会停止并清理当前会话；批次保留已完成副作用，不承诺业务事务回滚。`RuntimeLimits` 的节点数、深度、结构操作与稳定轮数预算同样约束动态内容。


结构 API 的失败通过 `UIException.code` 区分：旧引用为 `StaleReference`，失效或外父锚点为 `StaleAnchor`，跨父移动为 `CrossParentMove`，重复挂载或预留为 `AlreadyMounted`，叶子父节点为 `InvalidParent`。动态构造的空 key、重复 key、根数不符分别为 `InvalidKey`、`DuplicateKey`、`ConstructionRootCount`；预算超限为 `CapacityExceeded`，同步更新不稳定为 `UnstableUpdate`。错误 UI 域为 `WrongUIContext`，结构求值重入为 `ReentrantStructure`，求值中写可观察状态为 `ReentrantEvaluation`，生命周期中直接改树为 `LifecycleReentry`。应用 getter、body、事件或挂载回调抛出的普通异常保留原对象与类型；若清理还发生附加失败，使用 `UICleanupException` 聚合报告。

`RichText`、`TextSpan` 和 `TextStylePatch` 提供不可变富文本；`parseAnsiText` 或增量
`AnsiTextDecoder` 显式将有界 ANSI 输入转换为安全文本及诊断，普通 String 入口仍严格
拒绝控制字符。整篇字符簇、布局、绑定与 Frame 路径共享，组件显式属性逐字段覆盖 span。
API、样式优先级、限制及错误见[富文本说明](rich-text.md)，示例见 `examples/rich-text`。

Label/Button/Checkbox/Radio/Progress用法见[基础控件](widgets.md)，证据见[有限S归档](../reviews/widgets/S/README.md)；新native覆盖ASCII/default Classic，完整展示027/041另汇合。
