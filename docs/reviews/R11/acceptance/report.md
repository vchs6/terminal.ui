# TASK-070 有限功能与合同验收

受检固定主仓：`5c2a7e7d956b5d8c0284e96514276608616bf8a6`。本轮结论：**AC-005、AC-007、AC-067、AC-068、AC-069 的限定交付通过；AC-010 的 Frame 文件原语部分通过，完整 AC-010 保持 pending。AC-070 的功能/合同验收部分通过，最终主仓证据复制及状态元数据投影尚待第二次有限核对，因此本报告不宣称整个 TASK/AC-070 已完成。**

原完整包检查器仍实际 exit **1**，缺少后续 `examples/composition/cjpm.toml`。正常 `cjpm bundle` 与普通包消费者通过不改变完整 release 失败事实。全部 Linux、应用层覆盖捕获、动态更新/焦点、M2、其他平台及发布均未据此通过；主代理应继续总计划。

## 身份、方法与固定输入

本角色为独立验收者，指定 Astra/high；当前可见运行元数据不能证明实际后端型号或推理强度，因此不把指定值写成已验证运行身份。未派子代理，未写产品或 tests，未重跑功能 suite、bundle 或消费者。主仓在本轮首尾均为固定 SHA 且 `git status --porcelain` 空。独立产物仅写入 `/workspace/work/frame-acceptance`。

分类为 execution：验收已冻结合同，不新增需求或改变范围。读取 AGENTS、总体提案/需求/架构/用户构造设计背景、`openspec/changes/implement-frame-composition/design.md`（包含 F003）、`tasks.md` 及当前 AC 行。使用 cloud-environment-runtime 查询当前环境；使用 verification-before-completion 的先核证据门禁，并服从 AGENTS §11 及任务指令复用有效同范围结果。using-superpowers 的 SUBAGENT-STOP 适用于当前派遣角色。没有把低层 API 增量升级成真实终端呈现验收或额外要求 GUI 截图。

独立审核输入为 `/workspace/work/frame-review/review-round1.md`、`recheck-f003.md`；执行索引为 `/workspace/work/frame-execution/report.md`，结论实际依据其 raw、实际包与保留 artifact；独立测试输入为 `/workspace/work/frame-tests/report.md` 及 evidence 原件。本轮没有阅读产品作者分析报告或把作者自评作为验收结论。五旧回归仅直接核原始日志、版本和内容适用性。

可复核自有检查为 `audit.mjs`、`package-boundary.mjs`；其实际输出/退出位于 `raw/`。`facts.json` 保存固定源、所有核对清单、执行入口/cwd/start/end/退出、日志摘要、文件原件逐项字节 hex、包内文件摘要及回归结果；`package-boundary.json` 保存从实际 tar 读取的全部清单与递归依赖表。本次实际审计两入口 exit 0；这是证据校验，不冒称重新执行产品功能。

## 逐 AC 判断

| AC | 本次判定 | 合同、观察及证据 |
|---|---|---|
| AC-005 | passed，Frame 层完整范围 | 原 contract 保留组合符 `e+U+0301`、中文、ZWJ emoji、旗帜的 leader/continuation、边缘省略、覆盖清簇、孤立零宽字符规则；新 composition 覆盖 clear 整簇、copy/resized 左右截簇变同样式不透明空格、目标交集外伙伴清理、四向自身重叠、独立所有权和极值。不透明簇使用同一 Frame transfer/clearAt，未复制 Unicode 算法。独立 composition 165 PASS/0 FAIL/0 SKIP、旧 contract 109 PASS 及审核固定代码支持这一判断。 |
| AC-007 | passed，完整目标 Frame 与低层叠放 | `Cell.isTransparent` 独立只读位；透明规范化空白，默认/带样式空格不透明；后层在上、透明不覆盖、源不变、自身开始快照。F003 明确 copy/resized 保存透明位；实际 original/copy/same-size resized 各自叠 `ABC` 均为 `XBZ`，新增行列保留源默认 opaque 空白，双向修改独立。见两次独立消费者原件及源码 `transfer` 的 `skipTransparent` 区分。 |
| AC-067 | passed | 原独立 tests 159d44e/b4684be 的真实缺 API RED exit 1；原产品正常 build 0，baseline 源摘要与 31a7017 的 26 文件匹配，core 5 文件及最终 tests 摘要匹配对应固定提交。F003 独立新增测试 7a4def7 在未改产品 8834441 上正常 build 0，直接 focused binary exit 1，8 条具体 FAIL；旧 golden 未改。F003 测试文件摘要等于最终受检源码。 |
| AC-068 | passed | 初轮固定 31a7017..8834441 完整技术审核及 F003 scoped 复核汇合至 5c2a7e7；最终 spec/quality 均 PASS，无未决 Critical/Important/Minor。原初轮按当时透明跳过合同判断，后续 F003 澄清以独立 RED 和修复复核处理，不能倒算成原作者违反原歧义合同。 |
| AC-069 | passed，限定交付 | 独立根 build/check、完整新消费者、实际无 skip 的 bundle、实际解包 build/check、普通消费者均有真实 exit 0。两次新消费者各150 native +15独立文件 verifier PASS；五旧回归按内容复用且原件/副本 hash 相同。完整 checker 的真实 exit1 仍保留，069限定通过不等于 release 通过。 |
| AC-070 | functional_contract_passed；final_projection_pending | 本报告完成固定源、原始证据、AC005/007、文件原语、包和普通消费的有限验收。最终主仓复制/引用可达性、tasks/acceptance/product/progress 等状态一致性在后续二次有限核对完成前不能宣称全部070完成。本轮未修改任何主仓状态。 |
| AC-010 | 文件原语部分 passed；原 AC pending | 完整 Frame 的独立 ANSI/纯文本文件、UTF-8、透明扁平化、颜色、创建/精确截断、预算先行、明确实际写失败成立。真实 Application 可见覆盖层捕获、装饰/状态/层生命周期汇合仍待 TASK-018 后验证；不能用手工 composite 的文件替代应用层捕获。 |

## 关键合同核对

**宽簇与透明孔。** 原始 F003 RED 中 original 的孔和 `XBZ` 成立，copy/resize 变为 `X Z`；metadata 也明确为 false，因此不是文本显示差异或编译失败。修复后独立 TASK-069 两次完整入口同时保留旧宽簇/裁剪/自重叠和新25条 F003 断言。源码 copy/resized 传 `skipTransparent=false`；composite 传 true。源透明 Cell 已规范化，复制后仍是独立新数组；源默认空白类型仅控制交集外 padding 与未来清理。未仅用相同空格字节推断透明语义。

**预算和历史零轴。** 默认正面积上限1048576、非正预算/负尺寸/乘积溢出都在分配前拒绝；copy/resized 保留预算。新几何操作先策略校验再空轴/离屏短路，极值不进入虚拟循环。`Frame(0,Int64.Max)` 与 `Frame(Int64.Max,0)` 的合法构造和 ANSI 空输出保留；零高 plain 为空，零宽 plain 为 height−1 个 LF，在生成/打开前以 maxCells 限制。原独立日志明确覆盖上述历史极值、LF恰好预算/超预算、拷贝/缩放及 mismatch even empty/offscreen，不靠实际巨量分配验证。默认正面积新合法域与零轴兼容例外已在合同公开，不声称旧无限面积分配继续被支持。

**文件字节与错误。** 两次保留原件目录分别为 `/workspace/work/frame-execution/artifacts/run.80htWDRC`、`run.sFSi63rl`。本轮对每组13文件直接读 Buffer 与字面 UTF-8 比较，并验证2条路径仍不存在；没有调用产品 exporter 产生期望。plain 为 `中CD\n e\u0301  `（保留组合序列与全部列空格），无 ESC、BOM、额外尾 LF。ANSI 初尾 reset、每行 CUP、默认及显式 TrueColor、Basic8、Monochrome 逐字节相等；透明帧扁平化为空格，零高文件0字节，零宽 plain为3个LF、ANSI为空。两组1024-byte旧文件实际截断；预算 sentinel 原文不变且 budget-created/missing-parent 未创建。

冻结 runner 在 `TERM=dumb`、空 COLORTERM 下运行，默认文件 TrueColor 不依赖终端探测；xtrace 证明实际 `/dev/full` 存在并选择写失败分支。原日志分别记录 plain/ANSI missing parent、directory target 与真实 `/dev/full` 写失败传播成功。源码使用标准 `File.writeTo(path, export().toArray())`，先求值验证后打开且无 catch 吞异常。单独 close-failure 动态注入未做，只能据标准库委托/未吞错说明传播路径；不声称做过 close 注入、原子替换或持久化测试。

## 源、包与普通消费者证据链

- `raw/inventory.sha256` 全 **149** 条逐项匹配；delivery manifest 也匹配。执行 final-source-tests 清单逐项等于主仓工作区、独立执行 checkout 及固定 Git blobs。原测试 baseline/core/delivery/F003 evidence 清单均检查；F003 旧产品摘要精确匹配8834441，最终测试摘要匹配5c2a7e7。
- 实际 `.cjp` SHA256 为 `c5808fab3b2599cde853d35f1d6cf52f0f73bd100a86f5c6ad89aabd4ab7a064`。从 tar 逐项读出的 **62** 普通文件全部等于固定 Git 源及实际解包目录。归档只有普通文件/目录，没有 target、tests、缓存、脚本开发目录或编译 archive。4个实际 cjpm.toml 的全部递归 dependency tables 已独立解析：根中心仓依赖 ansies1.3.113/unicode0.1.0/unicodewidth0.1.113，3个示例路径均指向包内根，无 git/绝对逃逸依赖。
- 原 `cjpm bundle` 无 skip；真实 exit0、测试汇总 TOTAL0、mandatory lint **145 warning**、bundle success。TOTAL0 不冒充 composition 功能用例；功能证据来自单独 consumer。
- 实际解包后 `cjpm build/check` 各exit0。普通消费者仅将冻结 manifest 的 `../..` 改为解包产品绝对路径；4个源文件、runner、verifier 逐字节相同，无私有 FFI/link/compile 参数。执行准备脚本只生成 ignored registry/cache 配置，未复制作者 target/native archive。包本身排除编译物；普通消费者直接timeout binary再运行外部 verifier，xtrace 下一条 `previous_exit=0` 与 set-e runner 最终exit0支持两阶段真实状态。
- 构建使用SDK1.2.0、Node24.22.1、GCC14.2.0、Linux x86_64，原版本/environment/SDK/UCD摘要在execution raw保留。初次root-check在native生成前exit1，build后重check0；初次npm默认缓存权限失败254，改私有cache后0。失败未删除；它们不构成仍未解决的产品失败。
- 原完整 checker 保持原脚本和实际exit1：`Incomplete product bundle: examples/composition/cjpm.toml`。实现范围的包审计不替代全量 checker，也不通过篡改 required 列表制造 release success。

## 有效旧回归复用

原件位于 `/workspace/work/frame-implementation/{contract,coordinates,colors,layout,decoration}.{stdout,stderr,exit}`；直接读原件并与 execution/raw/reused 副本比hash，结果分别109/2/1944/114/59 PASS，全部exit0且无FAIL/SKIP。layout两条既有warning保留。本角色与069都没有声称独立重跑这五项。

适用性依据：8834441..5c2a7e7 的五类 tests、cjpm.toml、build.cj/native diff为空；产品 F003 只影响共享 transfer 的复制透明分支，旧 put/fill/border/shadow/export、颜色/布局路径没有变化，新受影响 copy/resized/composite由独立完整composition重新覆盖。两角色依赖缓存中全部 `.cj/.toml/.c/.h/.S` 源内容重新逐文件比对一致，native UCD archive摘要同为 `96f0552e197c0f02a7860f13cd0174617df639315252221828785103628e0c03`。SDK/OS/同一环境、UCD输入与registry relay范围可追踪；仅缓存绝对目录不同不使内容证据失效。

## 后续有限汇合与限制

当前固定 docs/acceptance.md 中这些AC仍为pending，tasks.md仍未勾选：这是本轮交付前状态，不能把本报告当作已完成最终元数据投影。主代理在复制证据、更新单一权威tasks和AC有限状态后，应只交这些变化及其引用/hash做二次有限核对，不重复已有效功能套件。验收输入不变时本报告功能结论可复用。

不判全Linux/真实宿主matrix、应用层可见覆盖层/关闭后最新状态/焦点、完整AC010、M2、性能/物理内存极限、其他平台或release。当前无已确认的本增量产品缺陷或未决必需功能失败；完整交付缺口和后续投影待核对均如实保留。
