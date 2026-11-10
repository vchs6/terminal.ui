# 3138 colors resize 测试设施独立审核

测试合同符合性 **CHANGES_REQUIRED**；代码质量 **CHANGES_REQUIRED**。Critical 0 / Important 1 / Minor 0。发现 CRF001：最后一次正确目标已通过后，退出期间的部分行/不完整ESC/完整同宽错误样式仍可被当作成功。此结论只针对测试设施，不撤销199产品TASK165的原范围PASS。

固定输入 `3138d1a549c5941793b24183bd71cad74d2c688c`，父提交 `91c22f82adcd2412d9509b9872ff63450ba81af9`。完整7文件260+/16-差异见 `raw/full-test.diff`，全部位于tests/colors。没有修改产品/正式tests/main，没有子代理或与作者联系。读取正式R019、固定实现/负控、独立测试角色事实原件；未重跑旧全suite。继续使用已读取的独立review与verification技能，并按systematic-debugging将具体边界疑点定位后作最小oracle探针。

## 已确认正确的修改

- `Session.resize:150-158` 使用现有 `atomicResize`；原helper的C实现只有一次TIOCSWINSZ同时设width/height，再独立GET/readback。启动stty仍在app前，不制造受检应用的中间态。正式尺寸跳变100→31→8→100宽度不同，first-row width可唯一选old/target完整pair。
- `Screen.beginResize/flush:41-77` 不再提前丢弃旧尺寸；限定两pair，按序完整行计数，不能用100×12冒充原100×40或目标31×12；第三width、过高、unfinished frame及回旧作为最终结果受到现负控约束。没有任意width白名单或静默忽略错误。
- `targetComplete:47-50` 在resize完成时要求完整target frame、无当前部分row/escape、实际尺寸相符；现有100ms仅观察完成后的settle，未增加sleep来跳过输出。有限测试场景中old在途后完整target被允许，符合R019。
- `expectedResize:219-243` 与 `example:265-268` 对31×12、8×4逐文本/fg/bg/六属性手写golden严格比较；回100×40严格比较原完整styled grid。原14个握手确认精确byte动作、RGB循环、六属性切换、exit0、termios相等没有弱化。`close`取代`exit`改善了stdio尾部异常覆盖。
- 原old failure/trace/gated inflight原件有hash；deterministic control实际提取固定91的历史Screen，不重造旧oracle。old100×12是两次SET实际经过的pair，而新单SET场景中应被拒，分类正确。

## Important CRF001：终结校验没有覆盖最终流状态

位置：`tests/colors/pty.mjs:164-169`，关联`:150-162`与`:265-270`。`stop()`等待close后仅检查已经抛出的`this.error`、exit和termios。最后精确目标比较在更早的`resize()`返回/`example()`断言时完成。此后晚到数据仍由feed消费，但部分row/ESC不会立即throw，完整同宽SGR变化也不会throw；stop没有调用snapshot/finalization，也不再比较最后目标。

独立最小复现：`node late-output-probe.mjs`。原固定文件保存在`raw/fixed-pty.mjs`；探针只把helper import定位为绝对路径并导出原Session，Screen和Session.stop方法体不变。在有效31×12已finish后，用合成stdin/close回调分别送入：

1. `CUP1;1`后30个字符加SGR0（短于应有31列）；
2. 只送`ESC[`；
3. `CUP1;1 + SGR31 + 31个原字符 + SGR0`，改变最后目标第一行颜色。

三例均返回 `stopAccepted=true, finalGridValid=false, parserError=null`，见`raw/late-output-probe.json`及exit0（表示反例断言成立，绝不是产品PASS）。这只执行测试oracle控制流，不模拟产品实现、物理终端或真实退出恢复。

现`resize_oracle_test.mjs` late-old-width例会立即触发行宽异常，覆盖不到以上三类。最后wrongStyle例仅直接比较两个手构对象，虽证明deepEqual可区分颜色，却没有经过接收晚到bytes→close→stop的路径。因此现套件全部GREEN不排除此假通过。

需要原测试角色在stdio真正关闭后完成parser尾部/行完整性校验，并使最终画面仍满足最后已验target，或以明确允许的退出输出契约严格限制该边界；追加沿同一终结路径的late-partial/late-style负控。无需改变产品、扩大允许pair或放松原恢复断言。本审核没有代作者修正。

## 证据复用范围

已读取最终 `raw/final-colors-after-close-check` 命令、exit0/stdout，以及 `final-controls-after-close-check` exit0的负控记录。前者仍准确证明当次old91实际fixture14和example、尺寸/样式、恢复场景通过；后者准确证明所列既有负控通过。`resize-coherence`原命令exit0真实gated old/inflight原件、独立SET trace支持根因。它们不证明CRF001覆盖完整，也不证明199 GUI修复。

`node audit.mjs`核固定git内容与source-hashes记录、全部raw/evidence.sha256及parent/七文件边界；结果与清单见`raw/audit.json`、`hashes.json`。未因review身份重复正常构建/PTY全套。

## 199既有回归语义复用补充

另核`/workspace/work/glyph-advance-reuse-proof`：重建pre-lint `terminal_projected_row.cj` 的SHA恰等于原manifest `6f98c3ff7d1afdd7fe95abbafebff25aba36c118737caf9321b911b7f7ebd9ae`，final恰为199记录`93ca78942310ee6dd8dbd40de50f165cd475f90013b1f6a262ac71620d850116`。实际diff只有将`encodeTerminalRow`里两处`Style()`改为一个局部`let defaultStyle`并复用。

读取`src/style/style.cj`确认Style是不可变struct，构造仅赋Color/Bool默认值，等号逐字段，无IO、全局副作用或可变共享引用。因此该局部默认值hoist语义等价，可按AGENTS11.1将相同deps/env/config/scope的04-colors、09-capabilities等既有结果复用至199；这补足上次165没有前后原件时保留的证据范围，不要求重复有效套件。它不覆盖需重测的真实GUI或本次修正后颜色resize路径。

未裁定：任意Unicode物理宽度、真实GUI199、完整Linux/VT、同width不同height的新泛化resize API；本修正是既定三组不同宽度颜色fixture，不将窄oracle包装成通用终端模型。新源166/167验收仍独立。
