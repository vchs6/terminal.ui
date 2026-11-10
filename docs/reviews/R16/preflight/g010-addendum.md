# G010 限定 preflight 补充

结论：**ready / design_reviewed**，仅指新增 G010 内部接口可冻结供 TASK-093/094 消费。无 Critical/Important 缺口；不改变原报告对其余设计的结论或各下游任务的依赖门槛，不代表产品实现或验收通过。

固定输入为 `6d30da46b36e687d4fe8ca95cfa553f00997c7cf:openspec/changes/implement-linux-vt-glyph-fallback/design.md`。与原审查 `d504ca6faa2a136179275ec2ed32ab7c7fc496f0` 比较，已机械核实 G001–G009 内容不变，差异仅为追加 G010。本轮只检查这一增量及与其直接相关的当前 `TerminalRenderProfile`、`Frame` 源码；未读取产品作者报告、未改主仓或正式测试、未派代理、未运行套件或重跑此前签名微验证。

| 检查 | 判定与依据 |
|---|---|
| 可见性与依赖 | pass。根 cjtui 包内 class 与 package 可见 static 工厂可供根包 Application、Frame、布局及同包测试共享；无 public 导出、无 text 叶包反导根包，也没有将内部类型放进公共签名。工厂普通标识符与命名参数默认表达式不引入新的语言机制。本轮是合同/源码核验，未声称编译了新生产实现。 |
| 唯一生产构造 | pass。unicode/ascii/mapped 均明确是设备和离线解析的实际构造入口；同包测试调用同一生产入口。无需环境变量、全局注入、公开 bitmap、测试专用回调或额外可变 capabilities。其它内部实现细节留给作者不妨碍固定输入和可观察输出。 |
| bitmap 所有权 | pass。mapped 精确接受 8192 字节，错误长度抛 IllegalArgumentException；成功防御复制并冻结，调用方修改原数组不能影响 policy。结合既有 G005 不可变 policy 要求，不能仅把数组引用保存到 let 后宣称不可变。长度验证必须在复制/使用前完成，属于现已冻结的验证后构造语义。 |
| profile 兼容 | pass。固定源 TerminalRenderProfile 为根包内部 struct，旧参数末尾为 noColorVideo!；在其后追加 glyphPolicy! 并默认 GlyphRenderPolicy.unicode()，保留所有旧参数名/默认值。snapshotProfile(colorMode) 的原调用仍完整满足必需参数；其他旧颜色调用同理。只读 let 保存已冻结 policy 不引入另一份 bitmap 权威，设备解析显式传本会话策略。 |
| width 边界 | pass。0 返回空、负数抛 IllegalArgumentException，为纯函数补齐确定行为；所有实际正 width 来自 Frame 起始 Cell。固定源 Frame 构造校验非负尺寸、乘积溢出与 maxCells；put 仅在整簇 w<=width-cx 时写起始格。因此任何可被编码的起始格均受实际 Frame 预算约束，零高或零宽 Frame 没有这种起始格。无需对不可达的 Int64.Max helper 输入分配占位串。 |
| 不拒绝合法复杂簇 | pass。没有把 width 人为限为 1/2，也没有新增硬编码宽度上界；正宽回退仍按原 Cell.width 保留列数。Frame 文本控制验证、分簇和宽度权威不迁入工厂。预算测试归真实 Frame 配置，不通过 helper 伪造不可达 OOM。 |
| 证据范围 | pass。同包策略测试能验证确定投影/差分；G010 明确其不能替代真实PTY/VT。公共API、设备/离线语义、后续Theme013真实ellipsis及完整041边界均未改变。 |

责任归属：093 使用固定工厂/profile 构造写内部预期及边界用例；094 在真实解析链实现工厂、防御复制和 profile 注入；095 核实它们确为生产使用且无可变 bitmap 逃逸。前述是原任务内的实现/验证义务，非新增任务或批准请求。

证据：`g010-input/design.diff`、固定全文与 G010 提取件、相关源码副本；精确 SHA-256 及本补充报告摘要见 `g010-reviewed-hashes.json`。原 `report.md`、`findings.json`、`reviewed-hashes.json` 保持原貌。
