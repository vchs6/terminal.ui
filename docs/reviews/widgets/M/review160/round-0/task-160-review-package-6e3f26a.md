# TASK160 full finite review package
BASE 9ec836cef9c137b87c928a049aa8452b3a83b301
HEAD 6e3f26aaaeee9442fde91ce31d720a841eeda473
Author report/self-assessment excluded; contracts, exact tests, full diff and raw-only evidence supplied separately.


6e3f26aa test(widgets): publish complete PTY observations before fence
2e174879 test(widgets): enforce unanswered PTY probe mode policy
d9e70985 test(widgets): expand native indexed string update
c2d641fc test(widgets): make custom theme state inheritance explicit
bbec24cb test(widgets): distinguish local role fill from global seed
8da21359 test(widgets): install modal shortcuts on content roots
a757be12 docs: align current product overview and Linux execution pointers
4aa07649 test(widgets): correct collector mounting and public notify kind
6f7d6fee Implement composite widget factories


 docs/linux-completion-plan.md                     |   2 +-
 docs/product/README.md                            |  10 +-
 docs/product/widgets.md                           |   6 +-
 docs/tasks.md                                     |   2 +-
 examples/widgets_composition/cjpm.toml            |   8 ++
 examples/widgets_composition/src/main.cj          |  47 ++++++++++
 openspec/linux-completion-progress.md             |   2 +
 src/horizontal_menu.cj                            |  13 +++
 src/menu_composition.cj                           |  87 +++++++++++++++++
 src/menu_entry.cj                                 |  15 +++
 src/menu_refs.cj                                  |  28 ++++++
 src/popup_menu.cj                                 |  14 +++
 src/split_axis.cj                                 |   5 +
 src/split_pane.cj                                 |   9 ++
 src/status_bar.cj                                 |   5 +
 tests/widgets_composite/COVERAGE.md               |   6 +-
 tests/widgets_composite/README.md                 |   2 +-
 tests/widgets_composite/device/src/main.cj        |  76 +++++++++------
 tests/widgets_composite/expected.json             |  22 ++++-
 tests/widgets_composite/fixtures/local-theme.toml |   1 +
 tests/widgets_composite/pty.py                    |  35 ++++++-
 tests/widgets_composite/pty_fence_selftest.py     | 109 ++++++++++++++++++++++
 tests/widgets_composite/pty_mode_selftest.py      |  60 ++++++++++++
 tests/widgets_composite/run.sh                    |   2 +
 tests/widgets_composite/src/composition_cases.cj  |  40 ++++++--
 tests/widgets_composite/src/identity_cases.cj     |   7 +-
 tests/widgets_composite/src/interaction_cases.cj  |  21 +++--
 tests/widgets_composite/src/overlay_cases.cj      |  44 ++++++---
 28 files changed, 602 insertions(+), 76 deletions(-)


diff --git a/docs/linux-completion-plan.md b/docs/linux-completion-plan.md
index 7142e8e6..3afeb8e8 100644
--- a/docs/linux-completion-plan.md
+++ b/docs/linux-completion-plan.md
@@ -50,11 +50,11 @@ TASK-006、011、012 及既有支持任务保持已验范围，不重新实现
 - **Ruling L004:** 优先原生尾随 Lambda 与已实证宏、标准仓颉构建；不新增语言运行时或手写完整 TOML/Unicode/ANSI 内核。宏 @Component/@State/@Bind 的精确源码与支持限制在运行时变更冻结。
 
 - **Ruling L005:** M2124前冻结完整功能M1库及041已冻结设备/ABI/输入输出/尺寸/恢复子接口；原041包含全组件/M2/全部宿主的最终验收在M2后汇合，不能反向作124前置。008/020的M1实际恢复条件保留，原041不提前关闭。
 
 - **Ruling L006:** I015查询/显隐恢复需要Session S008唯一writer实际输入。顺序明确084→有限148–152→Glyph097→Theme088/092→A098–102→B/C→Keyboard/Editing。152不提前关闭完整030/020/041，不依赖A，无环。Unknown自动保留原显隐，已知报告才管理；600ms一次异步窗口，细节以interaction I015为准。
 
 - **Ruling L007:** R14实际GUI越行由canonical2列与host4/1列冲突证实，纯Glyph投影163–167先行阻塞083/084；使用已规划G005/G007/G010同一owner，完整094仍在084/152后扩native/map/publicAPI，避免094↔084环。逻辑Unicode不变，默认设备自动保守等宽呈现，细节见projection change；1113ba18独立规划preflight通过，163正式测试在执行，164仍等fixed163。
 
 ## 当前执行入口
 
-当前：[设备字形投影163–167](../openspec/changes/fix-uncertain-glyph-advance/tasks.md)正修复R14真实GUI推进不相容；163正式RED已固定，fresh164独立产品作者实施中。富文本91的typed/decoder/kernel检查和独立082已通过，但083物理失败未关闭，084/Session149仍等待；修复后复验并按L006继续Session→Glyph→Theme→交互→编辑/控件→完整M1/M2→全Linux制品和验收。全阶段恢复日志：[Linux总执行日志](../openspec/linux-completion-progress.md)。本索引不另维护TASK状态。
+当前：main `83b264db784af638f3c6554bef595316ecdb0e3c` 已记录[标准控件正式测试158及159实施进展](../openspec/changes/implement-standard-widgets/tasks.md)：固定测试原 `e59d5c9f` 对应main `9ec836ce`，前置成功及真正目标缺API RED已交付；159由独立Terra/high角色实际实施，160–162等待前序固定产物。已接受的A/B/C/K/E/S有限证据按原范围复用，未把M测试交付当M行为通过。后续顺序保持完整功能M1/027集成→M2局部布局绘制与对照基准→最终Linux023/024等门槛；完整Linux尚未验收。上文裁决中的阶段状态为历史记录，当前唯一任务状态见各change tasks；本索引不另维护复选框。全阶段恢复日志：[Linux总执行日志](../openspec/linux-completion-progress.md)。
diff --git a/docs/product/README.md b/docs/product/README.md
index 20f7e5e0..f2c12d84 100644
--- a/docs/product/README.md
+++ b/docs/product/README.md
@@ -1,28 +1,28 @@
 # 产品说明
 
-单/多行公共编辑见[TextInput/TextArea](text-editing.md)；[有限E独立验收、原件与真实截图](../reviews/E/README.md)接受E001–E005，完整Linux/父AC仍待汇合。
+当前已接受公共 Canvas/焦点/caret、视口滚动与覆盖层，使用方法见[交互原语](interaction.md)，独立证据分别见[A绘制与焦点](../reviews/interaction/A/README.md)、[B视口与滚动](../reviews/interaction/B/README.md)、[C覆盖层](../reviews/interaction/C/README.md)。归一化键盘/paste已获[有限K验收](../reviews/K/README.md)；单/多行[TextInput/TextArea](text-editing.md)已获[有限E验收](../reviews/E/README.md)。这些已接受范围不等于完整Linux验收。
 
-公共绘制、焦点和 caret 见 [交互原语](interaction.md)。键盘事件、粘贴与限制见 [键盘输入](keyboard-input.md)，示例位于 `examples/keyboard`。主题配置、解析和显式加载见 [主题配置](theme.md)。可选会话复制、宿主标题与恢复结果见 [会话扩展](session.md)，正常公共调用示例位于 `examples/session`。完整发送为 SentUnconfirmed；能力声明不等于宿主效果确认。
+键盘事件、粘贴与限制见[键盘输入](keyboard-input.md)，示例位于 `examples/keyboard`。主题配置、解析和显式加载见[主题配置](theme.md)。可选剪贴板复制、宿主标题与恢复结果见[会话扩展](session.md)，正常公共调用示例位于 `examples/session`；这些可选操作完整发送后仍仅返回 `SentUnconfirmed`，不确认宿主效果，不返回 `Applied` 或 `RestoreConfirmed`。图片图标返回 `Unsupported/NoImageAdapter`。
 
-cjtui 0.0.0 的首个切片提供 Linux ANSI TTY 文本界面：`Text`、`Row`、`Column` 组件块及前景色、背景色和粗体属性，Unicode 字符网格、纯文本与 ANSI 快照、键盘回调和终端尺寸变化时重排。普通应用无需发送 ANSI 或手动刷新。
+cjtui 0.0.0 的历史首个切片提供 Linux ANSI TTY 文本界面：`Text`、`Row`、`Column` 组件块及前景色、背景色和粗体属性，Unicode 字符网格、纯文本与 ANSI 快照、键盘回调和终端尺寸变化时重排。普通应用无需发送 ANSI 或手动刷新。
 
 使用仓颉 SDK 1.2.0，在 Linux ANSI 终端中从源码运行最小示例：
 
 ```sh
 cd examples/minimal
 cjpm run
 ```
 
 按 `q` 退出，Ctrl-C 取消；程序需要实际 TTY。构建依赖及可选离线 Unicode 数据输入见 [原生构建](native-build.md)。
 
-首片采用 `ansies` 1.3.113、`unicode` 0.1.0 和 `unicodewidth` 0.1.113。更多组件、M2 局部更新及完整 Linux 能力仍待实现和验收；Windows、macOS、HarmonyOS 是后续必需目标，尚未实现。当前未发布发行版。
+当前依赖采用 `ansies` 1.3.113、`unicode` 0.1.0 和 `unicodewidth` 0.1.113。基础五控件已获[有限S验收](../reviews/widgets/S/README.md)，新native S证据仅覆盖ASCII/default Classic；Unicode/disabled/explicit palette另有headless与源码证据。菜单/状态栏/分区的[正式测试158已固定，159实际实现中](../reviews/widgets/M/README.md)。M2局部布局与局部绘制尚未实现或验收，不能把现有失效通知和完整帧差分输出当作M2；完整M1集成、027/041展示及最终Linux验收仍待汇合。Windows、macOS、HarmonyOS尚未实现，当前未发布发行版。
 
 低层可用 `Frame(width, height)` 和 `put(x, y, text, style: Style(...))` 写入网格，`cellAt` 查询，`toPlainText` 和 `toAnsi` 导出完整快照。负尺寸与越界查询报错；写入按边界裁剪，拒绝除换行外的控制字符。`render(root, width, height)` 使用同一网格渲染组件树。`Application(root).onKey { event => ... }.run()` 负责终端会话；文本按 Unicode 字符提供，`stop()` 可从回调退出。
 
 低层帧支持 `Frame(width, height, transparent: true)` 创建透明底层，`composite` 按偏移叠加：透明单元跳过，带样式空格覆盖。`clear`、`copy` 和 `resized` 保持宽字符完整；截断的宽字符片段变为保留样式的空格。复制和缩放保留源单元的透明位，新增区域使用源帧的默认空白类型。`writePlainText(path)` 和 `writeAnsi(path)` 写入完整 UTF-8 快照，已有文件会被截断；文件错误向调用方传播。正面积默认最多 1048576 单元，可通过 `maxCells` 显式调整；零面积保留，零宽文本的换行数量也受预算限制。不同字符宽度策略的帧不能合成。
 
 布局可通过组件属性链设置 `width`、`height`、`minWidth`、`minHeight`、`layoutWeight`、`padding`；`widthAuto`、`heightAuto` 清除固定尺寸。`Row` 和 `Column` 还支持 `gap`、`alignItems` 和 `justifyContent`，`Text` 支持逐行 `textAlign`。尺寸与间距以字符列和行为单位，必须非负；实际视口及祖先内容区域限制绘制。正权重在容器主轴上分配剩余空间，余数按最大余数及声明顺序确定。`Alignment` 提供 `Start`、`Center`、`End`、`Stretch`，其中 `Stretch` 仅用于交叉轴对齐。显式背景填充组件外框；文本、裁剪及宽字符使用同一 Frame 规则。
 
 组件可通过 `border(BorderStyle.Rounded)`、`borderColor(Color.Cyan)` 和 `shadow()` 设置字符装饰；`border(BorderStyle.None)` 与 `shadow(enabled: false)` 分别移除效果。边框占外框每边一行或一列，阴影仅扩展绘制范围、不改变布局，并受祖先内容区裁剪。阴影可指定正负偏移及完整 `Style`。未设置边框颜色时使用节点有效前景色；显式背景包含边框与内边距。`BorderStyle` 还提供 `Single`、`Double` 和 `Ascii`；终端宽度策略无法以一列显示某个边框字符时整套回退 ASCII。阴影字符 `░` 非一列时回退 `.`，这不代表检测了字体覆盖。
 
 低层 `Frame.fillRect`、`drawBorder` 和 `drawShadow` 使用相同字符宽度、样式和裁剪规则；填充写入带样式的空格，边框按原矩形几何裁剪。`examples/layout` 展示标题、加权面板和底栏；按 `d` 切换边框及阴影，按 `q` 退出，终端改变尺寸时自动重排。
@@ -37,21 +37,21 @@ cjpm run
 
 未知终端的保守规则针对 XTerm 398 和 XFCE4 Terminal 1.1.4 / VTE 0.80.1 观察到的字符簇推进差异，不检测字体，也不保证任意宿主、字体或 Unicode 版本的实际推进；库内两种宽度计算一致仅是保留条件。
 
 文本属性包括 `bold`、`dim`、`italic`、`underline`、`inverse` 和 `strikethrough`。组件属性链如 `.italic()` 启用属性，`.italic(false)` 显式关闭继承值；`Style` 对应参数默认为 false。文本、显式背景和边框继承这些属性，阴影使用传入的完整 Style。
 
 `examples/colors` 展示命名色、索引色、RGB 和文本属性；在终端中按 `c` 循环三种 RGB 样例，按 `t` 切换属性，按 `q` 退出。
 
 
 可观察状态与持久组件示例位于 `examples/reactive`。在 SDK 1.2.0 环境中运行 `cd examples/reactive && cjpm run`；按任意键递增，Ctrl-C 退出。源码同时导入 `cjtui`、`cjtui.*` 和 `cjtui.macros.*`，使用 `@Component`、带显式类型和初值的 `@State` 与 `@Bind` 声明绑定。普通表达式按初值求取；对自动更新的属性使用 `@Bind(expr)` 或类型明确的 `{ => expr }` getter。
 
-`Observable<T>` 可由多个视图共享；`set` 和 `notify` 可从后台线程调用，框架在 UI 会话处理绑定。终端循环在无阻塞用户回调时最多每 100 毫秒检查一次更新。可变对象内部的更改由应用同步，并显式调用 `notify`。`Application.post` 将回调投递到会话，`batch` 合并 UI 变更；`startHeadless`、`snapshot` 和 `dispose` 支持无终端消费。`visible(false)` 保留节点与状态但不占布局。`render` 是无终端的完整帧导出，脱离活动会话导出时不运行挂载副作用。焦点和覆盖层仍在开发。
+`Observable<T>` 可由多个视图共享；`set` 和 `notify` 可从后台线程调用，框架在 UI 会话处理绑定。终端循环在无阻塞用户回调时最多每 100 毫秒检查一次更新。可变对象内部的更改由应用同步，并显式调用 `notify`。`Application.post` 将回调投递到会话，`batch` 合并 UI 变更；`startHeadless`、`snapshot` 和 `dispose` 支持无终端消费。`visible(false)` 保留节点与状态但不占布局。`render` 是无终端的完整帧导出，脱离活动会话导出时不运行挂载副作用。焦点、默认动作路由、视口滚动与覆盖层已有上述独立接受的公共实现，具体边界见[交互原语](interaction.md)。
 
 
 `If(condition, thenBody, elseBody: ...)` 和 `ForEach<T>(items, key, body)` 提供响应式条件与列表；普通 `if` / `for` 只在组件首次构造时执行。它们没有额外布局盒，生成的组件直接进入父节点。`If` 活跃分支可以为空，最多一个根；`ForEach` 每个 key 必须有一个根，复合项使用 `Column` 或 `Row`。key 必须非空且在本组唯一；框架保留数据顺序，不推断排序或数据保留规则。
 
 列表 body 接收 `ListItem<T>`，其中 `key` 固定，`value` 是只读可观察值槽。使用 `Text({ => item.value.name })` 一类 getter，在相同 key 的数据对象替换后自动更新；保留项的节点身份与局部状态不变。删除再加入同一 key 会创建新节点。
 
 在 UI 事件、`post` 或 `app.batch` 中，可通过父组件的 `reference()` 调用 `children()`、`append(child)`、`insertBefore(anchor, child)`、`moveBefore(childRef, anchor)`、`moveToEnd(childRef)` 和 `remove(childRef)`。`children()` 返回已提交直接孩子的独立快照，不暴露内部 marker；批内新插入组件的 `reference()` 要等提交后取得。插入描述须未挂载，同父移动保留身份，跨父移动被拒绝。生命周期回调如需修改结构，通过 `post` 安排下一轮。
 
 显式命令先提交，再协调本轮失效的动态组。协调按组当前占用的物理槽位依数据顺序替换，手动节点与其他组的相对次序保持。例如 `A X B C` 中 `X` 为手动节点，列表反转后为 `C X B A`，删除 `A` 后为 `B X C`；清空后剩 `X`，再加入 `D/E` 为 `X D E`。手动移除声明节点不会修改业务数据，只有后续数据失效或父引用 `notify(ChangeKind.Structure)` 才按最新数据重建。
 
diff --git a/docs/product/widgets.md b/docs/product/widgets.md
index 8bdf9186..3239e718 100644
--- a/docs/product/widgets.md
+++ b/docs/product/widgets.md
@@ -1,13 +1,17 @@
 # Small widgets
 
 `Label`, `Button`, `Checkbox`, `Radio`, and `Progress` compose with ordinary component blocks and attribute chains. See `examples/widgets_small` for a complete application; press Tab to move focus, Enter or Space to activate, and q to exit.
 
 Captions are single logical lines of plain Unicode text. Text wrapping and clipping follow the normal Text rules. Checkbox and Radio receive getters and issue change requests; the application owns the values and any radio-group exclusivity. A rejected request leaves the display unchanged. Progress accepts a finite fraction from 0 through 1 and has a natural content size of 20 by 1; dimensions can be set by theme or component attributes.
 
 Controls use the normal theme resolver and public `enabled` and `focusable` attributes. `visualStates` replaces the control's declared visual-state slot, so a later call can override Checkbox or Radio's selected appearance without changing its behavior. Similarly, a later Target `defaultAction` replaces the built-in activation action. Use `onKey` or `onKeyCapture` to observe or prevent an activation. Explicit style attributes override theme values. Simulated visual states do not change focus or enabled behavior.
 
-StatusBar is outside this small-widget delivery. Its specified composition is a natural-height Row, placed by the application's layout rather than automatically fixed to the bottom.
+`HorizontalMenu` and `PopupMenu` accept an array of `MenuEntry(key, label, enabled: true)` values or a getter returning one. Keys must be nonempty and unique; the application owns the order and responds to `onChoose(key)`. Horizontal menus navigate with Left and Right, popup menus with Up and Down; Home and End focus the first and last enabled entry. Tab follows the ordinary focus order. Enter or Space requests a choice without changing the model.
+
+`PopupMenu` is reusable opaque content. It may be embedded in a layout or opened with `owner.openOverlay(popup, options: ...)`. Choosing an entry does not close the overlay; retain the returned handle and call `handle.close()` in the application when desired. Escape and focus restoration follow the ordinary overlay options.
+
+`StatusBar { ... }` is a natural-height Row placed by the application's layout, not automatically fixed to the bottom. `SplitPane { ... }` composes children in a Row; `SplitPane(axis: SplitAxis.Vertical) { ... }` uses a Column. Set weights and dimensions using ordinary attributes. See `examples/widgets_composition` for a menu, split and status bar together.
 
 Unsupported attributes keep the underlying primitive's error contract. On Text-root controls, the existing constant `gap`, `alignItems`, and `justifyContent` shortcuts throw `IllegalArgumentException` and leave the previous setting intact; the existing container `textAlign` and invalid Stretch boundaries also retain their original behavior. Unsupported typed `setStyle`, getter attributes, and resolved named or Inline styles throw `UIException` with code `InvalidProperty`; so does `wrap` on Progress. Unsupported fields in theme configuration report `UnsupportedProperty`, while invalid programmatic style values retain their `IllegalArgumentException` boundary. Invalid Progress fractions report `InvalidProperty`.
 
 To supply an initial custom theme, pass it to `Application(root, theme: theme)` before starting the application. Use `loadTheme` for changes after a session is active; a pre-start load returns `SessionClosed`.
diff --git a/docs/tasks.md b/docs/tasks.md
index c50d79f8..9eab8a79 100644
--- a/docs/tasks.md
+++ b/docs/tasks.md
@@ -542,21 +542,21 @@ Linux布局/装饰实施：TASK-011/012状态及替代前置仅见[implement-lay
 颜色/属性实施TASK-006与独立测试061、审核062、执行063、验收064唯一状态见[颜色与样式变更](../openspec/changes/implement-color-style-output/tasks.md)。
 
 自动终端能力与跨终端截图调查TASK-065随[颜色与样式变更](../openspec/changes/implement-color-style-output/tasks.md)，用户新裁决覆盖其旧显式默认；原实现记录不作新自动验收证据。
 
 真实跨终端测试与截图采集TASK-066依[颜色样式D031–33](../openspec/changes/implement-color-style-output/design.md)独立测试角色编写，真实host执行由TASK063负责，状态只见该change。
 
 ## Linux 全阶段连续实施
 
 持久运行时支持TASK071–080唯一状态在[reactive-runtime tasks](../openspec/changes/implement-reactive-runtime/tasks.md)。014/015/016/032本表原完整AC保持；构造/绑定子接口分阶段交付，列表/混合结构由R13验收；014跨弹窗已由C-05同类型组件普通/覆盖层两实例及干净公开例子验证，见C独立验收。精确接口与分段前置见该design第6节。
 
-当前用户要求完成全部 Linux；[总执行计划](linux-completion-plan.md)与[恢复日志](../openspec/linux-completion-progress.md)协调全部稳定任务，不维护第二份完成复选框。TASK-067–070（测试/审核/执行/验收支持）唯一状态在[帧合成变更](../openspec/changes/implement-frame-composition/tasks.md)，对应 AC-067–070。TASK-010 仍由本表维护；文件原语在该增量交付，实际可见覆盖层快照在018后汇合，不提前标完整通过。
+当前用户要求完成全部 Linux；[总执行计划](linux-completion-plan.md)与[恢复日志](../openspec/linux-completion-progress.md)协调全部稳定任务，不维护第二份完成复选框。TASK-067–070（测试/审核/执行/验收支持）唯一状态在[帧合成变更](../openspec/changes/implement-frame-composition/tasks.md)，对应 AC-067–070。TASK-010 唯一复选框与状态已转[complete-linux-integration tasks](../openspec/changes/complete-linux-integration/tasks.md)；本表只保留原范围/依赖与编号映射。文件原语和覆盖层相关既有证据按已接受范围复用，完整010汇合由该收尾变更维护。
 
 有界富文本支持TASK081–084唯一状态在[implement-rich-text](../openspec/changes/implement-rich-text/tasks.md)，对应AC081–084；原009状态同变更，010仍保持实际可见层前置。
 
 主题样式支持TASK085–092唯一状态在[implement-theme-styles](../openspec/changes/implement-theme-styles/tasks.md)，稳定013/025/026/027同变更；013/025及085–088基础范围已独立验收，089真实异步API RED已交，026实施中；027完整展示仍等全部控件，不将基础截图当完整展示。
 
 Linux VT自动字形子接口支持TASK093–097唯一状态在[字形适配变更](../openspec/changes/implement-linux-vt-glyph-fallback/tasks.md)，追踪原041但不转移其全量验收；093–097已按R16有限验收；主题013消费已接受生成标记策略，真实ellipsis布局仍由013/085追加/088验收。
 
 公共交互支持TASK098–112唯一状态在[public-interaction tasks](../openspec/changes/implement-public-interaction/tasks.md)：A绘制/焦点追踪017、B纵横视口追踪037、C覆盖层追踪018；三单位及098–112均完成有限验收，原014/018完整AC已由C-05及父018四项证据关闭；菜单/标准Modal、输入编辑、M2及完整Linux另阶段。
 
 可选会话能力TASK148–152唯一状态在[session-extensions tasks](../openspec/changes/implement-session-extensions/tasks.md)，追踪030并联004/020/041既有接口；copyLocalText同步结果供028编辑消费，不另建剪贴板队列。完整030粘贴与真实SSH仍待实际证据，图片无adapter如实降级。
diff --git a/examples/widgets_composition/cjpm.toml b/examples/widgets_composition/cjpm.toml
new file mode 100644
index 00000000..b89339f1
--- /dev/null
+++ b/examples/widgets_composition/cjpm.toml
@@ -0,0 +1,8 @@
+[package]
+cjc-version = "1.2.0"
+name = "cjtui_widgets_composition"
+version = "0.0.0"
+src-dir = "src"
+output-type = "executable"
+[dependencies]
+cjtui = { path = "../.." }
diff --git a/examples/widgets_composition/src/main.cj b/examples/widgets_composition/src/main.cj
new file mode 100644
index 00000000..9dbd2f4b
--- /dev/null
+++ b/examples/widgets_composition/src/main.cj
@@ -0,0 +1,47 @@
+package cjtui_widgets_composition
+
+import cjtui.*
+
+main(): Int64 {
+    let status = Observable("Ready")
+    let trigger = Array<?NodeRef>(1, repeat: Option<NodeRef>.None)
+    let app = Application(
+        Column {
+            HorizontalMenu([MenuEntry("open", "Open"), MenuEntry("save", "Save")],
+                {key => status.set("Selected: " + key)})
+            Button(
+                "Options",
+                {
+                    =>
+                        let handle = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
+                        let popup = PopupMenu(
+                            [MenuEntry("close", "Close")],
+                            {
+                                key =>
+                                    status.set("Selected: " + key)
+                                    handle[0].getOrThrow().close()
+                            }
+                        )
+                        handle[0] = Some(trigger[0].getOrThrow().openOverlay(popup))
+                }
+            ).onMount(
+                {
+                    ref =>
+                        trigger[0] = Some(ref)
+                        {=> trigger[0] = Option<NodeRef>.None}
+                }
+            )
+            SplitPane(axis: SplitAxis.Horizontal) {
+                Text("First pane").layoutWeight(1)
+                Text("Second pane").layoutWeight(1)
+            }.layoutWeight(1)
+            StatusBar {Text({=> status.get()})}
+        }
+    )
+    app.onKey({
+        event => if (event.text == "q") {
+            app.stop()
+        }
+    }).run()
+    0
+}
diff --git a/openspec/linux-completion-progress.md b/openspec/linux-completion-progress.md
index efa4b4a9..1545e53c 100644
--- a/openspec/linux-completion-progress.md
+++ b/openspec/linux-completion-progress.md
@@ -60,10 +60,12 @@ TASK083独立实际FAIL R14T083001，两真实GUI t delta仅CUP第3行却第4行
 
 测试准备103原da4934b已集成b288dda，31case记录/8明确recipe/actualupstreammissingBLOCKED、无行为RED；108原aa6b1de已集成7d543d2，真实既有baseline0、overlaygate77、无新overlay编译执行/strongRED。A/B/C仍各自actualsource/interface-map准入，准备不是完成。R14执行FAIL667原件、widthrecon current34+history34 PNG与DSR、082scopedPASS已机械归R14，962原件再核；R23 preflight+163外部事实200原件不重复tests内70PNG，roothash再核。未来依次持续，不停有限增量。
 
 2026-11-11 Glyph093–097有限子接口最终PASS：独立095/096/097完成，当前源1f67/rootb3，final09733项矩阵明确30pass+有限P30pass+接口pass/layoutpending+父pending，0C/I/M。R16/execution保留真实kernel7轮/GUI2宿主39原PNG、21PPM、普通uid1000产品及受控GIO失败；P30仅本固定kernel正常组合，不关闭full041等父项。rootfresh1391sourcecopy2782SHA全同。097已封存curated41文件/40index/artifacts603d70f0…，独立机械归档中。Theme085固定原74b1+追加2b16交付已准；013025唯一产品Terra/high ACTUAL GO最终BASE81cd29c/独立theme-implementation源，当前正在实施，不等ThemeGREEN才开始。后续按086087088→089真实RED026→交互/输入/控件→完整M1→M2→finalrelease，不以此次有限通过结束用户全部Linux目标。
 
 2026-11-11 Theme基础013/025、085–088最终独立接受，当前0C/I/M；正常8d包175成员/干净SDK+stdx公开消费、12真实XTerm/VTE原PNG及布局/Glyph前缀证据归R15。root已推已验产品main73abef3（与8d的46产品路径同源），完整矩阵有限复用/来源限制保留。T087-G01 wholechecker仍exit1：themes允许表滞后、composition/benchmark未交付，按既有023.a–d最终必修，不能称release/Linux完成。089真实异步API缺失RED已交；026实现ACTUAL GO，独立源BASE73abef3，数据层checkpoint非完成。下一持续026→090091092→交互A/B/C→输入编辑→控件→完整M1/027→M2→最终Linux门禁，不停在本基础增量。
 
 2026-11-13：异步主题026、公共交互A/B/C已依次完成有限验收；实际状态权威见各change tasks和docs/acceptance。C原产品7f431765经独立112接受并机械集成main283e59b1，产品路径与受检源码字节一致；原014/018完整AC已映射。C独立111正常mandatory bundle/220成员、干净完整公共消费者与公开例子、五PTY及三宿主H01/原生caret均有固定原件。71张最终场景原PNG及125其他历史/瞬时图分类保留；VT Unknown物理隐藏证据不足但符合I015降级，不声称物理隐藏成功。整C原件与验收见[公开归档](../docs/reviews/interaction/C/README.md)。
 
 下一正式工作为Keyboard113冻结复核→114–117，再118–122编辑、153–162控件/菜单、完整M1/027展示、M2及最终Linux023/024等门槛；其他OS仍后置。旧B-M01 getter axes/onMount Off须024关闭；T087-G01最终制品检查仍须023关闭。C历史作者可变索引旧版本未保留和外部编译中间件限制已在112明确，不用新构建冒充旧原件，不影响已固定最终独立111证据。不因此次C有限验收停止用户的完整Linux目标，未发布。
+
+2026-11-13 当前恢复指针：main `83b264db784af638f3c6554bef595316ecdb0e3c` 已公开[正式158报告与固定测试身份](../docs/reviews/widgets/M/README.md)；独立测试原e59d5c9f→main9ec836ce，前置build/direct0和真正缺M目标RED已记录。当前159由fresh独立Terra/high角色在 `/workspace/work/widgets-composite-implementation/source` 实际实施；typing/runtime/headless/native/clean-bundle尚待产品与后续独立角色交付。唯一状态仍在[standard-widgets tasks](changes/implement-standard-widgets/tasks.md)，本日志不另列checklist。下一阶段仍为完整功能M1/027→M2局部布局绘制→最终Linux023/024；M/027/041/Linux未关闭，旧执行指针只保留历史。
diff --git a/src/horizontal_menu.cj b/src/horizontal_menu.cj
new file mode 100644
index 00000000..9bfcfa4a
--- /dev/null
+++ b/src/horizontal_menu.cj
@@ -0,0 +1,13 @@
+package cjtui
+
+public func HorizontalMenu(items: Array<MenuEntry>, onChoose: (String) -> Unit): Component {
+    let copy = Array<MenuEntry>(items.size, {i => items[i]})
+    HorizontalMenu({=> copy}, onChoose)
+}
+
+public func HorizontalMenu(items: () -> Array<MenuEntry>, onChoose: (String) -> Unit): Component {
+    let refs = MenuRefs()
+    Row({=> menuEntries(items, onChoose, refs)})
+        .themeRole(ThemeRole.HorizontalMenu)
+        .defaultAction({event => menuNavigate(event, refs, true)}, phase: DefaultActionPhase.Ancestor)
+}
diff --git a/src/menu_composition.cj b/src/menu_composition.cj
new file mode 100644
index 00000000..83b19a08
--- /dev/null
+++ b/src/menu_composition.cj
@@ -0,0 +1,87 @@
+package cjtui
+
+import std.collection.ArrayList
+
+func menuEntries(items: () -> Array<MenuEntry>, onChoose: (String) -> Unit, refs: MenuRefs): Unit {
+    ForEach<MenuEntry>(items, {entry => entry.key}, {
+        item => Text({=> widgetCaption(item.value.label)})
+            .themeRole(ThemeRole.MenuItem)
+            .focusable(true)
+            .enabled({=> item.value.enabled})
+            .onMount(
+                {
+                    ref =>
+                        refs.add(ref);
+                        {=> refs.remove(ref)}
+                }
+            )
+            .defaultAction({
+                event => if (widgetActivation(event)) {
+                    event.preventDefault();
+                    onChoose(item.key)
+                }
+            })
+    })
+}
+
+func menuNavigate(event: UIKeyEvent, refs: MenuRefs, horizontal: Bool): Unit {
+    if (!refs.contains(event.target)) {
+        return
+    }
+    if (!event.target.isFocused()) {
+        return
+    }
+    let code = event.key.code
+    let previous = if (horizontal) {
+        "left"
+    } else {
+        "up"
+    }
+    let next = if (horizontal) {
+        "right"
+    } else {
+        "down"
+    }
+    if (code != previous && code != next && code != "home" && code != "end") {
+        return
+    }
+    let eligible = ArrayList<NodeRef>()
+    for (child in event.currentTarget.children()) {
+        if (!refs.contains(child) || !child.isValid()) {
+            continue
+        }
+        if (!child.isEnabled()) {
+            continue
+        }
+        if (child.isVisible()) {
+            eligible.add(child)
+        }
+    }
+    if (eligible.isEmpty()) {
+        return
+    }
+    var current: Int64 = -1
+    for (i in 0..eligible.size) {
+        if (eligible[i].sameNode(event.target)) {
+            current = i
+            break
+        }
+    }
+    if (current < 0) {
+        return
+    }
+    var target = current
+    if (code == "home") {
+        target = 0
+    } else if (code == "end") {
+        target = eligible.size - 1
+    } else if (code == next) {
+        target = (current + 1) % eligible.size
+    } else {
+        target = (current + eligible.size - 1) % eligible.size
+    }
+    event.preventDefault()
+    if (target != current) {
+        eligible[target].requestFocus()
+    }
+}
diff --git a/src/menu_entry.cj b/src/menu_entry.cj
new file mode 100644
index 00000000..7fa4a769
--- /dev/null
+++ b/src/menu_entry.cj
@@ -0,0 +1,15 @@
+package cjtui
+
+public struct MenuEntry {
+    public let key: String
+    public let label: String
+    public let enabled: Bool
+    public init(key: String, label: String, enabled!: Bool = true) {
+        if (key.isEmpty()) {
+            throw UIException("InvalidKey", "list key cannot be empty")
+        }
+        this.key = key
+        this.label = widgetCaption(label)
+        this.enabled = enabled
+    }
+}
diff --git a/src/menu_refs.cj b/src/menu_refs.cj
new file mode 100644
index 00000000..19abfa4e
--- /dev/null
+++ b/src/menu_refs.cj
@@ -0,0 +1,28 @@
+package cjtui
+
+import std.collection.ArrayList
+
+class MenuRefs {
+    let entries = ArrayList<NodeRef>()
+    func add(ref: NodeRef): Unit {
+        entries.add(ref)
+    }
+    func remove(ref: NodeRef): Unit {
+        var i = 0
+        while (i < entries.size) {
+            if (entries[i].sameNode(ref)) {
+                entries.remove(at: i);
+                return
+            }
+            i++
+        }
+    }
+    func contains(ref: NodeRef): Bool {
+        for (entry in entries) {
+            if (entry.sameNode(ref)) {
+                return true
+            }
+        }
+        false
+    }
+}
diff --git a/src/popup_menu.cj b/src/popup_menu.cj
new file mode 100644
index 00000000..16e564db
--- /dev/null
+++ b/src/popup_menu.cj
@@ -0,0 +1,14 @@
+package cjtui
+
+public func PopupMenu(items: Array<MenuEntry>, onChoose: (String) -> Unit): Component {
+    let copy = Array<MenuEntry>(items.size, {i => items[i]})
+    PopupMenu({=> copy}, onChoose)
+}
+
+public func PopupMenu(items: () -> Array<MenuEntry>, onChoose: (String) -> Unit): Component {
+    let refs = MenuRefs()
+    Column({=> menuEntries(items, onChoose, refs)})
+        .themeRole(ThemeRole.PopupMenu)
+        .surface(SurfaceMode.Opaque)
+        .defaultAction({event => menuNavigate(event, refs, false)}, phase: DefaultActionPhase.Ancestor)
+}
diff --git a/src/split_axis.cj b/src/split_axis.cj
new file mode 100644
index 00000000..105bc3fd
--- /dev/null
+++ b/src/split_axis.cj
@@ -0,0 +1,5 @@
+package cjtui
+
+public enum SplitAxis {
+    | Horizontal | Vertical
+}
diff --git a/src/split_pane.cj b/src/split_pane.cj
new file mode 100644
index 00000000..09566ac3
--- /dev/null
+++ b/src/split_pane.cj
@@ -0,0 +1,9 @@
+package cjtui
+
+public func SplitPane(axis!: SplitAxis = SplitAxis.Horizontal, body!: () -> Unit): Component {
+    let root = match (axis) {
+        case SplitAxis.Horizontal => Row(body)
+        case SplitAxis.Vertical => Column(body)
+    }
+    root.themeRole(ThemeRole.SplitPane)
+}
diff --git a/src/status_bar.cj b/src/status_bar.cj
new file mode 100644
index 00000000..96cf470b
--- /dev/null
+++ b/src/status_bar.cj
@@ -0,0 +1,5 @@
+package cjtui
+
+public func StatusBar(body: () -> Unit): Component {
+    Row(body).themeRole(ThemeRole.StatusBar)
+}
diff --git a/tests/widgets_composite/COVERAGE.md b/tests/widgets_composite/COVERAGE.md
index 3ae2636b..3b9492da 100644
--- a/tests/widgets_composite/COVERAGE.md
+++ b/tests/widgets_composite/COVERAGE.md
@@ -1,17 +1,17 @@
 # Hand-authored acceptance mapping
 
 Every test observes public consumers. No expectation is read back from widget output or a production helper. The source assertions are authoritative; `expected.json` supplies human-readable literal traces/grids. All M runtime assertions and the real PTY device remain pending the TASK159 implementation. Accepted-prerequisite and tool results are listed separately in the immutable author evidence.
 
 | AC | Executable cases | Normal, boundary, failure and lifecycle observations | Break caught |
 |---|---|---|---|
 | M01 | `entryAndShapes`, `menuIdentity`, `duplicateBatch` in `src/identity_cases.cj` | All overloads and raw blocks register once; exact/untrimmed key, invalid empty key, illegal single-line caption, empty/Unicode clipping; current retained labels/enabled on replace/reorder; same refs/focus; source unchanged; duplicate label still distinct key; caller constant array copied; removal/readd invalidates old generation; duplicate batch reports DuplicateKey, preserves source, releases resources once. | Captured first value, index identity, changed array, normalized/label-derived key, duplicate registration, partial live tree after rejected batch, old-ref resurrection. The upstream atomic ForEach precheck authority remains accepted C112; failure closes the public session, so no post-error stale tree is queried. |
 | M02 | `navigation(false/true)`, `navigationBoundaries`, `activationMatrix(false/true)` in `src/interaction_cases.cj` | Literal c,a,a,c,a,a trace for each axis; skip disabled, wrap, Home/End, opposite-axis no consumption; single eligible consumes without callback; empty/all-disabled no candidate or consumption; manual physical c,a,b changes navigation while source remains a,b,c; appended nonentry ignored; Tab exits last entry. Enter/ASCII Space each choose stable key once; all 7 ctrl/alt/shift masks for both keys, paste/multi/NBSP excluded; unfocused/disabled ancestor and capture/bubble/app prevent yield0, stop alone yields1. | Business-order/private-child scan, wrong axis, trapped Tab, missed consumption, duplicate requests, incomplete modifier filter or incorrect default-action eligibility. |
-| M03 | `popupOwnership`, `popupEscapeBoundaries`, `nestedPopup`, `popupOwnerAndAnchor` in `src/overlay_cases.cj` | Actual public overlays; strict opaque centered grid; choose stays open; explicit close inside callback gives Requested/focus restore; Esc cancel, closeOnEscape false and app preventDefault; empty/all-disabled activeTarget Esc; inline no layer invented; child-only nested cancel and parent dependency close; OwnerGone/AnchorGone; uncovered base is latest frame. | Automatic business close/new Application, fake focused item, swallowed Esc, orphan dependency, transparent blank popup or stale restoration. |
+| M03 | `popupOwnership`, `popupEscapeBoundaries`, `nestedPopup`, `popupOwnerAndAnchor` in `src/overlay_cases.cj` | Actual public overlays; strict opaque centered grid; choose stays open; explicit close inside callback gives Requested/focus restore; Esc cancel, closeOnEscape false and modal-root preventDefault; base app/legacy handlers remain0; empty/all-disabled activeTarget Esc; inline no layer invented; child-only nested cancel and parent dependency close; OwnerGone/AnchorGone; uncovered base is latest frame. | Automatic business close/new Application, fake focused item, swallowed Esc, orphan dependency, transparent blank popup or stale restoration. |
 | M04 | `statusAndSplitFrames` in `src/layout_cases.cj` | Empty/single/multiline natural Row; explicit1, role theme1 and explicit2 override; 1-column/0-width/0-height; horizontal/vertical 5-cell odd weights; narrow/zero; no implicit weights/separator; 1:2:3 largest remainder; nested two axes with explicit inner height3; public visible remains true after zero viewport. | Forced height/docking, private hidden screen, different layout rounding, separator or virtual minimum canvas. |
-| M05 | `localTheme`, `sharedPanels`, `callbackRecovery`, `SharedPanel` | Exact full Style equality for HorizontalMenu/MenuItem/PopupMenu/StatusBar/SplitPane; explicit > reusable > theme; explicit all-false attributes and separate color-only Classic underline inheritance; ordinary/layer instances share model and Application but distinct refs; menu+ScrollView+StatusBar+Split; owner post; narrow/zero, cleanup and remount; callback/getter first-error preservation and recovery. | Wrong role/priority/field inheritance, explicit Default background, duplicated model or private kind, leaked subscriptions, doubled callback, error swallowed by cleanup. |
+| M05 | `localTheme`, `sharedPanels`, `callbackRecovery`, `SharedPanel` | Exact full Style equality for HorizontalMenu/MenuItem/PopupMenu/StatusBar/SplitPane; explicit local HorizontalMenu role background tests full red/black blank fill, separate foreground-only role tests exact background-only global seed fill; explicit > reusable > theme; explicit all-false attributes, same-custom-theme normal→focused field inheritance and focused-only custom-theme no-preset-merge control; ordinary/layer instances share model and Application but distinct refs; menu+ScrollView+StatusBar+Split; owner post; narrow/zero, cleanup and remount; callback/getter first-error preservation and recovery. | Wrong role/priority/field inheritance, explicit Default background, duplicated model or private kind, leaked subscriptions, doubled callback, error swallowed by cleanup. |
 | affected S02 | `affectedS02` plus identical accepted-only `prerequisite/src/s02_cases.cj` | Three S controls × seven nonempty modifier masks × Enter/Space =42 exclusions; committed focus explicitly asserted before dispatch. Existing accepted S event-phase, controlled-checkbox/radio and native evidence are reused unchanged by the M input manifest. | Shared activation regression accepting any modified activation. |
 | real PTY | `device/src/main.cj`, `pty.py` normal/callback-failure/getter-failure | Native exact focus trace and choose list `h:a;h:a;p:r;p:p;`; Tab, both axes, Home/End, CR/Space, Alt+Space and paste; real layer choose/close/Esc/nested restore; model NEW; resource0/0/0/0, cleanup1; native error sentinels and termios/cleanup. | Decoder/runtime integration failure, native business duplicate, wrong modal domain/restore, native error leak. Recipe only until actual device build succeeds. |
 
-The strict M04 grids are explicitly written in source and JSON. In the nested case the first pane has width3, explicit height3, its equal-weight children receive heights2/1; the right pane starts at x3, yielding `A  C /     /B    `. The explicit height expresses the intended 3-row test; the default cross-axis natural height is not assumed to stretch. Width0×height2 is the string newline, not empty. Style expectations include all eight fields: color-only focused overrides preserve Classic underline unless false is explicitly configured.
+The strict M04 grids are explicitly written in source and JSON. In the nested case the first pane has width3, explicit height3, its equal-weight children receive heights2/1; the right pane starts at x3, yielding `A  C /     /B    `. The explicit height expresses the intended 3-row test; the default cross-axis natural height is not assumed to stretch. Width0×height2 is the string newline, not empty. Style expectations include all eight fields: the custom theme explicitly declares normal MenuItem underline=true and focused red only; its focused state inherits that normal underline. A separate focused-only custom theme has no preset merge and expects the full red Style with underline=false. Default Classic with Inline/local overrides is a different configuration, not an implicit source for parsed custom themes.
 
 The shared-panel layer is explicitly 8×4, so it covers the inline instance with the same literal three-row data and a blank fourth row. On close the inline instance exposes the latest shared model. This is finite local-role composition, not a complete four-theme/all-state product demonstration.
diff --git a/tests/widgets_composite/README.md b/tests/widgets_composite/README.md
index dc5d99e6..f0ecd2c9 100644
--- a/tests/widgets_composite/README.md
+++ b/tests/widgets_composite/README.md
@@ -20,13 +20,13 @@ path = "/workspace/work/viewport-tests/cache"
 [repository.home]
 registry = "https://pkg.cangjie-lang.cn/registry"
 ```
 
 `formal` normally builds/runs the accepted prerequisite, builds/runs the complete headless consumer, then builds the device consumer and drives three real PTY modes. It returns the actual first failing build/binary status. There is no old exit77 admission gate. On the pre-TASK159 baseline the M factories/types are absent, so headless M execution and native PTY execution remain blocked. Missing-API compiler RED proves that boundary only; it does not prove M runtime behavior or full consumer type correctness after M becomes available.
 
 `target-red.sh` isolates only six absent public targets in a tiny normal consumer. At this fixed baseline it requires compiler exit1 and exactly six attributed diagnostics: undeclared MenuEntry/SplitAxis, and non-callable HorizontalMenu/PopupMenu/StatusBar/SplitPane (the existing imported ThemeRole variants have those spellings). The classifier rejects any extra diagnostic, package/import/macro/syntax/setup contamination, or non-target source location. Wrapper exit0 means the actual RED was correctly classified. TASK159 must make this historical RED recipe cease to succeed; the formal runner must then pass instead.
 
 `src/*.cj` contains executable assertions over public frame cells and exact styles, refs, physical children, focus, events, error codes, overlay handles/reasons, and resource stats. Expectations are literal and hand authored. `expected.json` is a matching observation catalogue, not synthetic actual output. `oracle.py --self-test` only checks that catalogue and mutation rejection; direct CJPM consumer assertions are the runtime oracle. `COVERAGE.md` maps each condition to its executable fixture and remaining execution obligation.
 
-The real PTY driver uses `os.openpty()` with a fixed 40×6 terminal, direct `Application.run`, and public callback/focus files. It waits for the actual first frame and event fences, sends arrows/Home/End/HT/CR/Space/Alt+Space/bracketed paste/standalone Escape, and asserts exact focus/request/layer traces. It exercises nested modal Escape, explicit callback close, latest shared model, callback/getter failures, exact termios recovery and native cleanup bytes. Raw input/output, stderr, process status, binary hash and metadata are saved to `CJTUI_COMPOSITE_PTY_OUTPUT` (a new directory). PTY tool self-test uses a tiny plumbing child and never counts as product execution.
+The real PTY driver uses `os.openpty()` with a fixed 40×6 terminal, direct `Application.run`, and public callback/focus files. It waits for the actual first frame and event fences, sends arrows/Home/End/HT/CR/Space/Alt+Space/bracketed paste/standalone Escape, and asserts exact focus/request/layer traces. It exercises nested modal Escape, explicit callback close, latest shared model, callback/getter failures, exact termios recovery and native cleanup bytes. This PTY fixture sends no DECRQM report: it requires exactly one mode25 query, zero mode25 h/l/s/r commands, zero alternate-screen1049 h/l commands, and one ordered bracketed-paste2004 enable/disable pair. Pending/Unknown caret visibility is unmanaged; no cursor-show or alternate-screen-exit command is invented as a restore requirement. Known-mode restore coverage remains the accepted upstream contract/final020 scope. Raw input/output, stderr, process status, binary hash and metadata are saved to `CJTUI_COMPOSITE_PTY_OUTPUT` (a new directory). PTY tool self-test uses a tiny plumbing child and never counts as product execution.
 
 After TASK159, run `formal` on its fixed source, preserve actual headless/PTY logs, then run affected S and TASK011/interaction B/C/117 regressions using their accepted entrypoints. Produce a normal source bundle via the producer's documented `cjpm bundle` flow and run this unchanged consumer against that extracted cjtui path in a fresh package workspace. Native host routes and screenshots remain the independent execution role's work; no PTY result is claimed here from an absent binary. This scope does not close TASK027, TASK041, all Linux, TASK019 or the parent layout task.
diff --git a/tests/widgets_composite/device/src/main.cj b/tests/widgets_composite/device/src/main.cj
index c9eca55a..463d3298 100644
--- a/tests/widgets_composite/device/src/main.cj
+++ b/tests/widgets_composite/device/src/main.cj
@@ -9,59 +9,43 @@ main(): Int64 {
     let directory = getVariable("CJTUI_COMPOSITE_OUTPUT").getOrThrow()
     let mode = getVariable("CJTUI_COMPOSITE_MODE").getOrThrow()
     let report = { name: String, value: String => File.writeTo(directory + "/" + name, value.toArray()) }
     let model = Observable<String>("old")
     let escapes = [0]
     let cleanups = [0]; let calls = [0]; let chosen = [""]; let focusTrace = [""]
     let held = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
     let nested = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
     let popupRoot = Array<?Component>(1, repeat: Option<Component>.None)
     let nestedRoot = Array<?Component>(1, repeat: Option<Component>.None)
-    let menu = HorizontalMenu([MenuEntry("a", "A"), MenuEntry("b", "B", enabled: false), MenuEntry("c", "C")], { key =>
-        calls[0]++
-        if (mode == "callback-failure") { throw Exception("M_NATIVE_CALLBACK_SENTINEL") }
-        chosen[0] += "h:" + key + ";"
-        report("chosen", chosen[0])
-    })
+    let menuSlot = Array<?Component>(1, repeat: Option<Component>.None)
     let root = SplitPane(axis: SplitAxis.Vertical) {
         Text("M_WIDGETS_READY")
-        menu
+        menuSlot[0] = Some(HorizontalMenu([MenuEntry("a", "A"), MenuEntry("b", "B", enabled: false), MenuEntry("c", "C")], { key =>
+            calls[0]++
+            if (mode == "callback-failure") { throw Exception("M_NATIVE_CALLBACK_SENTINEL") }
+            chosen[0] = chosen[0] + "h:" + key + ";"
+            report("chosen", chosen[0])
+        }))
         ScrollView { Text({ =>
             if (model.get() == "bad") { throw Exception("M_NATIVE_GETTER_SENTINEL") }
             model.get()
         }) }.height(1)
         StatusBar { Text({ => model.get() }) }
     }.onMount({ _ => { => cleanups[0]++ } })
+    let menu = menuSlot[0].getOrThrow()
     let app = Application(root)
-    app.onKeyEvent({ event =>
+    // C.3 routes modal shortcuts to the content root and suppresses base
+    // app/legacy handlers. The same public trace runs in each active domain.
+    let trace = { event: UIKeyEvent =>
         if (event.key.code == "escape") { escapes[0]++; report("escape_seen", "${escapes[0]}") }
         if (event.key.code == "text") {
             match (event.key.text) {
-                case "q" => event.preventDefault(); app.stop()
-                case "u" => event.preventDefault(); model.set("NEW")
-                case "g" => event.preventDefault(); model.set("bad")
-                case "o" | "e" =>
-                    event.preventDefault()
-                    let explicitClose = event.key.text == "e"
-                    let popup = PopupMenu([MenuEntry("p", "P"), MenuEntry("x", "X", enabled: false), MenuEntry("r", "R")], { key =>
-                        calls[0]++; chosen[0] += "p:" + key + ";"; report("chosen", chosen[0])
-                        if (explicitClose) { held[0].getOrThrow().close() }
-                    })
-                    popupRoot[0] = Some(popup)
-                    held[0] = Some(root.reference().getOrThrow().openOverlay(popup,
-                        options: OverlayOptions(mode: OverlayMode.Modal)))
-                case "n" =>
-                    event.preventDefault()
-                    let child = PopupMenu([MenuEntry("n", "N")], { _ => () })
-                    nestedRoot[0] = Some(child)
-                    nested[0] = Some(popupRoot[0].getOrThrow().reference().getOrThrow().openOverlay(child,
-                        options: OverlayOptions(mode: OverlayMode.Modal)))
                 case "c" => event.preventDefault(); held[0].getOrThrow().close()
                 case "#" =>
                     event.preventDefault()
                     var name = "none"
                     if (let Some(current) <- app.focusedNode()) {
                         let base = menu.reference().getOrThrow().children()
                         if (current.sameNode(base[0])) { name = "a" }
                         if (current.sameNode(base[2])) { name = "c" }
                         if (let Some(popup) <- popupRoot[0]) {
                             if (let Some(ref) <- popup.reference()) {
@@ -70,27 +54,63 @@ main(): Int64 {
                                 if (current.sameNode(children[2])) { name = "r" }
                             }
                         }
                         if (let Some(child) <- nestedRoot[0]) {
                             if (let Some(ref) <- child.reference()) {
                                 if (current.sameNode(ref.children()[0])) { name = "n" }
                             }
                         }
                     }
                     focusTrace[0] += name + ";"
-                    report("focus", focusTrace[0])
                     if (let Some(handle) <- held[0]) {
                         report("open", "${handle.isOpen()}")
                         if (let Some(reason) <- handle.closeReason()) {
                             report("reason", if (reason == OverlayCloseReason.Requested) { "Requested" } else { "Escape" })
                         }
                     }
+                    // Publish this observation only after every payload file.
+                    report("focus", focusTrace[0])
+                case _ => ()
+            }
+        }
+    }
+    let modalHandler = { event: UIKeyEvent =>
+        trace(event)
+        if (event.key.code == "text") {
+            match (event.key.text) {
+                case "n" =>
+                    event.preventDefault()
+                    let child = PopupMenu([MenuEntry("n", "N")], { _ => () }).onKey(trace)
+                    nestedRoot[0] = Some(child)
+                    nested[0] = Some(popupRoot[0].getOrThrow().reference().getOrThrow().openOverlay(child,
+                        options: OverlayOptions(mode: OverlayMode.Modal)))
+                case _ => ()
+            }
+        }
+    }
+    app.onKeyEvent({ event =>
+        trace(event)
+        if (event.key.code == "text") {
+            match (event.key.text) {
+                case "q" => event.preventDefault(); app.stop()
+                case "u" => event.preventDefault(); model.set("NEW")
+                case "g" => event.preventDefault(); model.set("bad")
+                case "o" | "e" =>
+                    event.preventDefault()
+                    let explicitClose = event.key.text == "e"
+                    let popup = PopupMenu([MenuEntry("p", "P"), MenuEntry("x", "X", enabled: false), MenuEntry("r", "R")], { key =>
+                        calls[0]++; chosen[0] += "p:" + key + ";"; report("chosen", chosen[0])
+                        if (explicitClose) { held[0].getOrThrow().close() }
+                    }).onKey(modalHandler)
+                    popupRoot[0] = Some(popup)
+                    held[0] = Some(root.reference().getOrThrow().openOverlay(popup,
+                        options: OverlayOptions(mode: OverlayMode.Modal)))
                 case _ => ()
             }
         }
     })
     var caught = ""
     try { app.run() } catch (error: Exception) { caught = error.message; report("error", caught) }
     let stats = app.stats()
     report("summary", "calls=${calls[0]}\nchosen=${chosen[0]}\nmodel=${model.get()}\ncleanups=${cleanups[0]}\nresources=${stats.mountedNodes}/${stats.activeBindings}/${stats.subscriptions}/${stats.pendingPosts}\n")
     if (mode == "normal" && caught.isEmpty()) { return 0 }
     if (mode == "callback-failure" && caught.contains("M_NATIVE_CALLBACK_SENTINEL")) { return 21 }
diff --git a/tests/widgets_composite/expected.json b/tests/widgets_composite/expected.json
index b1ea5c8e..a1d5a256 100644
--- a/tests/widgets_composite/expected.json
+++ b/tests/widgets_composite/expected.json
@@ -407,21 +407,21 @@
         1,
         2,
         3,
         4,
         5,
         6,
         7
       ],
       "callbacks": 0
     },
-    "M03-app-blocked-escape": {
+    "M03-modal-root-blocked-escape": {
       "blocked_open": true,
       "after_allow_open": false,
       "focus_after_close": "trigger"
     },
     "M01-duplicate-label": {
       "labels": [
         "same",
         "same"
       ],
       "distinct_refs": true,
@@ -429,13 +429,33 @@
     },
     "M05-horizontal-root-style": {
       "foreground": "red",
       "background": "black",
       "bold": false,
       "dim": false,
       "italic": false,
       "underline": false,
       "inverse": false,
       "strikethrough": false
+    },
+    "M05-horizontal-global-seed-style": {
+      "foreground": "default",
+      "background": "black",
+      "bold": false,
+      "dim": false,
+      "italic": false,
+      "underline": false,
+      "inverse": false,
+      "strikethrough": false
+    },
+    "M05-custom-theme-no-preset-fallback": {
+      "foreground": "red",
+      "background": "default",
+      "bold": false,
+      "dim": false,
+      "italic": false,
+      "underline": false,
+      "inverse": false,
+      "strikethrough": false
     }
   }
 }
diff --git a/tests/widgets_composite/fixtures/local-theme.toml b/tests/widgets_composite/fixtures/local-theme.toml
index 9b286b40..13db0a5b 100644
--- a/tests/widgets_composite/fixtures/local-theme.toml
+++ b/tests/widgets_composite/fixtures/local-theme.toml
@@ -4,20 +4,21 @@ name = "M-local"
 foreground = "white"
 background = "black"
 bold = false
 dim = false
 italic = false
 underline = false
 inverse = false
 strikethrough = false
 [components.horizontal_menu.text]
 foreground = "red"
+background = "black"
 [components.popup_menu.text]
 foreground = "green"
 background = "blue"
 [components.status_bar.text]
 foreground = "yellow"
 [components.split_pane.text]
 foreground = "magenta"
 [components.menu_item.text]
 foreground = "cyan"
 [components.menu_item.states.focused.text]
diff --git a/tests/widgets_composite/pty.py b/tests/widgets_composite/pty.py
index 1878ee5d..1c4b9b6f 100644
--- a/tests/widgets_composite/pty.py
+++ b/tests/widgets_composite/pty.py
@@ -1,27 +1,53 @@
 #!/usr/bin/env python3
 """Real Linux PTY exercise of Application.run; no emulator or product stand-in."""
 import argparse
 import errno
 import fcntl
 import hashlib
 import json
 import os
+import re
 import select
 import signal
 import struct
 import subprocess
 import termios
 import time
 from pathlib import Path
 
 
+def assert_unanswered_probe_modes(raw, sent):
+    """Wire oracle for this no-reply fixture only; not a Known-mode matrix."""
+    query = b"\x1b[?25$p"
+    assert raw.count(query) == 1, "one exact mode25 DECRQM request"
+    requests = re.findall(rb"\x1b\[\?([0-9;]+)\$p", raw)
+    assert sum(25 in [int(p or b"0") for p in params.split(b";")] for params in requests) == 1, "no repeated mode25 query"
+    assert not re.search(rb"\x1b\[\?25;[0-4]\$y", sent), "fixture must not send a valid mode25 protocol report"
+    controls = re.findall(rb"\x1b\[\?([0-9;]*)([hlsr])", raw)
+
+    def count(mode, action):
+        return sum(mode in [int(p or b"0") for p in params.split(b";")] and final == action
+                   for params, final in controls)
+
+    for action in [b"h", b"l", b"s", b"r"]:
+        assert count(25, action) == 0, "unanswered probe: no mode25 change/save/restore"
+    for action in [b"h", b"l"]:
+        assert count(1049, action) == 0, "fixture never enters or exits alternate screen"
+    enable, disable = b"\x1b[?2004h", b"\x1b[?2004l"
+    assert raw.count(enable) == 1 and raw.count(disable) == 1, "paste mode paired cleanup"
+    assert count(2004, b"h") == 1 and count(2004, b"l") == 1, "no extra combined paste mode transitions"
+    assert raw.index(enable) < raw.index(disable), "paste mode enable precedes cleanup"
+    return dict(query_count=1, valid_input_reports=0, mode25_hlsr=[0, 0, 0, 0],
+                alternate1049_hl=[0, 0], paste2004_hl=[1, 1], reply_fixture="unanswered; Pending/Unknown wire policy")
+
+
 def run(binary, output, mode):
     directory = output / mode
     directory.mkdir(parents=True, exist_ok=False)
     master, slave = os.openpty()
     fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 6, 40, 0, 0))
     before = termios.tcgetattr(slave)
     raw, sent, events = bytearray(), bytearray(), []
     env = dict(os.environ, TERM="xterm-256color", COLORTERM="", CJTUI_COMPOSITE_OUTPUT=str(directory), CJTUI_COMPOSITE_MODE=mode)
     metadata = dict(mode=mode, binary=str(binary), binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),
                     cwd=str(Path.cwd()), before_termios=before, events=events, route="real PTY; direct product binary")
@@ -57,31 +83,33 @@ def run(binary, output, mode):
         return path.read_text() if path.exists() else ""
 
     def send(data):
         sent.extend(data)
         events.append(dict(input_hex=data.hex(), monotonic_ns=time.monotonic_ns()))
         view = memoryview(data)
         while view:
             view = view[os.write(master, view):]
 
     focus_expected = []
+    escape_expected = [0]
 
     def fence(want):
         focus_expected.append(want)
         send(b"#")
         expected = ";".join(focus_expected) + ";"
         await_condition(lambda: text("focus") == expected, "public focus trace " + expected)
 
     def escape():
-        old = text("escape_seen")
+        escape_expected[0] += 1
+        expected = str(escape_expected[0])
         send(b"\x1b")
-        await_condition(lambda: text("escape_seen") != old, "standalone Escape decoded")
+        await_condition(lambda: text("escape_seen") == expected, "standalone Escape decoded")
 
     try:
         await_condition(lambda: b"M_WIDGETS_READY" in raw and b"\x1b[" in raw, "actual native first frame")
         if mode == "callback-failure":
             send(b"\r")
         elif mode == "getter-failure":
             send(b"g")
         else:
             fence("a")
             for key, want in [(b"\x1b[C", "c"), (b"\x1b[C", "a"), (b"\x1b[F", "c"),
@@ -138,22 +166,21 @@ def run(binary, output, mode):
         assert after == before, "exact termios restoration"
         summary = dict(line.split("=", 1) for line in text("summary").splitlines())
         metadata["summary"] = summary
         assert child.returncode == {"normal": 0, "callback-failure": 21, "getter-failure": 22}[mode]
         assert summary["resources"] == "0/0/0/0" and summary["cleanups"] == "1"
         if mode == "normal":
             assert summary == dict(calls="4", chosen="h:a;h:a;p:r;p:p;", model="NEW", cleanups="1", resources="0/0/0/0")
             assert not text("error")
         else:
             assert {"callback-failure": "M_NATIVE_CALLBACK_SENTINEL", "getter-failure": "M_NATIVE_GETTER_SENTINEL"}[mode] in text("error")
-        assert raw.count(b"\x1b[?2004h") == 1 and raw.count(b"\x1b[?2004l") == 1, "paste mode paired cleanup"
-        assert b"\x1b[?25h" in raw and b"\x1b[?1049l" in raw, "cursor/alternate screen restored"
+        metadata["mode_oracle"] = assert_unanswered_probe_modes(bytes(raw), bytes(sent))
         metadata["result"] = "PASS"
     except BaseException as error:
         metadata.update(result="FAIL", error=repr(error))
         raise
     finally:
         if child.poll() is None:
             os.killpg(child.pid, signal.SIGKILL)
             child.wait()
         metadata["exit"] = child.returncode
         (directory / "stdout.raw").write_bytes(raw)
diff --git a/tests/widgets_composite/pty_fence_selftest.py b/tests/widgets_composite/pty_fence_selftest.py
new file mode 100644
index 00000000..e986c5b9
--- /dev/null
+++ b/tests/widgets_composite/pty_fence_selftest.py
@@ -0,0 +1,109 @@
+#!/usr/bin/env python3
+"""Pause a tool-only file writer; exercise actual harness reader closures."""
+import ast
+import copy
+import tempfile
+import unittest
+from pathlib import Path
+
+DRIVER = Path(__file__).with_name("pty.py")
+
+
+def reader_namespace(directory, writer, mutate_escape=False):
+    run = next(node for node in ast.parse(DRIVER.read_text()).body
+               if isinstance(node, ast.FunctionDef) and node.name == "run")
+    functions = copy.deepcopy([node for node in run.body
+                               if isinstance(node, ast.FunctionDef) and node.name in {"fence", "escape"}])
+    if mutate_escape:
+        escape = next(node for node in functions if node.name == "escape")
+        predicate = next(node for node in ast.walk(escape) if isinstance(node, ast.Compare))
+        predicate.ops = [ast.NotEq()]
+        predicate.comparators = [ast.Name(id="old_count", ctx=ast.Load())]
+    events, sent = [], []
+
+    def text(name):
+        path = directory / name
+        return path.read_text() if path.exists() else ""
+
+    def await_condition(predicate, _label):
+        for boundary in writer:
+            ready = predicate()
+            events.append((boundary, ready))
+            if ready:
+                return
+        raise AssertionError("completion fence never published")
+
+    namespace = dict(text=text, send=sent.append, await_condition=await_condition,
+                     focus_expected=["p"], escape_expected=[9], old_count="9")
+    tree = ast.fix_missing_locations(ast.Module(body=functions, type_ignores=[]))
+    exec(compile(tree, str(DRIVER), "exec"), namespace)
+    return namespace, events, sent
+
+
+def paused_writer(directory, fields):
+    """Yield with the real file truncated, partly written, then complete."""
+    for name, value in fields:
+        with (directory / name).open("w") as stream:
+            yield name + ":truncated"
+            cut = len(value) // 2
+            stream.write(value[:cut])
+            stream.flush()
+            yield name + ":partial"
+            stream.write(value[cut:])
+            stream.flush()
+            yield name + ":complete"
+
+
+class PublicationFenceTests(unittest.TestCase):
+    def exercise_focus(self, marker_first=False):
+        with tempfile.TemporaryDirectory() as temporary:
+            directory = Path(temporary)
+            for name, value in [("focus", "p;"), ("open", "true"), ("reason", "Requested")]:
+                (directory / name).write_text(value)
+            fields = [("open", "false"), ("reason", "Escape"), ("focus", "p;c;")]
+            if marker_first:
+                fields = [fields[-1]] + fields[:-1]
+            writer = paused_writer(directory, fields)
+            try:
+                reader, events, sent = reader_namespace(directory, writer)
+                reader["fence"]("c")
+                self.assertEqual(sent, [b"#"])
+                self.assertEqual((directory / "open").read_text(), "false")
+                self.assertEqual((directory / "reason").read_text(), "Escape")
+                self.assertEqual(events[-1], ("focus:complete", True))
+                self.assertTrue(all(not ready for _, ready in events[:-1]))
+            finally:
+                writer.close()
+
+    def test_marker_last_blocks_at_every_partial_payload_boundary(self):
+        self.exercise_focus()
+
+    def test_marker_first_mutation_is_detected_as_early_payload_read(self):
+        with self.assertRaises(AssertionError):
+            self.exercise_focus(marker_first=True)
+
+    def exercise_escape(self, mutant=False):
+        with tempfile.TemporaryDirectory() as temporary:
+            directory = Path(temporary)
+            (directory / "escape_seen").write_text("9")
+            writer = paused_writer(directory, [("escape_seen", "10")])
+            try:
+                reader, events, sent = reader_namespace(directory, writer, mutate_escape=mutant)
+                reader["escape"]()
+                self.assertEqual(sent, [b"\x1b"])
+                self.assertEqual((directory / "escape_seen").read_text(), "10")
+                self.assertEqual(events, [("escape_seen:truncated", False),
+                                          ("escape_seen:partial", False), ("escape_seen:complete", True)])
+            finally:
+                writer.close()
+
+    def test_exact_next_counter_ignores_truncation_and_partial_digits(self):
+        self.exercise_escape()
+
+    def test_any_change_counter_mutation_is_detected(self):
+        with self.assertRaises(AssertionError):
+            self.exercise_escape(mutant=True)
+
+
+if __name__ == "__main__":
+    unittest.main()
diff --git a/tests/widgets_composite/pty_mode_selftest.py b/tests/widgets_composite/pty_mode_selftest.py
new file mode 100644
index 00000000..4d923ea4
--- /dev/null
+++ b/tests/widgets_composite/pty_mode_selftest.py
@@ -0,0 +1,60 @@
+#!/usr/bin/env python3
+"""Tool-only wire-oracle mutations; never a product or native PTY pass."""
+import importlib.util
+import unittest
+from pathlib import Path
+
+spec = importlib.util.spec_from_file_location("composite_pty_driver", Path(__file__).with_name("pty.py"))
+driver = importlib.util.module_from_spec(spec)
+spec.loader.exec_module(driver)
+check = driver.assert_unanswered_probe_modes
+ENABLE = b"\x1b[?2004h"
+DISABLE = b"\x1b[?2004l"
+QUERY = b"\x1b[?25$p"
+RAW = ENABLE + QUERY + b"M_WIDGETS_READY" + DISABLE
+SENT = b"\x1b[C#\r \x1b[200~ \x1b[201~\x1b#q"
+
+
+class UnansweredModeOracleTests(unittest.TestCase):
+    def test_hand_authored_positive(self):
+        observed = check(RAW, SENT)
+        self.assertEqual(observed["query_count"], 1)
+        self.assertEqual(observed["valid_input_reports"], 0)
+        self.assertEqual(observed["mode25_hlsr"], [0, 0, 0, 0])
+        self.assertEqual(observed["alternate1049_hl"], [0, 0])
+        self.assertEqual(observed["paste2004_hl"], [1, 1])
+
+    def test_query_missing_repeated_or_nonexact_is_rejected(self):
+        for raw in [RAW.replace(QUERY, b""), RAW + QUERY,
+                    RAW.replace(QUERY, b"\x1b[?025$p"), RAW + b"\x1b[?25;2004$p"]:
+            with self.subTest(raw=raw), self.assertRaises(AssertionError):
+                check(raw, SENT)
+
+    def test_every_mode25_transition_and_save_restore_is_rejected(self):
+        for action in [b"h", b"l", b"s", b"r"]:
+            with self.subTest(action=action), self.assertRaises(AssertionError):
+                check(RAW + b"\x1b[?25" + action, SENT)
+        for extra in [b"\x1b[?025h", b"\x1b[?2004;25h"]:
+            with self.subTest(extra=extra), self.assertRaises(AssertionError):
+                check(RAW + extra, SENT)
+
+    def test_alternate_screen_entry_and_exit_are_rejected(self):
+        for action in [b"h", b"l"]:
+            with self.subTest(action=action), self.assertRaises(AssertionError):
+                check(RAW + b"\x1b[?1049" + action, SENT)
+
+    def test_injected_protocol_report_breaks_no_reply_fixture(self):
+        for status in [b"0", b"1", b"2", b"3", b"4"]:
+            with self.subTest(status=status), self.assertRaises(AssertionError):
+                check(RAW, SENT + b"\x1b[?25;" + status + b"$y")
+
+    def test_paste_pair_count_and_order_remain_strict(self):
+        for raw in [RAW.replace(ENABLE, b""), RAW.replace(DISABLE, b""),
+                    RAW + ENABLE, RAW + DISABLE, DISABLE + QUERY + ENABLE,
+                    RAW + b"\x1b[?2004;999h"]:
+            with self.subTest(raw=raw), self.assertRaises(AssertionError):
+                check(raw, SENT)
+
+
+if __name__ == "__main__":
+    unittest.main()
diff --git a/tests/widgets_composite/run.sh b/tests/widgets_composite/run.sh
index 617fd588..ab438f1e 100644
--- a/tests/widgets_composite/run.sh
+++ b/tests/widgets_composite/run.sh
@@ -1,20 +1,22 @@
 #!/usr/bin/env bash
 set -euo pipefail
 here=$(cd "$(dirname "$0")" && pwd)
 source /workspace/work/validation/sdk/cangjie/envsetup.sh
 export CANGJIE_STDX_PATH=${CANGJIE_STDX_PATH:-/workspace/work/linux-build-recon/stdx-env}
 export CJTUI_UCD_ARCHIVE=${CJTUI_UCD_ARCHIVE:-/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip}
 mode=${1:-formal}
 if [[ "$mode" == self-test ]]; then
     python3 "$here/oracle.py" --self-test
     python3 "$here/pty_selftest.py"
+    python3 "$here/pty_mode_selftest.py"
+    python3 "$here/pty_fence_selftest.py"
     python3 - "$here" <<'PYCHECK'
 from pathlib import Path
 import sys
 for path in Path(sys.argv[1]).glob("*.py"):
     compile(path.read_text(), str(path), "exec")
 print("PYTHON_SYNTAX_PASS")
 PYCHECK
     exit 0
 fi
 if [[ "$mode" != formal ]]; then printf 'usage: %s [formal|self-test]\n' "$0" >&2; exit 64; fi
diff --git a/tests/widgets_composite/src/composition_cases.cj b/tests/widgets_composite/src/composition_cases.cj
index bd9640ac..74ad3d2c 100644
--- a/tests/widgets_composite/src/composition_cases.cj
+++ b/tests/widgets_composite/src/composition_cases.cj
@@ -7,65 +7,89 @@ import cjtui.*
 // lost errors, leaked subscriptions, callbacks executed more than once.
 func localTheme(): Unit {
     let theme = Theme.readFile("fixtures/local-theme.toml")
     let horizontal = HorizontalMenu([MenuEntry("a", "A"), MenuEntry("b", "B", enabled: false)], {_ => ()})
     let app = Application(horizontal, theme: theme)
     app.startHeadless()
     try {
         let frame = app.snapshot(4, 1)
         check(frame.cellAt(3, 0).style == Style(foreground: Color.Red, background: Color.Black), "M05 HorizontalMenu root role fills exact Style")
         check(frame.cellAt(0, 0).style == Style(foreground: Color.Blue, background: Color.Black), "M05 focused MenuItem exact Style includes inherited fields")
-        check(frame.cellAt(1, 0).style == Style(foreground: Color.Red, background: Color.Black), "M05 disabled MenuItem exact Style overrides Classic dim")
+        check(frame.cellAt(1, 0).style == Style(foreground: Color.Red, background: Color.Black), "M05 disabled MenuItem exact Style retains declared false dim")
     } finally { app.dispose() }
+    // T015: global seed background fills use only the seed background;
+    // a foreground-only menu role must not turn its blank cells opaque red.
+    let seedTheme = Theme.parse("schema_version = 1\nname = \"M-seed-only\"\n[text]\nforeground = \"white\"\nbackground = \"black\"\n[components.horizontal_menu.text]\nforeground = \"red\"\n")
+    let seedMenu = HorizontalMenu([MenuEntry("a", "A")], {_ => ()})
+    let seedApp = Application(seedMenu, theme: seedTheme)
+    seedApp.startHeadless()
+    try {
+        check(seedApp.snapshot(4, 1).cellAt(3, 0).style == Style(background: Color.Black),
+            "M05 foreground-only HorizontalMenu role preserves exact global seed fill Style")
+    } finally { seedApp.dispose() }
     let bar = StatusBar { Text("S") }.styles([StyleUse.Named("reused")]).foreground(Color.Red)
     let styled = Application(bar, theme: theme)
     styled.startHeadless()
     try { check(styled.snapshot(2, 1).cellAt(0, 0).style == Style(foreground: Color.Red, background: Color.Black),
         "M05 explicit beats reusable beats theme") }
     finally { styled.dispose() }
     let reused = Application(StatusBar { Text("S") }.styles([StyleUse.Named("reused")]), theme: theme)
     reused.startHeadless()
     try { check(reused.snapshot(1, 1).cellAt(0, 0).style == Style(foreground: Color.Green, background: Color.Black), "M05 reusable beats StatusBar theme") }
     finally { reused.dispose() }
     let status = Application(StatusBar { Text("S") }, theme: theme)
     status.startHeadless()
     try { check(status.snapshot(1, 1).cellAt(0, 0).style == Style(foreground: Color.Yellow, background: Color.Black), "M05 StatusBar theme role") }
     finally { status.dispose() }
     let split = Application(SplitPane { Text("L"); Text("R") }, theme: theme)
     split.startHeadless()
     try { check(split.snapshot(2, 1).cellAt(0, 0).style == Style(foreground: Color.Magenta, background: Color.Black), "M05 SplitPane theme role") }
     finally { split.dispose() }
-    let trigger = Text("abcdefgh").focusable(true)
-    let base = Application(Column { trigger; Text("ijklmnop"); Text("qrstuvwx") }, theme: theme)
+    let triggerSlot = Array<?Component>(1, repeat: Option<Component>.None)
+    let root = Column {
+        triggerSlot[0] = Some(Text("abcdefgh").focusable(true))
+        Text("ijklmnop")
+        Text("qrstuvwx")
+    }
+    let trigger = triggerSlot[0].getOrThrow()
+    let base = Application(root, theme: theme)
     base.startHeadless()
     try {
         base.snapshot(8, 3)
         let popup = PopupMenu([MenuEntry("a", "X")], {_ => ()}).width(3).height(1)
         let handle = open(base, mounted(trigger), popup, OverlayOptions(mode: OverlayMode.NonModal))
         let frame = base.snapshot(8, 3)
         equal(frame.toPlainText(), "abcdefgh\nijX  nop\nqrstuvwx", "M05 real popup themed opaque frame")
         check(frame.cellAt(3, 1).style == Style(foreground: Color.Green, background: Color.Blue), "M05 popup blank uses role fields and preserves theme background")
         check(handle.isOpen(), "M05 observing role does not alter overlay")
     } finally { base.dispose() }
-    // Color-only overrides deliberately leave Classic focused underline intact.
-    let inheritance = Theme.parse("schema_version = 1\nname = \"color-only\"\n[components.menu_item.states.focused.text]\nforeground = \"red\"\n")
+    // A parsed custom theme replaces the preset. Focused fields inherit
+    // only the normal fields explicitly declared in this same custom theme.
+    let inheritance = Theme.parse("schema_version = 1\nname = \"normal-focused\"\n[components.menu_item.text]\nunderline = true\n[components.menu_item.states.focused.text]\nforeground = \"red\"\n")
     let inherited = Application(HorizontalMenu([MenuEntry("a", "A")], {_ => ()}), theme: inheritance)
     inherited.startHeadless()
-    try { check(inherited.snapshot(1, 1).cellAt(0, 0).style == Style(foreground: Color.Red, underline: true), "M05 Classic focused underline inheritance remains exact") }
+    try { check(inherited.snapshot(1, 1).cellAt(0, 0).style == Style(foreground: Color.Red, underline: true), "M05 focused color inherits declared normal underline exactly") }
     finally { inherited.dispose() }
+    let focusedOnly = Theme.parse("schema_version = 1\nname = \"focused-only\"\n[components.menu_item.states.focused.text]\nforeground = \"red\"\n")
+    let unmerged = Application(HorizontalMenu([MenuEntry("a", "A")], {_ => ()}), theme: focusedOnly)
+    unmerged.startHeadless()
+    try { check(unmerged.snapshot(1, 1).cellAt(0, 0).style == Style(foreground: Color.Red),
+        "M05 focused-only custom theme has no implicit preset underline") }
+    finally { unmerged.dispose() }
 }
 
 func sharedPanels(): Unit {
     let model = Observable<String>("old")
-    let first = SharedPanel(model)
+    let firstSlot = Array<?Component>(1, repeat: Option<Component>.None)
+    let root = SplitPane(axis: SplitAxis.Vertical) { firstSlot[0] = Some(SharedPanel(model)) }
+    let first = firstSlot[0].getOrThrow()
     let second = SharedPanel(model).width(8).height(4)
-    let root = SplitPane(axis: SplitAxis.Vertical) { first }
     let app = Application(root)
     app.startHeadless()
     try {
         equal(app.snapshot(8, 4).toPlainText(), "A       \nold     \nold     \n        ", "M05 first composed panel")
         let firstRef = mounted(first)
         let layer = open(app, firstRef, second, OverlayOptions(mode: OverlayMode.Modal))
         check(!firstRef.sameNode(mounted(second)), "M05 two instances have distinct refs")
         check(mounted(second).application().focusedNode().getOrThrow().sameNode(app.focusedNode().getOrThrow()) &&
             firstRef.application().focusedNode().getOrThrow().sameNode(app.focusedNode().getOrThrow()), "M05 one Application for ordinary and layer instances")
         app.batch({ => model.set("new") })
diff --git a/tests/widgets_composite/src/identity_cases.cj b/tests/widgets_composite/src/identity_cases.cj
index 53e3ec47..790c218d 100644
--- a/tests/widgets_composite/src/identity_cases.cj
+++ b/tests/widgets_composite/src/identity_cases.cj
@@ -76,23 +76,26 @@ func menuIdentity(): Unit {
         equal(chosen[0], "b", "M01 duplicate label requests stable key")
     } finally { twinApp.dispose() }
     let constant = [MenuEntry("a", "A")]
     let fixed = HorizontalMenu(constant, {_ => ()})
     constant[0] = MenuEntry("b", "B")
     equal(render(fixed, 1, 1).toPlainText(), "A", "M01 constant overload copies caller array")
 }
 
 func duplicateBatch(): Unit {
     let source = Observable<Array<MenuEntry>>([MenuEntry("a", "A")])
-    let menu = HorizontalMenu({ => source.get() }, {_ => ()})
+    let menuSlot = Array<?Component>(1, repeat: Option<Component>.None)
     let cleanups = [0]
-    let root = Column { menu }.onMount({ _ => { => cleanups[0]++ } })
+    let root = Column {
+        menuSlot[0] = Some(HorizontalMenu({ => source.get() }, {_ => ()}))
+    }.onMount({ _ => { => cleanups[0]++ } })
+    let menu = menuSlot[0].getOrThrow()
     let app = Application(root)
     app.startHeadless()
     let previous = mounted(menu).children()[0]
     let invalid = [MenuEntry("new", "N"), MenuEntry("dup", "D"), MenuEntry("dup", "E")]
     expectCode({ => app.batch({ => source.set(invalid) }) }, "DuplicateKey")
     check(invalid.size == 3 && invalid[0].key == "new" && invalid[2].label == "E", "M01 rejected batch leaves source unchanged")
     check(!previous.isValid() && cleanups[0] == 1, "M01 failed batch cleans old tree once")
     clean(app)
     app.dispose()
     check(cleanups[0] == 1, "M01 disposal after failure is idempotent")
diff --git a/tests/widgets_composite/src/interaction_cases.cj b/tests/widgets_composite/src/interaction_cases.cj
index 422fdf09..3f9ac824 100644
--- a/tests/widgets_composite/src/interaction_cases.cj
+++ b/tests/widgets_composite/src/interaction_cases.cj
@@ -1,22 +1,26 @@
 package widgets_composite
 
 import cjtui.*
 
 // Breaks caught: source-order navigation, unrelated-child scanning, wrong axis,
 // missing wrap/skip, Tab trapping, double requests, incomplete modifier checks.
 func navigation(popup: Bool): Unit {
     let entries = [MenuEntry("a", "A"), MenuEntry("b", "B", enabled: false), MenuEntry("c", "C")]
     let calls = [0]
-    let menu = if (popup) { PopupMenu(entries, {_ => calls[0]++}) } else { HorizontalMenu(entries, {_ => calls[0]++}) }
-    let outside = Text("outside").focusable(true)
-    let root = Column { menu; outside }
+    let components = Array<?Component>(2, repeat: Option<Component>.None)
+    let root = Column {
+        components[0] = Some(if (popup) { PopupMenu(entries, {_ => calls[0]++}) } else { HorizontalMenu(entries, {_ => calls[0]++}) })
+        components[1] = Some(Text("outside").focusable(true))
+    }
+    let menu = components[0].getOrThrow()
+    let outside = components[1].getOrThrow()
     let captured = Array<?UIKeyEvent>(1, repeat: Option<UIKeyEvent>.None)
     let app = Application(root).onKeyEvent({ event => captured[0] = Some(event) })
     app.startHeadless()
     try {
         let refs = mounted(menu).children(); let a = refs[0]; let b = refs[1]; let c = refs[2]
         focus(app, a)
         let next = if (popup) { "down" } else { "right" }
         let previous = if (popup) { "up" } else { "left" }
         let orthogonal = if (popup) { "left" } else { "up" }
         for ((key, want) in [(next, c), (next, a), ("home", a), ("end", c), (previous, a), (orthogonal, a)]) {
@@ -54,21 +58,21 @@ func navigationBoundaries(): Unit {
     let app = Application(single).onKeyEvent({ event => captured[0] = Some(event) })
     app.startHeadless()
     try {
         let a = mounted(single).children()[0]
         focus(app, a)
         for (key in ["up", "down", "home", "end"]) {
             app.dispatch(a, KeyEvent(key))
             focused(app, a, "M02 single eligible focus stable")
             check(captured[0].getOrThrow().defaultPrevented && calls[0] == 0, "M02 single navigation consumed without selection")
         }
-        app.batch({ => mounted(single).children()[1].notify(ChangeKind.Paint) })
+        app.batch({ => mounted(single).children()[1].notify(ChangeKind.Style) })
     } finally { app.dispose() }
     for (disabled in [false, true]) {
         let empty = PopupMenu(if (disabled) { [MenuEntry("a", "A", enabled: false)] } else { Array<MenuEntry>() }, {_ => calls[0]++})
         let event = Array<?UIKeyEvent>(1, repeat: Option<UIKeyEvent>.None)
         let zero = Application(empty).onKeyEvent({ e => event[0] = Some(e) })
         zero.startHeadless()
         try {
             check(zero.focusedNode().isNone(), "M02 empty/all disabled no focus candidate")
             zero.dispatch(mounted(empty), KeyEvent("down"))
             check(!event[0].getOrThrow().defaultPrevented && calls[0] == 0, "M02 no eligible candidate no menu consumption")
@@ -100,23 +104,26 @@ func activationMatrix(popup: Bool): Unit {
                 check(!event[0].getOrThrow().defaultPrevented && calls[0] == 2, "M02 all seven modifier combinations excluded")
             }
         }
         for (key in [KeyEvent("paste", text: " "), KeyEvent("text", text: "  "), KeyEvent("text", text: "\u{a0}")]) {
             app.dispatch(a, key)
         }
         check(calls[0] == 2, "M02 paste/multi/non-ASCII spaces excluded")
     } finally { app.dispose() }
     for (mode in 0..4) {
         let requests = [0]
-        let target = if (popup) { PopupMenu([MenuEntry("a", "A")], {_ => requests[0]++}) }
-            else { HorizontalMenu([MenuEntry("a", "A")], {_ => requests[0]++}) }
-        let parent = Column { target }
+        let targetSlot = Array<?Component>(1, repeat: Option<Component>.None)
+        let parent = Column {
+            targetSlot[0] = Some(if (popup) { PopupMenu([MenuEntry("a", "A")], {_ => requests[0]++}) }
+                else { HorizontalMenu([MenuEntry("a", "A")], {_ => requests[0]++}) })
+        }
+        let target = targetSlot[0].getOrThrow()
         if (mode == 0) { parent.onKeyCapture({ e => e.preventDefault() }) }
         if (mode == 1) { parent.onKey({ e => e.preventDefault() }) }
         if (mode == 3) { parent.onKeyCapture({ e => e.stopPropagation() }) }
         let current = Application(parent)
         if (mode == 2) { current.onKeyEvent({ e => e.preventDefault() }) }
         current.startHeadless()
         try {
             let ref = mounted(target).children()[0]
             focus(current, ref)
             current.dispatch(ref, KeyEvent("enter"))
diff --git a/tests/widgets_composite/src/overlay_cases.cj b/tests/widgets_composite/src/overlay_cases.cj
index bd41348f..de1443df 100644
--- a/tests/widgets_composite/src/overlay_cases.cj
+++ b/tests/widgets_composite/src/overlay_cases.cj
@@ -5,22 +5,27 @@ import cjtui.*
 func open(app: Application, owner: NodeRef, content: Component, options: OverlayOptions): OverlayHandle {
     let held = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
     app.batch({ => held[0] = Some(owner.openOverlay(content, options: options)) })
     held[0].getOrThrow()
 }
 
 // Breaks caught: automatic menu layers/close, swallowed Esc, opaque background
 // reset, orphan nested layers, stale restored frame/focus or invalid ownership.
 func popupOwnership(): Unit {
     let model = Observable<String>("ijklmnop")
-    let trigger = Text("abcdefgh").focusable(true)
-    let root = Column { trigger; Text({ => model.get() }); Text("qrstuvwx") }.viewport(ScrollAxes.Off)
+    let triggerSlot = Array<?Component>(1, repeat: Option<Component>.None)
+    let root = Column {
+        triggerSlot[0] = Some(Text("abcdefgh").focusable(true))
+        Text({ => model.get() })
+        Text("qrstuvwx")
+    }.viewport(ScrollAxes.Off)
+    let trigger = triggerSlot[0].getOrThrow()
     let app = Application(root)
     app.startHeadless()
     try {
         app.snapshot(8, 3)
         focus(app, mounted(trigger))
         let calls = [0]
         let popup = PopupMenu([MenuEntry("a", "X")], {_ => calls[0]++}).width(3).height(1)
         let handle = open(app, mounted(trigger), popup, OverlayOptions(mode: OverlayMode.NonModal))
         equal(app.snapshot(8, 3).toPlainText(), "abcdefgh\nijX  nop\nqrstuvwx", "M03 popup has public opaque surface")
         let entry = mounted(popup).children()[0]
@@ -38,64 +43,70 @@ func popupOwnership(): Unit {
         let closeEntry = mounted(closeMenu).children()[0]
         focus(app, closeEntry)
         app.dispatch(closeEntry, KeyEvent("text", text: " "))
         check(!held[0].getOrThrow().isOpen(), "M03 onChoose may explicitly close held handle")
         focused(app, mounted(trigger), "M03 callback close restores trigger")
     } finally { app.dispose() }
 }
 
 func popupEscapeBoundaries(): Unit {
     for (mode in 0..4) {
-        let trigger = Text("T").focusable(true)
+        let triggerSlot = Array<?Component>(1, repeat: Option<Component>.None)
+        let root = Column { triggerSlot[0] = Some(Text("T").focusable(true)) }
+        let trigger = triggerSlot[0].getOrThrow()
         let prevent = [mode == 3]
-        let app = Application(Column { trigger }).onKeyEvent({ event =>
-            if (prevent[0] && event.key.code == "escape") { event.preventDefault() }
-        })
+        let baseCalls = [0]; let legacyCalls = [0]
+        let app = Application(root).onKeyEvent({ _ => baseCalls[0]++ }).onKey({ _ => legacyCalls[0]++ })
         app.startHeadless()
         try {
             focus(app, mounted(trigger))
             let values = if (mode == 0) { Array<MenuEntry>() } else { [MenuEntry("a", "A", enabled: false)] }
-            let popup = PopupMenu(values, {_ => ()})
+            let popup = PopupMenu(values, {_ => ()}).onKey({ event =>
+                if (prevent[0] && event.key.code == "escape") { event.preventDefault() }
+            })
             let handle = open(app, mounted(trigger), popup,
                 OverlayOptions(mode: OverlayMode.Modal, closeOnEscape: mode != 2))
             check(app.focusedNode().isNone(), "M03 empty/all-disabled has no fake focus item")
             app.dispatch(app.activeTarget().getOrThrow(), KeyEvent("escape"))
             if (mode == 3) {
-                check(handle.isOpen(), "M03 app preventDefault blocks Escape")
+                check(handle.isOpen(), "M03 modal root preventDefault blocks Escape")
                 prevent[0] = false
                 app.dispatch(app.activeTarget().getOrThrow(), KeyEvent("escape"))
                 check(!handle.isOpen(), "M03 later allowed Escape closes")
             } else if (mode == 2) {
                 check(handle.isOpen(), "M03 closeOnEscape false blocks close")
                 app.batch({ => handle.close() })
             } else {
                 check(!handle.isOpen() && handle.closeReason().getOrThrow() == OverlayCloseReason.Escape,
                     "M03 empty/all-disabled activeTarget Escape closes")
             }
+            check(baseCalls[0] == 0 && legacyCalls[0] == 0, "M03 modal keys never reach base app or legacy handlers")
             focused(app, mounted(trigger), "M03 canceled layer restores focus")
         } finally { app.dispose() }
     }
     let inline = PopupMenu([MenuEntry("a", "A")], {_ => ()})
     let app = Application(inline)
     app.startHeadless()
     try {
         let ref = mounted(inline).children()[0]
         focus(app, ref)
         app.dispatch(ref, KeyEvent("escape"))
         check(ref.isValid(), "M03 inline popup does not invent closed overlay")
         focused(app, ref, "M03 inline Escape leaves focus")
     } finally { app.dispose() }
 }
 
 func nestedPopup(): Unit {
-    let trigger = Text("base").focusable(true)
-    let app = Application(Column { trigger })
+    let triggerSlot = Array<?Component>(1, repeat: Option<Component>.None)
+    let root = Column { triggerSlot[0] = Some(Text("base").focusable(true)) }
+    let trigger = triggerSlot[0].getOrThrow()
+    let app = Application(root)
     app.startHeadless()
     try {
         focus(app, mounted(trigger))
         let parent = PopupMenu([MenuEntry("p", "Parent")], {_ => ()})
         let parentHandle = open(app, mounted(trigger), parent, OverlayOptions(mode: OverlayMode.Modal))
         let p = mounted(parent).children()[0]
         focus(app, p)
         let child = PopupMenu([MenuEntry("c", "Child")], {_ => ()})
         let childHandle = open(app, p, child, OverlayOptions(mode: OverlayMode.Modal))
         let c = mounted(child).children()[0]
@@ -106,24 +117,29 @@ func nestedPopup(): Unit {
         let again = PopupMenu([MenuEntry("d", "Dependent")], {_ => ()})
         let dependent = open(app, p, again, OverlayOptions(mode: OverlayMode.Modal))
         app.batch({ => parentHandle.close() })
         check(!parentHandle.isOpen() && !dependent.isOpen(), "M03 parent explicit close closes dependent layer")
         focused(app, mounted(trigger), "M03 parent closure restores base trigger")
     } finally { app.dispose() }
 }
 
 func popupOwnerAndAnchor(): Unit {
     for (anchorCase in [false, true]) {
-        let anchor = Text("anchor").focusable(true)
-        let owner = Column { anchor }
-        let fallback = Text("fallback").focusable(true)
-        let root = Column { owner; fallback }
+        let components = Array<?Component>(2, repeat: Option<Component>.None)
+        let root = Column {
+            components[1] = Some(Column {
+                components[0] = Some(Text("anchor").focusable(true))
+            })
+            Text("fallback").focusable(true)
+        }
+        let anchor = components[0].getOrThrow()
+        let owner = components[1].getOrThrow()
         let app = Application(root)
         app.startHeadless()
         try {
             app.snapshot(16, 4)
             focus(app, mounted(anchor))
             let menu = PopupMenu([MenuEntry("a", "A")], {_ => ()})
             let handle = open(app, mounted(owner), menu,
                 OverlayOptions(mode: OverlayMode.NonModal, anchor: Some(mounted(anchor))))
             if (anchorCase) { app.batch({ => mounted(owner).remove(mounted(anchor)) }) }
             else { app.batch({ => mounted(root).remove(mounted(owner)) }) }
