# Capability Specification

状态：待实现需求规格；实现planned，验证pending。同步文档不代表能力已实现。

需求全文见 [需求说明](../../../docs/requirements.md)。

## Purpose

明确字符终端会话与宿主可选能力的边界，使应用在本地或 SSH 连接下使用一致的核心界面，并能判断剪贴板、标题和实际图片图标请求是否受支持、是否确认生效，以及退出时哪些状态可以真实恢复。

## Requirements

### Requirement: Character terminal session remains the foundation
框架 SHALL 以实际行列尺寸、字符显示、键盘事件、布局和刷新提供基础会话；本地设备剪贴板、宿主标题及实际图片图标均为可选能力。可选能力未知、不支持或独立请求失败 MUST 不妨碍核心界面运行；若实际设备写入破坏同步，则仍遵守统一输出失败与停止契约，不能要求图形宿主或远程系统剪贴板作为核心依赖。对应 REQ-010。

#### Scenario: Run without optional host features
- **WHEN** SSH 会话或文本终端未提供剪贴板、标题和图片图标能力
- **THEN** 核心界面仍可显示、输入、导航和刷新，可选操作返回明确能力或失败结果

### Requirement: Report capabilities separately from operation results
框架 SHALL 分项报告 supported、unsupported 或 unknown 及其依据，不能只凭终端名称或写入成功宣称能力生效。操作 MUST 区分已确认生效、已发送但未确认、不支持、未知及失败；只有可靠宿主确认或已验证适配依据才可声称已生效，写入失败不得静默成功。

#### Scenario: Do not equate bytes written with host effect
- **WHEN** 后端成功写出标题或剪贴板控制但没有宿主确认
- **THEN** 操作返回已发送但未确认，不宣称本地标题或剪贴板已改变

#### Scenario: Report rejected or partial operations
- **WHEN** 功能被禁用、能力无法判定或输出仅部分成功
- **THEN** 分别返回不支持、未知或失败及原因，核心输入与屏幕更新继续遵守自身错误契约

### Requirement: Clipboard targets the terminal user's local device
复制 SHALL 在已声明可用时经终端剪贴板通道发送文本；SSH 下目标是用户本地设备。粘贴 SHALL 接收终端投递的文本事件或括号粘贴数据，不主动查询或读取本地剪贴板。框架 MUST 不以远程主机剪贴板命令替代本地设备，不因剪贴板不可用而伪称复制成功。

#### Scenario: Copy from a remote application
- **WHEN** 用户在 SSH 应用中复制且会话已配置可用的 OSC 52 通道
- **THEN** 文本经该通道发送至用户终端，返回与确认能力相符的结果，不执行远程剪贴板工具

#### Scenario: Receive pasted text without querying clipboard
- **WHEN** 用户通过终端粘贴多行文本且终端投递括号粘贴事件
- **THEN** 框架将其作为粘贴文本交给有效输入目标，不当作逐键快捷命令，不发送剪贴板读取查询

#### Scenario: Copy channel unavailable
- **WHEN** 用户请求复制但本地设备剪贴板通道不支持或未知
- **THEN** 操作返回不支持或未知，应用可报告结果，其他键盘编辑继续可用

### Requirement: Distinguish title from actual image icon
宿主标题 SHALL 在已声明能力下通过适配通道设置；实际图片图标 SHALL 独立报告能力并仅在已验证宿主接口可用时支持。框架 MUST 不把 OSC 1 图标名称或界面内图片当作实际宿主图片图标，不宣称通用字符终端协议支持图片图标；非法控制内容不得注入设备控制序列。

#### Scenario: Set a supported host title
- **WHEN** 应用显式请求设置合法标题且会话已声明 OSC 2 或等效通道可用
- **THEN** 请求通过统一后端发送，结果区分已发送与确认生效

#### Scenario: Reject unsupported image icon request
- **WHEN** 应用请求设置 PNG 等实际图片图标但没有已验证宿主适配
- **THEN** 返回不支持或未知，不改发 OSC 1 名称并宣称图片图标已设置

#### Scenario: Reject control sequence injection
- **WHEN** 标题包含 ESC、BEL 或其他可突破参数边界的控制内容
- **THEN** 请求被诊断拒绝，不将该内容作为设备控制透传

### Requirement: Restore only session state that can be restored
正常、异常和取消退出时，框架 SHALL 清理由自身实际开启的输入模式与会话资源；宿主标题或图片图标只在通道支持保存/恢复且已保存原状态、又由框架修改时承诺恢复。未知原值或缺少恢复通道 MUST 明确报告不可保证，不能把写入默认值称为恢复原值；失败须可诊断。

#### Scenario: Restore saved host state
- **WHEN** 已验证通道保存了原标题且框架随后修改标题，再正常或取消退出
- **THEN** 执行该通道的恢复动作并报告其结果，不恢复未由框架修改的宿主状态

#### Scenario: Do not fabricate restoration
- **WHEN** 原始标题/图标未知或恢复写入失败
- **THEN** 分别报告无法保证恢复或恢复失败，不宣称宿主已回到原状态；其他可清理资源仍继续清理

### Requirement: Cross-platform core including HarmonyOS

框架 SHALL 以Linux、Windows、macOS、HarmonyOS为必需目标，使用统一公开UI/API及视图源码；每个OS至少有一个冻结配置完成核心字符UI验收。平台差异限于会话/依赖适配及能力配置，不能把图形宿主作为核心前提。对应REQ-011。

#### Scenario: Same application across targets

- **WHEN** 同一应用在各冻结OS/SDK/CPU/ABI/字符终端宿主配置构建运行
- **THEN** 组件、布局、状态、键盘和更新遵守同一契约；输入、尺寸、写入/失败及退出恢复有分目标证据，缺任一目标不报完整跨平台支持。

#### Scenario: Require HarmonyOS local execution evidence

- **WHEN** 只有交叉编译成功、OpenHarmony测试、鸿蒙作SSH客户端访问Linux或输出应用日志
- **THEN** 保持HarmonyOS端到端字符UI验收pending；需实际目标环境中的交互输入/渲染/尺寸/恢复证据，不能改称GUI支持。

#### Scenario: Separate optional host features

- **WHEN** 某必需目标不支持剪贴板、窗口标题或图片图标
- **THEN** 核心字符UI仍按平台契约运行，可选操作明确报告能力，不因此取消该OS目标。
