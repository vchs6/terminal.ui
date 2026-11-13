# 公共绘制与交互

`Canvas(measure, draw)` 是通用叶节点。`measure` 使用 `Constraints` 返回内容自然 `Size`；实际尺寸仍受视口约束。`draw` 使用 `PaintContext` 的局部坐标、`size` 和 `clip`，通过 `put` 或 `fill` 绘制，不能取得底层帧。上下文仅在本次同步调用中有效。文本宽度应使用约束或上下文的 `textWidth`；String 和 RichText 使用相同字符簇与裁剪规则。测量与绘制分别跟踪读取的可观察状态，回调须保持只读。

组件可以用 `focusable` 与 `enabled` 的常量或 getter 声明交互资格。应用启动后选择首个可用焦点，Tab 和 Shift-Tab 在可用节点间移动；`NodeRef.requestFocus()` 可在事件、批次或 post 中请求焦点。`focusedNode()` 与 `activeTarget()` 是只读查询。`defaultAction` 提供目标及祖先两个阶段；`preventDefault` 阻止尚未执行的默认动作，`stopPropagation` 只停止用户传播。

聚焦 Canvas 可在 draw 中用 `caret(x, y)` 请求逻辑光标；`Application.caretSnapshot()` 读取最近完成目标帧的结果。无效、裁剪外或宽字符延续单元上的位置会隐藏。设备会自动进行一次有界原始显隐查询；未知原态时不会改变显隐，逻辑可见时仍定位光标。因此未知原态终端可能继续显示原有光标，或不能显示新请求的光标。`terminalCapabilities().cursorVisibilityStatus` 仅提供只读诊断。

`examples/interaction_primitives` 展示普通 Text 默认动作、Canvas 进度与 Canvas caret。运行 `cjpm run` 使用终端，按 `q` 退出；构建后可用 `target/release/bin/main --smoke` 执行无终端快照。完整输入编辑、标准控件与覆盖层能力另行交付。

## 视口与滚动

应用根没有显式声明视口时，默认支持纵向滚动；短内容首先保留普通布局分配，仅当内容在实际尺寸下溢出时才协商滚动内容。`.viewport(ScrollAxes.Off)` 可显式关闭根的默认滚动。一般将可变长度主体放在 `ScrollView { ... }`，将菜单和状态栏留在普通容器中；`ScrollView` 是可聚焦的纵向 `Column` 组合。宽表可使用 `.viewport(ScrollAxes.Horizontal)`，`Both` 同时启用两个轴。

挂载后的 `NodeRef.viewportSnapshot()` 返回上次提交的实际宽高、有限内容尺寸、偏移与轴。`scrollTo` 和 `scrollBy` 返回是否接受了偏移变化；尺寸变化后偏移会重新钳制。`ensureVisible` 使用节点内容坐标，或不带矩形请求整个节点布局盒；可选择 `Nearest`、`Start`、`Center`、`End` 对齐。用户祖先默认动作先执行，未阻止时视口处理方向键、PageUp/PageDown、Home/End；不能继续滚动时事件可交给外层。

`examples/viewport` 展示固定头尾、可滚动主体及可横向滚动的宽表。进入目录运行 `cjpm run`，使用 Tab 切换焦点、方向键滚动、`q` 退出；构建后的 `--smoke` 运行无终端快照。

## 覆盖层

挂载后的节点可在事件、批次或 post 中通过 `NodeRef.openOverlay` 打开另一份未挂载的组件，返回的 `OverlayHandle` 提供关闭、当前内容引用和终态原因。层的逻辑 owner 决定生命周期、事件路径和主题继承；显式 host 只限定位置与裁剪，且须是 owner 或其祖先。普通 `children()` 不包含覆盖层。

`OverlayMode.Modal` 限制键盘焦点与输入域，默认对层的布局盒填充不透明表面；`NonModal` 不限制焦点遍历，`Passive` 不夺取焦点。`surface(SurfaceMode.Transparent)` 可覆盖默认表面意图，但不会取消组件自身或主题明确声明的背景填充。关闭层后显示底层最新状态，而不是打开时的旧画面。Escape 默认关闭最近允许关闭的交互层；未被阻止的 interrupt 仍退出整个应用。

可将同一自定义组件类型的不同实例用于普通区域和层内容，并共享业务 Observable；同一个组件实例不能同时挂载两处。锚定弹层使用 owner 自身或其后代作为 anchor，并受 host 与终端的实际裁剪约束。

`examples/overlay` 展示同一自定义面板类型在普通区域与模态层中的两份实例。运行 `cjpm run` 后按 Enter 打开，按 Escape 关闭；构建后的 `--smoke` 使用无终端快照。
