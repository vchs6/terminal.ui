# cjtui 项目文档

本目录提供完整产品说明与开发设计，不要求从任务清单反推产品。当前只进行仓库和文档建设，产品实现 planned、验收 pending；文档完整性不代表功能已实现。

## 建议阅读顺序

| 文档 | 回答的问题 | 内容边界 |
|---|---|---|
| [整体提案](development/proposal.md) | 为什么建设、面向谁、交付什么、怎样判断成功？ | 价值、场景、范围、阶段、风险 |
| [需求说明书](requirements.md) | 产品必须做什么、有哪些限制、如何验收？ | 功能/非功能、异常、平台未知与追踪 |
| [总体架构设计](architecture.md) | 怎样分工、数据怎样流动、如何保持一致并恢复？ | 模块、数据与所有权、运行流程、技术取舍 |
| [用户构造设计](ui-construction.md) | 应用如何构造、绑定、交互和复用？ | U1–U5、语法支持目标、公开构造与冻结门槛 |
| [工程任务](tasks.md) | 具体执行什么、依赖和准入是什么？ | L1–L4、近期任务卡和远期候选；未启动 |
| [验收矩阵](acceptance.md) | 哪条要求用什么证据判定？ | AC 编号、责任与唯一实际结果 |

## 辅助资料与权威关系

- [OpenSpec 需求场景](../openspec/specs/)：需求说明的流程场景投影，全部待实现，不作为已归档交付。
- [开发环境与 CI](development/environment.md)：工具安装、技能入口、检查与制品边界。
- [外部依赖证据](development/dependencies.md)：固定中心仓版本、来源及尚需实测的能力。
- [产品说明](product/README.md)：随制品提供的真实产品状态；开发设计不打入产品。
- [Agent 规范](../AGENTS.md)、[Battle 协议](../BATTLE_PROTOCOL.md)、[任务分解规范](../ENGINEERING_TASK_DECOMPOSITION.md)：执行治理，不能代替产品需求与架构。
- [完整性审查](reviews/R3/result.md)：本次文档补齐的范围、问题处置和验证证据。

需求全文由 requirements.md 组织，场景投影不独立新增要求；架构描述参考实现，不能擅自改变需求。任务状态、验收结果各有唯一位置，本文只导航。精确语法/API、平台矩阵和依赖运行证据仍须按已定义调查任务获取；用户已进一步明确Linux ANSI优先实施并解决平台/依赖风险；具体L3仍须满足契约和DQ准入，发布未授权。

本轮规格修订入口：[变更提案](../openspec/changes/refine-terminal-ui-contracts/proposal.md)、[设计](../openspec/changes/refine-terminal-ui-contracts/design.md)、[主题配置](theme-config.md)、[会话能力](terminal-session.md)、[框架调研](development/framework-research.md)、[独立审核](reviews/R5/result.md)。

跨平台与HarmonyOS补充：见需求REQ-011、[R6官方证据](reviews/R6/platform-evidence.md)及[独立审核结果](reviews/R6/result.md)。

Linux优先及依赖风险处理：[R7输入与决策](reviews/R7/input.md)。非Linux平台保留后续目标，不作为当前Linux实施前置。
