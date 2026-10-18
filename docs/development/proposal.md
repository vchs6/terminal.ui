# 项目提案

## Why

现有实现与新确定的用户构造契约存在显著差距，且没有可追踪的功能重建计划。以 PR #1 三份规范为基线重建开发仓库，使后续实现能按依赖、验收与发布边界推进。

## What Changes

- 建立 OpenSpec 与 Superpowers 开发入口、唯一任务状态及验收映射。
- **BREAKING**：旧实现隔离至 legacy，不作为新框架；新框架按组件块、属性链、仓颉状态/回调重建，不承诺旧内部 API 兼容。
- 规划主库、示例和基准项目，区分产品文档与开发文档；CJPM 仅打包产品文件。
- ANSI / Unicode 采用用户指定的中心仓依赖，以适配边界避免平行实现。
- 配置规划检查 CI 与后续产品构建、测试、基准及实际制品检查入口。
- 本轮仅交付目录治理、配置、CI 和提案；不授权功能实现、语法原型、示例/基准源码或产品发布；仓库文档与配置合并不构成功能实施授权。待用户后续授权再实施 [工程任务](../tasks.md)。

## Capabilities

### New Capabilities

- `ui-construction`：声明式构造、自定义组件与 U1–U5。
- `ui-runtime`：状态生命周期、布局、装饰、多层界面与焦点。
- `terminal-output`：字符完整性、差分恢复、ANSI 与文件快照。
- `distribution`：最终源码制品、示例、基准、文档和许可证边界。
- `development-workflow`：可复核的开发工具、任务与 CI 推进。

### Modified Capabilities

需求基线位于 openspec/specs/，记录既有治理基线的待实现行为，不将基线存在或旧源码存在当作已实现能力。

## Impact

影响根 cjpm.toml、历史源码位置、文档入口、CI 和开发工具配置。模块名 acnl 暂保留，不擅自改名；SDK 验证基线更新至 1.2.0，以满足 unicode 所声明的最低版本并验证中心仓发布工具。依赖版本 ansies 1.3.113、unicode 0.1.0 已从中心仓核实，编译兼容性尚未验证。完整技术取舍见 [参考实现方案](../architecture.md)。
