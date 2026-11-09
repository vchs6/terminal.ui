# Capability Specification

状态：待实现需求规格；实现planned，验证pending。同步文档不代表能力已实现。

需求全文见 [需求说明](../../../docs/requirements.md)。

## Purpose

让应用开发者以符合字符终端语义的分类配置统一界面样式，在不引入完整 CSS 引擎、不依赖字体和像素能力的前提下复用主题，并由应用显式控制加载、切换和重载及其失败处理。

## Requirements

### Requirement: Classified terminal theme configuration
框架 SHALL 提供文本、装饰、间距与对齐、组件及聚焦/选中/禁用状态的分类主题配置；间距使用行和显示列，装饰使用字符语义。主题只改变已有状态的外观，不创建业务状态；未知或不支持的属性 MUST 给出可定位诊断，不接受完整 CSS 选择器或可执行配置代码。对应 REQ-008。

#### Scenario: Configure component state appearance
- **WHEN** 应用为按钮的正常、聚焦、选中和禁用状态配置样式并改变其已有状态
- **THEN** 外观依公开规则变化，禁用与选择等行为仍由组件或业务状态决定

#### Scenario: Reject unsupported visual properties
- **WHEN** 配置包含字体文件、像素字号、CSS 选择器或未知属性
- **THEN** 加载失败并指出文件与属性位置，不静默忽略或执行其中代码

### Requirement: Deterministic property precedence
框架 SHALL 逐属性按组件显式属性 > 可复用样式 > 主题 > 框架默认值解析；多个复用样式按声明顺序后者覆盖。同层状态覆盖按禁用 > 选中 > 聚焦 > 正常逐属性回落。未设置值回落下一来源，显式复位使用框架默认；布局、边框与内边距不自动从父组件继承。

#### Scenario: Resolve overlapping sources
- **WHEN** 组件显式设置前景、复用样式设置背景，主题同时设置两者
- **THEN** 前景取显式值、背景取复用样式，其他属性继续回落主题或默认值

#### Scenario: Resolve simultaneous states and reset
- **WHEN** 组件同时聚焦且选中，选中样式未设背景但聚焦样式已设背景，显式前景复位
- **THEN** 背景取聚焦值、前景取框架默认；移除显式复位后前景重新按来源优先级解析

### Requirement: Four preset themes share one showcase
框架 SHALL 提供深色、浅色、高对比和经典终端四套预置主题，并以同一组件展示应用验证；展示 MUST 覆盖文本、输入框、标签、菜单、按钮、单选/复选、进度、状态栏、分区容器和模态窗口及适用状态，不能为各主题维护不同组件逻辑。

#### Scenario: Switch all preset themes
- **WHEN** 同一展示应用依次切换四套预置主题
- **THEN** 组件内容、输入行为、焦点与业务数据保持一致，颜色与字符装饰依主题变化

#### Scenario: Inspect constrained terminal output
- **WHEN** 展示应用在窄屏、基础色或字符回退配置下运行
- **THEN** 四主题均遵守相同布局与降级规则，焦点及选择仍有可辨识的字符或文本提示

### Requirement: Explicit atomic theme loading
主题加载、切换及重载 SHALL 由应用显式发起，框架不默认监听文件。候选主题 MUST 在整体解析、引用及属性校验通过后于 UI 更新批次原子替换；失败保留旧主题并返回可诊断错误。成功替换自动使相关样式与绘制失效，间距或尺寸变化触发布局，不要求业务逐组件刷新。

#### Scenario: Apply valid theme changes together
- **WHEN** 应用主动重载合法配置，其中同时改变颜色与内边距
- **THEN** 界面在同一更新批次使用新主题并重新布局，无新旧主题混杂帧

#### Scenario: Keep active theme on invalid reload
- **WHEN** 文件读取失败、语法错误、变量引用缺失或属性值非法
- **THEN** 返回失败及定位信息，旧主题和当前界面继续有效

#### Scenario: Wait for explicit reload
- **WHEN** 活动主题对应文件已被外部修改但应用未发起重载
- **THEN** 活动主题不因文件变化自行改变

### Requirement: Capability-aware theme degradation
框架 SHALL 将合法颜色与文本装饰按已公布终端能力或显式覆盖配置降级，保留结构化主题原值，不修改终端全局调色板；无法可靠检测字形时 MUST 报告未知或使用配置回退，不能承诺最终字体字形。

#### Scenario: Degrade without changing the global palette
- **WHEN** 真彩色主题运行于仅支持基础色的已声明环境
- **THEN** 输出使用确定的颜色映射，不发送修改全局调色板的控制，主题原值仍可用于其他能力配置

#### Scenario: Use character fallback
- **WHEN** 能力配置要求 ASCII 边框回退
- **THEN** 圆角等装饰按公开字符策略回退，不以像素曲率或字体加载模拟支持
