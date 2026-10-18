## 1. GOV-001 治理与任务分解修订（L3）

分类 execution；用户本轮授权修改。输入为 AGENTS、Battle 协议、工程任务分解规范及前轮 Battle 结论；范围限开发治理及对应静态检查，排除产品实现。openspec_change_ref 为 refine-development-governance；required_skills 为 using-superpowers、verification-before-completion 与 OpenSpec propose/apply/sync/archive。技能及验证记录见 docs/reviews/R4/result.md；本变更 tasks.md 为 GOV-001 状态权威，不改变 TASK-001–024 状态。

验收：阶段准入不要求未来证据；审查版本可恢复；既有编码规范无重复权威；静态检查允许合法进度变化并拒绝坏映射；npm run check 与 diff 检查通过。

- [x] 1.1 逐项核对 Battle 结论并修订三份权威规范及近期卡片。
- [x] 1.2 同步流程规格，修正固定未完成任务数检查。
- [x] 1.3 检查合法/非法映射变体、文档引用与 OpenSpec，记录证据及复核局限。

DQ 复核：DQ-01–05、07–12、14 pass；范围单一、输入与交付可定位，验收覆盖阶段语义/版本/映射。DQ-06 pass：前轮 Battle 已完成，本轮明确授权，无外部依赖。DQ-13 pass：具体变更与必需技能已验证，实际使用及复核记录见 R4。L4 对应以上三个步骤。质量归属为三份现有权威规范与已有静态检查，无旧产品路径替换、兼容例外或新增依赖；风险为人工规则仍需人工核对。完成依据见 R4 evidence.json，复核不是独立评审。
