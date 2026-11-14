# M2 rendering and public benchmark implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL superpowers:subagent-driven-development；按用户指定独立测试/产品/审核/执行/验收五角色连续完成，主代理只负责契约、集成与分歧处理。本文作者不执行下列产品任务。

**Goal:** 完成TASK-031真实局部布局/绘制与TASK-022公开可重复基准，保留完整M1 oracle与Linux全部完成目标。
**Architecture:** RuntimeNode持久缓存、同一LayoutNode measure/arrange/paint、整行damage、Frame行COW；精确失效与完整合成、成功输出baseline分开。M1临时计算不污染M2。
**Tech Stack:** SDK1.2.0/CJPM、正常cjtui源码制品及已冻结依赖；现Unicode/ANSI/Style唯一核。
**Spec:** design.md第14节最终裁决优先；三个specs；REQ-004.8、AC-031/022、AGENTS11/13.2/14；工具微证仅作诊断可用性证据。

## Global Constraints

- 原TASK-031/022为完整验收责任归属；123–142实现031各单元，143–147实现022并供031成本验收。实际工程层级依原WP002/WP005，角色工作为独立L3，不把原L3强行嵌另一套L3树。主仓接入时031/022转为本tasks唯一状态引用，不能保留两份勾选权威。
- 单元A/B/C123–137已独立接受；138测试已固定，139实施中，140–147仍planned；有上游合同不等于上游产品已通过。正式产品124前必须冻结全部功能M1源码/制品及下表最终SHA；禁止提前用c3d743d有限功能作性能基线。
- A→B→C→D→E顺序集成。测试可按冻结合同准备，但产品只消费前单元验收固定提交；共享Component/Layout/Frame禁止多个产品作者同时编辑。
- 每实体一个小写下划线.cj文件，最小可见性，原public调用兼容，新增RuntimeStats三项仅只读；无私有测试hook、无强制M1/M2模式开关。
- 测试作者Sol/high、产品Terra/high或适合仓颉任务的Sol/high、审核/验收Astra/high、执行Sol/medium；记录指定配置，无法核验serving时不冒充实测。
- 角色只交接合同、固定源码/测试SHA、公开命令和原始证据，不交产品作者自评。验收按原AC及实际工作量/CPU/分配/输出，不以测试数量代替。
- 不publish、不改共享SDK/seed/cache、正式基准不依赖探针或开发目录；正常CJPM和普通bundle消费者不可skip。

## Admission Inputs

实施准入由主代理填写并固定下列manifest；任一未填写/未通过则相关产品任务仍planned。此处未知来自尚未完成的实际产品，不虚构SHA。

| 输入 | 合同来源 | 正式产品固定SHA/证据 |
| --- | --- | --- |
| Runtime A+B/C | reactive-runtime R001–019、单序列C | Runtime075 `0912436b647f701e1de607fe03ce1bfba6a9bbf4`；Runtime080 `216b2ab5f2315f4be19467b7e49f4047aec78ab9`；统一M1源 `d654ae59`，详[公开准入记录](../../../docs/reviews/Linux-final/m1/admission.json) row1。 |
| RichText | implement-rich-text冻结design | RichText084 `199f00076c1a79cfa6d0be92e7be09366e1a06af`；统一M1源 `d654ae59`，详[公开准入记录](../../../docs/reviews/Linux-final/m1/admission.json) row2。 |
| 主题基础/加载/展示 | T001–015及后续正式修订 | Theme088 `8d75233c664fd61be08d441f74d464cbcdff2d9c`；Theme092 `fa6a46ec339ea0f098dea521c814226a7a373c7e`；AC027 `b5de3dd6610e90fcdcd951c5703a1429ec13b417`；统一M1源 `d654ae59`，详[公开准入记录](../../../docs/reviews/Linux-final/m1/admission.json) row3。 |
| Canvas/焦点/viewport/overlay | 主代理采用interaction合同，含root Vertical有限布局fallback | InteractionA102/I011/I012 `f8a028b39daf8a341576f304335d262544b9cca5`；ViewportB107 `62039552a26da295dcd710d7cfc40cb9e43ca5fd`；OverlayC112 `7f43176505aa3c392afc5fc897181a9eeba89e6e`；统一M1源 `d654ae59`，详[公开准入记录](../../../docs/reviews/Linux-final/m1/admission.json) row4。 |
| 输入编辑/标准控件/应用示例 | 原017–021/028–030/037等完整Linux公共功能 | Keyboard117 `c3c4642d84df57bbd9550d222ed22f602acd13ef`；Finite editing E122/current combined input `22ca8cf7c756c5185064a6f8bc7e9f2c58d4f167`；S157 `1df1325f7b51777d8adab62f950c936051aa5876`；M162 `6e3f26aaaeee9442fde91ce31d720a841eeda473`；Session152 `83094ca92acab37ed0a38042e2e40ead55049f41`；AC021 `c190e6f957a18f47be2f329a40cf444d9985cb6c`；统一M1源 `d654ae59`，详[公开准入记录](../../../docs/reviews/Linux-final/m1/admission.json) row5。 |
| Frame/Unicode/装饰/输出恢复 | 原005/007/008/011/012/020功能M1证据，以及041已冻结M1 Linux设备/ABI/输入输出/尺寸/恢复子接口证据；完整041最终全组件/M2/全部宿主验收后置 | R10 `8af39f6c8882772b946ae1d9507361f8a6082388`；070 `5c2a7e7d956b5d8c0284e96514276608616bf8a6`；Glyph097 `1f67e27358254e9daef637b5c2f5a93707ee7cef`；AC008 `80d21e071537898cde27f1c7de4328ab6f27d991`；AC010 `13e7880ce96d1331fc9e12a2b62275a307183e9a`；AC020_M1 `e35d407a87ab197537ccc931c143c9927458a75f`；LayoutDecoration057_054_060 `40aa4db6c2b7673bb3e8c9a80fdb5b4e385cb940`；LinuxNativeFirstSlice053 `2ad6c5ceeb0068d3b2b2d5efe010059965b9415a`；统一M1源 `d654ae59`，详[公开准入记录](../../../docs/reviews/Linux-final/m1/admission.json) row6。 |
| 完整M1性能基线 | 全部功能齐全、M2实施前 | AC021 `c190e6f957a18f47be2f329a40cf444d9985cb6c`；AC027 `b5de3dd6610e90fcdcd951c5703a1429ec13b417`；AC008 `80d21e071537898cde27f1c7de4328ab6f27d991`；AC010 `13e7880ce96d1331fc9e12a2b62275a307183e9a`；AC020_M1 `e35d407a87ab197537ccc931c143c9927458a75f`；统一M1源 `d654ae59`，详[公开准入记录](../../../docs/reviews/Linux-final/m1/admission.json) row7。 |
| 本候选 | design14与三个spec、独立preflight/DQ | M2_preflight（固定证据映射）；L005_planning_preflight（固定证据映射）；统一M1源 `d654ae59`，详[公开准入记录](../../../docs/reviews/Linux-final/m1/admission.json) row8。 |


当前正式冻结：普通CJP `29cab0f8de79a3b42ebc6a8bf7e2c2648217b565ccbc0e03f77f4cb915852c7a`，独立准入索引 `c1f7320ae7e5a1659ba83fee2f9083566cdf688d5f5585941ad2a8b8f05972b5`，041.a仅M1设备输入已固化，完整041保持开放。[原件及旧包](../../../docs/reviews/Linux-final/m1/README.md)保存原始准备、身份补充与固定SDK/deps/native/ABI。123正式tests `34240845e4bf393cc5d83475a2c9860a8de10f0e`/index `345ff318bc070a8535858e087fe44d605c1cec11c62354c58389698d5a828f64`：原行为6项GREEN，Canvas窄reference替换持久draw订阅为真实RED；新三统计缺API为真实编译RED（29条均属缺字段）。该Canvas失败属于124/M004明确修复义务，保留冻结M1原件，不伪称所有baseline用例GREEN。124按A固定合同实施，125–127独立质量门后才关闭本单元。

## Review Focus

1. 同宽文本/颜色/Canvas caret-only变化不得触发无关measure/arrange；依赖相等不丢订阅，显式notify不被吞（123/133）。
2. Row flex/Column sibling/wrap/root fallback/viewport clamp连带既不能漏，也不能靠全树重算隐藏（123/133/138）。
3. Frame共享别名、零面积虚拟大轴、透明孔/StyledSpace、自合成和宽簇伙伴仍R11/F003（128/138）。
4. 隐藏/卸载/阴影/滚动/层关闭清旧画面，重合成底层最新值；cached caret的真实opaque遮挡与grid变化独立（138）。
5. 任意old Frame/profile/输出失败不误用damage；paired frame同业务epoch，计槽容量不冒充heapbytes（128/138/143）。

## Tasks

- [x] TASK-123（testing/A）：冻结共享算法重构的公开行为/统计消费者及可复现正常基线。
- [x] TASK-124（implementation/A）：同核measure/arrange/paint分离、M1独立临时结果、三统计真实作用域。
- [x] TASK-125（verification/A）：固定124与123独立spec/quality审核。
- [x] TASK-126（testing/A）：自有工作目录独立执行A公开消费者及受影响旧布局/主题/Canvas证据。
- [x] TASK-127（acceptance/A）：验收算法单核/参考隔离/统计真实，不提前声明M2。
- [x] TASK-128（testing/B）：冻结Frame COW别名/宽簇/透明/任意baseline与真实分配槽观察用例。
- [x] TASK-129（implementation/B）：Frame私有行共享/脱离及精确行身份比较；保留通用慢路径。
- [x] TASK-130（verification/B）：固定129与128独立审核含所有写入口/零面积/来源证明。
- [x] TASK-131（testing/B）：独立执行受影响R11/F003、旧快照/输出及公开计槽消费者。
- [x] TASK-132（acceptance/B）：验收共享正确与Cell分配变化，不把存储优化当局部布局完成。
- [x] TASK-133（testing/C）：冻结dirty/约束缓存、布局连带、相等结果/notify/ForEach/manual/主题/Canvas依赖公开证据。
- [x] TASK-134（implementation/C）：节点级Content/Style/Layout/Structure、bounded约束缓存及依赖传播。
- [x] TASK-135（verification/C）：固定134与133独立审核所有失效入口/缓存key/版本消费。
- [x] TASK-136（testing/C）：独立执行局部measure/arrange与M1逐帧对照、生命周期/顺序/主题回归。
- [x] TASK-137（acceptance/C）：验收无关计算减少及连带完整，局部合成仍待D。
- [x] TASK-138（testing/D）：冻结整行damage相交重绘、滚动/层/宽簇/caret/失败baseline组合证据。
- [x] TASK-139（implementation/D）：局部合成目标、旧新bounds、缓存caret/层来源及后端安全消费。
- [x] TASK-140（verification/D）：固定139与138独立审核draw上下文、重放顺序、目标/显示提交分离。
- [x] TASK-141（testing/D）：独立执行逐帧Cell等价、设备故障/恢复与真实适用TTY输入输出。
- [x] TASK-142（acceptance/D）：验收局部渲染功能完整；成本证据等E，不提前关031。
- [ ] TASK-143（testing/E）：冻结公开benchmark场景/动作/同epoch配对/CSV指标/干净消费与计量方法。
- [ ] TASK-144（implementation/E）：交付benchmarks/rendering正常独立CJPM与产品方法说明。
- [ ] TASK-145（verification/E）：固定144与143独立审核公平性、纯公共API、数据口径及制品边界。
- [ ] TASK-146（testing/E）：独立运行重复headless、真实TTY/输出、M1/M2普通包双版本、CPU/分配/退化与干净bundle消费。
- [ ] TASK-147（acceptance/E）：逐AC-022/031核原始结果与限制，完整通过后回写父任务并继续023/024。

## Task Cards and Checkable L4

所有角色任务classification=execution（主代理已裁决路线），workflow本tasks，change本目录。测试/产品/审核/执行/验收分别独立交付且顺序：test→product→review→execute→accept；反馈经主代理，必要新反例由测试作者先固定，再原产品作者修复，审核定点复核。适用skills：主代理brainstorming/writing-plans/SDD；测试/产品TDD与cangjie-coding（SDK实际语法优先）；故障systematic-debugging；审核requesting/receiving-code-review；执行/验收verification-before-completion。实际使用与来源在角色证据记录，不把技能存在当实际完成。

### A / 123–127（父031，REQ004.8，AC031正确性与参考边界）

文件：123新增tests/incremental_layout公共CJPM消费者、README/run.sh与每实体helper；124修改src/layout.cj、layout_node.cj、runtime_node.cj、runtime_session.cj、runtime_stats.cj及必要已冻结Canvas/layout接口；新内部计算记录各独立文件，命名/可见性先SDK编译。只读新增精确接口：RuntimeStats.arranges/cellWrites/frameAllocatedCells:Int64；其构造仍内部。

输入：完整M1冻结包、现公开render/snapshot/stats及全部布局/主题/viewport合同。输出：M1完整结果不变、同核拆分与真实统计，供B/C复用。

- [x] 123列出手算布局/来源/Canvas场景固定期望，已记录原行为6项GREEN、真实Canvas reference隔离RED与新统计缺API RED；不伪造内部实现测试或掩盖既有缺陷。
- [x] 123冻结test-only SHA及普通CJPM构建/运行命令；统计断言按真实调用/实际Cell分配点含初建，不按实现源码生成预期。
- [x] 124把paint内分配移到唯一arrange，Runtime节点承载唯一顺序引用；完整render用临时表而不建第二组件树，snapshot仍正常目标链。
- [x] 124实现三只读诊断及生成/副本作用域，外部snapshot后续修改不回记；保留原八字段定义与生命周期。
- [x] 125审核fixed base..product，覆盖M1稳定绑定与缓存隔离、root有限布局fallback、Canvas独立依赖不被参考替换、单核/退役与每实体文件。
- [x] 126在独立checkout用普通cjpm build/直接binary真实退出执行123；按变化复用/补跑旧布局/主题/Canvas/生命周期证据，无关旧套件不重跑。
- [x] 127按原输出、源码单核与计数原件验收；记录本阶段尚无局部性能承诺。

### B / 128–132（父031，REQ004.1/.3/.8，R11/F003）

文件：128扩同测试项目Frame公共消费者（不改旧断言）；129修改src/frame.cj及必要私有frame_row等单实体文件、终端比较接口内部实现。Cell/Style公开只读值不改；不新增第二Frame类/Unicode。

输入127固定产物和旧Frame完整语义。输出同Frame不可变行共享、实际分配槽计数、任意比较正确fallback。

- [x] 128固定源/副本双向改、自composite、半簇、透明hole、StyledSpace、负偏移、改宽/高、预算与零面积极值场景；计量观察完整snapshot共享及第一次/重复写不同作用域。
- [x] 128记录基线功能GREEN与真实“copy逐Cell分配仍存在”工作证据，冻结测试；不为内部存储类型造反射hook。
- [x] 129将所有实际Cell存储分配统一计槽；所有写入口含clearAt/伙伴写按行脱离；full copy共享、subrect等允许正确慢路径。
- [x] 129终端比较仅在冻结行身份/profile及精确版本关系适用时排除行；任意old Frame/外部修改/截断lineage回退完整正确比较。
- [x] 130审每写入口/源别名/共享不可变/零面积不建巨量目录，以及damage不能覆盖后端失同步。
- [x] 131独立执行128与受影响R11/F003/文件/后端消费者；132按原件确认正确性及计槽口径、性能热路径分配下降，仍不关031。

### C / 133–137（父031，REQ004.8/002，C/主题/Canvas合同）

文件：133扩tests/incremental_layout；134改runtime_node/session、binding结果提交、layout/node及theme resolver/Canvas依赖的已冻结接缝；必要node_dirty/measure_key/measure_result各实体文件。禁止第二children列表/第二resolver。

输入132；输出分类dirty、约束缓存、受影响measure/arrange集合及新旧几何。

- [x] 133准备常量替getter、typed相等、notify各类别、ForEach keymove/manual、hidden→visible、纯span样式与文字、theme mask/fill、Canvas M/P独立失效；每批同root稳定M1对照。
- [x] 133覆盖Row flex余数与兄弟重分配、Column后续/justify前后移动、宽wrap高度/四pad、root fallback与viewport clamp；固定能证明无关工作为零/减少的树形场景，不给凭空时间阈值。
- [x] 134分开待求值与真正有效输出dirty；Content/Style/Layout/Structure不互相吞并，只有成功目标消费当期版本。
- [x] 134有界intrinsic/实际约束缓存，位置变化复用文本测量；隐藏待算失效保留；依赖传播以真实输出/输入不变截断，不仅比父大小。
- [x] 135审核缓存key、source mask/fill、独立Canvas依赖、真实C序列、cutoff之后通知与GC订阅资源；136独立执行133及相关生命周期/主题组合；137确认局部布局成立，paint局部仍待D。

### D / 138–142（父031，REQ003/004/009，原008/018/020/037组合）

文件：138新增tests/incremental_composition公开消费者及适用已有设备故障驱动组合；139改layout/Frame/runtimeSession/application的既有合成与设备目标接缝，新增damage_rows/paint_state等单实体记录。测试驱动工具不进入生产。

输入137、完整008恢复及交互产品；输出完整M2目标、整行局部绘制、正确caret与baseline。

- [x] 138冻结长→短/移动/隐藏/卸载/阴影、背景移除、透明hole与StyledSpace、目标宽簇伙伴、滚动/anchor、nested modal close/下层后台最新值、caret-only及opaque同字符遮挡。
- [x] 138用受控Canvas记录draw次数和可观察clip，证明相交节点每目标至多一次、上下文不随damage改变；全量M1另运行不混计。
- [x] 139以旧新paint bounds并集形成整行带，清初值后全场景顺序重绘相交前后节点/层；subtree bounds含后代阴影，不只dirty节点。
- [x] 139缓存未draw节点caret请求、按焦点/geometry/层opaque覆盖重算；设备grid零差分也输出caret变化，输出成功才提交组合baseline。
- [x] 140审未知lineage/profile、partial write/resize、缓存clean但设备失同步、异常清理围栏；141独立执行138与008受影响恢复矩阵/真实适用TTY；142核M1逐Cell等价与交互caret结果，保留E成本前置。

### E / 143–147（父022并供031，REQ006/NFR05/AC022/031）

文件：143冻结基准输入场景/预期/CSV合同及公开可消费性检查（tests/rendering_benchmark）；144创建benchmarks/rendering/cjpm.toml、src/*.cj每实体文件、README.md，产品说明docs/product/rendering-benchmark.md；制品白名单已有benchmarks，核实实际包而非只看配置。

输入142与完整M1冻结普通制品。输出普通公开benchmark、原始重复数据与方法，供023干净最终制品消费。

- [ ] 143冻结80×24/160×48混合Unicode、各类变化/横向同行代价/全局退化动作与业务barrier；正确性按完整Cell+独立caret断言，性能不运行oracle/equality/hash。
- [ ] 143冻结CSV列的单位/范围：measure/arrange/paint/frame/cellWrites、frame_allocated_cell_slots、CPU user/system、wall、heap/GC/RSS、成功输出bytes/calls、环境/源码/seed/尺寸/重复编号；缺某采样工具记录实际限制，不自动取消其他必要证据。
- [ ] 144按M013交付同源compat correctness/snapshot-headless/tty双版本入口，以及最终库专用correctness/m1-headless/m2-headless诊断入口；冻结资格表并拒绝不支持组合，库无测试模式；外部计量不进入运行依赖。
- [ ] 144说明旧M1制品与最终M2制品正常CJPM构建并核相同业务/完整帧，记录普通bundle/依赖/SDK前置；原八统计之外新增三计量口径与未覆盖成本公开。
- [ ] 145审公平性、M1 oracle GC污染、错误状态配对、伪TTY/伪allocated bytes、工具退出0但无有效数据、选择性汇报与产品制品边界。
- [ ] 146独立执行足够时长/重复的分进程CPU与Cell存储分配，SDK heap/GC/RSS补充，单独真实TTY输出采样；报告所有重复、分布及噪声，不只best；干净目录从普通cjp构建并运行。
- [ ] 147逐原AC记录代表局部负载无关工作/实际成本减少与全局退化；计数下降但CPU恶化须解释，不以通过个数宣称收益。所有功能、方法、资源与制品证据足够后才关闭022/031，其他Linux任务继续。

## Quality and DQ Exit

canonical owner：RuntimeNode身份/dirty/cache，唯一LayoutNode算法，Frame单一簇/透明/存储，终端后端显示baseline，benchmark自身输入/量测。旧每目标全树清dirty、paint内分配、第二短命几何权威、逐Cell full-copy热路径与无条件全frame比较在相关单元退役；通用fallback保留并明确场景。所有公开/持久数据兼容，无业务数据删除/迁移。

DQ预检核25编号唯一、原父AC未缩小、冻结输入可定位、每单元真实可验/不重叠写文件、统计语义可手算、纯公共消费者与普通制品命令、故障不被缓存跳过、角色独立。当前为可冻结候选，主代理接入OpenSpec后独立preflight确认DQ再将具体任务ready；本稿与探针均不是正式测试产物或产品完成证据。

### M011/M012追加准入与L4

Admission新增Glyph G001–G011及097实际接受SHA。133增加Unicode/Ascii/Auto交替cache handgolden，138增加同投影零输出/旧新profile，143同模式同epoch配对。124前仅冻结完整功能M1库cjp及source/deps/native/SDK；143/144基准源后置，不再要求其作为124的不存在上游。144新增`benchmarks/rendering/{compat,workloads}/cjpm.toml`及各自src，compat/workloads与新库专用诊断入口分包，无private编译参数/生产模式开关。143→144→145→146在142之后，146前freeze相同compat/workload代码并对旧/新cjp正常构建；旧库缺三Stats记not_available，真实新三诊断只从最终库专用入口取。

### L005：041最终汇合不反向阻塞M2输入

主代理据独立范围审计修正Admission：124冻结的是全部功能M1库、SDK/deps/native及真实M1设备输入证据，不要求尚含M2最终矩阵的原AC041完整passed。123–147消费已冻结的041 M1子接口；完成M2后原041再随全Linux宿主矩阵最终验收。原041任务/AC保持pending到完整证据具备，不缩减其范围、不新增生产模式，也不把这一规划裁决当产品通过。此消除“041完整最终验收等M2，而M2等完整041”的语义环；沿总计划L002分阶段输入原则，008/020在M1阶段的实际恢复条件仍必须满足。

## 2026-11-14 当前实施状态

单元A123–127完成并独立接受：源码 `4f7e853f821c334318e2038d4e20ab26e72c16c8` → main `0f83f73d`，正式9例独立构建运行通过；127 `PASS_UNIT_A`，12条件通过，索引 `a47adf3f2aa3311fd7fdb810869428c6f4094d14c1f888c4bf70f3e7936d6272`。[原始证据与范围](../../../docs/reviews/R24/A/README.md)保留125/126及CJP `56a7318d7931490545ee5fd255628170ed0bdc32aca71a11bc549955cfa53b49`。Q1内部临时Frame owner清理为非阻塞观察，交129涉及相同Frame生命周期时处理。

128正式测试 `9908551d206922d0083711abbc70738c60da9215`/index `c9538b0eea0d6cae5e1c9ee5e4c491ae1254481cd5c35f255abf6f41c37b145f`：7个公共正确性GREEN，未变snapshot分配48/48槽而COW要求0/0为真实RED；原9例字节不变并复用A126有效证据。随后129完成，最终证据及130–132质量门结果见下节。公开实际API为Frame.copy/resized；私有backend任意old/profile比较明确由现有output_recovery夹具与130/131覆盖，不增加public测试hook。D–E/完整AC031/M2/Linux保持开放。

## 单元B完成与C测试准入

单元B128–132已独立接受：固定源码 `275149c274df41d38ffc950f104b31185dea19a7` 由 main merge `bacfa0ba7b25e357636bc21942e2b6e415d2ee07` 保留原提交；合成树与受审源码、native、构建配置、产品文档及全部既有增量测试逐字节一致。130源码规格/质量通过；131自有正常构建与公开7例、计槽检查、后端正常5/补充45例通过，覆盖4→2→4尺寸及RGB→Monochrome。旧A9/布局/合成/文件/full338故障/正常bundle仅在源码、依赖、配置与原件比对后复用。132 `PASS_UNIT_B`，12项要求满足，索引 `2bb0a7a5b7946027feca8b4bba2a83c82341d84e71b17bca0cc70d1a91528a5c`；缓存snapshot的Cell槽从48/48降为0/0，变化目标从72降为24。任意old/profile回退和owned-detach有源码证明，不冒称单独运行测量；不把槽计数当CPU/heap字节或完整M2收益。

133已准备19个公共场景，原测试提交 `c23adbd63afea032c184bd876e57b3eeeb15ba27`，现在消费已接受B源码进行正常构建、正确性基线与实际工作量RED验证；最终测试已固定并准入134，原准备阶段的源与诊断仍保留，详下节。D/E、AC031/022、最终宿主矩阵及023/024保持开放。

### B证据归档与133最终准入

[B完整证据](../../../docs/reviews/R24/B/README.md)以19个检出文件保存8,607个原件成员，raw SHA `7671c1ac21c81144a7303b4be358438218746ff941e768025d5bdff2f58ba8c4`，归档索引 `6a2fe776a27805082789319e9a3c02246f1a2488684187bdfb910f099dc0baea`；主代理逐成员核验安全路径、字节、权限及SHA，零不符。

133固定测试源码 `d901cf39292230c11abbe1c1958126b123fb1794` → main merge `ca7772dfc24ef79f252c381c6a3219130a8559c0`，仅新增27个测试文件、产品源码与既有测试无变化；索引 `93d591fd0c7ca2735206d0018bbd60872348a501b2a57406213e885a2b34ad82`。正常build05退出0，直接run03退出1：19个正确性场景、90组完整Cell/手算配对均通过，10个场景共27项C工作量断言为真实RED。编译诊断与原始run01/02、格式整理前索引均保留；纯函数辅助按内聚职责合并，函数/断言/场景不变，最终stdout与run02逐字节相同。旧235运行文件曾被正常重建替换，原hash作为历史记录而非当前物理文件，最终ELF与测试清单另行核验。未冒称新的解包消费。

134由独立Terra/high按C1有效失效/C2约束缓存与连带/C3最终验证三个私有步骤连续实施；只有完整产品通过135源码审核、136独立执行、137验收后才关闭C。D/E及原022/031、最终设备矩阵、023/024继续保留完整范围。

## 单元C完成与D测试准备

134–137已独立接受，最终固定源码 `ee84e7ac7a35bb6481a17ecb91f1ec07804b672a` 快进合入main。135首次审核5项问题，第一轮修复关闭5项并发现2项新回归，第二轮定点复审关闭余下2项且无新发现；没有把首次19例通过当作完成。独立测试追加5例及2例，固定测试 `4845df24b33f75432d26a68fb0b844abbb4e8528`，原19/24断言字节不变。136自有正常构建和直接运行均退出0，26例正确性及工作量断言全部通过，101组完整Cell配对及附加手算/直接检查通过。136索引 `ecf8ee2741d96c4302426e84a3adf7a212d9ebf8bf8ea74179b351f2b8519ed8`；137 `PASS_UNIT_C`，12项要求满足、零阻塞，索引 `fa9af11a8406da756139346488bb08859d5972806980f8dc97a7f89975d6878c`。

正常bundle含默认tests/lint通过，默认发现0项测试不充当行为证明。A7/stat2复用同最终源码的实际执行记录；Frame COW复用R1结果前核对Frame/测试字节、叶Text根且不调用ensure/style的路径及原始ELF见证。自定义Canvas最终约束实际measure漏计已修正，通知容量按源码证明为每节点有界元数据，不冒称运行期队列容量采样。有限/实际约束缓存、有效输入/输出截断、默认根溢出摘要、失效版本与可见/隐藏处理均在本单元范围；暂不声明CPU/heap/GC/RSS或端到端性能收益。

138已在独立工作树准备测试源码 `fa4354173a78aa1751acc5c2c840619f297d4fa6`，尚未正常编译/运行；下一步消费已接受C源码完成公开局部合成反例基线，再准入139。D局部绘制/光标/覆盖层与E真实基准、原031/022、最终Linux宿主矩阵及023/024保持开放。

[C完整证据归档](../../../docs/reviews/R24/C/README.md)保留339个原件成员、三份不同候选源码制品、首次审核失败与两轮修复及最终独立执行/验收；仅32个检出文件。raw SHA `3c71f72ea247fc2129e35cd1b20bc91a48572afbcd2ef56b7013aad4e7187e4e`，索引 `e77b1ba2a5261315b20b59c1da537b7120a58d30edbe9f1d88cce89ef15a5cd3`，主代理逐成员核验安全路径、字节、权限与SHA一致；无新终端PNG，因本轮为无终端的布局单元，最终宿主效果图仍由Linux矩阵交付。

## 138最终测试准入与139实施

固定D公开测试 `0ab2536475c142a0731a34d4112d719c75b2a3ad`，索引 `042e3789e165c2e0e542b49227cc90fad539f110c4fc3790d1080c61601d8222`；正常CJPM构建退出0，直接基线退出1：15个领域、68组同epoch完整Cell/手算配对正确性零失败，14项工作量真实RED（行重放2、显隐/移除6、缓存caret6）。首次fixture默认ScrollView抢占Canvas焦点的设置已显式修正为不可聚焦wrapper，断言不变，两次构建/运行原件均保留。主代理核验34项源码/证据、ELF及锁文件字节，并确认合入只新增20个D测试文件、C产品与原A/B/C测试无变化。

139由独立Terra/high在独立工作树实施D1损伤边界与版本、D2局部重放与caret/遮挡、D3后端失败围栏与正常包。140审核、141独立执行与适用真实TTY、142验收后才关闭D。138的设备故障/投影私有覆盖显式映射既有output_recovery/glyph fixtures及后续源码证明，不冒称本轮运行过；没有新增产品测试hook。E真实基准、完整031/022、Linux最终宿主矩阵、023/024继续开放。

## M013 计量方法独立预审与E准入补充

独立Astra/high源码与方法预审为PASS，未运行构建或性能测量；此结论不等于143–147通过。§11及rendering-benchmark spec已同步：主要旧/新普通包同源snapshot对照保留全部非idle矩阵，同库参考计时仅限输入等价资格表；idle走正常run。143须冻结全场景/模式覆盖、动作/epoch、schema、窗口/生命周期/Frame保留策略、独立geometry/caret预期和不支持组合的非零失败。145核这些边界与正常包隔离；146执行完整表及所有重复/负面/全局数据、独立真实TTY输出；147按原AC022/031核实际成本。D142固定输入和根代理容量准入不变，源码准备不冒称正式测试。

### D根组件显隐补充测试已冻结

独立测试提交 `16b9f25dcef0f7d163a7651bf2617d6d3a14b13a`、索引 `04bf90e9d7527eca88805f2323771a21441d59fdac2656632c8e690aa2289199` 在原C基线上正常构建0/运行1：16领域、71组完整配对、正确性零失败，18项工作量RED。原15用例及产品字节不变；新增3×1根Canvas在8×5帧隐藏/恢复，回调1/0/1及上下文正确，hide slots/writes=40/40、show=40/42，使新增4项整帧代价断言真实失败。源码/配置/原始结果/ELF由主代理核验；139已接入固定补充测试，尚待最终正常包、恢复验证和140–142独立质量门，不能标记D完成。

## 单元D完成与E正式测试准入

139最终源 `f48ca45608247f52a6876ad5c27b4ca36867f406` 已由142独立接受并合入 `cae9e743`，139–142完成。142为PASS_UNIT_D，15项要求零阻断，索引 `19b9fc0ef2bd4fe4dc1f6280b9b26687bd4e22a2ead724f396a17a6cd06fecfa`；140完整审核发现跨损伤行的遮挡caret恢复错误，独立测试 `df679c58` 实际RED后修复，限定复审索引 `d36cec40cf929587ba777ae21838f9ccd756c28bdd49dad77ef9db8457fd0cda` PASS，初始失败与修复历史保留。

141独立执行索引 `159189b07c8348e1289f7ed23e284e95d375f0ba7bf069bc041055d09ae842eb`：同源公开17领域/74组完整Cell配对零正确性及工作量失败；当前源native PTY普通5、补充45、完整故障切点338均零失败。实际XTerm398与xfce4-terminal1.1.4/VTE0.80.1各10张最终原始PNG，编辑/模态关闭与焦点/80×24→100×30→80×24缩放/F10退出及termios恢复通过。VTE默认F10被菜单拦截的失败保留，成功轮使用已核实的隔离ShortcutsNoMenukey配置；仅代表已测配置。

正常包 `1110d0ffbb626a8bda6f3daa67daf0198688aa0b59cd795f1a2da2e0f27dee0a` 默认测试/lint成功，解包17领域、Frame baseline/cow各7领域有效同源原件复用；205包成员经独立核对等于固定源。主代理核验354产品绑定、271执行绑定及20最终PNG，合并唯一registry冲突取固定候选原件，最终树 `8a60b845f469aeedb2bcbd699d86fd781c029b3c` 与预演完全相同，产品及D测试字节不变，无重复运行相同测试。

E143源码准备 `cc178b86294dc6a640b468888c4aadf06863bb2e` 现在可消费已接受D做正常验证器构建与真实缺项基线；准备不等于143正式通过。M013独立方法预审通过后已同步规格，保留36场景、35个非idle主要双版本/独立M2场景及10个同库配对资格；144仍须固定143正式测试后才实施。新增Int64绘制归属元数据/transfer scratch、全可见节点遍历和真实CPU/heap/GC成本仍由E核验，Cell槽下降不等于总体收益。T087-G01 release检查器缺口留023；031/022、完整六宿主C008矩阵和001/002/003/004/041、023/024继续开放。
