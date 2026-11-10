# Change: Linux VT glyph adaptation

## Why

真实 Linux 文本 VT 的当前 BMP→font 映射缺少中文、圆角、组合重音和 emoji 所需成员，逻辑 Unicode Frame 正确仍会显示缺字。应用应继续声明完整文本/装饰，框架默认按已知设备能力适配；不能要求程序员根据 TERM 选择字体能力。

## What Changes

- 引入高级可选 `GlyphMode.Auto / Unicode / Ascii`，Application 默认 Auto；已确认文本 VT 可按只读 GIO_UNIMAP 和宽度约束准入，其余整簇输出等宽 ASCII；未知模拟器保持 Unicode 输出但诊断覆盖率未知。
- 复用 TerminalRenderProfile 和 Frame 设备编码/差分路径，逻辑 Frame、业务文本、宽簇、布局/caret 与默认文件快照保持 Unicode；边框 fallback 复用现 ASCII 对应组。
- 新增最小只读字形诊断，不公开 bitmap 或字体加载接口；探测生命周期与 R10 相同。
- `snapshot/render` 新增显式 glyphMode 参数，默认离线 Unicode，不读设备。Ascii 生成标记上下文与纯函数交给 Theme013；完整 ellipsis 排版仍由其现唯一文本布局实现、085 追加测试和088验收，不在093–097提前交付。
- 在 runtime080 与 richtext084 固定集成后、theme013/025产品前交付093–097有限子接口。完整041/AC041仍等所有规定宿主/场景和最终产品汇合。

## Impact

需求引用 REQ-001.7、REQ-004.2–.7、REQ-005.4–.6、REQ-011；不改变既有主题085冻结公共API。受影响为 Application、RuntimeSession帧缓存键/布局上下文、LayoutNode/Frame设备输出、TerminalRenderProfile、原生Linux探测及产品文档。保持Unicode17数据/现分簇/宽度依赖及ansies，不加字体/GUI依赖、不做NFC或console模式切换，不发布。

本目录为独立草稿，待主代理冻结及独立preflight；不是主仓已生效变更。技术证据与范围见 decisions.md、design.md、原调查 ../../../../draft.md。
