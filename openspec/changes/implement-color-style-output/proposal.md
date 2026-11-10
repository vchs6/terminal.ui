# Why

R9已交付布局/装饰，但Color仍只有8色、Style只有bold，TASK013主题依赖的TASK006尚缺16/256/RGB与能力映射。先完成这一基础，避免主题建立在错误颜色或另一套样式内核上。

# What Changes

实现既定TASK006：扩展结构化Color/Style和组件属性；Frame与Application显式颜色模式、确定性降级、按有效输出差分；交付可运行颜色示例。继续使用ansies公开编码API，依赖最近邻缺陷仅用框架策略薄适配，不修共享包或引入新依赖。

# Capabilities

不新增规范级目标；落实REQ001文本样式/REQ005.4和既有AC006。现有终端输出/状态/性能要求不改变，skip_specs=true。

# Impact

style类型、根重新导出、共享ANSI序列化与Frame差分、组件样式继承、Application输出模式、示例/测试/产品说明。输入/native/布局算法/字体/主题文件/M2/其他平台不改。保持0.0.0、SDK1.2及原依赖。主代理只写契约/文档/集成；独立测试、实现、审核、执行、验收。
