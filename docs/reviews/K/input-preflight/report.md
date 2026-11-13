# Input/editing independent preflight

受检版本：6a063ed3a07288587288c2afcdabf96a1d4e63a3。主仓仅只读，快照由git archive建立；未读作者progress/自评、未改主仓或正式测试、未派子代理。范围：K001–004/E001–005/F001，对照交互I001–013与Session S001–012。预算：一次设计审查，最多60分钟/3轮定点复核。

结论：**4项Important（Battle severity=major）待root工程裁决；当前不能给无保留design_reviewed，TASK-113–122保持planned。** 未发现要求改用户目标或重新向用户菜单提问的事项。每项责任段、反例和修复要求见findings.json。

## 核验结果

- F001优先于历史候选措辞；两单元113–117、118–122独立。有限writer 152→114，完整030 paste/cut等117/122汇合，没有循环前置。119还等117/118、Theme088/092、RichText084、Runtime080及交互固定验收。实际源/验收依赖未提供，设计与shape通过不能替代ready。
- KeyboardDecoder有真实高级适配/离线重放用途，共同唯一状态机，device桥接必须按字节流先dispatch旧key再锁paste；KeyEvent旧code/text/interrupt/backtab保留，三modifier和支持矩阵明确至C1缺口。
- paste开始锁完整弱目标+域，单纯焦点变化不改投，hidden/disabled/unmount/modal阻挡整次丢弃；1MiB原始bytes完整原子、超限释放且drain，无隐含timeout；EOF/外部signal与preventable CtrlC区分；4096bytes/turn和100ms空闲规则明确。2004清理消费149唯一writer/持久unsafe闩，无越界输出豁免。
- 编辑只用Canvas/focus/defaultAction/viewport/application服务，根为focusable Canvas；没有专用kind/第二offset/Unicode表；I012统一行为外观态，I013 Off及I011只读应用引用已同步。
- Observable后台许可保留，内部原子value+version读取及条件写在唯一锁/版本权威；锁外计算与回调，来源token与UInt64编辑revision不同于Int64 source版本。自视图caret/history、弱controller与mount/source/selection token防ABA方向正确。
- SessionResult同步最终形状与S011 NoIssue/S012防别名兼容，无历史异步ClipboardRequest；当前无Applied实际生产者，保守cut不删Sent，纯策略证据不得冒充宿主确认。回调/失败优先等仍见Important。

## SDK微验证（只证明语法与公开形状）

SDK env=/workspace/work/validation/sdk/cangjie/envsetup.sh；cjc/cjpm 1.2.0，x86_64-unknown-linux-gnu；自有CJPM_HOME=/workspace/work/input-preflight/cache。fixture无外部依赖，所以未启动或占用relay18973。独立library/consumer正常CJPM path依赖，根import cjtui.*，所有K/E签名各实体单文件，方法/构造体throw-only，不运行publicShape，main空返回。

命令：source SDK env，export CJPM_HOME，cd shape/consumer，cjpm build。positive exit=0（raw/shape-build.log）；默认命名参数、KeyEvent旧构造、readonly数组getter、Equatable、UInt64、TextInput/TextArea回调、两个Application overload追加keyboardLimits、NodeRef.application/copyLocalText、Option None与Off/NoIssue并存均获编译检查。已读取完整raw：仅fixture未使用参数/函数警告。

negative增加外部构造KeyboardDiagnostic/KeyboardBatch/TextEditSnapshot，exit=1且恰三条no matching constructor（raw/shape-negative.log），证明内部构造不会泄漏。初次fixture把相邻成员压在同一行导致语法错误，改为换行后成功；这是探针自身格式错误，保存raw/shape-build-fixture-format-failure.log，不作为产品RED。positive内容已恢复且与保存文件字节相同。

范围限制：用于支撑签名的Component/Observable/Theme/Session及Application是throw-only声明shape；Theme默认值用占位Theme()，不证明Theme.preset或现有产品集成。SessionCapability仅占位类型，SessionResult字段按本次消费形状；未重测Session全合同。没有执行decoder/编辑功能，没有实际CAS/PTY/宿主/深层数组运行证据，不记产品GREEN、正式RED、验收或实现通过。按AGENTS11.1未重跑任何旧suite。

## 流程与下一步

已有OpenSpec变更是唯一任务入口；本目录仅审查证据。using-superpowers声明subagent无需该工作流；本轮读并应用verification-before-completion，按AGENTS11.1复用同内容证据，未调用实现类技能。未重做已有OpenSpec schema或安装过程，本轮检查文件引用/编号/合同关系。DQ逐项在dq.json，准入不通过不等于产品功能失败。

root补冻四项后，提供固定SHA/补丁hash，仅定点复核受影响合同与golden可判定性；shape签名若不变直接复用，不再编译或扩大探针。
