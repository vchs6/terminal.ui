# Input design scoped preflight resume

原初审固定 `6a063ed3a07288587288c2afcdabf96a1d4e63a3` 的 **FAIL 保留**；原报告、四项 findings、DQ 和 hashes 均未改动。本轮先审 `024885780340980a67b0faabb64d376a20138bfb` 的 F002–F005 与 tasks 补冻，再仅审 `88ed5f7866fae04c0459ab7310f927b02fb59c29` 的 F005 末句修订。

最终结论：**PF001–004 均 verified，design_reviewed=true（仅本设计限定复核）；execution_ready=false，TASK-113–122 不因此进入 ready。** 本轮没有实施、正式 RED/GREEN、独立产品验收或父 AC 完成结论。

## 四项修订闭合

| Finding | 固定合同与原反例核对 | 结论 |
|---|---|---|
| PF001 | F002:269–280。9B 41 与 C2 9B 41 都为 up；C2 9D 78 07 在首引导报 UnsupportedSequence，payload 丢弃至 BEL；ESC ] x C2 9C 由标量边界 ST 结束；普通有效标量中的 9C continuation 不作 ST。raw/UTF8 C1 的实际 byte 预算/offset、string/paste 隔离、仅精确七位 paste 标记及非paste raw03取消已明确。 | verified at 0248857 |
| PF002 | F003:284–292。已发生 diagnostic 回调及焦点安全提交先于后续 paste 开始捕获；EOF 在 active UI 域先 finish diagnostics，再 stop/cleanup，未运行 post 可取消。编辑先 source 条件写、再本地状态、再 onChange；回调可读已提交 snapshot，写 source 为后续外部同步，同editor变更重入拒绝。非法显式 dispatch 在副作用前拒绝，外层参数错误保留健康 session，未捕获 callback 异常沿原清理。与 Runtime R007/R011/R018 一致。 | verified at 0248857 |
| PF003 | F004:296–309。无选区 copy/cut 为 None 且零输出/issue。copy Applied/Sent 无issue，其余一次 ClipboardUnavailable；cut Applied身份/条件写失败只 CutStale，Sent 只 CutUnconfirmed，其余只 ClipboardUnavailable，不与 ConcurrentValueChanged 叠加。fatal 首设备错保留，与 S008 同步返回 Failed 后最外边界关闭一致。CtrlV/ShiftInsert 一次 PasteFromTerminalRequired；guard false 不自行报issue/修改本地，外部失效后续正常投影。 | verified at 0248857 |
| PF004 | F005:313–315 已补首次/重挂载两 revision、selection、history 初态0；同文本替换非空选区折叠、实际选择变化推进 selectionRevision、false/no onChange/no history/redo保留。容量末句经下述定点修订后与外部写许可及不回滚一致。 | verified at 88ed5f7 |

## 本轮中间 FAIL 与最后定点复核

0248857 的 F005:317 原写“任何操作需要推进但已Max时，在该操作业务写入/局部状态发布之前报…”。该版本 PF004 保持 confirmed：当后台或允许的业务回调已经完成合法 Observable.set/notify，UI 下一安全边界才同步，无法再于该业务写之前拒绝。E001:175/183、F003:290 和 Runtime R011 均保留后台许可及已写业务不回滚；测试作者不能自行补出撤销外部值或预阻止通用 Observable 的政策。这是合同边界推导，没有声称运行了 2^64 次操作。

88ed5f7 对输入 design 仅改 F005 末句，tasks 未变。现在明确：编辑器自己的文本/选择操作先检查实际需推进的局部计数，再 CAS/发布；外部写已完成后，同步耗尽在新本地状态/来源 token 发布前报 CapacityExceeded 并沿 Runtime 终止清理。业务源已写值保留、不回滚、不以旧快照伪造新 token、不撤通用后台许可。该修订闭合原剩余缺口；其他三项结论复用未改合同，不重做初审。

## DQ、依赖及证据边界

原 dq.json 原貌保留。本轮仅解除 PF001–004 引起的 DQ-05 可判定性与 DQ-10 合同未知阻塞；相关工程决策在最终文本中已明确，不把 DQ-13 所有未来角色技能/工具准备一并记为已满足。其余初审维度未重审，沿原证据与适用范围。

DQ-06 执行依赖仍未据本轮获得实际就绪证据：080、084、088、092、交互102/107/112与会话152，以及各阶段正式测试/产品/审核/执行/验收前置均按固定产物逐项准入。152仅有限 writer/unsafe 门，完整父030仍待117/122等汇合；设计闭合不能提前关闭父AC。`ready` 若用于展示只能明确标注设计层状态，不能投影为 L3 execution ready。

原 SDK shape positive exit=0、negative exit=1（恰三项外部构造拒绝）复用；完整原 artifact manifest 逐项 SHA-256 校验，结果见 reviewed-hashes.json。签名/构造/可见性未变，新增 PasteFromTerminalRequired 仅既有 enum 新 case，本轮未重编译、更未实现产品。原 throw-only fixture 只证明声明形状，不证明解码、编辑、CAS、PTY或真实宿主。

使用 verification-before-completion（cloud `c5/verification-before-completion`）：逐项检查原反例、固定 git diff、原 artifact 哈希和最终 JSON 结构。using-superpowers 的 SUBAGENT-STOP 适用独立派发角色。依 AGENTS §11.1–11.2 采用纯文档一致性核验，未运行无关测试。OpenSpec现有变更仍为任务权威；本目录仅独立复核证据。指定独立审核 Astra/high；工具无法核验 serving model 时不冒认实测模型。

未读取产品作者自评/progress，未改主仓、产品或正式测试，未派代理。一次工作树与固定版本一致性检查遇并发 root 修订而拒绝生成，随后直接从两个固定 git 对象提取摘要；没有把并发工作树冒充受审版本。最终仅三个请求工件写入本目录。
