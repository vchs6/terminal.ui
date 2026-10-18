# R1 项目基线目录整理

分类：执行型。用户明确不保留整项目重建变更目录，本次仅整理基线位置与引用，不修改产品需求、源码或实施授权。

提案移至 docs/development/proposal.md；参考设计、任务分别合并到 docs/architecture.md、docs/tasks.md；规格转为 openspec/specs/ 下的待实现需求基线。没有执行 archive，也未将任何功能任务标为完成。

采用已安装 Superpowers using-superpowers 的流程检查及 verification-before-completion 的证据要求，读取 OpenSpec update 技能和 CLI 状态；按用户明确的目录移除要求调整布局，不重新生成替代的整项目 change。OpenSpec 配置和六个技能入口保留，后续具体能力变更照常使用工作流。

唯一状态归属由 AGENTS 第 10.1 节统一规定：项目任务基线在 docs/tasks.md；后续具体变更取得对应任务的状态权威后，基线只保留引用。CI 改为校验全部现有规格与变更，不再绑定特定目录名。引用、任务编号、验收对应关系和 OpenSpec strict 在提交前检查；功能能力仍 planned/pending。

验证结果：npm run check 通过，五项基线规格 strict 均通过；openspec list --json 返回 changes=[]；旧目录和活动引用已清除；任务与验收编号保留，未运行无关功能测试。
