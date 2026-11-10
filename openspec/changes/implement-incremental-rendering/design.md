# M2 局部布局、绘制与可重复基准：可冻结候选设计

2026-11-10；主代理已采用本方案及第14节最终裁决，已纳入主仓，独立preflight修订中。本件是可冻结OpenSpec工件，不是实现或验收通过结论。第14节优先于前述独立草稿中“推荐/待裁决/未冻结”的措辞。原独立作者仅写草稿，当前主代理维护此正式变更；产品尚未准入。指定Astra/high，实际serving/effort不可核验；未派下级。适用brainstorming、writing-plans及verification-before-completion，语言微探针使用cangjie-coding与当前SDK实证。

## 1. 固定输入与已知事实

产品读取固定 `c3d743d`，完整 commit 及逐文件 SHA-256 见 `source-hashes.tsv`。读取时工作树 HEAD 已是 `fc7667339d39208bbd0c25650696a7f495ca971d`，因此使用 `git show`，不将并行改动混入产品基线。主题输入固定 `d4a92238` 的 design T001–T015；runtime R019 从 `fc7667339d39208bbd0c25650696a7f495ca971d` design 消费，仅是独立尺寸采样修订，不声称它已实施/验收。未读取实现作者的 progress/自评或产品通过报告。

需求权威为 REQ-004.8、TASK-031/022、linux-completion-plan；M2 是完成 Linux 的必需里程碑。C 的单一序列/If/ForEach/manual 合同、RichText 合同、主题约束和四边 padding/wrap 均为将消费的冻结合同，不把“已设计”当“已实现”。交互 Canvas/焦点/viewport/overlay 仍是并行草稿，其具体接口待冻结；本文仅声明需要的语义输入。

源码事实：

- RuntimeNode 已有 contentDirty/styleDirty/layoutDirty，但 produce 清掉全树标记后仍重新构造 LayoutNode、全树 measure、全树 paint；Structure 被折成 layout，尚无独立结构 revision。
- 当前 paint 同时进行 Row/Column 分配与绘制；因此仅跳过 paint 会漏掉布局依赖，必须先把共享分配逻辑从绘制中抽出。
- LayoutNode.measure 递归建一份短命几何树；它既无约束 key，也无持久结果。M2 不能再在旁边增加另一种布局算法/组件树。
- Application.snapshot 总是对完整缓存 Frame 调 copy；Frame.copy 先初始化整帧，再 transfer 逐 Cell。后台变化即使只一字，也承担面积级复制。
- Frame.changesSinceForTerminal 当前逐帧逐 Cell 检查，再整行编码。Cell 为只读 struct，Style 为不可变值，允许同一 Frame 类型内部共享冻结存储。
- run 已由 needsWork/尺寸/profile 等常数信号驱动；空闲不遍历树、不复制 Frame、不 diff。不能把先前 idle 缺陷的修复算作 M2 收益。
- 全局 render 的持久分支稳定绑定后直接完整 renderLayout；它不委托 session 的目标缓存。runtime R004 保证此行为继续。

环境核对：清单SDK1.2.0、包0.0.0及依赖未动。初始PATH无cjc/cjpm，后续source已有SDK envsetup后实际核验cjc/cjpm/cjprof1.2.0，正常外部小程序build/run；工具原件见独立probe-report。此微证不代表下述内部类型/新增统计签名已编译，正式产品仍待独立公开消费者实证。

## 2. 单一方案与取舍

推荐：RuntimeNode 保存唯一持久几何/样式/文本缓存；现有 LayoutNode 演进成同一算法的求值上下文；布局分 measure/arrange，paint 按 damage 访问相交节点；仍维护一个完整合成 Frame。M1 使用相同函数和当前已提交节点序列，以独立临时结果表执行完整求值，禁读写 M2 缓存。Frame 私有行 COW，终端按冻结行身份或可靠 lineage 缩小比较范围。

第一版 damage 取**整行带集合**，而不是任意小矩形：把受影响旧/新 paint bounds 涉及的可见行展开为整行，合并区间。这仍是真正局部布局/绘制——未受依赖影响的节点不 measure/arrange，未与脏行相交的节点不 paint。多列同一行可能重绘更多，收益必须实测；宽簇没有人工横向切口，正确性明显简单。横向细粒度区间以后只能在本内核中演进，不是本里程碑前置。输出差分可以继续整行，不能把这一输出政策当成局部布局证据。

替代方案及不采用原因：

1. 保留每帧整树/整帧，仅减少 ANSI 行输出：不满足 REQ-004.8，且 copy/diff 成本不变。
2. 每个节点持有独立 Frame、另写缓存 compositor：空间随节点面积累计；嵌套透明/宽簇行为易与主 Frame 分叉。第一版不采用。overlay 若交互合同有必要的离屏 Frame，也必须使用同一 Frame/composite 核与节点身份，不能成为第二组件树。
3. 初版任意 cell damage + 空间索引/复杂命令缓存：可提高同行稀疏负载收益，但需要证明边缘宽簇闭包、clip 语义和维护成本。先用整行 damage 建立可审计正确性；若实测目标负载无法获益，再据数据收窄，不能永久全帧退化。

## 3. 关键公开不变与内部职责

公开 Text/Row/Column、自定义 Component、常量/getter 链、Observable、NodeRef.notify、batch/post、snapshot、全局 render、Frame 原方法保留签名与语义。无 M2 开关、无手工 flush/markDamage、无 benchmark 专用渲染模式，无用户可变 dirty/缓存句柄。主题/RichText/C/交互依原本所属合同增加的接口不是 M2 新造接口。

RuntimeNode 是生命周期、身份、顺序、失效、缓存的唯一拥有者。C 的已提交 child sequence（真实孩子加内部 marker）是唯一顺序权威。布局迭代可跳过 marker/隐藏节点，不复制一份可独立协调的 children。LayoutNode 若保留名字，定位为几何结果/求值视图；旧递归分配独立树构造退役。M1 临时表只有当前节点引用及计算结果，不 mount/clone Component、无第二序列、不保有用户状态。

建议内部概念（非已编译签名）：

| 概念 | 最少职责 |
| --- | --- |
| NodeDirty | Content、Style、Layout、Structure 分别累积；外加 subtree 汇总位/队列去重，避免每 turn 全树清标记 |
| ResolvedNodeStyle | 消费主题唯一 resolver 的完整 style、layout、decor、explicit/source mask、三种 fill 来源及独立 fillStyle |
| MeasureKey/Result | 输入约束、文本/布局/children revisions、宽度策略；输出 natural/min/约束测量尺寸与文本行数据 |
| ArrangeInput/Result | 分配 rect、父内容 rect/clip、对齐/顺序、viewport transform、层放置；输出各孩子分配与依赖摘要 |
| PaintState | 最近成功目标的 paint bounds、clip、transform、绘制输入版本；subtree bounds 是保守并集 |
| RenderPass | 完整临时求值或增量持久求值，两者共用计算函数；只有内部模式，无公开测试入口 |
| DamageRows | 可见 y 区间集合、全帧标记；只描述候选损伤，不是最终终端已改变字节证明 |
| Frame storage | 私有冻结行/独占可写行、快照版本、精确来源关系；所有绘图仍经过现 Frame 簇操作 |

不能用 hash 唯一决定缓存有效、帧相等或未损伤：采用明确版本/输入值和不可变对象身份；hash 只能加速筛选，碰撞仍比较。

## 4. 失效输入：同一安全边界、保留分类

全部变更先走既有 UI 调度与 cutoff，C 结构提交、typed 求值、主题候选提交各按其冻结顺序完成，M2 只消费稳定后的结果。不得为了加速改变 getter/生命周期/异常先后。

| 输入 | 最小失效与连带 |
| --- | --- |
| 常量 setter 替换 getter | 解除旧依赖保持既有行为；按实际属性分类写节点 dirty，不能仅依赖 Binding.category |
| typed getter 失效但结果相等 | 求值及重订阅，最终有效值/来源 mask/fill/内容相同则无目标变化；不能把“待求值”永久等同“必须 measure/paint” |
| Text 文本/硬行/簇变化 | Content；失效该节点分段/测量/绘制，测量结果变化向相关布局依赖传播 |
| RichText 仅 span style 变化 | paint；不重新分段/排版，按冻结规范化值和首 scalar patch 规则；文字变化才重新测量 |
| 单颜色/文本属性 | Style→paint；继承只传给实际采用受变字段的后代；显式/主题屏蔽分支可截断 |
| shadow/背景来源/explicit mask | 即使最终八字段 Style 相等也比较来源和 fill；阴影旧/新范围损伤；不误触尺寸重排 |
| Layout/尺寸/padding/border有无/gap/weight/wrap | 几何输入失效，依赖传播；四边独立，wrap 按实际分配内容宽重测 |
| Structure/If/ForEach/manual | 只在成功提交后推进父序列 revision；新增初始化，移除保存旧 bounds 墓碑，保留 key move 不重建/重挂载 |
| notify(Content/Style/Layout/Structure/All) | 明确通知是保守失效要求，不能仅因无 getter 就吞掉；Bindings 仅重求值；Structure 仍由 C 决定协调语义 |
| visible false/true | 旧可见范围清除/新范围重绘，影响父自然尺寸和后续位置；隐藏不等于卸载，不停止正常订阅 |
| theme/visual state | 唯一 resolver 做来源/有效结果比较；只颜色则 paint，四边/尺寸/wrap 等才 measure；不重建身份/编辑/焦点/滚动 |
| scroll/viewport | 更新 offset/clip/子节点显示位置，损伤视口相关行；内容测量仅约束变化才无效 |
| overlay 开关/移动/重排 | 层所有权/栈由交互所有者提交；记录旧/新范围，关闭父同时纳入所有附属层范围 |

当前 stabilize 在运行 getter 前即 markNodeDirtyLocked(binding.category)，M2 不能据这一保守候选直接决定最终工作。推荐在结果应用位置比较有效输出并推进真正版本；保留 pending evaluation 标识与实际 dirty 的区别。若初版仍保守产生某个目标帧，应至少避免结果相等时实际 measure/paint；R003 的相同 typed 值无新画面承诺不能被重构降级。

隐藏/被裁出视口的节点可延迟计算，但其内容/布局版本失效必须保留；重新可见或暴露时按最新值求值，不能把“这次没画”当缓存已更新。

dirty 先累积到受影响节点及祖先 subtree 汇总；取 turn 工作集合，不逐帧扫描所有节点/绑定清零。成功完成新目标后只消费本次版本，不清除 cutoff 之后新来的失效。clear-all 再 render 的旧 produce 路径退役。

## 5. 约束缓存与依赖连带

共享布局算法拥有尺寸协商；M2 只增加输入键、复用和受影响区域遍历，不定义第二套 Row/Column 取整、最小值、溢出、Unicode 或换行规则。

缓存 key 至少包含：有效宽/高约束（含 auto/固定/最小语义）、内容区四边 inset、文本内容版本、wrap/overflow/对齐中实际参与测量的键、宽度策略、孩子顺序/测量结果版本。主题总 revision 可作失效候选，不能令纯颜色变化自动废弃所有 measure。不要把整个 Style 打进 measure key。

每节点有有界最近测量缓存；初版建议区分 intrinsic 与当前实际约束两个槽，不无限缓存每个 resize 宽度。Row 先共享计算固定/弹性宽分配，再对实际宽依赖的文字重测高度；Column 先确定孩子可用横向内容宽再测自然高。具体协商执行次序沿 T005/T014 形成的唯一实现，M2 不新增迭代“直到看起来稳定”的循环。若共享算法需要有限多次测量，缓存每次可识别输入并统计真正执行量。

依赖规则须可解释：

- Row 任一非弹性孩子主轴需求、min/weight/gap、父宽变化可能改变所有 flex 分配及余数；容器重新分配对应 sibling group。某兄弟分配宽未变可复用测量；宽变且 wrap 则重测高，最大横轴高度变化可进一步影响祖先。
- Column 某孩子自然高变化会移动后续孩子；justify center/end 可移动前后全部，cross align/stretch 和父宽变化可能改变所有孩子。复用未变内容测量，同时重算确实变化的分配与位置。
- 位置变化不等于文本 measure 变化。只平移的节点复用文字测量，更新 transform/clip/bounds 与 paint damage。不要为了移动递归重新分段所有文本。
- 父自然尺寸不变不能一概截断传播：父仍需安排受影响孩子；flex/justify/clip/viewport 参数变化可能让内部几何变化而外部尺寸不变。截断条件是父对其父的布局输出及所有有关依赖输入未变。
- viewport 宽度变化会连带 wrap 行高、后续 sibling 位置、滚动范围与 offset clamp。height 变化可能改变 flex 高/clip。实际尺寸以 R019 单次采样 pair 为边界；零尺寸、窄于 min 仍沿已冻结裁剪政策。
- key move 保留节点缓存和代际，但 sibling 顺序、余数分配、位置/clip 可能变。移动祖先需更新后代可见 transform，不许留下旧绝对 bounds。

子树几何摘要/已有顺序前缀和可在必要容器缓存；第一版允许为一个受影响 Row/Column 线性扫描它的直接孩子，但无关兄弟子树不重新 measure/paint。需如实计入遍历 CPU，不把容器扫描包装成 O(1)。

## 6. damage 与局部合成的正确性

paint bounds 是该节点**实际可能写入**的保守范围，含边框、正文、local/seed fill 和阴影，受既有祖先/层 clip 限制；与 layout/hit bounds 分开。自定义 Canvas 若只能写受控分配盒/clip，则该可写范围作保守 bounds；未经冻结的越界 paint 扩展不臆造支持。

步骤：

1. 保存本次变更相关的旧 bounds/clip/transform；卸载节点先留下仅含几何的短期墓碑，不能为了清残留延长 Component/NodeRef 生命周期。
2. 完成受影响布局/样式，计算新 bounds。旧、新、可见性/层序变化覆盖区域并集构成初始 damage。新旧阴影都纳入。
3. 将 damage 投影为视口内完整行带。宽簇伙伴同一行，因此源/目标整簇清除不可能越过 damage 的横向边界。负坐标/极值用现有 checked/saturating 交集，零面积早返回。
4. 从上个完整目标 fork 同类型 Frame。在损伤行恢复根初始空白/背景，然后按**全场景既定绘制顺序**重放所有与 damage 相交的当前节点与层。先下层再上层，不能只画 dirty 节点，也不能只画其祖先。
5. 用 subtree bounds 剪枝；若祖先自身 bbox 不相交但后代 shadow 相交，仍访问相交后代。容器先后装饰顺序与 M1 完全一致。
6. 目标成功完成后发布完整 Frame 与本次新几何/版本；可导出/可 snapshot。几何、文字、样式都来自同一稳定 turn。

**写入过滤不能改变用户可观察的绘制上下文。** Canvas 回调看到原本分配/clip/样式，不能把 damage 当新的 layout clip，诱使用户依 clip 产生不同内容。damage 行过滤在受控写入端内部执行；一次相交节点 callback 在该目标生成中至多调用一次。框架的每个低层写入都仍经过 Frame 的唯一宽簇/透明规则。

对于 overlay 使用 transparent Frame 的实现，必须重建受损行的透明初值并合成最新层；禁止从曾显示的终端区域“抓屏恢复”。透明 hole 是 isTransparent=true 的规范空白、合成跳过；StyledSpace 即使 Color.Default/Style() 也为实写并覆盖。清掉上层旧位置后必须重新合成下层最新状态，包括遮挡期间发生的变化。第一版不做遮挡剔除，因此被遮挡的脏下层仍更新自身有效状态并参与相交行重绘；关闭嵌套 modal 必须清所有已关闭附属层的旧范围，最后合成剩余栈。

整行策略将宽簇边界风险限定到已有 Frame 操作：所有 put/fill/clear/composite 继续遵守 R11/F003（源半簇变保留样式的 opaque 单格、目标碰到整簇清除、自身合成读开始快照、透明位保留）。未来收窄 x damage 时必须同时对旧/新帧及重放操作覆盖的目标簇求闭包，不能仅“扩一格”假设所有簇宽2；此次不实施该额外算法。

当 damage 遍布视口、大范围主题布局/resize、缓存缺失或来源证明不可用时，可用同内核全量求值/绘制。初版无需凭空设百分比阈值；用行带天然退化到全屏。任何性能切换阈值须由实测工作量和分配成本形成，不构成外部行为变化。

## 7. 同一 Frame 的私有行 COW

推荐先按行存储，不另造 Frame 类、宽度计算器或公开 mutability 规则。冻结 row 保存 Cell 数组；Frame 保存 row 引用。修改某行前复制该行一次成为当前 Frame 独占可写行；被 copy/snapshot/作为共享源时先冻结该行，之后所有写者均须脱离。冻结数组不暴露给应用。

完整同尺寸 copy 是 O(height) 引用复制而非 O(width×height) Cell 复制；目标更新只为受损行分配 Cell。若高度引用复制也成瓶颈，才评估 row-directory chunk COW；先不引入多层持久树。公开 copy/subrect/resized 仍返回独立可变 Frame；源、副本任一 put/clear/composite 不影响另一方。仅内部不可变存储共享符合“不共享可变 cells”，不是放宽 F003。

可直接分享的情况：完整行同宽复制、同尺寸 snapshot；其他裁剪/负偏移/改宽/源半簇情况先走现 transfer 语义，允许慢路径。扩高可共享旧完整行，新行按原默认透明类型；改宽不能盲目共用旧行。self-composite 先冻结所读行快照，之后才修改目标，避免别名拖影；不同帧 composite 的透明跳过也不可偷换成整行覆盖。

必须覆盖所有写入口和间接 clearAt；伙伴写入同样 detach/记修改，不得只标 put 的锚点。clear 显式透明策略、源透明位、ambiguousWide、maxCells、默认 blank 类型全部保留。Frame(0,Int64.Max)/Frame(Int64.Max,0) 不能因改为每行数组而分配虚拟 height：零面积存储必须为空，保留已冻结短路与导出预算。

每次公开外部快照修改都有自己的内容 revision/行引用。仅 Frame 对象身份不能证明内容未变；Cell/Style 不可变使冻结 row 身份可作为严格相等证明。无必要对 Cell 单独分配对象或每写一格加锁。

## 8. 后端比较、baseline 与失败恢复

完整目标缓存与最后成功显示 baseline 是两个状态。M2 完成目标可消费其计算 dirty，但设备尚未输出的呈现债务仍保留；不得声称已显示，也不得把后端 pending/fullResync 清掉。无可见变化（包括 profile 投影后相同）只有在后端原本同步时才可视为成功的零字节提交。

最小安全优化：同尺寸且 profile 完全等价时，旧/新行指向同一冻结 row 可以直接跳过；不同引用的行仍逐 Cell 正确比较。即使 old 是任意不相关 Frame，这一规则也正确。profile 任一影响投影的字段变化，即使 row 相同也必须重新比较投影/编码，不能只比 colorMode。

damage 提示仅在以下证据全满足时用于排除行：提示绑定到目标的精确冻结版本；base 对应最后成功 baseline 的精确内容版本；中间每次修改完整纳入；尺寸/宽度策略/profile 适用。可用有界 parent-version+行集合；多步 target 超过已保留 lineage 时回退全行比较，不能按 Frame 地址、hash、最近 target 或业务 turn 猜 baseline。外部 Frame 被修改后旧提示不得复用。建议初版以冻结行身份为主，少维护历史链；它已消除未变行逐 Cell diff，任意 old 都有正确 fallback。

仍可整行 ANSI 编码。输出非空时按 TASK-008 完整写成功后才发布 baseline/profile/尺寸；部分写失败使同步失效，即使下一目标 rows 与旧 baseline 共享，也不得跳过恢复或全量重画。008 决定安全恢复解析/模式或停止报错；M2 不发明“重发差分就好了”。resize 同样使设备 baseline 失效。R019 允许曾真实存在的尺寸的在途帧稍后完成，不允许混合宽高 pair。

## 9. M1 参考隔离与逐帧相等

全局 render 仍是完整 M1；不可调用 produce 增量模式或将缓存 hit 计作完整参考。共享算法的纯输入/输出函数接受已稳定 RuntimeNode 视图，M1 使用临时结果表，强制全部 measure/arrange/paint；M2 使用节点缓存。M1 的纯参考求值阶段不写入/清除 M2 dirty、bounds、Frame lineage、viewport 缓存、overlay 缓存或后端 baseline，不重新 onMount/cleanup，也不为 oracle 建另一组 Component。

全局 render 入口按 R004 稳定绑定时，真实新值仍须按原合同给持久节点标脏，不能为隔离 oracle 吞掉业务失效；隔离的是随后的参考计算与缓存提交。涉及覆盖层时，两入口必须消费相同逻辑根/可见层栈/viewport状态，具体全局 render 的层宿主接缝待交互合同冻结，不能只比较无覆盖层子树后宣称整帧等价。

全局 render 本身的绑定稳定与公开累计 stats 行为保持 R004/R008；参考 render 必然增加其实际 measure/paint/frame 计数。因此正确性运行与性能运行分开，不能声称 oracle 完全没有任何可观察计数影响。若受控 measure/paint 内自动依赖收集，M1 在“既定 render 计算”范围内使用观察但不提交 M2 订阅的上下文：不破坏未来失效，也不让 oracle 增添持久订阅。该具体接口必须等交互合同冻结后联合裁决。

逐帧相等比较完整 Cell：grapheme、width、continuation、完整原始 Style、isTransparent 和帧尺寸；不能只比较 plain text 或投影后的 ANSI。共用算法可发现增量遗漏，却不能证明共用算法本身正确，因此沿用已独立的 Frame/布局/主题/Unicode手算金例，不要求另写第二渲染器。

正确性 paired frame 由单 UI 线程提交确定性动作脚本，先一个 batch、再 snapshot 完成该 turn；冻结生产者/主题完成信箱等外部写入后对相同 root 调 render。一次配对前后的外部输入计数与业务状态 epoch 必须相同；仅同尺寸/同时间戳不够。非冻结后台 Observable 持续写入时两次 API 各有 cutoff，不能拿不同状态的帧判 M2 错。异步场景以公共 post 接收确认/业务 barrier 停止新写入，执行到已知批次，再配对。freeze 是基准业务自己的门控，不加生产运行时 freeze hook。绘制回调须遵守交互合同的受控无变更规则；M1 参考允许额外执行受控绘制，不能放时间/random副作用后要求两帧偶然相同。

## 10. 可观测统计：最小充分，不造测试模式

既有八个 RuntimeStats 用来报告每阶段差值：builds、measures、paints、frames 与 mountedNodes/bindings/subscriptions/pendingPosts。计数沿原义：真正执行 measure 才加 measures，命中缓存不加；实际节点 paint 才加 paints；生成完整目标加 frames；M1 增加其真实执行计数。stats 查询本身可能扫描 bindings，不能每个空闲 tick 轮询后把费用算产品 idle。

为区分分配布局、实际绘制写入与Cell存储分配，主代理已采用三个通用只读诊断量，原八字段不重定义：

- `arranges`：实际重新计算节点分配/位置/clip 的次数；缓存输入未变直接复用不计，正常 M1 全算全部计。遍历候选但没重新计算不计，CPU仍如实测。
- `cellWrites`：渲染目标生成期间 Frame 实际执行的 Cell 槽写入次数，包括初始化/清残留/宽簇伙伴/多层覆盖，重复写同一格重复计；只读共享/未变行复制引用不计。公开外部用户编辑 snapshot 不归 Application 目标生成计数。批量填写可以加长度，不要求每格原子递增。

- `frameAllocatedCells`：在实际Cell存储分配点累计成功新分配槽容量，精确归属/范围见M003；共享行不计，GC不扣。

三项是通用生产诊断，已采用而新签名仍待正式编译。CPU/输出字节真实测量，不能由计数反推。Cell槽不是bytes/整个heap；引用数组、字符串等成本另由CPU及SDK heap/GC/RSS报告。内部常驻状态预算与峰值说明，不无限保留历史Frame/节点/lineage。

## 11. benchmarks/rendering 的公开、可重复方法

交付正常独立 CJPM 项目，仅依赖制品中的 cjtui 公共 API 与已声明依赖，产品基准源码不引用 src、私有方法、开发目录、作者缓存或测试宏。配置命令的确切仓颉参数解析/计时签名待 SDK 正常消费者实证，本文不伪造可运行代码。

建议同一业务 workload 支持 correctness、m1-headless、m2-headless、tty 四种**基准自身执行路径**，不向生产库加入模式开关。m1 使用公开 render(root,w,h)，m2 使用 startHeadless/batch/snapshot/stats/dispose。两者使用同一 workload 源码、动作种子、总更新数、尺寸和完整组件功能；M1 也持久挂载一次以消除生命周期构造差异，但每次采样走全局 render。含后台 post 的正确性负载另测，主 CPU 对照用确定性 batch，不以 M1 render 不 pump posts 制造不公平差异。

公共接口当前没有独立 diff 编码入口，changesSinceForTerminal 为内部方法，不能让基准 import 私有符号。处理方式：

1. headless 直接比较当前同一库的 M1/M2；快照独立副本成本算 M2 的真实公开调用成本，单独记录 M1 帧导出/消费策略。
2. diff 阶段由开发侧 profiler 对正常 Application.run 分段归因；不把 Frame.toAnsi 全量编码叫作差分基准。
3. 若需真实 TTY 下 M1/M2 输出与 CPU 对照，保存**功能全部一致、M2 开始前的 M1 产品固定提交**，用同一公开基准分别依赖该 M1 制品与最终 M2 制品正常构建。无需生产强制全量开关。先证两版本相同动作产生同完整帧；缺同功能基线时只报告最终 TTY 绝对成本与 headless 对照，不虚构 TTY 加速倍数。

最少 workload 矩阵：80×24 与160×48；ASCII、中文、组合字符、ZWJ emoji/旗帜混合文本。包含单一末端颜色、同宽文本替换、长变短/短变长、Row flex 宽变化、Column wrap 高变化、resize pair 往返、一次 batch 多属性、多视图共用 Observable、typed 相等结果、显式 notify、ForEach key 重排和 manual 穿插、主题纯颜色/间距/四边/wrap、滚动一步/多步、透明 hole+StyledSpace 的覆盖层移动/缩小/嵌套关闭。首次构造、稳定 idle、大面积变化独立列出，不混进稀疏更新均值。

工作量必须包括：纵向分离面板（整行 damage 的主要受益对象）、同一行多个独立列（整行策略代价）、大填充/阴影重叠、可见小视口加较大已挂载树（不能自动宣称虚拟化）、全局主题/resize 大退化。每项公布总节点/可见节点/dirty叶数、文本量、层数和准确动作，不只写“复杂页面”。

正确性运行输出每一步 Cell 相等结果和首差坐标/完整值，配合手算边界例；性能运行**不生成 M1 oracle、不做全帧 equality/hash**。分 process 运行 m1/m2，随机或交替顺序防热度漂移；编译优化/SDK/库commit/native/依赖/GC配置、OS/CPU/核心与频率策略、终端及locale/字体/尺寸/能力来源均记录。先测预热达到稳态所需，再固定预热和测量次数；至少多次独立进程重复，保留每次原值、median和分布/区间，不能只报最好一轮。

CPU使用已实证的Linux wait4 user/system等可核验进程计量，同时报告wall。分配报告精确frame_allocated_cell_slots与明确范围的SDK当前heap/累计GC回收/次数耗时及RSS，不把任何一项冒充全进程allocated bytes。微探针已证cjprof采样权限失败、导出NewArray8钩子漏内联分配，均如实记录；这些不新增为原AC031的不可证前置。trace开销独立记录，不把带strace的一次和未插桩的另一次直接比较。

TTY 运行走正常 Application.run，更新来自基准业务公共 post/定时动作，记录真实宿主版本/尺寸与能力。输出 bytes/调用来自实际成功 write 观测；请求 bytes、成功 bytes、调用次数、短写重试应区分。baseline输出/退出控制另列，不混入每更新的增量。允许开发验证工具捕获真实运行，但基准/主库不依赖 GUI、JS或终端模拟器。无真实宿主只报告 headless/diff归因不足，PTY+TERM 改名不算多真实终端。

idle 目标是确认无 build/measure/arrange/paint/frame/diff工作、CPU由既有poll等决定；不声称0 tick/零CPU。CPU受测量噪声影响时扩大有效测量时长，不能拿空闲优化为M2独有收益。

收益判据：对预先公布的代表性局部负载，证明无关节点 measure/arrange/paint 与 Cell写入减少，并报告相应 CPU、分配、输出成本；输出可以与 M1 相同，因为两者都用正确差分。全局退化报告缓存/行共享开销和峰值内存，不隐去负收益。无需凭空定义“必须快2倍/低于5ms”；但若只计数下降而 CPU/分配恶化，结论只能是局部工作减少、总体性能尚未证实，须分析 copy/diff/遍历/GC 与 workload。

## 12. 分阶段可验单元与准入

下列是交付边界建议，不是直接转 ready 的正式 L4 或已编写测试。

| 单元 | 输入与可独立证明的结果 | 不得提前关闭 |
| --- | --- | --- |
| A：同核 measure/arrange/paint 分离 | 已完成主题约束布局与C单序列；M1 仍逐帧精确、统计真实；移除 paint 内重复布局规则 | 尚未有局部收益，不能算M2 |
| B：Frame 私有行共享 | 既有 R11/F003 完整公开消费者重跑受影响范围；copy隔离、零面积极值、透明/宽簇/自合成、任意frame diff正确 | 没有局部布局，不能算M2 |
| C：节点几何缓存与dirty传播 | 常量/getter/manual，Row/Column连带与wrap；M1临时表不污染缓存；颜色无无关measure/arrange | overlay/scroll尚待联合场景 |
| D：局部合成与设备消费 | 新旧bounds、透明、阴影、宽簇、移动/隐藏/卸载、viewport、嵌套层；失败仍服从008成功提交/恢复 | 008未验时不能宣称设备失败安全全部通过 |
| E：正常CJPM公开基准 | correctness与timing隔离，实际CPU/分配/输出/重复环境，稀疏与全局退化、独立制品消费 | 不能用测试数量代替成本证据 |
| 汇合：TASK-031/022 | 全部必需前置与组合证据完整，公开API一致、无测试模式；实际Linux环境缺口显式列明 | 不把M2草稿或单元A–C当全部Linux完成 |

测试作者/实现/审核/执行/验收各按 AGENTS 独立固定输入开展；本稿只提出待验行为，不编写正式测试。C/RichText/主题/交互冻结后须记录消费 SHA；若其实际接口不支持以上独立依赖或同核布局，先修订本草稿相应接缝，不能静默假设未来实现已具备。

## 13. 已采用路线与实施前实证检查

1. 接受首版整行 damage + 节点/子树相交绘制，并以同行多列负载暴露代价；若性能证据不足则同核优化，不减掉 M2 必需目标。
2. 接受 Frame 完整快照行 COW，其他 copy/subrect/改宽保留正确慢路径；最大零面积轴须特殊存储，不引入新的资源拒绝。
3. 三个只读RuntimeStats诊断已采用；独立消费者实证字段及现有包内8位置参数构造兼容，不能变更原八字段含义。
4. Canvas measure/draw独立依赖、readonly查询及viewport/overlay推荐路线已采用；最终精确产品SHA及接口消费须固定，M004/M009保持共享边界。
5. M1 功能完整的性能基线固定时间点与正常 SDK 分配工具可用性；没有真实分配/TTY数据则相应验收保留不足。
6. 内部冻结row身份、临时结果表、typed约束键以及新增诊断若采用，均需 SDK1.2 正常编译证明可见性/引用身份/数组别名/异常处理，本文不承诺尚未编译的仓颉新签名。

技术推荐均服务既定需求，不改变用户构造与范围；主代理可在已有自主技术授权内作可逆选择。此稿无功能完成声明，也没有把缺前置或缺环境当作用户必须再次授权的理由。

## 14. 主代理采用裁决（优先于上述独立草稿）

M001：采用整行damage与真实局部measure/arrange/paint。RuntimeNode单一身份/子序列/缓存权威；同算法M1独立临时表禁读写M2缓存及提交元数据。入口正常稳定绑定的真实dirty不因参考隔离被吞。无公开渲染模式/强制全量测试开关；全局render仍完整M1。

M002：采用同Frame私有冻结行COW；完整snapshot独立可变、宽簇/透明/F003/R11全部保持。零面积虚拟极大height不分配行目录。后端可以冻结行身份跳过等同行，damage提示仅在精确baseline内容版本关系有效时使用；不同profile、不同/未知lineage和任意外部Frame必须正确fallback，不信hash或对象地址。008的同步失效、成功提交与恢复/停止围栏优先于任何M2优化。

M003：RuntimeStats新增`public let arranges: Int64`、`public let cellWrites: Int64`、`public let frameAllocatedCells: Int64`，无公开构造或reset。原八字段含义不变；三者同session累计、start重置、dispose保留最后累计。arranges与cellWrites按第10节已给精确定义执行。frameAllocatedCells在实际Cell存储分配位置累计新分配槽容量，包括目标生成、完整公开render、Application.snapshot返回副本、COW脱离和渲染所需Cell暂存；共享既有行不计，GC不扣减，分配失败无成功新容量不计。当前Frame逐Cell初始化算实际写入，未来COW共享/复用不可虚增写入。

只统计Application拥有的生成/返回snapshot作用域；调用者后续修改保存的snapshot不增加该Application三项计数。独立Frame操作无Application统计归属。引用目录/字符串/节点/native分配不计frameAllocatedCells；它们成本仍由CPU、SDK堆/GC和进程RSS呈现，不隐藏。CSV固定`frame_allocated_cell_slots`，不得叫allocated_bytes/heap_allocations；一槽也不能乘未经实证的sizeof(Cell)当实际内存。仅新增这三项，不扩充测试hook。新只读签名须正式公开消费者SDK1.2编译确认。

M004：消费交互推荐的Canvas(measure,draw)独立依赖、readonly查询、viewport/overlay统一几何/层所有权。measure与draw依赖版本分别纳入缓存，readonly focus/viewport变化也通过原可观察机制失效；M1参考计算的读集合不替换持久M2订阅。临时detached render仍共享runtime临时模式，无onMount/cleanup副作用。

Canvas跳过draw时保留其最近有效的逻辑caret请求作为节点绘制结果。focus变化使旧/新focused Canvas绘制输入失效；其旧新可写范围纳入damage，所以新caret所在可见行已覆盖。viewport/anchor/层序变化重算caret变换/clip/遮挡；若该行被重绘，按同一实际opaque写入重算覆盖来源，透明孔不遮，StyledSpace/阴影遮，不用最终字符颜色相等判断归属。未损伤且焦点/请求/几何/层输入全部不变时可复用最近caret结果。M1返回Frame不改Application.caretSnapshot；正确性另通过交互公开caret断言，不声称Frame equality已覆盖caret。

设备比较是完整画面与caret组合目标；即使零grid差分，caret-only变化仍输出必要控制。两者全部输出成功后才提交baseline。缓存不能让隐藏/卸载/关闭层的caret复活，退出沿原会话恢复。

M005：分配证据以真实范围的Cell存储槽累计为精确指标，并公开SDK当前heap占用、累计GC回收、次数/耗时以及进程peak RSS；这些不相互冒充。不将精确全进程对象allocated bytes/count或perf权限新增为原AC-031前置。外部微验证已证明NewArray8导出hook漏内联快路径，禁止用其不完整计数当总分配。cjprof当前权限失败仅限制热点采样，不限制wait4真实CPU测量。报告工具覆盖边界，不以“多项测试通过”替代总体证据。

M006：全部功能完成且M2产品实施前冻结完整M1基线，记录功能库源码/依赖/SDK/native/普通制品hash；公开benchmark源码由143/144后置交付并在146计量前冻结，不要求124前已有基准项目。TTY的M1/M2对照用同业务基准分别依赖两份固定普通包正常构建，无生产库模式开关。headless当前全局render与snapshot同库对照；timing不夹M1 oracle/equality/hash，避免其GC污染。correctness用业务barrier和同稳定批次，防两次API消费不同后台状态。大小至少80×24/160×48，所有第11节变化与全局退化均纳入。

M007：本候选已同步三诊断与限定分配口径，不把全进程精确累计分配追加为前置；无需再次等待该路线确认。Canvas/viewport/overlay路线已采用，但其正式合同版本和全部上游产品固定SHA仍在实施前补齐。没有独立preflight、冻结测试和上游最终通过产物时本任务不ready，不能越过共享Component/Layout写屏障。

M008：123–147预留为A算法分离、B行共享、Cdirty/cache、D局部合成、E公开bench五单元，每单元测试/产品/审查/执行/验收五独立角色。原TASK-031/022继续承担完整验收归属；所有单元依次集成固定产品，任何单元独自通过不等于M2/Linux完整通过。细化见tasks。

M009（交互root共同输入补充）：Application隐式root默认Vertical fallback：先按旧有限布局；无未显式处理的内容overflow时保持旧weights及offset0，只有overflow才执行第二次B2自然协商，最多两pass；显式viewport声明优先。M2缓存须区分有限初次协商与fallback有效输入，不能因上次无overflow永久忽略新文本overflow。全局render(detached)不创建隐式rootviewport；render(mounted root)沿R004当前同session消费已提交viewport/offset/层栈并作完整M1，无第二session、无M2cache读写。配对必须保留真实scroll/root fallback场景，不能为使两帧相等刻意去掉滚动。最终精确接口消费交互正式冻结SHA。

M010（统计构造兼容，源码核对优先）：固定c3d743d与本次读取的现HEAD的RuntimeStats构造为包内`init`，R008明确无公开构造；不因本变更新增public init。保留已有8个位置参数调用，建议精确形状如下（新尾参语法待正式SDK消费者编译；本次不改产品）：

```cangjie
init(mountedNodes: Int64, activeBindings: Int64, subscriptions: Int64,
     pendingPosts: Int64, builds: Int64, measures: Int64, paints: Int64, frames: Int64,
     arranges!: Int64 = 0, cellWrites!: Int64 = 0, frameAllocatedCells!: Int64 = 0)
```

同一个public RuntimeStats返回对象新增三个`public let`，旧8参数包内调用仍编译，外部只读消费保持。框架在实际生成处传真实新计数，不能长期用默认0代替计量；M1完整参考也累计实际成本。旧八字段及查询副作用不变，无benchmark隐藏清零。独立消费者核字段可读和无额外公开可变状态，构造可见性依固定R008而非误述。

## M011 Glyph布局生成策略与终端投影闭包

消费已冻结Glyph G001–G011和097实际接受源，不只消费ambiguousWide。目标Frame缓存、文本行/测量/绘制缓存的输入包含影响generatedEllipsis结果的有效policy内容（至少能区分该次可用宽度及统一宽度策略下的marker字符串/宽度）；不能只比较requested Auto枚举、policy对象地址或文本revision。模式变更的候选失效经有效输入比较，复用同一generatedEllipsis与Frame终端projection，不新造省略号/Unicode/终端Frame。

设备produce使用实际会话policy；offline snapshot/render默认Unicode、显式Ascii按G007分别进入同算法。一个持久缓存交替使用这些入口时不得返回另一个policy的前缀。无业务/尺寸/样式变更，Text("abcdef").overflow(Ellipsis)宽5、ambiguousWide=false的snapshot Unicode→Ascii→Unicode，手算结果abcd…→ab...→abcd…。M1/M2必须使用相同glyphMode、同稳定epoch逐完整Cell配对，不能拿两个模式不同的Frame当算法错误。

设备profile与逻辑生成policy是不同责任。只有终端glyph投影变了而生成marker不变时，可复用逻辑布局/Frame，后端仍使用新/旧各自完整profile；同style的中→文与中→??若投影同两列??，必须零grid更新。行身份相同只有profile投影等价才可直接跳过；profile变化重新比较实际投影，不自动全屏输出。133/138/143分别补cache交替、damage/profile及正确性/成本场景；普通文件默认逻辑Unicode保持。

## M012 M1功能库冻结与双版本基准源码的可编译分工

修正M006旧稿不必要的提前benchmark源码冻结要求：124之前固定的是功能齐全、尚无任何M2优化的M1库源码及普通cjp/依赖/SDK/native/示例证据，而不是尚未交付的benchmark项目。143/144在142后实现公开基准，146计量前冻结相同业务workload/公共TTY入口源码，再分别依赖已保留的M1库制品和最终M2制品正常构建。库基线不回填M2优化，不设置生产M1开关；原第11节workload矩阵现在已预先声明，不能测后只挑赢家。此路线不增加额外早期产品任务，也不形成144→124前置环。

公共benchmark构建边界精确为：`benchmarks/rendering/compat`正常独立CJPM入口及`benchmarks/rendering/workloads`共享库只使用完整功能M1已有公共API/原八Stats字段，同一份源码在旧/新两个普通库制品上构建（仅依赖manifest路径改动）。新三诊断在此共同入口的CSV均为not_available，不填0、不运行时探测不存在的成员；该入口不得import仅新版本诊断代码。

`benchmarks/rendering`主项目是最终库专用诊断/同库headless M1-reference-vs-M2入口，复用同一个workloads库，允许读取arranges/cellWrites/frameAllocatedCells并报告其精确范围。它只对最终新库编译，不能用运行时分支声称会避开旧库缺字段的编译错误。旧/新TTY真实CPU/heap/GC/RSS/output由共同compat入口及外部计量比较；新库的精确阶段/Cell槽收益另由同库两个路径证明，不混称旧库也测过新字段。

143正式测试分别正常构建compat+workloads对冻结旧M1/新M2，及诊断入口对新M2；144交全部独立manifest/公开源码/说明，145审核隔离与公平性，146保留每次实际版本/源码/原值，147按原022/031验收。功能M1普通制品此时可能尚无benchmark文件，不能称已经通过最终Linux release；完整023/024仍在最后。
