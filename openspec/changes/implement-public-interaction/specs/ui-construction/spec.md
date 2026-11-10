# Public interaction construction delta

## MODIFIED Requirements

### Requirement: 公共构造与复用

框架 SHALL 通过公开接口实现 U1–U5，不要求普通应用计算全屏坐标、写 ANSI、操作缓冲区或手动刷新；相同组件类型能够用于容器及弹窗。标准控件使用与用户相同的公共组合能力；自绘仅增加一个通用Canvas叶，不新增Button/Input专用渲染kind。

#### Scenario: 跨场景组合
- **WHEN** 应用复用自定义进度面板并更新业务状态
- **THEN** 普通容器和弹窗均显示新状态，无内核专用业务分支；两处可共享业务model但使用各自未挂载组件实例。

#### Scenario: Already mounted instance
- **WHEN** 应用把已挂载组件实例再次作为overlay内容
- **THEN** 报AlreadyMounted并保持原挂载，不隐式复制、跨父移动或复活旧NodeRef。

## ADDED Requirements

### Requirement: Public measurement and painting

框架 SHALL 提供以约束测量内容自然Size、以受控局部上下文绘制的公开Canvas。measure/draw独立跟踪可观察读，复用同一文本验证、字符簇、宽度与样式规则；Canvas不接受静态Text排版或容器专属属性。

#### Scenario: Independent progress repaint
- **WHEN** Progress公共消费者的draw读取进度而measure只读取固定尺寸
- **THEN** 进度更新只形成paint依赖失效；M1仍可完整测量绘制，不以此宣称M2已实现。

#### Scenario: Invalid capability
- **WHEN** 用户对Canvas设置gap或静态wrap/ellipsis/textAlign
- **THEN** 明确报InvalidProperty，不因ThemeRole标签而获得不存在的能力。

### Requirement: Public visual selection

框架 SHALL 由同一主题resolver提供当前与selected文本样式，允许公共绘制指定选区patch；优先级为组件显式、绘制patch、span、复用/主题/继承。visualStates只是外观，不修改业务enabled或执行焦点迁移。

#### Scenario: Explicit reset over selection patch
- **WHEN** Canvas显式设置某文本字段为框架复位值，同时选区或span给该字段另一值
- **THEN** 显式字段仍优先，其他未显式字段继续从选区及span解析，不整块覆盖全部Style。

### Requirement: Default scroll construction

框架 SHALL 在公开构造指南中将可变长度主体默认放入Vertical ScrollView，固定菜单和状态条留普通布局；用户可以显式选择Horizontal/Both。普通非root Column保留原布局语义；Application根未声明viewport时提供Vertical兜底，root.viewport(Off)明确关闭。框架不自动修改业务visible。

#### Scenario: Body and fixed chrome
- **WHEN** 用户按公开指南构造固定菜单、100行主体与固定状态条
- **THEN** 主体可纵向访问全部行，菜单和状态条不随主体offset移动，窗口缩小只影响分配与clip。
