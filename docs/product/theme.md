# 主题配置

主题使用单个 TOML 文件。`Theme.parse(text)` 同步解析内存文本，`Theme.readFile(path)` 同步读取明确指定的文件；失败会抛出带 `ThemeDiagnostic` 的 `ThemeException`。`Theme.preset(ThemePreset.Classic)` 等工厂使用内置配置，无需从当前工作目录读取文件。随包 `themes/` 的四个 TOML 文件可作为编辑起点。

配置必须包含整数 `schema_version = 1` 和非空可打印的 `name`。可选的 `variables`、`text`、`decoration`、`spacing`、`components` 与 `styles` 是闭集；未知字段会诊断。变量可用 `{ ref = "name" }` 引用，`{ reset = true }` 表示显式恢复框架默认。删除字段表示未声明；`false`、零和 `"default"` 都是实际值。

解析前限制 UTF-8 文件为 1 MiB；变量和命名样式各最多 4096 项，值容器深度和有效键路径各最多 16 层，非 EOF token 最多 65536 个，键及表声明最多 16384 个。每个键段最多 1024 字节，按上游 Lexer 的原始键 token UTF-8 字节测量：引号定界符不计，转义拼写按输入字节计。通过资源预算后，等价 TOML 写法具有相同语义。

此配置值和解析接口不自动切换正在运行的应用。主题应用、显式加载和完整组件展示各有独立实现与验证阶段。
