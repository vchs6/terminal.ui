# 终端 UI 框架参考调查

调查日期：2026-11-09。目的为 cjtui 的组件、失效传播、合成与 M1/M2 渲染选择提供一手依据；未安装或运行这些框架，未做同负载测量，不给性能排名。下表事实来自官方仓库与文档；“借鉴”是本项目工程判断，不是已经实现或兼容的声明。

| 框架与核对版本 | 一手证据与事实 | cjtui 借鉴及边界 |
|---|---|---|
| Ratatui；main `2b7b78e`（2026-11-07） | [终端渲染源码](https://github.com/ratatui/ratatui/blob/2b7b78e786cda9e7328fd402d02dc9480fc4de7e/ratatui-core/src/terminal.rs)与[官方 rendering](https://ratatui.rs/concepts/rendering/)说明每次生成完整可见帧，比较前后缓冲，仅把变化交给后端；未绘制的内容按空白处理 | M1 采用完整目标帧与最后成功帧差分，建立确定性基线；公开 API 仍由框架自动更新，不要求应用维护手工 draw 循环。借鉴机制，不引入 Rust 依赖 |
| FTXUI；7.0.3（2026-08-06），另核 main `fa2ae5b` | [README](https://github.com/ArthurSonzogni/FTXUI/blob/fa2ae5b8f02507e409e53e60e130aafa3c145505/README.md)分 screen、dom、component 三层；[CHANGELOG](https://github.com/ArthurSonzogni/FTXUI/blob/fa2ae5b8f02507e409e53e60e130aafa3c145505/CHANGELOG.md)在 `Next` 下列出屏幕单元差分输出与同步更新，不能当成 7.0.3 已发行能力 | 区分底层屏幕、布局组合和交互组件；功能式描述可与持久运行节点组合。差分及同步更新按实际版本取证，不将未发行记录当性能优势。不引入 C++ 依赖或其源码构造语法 |
| Terminal.Gui；v2.5.0（2026-09-11） | [发布记录](https://github.com/tui-cs/Terminal.Gui/releases/tag/v2.5.0)、[View 文档](https://github.com/tui-cs/Terminal.Gui/blob/v2.5.0/docfx/docs/View.md)区分 `SetNeedsLayout` 与 `SetNeedsDraw`；[Scheme 文档](https://github.com/tui-cs/Terminal.Gui/blob/v2.5.0/docfx/docs/scheme.md)按 Normal、Focus、Disabled 等语义角色取样式，主题改变标记绘制失效 | 为 M2 区分测量/布局/绘制失效，主题配置按组件状态组织；不照搬其所有角色、父子继承或配置管理框架，不引入 C#/.NET。v2.5.0 本身包含 API 变更，版本固定后再评估接口 |
| Ultraviolet；main `a45b7c8`（2026-10-23） | [README](https://github.com/charmbracelet/ultraviolet/blob/a45b7c86333f9dfedb95f81064e80259b02937f0/README.md)定位为 Go 终端原语，提供 cell buffer、差分 renderer、统一键鼠输入；Terminal 管生命周期、Screen 管屏幕与模式，且提示 API 仍在演进 | 参考底层字符单元、缓冲/窗口接口与平台事件归一化的分工；不当作 ArkUI 应用构造层，不引入 Go 依赖，不扩大内联模式、鼠标或暂停功能范围 |
| Textual；官方 2024-12-12 文章（1.0 里程碑说明） | [作者 compositor 文章](https://textual.textualize.io/blog/2024/12/12/algorithms-for-high-performance-terminal-apps/)说明按行切分 styled segments，丢弃遮挡片段后合成，并讨论宽字符、裁剪、滚动、局部更新和 spatial map | 参考覆盖层最终可见内容、裁剪与局部失效，M2 必须保持与完整帧相同结果；不据文章推断当前版本表现，不引入 Python、Rich、CSS/DOM 引擎或 JS 依赖 |
| termbox2；master `8673286`（2026-11-08） | [README](https://github.com/termbox/termbox2/blob/8673286e50d34945427d3cb2618428386e7e7154/README.md)展示 cell 写入/呈现及事件轮询，并明确不包含输入框、复选框等控件 | 参考小型终端后端的职责边界及可控输出；本项目需要更高层组件组合与生命周期，不能用极简后端替代这些要求。不引入 C 依赖 |

## 性能证据边界

[Terminal.Gui #5323](https://github.com/tui-cs/Terminal.Gui/issues/5323) 于 2026-05-17 提交，核对时仍为 open（最后更新 2026-09-16），报告 v2 相对 v1 的输入、滚动与重绘退化。它是特定版本/负载的缺陷线索，既不能忽略后宣称 v2 最快，也不能代替对 v2.5.0 或其他框架的统一基准。发布记录列出若干修复不等于该 issue 已解决。

本项目保留 M1 完整帧差分，M2 再实现有明确失效边界的局部布局/绘制；两阶段共享公开应用 API、Unicode/裁剪不变量与输出失败契约。M2 需要同一输入轨迹下与 M1 的帧等价性及宽字符、缩放、层移动/关闭和主题改变反例，不能只用“输出字节更少”证明正确。

未来基准应固定框架版本、终端行列、字符/颜色负载、更新区域、输入节奏、连接路径、终端/OS 和测量方法，分别记录布局/合成耗时、输出字节及交互延迟；未经实测不给 FPS 或最快结论。以上方案均为机制借鉴，产品依旧用仓颉和已验证的指定依赖边界；字符簇与显示宽度的依赖选型由本轮实际证据另行决定。
