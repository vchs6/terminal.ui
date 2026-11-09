# R7 工具、技能与角色证据

## 来源与可用性

复用[R5工具与技能记录](../R5/input.md)、[R5检查](../R5/validation-final.txt)及[版本锁定](../../development/tools.lock.json)，本轮没有改变package-lock、安装脚本或锁定版本，不重复安装。OpenSpec本地CLI本轮读取版本为1.14.3；运行list/status，确认根为本仓库、活动变更为refine-terminal-ui-contracts。对应本地技能位于`.agents/skills/openspec-update-change/SKILL.md`、`openspec-sync-specs/SKILL.md`，均已实际读取；版本1.0，generatedBy1.14.3。

本地Superpowers复用7.0.0，仓库来源`https://github.com/obra/superpowers.git`，revision `bb92a77741419a4ab5f06e711a283343f1ada0c3`；本轮执行git rev-parse核对相同revision，`.agents/skills/superpowers`链接指向该安装的skills目录，实际读取verification-before-completion正文，确认可发现及可读。锁定源码不随产品制品分发。

本轮主代理同时通过宿主`skills.read`实际读取并应用云Superpowers技能。云包来源`c5`对应宿主已安装的`plugins~Plugin_60aea7460bd4819199fd97a9553a5e12`；工具返回SKILL.md内容证明可用。该服务未提供semver或Git revision，不声称云内容与本地7.0.0逐字节相同。固定本地版本和云资源来源分别记录，避免混淆。

## 本轮实际使用映射

| 技能 | 实际用途与产物 |
|---|---|
| OpenSpec update-change | 读取list/status返回的工件路径，修订现有proposal/design/tasks/specs；用户已指定Linux优先修订和自主执行，不逐文件重复索权 |
| OpenSpec sync-specs | 读取本地技能，核对terminal-session和distribution增量及主规格；现有R5一致性检查逐Requirement匹配；没有把规格同步当产品完成 |
| using-superpowers | 开始工作时读云技能，选择风险排查、独立角色及验证流程 |
| systematic-debugging | 查官方unicode包和正常build失败，区分原生缺失、链接传递与skip-script；测试执行发现旧exe后定位增量复用，不删失败断言 |
| dispatching-parallel-agents | 原生构建与许可来源两个独立领域分别交Sol/high隔离调查；只共享固定合同和交付文件，未互写 |
| requesting-code-review | 固定9a5c7034d245a053ff4614c3b7f594689a5b1389交Astra/high独立审核，审核者单独clone及书写发现 |
| receiving-code-review | 收到IR-001/002/003后实际读取云技能，核对现行条款再修正授权、拆分044/046/047、补本文件；不盲接或隐藏发现 |
| verification-before-completion | 主代理读取云与本地技能；作者自测不作为最终验收，独立执行者从固定commit新clone/目录复验并记录脚本失败，修复后仅补受影响路径；最终验收另派角色 |

主代理本轮仅修改文档/工件，未编写产品代码或测试；未触发产品实现的TDD、worktree或implementation-plan执行技能。原生探针作者收到独立失败后另读取systematic-debugging/TDD，保留原失败断言后修复复现脚本；这是隔离调查修复，不是产品实现。本轮没有新增用户价值/交互设计，Linux顺序由用户直接裁决，未重新进行已确认产品方向的brainstorming。

## 独立角色

原生调查与许可调查均Sol/high，各自隔离目录。独立测试执行Sol/medium，只读取固定脚本和契约，在新clone/构建目录运行，未读取作者日志作为结果；独立审核Astra/high，不参与作者或测试执行；最终验收使用另一独立代理，从固定版本、测试原始结果和需求核对边界。模型与上下文选择遵用户新增角色隔离要求，后续产品任务严格按AGENTS13.2分离测试设计、实现、审核、执行与验收。
