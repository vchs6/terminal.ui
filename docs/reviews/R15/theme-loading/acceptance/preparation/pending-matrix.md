# TASK092 待证矩阵

NOT_ASSESSED。32项等091最终原件，1项后续范围排除。静态capacity/overflow/Column轴一致性不冒新增runtime数量。

| ID / 合同 | 义务 | 待证内容 | 状态 |
|---|---|---|---|
| T92-01 / AC089–092 | 来源与角色 | 091 final源fa6/tests含3040111+71f9312、依赖/SDK/stdx/config、实际binary、command/UTC/exit与前后hash；原件→封存核对。 | pending_091_evidence |
| T92-02 / AC089 | 正式async-only RED/设施 | 真实foundation正向在先，async-probe缺load API RED独立；固定22case/真实SDK regular-file gate成功，声明-only不当执行。 | pending_091_evidence |
| T92-03 / AC090 | 审查与两轮闭环 | 完整090与round1/round2；I01从direct修到root/subtree约束身份、M01文档修；源码双PASS不能替091执行。 | pending_091_evidence |
| T92-04 / T006/T013/§2.2 | 公开接口/单向依赖 | ThemeSource/Result/Info/Request类型、两个Application入口、只读查询、无wait/cancel/hooks；root loader不使theme反向依赖。 | pending_091_evidence |
| T92-05 / T006/T007 | 初态/非活动/生命周期 | 初0/0、inactive load/reload立即SessionClosed无IO；accepted theme/history dispose后保留，重启id/revision不复用。 | pending_091_evidence |
| T92-06 / T006 | latest请求成功次序 | slow File/new Prepared/候选未提交换代；旧意图Superseded首个较新id固定，只有最新可commit。 | pending_091_evidence |
| T92-07 / T006/T007 | 新失败不复活旧成功 | new invalidFile/NoFileSource淘汰旧合法slow；保留最近已接受theme，旧终态不改。 | pending_091_evidence |
| T92-08 / T007 | 关闭/重启session fence | blocked真实IO与queued Prepared在dispose立即终结；旧worker后来完成不可污染新session，终态只写一次。 | pending_091_evidence |
| T92-09 / T006 | 有界worker/pending/mailbox | 源码090证明精确1active+1latestpending+1candidate；32files握手只最新实际读，关闭blockedworker不重开第二线程；不伪造内部counter实测。 | pending_091_evidence |
| T92-10 / T006 | post容量独立 | 满普通post队列overflow拒绝；有限theme mailbox仍可提交一次，不绕成无限积压。 | pending_091_evidence |
| T92-11 / T006/T008 | 锁/排序/无用户代码 | 090与固定源证明IO/parse/observer/usercode锁外、锁顺序、UI提交前id/session重核；无getter/build/mount replay。 | pending_091_evidence |
| T92-12 / T008 | 失败候选事务 | missing named/inapplicable/weight overflow/schema读错误在theme/info/cache变更前Failed；旧frame/theme/session仍可用。 | pending_091_evidence |
| T92-13 / T008/090-I01 | 实际checked minimum预检 | 同LayoutNode/allocateMain实际约束下Row/Column min sum检查，Max×0及0×Max无需巨分配；合法finite clip不误拒。明确runtime证据与axis-independent源码证明。 | pending_091_evidence |
| T92-14 / T008/090-I01-R2 | root/subtree extent | mounted child 1×1 render可处理候选但不得覆盖root Max×0约束；拒绝后旧Info0/0、refs/business/getter/mount及旧frame保留。 | pending_091_evidence |
| T92-15 / T008 | 当前缓存与原子布局 | IO阻塞时当前style引用改变，最后UI按最新stable cache验证；一帧同revision，全cell/style与active-root M1相同。 | pending_091_evidence |
| T92-16 / T008/AC026 | 身份与状态保持 | 成功/失败不重建Component/NodeRef，不改Observable业务文本/订阅、无unrelated getter/build/mount；后续真实focus/edit/scroll控件不先声称。 | pending_091_evidence |
| T92-17 / T008 | paint/layout缓存边界 | paint-only保持测量cache、几何变更清理；preview不替活tree/不写Frame、不冒零CPU成本，mask/fill/Glyph上下文不回归。 | pending_091_evidence |
| T92-18 / T007/§6 | accepted File reload | 只捕获当前已接受冻结File；失败/进行中File不改来源；外改无动作，成功preset/memory清源，Prepared(readFile)可恢复。 | pending_091_evidence |
| T92-19 / T007 | relative/source identity | 请求时cwd冻结绝对path，阻塞后chdir不能转向；sourceName似path的parse仍memory；同步parse/readFile不改变app。 | pending_091_evidence |
| T92-20 / T006 | 可观察非阻塞查询 | UI result/info绑定自动依赖和invalidate，background读不绑UI/不跑getter；单纯查询不pump或提交。 | pending_091_evidence |
| T92-21 / T006 | 事件/post与重入 | 普通callback可提交；getter/structure evaluation中load和reload均先拒ReentrantEvaluation且不分配/改主题。 | pending_091_evidence |
| T92-22 / T006/T007 | 多应用与并发请求 | 两个App真实同时进入各自文件gate、主题/请求序独立；八后台请求唯一顺序且maxid提交，共享Theme不可变。 | pending_091_evidence |
| T92-23 / T007/R017 | 清理错误与资源 | pending关闭，child/parent cleanup错误聚合，ref/post/binding/subscription释放；旧worker/失败cleanup不能污染restart。 | pending_091_evidence |
| T92-24 / T008 | 恢复错误分层 | read/path/UTF8/syntax/type/ref/capacity失败可恢复；业务异常在accept之后仍走原runtime清理，已接受Info/Applied不回滚。 | pending_091_evidence |
| T92-25 / T008/backend | 实际设备输出失败 | 真正设备写失败发生在theme acceptance后，原writer/restore/error路径有效且Info/Applied不回滚；callback exception不冒device故障。 | pending_091_evidence |
| T92-26 / T007 | 计数上界静态证据 | requestId/revision UInt64无wrap且先检查后变更；引用090源码证据，无公开seed、不伪造实跑UInt64域；继承runtime其他耗尽限仍保留。 | pending_091_evidence |
| T92-27 / AC091 | 实际22case完成 | 真实binary exit0+PASS CASE+controllerError null，各新process/gate events有序、无timing-success；最新atomic追加被实际调用。 | pending_091_evidence |
| T92-28 / AC091/AGENTS11.1 | 原有效回归 | 080084088152097等按source/deps/env/scope复用；对新增layout预检/调度/异常的受影响范围给新证据，不机械冷重跑旧suite。 | pending_091_evidence |
| T92-29 / T012/AC091 | 正常bundle/lint/CJP | finalfa6正常bundle原argv/exit/lint；实际全member字节等fixed源/presets，member记录不代替打开包。 | pending_091_evidence |
| T92-30 / T012/AC091 | clean SDK/stdx consumer | 正常解包库与纯公开load消费者只manifest路径改动，实际build/directexit、source/deps/config完整，不借作者target/cache。 | pending_091_evidence |
| T92-31 / AC092 | 元数据/原件/失败保留 | strictJSON/commands/env/native原件/hash/退出/省略理由，metadata与功能分开，保留失败尝试和既有身份限制。 | pending_091_evidence |
| T92-32 / AC026/092 | 说明与最终投影 | 文档已交付load/request/info语义符合UI提交/acceptedFile边界；逐mustpass证齐后再接受async有限scope，不直接改main状态。 | pending_091_evidence |
| T92-33 / TASK023/027/Linux | 明确后续排除 | T087-G01仍最终023 wholechecker themesallowlist/composition/benchmark门禁；027全控件、完整Linux/M2/release不由本轮关闭。 | excluded_followup_scope |
