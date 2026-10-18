# Implementation plan & 任务分解（初稿）

> 本文件为 terminal.ui 项目在现有治理规范（AGENTS.md / ENGINEERING_TASK_DECOMPOSITION.md / docs/*）基础上的可执行实施规划与任务分解（L1→L2→L3→L4）。遵循仓库工程任务分解规范：L3 为最小可独立交付单元，L4 为具体可检查步骤。每个 L3 含 acceptance 条目与 evidence_refs 要求。完成后由维护者审核并决定后续编码执行（本次提交仅为实施规划与任务分解）。

---

## 一、总体 L1 目标

- 交付一个基线可运行的 terminal.ui 骨干（支持 U1 最小应用）、AI/Agent 使用治理与 SAR（语义对抗审查）能力雏形、CI 校验与证据归档路径。满足 docs/requirements.md 中的核心必需项并为后续迭代建立可验收链路。

## 二、优先级与交付里程碑（建议）

1. W1 文档与治理模板（必需）
2. W2 项目骨架与 U1 示例（必需）
3. W4 SAR 报告 schema 与差异检测 harness 原型（高优先）
4. W5 CI 校验与 evidence registry（必需）
5. W3 更丰富示例（U2/U3）与差分回归测试（中）
6. W6 性能/基准（中）
7. W7 发布与打包（低）

---

## 三、工作包（L2）与 L3 任务卡（初稿）

说明：每个 L3 任务卡采用任务模板字段（id/level/parent/requirement_refs/classification/title/objective/scope/inputs/depends_on/preconditions/deliverables/acceptance/impact/quality_governance/risks/steps/status/blockers/evidence_refs）。

### W1 — 文档与治理（priority: 必需）

TASK-W1-01
- id: TASK-W1-01
- level: L3
- parent: W1
- title: 任务卡模板与 DQ 校验脚本
- objective: 在 `docs/templates/` 放置 task_card.yaml、DQ checklist.md 并实现本地校验脚本（python/node），用于 CI 校验任务卡与 DQ 准入。
- inputs: ENGINEERING_TASK_DECOMPOSITION.md, 现有 docs/tasks.md
- deliverables: docs/templates/task_card.yaml, docs/templates/dq_checklist.md, scripts/validate_task_card.py
- acceptance:
  - AC-1: 校验脚本能对示例良/劣 task_card 给出通过/失败结果（运行样例附证据）。
  - AC-2: DQ checklist 可作为 ready 准入清单并存档。 
- estimate: 1.5 人日
- steps:
  - S1: 抽取必要字段并编写 YAML 模板（check: fields present）
  - S2: 实现校验脚本并测试示例（check: script exit codes, sample logs）
  - S3: 更新 docs/ 使用说明并记录运行命令（check: README 条目）
- evidence_refs: scripts 输出日志与 CI 运行截图

TASK-W1-02
- id: TASK-W1-02
- level: L3
- parent: W1
- title: AI 代理治理补充（model/data/PII 简要策略）
- objective: 在 `docs/` 新增 `docs/ai-governance.md`，包含 model_card & dataset_card 模板、外部 Skill 使用白名单、密钥与 PII 指南、模型发布/回滚流程建议。
- deliverables: docs/ai-governance.md, docs/templates/model_card.md, docs/templates/dataset_card.md, docs/skills-approved.md
- acceptance:
  - AC-1: model_card/dataset_card 覆盖数据来源、许可、主要性能与偏差评估字段。
  - AC-2: docs/ai-governance.md 明确外部 Skill 使用审批流程并与 AGENTS.md 交叉引用。
- estimate: 2 人日
- steps:
  - S1: 草拟 template 字段并征内部分支评审（check: template file）
  - S2: 写入指南与审批流程（check: doc links）
- evidence_refs: commit id + review notes

### W2 — 架构骨干与核心库（priority: 必需）

TASK-W2-01
- id: TASK-W2-01
- level: L3
- parent: W2
- title: 项目基础 scaffolding（package.json, build, examples/minimal）
- objective: 初始化 JS 项目骨架，使 `examples/minimal` 可通过 `npm run start` 输出一帧（U1 最小示例）。
- deliverables: package.json, src/index.js, examples/minimal/*, README usage
- acceptance:
  - AC-1: 在 CI 环境 `npm ci` + `npm run start:examples/minimal` 可产生示例输出并退出码 0（附 CI 日志）。
- estimate: 4 人日
- steps:
  - S1: scaffold package.json 与基础依赖
  - S2: 实现 `src/index.js` 能读取 example 并输出合成帧
  - S3: 写 minimal example 源码与运行脚本
- evidence_refs: CI run log

TASK-W2-02
- id: TASK-W2-02
- level: L3
- parent: W2
- title: 最小帧合成与差分模块
- objective: 实现目标帧合成（cell model）与差分输出模块，包含基本 Unicode 宽字符处理测试。
- deliverables: src/frame/composer.js, src/diff/diff.js, tests/ (unit)
- acceptance:
  - AC-1: 单元测试覆盖 ASCII、宽字符与简单遮挡场景并全部通过（附 test output）。
- estimate: 5 人日
- steps:
  - S1: 设计单元格数据结构并实现合成
  - S2: 实现简单差分算法并写单元测试
  - S3: 集成 examples/minimal 并验证 diff 输出
- evidence_refs: test run artifacts

### W3 — 示例与用户验收（priority: 必需）

TASK-W3-01
- id: TASK-W3-01
- level: L3
- parent: W3
- title: U1 最小可运行用户示例
- objective: 提供用户可见的最小示例，包含样式与默认主题
- deliverables: examples/minimal + docs/examples.md
- acceptance:
  - AC-1: 示例可运行并在 README 中说明如何验证期望输出（附示例截图/文本）。
- estimate: 2 人日
- steps: S1 构建示例 S2 编写验证脚本 S3 文档说明

TASK-W3-02
- id: TASK-W3-02
- level: L3
- parent: W3
- title: U2 常规示例（菜单/容器/状态条）
- objective: 构造一组更复杂示例以验证布局/交互基本能力
- estimate: 3 人日

### W4 — SAR（语义对抗审查）能力（priority: 高）

TASK-W4-01
- id: TASK-W4-01
- level: L3
- parent: W4
- title: SAR findings schema 与 report 模板
- objective: 在 `docs/templates/` 定义 `findings.schema.json` 与 sar_report 模板，规定必须的可复现字段（input, env_snapshot, observed_up/down, reproducible_steps, evidence_refs, severity, diff_type）。
- deliverables: docs/templates/findings.schema.json, docs/templates/sar_report.md
- acceptance:
  - AC-1: 对给定示例 report 运行 jsonschema 校验通过（附运行记录）。
- estimate: 1 人日
- steps: S1 写 schema S2 生成示例并校验

TASK-W4-02
- id: TASK-W4-02
- level: L3
- parent: W4
- title: SAR 差异检测 harness 原型（非阻断）
- objective: 实现轻量 harness：对给定输入并行调用上游样例与下游实现，收集响应与 traces，输出 findings.json 存入 `docs/reviews/<round-id>/`。
- deliverables: tools/sar/harness.js, examples/sar-samples/, docs/reviews/<round-id>/findings.json
- acceptance:
  - AC-1: harness 在样本集上运行并生成 findings.json（附运行输出证明）。
- estimate: 4 人日
- notes: SAR 报告为迁移报告的一部分，**不阻断迁移**；后续处置由用户决定（并记录为 OpenSpec decision 或 task）。

### W5 — CI 和 证据归档（priority: 必需）

TASK-W5-01
- id: TASK-W5-01
- level: L3
- parent: W5
- title: schema 校验的 GitHub Actions
- objective: 实现 .github/workflows/validate-artifacts.yml，校验 task_card、findings.json、model_card 等 schema
- deliverables: workflow yaml, scripts/validate_* (node/python)
- acceptance:
  - AC-1: 故意违反 schema 的 PR 在 CI 中失败（示例 PR 证明）。
- estimate: 2.5 人日

TASK-W5-02
- id: TASK-W5-02
- level: L3
- parent: W5
- title: evidence publish script & docs/reviews 约定
- objective: 提供 `scripts/publish_evidence.sh` 用于把 findings/artifact 上传到 repo 或外部存储并在 docs/reviews 生成索引文件
- deliverables: scripts/publish_evidence.sh, docs/reviews/README.md
- acceptance:
  - AC-1: 在本地运行脚本能把示例 findings 归档并生成索引文件（附运行日志）。
- estimate: 2 人日

### W6 — 基准与性能（priority: 中）

TASK-W6-01
- id: TASK-W6-01
- level: L3
- parent: W6
- title: 渲染基准 harness
- objective: 实现基本的渲染性能基准并产出 CSV/JSON 指标
- estimate: 3 人日

### W7 — 发布（priority: 低）

TASK-W7-01
- id: TASK-W7-01
- level: L3
- parent: W7
- title: release checklist 与 packaging scripts
- estimate: 2 人日

---

## 四、DQ（分解质量）门槛（ready 准入）

所有 L3 在进入 `ready` 前必须通过以下核查（脚本或人工）：
- DQ-01 层级合法（代码更改仅发生在 L3/L4）
- DQ-02 目标单一
- DQ-03 定义完整（task_card 字段齐全）
- DQ-04 边界与影响明确
- DQ-05 验收可判定（至少一项 AC 有可执行验证入口）
- DQ-06 依赖可执行（depends_on 完整）
- DQ-12 追踪与证据（evidence_refs 占位或指向样例）

运行方法：`scripts/validate_task_card.py` 将把 DQ 检查项作为 warning/error 输出；进入 `ready` 前必须全部 pass（或有明确 blocked 标注）。

---

## 五、风险与缓解

- 文档化成本高 → 缓解：优先交付最小可验证工件（MVP 风格）
- Unicode/终端语义复杂 → 缓解：采用现有成熟 unicode 库，编写边界单元测试
- SAR 噪声 → 缓解：先在小样本、固定环境下运行，人工 triage

---

## 六、估算汇总（粗略）

合计（MVP + 必需治理/CI）：约 32 人日（单人工作量估计），并行开发可缩短日历时间。

---

## 七、下一步（等待你确认）

我已完成本项目的实施规划与任务分解（如上）。请审核 L2/L3 列表与优先级：
- 若确认，我会把上述实施规划与 L3 任务卡以文件形式提交到仓库（PR），并在 PR 中列出每项 L3 的 evidence 路径与运行命令；随后等待你审核并决定编码阶段启动。 
- 若需要调整（新增/优先级变更/合并任务），请指出修改点，我会持续更新直到你确认。

---

*注：本文件为“实施规划与任务分解”的提交稿，不包含实现代码变更。提交 PR 后请在 PR 描述中指明审查重点：任务卡的 AC、依赖与 DQ 检查。*
