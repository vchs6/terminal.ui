# M2 rendering and public benchmark implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL superpowers:subagent-driven-development；按用户指定独立测试/产品/审核/执行/验收五角色连续完成，主代理只负责契约、集成与分歧处理。本文作者不执行下列产品任务。

**Goal:** 完成TASK-031真实局部布局/绘制与TASK-022公开可重复基准，保留完整M1 oracle与Linux全部完成目标。
**Architecture:** RuntimeNode持久缓存、同一LayoutNode measure/arrange/paint、整行damage、Frame行COW；精确失效与完整合成、成功输出baseline分开。M1临时计算不污染M2。
**Tech Stack:** SDK1.2.0/CJPM、正常cjtui源码制品及已冻结依赖；现Unicode/ANSI/Style唯一核。
**Spec:** design.md第14节最终裁决优先；三个specs；REQ-004.8、AC-031/022、AGENTS11/13.2/14；工具微证仅作诊断可用性证据。

## Global Constraints

- 原TASK-031/022为完整验收责任归属；123–142实现031各单元，143–147实现022并供031成本验收。实际工程层级依原WP002/WP005，角色工作为独立L3，不把原L3强行嵌另一套L3树。主仓接入时031/022转为本tasks唯一状态引用，不能保留两份勾选权威。
- 当前全部planned；有上游合同不等于上游产品已通过。正式产品124前必须冻结全部功能M1源码/制品及下表最终SHA；禁止提前用c3d743d有限功能作性能基线。
- A→B→C→D→E顺序集成。测试可按冻结合同准备，但产品只消费前单元验收固定提交；共享Component/Layout/Frame禁止多个产品作者同时编辑。
- 每实体一个小写下划线.cj文件，最小可见性，原public调用兼容，新增RuntimeStats三项仅只读；无私有测试hook、无强制M1/M2模式开关。
- 测试作者Sol/high、产品Terra/high或适合仓颉任务的Sol/high、审核/验收Astra/high、执行Sol/medium；记录指定配置，无法核验serving时不冒充实测。
- 角色只交接合同、固定源码/测试SHA、公开命令和原始证据，不交产品作者自评。验收按原AC及实际工作量/CPU/分配/输出，不以测试数量代替。
- 不publish、不改共享SDK/seed/cache、正式基准不依赖探针或开发目录；正常CJPM和普通bundle消费者不可skip。

## Admission Inputs

实施准入由主代理填写并固定下列manifest；任一未填写/未通过则相关产品任务仍planned。此处未知来自尚未完成的实际产品，不虚构SHA。

| 输入 | 合同来源 | 正式产品固定SHA/证据 |
| --- | --- | --- |
| Runtime A+B/C | reactive-runtime R001–019、单序列C | PENDING最终075/080 |
| RichText | implement-rich-text冻结design | PENDING最终084 |
| 主题基础/加载/展示 | T001–015及后续正式修订 | PENDING088/092/027 |
| Canvas/焦点/viewport/overlay | 主代理采用interaction合同，含root Vertical有限布局fallback | PENDING正式合同SHA及全部独立验收 |
| 输入编辑/标准控件/应用示例 | 原017–021/028–030/037等完整Linux公共功能 | PENDING最终固定集成 |
| Frame/Unicode/装饰/输出恢复 | 原005/007/008/011/012/020功能M1证据，以及041已冻结M1 Linux设备/ABI/输入输出/尺寸/恢复子接口证据；完整041最终全组件/M2/全部宿主验收后置 | PENDING最终固定SHA/有效复用证据 |
| 完整M1性能基线 | 全部功能齐全、M2实施前 | PENDING源码/依赖/native/制品/hash；正常公共benchmark双版本构建 |
| 本候选 | design14与三个spec、独立preflight/DQ | PENDING主仓冻结SHA |

## Review Focus

1. 同宽文本/颜色/Canvas caret-only变化不得触发无关measure/arrange；依赖相等不丢订阅，显式notify不被吞（123/133）。
2. Row flex/Column sibling/wrap/root fallback/viewport clamp连带既不能漏，也不能靠全树重算隐藏（123/133/138）。
3. Frame共享别名、零面积虚拟大轴、透明孔/StyledSpace、自合成和宽簇伙伴仍R11/F003（128/138）。
4. 隐藏/卸载/阴影/滚动/层关闭清旧画面，重合成底层最新值；cached caret的真实opaque遮挡与grid变化独立（138）。
5. 任意old Frame/profile/输出失败不误用damage；paired frame同业务epoch，计槽容量不冒充heapbytes（128/138/143）。

## Tasks

- [ ] TASK-123（testing/A）：冻结共享算法重构的公开行为/统计消费者及可复现正常基线。
- [ ] TASK-124（implementation/A）：同核measure/arrange/paint分离、M1独立临时结果、三统计真实作用域。
- [ ] TASK-125（verification/A）：固定124与123独立spec/quality审核。
- [ ] TASK-126（testing/A）：自有工作目录独立执行A公开消费者及受影响旧布局/主题/Canvas证据。
- [ ] TASK-127（acceptance/A）：验收算法单核/参考隔离/统计真实，不提前声明M2。
- [ ] TASK-128（testing/B）：冻结Frame COW别名/宽簇/透明/任意baseline与真实分配槽观察用例。
- [ ] TASK-129（implementation/B）：Frame私有行共享/脱离及精确行身份比较；保留通用慢路径。
- [ ] TASK-130（verification/B）：固定129与128独立审核含所有写入口/零面积/来源证明。
- [ ] TASK-131（testing/B）：独立执行受影响R11/F003、旧快照/输出及公开计槽消费者。
- [ ] TASK-132（acceptance/B）：验收共享正确与Cell分配变化，不把存储优化当局部布局完成。
- [ ] TASK-133（testing/C）：冻结dirty/约束缓存、布局连带、相等结果/notify/ForEach/manual/主题/Canvas依赖公开证据。
- [ ] TASK-134（implementation/C）：节点级Content/Style/Layout/Structure、bounded约束缓存及依赖传播。
- [ ] TASK-135（verification/C）：固定134与133独立审核所有失效入口/缓存key/版本消费。
- [ ] TASK-136（testing/C）：独立执行局部measure/arrange与M1逐帧对照、生命周期/顺序/主题回归。
- [ ] TASK-137（acceptance/C）：验收无关计算减少及连带完整，局部合成仍待D。
- [ ] TASK-138（testing/D）：冻结整行damage相交重绘、滚动/层/宽簇/caret/失败baseline组合证据。
- [ ] TASK-139（implementation/D）：局部合成目标、旧新bounds、缓存caret/层来源及后端安全消费。
- [ ] TASK-140（verification/D）：固定139与138独立审核draw上下文、重放顺序、目标/显示提交分离。
- [ ] TASK-141（testing/D）：独立执行逐帧Cell等价、设备故障/恢复与真实适用TTY输入输出。
- [ ] TASK-142（acceptance/D）：验收局部渲染功能完整；成本证据等E，不提前关031。
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

- [ ] 123列出手算布局/来源/Canvas场景的固定期望；对纯重构已有行为先记录GREEN，对缺新增统计的公开消费者记录真实缺API RED，不能伪造内部实现测试。
- [ ] 123冻结test-only SHA及普通CJPM构建/运行命令；统计断言按真实调用/实际Cell分配点含初建，不按实现源码生成预期。
- [ ] 124把paint内分配移到唯一arrange，Runtime节点承载唯一顺序引用；完整render用临时表而不建第二组件树，snapshot仍正常目标链。
- [ ] 124实现三只读诊断及生成/副本作用域，外部snapshot后续修改不回记；保留原八字段定义与生命周期。
- [ ] 125审核fixed base..product，覆盖M1稳定绑定与缓存隔离、root有限布局fallback、Canvas独立依赖不被参考替换、单核/退役与每实体文件。
- [ ] 126在独立checkout用普通cjpm build/直接binary真实退出执行123；按变化复用/补跑旧布局/主题/Canvas/生命周期证据，无关旧套件不重跑。
- [ ] 127按原输出、源码单核与计数原件验收；记录本阶段尚无局部性能承诺。

### B / 128–132（父031，REQ004.1/.3/.8，R11/F003）

文件：128扩同测试项目Frame公共消费者（不改旧断言）；129修改src/frame.cj及必要私有frame_row等单实体文件、终端比较接口内部实现。Cell/Style公开只读值不改；不新增第二Frame类/Unicode。

输入127固定产物和旧Frame完整语义。输出同Frame不可变行共享、实际分配槽计数、任意比较正确fallback。

- [ ] 128固定源/副本双向改、自composite、半簇、透明hole、StyledSpace、负偏移、改宽/高、预算与零面积极值场景；计量观察完整snapshot共享及第一次/重复写不同作用域。
- [ ] 128记录基线功能GREEN与真实“copy逐Cell分配仍存在”工作证据，冻结测试；不为内部存储类型造反射hook。
- [ ] 129将所有实际Cell存储分配统一计槽；所有写入口含clearAt/伙伴写按行脱离；full copy共享、subrect等允许正确慢路径。
- [ ] 129终端比较仅在冻结行身份/profile及精确版本关系适用时排除行；任意old Frame/外部修改/截断lineage回退完整正确比较。
- [ ] 130审每写入口/源别名/共享不可变/零面积不建巨量目录，以及damage不能覆盖后端失同步。
- [ ] 131独立执行128与受影响R11/F003/文件/后端消费者；132按原件确认正确性及计槽口径、性能热路径分配下降，仍不关031。

### C / 133–137（父031，REQ004.8/002，C/主题/Canvas合同）

文件：133扩tests/incremental_layout；134改runtime_node/session、binding结果提交、layout/node及theme resolver/Canvas依赖的已冻结接缝；必要node_dirty/measure_key/measure_result各实体文件。禁止第二children列表/第二resolver。

输入132；输出分类dirty、约束缓存、受影响measure/arrange集合及新旧几何。

- [ ] 133准备常量替getter、typed相等、notify各类别、ForEach keymove/manual、hidden→visible、纯span样式与文字、theme mask/fill、Canvas M/P独立失效；每批同root稳定M1对照。
- [ ] 133覆盖Row flex余数与兄弟重分配、Column后续/justify前后移动、宽wrap高度/四pad、root fallback与viewport clamp；固定能证明无关工作为零/减少的树形场景，不给凭空时间阈值。
- [ ] 134分开待求值与真正有效输出dirty；Content/Style/Layout/Structure不互相吞并，只有成功目标消费当期版本。
- [ ] 134有界intrinsic/实际约束缓存，位置变化复用文本测量；隐藏待算失效保留；依赖传播以真实输出/输入不变截断，不仅比父大小。
- [ ] 135审核缓存key、source mask/fill、独立Canvas依赖、真实C序列、cutoff之后通知与GC订阅资源；136独立执行133及相关生命周期/主题组合；137确认局部布局成立，paint局部仍待D。

### D / 138–142（父031，REQ003/004/009，原008/018/020/037组合）

文件：138新增tests/incremental_composition公开消费者及适用已有设备故障驱动组合；139改layout/Frame/runtimeSession/application的既有合成与设备目标接缝，新增damage_rows/paint_state等单实体记录。测试驱动工具不进入生产。

输入137、完整008恢复及交互产品；输出完整M2目标、整行局部绘制、正确caret与baseline。

- [ ] 138冻结长→短/移动/隐藏/卸载/阴影、背景移除、透明hole与StyledSpace、目标宽簇伙伴、滚动/anchor、nested modal close/下层后台最新值、caret-only及opaque同字符遮挡。
- [ ] 138用受控Canvas记录draw次数和可观察clip，证明相交节点每目标至多一次、上下文不随damage改变；全量M1另运行不混计。
- [ ] 139以旧新paint bounds并集形成整行带，清初值后全场景顺序重绘相交前后节点/层；subtree bounds含后代阴影，不只dirty节点。
- [ ] 139缓存未draw节点caret请求、按焦点/geometry/层opaque覆盖重算；设备grid零差分也输出caret变化，输出成功才提交组合baseline。
- [ ] 140审未知lineage/profile、partial write/resize、缓存clean但设备失同步、异常清理围栏；141独立执行138与008受影响恢复矩阵/真实适用TTY；142核M1逐Cell等价与交互caret结果，保留E成本前置。

### E / 143–147（父022并供031，REQ006/NFR05/AC022/031）

文件：143冻结基准输入场景/预期/CSV合同及公开可消费性检查（tests/rendering_benchmark）；144创建benchmarks/rendering/cjpm.toml、src/*.cj每实体文件、README.md，产品说明docs/product/rendering-benchmark.md；制品白名单已有benchmarks，核实实际包而非只看配置。

输入142与完整M1冻结普通制品。输出普通公开benchmark、原始重复数据与方法，供023干净最终制品消费。

- [ ] 143冻结80×24/160×48混合Unicode、各类变化/横向同行代价/全局退化动作与业务barrier；正确性按完整Cell+独立caret断言，性能不运行oracle/equality/hash。
- [ ] 143冻结CSV列的单位/范围：measure/arrange/paint/frame/cellWrites、frame_allocated_cell_slots、CPU user/system、wall、heap/GC/RSS、成功输出bytes/calls、环境/源码/seed/尺寸/重复编号；缺某采样工具记录实际限制，不自动取消其他必要证据。
- [ ] 144用同公开业务程序分correctness/m1-headless/m2-headless/tty；库无测试模式；M1普通render、M2普通snapshot；输出bytes采集/CPU外部工具不进入运行依赖。
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
