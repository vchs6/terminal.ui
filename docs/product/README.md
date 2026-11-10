# 产品说明

cjtui 0.0.0 的首个切片提供 Linux ANSI TTY 文本界面：`Text`、`Row`、`Column` 组件块及前景色、背景色和粗体属性，Unicode 字符网格、纯文本与 ANSI 快照、键盘回调和终端尺寸变化时重排。普通应用无需发送 ANSI 或手动刷新。

使用仓颉 SDK 1.2.0，在 Linux ANSI 终端中从源码运行最小示例：

```sh
cd examples/minimal
cjpm run
```

按 `q` 退出，Ctrl-C 取消；程序需要实际 TTY。构建依赖及可选离线 Unicode 数据输入见 [原生构建](native-build.md)。

首片采用 `ansies` 1.3.113、`unicode` 0.1.0 和 `unicodewidth` 0.1.113。更多组件、响应式状态、多层合成、主题、M2 局部更新及完整 Linux 能力仍待实现和验收；Windows、macOS、HarmonyOS 是后续必需目标，尚未实现。当前未发布发行版。

低层可用 `Frame(width, height)` 和 `put(x, y, text, style: Style(...))` 写入网格，`cellAt` 查询，`toPlainText` 和 `toAnsi` 导出完整快照。负尺寸与越界查询报错；写入按边界裁剪，拒绝除换行外的控制字符。`render(root, width, height)` 使用同一网格渲染组件树。`Application(root).onKey { event => ... }.run()` 负责终端会话；文本按 Unicode 字符提供，`stop()` 可从回调退出。

布局可通过组件属性链设置 `width`、`height`、`minWidth`、`minHeight`、`layoutWeight`、`padding`；`widthAuto`、`heightAuto` 清除固定尺寸。`Row` 和 `Column` 还支持 `gap`、`alignItems` 和 `justifyContent`，`Text` 支持逐行 `textAlign`。尺寸与间距以字符列和行为单位，必须非负；实际视口及祖先内容区域限制绘制。正权重在容器主轴上分配剩余空间，余数按最大余数及声明顺序确定。`Alignment` 提供 `Start`、`Center`、`End`、`Stretch`，其中 `Stretch` 仅用于交叉轴对齐。显式背景填充组件外框；文本、裁剪及宽字符使用同一 Frame 规则。

组件可通过 `border(BorderStyle.Rounded)`、`borderColor(Color.Cyan)` 和 `shadow()` 设置字符装饰；`border(BorderStyle.None)` 与 `shadow(enabled: false)` 分别移除效果。边框占外框每边一行或一列，阴影仅扩展绘制范围、不改变布局，并受祖先内容区裁剪。阴影可指定正负偏移及完整 `Style`。未设置边框颜色时使用节点有效前景色；显式背景包含边框与内边距。`BorderStyle` 还提供 `Single`、`Double` 和 `Ascii`；终端宽度策略无法以一列显示某个边框字符时整套回退 ASCII。阴影字符 `░` 非一列时回退 `.`，这不代表检测了字体覆盖。

低层 `Frame.fillRect`、`drawBorder` 和 `drawShadow` 使用相同字符宽度、样式和裁剪规则；填充写入带样式的空格，边框按原矩形几何裁剪。`examples/layout` 展示标题、加权面板和底栏；按 `d` 切换边框及阴影，按 `q` 退出，终端改变尺寸时自动重排。

颜色提供 16 种命名色、`Color.Indexed(UInt8)` 和 `Color.Rgb(UInt8, UInt8, UInt8)`。`Application(root, colorMode: ColorMode.Basic16)` 指定输出能力，默认 Basic16；也可在回调中调用 `app.colorMode(ColorMode.Indexed256)`，或选择 `TrueColor`、`Monochrome`。降级使用固定名义调色板的 RGB 平方距离，距离相同时选择较小索引；实际终端可能使用自定义调色板。Monochrome 保留文本属性。`Frame.toAnsi(colorMode: ...)` 按指定能力导出，网格仍保留原始颜色。

文本属性包括 `bold`、`dim`、`italic`、`underline`、`inverse` 和 `strikethrough`。组件属性链如 `.italic()` 启用属性，`.italic(false)` 显式关闭继承值；`Style` 对应参数默认为 false。文本、显式背景和边框继承这些属性，阴影使用传入的完整 Style。

`examples/colors` 展示命名色、索引色、RGB 和文本属性；在终端中按 `c` 依次切换 Basic16、Indexed256、TrueColor 和 Monochrome，按 `t` 切换属性，按 `q` 退出。
