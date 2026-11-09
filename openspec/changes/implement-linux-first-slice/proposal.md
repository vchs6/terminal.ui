# Proposal

## Why

仓库没有产品源码，已授权的Linux实施尚未落实。交付首个可构建的字符网格、声明式文本界面和Linux ANSI全屏会话，使用户实际运行应用，而不再止于探针。

## What Changes

- 正式接入固定unicode/unicodewidth/ansies，构建时生成原生Unicode库，不修改共享依赖缓存。
- 实现字符簇安全网格、基础样式、Row/Column/Text、完整帧/差分及ANSI/plain快照。
- 提供Linux TTY运行入口，键盘事件、实际尺寸/resize、正常/取消清理与可运行minimal示例。
- 独立测试设计→实现→审核→测试执行→验收；本轮不声称其他组件、响应式和M2已经完成。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

无需求行为变更：实现既有ui-construction/ui-runtime/terminal-output/terminal-session/distribution的首个有限切片，精确接口见design.md。skip_specs=true，避免复制现有规格。

## Impact

新增src、native、build.cj、examples/minimal和独立测试。版本0.0.0，SDK1.2.0 Linux x86_64。保留真实第三方许可与归属，按用户最新裁决，声明矛盾不作为实施/交付阻塞，不擅改第三方声明。用户已授权实施并要求代码；本次直接执行，不再把技能的规划停顿当作重新索取实施授权的理由。未授权上传发行包。
