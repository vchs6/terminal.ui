# Linux 文本/ANSI 下一增量契约审计草稿

审计时间：2026-11-10 UTC。固定产品基线：`6a7b240bfc89bb054b11306f257ebed519a26b5f`。范围仅只读源调查、API 微探针和建议；未写产品、测试或正式规格，未读取其他角色报告或推理。本目录不属于产品运行依赖。角色由主代理指定 Sol/high；当前工具没有暴露可核实的实际模型/推理档位元数据，因此只记录指定值，不把实际执行型号作为已验证事实。未派下级。

## 1. 可冻结的结论

下一增量宜给现有 `Text`/`Frame` 增加 typed 富文本入口，并在独立入口把 ANSI 字符串转换成同一富文本值。严格纯文本 `Text(String)`、`Frame.put(..., String)` 保留控制字符拒绝行为。ANSI 的唯一输入效果是解释被允许的 SGR 并产生内容/样式；不自动加边框、补配色、添加图标或生成额外装饰。

ANSI 库可重用 `ansies.core.parseCSIParams(raw, terms: "m")` 拆分已完整框定的 7-bit CSI；库不提供满足本需求的增量流、输入安全边界或 SGR → typed Style 解码。仅增加有界序列框定、白名单 SGR 参数映射和控制丢弃薄适配；继续唯一使用既有 ansies 编码，以及 unicode 分段 / unicodewidth 宽度。不引入光标、擦除、屏幕/滚动区、终端模式、设备回复等虚拟终端状态。

TASK 编号需保持准确：TASK-008 是差分提交/写失败恢复；TASK-009 是有界增量 ANSI 输入；富文本是 REQ-001.4 / REQ-005.4 的公共数据前置。TASK-010 的 Frame 快照原语已有实现；当前可见覆盖层的实际快照待 TASK-018 汇合，不因本增量提前声称完成。

## 2. 已确认事实与原始证据

| 现有能力 | 固定源位置 | 影响 |
|---|---|---|
| `validateText` 拒绝 `< U+0020`、U+007F–009F，允许 LF / CRLF | `src/text_validation.cj:3` | ANSI 不能直接放入现有 Text/Frame；不要放宽公共纯文本安全边界 |
| `Text(value: String): Component`，组件保存单个 String；样式显式值用 Optional 字段 | `src/component.cj` | 尚无 typed runs 或 RichText 公共入口 |
| 单一 `Style` 为完整不可变 resolved 值，颜色 + bold/dim/italic/underline/inverse/strikethrough | `src/style/style.cj:3` | 可直接保留为 Cell 样式；它无法表达某个字段“未指定/继承” |
| 组件 measure 按整个 String 分段并保存 String 簇；paint 为所有簇应用同一组件样式 | `src/layout_node.cj:15`、`src/layout.cj:76` | 富文本须改共同 measure/paint 数据，而非另建富文本渲染器 |
| `Frame.put` 先整段 validate，再分段、宽度、裁剪、整簇清除/写入 | `src/frame.cj:49` | typed put 也必须在改变帧前确认所有内容合法，仍用同一完整簇写入原语 |
| `graphemeClusters` 调 unicode，`displayWidth` 只调 unicodewidth；空串适配已有 | `src/text/unicode.cj` | 没有必要新增任何 Unicode 表/分段器/宽度算法 |
| 私有 `InputDecoder` 消费逐字节键盘，保留有限状态，丢弃控制字符串，识别少数键 | `src/input_decoder.cj` | 不是富文本解析器；不要把其键盘事件/timeout/Ctrl-C 模型混入应用文本 |
| `Frame.toPlainText/toAnsi/writePlainText/writeAnsi` 从完整帧导出，ANSI 为 ansies 的 CUP/SGR 编码 | `src/frame.cj`、`src/ansi_encoding.cj` | 富文本转 Cell 后天然进入快照，不应从输入 ANSI 直接写文件或终端 |
| Application 写完整成功后才赋 baseline；writeScreen 出错抛异常并结束会话 | `src/application.cj:74`、`src/terminal_bridge.cj:25` | 不应由文本 parser 获得设备写权限或承担 TASK-008 重同步 |

源 hash 见 `source-sha256.txt`，公共符号索引见 `public-symbols.txt`。hash 中相对路径均以 `/workspace/work/terminal.ui` 为根，外部包使用绝对路径。基线工作树 `baseline-status.txt` 为空。

### 依赖 API 微探针（SDK 1.2.0 实测）

独立 `probe/` 由 `cjpm init --name text_contract_probe --type executable` 生成；只添加 ansies 1.3.113 依赖。seed cache 被完整复制至本目录 `cache/`，未写 seed。本地缓存/已有 lock 构建，不依赖正在运行的 registry；配置中保留原有 registry 标识以让 cjpm 接受 home 配置。

可复现：

```bash
source /workspace/work/validation/sdk/cangjie/envsetup.sh
cd /workspace/work/text-contract-audit/probe
cjpm build
./target/release/bin/main
```

首次依赖构建成功见 `probe-build.log`；加入重载微探针后的最终构建成功见 `overload-build.log`，最终执行输出见 `probe-run.log`；探针本身与日志 hash 见 `probe-sha256.txt`。

| 探针输入（对 parseCSIParams 均使用 terms: "m"） | 实际结果 | 契约含义 |
|---|---|---|
| ESC `[31m` | Some(["31"]) | 可复用参数拆分 |
| ESC `[m` | Some([]) | 适配层要显式把无参数处理为 SGR 0 |
| ESC `[;31;m` | Some(["", "31", ""]) | 空字段不丢失；应按 0 处理 |
| ESC `[31` | Some(["31"]) | 库不校验完整终止符 |
| ESC `[31R` | Some(["31R"]) | 库不会拒绝错误 final |
| ESC `[?31m` | Some(["?31"]) | 库不拒绝 private 参数 |
| ESC `[38:2::1:2:3m` | Some(["38:2::1:2:3"]) | colon 子参数不是已经支持的 SGR 语义 |
| U+009B `31m` | None | 若接纳 C1，需先在边界识别后规范为 7-bit 再调用库 |

`StyledText("A").bold().then("B").toString()` 实际字节为 `ESC[1mAB` 紧接 `ESC[0m`：新段未设属性不会清前段样式。`StyledText` 的 Segment 私有，公开输出为 ANSI 字符串，另有 `printAt` 直接 stdout。它不是框架 typed runs 的数据来源或绘制入口，不能借用后再“解析回来”造成第二权威路径。`TextStyle` 可选颜色与 mutable 位域是库输出聚合模型；不代替 cjtui resolved Style/继承语义。

SDK 1.2.0 已实编以下四个同名重载：`Text(String)`、`Text(RichText)`、`Text(() -> String)`、`Text(() -> RichText)`。已类型的函数值及直接 `{ => "E" }` / `{ => RichText("F") }` 均正确分派，输出为 `plain-binding:E` / `rich-binding:F`。代码见 `probe/src/text_overloads.cj`，RichText 是独立最小 stub；此证据证明语言重载可行，不代表 cjtui 正式富文本/动态绑定或真实宏已经实现。当前 runtime 继续只支持纯 Text，后续增加 RichText 重载无需预先改变 runtime String 绑定公共签名。

仓颉 Skill 固定 HEAD 为 `277f2e1234ca5217496966887243c679653887a8`；已读 `.agents/skills/cangjie-coding/SKILL.md`，按其脚本批量查询 String.fromUtf8、runes、ArrayList.remove 等，原始摘要见 `cangjie-api-search.txt`。String.fromUtf8 的叶子契约见 `cangjie-utf8-contract.txt`：非法 UTF-8 或超过 UInt32 长度抛 IllegalArgumentException。SDK 实际 cjc/cjpm 为 1.2.0，优先于 Skill 默认旧版本。

## 3. 最小 typed 公共契约建议（待主代理冻结，不是已编译产品 API）

必须用类型表达内容、覆盖值与解析结果，不用 magic kind / String style token。建议最小实体如下，每个实体独立小写下划线 `.cj` 文件；包布局由主代理按现有兼容与编译事实冻结。

1. `TextStylePatch`：颜色字段 `?Color`、六种布尔属性 `?Bool`。None 表示未指定；Some(Color.Default) 表示显式终端默认颜色；Some(false) 表示显式关闭属性。现有 resolved `Style` 不变，现有组件 optional 字段应复用相同字段解析函数，不能两套合并语义。
2. `TextSpan(text: String, style!: TextStylePatch = TextStylePatch())`：不可变纯文本及 patch。空文本可规范消除；所有文本仍使用现有 validateText。不要在每个 span 内独立断字形。
3. `RichText(spans: Array<TextSpan>)`：拷贝/封装传入集合，公开只读内容；可提供 `toPlainText(): String` 供测量/导出前内容查看。无 ANSI、无终端命令、无设备 handle。
4. `Text(value: RichText): Component` 及 `Frame.put(x, y, value: RichText, style!: Style = Style())`：走既有 measure/paint/Frame 簇写路径；String 旧入口等价于单个无 patch 的 span。
5. `AnsiTextDecoder`：独立、显式流实例；输入 bytes，输出按顺序的安全 TextSpan 批次与有类型的诊断；不存累计文档、不访问组件、线程、Frame 或 stdout。另有便利 `parseAnsiText(value: String): AnsiTextResult` 一次调用共享该 decoder 并 finish，返回 RichText + diagnostics。不得采用 `Text(String)` 的猜测/自动检测 ANSI。

接口签名建议骨架：

```text
AnsiTextDecoder()
feed(chunk: Array<UInt8>): AnsiTextBatch
finish(): AnsiTextBatch
AnsiTextBatch: spans: Array<TextSpan>, diagnostics: Array<AnsiTextDiagnostic>
AnsiTextDiagnostic: kind: AnsiTextIssue, offset: Int64
AnsiTextIssue: UnsupportedSequence | MalformedSequence | SequenceTooLong | IncompleteSequence
parseAnsiText(value: String): AnsiTextResult
```

具体是否用命名参数/属性由正式代码实编确认。这里推荐 Array<UInt8> 而非 feed(String)，因为 UTF-8 字符可以跨输入块；只收 String 无法覆盖任意字节分块或 raw 8-bit C1。String 便利入口应调用 `toArray()`，禁止 unsafe fromUtf8Unchecked。

### 样式优先级与整簇规则

建议明确每字段优先级：组件显式链属性 > span patch > 组件继承/主题基础值；未赋值 span 从该基础值继承。组件显式 foreground 可统一覆盖整篇，组件 `.bold(false)` 可关闭所有 span bold。低层 Frame.put 的 style 是基础值，span 的显式字段覆盖它。若主代理希望 span 显式高于组件显式，这是实质契约差异，必须在写测试前裁定；不能让实现者自行猜。

ANSI 起始 patch 全为 None，保持未指定字段；SGR 0 明确将全部字段设为 Default/false，而不是变回 None。这样“继承”和“显式 reset”有区别，与 typed span 相同。SGR 状态只存在该 decoder 实例；finish 后关闭实例，后续 feed/finish 报 IllegalStateException 或一致已关闭错误（需最终统一），不同文本间不继承状态。

RichText 的可见字符串应先拼接，再用唯一 graphemeClusters 分段；每个簇采用其首个 scalar 的 patch，簇内后续 style 边界不拆簇。字节偏移用于把原 span patch 映射到簇。`e` + style change + combining acute、跨 span emoji ZWJ/旗帜、跨 span CRLF 均只按完整文本分段。不能分别渲染 spans 后拼 Frame，不能在 parser 自写增量 Unicode 分段。解析批次也只是 runs，不是最终 graphemes：调用者先收集所需文本值，组件测量时统一分段。该设计无需 parser 保留可能任意长的待完成 Unicode 簇。

## 4. ANSI 解析支持矩阵建议

### 支持的唯一执行语义：SGR 样式

7-bit ESC `[` 和 C1 CSI 规范化后，仅 final `m`、无 private/intermediate、参数为十进制数字或分号的完整序列可应用。无参数/空字段为 0。先验证整条再原子应用；失败不应用前半条，也不把剩余参数解释成独立样式。

| 参数 | 映射 |
|---|---|
| 0 | 全字段显式复位为 Default/false |
| 1 / 2 / 3 / 4 / 7 / 9 | bold / dim / italic / underline / inverse / strikethrough true |
| 22 | bold 和 dim 同时 false |
| 23 / 24 / 27 / 29 | 对应属性 false |
| 30–37 / 90–97 | 前景基础/亮色 |
| 40–47 / 100–107 | 背景基础/亮色 |
| 39 / 49 | 前景/背景显式 Color.Default |
| 38;5;n / 48;5;n | Indexed(n)，n 为 0–255 |
| 38;2;r;g;b / 48;2;r;g;b | Rgb，通道均为 0–255 |

颜色保留原始 typed 值，到现有 terminal profile 投影时才降级。不要在 parser 把 RGB 提前换成 16 色。不存在 blink/conceal/double underline/超链接等 cjtui 字段时，将整条含该参数的 SGR 诊断为 UnsupportedSequence 并丢弃；不要 silently success 或增加本轮无需求的字段。colon 子参数（如 38:2::r:g:b）、private prefix、intermediate 先明确 unsupported，整体丢弃；不是 ansies 已替我们提供其语义。

### 控制边界（均不向终端透传）

| 输入类别 | 建议结果 |
|---|---|
| 普通有效 UTF-8 内容 | 原文转 span，不改空格、不美化、不插入装饰 |
| LF / CRLF | 保留现有换行语义；CR 跨 feed 必须留 1 字节待确认 LF |
| 孤立 CR、HT、BS、BEL、其他 C0 / DEL | 丢弃并产生控制/不支持诊断；不作光标退回、tab 展开或蜂鸣 |
| CSI CUP/HVP/CUU/EL/ED/DSR/DECSET 等，即使库可编码 | 整条丢弃并 UnsupportedSequence；不得修改帧光标、区域、模式或产生设备查询 |
| OSC 0/2 标题、52 剪贴板、8 hyperlink、其他 OSC | 整串丢弃；仅 OSC 可由 BEL 或 ST 结束 |
| DCS / SOS / PM / APC，包括六像素和图片协议 | 整串丢弃，只有 ST 结束；BEL 不终止这些串 |
| ESC charset designation、save/restore、RIS 等 | 消费完整 ESC 序列后丢弃，不切换字符集，不重置设备 |
| raw C1 0x90/98/9B/9D/9E/9F/9C | 在 UTF-8 scalar 边界识别为 DCS/SOS/CSI/OSC/PM/APC/ST；从不作为可见字符输出 |
| UTF-8 编码的 U+0090/98/9B/9D/9E/9F/9C | 与上述 C1 同策略，须跨块等价；其余 C1 丢弃诊断 |
| UTF-8 多字节 scalar 内出现 0x80–9F continuation | 属于字符数据，不当 raw C1（例如 U+049B 的 D2 9B 不得误判 CSI） |
| 非法 UTF-8 | 推荐 fail-fast IllegalArgumentException 并关闭 decoder；此前 feed 已交付前缀不回滚，此次不交付半个失败 batch；便捷一次解析整体失败，不产生可用 RichText |
| finish 遇不完整 UTF-8 | 同非法 UTF-8；绝不 unsafe 构造字符串 |
| finish 遇待确认 CR | 丢弃 + UnsupportedSequence（与孤立 CR 一致） |
| finish 遇 ESC / CSI / 控制串未闭合 | 丢弃残留 + IncompleteSequence，不把尾部控制 payload 当正文 |

本矩阵是限制性文本适配，不是“所有 ECMA-48 控制都被执行”。源输入中的终端控制与输出编码支持必须分别列矩阵。

### 畸形、重同步与限制

建议固定公开资源限制 `maxSequenceBytes = 4096`（包含 introducer/final）、`maxSgrParameters = 64`、单个 decimal token 最多 3 digits（本支持集最大值 255），暂不增加可配置 limits 类型。前导零允许但仍计入 3 digits；需要更长 token 的输入整体丢弃并诊断 SequenceTooLong。它们不是 Unicode 数据表；最终数值在测试前冻结。计数超过最大值即饱和，禁止整数溢出。

CSI 使用常规分区：0x30–3F 参数字节、0x20–2F intermediate、0x40–7E final。只在完整且白名单语法的 `m` 后调用 `parseCSIParams`。出现非法排序/非法控制字节即标记为畸形并进入 drain：消费到下一 final，不得把余下数字或 final 泄漏为正文。非控制串内遇新 ESC 可取消当前序列并开始新 ESC；记录原序列问题，防止执行其一部分。未知但完整的序列只记录一次问题。

控制串永远不缓存 payload，只记 string kind、ST 检测状态和饱和计数。超过上限记录一次 SequenceTooLong，进入同类型 quarantine；持续丢弃直到合法终止符或 finish，不能清空状态立即回正文。CSI 超限同样 drain 到 final。控制串里的 ESC 后若不是反斜线，继续 quarantine，不把嵌套 `ESC[31m` 当实际 SGR，也不让未知 device payload“逃出”为正文；CAN/SUB 和其他 C0 也只丢弃，不能作为通用放行 payload 的重置按钮。ST 跨块、连续 ESC、UTF-8 编码 ST 必须覆盖。raw ST 只在 scalar 边界识别，避免吃掉多字节字符中的 continuation。

`feed` 输入可以任意大但 decoder 保留状态仅 O(maxSequenceBytes + maxSgrParameters + 3 UTF-8尾字节 + 1 CR + 常量状态)，绝不累计全文。普通输出批次内存 O(chunk bytes + completed pending prefix)；相同 patch 邻接 runs 可合并。诊断同样不能累计：仅返回当前批次的 issue，必要时按 kind 汇总/计数；如果逐个事件返回，则声明返回内存 O(chunk) 而非假称固定；issue 不包含原始 device payload。无新公共日志回调、无隐藏线程。

UTF-8 薄适配只保留可能跨块的最多 3 字节、识别 scalar 长度，完整 scalar 的合法性用 SDK String.fromUtf8 检查；不复制 Unicode 的码点表/分段规则。raw C1 仅可在无 pending UTF-8 scalar 时识别，合法 continuation 优先；非法 UTF-8 不重解释为后续控制。此边界要有编译探针/负向测试，不能抄键盘 decoder 当第二验证权威。

## 5. 不依赖 reactive-runtime 的集成边界

本增量建议交付的值是不可变 RichText。当前 Component 后续可增加此属性，未来 reactive 的描述/绑定可把同一值作为普通属性更新；不在本文引入 State、节点 identity、订阅或 scheduler 签名，也不读取/假定当前 reactive 计划内情。主代理明确本次 runtime 先仅纯 Text；富文本后续可增加 `Text(RichText)` / `Text(() -> RichText)`，语言重载已独立实证，框架/宏集成仍待验。文本/样式更新的失效仍归 runtime；parser 不主动标脏或刷新。

Frame 与布局共享整簇内容/patch → resolved Style 的解析结果。Frame 仍只保存普通字符簇、完整 Style 和 continuation。ANSI bytes 到此已退役，后端只编码 Frame 自己的安全 ANSI。高层和低层不能存在不同的 SGR 解释、宽度、颜色降级或剪裁路径。

现有 TASK-008 路径在写失败后停止并 close；本增量不给它另增安全重同步内核或透传路径。TASK-010 继续从最终完整 Frame 导出：输入里的 OSC/光标等不可能进入纯文本/彩色快照；实际层可见性依合成后的帧而非重复解释原始 ANSI。TASK-018 可直接消费普通 RichText 经同一绘制上下文写入 Frame，不需要重播 ANSI。截图使用真实终端 PNG，本文 probe 不充当任何可见层/宿主截图证据。

## 6. 建议独立测试作者的可观察验收输入

以下是行为清单，不是测试实现：

- 每个字节边界分块：7-bit CSI、raw C1、UTF-8 C1、RGB/256 色、ST/BEL、CRLF、中文/emoji 四字节数据；所有分块与整段 RichText 规范结果一致（允许相同 patch 邻接 run 数不同，比较归一化内容/样式）。
- 重置与 unset：继承颜色、SGR39、SGR0、22 清 bold+dim；未知混合 `31;999m` 和截断 `38;2;255m` 不部分应用、也不把 2 当 dim。
- 所有六种属性、16/256/RGB、背景空格；通过已有 Frame 样式与快照观察，不检查内部 parser state。
- OSC52/标题/hyperlink、DCS图形、DEC模式、CUP/ED/EL、ESC charset；放入小组件和覆盖层，外部设备/分配区不改变，原始控制 payload 不输出。
- 序列 4095/4096/4097 字节、参数63/64/65、超长 string 后追加普通 ASCII 且未闭合（继续被丢弃）、闭合后恢复正文；多次 feed 不累计 payload/诊断。
- 所有 finish 状态、不完整 UTF-8、非法续字节、D2 9B 等含 C1 数值 continuation；失败后 decoder 不复用。
- typed span 在 e/combining、emoji ZWJ、国旗、CRLF 内部的边界；不拆簇、不遗留半宽 continuation，高低层一致。
- old Text(String) 和 Frame.put(String) 对 ESC/C0 的拒绝仍然存在；typed文本非法 run 不能在 Frame 留下先写入的前缀。
- 不变画面无更新、仅 run 属性变化可观察、快照纯文本无 ESC、ANSI 独立快照仍由完整帧编码；具体 TASK-008 的写失败矩阵单独安排。

## 7. 冻结前仅需主代理决断/补实证的点

1. Span patch 与组件显式链属性谁优先；本文推荐组件显式逐字段优先，符合现有 AGENTS 组件显式优先原则。它不是当前实现已存在的行为。
2. 资源限制的确切固定数值、批次诊断是否逐事件或聚合，以及错误类/关闭后调用行为。上述建议已足够让测试作者写固定期望；正式公开后应避免随意变化。
3. Byte 流 raw C1 与 UTF-8 联合边界需产品实现前专门微验证；目前实测的是 ansies 的 API 缺口与 SDK UTF-8契约，不声称增量 decoder 已实现。

不需要用户选择完整终端模拟器与否：既有需求已经排除；也不需要把图形协议、设备控制或键盘 decoder 合并纳入来“提升兼容”。

## 8. 调查执行记录补充

曾误在产品根目录启动一次 `cjpm run`，发现进程等待后已终止。没有把该调用当作产品构建/运行通过证据；前后 tracked 工作树保持为空。独立 probe 随后从自己的 `target/release/bin/main` 直接执行，日志与本目录源码一一对应。产品源码未编辑，所有建议仍为未落码草稿。
