# Proposal

## Why

REQ-010 与 TASK-030 已要求应用通过统一会话复制到用户本地设备、设置宿主标题并诚实报告可选能力，但当前 Application 尚无这些公共入口。真实 XTerm/VTE/tmux/screen 调查证明“完整写出”“实际应用”“原标题恢复”是三个不同事实，必须先冻结可测试的结果和恢复契约。

## What Changes

- 在现有 Application/RuntimeSession/Linux native 输出拥有者内增加显式复制、标题、图片图标降级入口，普通调用不需要先选择终端能力。
- 分离 Supported/Unsupported/Unknown 能力与 Applied/SentUnconfirmed/Unsupported/Unknown/Failed 执行结果。现有 OSC 通道没有可靠效果回执，Applied 不可达。
- Auto 不发送主动探针、不猜 TERM 白名单；显式请求允许按固定 Direct OSC 候选尝试，能力仍 Unknown，完整发送只返回 SentUnconfirmed。没有请求不输出扩展控制。
- OSC 52 只写本地用户 CLIPBOARD；不 query、读系统剪贴板、启动 xclip/wl-copy 或 shell。标题用 OSC 2；标题栈独立评估。实际图片图标无 adapter 时 Unsupported，绝不改发 OSC 1。
- 冻结 UTF-8/控制字符/有界负载、统一 UI 域与 post FIFO、部分写入停止和清理结果、未来 cut 的 Applied+revision 条件。
- 预留 TASK-148–152 分别给独立测试、产品实施、审核、执行、验收；TASK-030 仍是完整父验收责任，001/003/004/020/041 的相关子范围映射不能提前关闭原父项。

## Capabilities

### New Capabilities

无；沿用 terminal-session，避免建立第二 session/runtime 能力域。

### Modified Capabilities

- `terminal-session`：细化分项能力与发送结果、Unknown 显式尝试、本地只写剪贴板、标题恢复 ledger、有界编码、统一线程/输出失败及 cut 消费条件。

## Impact

拟影响 `src/application.cj`、`src/runtime_session.cj`、`src/terminal_bridge.cj`、`native/cjtui_terminal.c`，增加小型纯值类型与编码函数；实际每类型独立文件。复用现有 native open/close 与 R10 异常清理围栏，不另建输入循环、线程池、TTY 或运行时。无需新增产品依赖。正式测试/消费者/真实 host 执行由后续独立角色编写。

此目录为隔离草稿；产品、正式测试、主仓均未修改。全部新签名和示例尚未编译；OpenSpec 静态验证不是产品通过。主代理最终冻结后进行独立 preflight，再顺序派五角色。Linux 授权允许自主推进常规选择；其他 OS、发布和完整图片图标适配不在本增量内。
