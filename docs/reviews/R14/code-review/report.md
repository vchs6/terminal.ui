# TASK082 独立技术审核

固定 BASE：`9bc493fe9c1943b8608be0969c0b2d5e4cfdd924`。固定 PRODUCT：`034685dacd76f1450317b0352411ddc4be112136`，tree `f88bd92e72110297e5dfc5e45d1bd1e4e6a20e60`。

**Spec compliance：FAIL。Task quality：FAIL。Critical 0，Important 1，Minor 0。** 两个结论均针对本次固定产品增量；阻塞项为 R14-T082-001。未发现另一项需阻塞的架构、公开接口、数组所有权或运行时集成缺陷。不存在“测试通过因此默认审核通过”的推定。

## 输入、隔离与方法

本审核按 task-082-brief.md 读取 AGENTS、最终 `7a33ddc7fb93da3f30007e49538cb00821a2d81b` 的 design、task-009-brief、当前变更 tasks 的 global/review focus、正式 `3f60142/7ba2cd4` tests/rich-text，以及固定 BASE..PRODUCT 的全部 26 文件差异。未读取产品作者报告、progress 或自评，未联系作者、未创建子代理、未改产品源码、正式测试或主仓。

独立目录为 `/workspace/work/rich-text-review`；`source` 是固定 PRODUCT 的 git archive。`reviewed-sourcehashes.json` 记录 79 个产品源码/本地构建输入/本次文档示例文件的 SHA256 与 git blob，逐个与固定提交内容比较。独立 probe、cache、配置及原始输出均在本目录下。源码本身未改动；构建生成物与被忽略的仓库配置单独留存。

采用 verification-before-completion 的证据门槛，按 AGENTS11 复用内容与范围相同的已有有效结果，不因审核角色重复旧套件。读取 review 技能的核实原则；仓颉 coding Skill 通过其 search_docs.py 批量查询 String.size、String.fromUtf8、Array.clone。另读取固定 cangjie-rules 的结构、命名及格式适用条目，以项目 cangjie-conventions 的范围为准，未引入额外检查器或依赖。语言事实以实际 SDK1.2.0 构建优先。

## 阻塞发现 R14-T082-001（Important）

位置：`src/text/ansi_text_decoder.cj:109`，关联 `feed` 的逐 byte 资源检查（84–85）、UTF-8 完整 scalar 才分派（87–101）、CSI 语法分类（247）。

现有实现遇 CSI 内 UTF-8 lead byte 时只保存 UTF-8 前缀；直到 scalar 完整才调用 `controlSequence`。这个 lead 已不属于 CSI 允许的 ASCII 参数 `30–3F`、intermediate `20–2F` 或 final `40–7E`，语法首错却被延迟。下一 byte 的资源检查因此可以先设置全序列 fault，永久压过更早的语法错误。

独立公共消费者：`probe/src/main.cj`。实际 SDK 构建 exit 0，直接执行 `target/release/bin/main` exit 0（观察探针打印结果，不把进程成功当成契约通过）。原始命令及条件见 `raw/probe-command.txt`，原始输出见 `raw/probe-run.log`，受检二进制和源码 hash 见 `raw/probe-binary-source.sha256`。

输入 `maxSequenceBytes=3`，第一批 `1B 5B C2`，第二批 `A0 6D`：

- 期望第一批立即返回 `MalformedSequence(offset=0)`；第二批只继续验证合法 UTF-8 `C2 A0` 并 drain 到 `m`，不替换或重复已有首错。
- 实际第一批 diagnostics=0；第二批返回 `SequenceTooLong(offset=0)`。
- 对同一完整流把预算改成4，则实际返回 `MalformedSequence(offset=0)`。

冻结 design5/6 明确首个语法/资源故障立即一次报告，仅同一 byte 同时故障才资源优先。C2 已是不可能成为合法 ASCII CSI 字节的输入，因此不需要等待 A0 才知道语法错误。主代理基于冻结文本确认此解释，记录在 `raw/contract-interpretation.txt`。此项不是新增未知 SGR 语义。影响为可观察的诊断时序和 first-fault kind 错误；未观察到 payload 泄漏或终端控制执行。

修复须保留已有 UTF-8 校验：后续非法或不完整 UTF-8 仍应抛 `InvalidUtf8` 并永久关闭；提前记语法首错不能释放残余正文、重解释 continuation 为 C1，或改变 normal 状态下合法 UTF-8 C1 introducer。正式回归用例由独立测试角色编写，再由原产品角色修复。本审核未作修复或更改正式测试。

## 规范与质量审查覆盖

| 检查面 | 审核结果与依据 |
|---|---|
| 不可变值、数组防别名 | TextSpan/Patch 为 let 字段值；RichText 规范化并保存独立 Array；getter clone；Batch/Result 数组防别名，Diagnostic 只读且无公开构造。逐项 resolve 保留 None/Default/false 差异。与 values/aliases 原始结果一致。 |
| 全文分簇与 CRLF | RichText 拼接后唯一严格验证；richTextClusters 用整篇 graphemeClusters 和 UTF-8 byte 边界选择首 scalar patch；不是逐 span 分段。跨 span CRLF、ZWJ、组合符、旗帜及宽格清理沿用 Frame 内核。 |
| 样式优先级 | Frame base 在 span 下；组件 explicit patch 在 span 上，祖先 inherited 在 span 下。Style/Color 保留原 typed 值，未建立颜色降级或 ANSI 输出第二内核。 |
| 公开兼容与包方向 | 原 String API 仍在并严格拒绝控制；新增 Frame/Component 成员及 Text 重载符合冻结签名。validatePlainText 在 text 叶包，根 validateText 仅委托；root 重导出，text 只依赖 style/Unicode/SDK/ansies，无反向根依赖。 |
| 有界 decoder | 对 CSI raw byte、参数含空字段、三 digit-run、终止符及 introducer 长度进行有界计数；超限后计数饱和，csi 清空且不再增长；UTF-8 pending 常量上界；不保存控制串 payload、过往 batch 或诊断。Int64 offset 先检查再增加。首错的 UTF-8/byte 分类顺序存在上述阻塞。 |
| 安全框定与 SGR | 只执行白名单样式；ansies.parseCSIParams 负责既定参数拆分；所有 SGR 先在局部映射，完整成功才提交 patch。未知/畸形不部分应用；OSC BEL/ST 与其他控制串仅 ST，内部 ESC/CAN/SUB 不释放隔离。UTF-8 continuation 不作为 raw C1；无 unsafe String。 |
| 关闭与异常 | finish 后 DecoderClosed；非法/残缺 UTF-8 走 fail-close，清残留且本次 batch 不交付。异常前已成功 batch 不回滚符合契约。InputTooLarge 的不可实际穷举边界按 pre-increment guard 审核，没有声称做过巨量输入实测。 |
| getter/失效/缓存 | String/RichText 共用 text binding 名，替换释放旧订阅；值相等不 mark；同纯文本样式改变仅 Style，文字变化 Content。evaluateReady 由具体 setter 判实际变更；显式 NodeRef.pending 的 Content/Style/Layout/Structure/All 仍保留独立强制通知，Bindings 仅重求值。 |
| 生命周期、render(subtree) | measuredLayout 仅由 application root 持有；子树 render 创建自己的测量，不污染根缓存。Content/Layout/Structure/All 清缓存；动态组/显隐/尺寸 setter 正常标记；身份、挂载、卸载、UI 域和 cleanup 路径复用原运行时。 |
| 职责与文件组织 | 全部新增实体各一文件，纯函数内聚；没有第二 Runtime、富文本 renderer、Unicode 表、终端模拟器、外部运行依赖或主题/M2扩张。样式改变需要重 paint 并复用 measure，因此新增测量缓存有契约依据。文档与可运行公开示例覆盖使用边界。 |

## 原始证据复用与限制

`raw/evidence-reuse.json` 逐条给出原日志 SHA256、exit、staged tree 及相对 PRODUCT 的变化；`raw/log-summary.json` 的 PASS 行数只是日志摘要，不能等同独立测试用例数。所有复制日志与原 `.meta` 内声明的 hash 一致；SDK 两个二进制、envsetup、依赖归档和 UCD 的实物 hash 核对成功；正式 tests/rich-text 的全部归档 hash 核对成功。检查输出在 `raw/environment-hash-check.log` 与 `raw/formal-test-hash-check.log`。

- `rich-fixed`、`runtime-fixed`、`bundle-fixed`、`clean-consumer`、`scope-probe-green` 受检 staged tree 与 PRODUCT tree 完全一致，原 exit 均0。rich-fixed 保留12条场景组 PASS；runtime-fixed 保留301条 PASS输出。
- `regress-frame-layout`、`regress-color-layout-pty` 和 `example` 原 exit0，受检 tree 只差后续 `renderLayout` 的应用根缓存归属修复。其根渲染路径分支语义不变，可复用相应 Frame/layout/decorations/composition/colors/PTY/example 范围；子树行为由最终 scope-probe-green 与 runtime-fixed 覆盖。差异原件为 `raw/pre-scope-to-final.diff`。
- `rich-final` 为历史结果，有 exports/layout 后续变化，已由 rich-fixed 替代，不当作最终证据。
- `scope-probe-red` 名称含 red 但实际 exit0，原样保留；真正 mounted 反例 `scope-probe-mounted-red` exit1 也保留，不以文件名替代事实。
- `clean-consumer` 来自正常 bundle 解包，仅 consumer manifest 改相对依赖路径；原 `.cj` source diff为空。该记录不代替 TASK083 的独立执行。普通 `cjpm bundle` exit0，存在仓颉 lint warnings，不声明零警告。
- **完整制品边界仍失败**：`archive-boundary-fixed` exit1，原错误是缺少 `examples/composition/cjpm.toml`；现 required 清单也要求尚未交付的 `benchmarks/rendering`。原 log/meta 完整保留。本项不作为额外 TASK009 gate，也不宣称完整 Linux release 通过。
- 先前缺 API/编译失败原件 `initial-red`、`iteration-1/2/3/4` 保留，不重跑失败或把历史终止/空日志记作成功。

本次唯一新增运行是上述具体未验证 byte-order 反例；未重新执行有效旧套件。主代理应先交独立测试角色固定真实 RED，再交产品作者修复，按变化范围重新核对。TASK083/TASK084、TASK010可见层、完整 Linux 交付仍各有原独立退出条件，本报告不关闭这些任务。
