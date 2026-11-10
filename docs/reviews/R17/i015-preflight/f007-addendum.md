# F007 限定设计复核补充

**design_reviewed；execution_ready=false。无 Critical/Important（Battle blocker/major）冲突。** 固定提交 `9b3776d475cd8888dc13d45ec6a978aba9cf33ef`，仅审 `implement-linux-input-editing/design.md` 新增 F007（323–325行）及其 K002/F002/F003/F006、interaction I015 cancel 接口。未实现不是本次缺陷判断依据。

root说明：本次由独立113测试作者询问后，root工程裁决明确取消本身不额外发IncompleteInput/Malformed。固定提交中该文件仅新增F007四行；相邻其他变更未审。原I015报告、findings、hash与C源码完全保留，本次没有重新审查I015整体或跑ABI/产品测试，没有修改主仓或派子代理。

| 受检接口 | 判断与合同推演（非运行结果） |
|---|---|
| K002新ESC取消 | PASS。K002:96已规定新ESC取消未完成非string并开始新引导；F007只明确取消不额外诊断。`1b 5b 31 32 1b 5b 41`产生新up，旧片段不成为text，不额外生成IncompleteInput/Malformed。没有把新ESC伪作旧CSI的final或要求回放。 |
| F002标量边界C1 CSI | PASS。`1b 5b 31 9b 41`与`1b 5b 31 c2 9b 41`在真实标量边界重新引导CSI并产生up，取消自身无附加issue。UTF8中普通标量的9B续字节（例如D8 9B）不是C1；F007明确不改变该边界。新C1引导/完整未知序列原诊断规则保留。 |
| raw03非paste取消 | PASS。`1b 5b 31 32 03 78`产生interrupt(ctrl=true)、text x，没有旧未完整CSI的额外issue；沿F003先完成interrupt回调/安全提交再消费x。若interrupt导致stop，则按既有设备停止规则不继续投递；F007示例描述纯decoder结果，不覆盖停止生命周期。 |
| 已报诊断与F003顺序 | PASS。先前MalformedSequence/SequenceTooLong等保留，不能为“取消无新issue”删除、回滚或重排已形成诊断及其callback。原diagnostic仍按F003在后续byte/paste开始前完成UI稳定提交；因此无新焦点/队列权威或通知通路。 |
| 真实timeout/finish | PASS。F007明确与真实100ms idle/finish区分。旧未完整CSI已经timeout产生IncompleteInput后，再来新ESC/C1不能撤销该诊断；裸ESC timeout发escape、普通未完整UTF8 tail保留、超预算drain及finish规则仍按K001/K002，未统一改成静默丢弃。 |
| paste/string/UTF8 | PASS。K003/F002原隔离继续优先；paste及drain内03是数据，string内ESC/C1 CSI不作普通取消或新协议引导。F002已有非paste raw03取消string规则未由F007扩写或撤销。坏UTF8仍按原InvalidUtf8规则，F007只限制取消附加的IncompleteInput/Malformed，不免除UTF8错误。 |
| I015/F006的取消边界 | PASS。I015:478/F006:321要求完整mode25报告来自同一未被timeout/cancel打断的CSI。`ESC[?25;`被新ESC/C1/03取消后，后续`1$y`不能补接旧报告授权。新精确7bit完整报告仍按I015原窗口判定；raw/UTF8 C1即使引导新CSI仍不获mode25管理权。取消无额外issue不意味着未取消，也不改变probe600ms与keyboard100ms分离。 |
| public API、资源、实现归属 | PASS。无类型/签名/构造或队列新增，唯一decoder状态转移承接；原maxSequenceBytes、drain、流位置与预算不变。 |

受影响DQ：DQ-04范围明确、DQ-05取消/timeout/已报诊断的可观察结果明确、DQ-08唯一状态机且无冲突、DQ-09 F003及I015组合闭合、DQ-10仅消除诊断歧义而不假定产品已交付、DQ-12固定SHA/patch/哈希可追踪、DQ-13 root裁决与独立限定复核相分离，均为 **pass（本次规划范围）**。其他DQ未重审，沿用原范围判定。下游实际测试与产品准入条件没有因本澄清解除。

证据：`f007-reviewed-hashes.json`固定两个正式合同全文与补丁哈希；`raw/f007/f007.patch`确认本文件仅新增F007。`f007-findings.json=[]`。`f007-SHA256SUMS`只索引本次补充产物，不覆盖原I015的`SHA256SUMS`。采用此前已读取的Battle/DQ及verification-before-completion流程；本次仅做固定文本/差异/哈希核验，不从静态合同推演声称产品执行通过。
