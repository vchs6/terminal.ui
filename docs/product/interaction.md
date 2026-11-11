# 公共绘制与交互

`Canvas(measure, draw)` 是通用叶节点。`measure` 使用 `Constraints` 返回内容自然 `Size`；实际尺寸仍受视口约束。`draw` 使用 `PaintContext` 的局部坐标、`size` 和 `clip`，通过 `put` 或 `fill` 绘制，不能取得底层帧。上下文仅在本次同步调用中有效。文本宽度应使用约束或上下文的 `textWidth`；String 和 RichText 使用相同字符簇与裁剪规则。测量与绘制分别跟踪读取的可观察状态，回调须保持只读。

组件可以用 `focusable` 与 `enabled` 的常量或 getter 声明交互资格。应用启动后选择首个可用焦点，Tab 和 Shift-Tab 在可用节点间移动；`NodeRef.requestFocus()` 可在事件、批次或 post 中请求焦点。`focusedNode()` 与 `activeTarget()` 是只读查询。`defaultAction` 提供目标及祖先两个阶段；`preventDefault` 阻止尚未执行的默认动作，`stopPropagation` 只停止用户传播。

聚焦 Canvas 可在 draw 中用 `caret(x, y)` 请求逻辑光标；`Application.caretSnapshot()` 读取最近完成目标帧的结果。无效、裁剪外或宽字符延续单元上的位置会隐藏。设备会自动进行一次有界原始显隐查询；未知原态时不会改变显隐，逻辑可见时仍定位光标。因此未知原态终端可能继续显示原有光标，或不能显示新请求的光标。`terminalCapabilities().cursorVisibilityStatus` 仅提供只读诊断。

`examples/interaction_primitives` 展示普通 Text 默认动作、Canvas 进度与 Canvas caret。运行 `cjpm run` 使用终端，按 `q` 退出；构建后可用 `target/release/bin/main --smoke` 执行无终端快照。完整输入编辑、标准控件与后续视口和覆盖层能力另行交付。
