# Persistent reactive runtime implementation plan

> For agentic workers: REQUIRED SUB-SKILL superpowers:subagent-driven-development；连续执行本单元后继续Linux总计划，不重复询问已授权实施方式。

**Goal:** 原生声明式组件持久挂载，状态/通知安全更新，同序列动态结构。
**Architecture:** 单一Component/Runtime/LayoutNode/Frame，ThreadLocal构造与依赖收集，代际句柄和UI边界提交。
**Tech Stack:** 仓颉SDK1.2.0、既有中心仓三依赖、产品0.0.0；原生macro子包，无新运行时。
**Spec:** design.md（第6节优先）、REQ001/002/004.8/009.1；Linux总计划L001/L002及本变更R001–014。

## Global constraints

每类型一文件，纯函数按职责；主代理不写正式产品/测试。独立角色隔离目录/上下文，只交契约和固定源码/测试/raw，不交作者推理或自评。既有公开消费者不破坏，单一Frame/Unicode/ANSI路径。不得以部分交付关闭014/002/004或Linux。原稳定TASK状态留docs/tasks，本变更支持071–080为唯一状态；稳定完整任务在实际AC满足后再投影。本变更不新增焦点/overlay/主题/M2假实现。

## Review focus

1. 后台写入/订阅安装竞态与持续生产者：版本复核，不丢最后一次更新，不因后台变化误报同步循环。
2. 同对象多会话/卸载重挂：build只一次，旧句柄不复活，订阅/队列/事件释放。
3. 构造/生命周期异常和ThreadLocal恢复：后续无串树，所有清理继续且真实终端恢复。
4. 动态依赖/相等结果/显式通知：替换旧订阅，只求值受影响getter；idle无布局绘制。
5. 混合槽位/锚点/多组同key：一个真实子序列，原manual保留，错误不半提交。

## Tasks / state

- [ ] TASK-071（WP005/testing）：固定A+B公共消费者、宏正负样例与原始RED。
- [ ] TASK-072（WP004/implementation）：实现A+B构造/绑定/代际/事件最小协议/调度，与run集成并交付公开动态示例。
- [ ] TASK-073（WP005/verification）：固定A+B完整技术diff的spec/quality独立审核，无未决Critical/Important。
- [ ] TASK-074（WP005/testing）：独立运行A+B新用例、受影响回归、正常bundle/纯公开包消费及真实TTY清理。
- [ ] TASK-075（WP005/acceptance）：有限合同证据及元数据核对，不提前关闭列表/弹窗父AC。
- [ ] TASK-076（WP005/testing）：固定C槽位表、混合/失效/边界独立测试与RED。
- [ ] TASK-077（WP004/implementation）：实现If/ForEach/ListItem和NodeRef混合操作，唯一子序列。
- [ ] TASK-078（WP005/verification）：固定C增量和整体运行时跨界spec/quality独立审核。
- [ ] TASK-079（WP005/testing）：独立C矩阵、A+B相关回归和正常源码制品消费。
- [ ] TASK-080（WP005/acceptance）：AC015/016/032符合原范围才关闭，014仍等018；主代理集成后继续Linux。

## Shared L3 admission card

各TASK为L3：071/073–076/078–080父WP005/REQ007；072/077父WP004/REQ001/002/009。分类execution：用户已确定运行时目标；可逆精确接口经独立设计草稿与主代理R001–014裁决，不重开产品方向。具体change为本目录，workflow为本tasks，skills为using/TDD/SDD/receiving-review/systematic-debugging/verification（按角色适用）；实际调用在progress记录。模型071/076 Sol high，072/077 Terra high，073/075/078/080 Astra high，074/079 Sol medium，指定配置和实际不可独立核验区分。

输入：6a7b240已验Frame/Layout/Style/Unicode/能力/设备恢复、design精确接口与独立语言/正常宏CJPM证据。完整上游001–004/008/013按R001分段准入，不伪称父任务完成。071准入为独立preflight通过本合同；072依赖071固定测试；073依赖072固定产品；074依赖073；075依赖原始执行与审核。076消费已冻结C合同可与072并行写测试，但旧产品RED在A+B集成固定后取；077依赖075/076；078→079→080顺序。全部证据有source/hash/命令/实际exit。

scope/impact：组件构造、宏、绑定、节点生命周期、应用循环及布局读取；C增加动态组/结构命令。排除完整键盘解码、焦点/滚动/覆盖层、主题和M2。compatibility：现有Text/Row/Column/属性/设备恢复及旧onKey行为保留；新重载typed，不吞非法源码。必要性：原静态每tick全树不能满足状态/身份。canonical owner：Component声明、RuntimeSession挂载/UI调度、Observable槽、ChildSequence实际顺序、LayoutNode布局、Frame绘制；无第二渲染树。

旧路径：global parents+Mutex→ThreadLocal collector，Application无条件poll render→dirty/resize，新RuntimeSession替换而非旁路；原LayoutNode/Frame/Style/Unicode/ansies保持。复杂度：新增挂载身份/依赖图/队列是需求必要状态，禁止重复child列表权威或控件私有内核。风险：宏源码定位、线程重入/锁、清理掩盖native错误、连续后台流、结构失败，Review focus逐项映射测试。

## Files / interfaces / L4

071：创建`tests/runtime/cjpm.toml`、`src/main.cj`及按实体拆分的helper、宏negative独立fixtures、run.sh；扩展`tests/run-slice.sh runtime`和tests说明。消费design A+B及R001–012/014。独立固定期望：build次数/cleanup顺序/文本与帧字节/路由trace/不同线程ID/旧ref无效/统计增量；先旧产品正常build再直接编译/执行取缺API RED，记录stdout/stderr/exit/hash，冻结test-only提交。不以产品getter生成期望。race使用真实可控同步，不用任意sleep掩盖。

072：修改`src/component.cj`、`application.cj`、`layout.cj`、`layout_node.cj`、`key_event.cj`、`exports.cj`按需要；新增design2.3/3.3各实体文件及`src/macros/{component_macro,state_macro,bind_macro}.cj`，一个类型一文件。单一collector→一次build→代际/cleanup→Observable typed绑定→调度→render/run桥接；正常编译精确公共API与泛型/接口/带参init，固定测试和必要受影响回归；更新`docs/product/README.md`和`examples/reactive`（正常CJPM公共依赖）。product-only提交，正常lint不跳过；不改固定测试和规范以迎合实现。

073：仅固定baseline..product/tests/spec，独立审查而非作者报告，具体反例/责任位置；双verdict。缺陷先回主代理归属，由测试作者补必要RED、实现者修，再只复核受影响内容。074：自己的忽略registry配置/缓存，正常build后直接binary，记录真正exit；复用相同内容有效旧证据，不因角色/提交反复全套；新run要真实TTY证明idle和异常恢复。标准bundle不skip，解包消费者只改manifest path，用同冻结源。完整release尚有后续example/benchmark时明确不足，不冒充全阶段pass。

075：逐合同和原件/hash/制品/实际版本/元数据独立核对；不重复有效suite。证据归R12。支持AC071–075有限结论，稳定AC完整条件仍按R001。

076：`tests/dynamic`公共消费者/run入口、手工槽位表golden；消费design4/R013。覆盖A X B C全部表、同key新T、两个group同key、移marker外、空组再加、remove源仍有key后Structure重建、重复key/根数/锚点/跨父/双挂载/重入/限额/失败清理；固定test-only版本。077：`dynamic_group.cj,list_item.cj,child_sequence.cj,structural_command.cj,keyed_reconciler.cj,conditional_group.cj`按实体必要划分，移除临时children权威重叠，布局/事件读提交序列；同固定测试、product-only提交。078–080职责、顺序、raw/hash/制品与前单元相同，另核所有A+B→C跨界和原AC015/016/032完整条件，证据归R13。

## Preflight / DQ

主代理自检：A+B生命周期/绑定耦合，C可独立验收，故分两个代码单元；测试/实现/审查/执行/验收均有独立输入输出及可观察条件，不按文件拆假任务。宏与库同名、参数/泛型/接口、namespace/ThreadLocal/WeakRef已实际微探针，完整签名仍需正式正常CJPM编译。无依赖图环；完整父AC待汇合标明。每个Review focus在071或076有明确断言，文件/职责/退役/兼容/技术风险/状态唯一权威齐全。独立preflight逐DQ01–14核对并提出具体缺口，未通过不得派产品。
