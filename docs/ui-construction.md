# cjtui 用户构造设计与场景契约

## 1. 文档目的与状态

本文说明应用作者如何组织界面、业务状态和事件，并投影已实现的公共构造契约。需求见 [需求说明](requirements.md) REQ-001–003；可运行入口和使用说明见 [产品文档](product/README.md)、[组合应用](product/composition.md)。本文仍是开发契约，不表示发布。

本次固定源码为 `d7e9d1445f98021a798d223de97b97b45239de93`。历史 c862 的 `src/`、`native/`、`examples/`、`build.cj`、根 `cjpm.toml` 与已接受的 `f48ca45608247f52a6876ad5c27b4ca36867f406` 分别具有相同 Git 对象；D7 仅改变 `src/application.cj` 的 `run()` 内部输入超时行为，公开签名及其余上述范围不变。下文第 9–12 节和 [construction-map.json](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/Linux-final/construction-map.json) 记录实际签名、来源、消费者、错误和证据范围；第 2–8 节保留总体使用目标。U1–U5 已有 [AC-021 冻结 M1 验收](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/R22/021/README.md)，四主题展示已有 [AC-027 冻结 M1 验收](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/R22/027/completed/README.md)。两者不能自行关闭原 AC-004、全部 Linux 或发行验收。最终消费者绑定及原 AC-004 独立审核/验收仍为 pending，任务状态仍由 OpenSpec `complete-linux-integration/tasks.md` 2.1.4 管理。
## 2. 统一构造模型

| 用户操作 | 设计契约 | 框架承担的工作 |
|---|---|---|
| 用组件块嵌套容器和内容 | 声明逻辑层次，不手算全屏位置 | 挂载、协调节点、布局与裁剪 |
| 用属性链设置布局和外观 | 同一构造方法的参数配置，具有默认与显式复位语义 | 解析样式、能力映射与失效 |
| 绑定仓颉可观察状态 | 保留计算规则及依赖；业务数据仍归应用 | 订阅、调度、合批更新与解除 |
| 提供仓颉事件回调 | 目标只在有效挂载与输入域内接收事件 | 键盘路由、模态隔离和生命周期检查 |
| 封装自定义组件 | 参数、绑定和事件通过公开契约传入 | 与内置组件共享节点和渲染路径 |
| 通过统一应用入口运行 | 可配置主题、能力策略及受控调度入口 | 输入、刷新、设备会话及退出恢复 |

普通开发不要求直写 stdout、发送 ANSI、手动擦屏、操作缓冲或 flush。高级绘制使用受控局部上下文，不能突破字符/裁剪/层规则。

## 3. 语法支持矩阵

| 构造形式 | 目标行为 | 验证门槛 |
|---|---|---|
| 组件块 + 属性链 | 以嵌套表达层次，以链配置属性和事件 | 真实原始源码经正式入口构建 |
| 状态声明与表达式绑定 | 修改可观察状态使相关表达式重新计算 | 文本、样式、布局与显隐变化均验证 |
| 条件构造 | 条件改变能挂载/卸载对应内容 | 订阅与引用按生命周期清理 |
| 列表构造与稳定 key | 重排后节点局部状态随身份而非位置移动 | 重排、增删与无效 key 诊断 |
| 自定义组件 | 同一组件用于容器和覆盖层 | 无私有 API 或内核特判 |
| 事件回调 | 关联仓颉业务动作与受控组件操作 | 禁用、卸载与模态域边界明确 |

不承诺完整 ArkTS/ArkUI SDK。原平台属性不存在时应诊断；合法但终端受限的效果按公开策略降级。字体、像素画布、CSS 与平台服务不在当前范围。

## 4. 五个用户验收场景

### U1：最小应用

目标是从一个统一入口构造带样式文本。应用只需描述内容与可选样式，框架提供默认主题、合理尺寸规则和刷新管理。验收检查入口样板、是否必须设置全屏坐标，以及退出是否恢复框架修改的终端状态。

### U2：常规应用

界面由水平菜单、主体容器和状态条组成，使用横纵/弹性布局及统一主题。菜单能够键盘导航，禁用项不能被误选，状态条参与正常尺寸分配。空间不足时按冻结规则截断、裁剪或限制最小尺寸，不允许每个组件自行发控制序列修补布局。

### U3：动态应用

后台任务提交业务进度和状态，页面绑定对应文本/颜色。短文本替代长文本后不留残留，仅颜色变化也可见。多次状态变化允许合批处理；多视图共享业务状态，局部焦点或展开状态由各自节点保留。应用无需追加手动刷新。

### U4：组合与多层应用

同一个用户面板分别用于普通容器与带圆角阴影的模态弹窗。弹窗可打开弹出菜单，再出现模态确认；关闭父层应关闭附属层，输入只进入允许的域。原触发节点卸载时关闭恢复必须选择有效回退，底层业务状态在遮挡期间继续更新，关闭后显示最新画面。

### U5：不同业务的泛化应用

选择不同于示例业务的布局与状态，仍使用相同公共组件、绑定和事件能力构造。验收不是增加另一个演示专用入口，而是证明公开接口可组合、默认值合理、用户自定义组件不需要访问私有节点或修改内核。

## 5. 组件参数、状态与样式规则

组件参数必须明确哪些是不可变输入、哪些绑定可观察值、哪些是回调、哪些是局部状态。外部业务对象不依赖特定窗口存在；节点卸载仅释放框架资源，不销毁应用数据。受控引用允许焦点/滚动等已定义操作，但不能当永久有效裸指针。

样式的来源与优先级遵循需求 REQ-001.6，不另定义顺序。同一参数在内置/用户组件、普通容器/弹窗和低层绘制/高层构造之间保持相同语义。圆角是字符边框，阴影扩大绘制而非默认布局/命中，实际字形由终端字体决定。

## 6. 构造便利性评审

| 维度 | 检查问题 | 不能接受的替代证据 |
|---|---|---|
| 入口 | 能否用公开统一入口启动并清理？ | 内部测试绕过应用生命周期 |
| 布局 | 普通界面是否要求计算全屏坐标？ | 演示把坐标硬编码而声称方便 |
| 更新 | 是否有隐含手动刷新或状态复制步骤？ | 业务回调每次显式 flush |
| 封装 | 参数/状态/事件是否可复用？ | 为不同宿主复制组件源码 |
| 组合 | U4/U5 是否需要内核特判？ | 内置大量一次性组件 |
| 诊断 | 不支持语法/属性是否能定位？ | 静默忽略而让运行看似成功 |

代码行数只是辅助观察，不以压缩可读性换取低行数。问题按 Battle 契约和证据处理，不虚构反对意见。

## 7. 冻结交付与验收引用

TASK-002 负责真实语法和限制，TASK-003 负责依赖适配，TASK-004 汇合公共构造签名、模块、状态/事件、诊断与普通入口。TASK-021 的公开示例已落地；本次依据固定源及独立既有证据整理接口，不新建 API，不把已接受的分段契约退回未设计状态。

本文件与总体架构共同构成任务输入。已实现签名以下述源码投影为准；证据不足的最终范围保持 pending。产品手册位于 docs/product/；本文和评审映射按根清单排除于产品包，不成为运行依赖。

## 8. 动态视图、通知与基础组件

开发者在编码期用仓颉编写界面与业务回调；运行期动态组合执行已编译视图逻辑，不要求读取执行新源码。尾随 Lambda 优先承载块嵌套，属性链配置返回的描述；框架仍需收集子元素、保持节点身份和绑定依赖。

视图可在已有容器的同一子序列中按指定位置增删移动元素，声明式子组件与 API 元素共同参与布局/交互，不要求独立容器或独立区域。数据排序和保留由应用处理；节点操作只改变视图。响应式绑定与显式通知共用自动调度，通知可定向内容、样式、布局和结构。内置基础组件范围见 REQ-001.8，统一服从公开状态/事件/样式契约。

新增验收责任如下；这是场景定义，具体实现和验证状态以 [验收矩阵](acceptance.md) 对应 AC 为准，不将这些已分段实施的能力笼统标为 planned：

| 场景 | 用户动作 | 必需结果 |
|---|---|---|
| U6 动态混合 | 声明 A/B/C，视图代码插入 X、移动/移除及卸载父容器 | 同一序列按调用指定排列，不排序数据；生命周期/焦点正确，无私有 API |
| U7 通知与大数据 | 后台处理完成后定向通知数据绑定/组件 | 合批更新相关呈现，不手动 flush，不阻塞键盘；性能不因全数据遍历冒充局部 |
| U8 编辑与缩放 | 输入中文/emoji，键盘选择撤销，固定小视口与resize | 字符簇完整，Enter按模式，内容可滚动，显隐不由框架决定 |
| U9 主题展示 | 同一组件展示应用切换四主题并显式重载坏配置 | 成功更新外观，坏配置保留原主题和编辑/焦点；无自动监听 |
| U10 可选会话 | SSH下请求本地剪贴板、标题、图片图标 | 按终端能力报告；未知不伪称成功，无图形扩展仍可运行核心界面 |

U1–U5 继续保留并由 TASK-021 承担整体公开构造验收；U6–U10 仅细化新增责任，映射 TASK-025–032 / AC-025–032，不意味着增加五套演示专用内核。

## 9. 实际源码、包与普通构建入口

示例采用 SDK 1.2.0 的普通 CJPM 项目，依赖 `cjtui = { path = "../.." }`。在 `examples/minimal`、`examples/composition` 或 `examples/theme_showcase` 内执行 `cjpm build`，随后在终端执行 `target/release/bin/main`。`--smoke` 是有限 headless 检查；它不验证交互输入、终端能力或模式恢复。SDK、stdx、UCD/native 和依赖缓存前置见 [产品说明](product/README.md) 与 [native 构建](product/native-build.md)。这里记录可复现入口，本次没有执行构建或运行。

| 场景 | 实际调用来源 | 公共构造与责任 | 既有执行及边界 |
|---|---|---|---|
| U1 最小应用 | `examples/minimal/src/main.cj` | `Application(Column { Text(...).foreground(...); Row { ... } })`；`onKey` 中 q→`stop`，`run` 管理会话 | AC-021 已独立构建、smoke/PTY/实际宿主；原始业务源码及 manifest 与当前一致，core 后有 M2 变化，不冒称最终重新执行 |
| U2 常规应用 | `examples/composition/src/{main,application_view,tasks_scene,commands}.cj` | `HorizontalMenu`、弹性主体、`StatusBar`；禁用项、`SplitPane`、`loadTheme` | AC-021 菜单/布局/主题；AC-027 补全部控件及四主题展示；当前 D141 提供受限最终源展示运行 |
| U3 动态应用 | `examples/composition/src/{job_data,commands,tasks_scene}.cj` | `spawn` 计算后 `post(owner, action)`；`Observable` getter 绑定 Text/Progress/颜色 | AC-021 验证 50005000/333383335000、长短文本与仅颜色变化；showcase 的 Run 只置 Pending，不替代真实 worker 证明 |
| U4 组合、多层 | `examples/composition/src/{job_panel,tasks_scene,commands}.cj` | 同一 `JobPanel` 类型的新实例用于普通区与圆角阴影模态层，`PopupMenu` 再开确认层 | AC-021 验证共享业务状态、独立 controller、关闭层/焦点/编辑状态；当前 D141/142 补最终 core 的层、caret、尺寸和恢复范围 |
| U5 泛化应用 | `examples/composition/src/{logs_scene,job_data,application_view}.cj` | Logs 场景使用相同 TextInput/Checkbox/Radio/ScrollView/ForEach；业务自行筛选/排序 | AC-021 验证不同于 Tasks 的日志业务；不是新增演示专用内核或强制文档模型 |

普通路径只描述逻辑顺序、尺寸约束与回调，无需屏幕坐标、私有 `RuntimeNode`、ANSI、擦屏或 `flush`。当前公开示例源和核心中没有按 JobPanel/TasksScene/LogsScene/GalleryView 名称分支的业务特判。高级 `Canvas` 的局部坐标、`Frame`/snapshot、受控滚动内容坐标和能力 override 是可选入口，不是 U1–U5 的前置步骤。

## 10. 固定公共签名与语法边界

下表为固定源码的实际签名；全部关联声明（含重载、命名参数/默认值、文件/行号和 hash）见 [机器映射](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/Linux-final/construction-map.json) `api_groups` 与 `source_bindings`。`cjtui.*` 导出常用构造；源码按 `cjtui`、`cjtui.geometry`、`cjtui.style`、`cjtui.text`、`cjtui.theme` 分责，宏位于编译期 `cjtui.macros`。

| 能力 | 实际签名/形式 | 源文件 |
|---|---|---|
| 块与链 | `Column(body: () -> Unit): Component`、`Row(body: () -> Unit): Component`、`Text(value: String): Component` / `Text(value: () -> String): Component`；另有 RichText 重载 | `src/component.cj` |
| 属性与绑定 | `foreground(value: Color): Component` / `foreground(value: () -> Color): Component`；尺寸/显隐/样式也有 typed 常量与 getter 重载 | `src/component.cj` |
| 自定义组件 | `Component` 子类 `public override func build(): Unit`；字段初始化后调用一次 `protected func finishConstruction(): Unit` | `src/component.cj`；实际 `JobPanel`/`LogsScene` |
| 可选宏 | `public macro Component(input: Tokens): Tokens`、`State`、`Bind`；`@State var x: T = value` 生成 Observable 存储和仓颉属性，`@Bind(expr)` 生成 getter | `src/macros/{component_macro,state_macro,bind_macro}.cj` |
| 状态 | `Observable<T>(initial: T)`；`get(): T`、`set(value: T): Unit`、`notify(): Unit` | `src/observable.cj` |
| 条件 | `If(condition: () -> Bool, thenBody: () -> Unit, elseBody!: () -> Unit = {=>}): Unit` | `src/conditional_declaration.cj` |
| 列表 | `ForEach<T>(items: () -> Array<T>, key: (T) -> String, body: (ListItem<T>) -> Unit): Unit`；body 读取 `row.value` | `src/foreach_declaration.cj`、`src/list_item.cj` |
| 菜单和主体 | `HorizontalMenu(items: Array<MenuEntry>, onChoose: (String) -> Unit): Component`，另有 getter items；`StatusBar(body: () -> Unit): Component`；`SplitPane(axis!: SplitAxis = SplitAxis.Horizontal, body!: () -> Unit): Component` | 各实体文件 `horizontal_menu.cj`、`status_bar.cj`、`split_pane.cj` |
| 控件与编辑 | `Progress(fraction: () -> Float64): Component`，另有常量重载；`TextInput(value: Observable<String>, controller!: ?TextEditController = None, limits!: TextEditLimits = TextEditLimits(), onChange!: (String) -> Unit = {_ =>}, onSubmit!: (String) -> Unit = {_ =>}, onIssue!: (TextEditIssue) -> Unit = {_ =>}): Component`；TextArea 无 onSubmit | `src/{progress,text_input,text_area,text_edit_controller}.cj`；[控件](product/widgets.md)、[编辑](product/text-editing.md) |
| 挂载与事件 | `onMount(effect: (NodeRef) -> (() -> Unit)): Component`、`onKey(handler: (UIKeyEvent) -> Unit): Component`、`Application.onKeyEvent(handler: (UIKeyEvent) -> Unit): Application` | `src/component.cj`、`src/application.cj` |
| 调度 | `Application.post(action: () -> Unit): Bool` / `post(owner: NodeRef, action: () -> Unit): Bool`；`batch(action: () -> Unit): Unit` | `src/application.cj` |
| 层 | `NodeRef.openOverlay(content: Component, options!: OverlayOptions = OverlayOptions()): OverlayHandle`；`OverlayHandle.close(): Unit` | `src/{node_ref,overlay_options,overlay_handle}.cj` |
| 主题 | `Application.loadTheme(source: ThemeSource): ThemeRequest`、`reloadTheme(): ThemeRequest`、`themeInfo(): ThemeInfo`；`ThemeRequest.result(): ?ThemeResult` | `src/application.cj`、`src/theme_request.cj`、`src/theme/` |
| 会话 | `Application(root: Component, limits!: RuntimeLimits = RuntimeLimits(), glyphMode!: GlyphMode = GlyphMode.Auto, theme!: Theme = Theme.preset(ThemePreset.Classic), keyboardLimits!: KeyboardLimits = KeyboardLimits())`；`run(): Unit`、`stop(): Unit` | `src/application.cj`；显式 colorMode 重载仅高级可选 |

块是仓颉尾随 Lambda，属性链配置同一 Component；普通 `if`/`for` 在构造时运行一次，动态分支/列表使用 `If`/`ForEach`。getter 的 Observable 读取保留依赖，普通不可观察变量变更不会自动更新。列表 key 必须非空、同组唯一且稳定；同 key 更新 `ListItem.value`，不以数组下标或业务对象地址替代身份。动态组无额外布局盒，与手动插入节点共用父子序列。

自定义组件可用显式子类，亦可用 `@Component` 自动生成等价构造；显式例子中的 protected `finishConstruction` 是支持的子类入口。宏不支持 open/abstract component、委托构造及直接构造器 return；State 必须是有类型和初值的实例 var。未知组件/方法/属性走真实编译或类型诊断，已知方法用于不合适的 primitive 走运行期校验。采用 ArkUI 约定的构造形式不等于兼容 ArkTS、ArkUI SDK、平台服务或完整 LSP；本次不增加编辑器验证承诺。

## 11. 状态、错误与生命周期契约

业务数据、组件描述和挂载节点分别拥有生命周期。同一组件类型的多个新实例可共享 Observable；编辑 controller 等局部资源由实例持有。同一个 Component 实例不得同时挂载两处。`onMount` 获取有效 `NodeRef` 并返回清理；卸载先撤引用/订阅/owner post，再尝试清理，不能因保留旧引用而复活已卸载节点。getter 替换或依赖改变会解除旧订阅。

UI 事件、batch 与已投递 post 在统一执行域内运行。后台计算使用 `post(owner, ...)` 进入 UI；返回 true 只表示入队，owner 随后失效则回调取消，队列满/会话停止或失效返回 false。批处理合并失效，不回滚应用业务值。挂载/清理中直接改树、请求焦点或重入 dispose 有限制；需要后续 UI 动作时投递下一 turn。普通运行由 `run()` 负责输入、布局、合成、差分刷新和 finally 清理；headless 的 `startHeadless/snapshot/dispose` 是独立的验证/导出入口。

层的 owner 决定生命周期，host 决定位置与裁剪；`OverlayOptions` 默认 NonModal、Center、closeOnEscape=true、takeFocus=true。Modal 不允许 takeFocus=false，Passive 不允许 takeFocus=true，非居中定位需合法 anchor。关闭父层关闭其附属层；模态域内未处理事件不穿透下层应用动作；恢复有效焦点并呈现底层最新状态。详见 [公共交互](product/interaction.md)。

| 失败类别 | 固定接口与处置 |
|---|---|
| 构造/参数/身份 | `UIException.code: String`：如 `InvalidProperty`、`InvalidKey`、`DuplicateKey`、`ConstructionRootCount`、`AlreadyMounted`、`StaleReference`；负尺寸等也可能是 `IllegalArgumentException`，不承诺所有失败都是 UIException |
| 结构/执行域 | `StaleAnchor`、`CrossParentMove`、`InvalidParent`、`SessionInactive`、`WrongUIContext`、`LifecycleReentry`、`ReentrantEvaluation`、`ReentrantStructure`、`CapacityExceeded`、`UnstableUpdate`；明确失败，不静默追加或无限重试 |
| 层/焦点 | `InvalidOverlayHost`、`InvalidOverlayAnchor`、`FocusOutsideDomain` 及非法选项异常；失效引用不得继续操作 |
| 用户回调/清理 | 用户异常保持对象/类型；额外清理失败使用 `UICleanupException.primary` 与有序 `cleanupFailures`，不伪造业务回滚 |
| 主题 | 同步 parse/read 抛 `ThemeException`；异步请求为 `Applied`、`Failed`、`Superseded`、`SessionClosed`，失败不改活动主题/编辑状态 |
| 终端与可选宿主 | 输出失败不提交成功基线，按已支持重同步契约重绘或停止输出；可选剪贴板/标题/图片图标返回结构化 SessionResult，Unknown/SentUnconfirmed 不冒充已应用；内部设备异常类型不是必需公共依赖 |

布局/富文本/样式/控制字符规则分别见 [交互](product/interaction.md)、[富文本](product/rich-text.md)、[主题](product/theme.md)、[会话](product/session.md)。能力退化遵循字符终端边界；受限字体、像素图形、外部 CSS 和平台服务不因签名存在而获支持。

## 12. 证据复用与最终待验范围

[construction-map.json](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/Linux-final/construction-map.json) 固定每个 U 场景的消费者/source blob/SHA-256、签名、模块、错误、生命周期和证据；这是源码/证据投影，不是新执行。依据 AGENTS §11.1：

- AC-021 原接受源 `e3016afe`/main `c190e6f9` 的 minimal/composition 业务源码与 manifest 均与当前相同；原运行仍标历史 M1，不能因接口不变把已改变的 core 当作旧执行。
- AC-027 原接受源 `b5de3dd6` 的 showcase 源码/manifest 与当前相同；保留四主题、文件失败、编辑/焦点/滚动和 VTE 的原范围。Run=Pending 与真实 worker 分开。
- 历史固定 core `f48ca456` 的 [D141 执行](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/R24/D/browse/incremental-composition-execution/report.md) / [D142 独立接受](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/R24/D/browse/incremental-composition-acceptance/report.md) 提供普通 showcase 构建、XTerm/VTE 实际运行及组合/输出恢复证明。D 的 composition consumer 位于 tests/incremental_composition，不能误写为最终 examples/composition 构建。原 VTE F10 截获失败保留；成功配置为 `ShortcutsNoMenukey=TRUE`。
- 历史 R12 宏正/负编译证据和 R13 条件/列表机制，仅按相同源码对象复用相应范围；不把已变化的运行时套件整体标为当前新执行。TASK145 固定 `c862` 普通包和解包 benchmark 消费证据补包入口，不能替代全部 U1–U5 或 AC-004 验收。

D7 前向范围见映射 `forward_projection`：就绪输入先送入 decoder，真实空闲读取才判定超时；独立输入修复审核确认构造、宏和公开 API 未变，仅准入相应有限复用。旧 f48/c862 包、ELF、原始执行与审核保持原身份，不改写为 D7 新执行；当前普通 D7 CJP 的身份记录也不替代最终公开 minimal/composition 消费者证明。设备/运行时、性能和完整 Linux 仍由原任务独立验收。

原 AC-004 保持 pending：需要独立逐条审核/验收，以及最终 minimal/composition 的固定消费者、构建环境/命令/ELF 与运行绑定，或既有同源接受证据的明确复用裁定。具体入口为上述目录的 `cjpm build`、`target/release/bin/main --smoke` 和既定实际交互序列；应先查已有有效证据，避免重复检查。本角色受 CPU 测量约束没有执行这些命令。最终语法/依赖/平台/发行证据仍由相应原任务汇合；本投影不宣称 Linux、M2 性能、跨平台、发布或完整 SDK/LSP 通过。
