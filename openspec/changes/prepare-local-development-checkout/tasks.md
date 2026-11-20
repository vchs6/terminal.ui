# 维护任务

L1 目标沿用 REQ-007 连续开发和可追踪交付。L2 工作包 WP-007-CHECKOUT 为可重建的独立开发检出。任务状态以本文件为准，规划和验收依据分别见[设计](design.md)及[执行记录](evidence.md)。

共用分类为执行型，CLEAN-D01 已明确当前树范围和历史恢复方式。工作流为 `prepare-local-development-checkout`，入口 `tasks.md`。适用 Superpowers 为 brainstorming（落实范围决策）、using-git-worktrees（隔离原工作区）、writing-plans（分解与验收）、executing-plans（实施）、test-driven-development（复现活动消费者中断）、verification-before-completion（验收证据）。通过宿主技能发现与实际读取使用，OpenSpec CLI 1.14.3 读取项目生成的 Codex 入口及相应工件指令。版本锁见 `docs/development/tools.lock.json`。已勾选的维护 L3 有对应[实测证据](evidence.md)。

## 1. 活动测试输入

- [x] 1.1 GOV-007 将活动历史输入变成当前检出夹具。

类型 verification / tooling。输入为独审 CLEAN-01、current TSV/JSON、颜色 resize oracle 与固定原 blob。前置为可读的固定提交和历史原 blob，无产品任务依赖。范围为夹具定位、原始文件、控件和主题 runner 的环境输入、使用说明。交付正式准入与原 oracle 自包含输入，保持测试含义及编译运行边界。

- AC-GOV-007-A：取掉旧审查树后，preparation 正常通过。gate-selftest 仍拒绝伪造或非祖先 SHA、缺失证据。比较七份 SHA-256。
- AC-GOV-007-B：main-only 检出中颜色 oracle 可执行，旧实现仍拒绝相同帧，当前 oracle 保留合法和非法边界。执行原 `resize_oracle_test.mjs`。
- AC-GOV-007-C：控件、主题的 runner 继承当前 SDK/stdx，且无旧宿主默认值。执行 shell/Python 语法检查、两条独立 oracle 自检和已配置环境下的公开 smoke。
- 归属：当前 TSV/JSON 与测试 fixture。七份旧本地路径迁移，颜色 Git 查找退役。新增固定摘要校验，兼容例外无。风险为错误迁移历史映射或改变旧 oracle 数据。

L4 S1 复现缺历史的两条入口失败。S2 固定字节与消费者定位迁移，使用调用者环境。S3 比较摘要并跑现有正负用例，记录结果。

## 2. 本地开发说明

- [x] 2.1 GOV-008 提供自下载依赖和普通构建的开发入口。

类型 documentation。输入为 SDK 锁、中心仓版本/摘要、native build 说明和 Node 锁。无产品任务依赖。范围为 README、开发文档、当前接续导航。交付可复制的 Linux 手顺及精确依赖表。

- AC-GOV-008：干净检出按指南安装开发工具并执行 repository/OpenSpec 检查；正常 SDK/stdx 构建和非交互示例的实际结果须记录。
- 归属：开发步骤集中在 local-setup，版本仍由现有锁定数据维护。环境页旧叙述退役，CI 与产品文档继续使用现有边界。新增指南无功能分支。风险为镜像、版本或下载布局与命令不符。

L4 S1 对照锁源和 vendor 布局。S2 更新 README、精确依赖和环境入口。S3 按文档跑开发工具与产品验证。

## 3. 在途输入与历史退役

- [x] 3.1 GOV-010 提供 C008 和 TASK-023 在途输入及当前接续导航。

类型 documentation / tooling。输入为固定来源审计和当前 C008 契约，依赖固定输入清单。范围为 C008 操作/验证输入、TASK-023 原测试及接续文档。交付可从检出定位的当前输入和执行前提。

- AC-GOV-010：核对固定来源、输入摘要与入口，自包含运行可本地执行的检查。TASK-023 测试与原 Git blob 等同且仍暴露已知红测。六宿主采集与产品验收状态在各自权威任务中记录。
- 归属：在途接续说明链接 Linux 工作包、专项测试及源固定清单，不复制任务状态或导入产品改动。风险为引用到旧镜像或用旧物理证据代替当前结果。

L4 S1 审计外部候选来源与契约优先级。S2 纳入固定最小输入。S3 验证源清单和本地检查。

- [x] 3.2 GOV-009 将历史迁移和旧证据移出当前树并检查集成结果。

类型 refactor / verification。依赖 GOV-007、GOV-008、GOV-010。输入为固定基线、CLEAN-D01 与上述交付。范围为历史目录、过期记录及受影响链接，排除产品源码和 Linux 任务状态改动。交付精简树与可定位的历史引用。

- AC-GOV-009：当前树无旧迁移卷或旧审查堆积，受保护产品 Git 树和清单等同基线，保留的当前本地链接通过检查。固定 Git 可查受影响历史输入。从保留祖先的独立克隆验证开发手顺与活动入口。
- 归属：源码和规范保留原入口，历史原件由基线定位。旧归档目录从当前树退役。无兼容分支，无新运行依赖。风险为逻辑归档路径误作 Git 文件或遗漏消费者。

L4 S1 按基线 tracked paths 核对旧路径与引用。S2 切换链接与索引并移出历史。S3 验证 Git 树、仓库检查、有效链接和最小新检出路径。
