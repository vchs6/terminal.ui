# TASK150 独立源码与质量审查

审查结论：**spec PASS；quality PASS，仅限本次固定 Session 增量。未发现未关闭的必修产品缺陷。** 这不是 TASK151 真实宿主执行、TASK152 验收、TASK030 完整集成或完整 Linux 发布通过。正常 bundle 存在 331 条 advisory；既有 full-boundary 缺 composition/benchmark 的 exit 1 不因本结论消失。

审查对象为 `04a5289361d990e5a340ace22bbd50c9b805a9d9 → 83094ca92acab37ed0a38042e2e40ead55049f41`。产品 commit 的父提交 `3c564b34de004ccceab67516a1f7f82894e76fe1` 是正式测试命名空间修复；其测试树与官方 `47d267fe802dcb817b4f95247eac18a4a30c2fab` 均为 `82e3bfcf8898dede884832f2fb73890ca66a7329`。产品 commit 本身仅改 25 个产品/示例/产品文档文件，没有改测试。完整两 commit 技术包与独立 `git diff -U10 BASE HEAD` 逐字相符，包 SHA256 `aff5103003d42ae58b6909a800e4186f088b13794a2a7f84de4f3202878f66d1`，`git diff --check` 退出 0。

正式 S001–S012 与 delta、AGENTS（尤其 11、13、14）、仓颉工程约定逐项读取。设计 SHA256 `46c6b199510d7aa4ee2ce62ccf56883f8120009be1d4060421b306dba3c91a73`，delta SHA256 `1bbb35d3191567ca91f076d2206b51f4e76170536f80b3b1701fc33c0bcd6b0b`。文档首部历史“草稿”措辞没有被用来取消 root 冻结的契约。初始正式测试为 `4093a7ab146f01ac60e0e447a487eaac55f82677` 加官方命名空间修复；S007 补充尚未作为本报告的冻结输入，以下 S007 结论由正式原文、独立源码推演和原始 wire 断言形成。

角色隔离：独立目录 `/workspace/work/session-extension-review`；通过 `git archive` 从固定 HEAD 取源码。没有读取产品作者报告、progress 或自评，没有与作者沟通、派出子代理、修改产品/正式测试/main/status。原始开发执行日志仅作有范围的证据复用，没有把作者结论当作审查结论。当前 serving model 无可验证证明；不自证模型身份。技能实际读取并应用 requesting-code-review 的固定输入与独立审查原则、verification-before-completion 的证据要求、cloud-environment-runtime 的环境确认；using-superpowers 明确对受派子代理停止。按 root 禁止再次派代理。无已确认故障须进入产品修复调试，未启动 systematic-debugging 修复流程。

独立重新建立的调用链是 `Application.sessionOperation → RuntimeSession.requireContext → SessionExtensionState → writeTerminal → cjt_buffer_write → write(STDOUT_FILENO)`。屏幕帧也走同一 `writeTerminal`。源码搜索及实际读取没有第二 writer、队列、运行时、设备控制子进程、剪贴板 query、原始 ANSI 公共入口、OSC0/OSC1 图标替代或 TERM 证明支持的逻辑。构建脚本中已有 Process 是开发构建入口，并非运行时会话路径。

| 审查义务 | 独立依据与判断 |
|---|---|
| S002/S003/S011 公共调用与结果可信度 | 七个 Application 方法和全部公开字段符合冻结形状。Options 内部只读；capabilities 是由全只读叶值组成的快照，通过 sessionLock 读，跨线程不可变共享安全。无会话返回 id=0；成功 open 后、mount 前建立真实设备快照。Auto 从 device/policy 出发保持 Unknown；DeclaredSupported 只是 ExplicitConfiguration。所有发送分支只能产生 SentUnconfirmed；Applied、VerifiedAdapter、RestoreConfirmed 仅类型保留，无构造成功路径。None 未污染根命名空间。 |
| S004 严格输入与资源界限 | `session_encoding.cj:33` 先 SDK `String.fromUtf8`，拒绝后才用定位器找首个失败标量，不用定位器替代 SDK 校验。随后按 bytes 检查 65536/1024，title 拒绝 C0、DEL、C1。copy 控制字符只进入标准 Base64；空串为固定空 OSC52。icon 只查 1048576 上限，不解码。有效字节预算先限定编码输入，最大 copy wire 为 Direct 87392、tmux 87402、screen 87396，均小于 90000；64 位长度运算由前置小上限排除溢出，不能用不可构造私有 enum/巨型数组伪造额外可达路径。诊断无用户 payload。 |
| S005 单层包装 | Direct、Screen 和 Tmux 三个穷举枚举分支，inner 为固定内部生成序列。tmux 按每个 ESC 加倍、固定 ST 两字节；screen 固定四字节开闭开销。title 的 ESC/C1 被拒绝，copy 只有 Base64，故用户数据不能注入 wrapper。没有嵌套输入、mux socket 或配置修改。 |
| S006 所有权与调用边界 | `application.cj:68` 先 requireContext，覆盖 owner thread/nonce、另一 active session、getter 和结构 evaluation，再拒绝 lifecycle；此时返回 InvalidContext 而非隐式调度。inactive 结果独立。事件、post、batch 和外层 owner 可同步调用。沿用既有 4096/FIFO/cutoff/NodeRef 规则。getter、mount、cleanup、后台调用均在发设备字节前拒绝。 |
| S006 stop 与事务顺序 | `terminal_bridge.cj:50` 在同一 RuntimeSession.lock 下检查 stopping 并开始 native write；requestStop 用同锁。stop 若先获得锁，则零输出 Cancelled；写入若先获得锁，则完整处理本序列，不能把已经完整发送改成 Cancelled。首次 title push 后 set 使用 checkCancel=false，保持整个 save+set 逻辑事务。唯一 UI owner 避免其他 frame/extension 插入；锁不是第二输出调度器。 |
| S007 ledger | `session_extension_state.cj:114` 完整构造两个 wire 并 reserve 最大 native buffer，才发送首次 push；push 成功立即拥有 titleScope，再发 set。重复 set 不 push；完整 pop 才释放；再次 restore 为 NoSavedTitle/NotNeeded；下一 set 重建 scope。Unknown stack 不 push/pop。正常 stop、异常及零字节 write failure 的内部 cleanup 绕过普通 API Cancelled，仅在 outputUnsafe=false 时 pop。未知原标题只记 Unavailable，不猜标题。 |
| S008 准确 native 计数与永久安全闩 | `native/cjtui_terminal.c:95` 逐次成功 write 累加 size_t at，并更新 Int64 emitted_bytes；每次调用开始归零。允许正短写与未 interrupted 的 EINTR 重试；其他失败结束。本次 at>0 才设原子 output_unsafe。close 只恢复 termios/signal/free/active，不清该闩；open 前后均检查，禁止同进程 reopen。zero-byte failure 不污染 parser，可在本 run 停止 close 后另起 run。 |
| S008 首错、停止与 R10 | send 检出实际 writer fault 后先 recordDeviceFailure/requestStop，再给用户 Failed；后续普通调用 Cancelled。stabilize 的最外安全回归点抛首错；pump 停止后丢后续 turn 工作，不再 poll。callback 再抛、UI cleanup 再抛、title 再失败及 native close 再失败均保留主错误并聚合。run 的 protected block 包含检测/挂载/业务/编码，dispose 的异常不会绕过后续 native close。 |
| S008 分配与屏幕基线 | native buffer_add 在 write 前失败返回 AllocationFailed，不设设备首错/停止/unsafe。`application.cj:442` 只有完整 write 才提交 frame/profile/dimensions；allocation failure 置 baseline=None，下轮即使没有新 invalidation 也因 baseline.isNone 重试，避免“会话健康但画面永远不重试”。扩展操作不置脏、不改屏幕 baseline。 |
| S009 未来 cut 边界 | 无 Applied 生产路径，故本 API 不授予默认删除许可；产品文档明确 SentUnconfirmed 保留源文/选区。此任务没有伪造 editor revision/selection/undo 或完整 paste 验收。 |
| S010 职责与质量 | Application 持公共配置与生命周期，RuntimeSession 托管小 ledger，encoding 纯函数局限在冻结协议，native 独占设备/故障闩。既有 Frame/ANSI/Unicode 核心继续复用。Base64 为已批准的最小 RFC4648 实现。没有新依赖或冗余兼容入口。独立扫描所有 src 仓颉实体，每文件最多一个 class/struct/interface/enum。 |
| S012 深层别名 | SessionResult 构造先 clone steps；保存 cleanup 时 value.copy；每次 cleanupSnapshot 和 Application getter 再按项复制 SessionResult/steps。StepResult 所有字段是不可变值。调用者替换 steps 元素或 cleanup 外层元素不会反写 ledger 或下一次查询。不可变 capability 引用复用安全。 |

重点反例核查不是单纯复述通过数：

- **push 完整 + set 零写故障**：独立读取原件 `038-fault-set-Direct-0`、`125-fault-set-TmuxPassthrough-0`、`230-fault-set-ScreenPassthrough-0`。每例结果为 save SentUnconfirmed + set WriteFailed，API 合计只含 save；close 的 cleanup pop SentUnconfirmed。完整 all-wire 长度依次为 14、34、22，即一个 push + 一个 pop，无 title 数据、无额外写；native 记录先成功 save、失败 set、成功 pop，之后 close。run 抛 device failure；后续普通 copy Cancelled；无 poll-after-fault；before/after termios 字节完全一致。原 oracle 对此处仅检查 prefix 的较弱覆盖没有被当作豁免。
- **push 完整 + set 写出一字节即失败**：对应 039、126、231 原件，全 all-wire 恰为 save 加一个失败前缀（8、18、12 字节），cleanup 为零字节 ParserUnsynchronized，未发送 pop 或其他恢复控制，same-process reopen 拒绝。这直接排除误用安全清理逃过 unsafe 闩的反例。
- **忽略 Failed 后再抛 callback/UI/native 错误**：275 聚合原件保留 device ParserUnsynchronized 为 primary，额外三个错误为 late callback、UI cleanup、native restore。276 业务先错原件保留业务主错，safe title pop 仍完成，UI/native 错误附加。源码上的 prioritizeFailure、closeFailure 与 run 聚合路径符合这些原始记录。
- **allocation 后没有新的业务变化**：独立追踪 baseline=None 的 loop 条件，故下一轮仍尝试输出；已有 screen-allocation-green 原始执行日志记录 exact termios 恢复与真实 exit 0。此处只声称 native buffer 分配 seam，不声称可恢复仓颉进程 heap/OOM。

新执行的是只读/重分析验证，而不是再次构建全部产品或重复跑 277 配置：`node verify.mjs`，cwd `/workspace/work/session-extension-review`，UTC `2026-11-10T23:19:50.512Z`，退出 0，40 项检查无失败。它重新计算固定源、正式测试、contract/native/runtime、seed 依赖、当前实际 native/consumer binary、原始 manifest 和 CJP SHA，检查实际解包 member 与 source 内容，重断言上述六例 all-wire/termios/cleanup，以及正常 bundle advisory 数。完整结果在 [independent-verification.json](raw/independent-verification.json)，固定对象与 diff 校验在 [git-boundaries.json](raw/git-boundaries.json)。检查命令、逐项结果、对应输入 hash 均保留，不把日志中的 timing 当作时序证明。

原始 build-final、session-final、bundle、clean-consumer-build/pty、native-session、runtime-core、runtime-session-final、application-lifecycle-final、colors、capabilities 的 `.exit` 均为 0；已对其 `.log`/`.exit` 留 SHA，并核 fixed product、tests、dependency 内容一致后按 AGENTS11.1 复用。runtime-session 原件包含 expected abnormal binary exit 1 的恢复场景，这些不是产品“全都 exit 0”。初始 clean-source-match 曾因包不含 `src/.gitkeep` 返回失败；之后显式 packaged manifest 对实际源码校验通过。空目录占位文件不是运行源码，不能把原始失败删掉或描述为最初无失败。未新增 registry、SDK、依赖或假 production stub。

实际 CJP `/workspace/work/session-extension-implementation/source/target/cjtui-0.0.0.cjp` SHA256 为 `b2a5b5e19f67058adf0f4d6f6b4e130af8454e6b72f66aaa8c09c87cf6435d54`；独立解包确认必要 session 源码、native、产品文档和公开 example 在内，正式 tests、openspec、target、ELF/archive/object 构建产物不在包中。CJP 仅外部原件 hash 标识，不复制进 curated review。实际 consumer SHA256 `d234f7ae7ee3df220a4a1b9fb34151e4ad7a43a3c1caf9c3ce063cf7688dffa9`，source 和 packaged source 匹配校验完整通过。

质量分级：Critical=0、Important=0、Minor=0。331 条正常 bundle 警告被保留并独立计数；其中 session 相关包括局部变量作用域、函数/参数数量建议、异常 API 文档和等号重载建议。结合正式公开字段/枚举和冻结设计逐项审查，未发现由这些建议指向的具体功能反例或必修结构违约；不因机械函数行数阈值拆分 ledger。公开文档已有异常/生命周期/失败语义，局部变量与枚举比较并未另起内核。质量 PASS 不含“零 warning”声明。

剩余范围：真实 XTerm/VTE/tmux/screen/SSH/native VT 的实际产品执行与效果、原始 PNG/native grid/clipboard/icon/termios、完整高层 editor/input/平台/发布门禁仍由 151/152 及其后任务分别判断。没有把开发 PTY wire 或声明 Supported 当作宿主效果确认；没有越过已知 full-boundary 的 composition/benchmark/checker 缺口。无需产品修改即可关闭本次源码审查；若 root 冻结新的 S007 测试，只需追加其版本与相应最小验证，不重复未变化的全套产品运行。

保留与省略：本目录的 `source/`、`package-inspection/` 是本地只读审查副本，不作为 curated 交付；原始 CJP/ELF/CJO/SDK/cache/整 checkout/整份源文档/私钥均省略。`reviewed-hashes.json` 对所有被依赖原件保留绝对路径、内容 hash、来源和省略理由；`artifacts.sha256` 只覆盖本角色报告、findings、核验脚本与有限 raw。正文源码定位是固定版本路径及行号，不用指向日后省略 checkout 的相对 Markdown 链接。
