# TASK-068 independent spec / quality review

受检版本：`883444195725224985f29060253017432abaa7f3`，基线 `31a7017`（完整基线 SHA 见 inspection.json）。独立工作目录 `/workspace/work/frame-review/repo`，detached checkout，审核后 tracked/untracked 状态为空。分类：execution；精确公共契约已经冻结，本轮只审核实现及测试，不改变需求或产品。

**Spec verdict: PASS. Quality verdict: PASS.** 本次固定技术范围内没有发现 Critical、Important 或 Minor 缺陷。可以进入 TASK-069 独立执行及 TASK-070 有限验收；这不是 TASK-069/070 已完成或全部 Linux 已验收的结论。

## 输入与独立性

- 精确判断依据为 `openspec/changes/implement-frame-composition/design.md` 与 `tasks.md`；读取 AGENTS、Battle 协议及整体提案/需求/架构/用户构造设计作为背景，不把后续 runtime 或其他平台工作纳入此次精确契约。
- 完整技术输入为 `/workspace/work/terminal.ui/.superpowers/sdd/frame-composition/full-technical-review.diff`，包含全部 11 个产品、冻结 tests 与产品说明路径。逐文件审核了 Cell、Frame 全文及相关 geometry / snapshotProfile 调用链，读取冻结消费者、文件 golden 和 runner。没有阅读实现作者的分析、report.md、自评或预设结论。
- `git apply --reverse --check <full-technical-review.diff>` 在固定 checkout 返回 0；11 个文件与作者工作目录内容 SHA-256 全部相同。具体文件、摘要与命令原始结果见 `inspection.json`。这证明当前技术内容一致，不声称单靠当前 hash 即可追溯每次历史测试的完整环境。
- `git diff --exit-code 31a7017 HEAD -- tests/contract tests/coordinates tests/colors tests/layout tests/decoration` 返回 0；这些既有消费者与 byte 断言未弱化。tests/run-slice.sh 仅新增 composition 分支、all 调用与帮助条目；既有模式未删除。
- 本角色没有修改产品/tests，没有派生子代理，也没有再次运行相同功能套件。没有发现需要新增执行探针的具体失败假设，因此没有为数量补造 probe。
- 实际读取并应用 Superpowers `requesting-code-review` / `code-reviewer.md`（独立只读审核、具体分级、declined-to-judge）与 `verification-before-completion`（先核实证据，再给结论）。using-superpowers 已读取，其 SUBAGENT-STOP 适用于本任务。按 AGENTS §11 与任务明确指令复用有效 raw，不因审核角色重复执行。
- 指定模型/推理强度：Astra/high。当前角色可见的工具输出没有可证明实际后端型号、推理强度或路由的运行元数据；不能将指定值伪写成已验证运行型号。实际可核实工具：Cangjie Compiler 1.2.0 (cjnative)、CJPM 1.2.0、target x86_64-unknown-linux-gnu，Linux 6.18.57 x86_64，见 `raw/reviewer-environment.txt`。
- 本轮为首次审核，scoped 修复复核 0/3。

## 关键检查与结论依据

| 检查 | 路径与具体推演 / 原始证据 | 结论 |
|---|---|---|
| 透明与样式空格 | `src/cell.cj:8` 新增只读位，旧包内构造固定 false；`src/frame.cj:253` 只按透明位跳过。put/fill/border/shadow 仍从旧不透明构造写入。透明初始化/clear 均生成单列 Style() 空格，无残留 continuation。`aXcd / ef h` 与默认空格覆盖案例同时校验文本与 metadata。 | 符合 |
| 源宽簇被左右裁断 | `src/frame.cj:257` 只复制剩余可见列容纳的完整 leader；首列 continuation 或右截 leader 在 264–266 转为原 style 的不透明单列空格。源 `a中bc` 的 copy(2,0,3,1) 为 ` bc`，resize(2,1) 为 `a `；负偏移和右侧复合都有对应固定期望。 | 符合 |
| 目标伙伴在交集外 | `src/frame.cj:35` clearAt 回溯 leader 并清完整簇；composite 写入前清目标全部触及簇，伙伴使用目标默认空白类型。两组目标 `中中` 被中间 `中` 覆盖应为 ` 中 `，冻结案例检查外侧两格透明规范化。透明源分支不会触发 clearAt。 | 符合 |
| 先裁剪再危险算术 | `src/frame.cj:237` 先拒绝空轴、正向越界与 `x <= -layer.width` / y；可到达 `-x` 的 x 严格大于 -layer.width，因此不是 Int64.Min。dx/sx 与减法均在实际尺寸内，columns×rows 不大于任一实际有界交集。clear 使用既有 signedAdd 饱和且循环仅遍历交集。copy 的 Int64.Min 特判合法：任何可表示的非负 extent 从该原点出发仍到不了源坐标 0。 | 符合 |
| 自身重叠 | `src/frame.cj:246` 在任何目标写入前复制全部交集 Cell 值，之后只读取该快照；Cell/Style 的值语义与不可变内容不共享可变 cells。四向偏移、宽簇伙伴清理与透明孔都有固定网格验证，不存在边读边写拖影。 | 符合 |
| 空轴与预算 | `src/frame.cj:14` 在分配前校验负尺寸、非正预算、乘积溢出与正面积上限；0×Max/Max×0 仍可创建。几何新操作空轴短路；零高纯文本循环为空，零宽文本只允许 height-1 <= maxCells，`toAnsiForTerminal` 零轴立即返回。没有真实巨量合法分配测试。 | 符合 |
| copy/resized 状态 | `src/frame.cj:220` 与 228 把原宽度策略、默认透明类型及 maxCells 传给新 Frame，再走共同 compositor；独立数组，越界 padding 使用原默认空白。扩缩与后续写入策略均有固定验证；不重复 Unicode/ANSI 内核。 | 符合 |
| 策略校验优先 | `src/frame.cj:234` 在任何 no-op/clip/snapshot 之前拒绝 ambiguousWide 不一致；空源、空目标与极端完全离屏也抛 IllegalArgumentException，目标无修改。 | 符合 |
| 文件创建、截断、失败 | `src/frame.cj:271` / 274 委托标准 File.writeTo；内容生成及预算验证发生在函数调用、打开文件之前，没有 catch 吞错。冻结 runner 先建 1024-byte 文件，独立 literal bytes 验证精确截断，包括零字节；不存在文件、目录、缺父目录、预算 sentinel 和真实 /dev/full 均有 raw。 | 符合；关闭阶段故障注入未执行，见 limits |
| 纯离线完整快照 | writeAnsi → toAnsi → snapshotProfile 参数构造；该链不访问终端、环境能力探测或差分基线。runner 强制 TERM=dumb/COLORTERM 空；默认 TrueColor、显式模式与透明扁平化字节仍由独立 CUP/SGR golden 判断。普通旧编码实现没有改动。 | 符合 |
| 职责/可维护性 | 仅扩展现有 Frame/Cell，仍每类型独立文件；copy/resized 复用合成，clearAt 单一维护宽簇。交集临时数组 O(columns×rows)，包括不同实例也快照，虽可未来优化但有界且不违反契约；未增加缓存、第二内核或产品外部依赖。 | 符合 |

特别核对但不作为缺陷：普通 opaque Frame 经 `clear(..., transparent: true)` 产生的孔，复制/缩放后可能回到该 Frame 的默认 opaque 空白。精确 design 明确 `copy/resized/composite` 中“透明仍跳过”，且结果以原默认空白初始化；实现遵守此规则。本次不暗中把 copy 改判为所有 metadata 的逐单元克隆。该组合没有单独动态 probe，结论来自明确契约与源码。

## Findings

Critical: 0；Important: 0；Minor: 0。没有确认的违反契约反例；不编造 severity 或修复要求。机器可读发现为 `findings.json` 的空数组。

## 原始执行证据与适用范围

以下是作者提供的原始执行产物，由审核者直接读取、复制并计算摘要；它们是开发验证依据，不替代 AGENTS §13.2 要求的 TASK-069 独立执行角色。

| 原件 | 审核目录副本 | 实际可见结果 |
|---|---|---|
| `/workspace/work/frame-implementation/final-matrix.{stdout,stderr,exit}` | `raw/final-matrix.{stdout,stderr,exit}` | build success；140 条 PASS、0 FAIL、0 SKIP；stderr 0 bytes，exit 0；包含 /dev/full 两类真实写失败与 15 条独立文件验证输出 |
| `/workspace/work/frame-implementation/contract.{stdout,stderr,exit}` | `raw/contract.{stdout,stderr,exit}` | SDK/CJPM 1.2.0；build success；109 条 PASS、0 FAIL、0 SKIP；stderr 0 bytes，exit 0 |

具体运行入口由冻结 runner 可恢复为 `tests/run-slice.sh composition` → CJPM build → 直接 binary under timeout → Node literal-byte verifier；contract 模式同样先 build 后直接 binary。所给 raw 没有完整 shell invocation/环境快照，因此不把推导的入口冒充日志实际记录过的完整命令。11 个相关当前文件与固定 checkout hash 相同，详情见 inspection.json。

审核者本次实际执行的验证：反向 patch check、旧消费者 diff check、工作区 clean check、11 文件 hash 比对、raw 字节/退出码与 PASS/FAIL/SKIP 行计数、工具版本检查。以上结果保存在 inspection.json 和 raw/reviewer-environment.txt。

## Declined to judge / limits

- TASK-018 可见覆盖层宿主、动态状态、关闭后更新与焦点行为：此次只有 Frame 原语，design 明确后续集成，不据此关闭 TASK-010 原完整 AC。
- runtime 更新事务、ANSI 输入 parser、终端故障恢复、全 Linux/全部宿主与其他平台：不在本次技术变更范围；没有重复会话/能力/全量发布套件。
- 原有字符串拼接导出性能、不同实例快照优化、显式极大 maxCells 的物理内存极限：本合同是可配置单元预算，不承诺固定字节或吞吐门槛；未测量性能，不给性能通过结论。
- File.writeTo 在单独 close 阶段失败的注入：本次没有独立 close-failure 动态证据；源码无异常捕获，依标准库传播。已可见的是打开失败与实际 write 失败，不把它们说成 close 注入证据。没有要求原子替换、旧内容保留或 fsync 持久化。
- 尚未收到本轮 coordinates/colors/layout/decoration、bundle 与包消费者的完整执行 raw；本审查不能宣称这些当前执行已通过。TASK-069 必须接续原始证据，审核发现的空集合不免除该义务。
- 所有 PASS verdict 仅为本固定 diff 的 spec/quality 审核结论，不代表全产品验收或发布许可。
