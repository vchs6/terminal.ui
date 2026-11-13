# 主题配置

主题使用单个 TOML 文件。`Theme.parse(text)` 同步解析内存文本，`Theme.readFile(path)` 同步读取明确指定的文件；失败会抛出带 `ThemeDiagnostic` 的 `ThemeException`。`Theme.preset(ThemePreset.Classic)` 等工厂使用内置配置，无需从当前工作目录读取文件。随包 `themes/` 的四个 TOML 文件可作为编辑起点。

配置必须包含整数 `schema_version = 1` 和非空可打印的 `name`。可选的 `variables`、`text`、`decoration`、`spacing`、`components` 与 `styles` 是闭集；未知字段会诊断。变量可用 `{ ref = "name" }` 引用，`{ reset = true }` 表示显式恢复框架默认。删除字段表示未声明；`false`、零和 `"default"` 都是实际值。

解析前限制 UTF-8 文件为 1 MiB；变量和命名样式各最多 4096 项，值容器深度和有效键路径各最多 16 层，非 EOF token 最多 65536 个，键及表声明最多 16384 个。每个键段最多 1024 字节，按上游 Lexer 的原始键 token UTF-8 字节测量：引号定界符不计，转义拼写按输入字节计。通过资源预算后，等价 TOML 写法具有相同语义。

构造 `Application(root, theme: Theme.preset(ThemePreset.Dark))` 可设置初始主题；也可传入成功解析或读取的 Theme。组件属性高于有序复用样式，后加入的复用样式高于先加入的样式，其后是组件角色主题、继承值和框架默认值。组件可用 `.styles([StyleUse.Named("accent")])` 引用主题内命名样式；显式 `Reset` 结束该属性的回落。文本绘制属性继承，间距和装饰不继承。

同步解析和读取不会自动切换正在运行的应用。运行中调用 `app.loadTheme(ThemeSource.File(path))`、`ThemeSource.Preset(...)` 或 `ThemeSource.Prepared(theme)` 返回 `ThemeRequest`；通过 `request.result()` 查询待处理或终态 `Applied`、`Failed`、`Superseded`、`SessionClosed`。最新请求优先，成功提交后可用 `app.themeInfo()` 查询已接受的主题及版本。`app.reloadTheme()` 重新读取最近一次成功接受的文件来源；没有文件来源时返回失败结果。完整组件展示属于后续阶段。

`visualStates(VisualStates(disabled: true))` 只选择外观状态，不禁用事件或改变业务状态；控件的交互状态由控件自身管理。

根级 `[text]` 的八个文本绘制属性是逻辑根的默认种子，并随父节点解析结果继承。例如，主题根前景为白色时，`Column { Text("x") }.foreground(Color.Red)` 中的文字继承红色；如果 `components.text.text.foreground` 指定蓝色，该文字自己的角色主题会覆盖继承值。
