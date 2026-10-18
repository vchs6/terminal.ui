# R4 — 开发治理修订复核

## 范围与决策

仅 GOV-001：根据前轮治理/任务分解 Battle，修订 AGENTS 第 10 节、Battle 第 3 节、工程任务分解规范及近期任务字段，补齐 OpenSpec 流程投影并修正静态任务数量检查。用户明确授权修改及直接提交。产品 TASK-001–024 保持 planned；不开展产品实现。

本轮由同一代理分轮修改和复核，不声称独立评审。历史 R0/R3 弱定位证据不伪造改写；后续用其作完成依据须重新核验。

## 判定依据

- 计划阶段可显式缺少变更引用；ready 要求具体映射和技能可用，实际调用证据随执行生成，避免循环准入。
- DQ-05 必检；not_checked 不得通过准入。任务状态与 insufficient_evidence 验收结果分开。
- 审查版本使用完整 commit 或基础 commit 加补丁/快照摘要；证据索引最小字段足以定位，不新增运行平台。
- 现有 AGENTS 10.5 已有反熵编码规范，只补充类型、接口、所有权及注释要求，不另建规范；参考 GanyuanRan/Aegis 官方 README，访问日期 2026-10-18。
- 外部技能仅开发用途，限制上下文、权限与凭据暴露；不加入模型训练、上线运营、SAR 或技能静态白名单要求。
- CI 不固定任务数量或未勾选数量，仅验证编号唯一及验收引用；该静态检查不是完整 DQ/schema 验证。

## Skill 与流程证据

已读取项目安装的 OpenSpec propose/apply/sync/archive 工作法及 Superpowers using-superpowers、verification-before-completion；OpenSpec 1.14.3，Superpowers 来源与锁定提交见 docs/development/tools.lock.json。实际使用：OpenSpec list 确认根目录，new change/status/instructions apply 管理 GOV-001；根据 completion 验证工作法先检查结果再声明完成。此前用户已完成 Battle 并明确要求修改，无需重复需求访谈。

## 验证

结果与受检内容摘要见 evidence.json；命令和日志一同存档。静态及变体检查仅证明开发资料一致性，不证明产品功能实现。新文档审查未发现违反本轮必需验收的未关闭问题；结论 design_reviewed，产品验收仍为 pending。
