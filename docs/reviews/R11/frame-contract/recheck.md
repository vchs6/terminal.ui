# Frame composition 定向复核

日期：2026-11-10；源码基线仍为 `31a7017e6bb522e3f4bcabd2f01abe1d81ea2170`。仅复核初报 S1/S2/P1/P2 及其直接修正边界，未重审全项目、未运行功能套件，未修改产品/测试。原始 [report.md](report.md) 保留。

## 当前结论

**Spec readiness：ready。** S1/S2 已落实，未发现修正引入新的阻塞歧义。

**Plan readiness：ready。** P1 最后两处记录已在本报告末尾最终复核中关闭；S1/S2/P2 亦已关闭。无剩余阻塞项。规划及 TASK-067 可以继续；产品实现仍应等待 TASK-067 冻结产物，不把后续前置记为已完成。

## 定向核对

| 原项 | 本次结果 | 依据 |
| --- | --- | --- |
| S1 预算兼容/依据/影响 | closed | design 明确预算仅约束正面积总单元数；保留两个零面积极值构造及空操作；零宽纯文本仍有 height-1 个 LF，超过预算在生成/打开文件前拒绝；height=0 为空。1Mi 容量取舍有依据且没有假设已测内存/FPS，render/Application 默认限制与低层 Frame 覆盖范围已公开。 |
| S2 文件边界 | closed | create、已有文件截断（含空快照）、不建父目录、打开/写入/关闭错误传播、允许部分残留、无原子替换/保留旧内容/持久化承诺均已明确。参数与预算异常先于文件 I/O。 |
| P1 准入记录 | closed（最终复核） | Shared admission card、preflight、DQ-01…14 逐项结果及技能 receipt/可用性证据现已齐备，详见末尾最终定向复核。 |
| P2 AC/状态映射 | closed | docs/acceptance 新增 AC-067–070 且均 pending；docs/tasks 将 005/007 与 067–070 权威指向具体 change；TASK-010/AC-010 仍 pending，实际应用层快照留待后续。 |

## 修正直接边界

- 零面积构造兼容现在与旧 decoration:84–88 一致；不需要删除或放宽旧断言。
- 零宽巨高纯文本拒绝与有限高度旧 LF 规则不冲突。toAnsi 与几何操作仍可对巨虚拟轴安全短路。
- copy/resized 必须先验证请求的新尺寸并构造指定尺寸的新帧，再跳过没有可复制面积的遍历；“零面积短路”不应被实现为返回原对象或错误尺寸。表中独立副本/指定尺寸契约已足以排除该错误，无需新增 API。
- 不同 ambiguousWide 即便空层也先拒绝，源同目标时读取快照、不同实例源不变，两处初稿字面歧义均已消除。
- 本次 ready 是具体帧契约就绪，不是 AC-005/007 或整阶段已通过。

## P1 首次复核时的剩余动作（已由末尾最终复核关闭）

1. 在具体 change 或可定位 review 记录补 DQ-01…14 各项 pass/fail/not_applicable 及理由；共享卡/本次复核可作为理由来源，无须复制任务模板。
2. skills/evidence 给出实际必需技能的来源/版本定位与可复用可用性证据。已读取的会话工具证据也可用明确会话/工具引用定位；不要求重复调用技能。

首次复核将上述差额反馈主代理；后续实际补写已由末尾最终复核核实。

## 受检内容

| 文件 | SHA256 |
| --- | --- |
| openspec/changes/implement-frame-composition/design.md | `736d309ba31b96876a6e9788268c182d6fc0ecc040b9e21eb2fea73f0bab09de` |
| openspec/changes/implement-frame-composition/tasks.md | `b9df8176e305db80ca34321e8e9bd58f4e0a56dc2293529dad7099b15eee74c0` |
| docs/tasks.md | `e02f98f0c1f0f14d430aa5c2e537258a10e15cabfdb3aad7c3e95e9021070682` |
| docs/acceptance.md | `564b17f2f6858ecfebabdbc4fa81aa27fd418b02561043eb366c669bceab5617` |
| openspec/linux-completion-progress.md | `96c4f680702a0ae45bdf3b472358e18f4b7066563b39277b3840df17b70c2424` |

## P1 最终定向复核：closed

本次直接读取主仓绝对路径，核对本项新落地记录，不重新检查其他规范或功能：

- `openspec/changes/implement-frame-composition/tasks.md` 新增 DQ-01–14 逐项结果及理由，明确 pass 范围为规划及 067 准入；005/007 仍等 067 冻结，后续角色按固定产物准入，没有越过未满足的执行依赖。
- `docs/reviews/R11/skills.json` 给出 local Superpowers 7.0.0 / commit、各技能路径/可读性/SHA256，以及本次 cloud 实际读取的包名；明确 cloud 未暴露独立版本，不冒称与 local commit 同源等价。
- 实际读取并计算 receipt 所列八个本地技能文件的 SHA256，全部与记录相符；正常基线构建证据文件存在。此检查只验证文档可定位性/可读性，不重跑构建或功能。
- `openspec/changes/implement-frame-composition/progress.md` 确有 F001/F002、独立角色 prepare 和技能/任务交接记录。本轮该具体 change 日志为最终核对入口；首次复核仅查总日志而未定位具体日志的不足已纠正。

**最终双 verdict：spec READY；plan READY。** 初报四项全部关闭，无剩余阻塞或需要用户回答的事项。该结论只代表契约/规划可执行，AC-005/007/010 与新增执行/验收 AC 的实际功能结果仍按其独立流程取得。

| 最终新增/更新受检文件 | SHA256 |
| --- | --- |
| openspec/changes/implement-frame-composition/tasks.md | `64fb3157f816a3cace73f029486791221d4b4021e2e1c6e03081ee25f2a9f804` |
| docs/reviews/R11/skills.json | `70d422d6b1e1449dfe730b0ac2b6b9db72666a91a6d1b7b96dee83ae531619a1` |
| openspec/changes/implement-frame-composition/progress.md | `ccac38e9cc1437712db1660391bc1c299bb88af2c793f5903f627670a5dfc99d` |
