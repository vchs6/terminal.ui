# TASK165 独立技术审核

规格符合性 **PASS**；代码质量 **PASS**。Critical 0 / Important 0 / Minor 0。此结论仅准予固定产品进入独立执行/验收，不宣称真实 GUI 修复通过，也不关闭原 R14T083001。

受检完整范围：BASE `23ac7aa602187428b6e4d297f38fca614df717fe` → PRODUCT `199f00076c1a79cfa6d0be92e7be09366e1a06af`，7 个产品文件、119 行新增/77 行删除；正式测试 `614d0a2f0e33e54ecc07bd783eaeb0b9957ca557`。以 git archive 建立本目录 `source/`，未修改主仓/产品/正式测试/分支，没有子代理或作者通信，没有读取作者 report/progress/self-assessment。

这是已冻结 A001–008 / G005、G007、G010、G012 下的执行型审核，不新增产品决策。依据实际调用链、完整差异及独立正式测试逐项判断，无预设通过。完整技术包与 `git diff -U10 BASE PRODUCT` 字节一致；测试目录从正式测试提交到 PRODUCT 的 diff 为空。原物理失败及独立 scalar 事实用作因果输入，不作新产品通过证据。

## 合同与源码核对

| 合同 | 核对结果与具体源码 |
|---|---|
| A002 单一私有 owner | `src/glyph_render_policy.cj:3` 只有包内不可变 class、只读 Bool、private init 和两个指定工厂；不暴露公共 setter/API。`src/terminal_render_profile.cj:12` 追加只读 policy，命名参数位于旧参数之后、默认 Unicode；与未来 G010 同名同包 owner，可在094原类扩展，无平行内核。 |
| A003 width 边界 | `src/terminal_glyph_projection.cj:4` 先拒绝负数，两策略一致；width0 在读取策略/遍历/分配前返回空。正宽没有固定<=2上限，唯一生产调用来自 Frame head。`src/frame.cj:13` 保留尺寸乘法溢出和 maxCells 除法预算，`put:64` 只存完整正宽 head，blankCell 宽1，transfer 保持完整 head/continuation。 |
| A003 scalar admission / overflow | `src/terminal_glyph_projection.cj:13` 以 stored width 为剩余预算；逐 Rune 调唯一 `displayWidth(scalar.toString())` 默认窄模糊宽度。先拒绝 scalarWidth<0 或 >remaining，再做减法，所以始终 0<=remaining<=width，没有累加回绕，也不会负值抵消误放行；恰好耗尽才保留。负标量宽的保护存在，即使常规依赖样例未产生负数。 |
| A003 字符/逻辑完整性 | 不再次对完整簇分段、不改 Unicode 表、不删 VS/ZWJ/组合符、不改 canonical width；ASCII63 有效字节经安全 `String.fromUtf8` 构造恰好 width 个 `?`。Frame/RichText 原控制字符验证保持。public ambiguousWide=true 格网及离线输出不变，设备窄标量和与已存width2不等时投影两问号。 |
| A004 统一 full/diff | `src/terminal_projected_row.cj:3` 为实际生产路径，`src/frame.cj:315` 与 `:332` 共用它；保留簇重建原 head+continuation，fallback 每列变 width1 `?` 同样式。旧 duplicated row encoder 已删除。每行只临时 Array<Cell>，无新 Cell 类型/第二 Frame/持久 cache。 |
| A004 实际列相等 | `terminalRowsEqual:31` 仅比较投影 grapheme、width、continuation、Style。ZWJ→VS16、宽head fallback↔两个独立字面问号都成为同一列序列。old/new 各用自己的完整 profile；无对象 identity 或 raw semantic 直接判变分支。 |
| A004 样式 | `projectTerminalRow:5` 用各自 profile 初始化默认 Style 的投影，head raw style 变化时重用既有 `projectTerminalStyle`；未复制或删改颜色/六属性/NCV 规则。continuation 使用head投影style。`encodeTerminalRow:41` 合并实际相同样式，full行末与delta外层复位保持原字节约定。NCV 正值及unknown位的处理仍由 `src/color_mapping.cj:99` 唯一拥有。 |
| A004 极空轴/尺寸/提交 | `src/frame.cj:307` 和 `:326` 在 height loop/row 分配前处理任一零轴，包括 Int64.Max 空轴；异尺寸继续 full 输出。`src/application.cj:214` 起原成功输出后提交 logical baseline/profile 的顺序未改；未引入持久 placeholder baseline。 |
| A005 默认设备/离线 | `src/terminal_capabilities.cj:114` 对每个 colorMode 显式 conservative；`Application.run:196/208` 自动和 override 均走该工厂。`snapshotProfile` 默认 Unicode，Frame.toAnsi/writeAnsi/纯文本/业务快照均维持原语义；诊断source/reason无改动。 |
| A002/A005/A007 范围 | 只有六源码和一产品文档变更；未改 native、deps、SDK、版本0.0.0、宏、示例或测试；无生产 DSR/读fd/7或25模式修改/全重绘掩盖。README具体说明保留条件、等宽替代和字体/宿主证据限制，没有把模型一致说成任意宿主实测。 |

数组助手的内部前置条件可由所有当前生产调用证明：每行从x0开始，合法head宽度正且不越右界，x += width跳过续格；行相等函数仅在 Frame 尺寸一致后调用，两个数组同宽。无需为不可由公开 Frame 构造的损坏Cell或私有 Int64.Max 分配添加额外API/固定宽度限额。透明 blank 的设备呈现仍为原空格；透明标记未参与旧设备等价，也未被新逻辑错误纳入。

时间/空间随该次实际簇标量和行宽增长，最多新旧两行临时投影；这是本次 A004 明许的 M1 方案。没有缓存身份、全局字形表或布局耦合。后续M2/完整094应消费此owner，不能以本审核视为那些任务完成。

## 已核验记录与复现入口

依据 AGENTS11.1 不因审核角色重跑仍有效套件；本角色实际运行的是来源/hash/diff完整性审核 `node audit.mjs`，最终 exit0。`raw/audit-initial.json` 保留初次锁文件hash不一致；`raw/lock-order-proof.json` 以相同四依赖行的排列精确重建旧SHA，证明仅 CJPM map顺序改变。该差异没有被伪报为逐字节相同。

`reviewed-sourcehashes.json` 核对全部7产品文件、77受检runtime/native/build输入、111依赖索引/源码文件、SDK/UCD/manifest、三件binary/package。`raw/manifest.json` 保存所引用原件路径/hash/字节数，raw命令/exit/输出均与作者提供的 artifacts-SHA256SUMS 一致。没有使用作者结论作为证据。

| 记录 | 原命令/真实结果 | 本次使用范围 |
|---|---|---|
| `raw/14-formal-final`（原件目录位于 glyph-advance-implementation；brief的13为目录笔误） | `bash tests/glyph_advance/run.sh all`，exit0；9 private、34 public；fixture-controls明确保留16 old failures/116完整DSR | 对固定源的逻辑投影、字节、预算、保留/替代、策略切换、公开消费者兼容。不能证明新GUI。 |
| `raw/15-bundle-final` | `cjpm bundle`，exit0；315 advisory warnings、0 errors | 正常bundle包含实际lint；不是lint零告警。 |
| `raw/17-clean-consumer-build` / `18-clean-consumer-direct` | 正常`cjpm build` exit0，再直接 `target/release/bin/main` exit0、34 PASS | 独立清包普通消费者，不使用cjpm run掩盖退出或功能stub。 |
| `raw/04-colors` / `09-capabilities` | 真实exit0，后者有NCV18与未知位合成终端分支 | 历史回归信息。pre-final→final manifest仅terminal_projected_row.cj hash变化，故未在缺少前后语义原件时把这两次冒称199 exact-source执行。最终受影响路径由166负责；静态审核已核现NCV调用链。 |
| `raw/08-colors-session` / `08b-colors-example-rerun` | 均exit1，保留 | 独立分类及stty原trace证实际100×40→100×12→31×12，而fixture提前切换Screen到31×12。与R019允许真实旧/在途pair一致；该记录不证明产品制造不存在pair，也不是把failed改为PASS。修正设施后执行仍必要。 |
| `raw/16-archive-boundary` | exit1，缺examples/composition/cjpm.toml | 既知完整composition/benchmark后续包门禁；本补丁未改变包清单/边界，不能称完整包门禁通过。 |

具体行为复现来自正式固定测试：`advance_projection_test.cj` 的20个字面保留/替代golden与负/零/宽>2/预算检查；`advance_frame_test.cj` 的双向宽head↔字面`??`、样式拆组/颜色相等、两profile切换、右缘裁剪、ambiguousWide与极空轴；`advance_device_test.cj` 的五colorMode；`advance_existing_device_test.cj` 的旧接口设备行为。预期值为手写字符串，没有把产品投影作为oracle。`tests/glyph_advance/run.sh internal` 使用普通临时同包源码+正常CJPM test，无扩大生产可见性；public直接运行普通依赖消费者。当前未发现需要追加独立反例探针的具体歧义，因此无重复功能运行。

## 技能与工程约束

实际读取并应用 requesting-code-review 的独立reviewer模板、verification-before-completion；后者按用户/AGENTS11.1复用内容相同证据，不强迫重复有效执行。using-superpowers明确subagent-stop。实际读取固定 CangjieSkills `277f2e1234ca5217496966887243c679653887a8` 的 cangjie-coding，以及 cangjie-rules `40bacab1dafc7c5710a9b14c5c5c86898feed63c` 的SKILL和STR/NAM/FMT；按脚本批量查询String.runes/fromUtf8/private-init，结果见`raw/cangjie-queries.txt`。private-init查询摘要不够直接证明语法，实际SDK1.2正式编译记录优先，未据旧SDK默认值改配置。未运行额外新门禁。每实体独立小写下划线文件、纯row函数同文件内聚、包内最小可见性/公共签名兼容均符合本项目采用规则。

## 明确未裁定范围

- 新source在真实XTerm/VTE的t/t/resize/t/q、ZWJ及VS16物理DSR/suffix/row4原PNG/恢复：属于166/167。本审核不推断其PASS，也不把尚未执行166当作165静态阻塞。
- 任意字体/宿主/Unicode版本逐标量实际推进：A003明示只用模型一致作为admission，README已限制保证；无全面字体保证。
- 完整GlyphMode/nativeVT/map/ellipsis公共接口、M2收益、全部Linux与后续平台：G012/A005指定未来任务，本7文件无越界实现。
- 既有完整包composition/benchmark缺项：保留真实失败及未来门禁，不作为本次新增源码缺陷。

原R14T083001实际FAIL保持开放。可进入TASK166；以上双PASS不替代实际GUI验收或完整交付声明。
