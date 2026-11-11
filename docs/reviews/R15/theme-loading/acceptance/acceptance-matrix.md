# TASK092 独立逐项验收

PASS_ASYNC_SCOPE；32项当前义务满足，1项后续范围排除且保持OPEN。E = `/workspace/work/theme-load-execution`；090 = `/workspace/work/theme-load-review`；fixed = fa6a46e。证据路径的花括号表示并列文件，不代表新增执行。

| ID / 合同 | 义务 | 结论 | 原件与判断 |
|---|---|---|---|
| T92-01 / AC089–092 | 来源与角色 | PASS | 091 manifest/command pre-post + own raw/verification.json；14组命令的274源记录稳定；final源/78正式输入/11环境文件/375依赖与371 stdx/ELF绑定核对，276原件和副本逐字节封存。 |
| T92-02 / AC089 | 正式async-only RED/设施 | PASS_REUSED | R15/async-red/raw/{foundation,async-probe}/commands.jsonl; E:raw/async-all；旧8d foundation实际0后async API缺失RED1；本轮foundation/API实际0和22行为case完成。all模式不额外执行独立infrastructure case，不虚增计数。 |
| T92-03 / AC090 | 审查与两轮闭环 | PASS | 090 report + round1/report + round2/report; E:raw/async-all/detail/atomic-caches.stdout；两轮I01修复与M01文档闭环；final双PASS、0 C/I/M，与本轮实际原件相互印证。 |
| T92-04 / T006/T013/§2.2 | 公开接口/单向依赖 | PASS | fixed src/theme_request.cj, src/theme_loader.cj, src/application.cj; E:raw/async-all/detail/async-api-build.*；只读公开异步接口与root所有权符合冻结契约；实际公共API编译通过，包消费者亦通过。 |
| T92-05 / T006/T007 | 初态/非活动/生命周期 | PASS | E:raw/async-all/detail/{lifecycle,queued-restart}.*；初态、inactive立即终态、dispose保留accepted历史及重启单调id/revision均有实际断言。 |
| T92-06 / T006 | latest请求成功次序 | PASS | E:raw/async-all/detail/{latest-success,candidate-order}.*；真实文件gate及UI提交前换代证据；旧请求Superseded首个新id稳定，最新意图独占提交。 |
| T92-07 / T006/T007 | 新失败不复活旧成功 | PASS | E:raw/async-all/detail/latest-failure.*；较新失败淘汰旧合法slow结果且不复活；已接受主题/终态保留。 |
| T92-08 / T007 | 关闭/重启session fence | PASS | E:raw/async-all/detail/{session-fence,queued-restart,cleanup}.*；阻塞IO与排队Prepared跨关闭立即终结，旧worker晚到被session fence拒绝。 |
| T92-09 / T006 | 有界worker/pending/mailbox | PASS_SOURCE_AND_RUNTIME | 090 final source; E:raw/async-all/detail/{pending-bound,session-fence}.*；精确1active+1pending+1candidate由源码证明；32文件请求实际只进入old和最新pending31，晚到worker仍占槽。无内部计数实测声称。 |
| T92-10 / T006 | post容量独立 | PASS | E:raw/async-all/detail/post-capacity.*；普通post溢出拒绝，独立有界theme mailbox仍提交一次。 |
| T92-11 / T006/T008 | 锁/排序/无用户代码 | PASS_SOURCE_AND_RUNTIME | 090 final source; fixed theme_loader/application; E:raw/async-all/detail/{getter-reentry,build-reentry,current-cache}.*；检查锁序、锁外IO/parse/用户通知及提交前session/id重核；运行证据不冒穷举调度证明。 |
| T92-12 / T008 | 失败候选事务 | PASS | E:raw/async-all/detail/{candidate-order,atomic-caches,recoverable}.*；missing/inapplicable/weight/schema等可预见失败先于theme/cache提交，旧frame与session保留。 |
| T92-13 / T008/090-I01 | 实际checked minimum预检 | PASS_SOURCE_AND_RUNTIME | 090 round1+round2; E:raw/async-all/detail/atomic-caches.stdout；final实际direct Row最小值溢出拒绝与finite clip成功；Column同checked allocator预检按轴一致源码与090证据闭环，不声称本轮新增Column用例。 |
| T92-14 / T008/090-I01-R2 | root/subtree extent | PASS | E:raw/async-all/detail/atomic-caches.stdout; fixed src/layout.cj；实际mounted subtree 1×1处理候选仍使用root Max×0；InvalidCandidate、旧Info0/0、节点/状态/getter/mount/frame保留。root identity guard不会被subtree改写。 |
| T92-15 / T008 | 当前缓存与原子布局 | PASS | E:raw/async-all/detail/{current-cache,atomic-caches}.*；IO期间变化的当前stable样式缓存参与最后验证；原子布局/frame/revision及M1对照实际通过。 |
| T92-16 / T008/AC026 | 身份与状态保持 | PASS_FINITE_APIS | E:raw/async-all/detail/{atomic-caches,lifecycle,current-cache}.*；Component/NodeRef/Observable业务状态与订阅身份保持；仅当前API，未把缺席的完整focus/edit/scroll控件算通过。 |
| T92-17 / T008 | paint/layout缓存边界 | PASS_SOURCE_AND_RUNTIME | 090 preview/cache analysis; E:raw/{async-all,layout,theme-integration}；paint-only保留live测量缓存、geometry清理；preview独立树不写Frame且无getter/build/mount重放；preview仍有CPU开销。受影响layout/Theme新跑0。 |
| T92-18 / T007/§6 | accepted File reload | PASS | E:raw/async-all/detail/reload-origin.*；reload只冻结accepted File；失败/进行中File不替换来源，memory/preset清源，Prepared(readFile)保留来源。 |
| T92-19 / T007 | relative/source identity | PASS | E:raw/async-all/detail/{relative-origin,synchronous-values,reload-origin}.*；cwd请求时冻结、sourceName不冒文件、同步解析不自动提交的实际断言通过。 |
| T92-20 / T006 | 可观察非阻塞查询 | PASS | E:raw/async-all/detail/observability.*；UI只读查询自动依赖/失效；background查询不绑定UI、不执行getter、不pump提交。 |
| T92-21 / T006 | 事件/post与重入 | PASS | E:raw/async-all/detail/{event-post,getter-reentry,build-reentry}.*；callback/post正常提交；getter/structure中load/reload预先ReentrantEvaluation，id及已接受主题保持。 |
| T92-22 / T006/T007 | 多应用与并发请求 | PASS | E:raw/async-all/detail/{multi-application,background-race}.*；两个App同时进入各自真实gate，八后台请求id唯一且max提交；不夸大为任意并发穷举。 |
| T92-23 / T007/R017 | 清理错误与资源 | PASS | E:raw/async-all/detail/cleanup.*; E:raw/device-pty-bound；cleanup异常聚合、关闭pending、引用/订阅/绑定/posts释放；真实PTY失败后资源全0。 |
| T92-24 / T008 | 恢复错误分层 | PASS | E:raw/async-all/detail/{recoverable,exception-boundary}.*；读取/格式/容量失败可恢复；accept后业务异常按runtime清理且Applied/info不回滚。 |
| T92-25 / T008/backend | 实际设备输出失败 | PASS_CONTROLLED_REAL_PTY | E:raw/device-pty-bound; E:device-observation; raw/verification.json detail.device；真实PTY先正常frame后接受主题，writer实际4字节再受控EIO；Applied1/info1保留，termios/3 handlers/close恢复，资源0。ParserUnsynchronized、visual state not restored明确保留；非自然故障或GUI视觉证明。 |
| T92-26 / T007 | 计数上界静态证据 | PASS_SOURCE_ONLY | 090 final source; fixed theme_loader/theme_request；UInt64上界检查先于请求/版本变更，禁止wrap；没有public seed，不伪造遍历计数上界实跑。 |
| T92-27 / AC091 | 实际22case完成 | PASS | E:raw/async-all/detail/commands.jsonl + per-case stdout/stderr/events; raw/verification.json；全部22 actualexit0、sentinel正确、controller_error null、真实gate顺序/enter/release完整；另clean2条为重复代表case，不作24唯一用例。 |
| T92-28 / AC091/AGENTS11.1 | 原有效回归 | PASS_SCOPED_REUSE | E:raw/reuse; previous080084088152097 accepted records；211/213与213/213及早期6路径差异有明确对照；旧无pending候选行为有限复用，当前22/layout/Theme/device覆盖新路径；未冷跑旧suite/PNG。旧C1时序限制不变。 |
| T92-29 / T012/AC091 | 正常bundle/lint/CJP | PASS | E:raw/bundle; E:raw/package/member-inventory.json; raw/verification.json detail.package；正常mandatorylint bundle0，508 warnings原样保留；实际打开CJP全部184文件字节==fa==clean展开后源，四preset包含。整包checker另项仍OPEN。 |
| T92-30 / T012/AC091 | clean SDK/stdx consumer | PASS_FINITE_PACKAGE_RUN | E:raw/{clean-library-build,clean-consumer-build,clean-async}; E:tools/clean-run.py；clean库与完整正式public consumer各build0，仅依赖路径变；正式run_controlled+同gate实际latest-success/atomic-caches各0，未称clean重跑全部22。 |
| T92-31 / AC092 | 元数据/原件/失败保留 | PASS | raw/final-metadata.json; E:raw/device-build; E:manifest.json；strictJSON/原件hash/exit/身份分别核；初始None harness编译1保留，sole Option资格修正后0；2252元数据/原始断言复核不当成2252产品测试。 |
| T92-32 / AC026/092 | 说明与最终投影 | PASS | fixed docs/product/theme.md; canonical design; this report/matrix；产品说明同步值与load/request/info/acceptedFile边界一致；允许root投影026及089–092有限完成，当前pending状态等待机械投影而非功能缺陷；本角色不改主仓。 |
| T92-33 / TASK023/027/Linux | 明确后续排除 | EXCLUDED_OPEN | TASK092 brief; prior088 T087-G01; E:raw/identity/fixed-inputs.json + raw/package/member-inventory.json；T010要求themes，与旧023 checker allowlist冲突及composition/benchmark缺项仍OPEN；027全控件展示、wholeLinux/M2/release未验收。 |
