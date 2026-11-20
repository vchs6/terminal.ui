# 继续 Linux 工作

先按[本地开发指南](local-setup.md)配置环境。当前产品源码以 `d7e9d1445f98021a798d223de97b97b45239de93` 的已集成版本为基线。M1、公开示例、主题展示和 M2 的已接受子范围见[Linux 阶段计划](../linux-completion-plan.md)。完整 Linux 仍待收尾。

## 执行顺序

1. 完成 Linux 六宿主 C008 整合并核对各宿主的构建、输入、渲染和恢复证据。历史五宿主结果限于其固定源码和场景，真实 Linux VT 仍待按现行合同取证。
2. 执行 TASK-023 完整源码包、正常 bundle、独立解包构建和消费者验证。
3. 执行 TASK-024 独立整体验收，逐项确认必需 Linux AC。

TASK-023 已有原独立负向测试 [tests/release](../../tests/release/)。输入来自 `8c20fb5c11d8a7d9f2b8033732f55adde3e63f1c` 的待完成工作，当前 check-bundle/check-product 还存在这些测试揭示的已知缺口。保持预期的红测并单独执行 `node --test tests/release/*.test.mjs`，通过条件由 TASK-023 验收定义。

C008 的固定 operator、契约、在途输入及本地源码检查见 [C008 接续目录](../../tools/linux-acceptance/c008/README.md)。

## 剩余任务入口

这 11 个稳定编号在交接时仍有开放的 Linux 父验收。任务身份、依赖和状态在各自页面维护。

| 编号 | 权威任务页 |
|---|---|
| 001、002、003、004、020、023、024、041 | [Linux 收尾 tasks](../../openspec/changes/complete-linux-integration/tasks.md) |
| 019 | [标准控件 tasks](../../openspec/changes/implement-standard-widgets/tasks.md) |
| 028 | [Linux 输入编辑 tasks](../../openspec/changes/implement-linux-input-editing/tasks.md) |
| 030 | [项目任务中的会话能力](../tasks.md#task-030可选会话能力与本地剪贴板通道)，已接纳的子范围见[会话扩展 tasks](../../openspec/changes/implement-session-extensions/tasks.md) |

状态细节见[工程任务索引](../tasks.md)和[验收矩阵](../acceptance.md)。Windows、macOS、HarmonyOS 为后续目标。
