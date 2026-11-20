# 开发环境与 CI

[本地开发指南](local-setup.md)提供依赖下载、SDK/stdx 环境、构建、示例和开发工具命令。[当前 Linux 工作](continue-linux.md)提供交接及各阶段验收入口。

## 规范与技能

根 [package.json](../../package.json) 是私有开发工具包。以 `npm ci --ignore-scripts` 安装固定依赖，`npm run dev:setup` 将锁定的 Superpowers 工作副本放在 `.dev-tools/superpowers`，建立 `.agents/skills/superpowers` 并运行 OpenSpec 配置更新。

OpenSpec 的 Codex 技能由固定 CLI 生成并跟踪。新开或重载代理后检查技能发现，在任务中实际调用适用技能。其他宿主按上游入口配置。OpenSpec 工件、任务准入和证据记录遵循 [AGENTS.md](../../AGENTS.md) 第 10 节。

| 工作记录 | 权威位置 |
|---|---|
| 总体设计与具体变更设计 | [架构](../architecture.md)和相应 OpenSpec `design.md` |
| 工程任务 | [任务索引](../tasks.md)及已启动变更的 `tasks.md` |
| 长期需求与场景投影 | [需求说明](../requirements.md)和 [OpenSpec 规格](../../openspec/specs/) |
| 验收事实 | [验收矩阵](../acceptance.md)与固定证据 |
| 历史原件 | [历史审查快照](https://github.com/vchs6/terminal.ui/tree/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews) |

## 检查入口

- `npm run check` 检查清单、有效本地链接、任务引用和 OpenSpec。
- `bash scripts/check-product.sh slice` 在已配置 SDK/stdx 的环境验证当前主库、样例、基准项目和现有切片测试。
- `bash scripts/check-product.sh release` 是最终制品核对入口，运行实际 bundle、解包构建、示例 smoke 和基准。完整发行验收仍由 [TASK-023/TASK-024](../../openspec/changes/complete-linux-integration/tasks.md)负责。

[CI](../../.github/workflows/ci.yml) 有 repository、toolchain 和 product 作业。手动 `release_check=true` 触发 release 模式。局部或持续集成通过仅对应各自执行范围；物理宿主和实际制品有独立验收依据。当前流程无发布步骤。

## 制品边界

根 [cjpm.toml](../../cjpm.toml) 的 `package.include` / `package.exclude` 定义源码制品边界。`scripts/check-bundle.mjs`检查实际 `.cjp` 文件。GitHub 源码 ZIP 是仓库导出。产品使用说明位于 [docs/product](../product/)；开发资料、测试工具和生成目录由源码开发检出管理。
