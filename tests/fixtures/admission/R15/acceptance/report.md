# TASK088 独立 Theme 基础验收

**PASS_FOUNDATION_SCOPE。** 固定产品 `8d75233c664fd61be08d441f74d464cbcdff2d9c` 的 AC013/025 与 AC085–088 当前基础范围可接受；未发现当前范围未关闭的 Critical / Important / Minor 产品缺陷。**T087-G01 whole checker 仍实际 exit1，最终 TASK023 release 门禁保持 OPEN。** 异步026/089、027完整控件showcase、完整Linux、M2和其他平台未通过本轮验收。

[42项矩阵](acceptance-matrix.md)逐条给出结论：37项 passed、2项限定内容复用通过、1项基础包通过而最终release门禁仍开、1项保留来源限制、1项后续范围排除。不是“42项全通过”。[findings](findings.json)与[机械投影建议](proposed-integration.json)保留这些边界。

## 固定输入与独立性

权威合同为根正式design SHA256 `084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4`，含T001–T016及末T009词法键预算澄清；BASE为 `81cd29cdf173cd02a390f3d992037de395caafaf`。087 checkout中较旧的design `e2070819…`只是历史对象，没有替代正式合同；产品包也不含该开发设计。已复用独立086完整审查、round1和cleanup closure：原I01–I03、M01已修，95→8d仅删除四行无引用helper。源码审查PASS不单独证明最终包或宿主执行。

087封存位于 `/workspace/work/theme-execution/artifacts`。本轮独立重算的index SHA256为 `8ed59a898f2e9703e6c0a7e97b7ecc2e31f2ac4c6e605dc636d6b6357dea7961`，manifest为 `4370276add7bbbf5ff55284d45532b48ae49f39c463b4d213edeb0eed020c011`。详细固定来源见 [reviewed hashes](reviewed-hashes.json)。

本角色没有读取产品作者目录、report、progress或self-assessment，没有作者通信、子代理、主仓/产品/tests/status修改，也未再运行产品。复制到独立087中的历史纯raw可以读取；其中原作者路径只是标签，未解引用。原Glyph已封存制品未改。采用verification-before-completion与AGENTS11.1内容复用原则；指定角色不等于能认证实际serving model/effort。

## 直接核验

| 独立只读核验 | 结果 |
|---|---|
| `python3 verify_evidence.py` | exit0；563份原件与副本逐字节相同、564条校验、565实际文件，无多余成员；168份strictJSON。16组命令均记录实际source/argv/cwd/UTC/exit，whole checker的1保留。 |
| 来源与环境 | 338条执行前后source/test/native hash全等固定8d；375份上游依赖源、371份官方stdx重算。25项外部环境记录中24项字节同，1项lock排序差异见下。1643项省略生成制品重新hash。 |
| 原正式执行 | values/integration实际正常build和direct binary均0，全部76正式Theme源文件对应固定Git；各次192生成输入hash核对，不复制输入大树。16旧负例按下述限定复用。 |
| CJP与clean | 实际CJP SHA256 `29ce7c64d16425c2a0f8350cb72d852a3e2a858fd423379bc0aad9fccd108fad`，121378bytes。175成员逐字节等8d及clean构建后源码；完整formal integration源不变，只改manifest依赖路径，build/direct0。 |
| `python3 verify_observations.py` | exit0；3个Glyph输入control与7个controlled profile重新核原row/字节/能力/map次数/termios/离线文件，12组真实GUI原trace独立解出write1并等stdout，再对native viewport和固定golden。 |
| `python3 verify_metadata.py` | exit0；原085正常根build0/真实缺API RED1与positive gate；复用负例公开声明、历史正向门禁、生成输入hash、正常host退出后seal及TASK023门禁范围独立核定。 |

完整结果留在本地；归档含[完整性摘要](raw/integrity-summary.json)、[观察摘要](raw/observations-summary.json)、[metadata核验](raw/metadata.json)、实际脚本/退出输出和完整结果hash。摘要省去重复成功断言，不把机械hash断言数量当产品测试数量。

公开values/integration不是声明stub：它们实际检查36typed slots、17roles、10变量种类、三态/相等/只读、来源/状态/Reset/继承、三种fill与RichText explicit mask、四边padding、实际Row/Column分配宽wrap及自然高、全部schema类型/引用/诊断/预算、四preset独立手写Frame。原I01/I02诊断优先和I03两个拒绝setter的binding保护均在最终正向执行中重验。仅样式/presence改变导致实际Frame更新，不把未来主题异步提交算入本轮。

151个encoded-key追加输入属于192份生成输入整体：6上下文、11拼写的1024/1025、103次转义与直接字符、value/comment控制均走真实上游Lexer/Parser及正式断言。到边界进入预期UnknownKey或SyntaxError仅证明预算放行，不被误写成合法schema。源码与独立086证明单一声明/resolver/Runtime/LayoutNode/Frame和上游Parser权威，无第二渲染或TOML路径。

## 实际宿主与复用限制

XTerm398与XFCE1.1.4/VTE0.80.1各执行四preset基本x/y场景，另各执行Glyph Ascii/Unicode；合计12张原PNG。实际Xorg私有display为`:187`（preset）与`:188`（Glyph），80×25、DejaVu Sans Mono12。两个普通公开消费者binary SHA256在逐host launch与当前ELF中一致；Glyph main与正式fixture逐字节相同，没有syscall wrapper。实际trace/原native屏幕证明width0..4的空、`.`/`..`/`...`/`A...`与Unicode前缀；真实80列Row空间不套用5列controlled fixture期望。

12组product/host exit0、termios恢复且host及Xorg在seal前退出。[视觉记录](raw/visual-inspection.json)包含6张直接查看的代表原图与hash；全部12图均核hash及native输出。VTE提供真实viewport文本而非完整cell属性；XTerm自动基本色投影与VTE RGB路径不同。Unicode显式override中的ZWJ物理shaping仍依宿主，不扩大为所有字形advance保证。基础场景不等于027全控件/窄屏/交互showcase。

7个mapped/unknown device profile里的字体map是明确合成分支，不是真实kernelVT。缺marker场景实际输出`A... → ABC… → A...`，没有错误的`ABC?`；同值setter无多余row写入，原runner的measure/mount断言实际成功。post-run默认/Auto文件保持Unicode，Ascii只改变生成marker，业务文本未被设备替换污染。R16的274个未变backend/test对象及39张原PNG只复用既有kernel/font/恢复事实，不用来证明新Theme布局。

16个编译负例复用范围是未变的公开类型与访问限制：每份fixture与固定旧085字节同，原stderr确为真实type/access错误，exit1且原values/integration正向门禁先成功。五个相关文件公开声明去注释后不变；最终8d正向消费者另有新执行。**C1产品输入hash是在执行后取得，旧compiler没有pre-run二进制capture。** 本验收接受上述证据组合的有限复用，未声称负例在8d重新运行，也不追认不存在的历史执行前身份。

旧contract/layout/decoration/runtime-core/RichText按95的201项执行前来源复用：200项等8d，唯一差异是decoder四行未用helper删除；相关测试不变，受修复影响行为已在最终正向重验。早期95 bundle成员记录没有冒充本次实际8d包，当前175个CJP成员已独立打开检查。

## whole checker与metadata裁定

T087-G01实际首错是`Development/unexpected file in bundle: themes/light.toml`。固定checker的allowlist没有`themes/`，而T010明确要求交付四个canonical主题。逐实际包检查确认这些文件是要求的产品内容，其他175成员符合正常产品边界、依赖不逃逸包、不含SDK/cache/target/CJO或开发资料。正常bundle exit0且491条mandatory lint warning保留；本轮没有改checker、跳过lint或把其exit1改成成功。

独立范围裁定依据是当前T012/AC087要求“正常bundle及干净SDK/stdx公开消费”，现有证据满足；`complete-linux-integration/tasks.md`的023.a明确规定为缺themes/showcase/benchmark等更新checker负控，023.b–d负责完整release接线与逐文件最终验收。composition与rendering benchmark实际仍缺。因此本轮基础可通过，**最终TASK023仍OPEN，不存在fullrelease通过**。此判断来自合同与实际包，不以root或执行者分类为前提。

T088-O02：`environment-artifact-hashes.json`的早期`product/cjpm.lock`为`d39e3d166dde08c5412838a6ff34fdfa931e0c40fb566e7fac670a9cb0086ee9`，最终fixed-source/current为`a29edd7f2ac024e90fc03c1e314ef0f054c9b1c2e7021176cc425d6a8ee3e6cf`。独立枚举相同五条完整requires记录的120种排列，唯一旧hash匹配，证明仅顺序差异、精确版本未变。原metadata未重写；这只是顺序等价证明，不是恢复了旧原始lock或历史pre-run证据。它不构成产品功能缺陷。

自身核验的第一次失败来自正式runner source-hashes也收录build-script-cache，不能全部当Git tracked文件；修正后76正式文件完整核对，额外缓存记录单列。第二次严格环境hash核验发现上述真实lock差异，保留原失败脚本/输出并单独证明，不静默忽略。没有修改产品、原oracle或期望使结果通过。

## 交接

可以机械记录固定AC013/025及AC085–088基础接受，并继续符合前置的后续任务；不关闭T006–008/026、027、TASK023、fullLinux或M2。根目录`report.md/findings.json/acceptance-matrix.* / reviewed-hashes.json/proposed-integration.json`为最终文件；`preparation/`保留原NOT_ASSESSED历史。

轻量归档目录为 `/workspace/work/theme-acceptance/artifacts`；包含报告、矩阵、独立脚本/结果摘要、失败记录及hash manifest，不复制SDK/stdx/CJP/ELF/checkouts/整份合同/生成输入/旧raw树/PNG。原图回指087封存原件。`artifacts.sha256`覆盖所有归档文件（自身除外），[manifest](manifest.json)记录外部依赖及省略大件hash/理由。
