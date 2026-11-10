# TASK150 S007 正式测试有限补充审查

**spec PASS；quality PASS；必修 findings=0。** 固定范围 `47d267fe802dcb817b4f95247eac18a4a30c2fab → f8b95815616c850145b647aae57e082c7915dab0`；测试子树 `4bf3044fb7c3a64d0e918455401f4cf214b26638`。这仅接纳测试补充进入 TASK151，不声称四个受影响配置已经由独立测试执行角色运行，也不改变主报告对固定产品 `83094ca92acab37ed0a38042e2e40ead55049f41` 的审查边界。

独立读取完整 6 文件、177 增加/2 删除技术 diff；与 `git diff -U10` 逐字一致，父提交和六文件 hash 已核实，`git diff --check` 退出 0。未读测试作者 report/progress/推理；仅消费固定测试、被允许的原始设施记录和 hash/summary 元数据。没有改源码/正式测试，没有派出子代理。源码来自本目录 `git archive` 副本，不依赖作者的未提交文件。

新增 `verifySafeSetCleanup` 只在既有 `fault-set` offset=0 分支生效。严格要求：wire 完全等于本路由 save+pop；set 结果为 Failed/WriteFailed，bytes 等于 save，两个实际 step 分别为完整 save 和零字节失败 set；后续普通 copy 为 Cancelled；恰有一项 cleanup，第一次和深拷贝重查都带正确 restore step、byte count、SentUnconfirmed/RestoreSentUnconfirmed。native 观测要求序列 1 成功、2 在 0 byte 失败、3 成功，pop 在第一次 native close 之前，实际 close=0，之前写入总量等于 save+pop。仅对具体故障夹具的观察编号做断言，不绑定产品私有 ledger 或错误文本；不允许控制的 callback/UI/native/assertion/post 错误替代设备主错。

这些断言直接来自 S007 已有的“完整 push 即拥有需释放 scope”及 S008 首错/安全清理契约，未因产品当前实现生成预期值。期望序列沿用独立金标准；新 selftest 另用 Direct/tmux/screen 手写十六进制向量检查。Native fixture 的新增 safe-set 分支只是顺序喂入三个字节文件到原生既有 writer，使用旧 `session_fault.c` 的 sequence2=EIO@0 注入；它没有 SessionResult、Application 或伪造恢复实现，不能独立证明产品清理正确。正式公共消费者和其 fault/cleanup 场景完全未改。

原 partial 分支的 exact all-wire、ParserUnsynchronized、reopen 拒绝和后续零输出断言未放宽；新增三个 unsafe-extra-pop 负控确认补充没有误许部分写之后 pop。39 个合成观测负控还覆盖缺 pop、多 pop、缺 cleanup、错误状态/步骤、requery 别名、丢 save、主错被替代和 close 后 pop。正常 `selftest.mjs` 把实际 fixture executable 参数传入导入模块，因此三种真实 native 故障选择器探针确实会执行；直接运行纯 oracle selftest 则明确报告 native-selection-checks=0，二者没有混称。

矩阵保留原 277 个配置，新增一个 Direct `fault-set@0 + callbackFail + uiFail`，总数 278；本补充影响三路由原有 zero-set 和这一新增配置，共 4 个。既有 runner 继续检查 UI 错误、设备主错、termios、信号恢复和真实 process exit shape。新增配置能在 callback/UI 故障组合下检查安全 pop；真实执行结果仍待 151 提供，不把 selftest PASS 或旧库 missing-public-API RED 当作产品绿色。

独立执行 `node test-supplement/source/tests/session_extensions/safe_pop_selftest.mjs`（主审查目录 cwd），exit 0，3 路由/39 故意负例，**仅 oracle 设施**。另执行 `node verify.mjs`，cwd `/workspace/work/session-extension-review/test-supplement`，UTC `2026-11-10T23:24:00.906Z`，exit 0，46 项/0 失败；[verification.json](raw/verification.json) 保留命令、原件路径/hash、逐项结论。

原始 `raw/final-s007-selftest` 的 `.execution.json` exit 0，39+3 记录和逐项原件 SHA 与 evidence manifest 相符，按 AGENTS11.1 复用 native seam 检查；较早 `final-fixture-selftest` 只有 33 个负例，未误称其为最终 39 个。三个既有产品 830 原始 zero-set 结果另由新 oracle 重断言通过（Direct/Tmux/Screen）。该动作只验证新断言能消费已有原件，不是重新运行产品，也没有覆盖新第四例。全部证据范围已区分。

本补充没有必修产品/测试缺陷；准入建议为将固定 f8 测试整合至独立执行工作目录后，运行四个受影响产品配置。未变化的全部 277、host、构建/包检查的复用或执行由 151 按其具体输入有效性决定。curated 交付省略本地 source 副本、fixture ELF、SDK/cache、整份源码文档；保留报告、findings、独立脚本、有限 raw 和原件 hash。
