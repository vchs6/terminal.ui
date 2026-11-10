# TASK-075 独立有限 A+B 验收

**AC-071–075：有限范围 PASS。必需的 A+B 行为证据未发现未决缺口。metadata：已准备并验证，待 root 机械集成一个严格 JSON 投影及状态映射后完成最终登记。** 本结论不表示 Linux 完成、完整源码发行制品通过或原父 AC 完成。

固定产品 `0912436b647f701e1de607fe03ce1bfba6a9bbf4`；测试截至 `6d703bfb10d491bed3ec761ac638ec77902e610d`，本次相关测试内容与执行冻结 `dddbdd9e02fbb6e8a998b24d447ec9b97a79a439` 相同；合同 `fc7667339d39208bbd0c25650696a7f495ca971d` 的 design 第 6 节 R001–019 优先。基线、逐文件 SHA-256、合同摘要及制品摘要在 [reviewed-hashes.json](reviewed-hashes.json)。产品实际版本 **0.0.0**，cjc/cjpm **1.2.0**；没有发布声明。

验收独立目录 `/workspace/work/runtime-acceptance`。指定角色为 Astra/high；实际 serving variant/effort 不可独立核验，不将指定值当实测身份。未派子代理、未联系作者、未读取实现者自评，未改正式产品、测试、合同或状态框。使用 cloud-environment-runtime 与 verification-before-completion；按任务 brief 和 AGENTS 11.1 复用有效未变内容，只重新计算摘要、核源码投影并重新解析已有 raw，不重跑产品套件。

验收输入 E 指 `/workspace/work/runtime-execution/r12-execution-draft`（拟归档 `docs/reviews/R12/execution`）；R 指主仓 `docs/reviews/R12/code-review`；T 指主仓 `docs/reviews/R12/test-design` 与 `test-supplements`。这些输入均为独立测试、审核或执行产物。归档后的报告应保留这些原始来源和固定版本。

| 验收项 | 有限结论 | 依据及限制 |
|---|---|---|
| AC-071 固定消费者与真实 RED | PASS | T 原旧产品 build exit 0，core-final-public-api-red 实际使用旧产品 .cjo 编译 exit 1，确为缺 Observable/NodeRef/UIException 等 API；宏正向旧库缺宏包、session 旧库缺接口均真实 RED。初始 99 件原件对应一致；补测 286 件与原件/hash 一致。声明-only scratch 只作静态语法检查，从未运行、从未算产品 GREEN。R017/R018/F007/受控 R019 RED 保留。 |
| AC-072 持久构造/绑定/调度/有限事件与公开示例 | PASS | 255 条公共 core 断言及宏正向消费者、独立 source review 支持固定 A+B 合同；公共 examples/reactive 已在真实宿主与干净包消费。R019 三文件修复以独立新执行验证。无 If/ForEach、focus、overlay、主题或 M2 已交付的推断。 |
| AC-073 固定技术 diff 的 spec/quality 独立审查 | PASS | R/report.md 初次 FAIL、scoped-report.md F001–006 关闭且 F007 FAIL、scoped-f007.md 最终有限 PASS、scoped-r019.md 双 PASS 全部保留。102 件归档和原件摘要一致。无未决 Critical/Important。 |
| AC-074 独立执行/恢复/普通 bundle/公开消费 | PASS（有限） | E 原 c3 回归失败保留；R019 fresh root build/check、native/ABI、受控 coherence/inflight、两 legacy resize、普通 bundle、clean root/native/public reactive 均真实 exit 0。复用不变 core/macros/Frame 与 12 PTY/两真实 GUI 有明确源版本。普通 bundle 不等于完整 release checker。 |
| AC-075 有限证据与 metadata 核对 | PASS（有限） | 764/764 执行产物摘要、原件、关键 raw 与内容一致性已独立核实；制品、版本、SDK、固定源码与测试一致。metadata 的唯一格式修正已制成并验证附加投影，root 完成以下机械集成后可登记 readiness；未提前登记未知最终 commit。 |

合同与证据对应如下；这不是仅按测试数量判断通过。

| 合同 | 独立核对的行为与来源 |
|---|---|
| R001、R013 | A+B 和 C 的边界保持；C 结构槽位协调不属于本次已交付行为。原 AC014/015/016/032 仍按完整原范围汇合。 |
| R002、R014、R015 构造/宏 | ThreadLocal collector、构造成功登记、一次 build、failed 实例不重试、重挂载新身份、Column 组合盒；宏泛型/双接口/带参 init/private State/嵌套 return 保留。E/c3/runtime-core、macro-positive-direct 原始断言和固定 tests/runtime 源对应。15 负例逐份非零编译 exit、正确源码位置/概念诊断，无依赖下载或链接失败冒充。 |
| R003、R009 绑定 | 多视图共享、动态依赖移除、同值目标无新帧、typed 常量/getter 替换与旧订阅释放、显式及后台 notify、真实 read-before-subscribe 同步竞态、70 turn 持续后台更新、满 post 队列仍接收 State 失效。固定 bindings/continuous_updates/scheduler 消费者及原始 stdout 对应；Observable/Binding 元数据锁与用户 getter 锁外调用及版本复核源路径核对。 |
| R005、R007、R012、R017、R018 生命周期 | WeakRef NodeRef、session nonce + ThreadLocal 线程生命期 token、旧代际不可复活、同/异 session 上下文优先级、cleanup 前撤 token/订阅/队列、孩子到父全部尝试、首错对象及清理聚合。F001–007 的初次失败与逐次关闭有固定源 diff/raw；线程 id 复用防护依据源码证明，不假称已实际复现调度器 id 复用。 |
| R006、R008、R011 调度/限制/stats | 精确 RuntimeLimits 及公开 stats 快照、限额失败清理、FIFO turn 截断、回调中新 post 下一 turn、batch 合并及异常不回滚业务值、stop UI 边界处理。run 的 O(1) needsWork 守卫跳过 idle snapshot/copy/full diff，dirty 分类保留，未实现 M2。 |
| R010、R015、R016 有限事件 | capture→bubble→新 app→旧非 interrupt→默认动作；consume/prevent/stop、expired event、隐藏目标/祖先、固定路由、隐藏 root 旧回调域、headless interrupt 清理。core 断言与真实 hidden/prevent/ctrlc PTY 相互补足；无 focus 或 modal 通过声明。 |
| R004、R008、R014 导出/唯一内核 | detached render 抑制生命周期/ref、最新绑定值；持久 snapshot 独立 Frame；owner 全局 render 每次完整 M1；LayoutNode/Frame/Style/Unicode/ansies 保留唯一生成路径。公共 export/stats 断言及旧六类 Frame/layout/style/composition-file 消费者 raw 保留。 |
| R011、R012、R017 设备退出 | 12 真实 PTY 场景逐份 result、signal、before/after termios、一次真实 close 原始记录核对；预期业务/cleanup/restore 故障返回 1 不被误标失败。native owner/setup-signal 新执行正常，非抛 finally close 和聚合顺序由 source review 与原始异常场景共同支持。12 场景不是 12 种宿主。 |
| R019 尺寸一致性 | 独立重新解析 6 份 raw：旧受控 coherence 真实 query 只为 24×5/8×3 却输出 24×3；旧 inflight 完整 24×5 合法。091 coherence/inflight 只输出 24×5/8×3、最终完整 8×3、正常 exit 0/一次 real close/exact termios。两 legacy resize 最终 ASCII/Unicode 字面网格正确。ABI 0/1/65535 所有组合、一次 ioctl、旧 shim 与错误 sentinel 有独立 raw。 |

可复查产物：[完整性核对](raw/integrity-audit.json)、[原始行为核对](raw/semantic-raw-audit.json)、[TDD 来源核对](raw/tdd-provenance-audit.json)、[宏负例诊断核对](raw/macro-negative-content-audit.json)、[历史 c3 命令](raw/c3-command-records.json)、[R019 命令](raw/r019-command-records.json)、[最终审计](raw/final-verification.json)。`audit.py`、`inspect-raw.mjs`、`finish-audit.py` 是本验收的只读重算方法，不是新产品测试。初期审计脚本的路径选择和 fixture 字面名称错误只影响验收脚本编写，修正后最终脚本 exit 0；没有因此修改原件或产品期望。

普通 `.cjp` 原件 SHA-256 为 `045d4030cc461922a91a207a0bd268e610fcc52175c753dfcd39a6757ba9465d`。直接读取 archive 内容及现存 clean 解包树与固定 Git blobs 比较：47 个有效 src/native 文件一致，另 build.cj/cjpm.toml/reactive manifest 和源码共计 51 文件一致；src/.gitkeep 是被正常省略的非源码占位。archive 无 target/cache/native 二进制夹带。普通 `cjpm bundle` 运行 SDK build/test/lint，保留 warnings；SDK 内置测试数量 0 不代替外部公共消费者。clean root/native/public reactive 使用普通构建与真实 PTY 运行；无 skip lint 或复制产品 native archive 救场。完整 archive checker 仍 exit 1，唯一已报告缺项 `examples/composition/cjpm.toml`；完整 `check-product release` 未通过、未声称执行通过。

真实宿主为 XTerm398 与 xfce4-terminal1.1.4/VTE（后补系统包查询 VTE0.80.1）。两套原始 PNG 中 Count2 及提示文字已目视核对；四阶段 raw/hash 为 Count0→1→2→3，实际尺寸 100×28→120×34，app/recorder/host exit 0 且 termios 精确相等。PNG 为 **c3** 原始运行，并非 091 新截图；R019 以三文件影响分析和新的受控设备检查补齐，未重建图片。普通示例没有能力诊断接口，metadata 明确只记录宿主声明，不能外推为新的全能力或全部 Linux 宿主认证。

idle CPU 同样是 c3 原始单宿主、单次 512×256/2048 getters/default heap 样本：100 Hz、1 tick = 0.01 CPU 秒，墙钟 2.003816325 秒；旧 f07 对照为 1.30 CPU 秒/2.004029228 秒。只支持这一配置下观察到降低，不能声称绝对零 CPU、跨主机阈值或私有子系统归因。O(1) idle 合同另由已审核且本轮未改的调用路径建立。

唯一 metadata 格式发现 M001（Minor）位于 E/evidence/c3/gui-reactive/xfce-vte/interrupt/metadata.json：host_version 含字面 TAB，严格 JSON parser 在 byte/character 182 拒绝。70 件 JSON 中仅此原件失败。**原件及原 hash 保留不变。** 附加 [严格 JSON 投影](metadata/xfce-vte-metadata.normalized.json) 和 [来源/转换诊断](raw/metadata-json-diagnostic.json) 已生成并实际 strict parse；所有解码字段与原件相等，host_version 精确等于原 host-version.txt 将换行替换为空格后的文本。

- 原 metadata SHA-256：`4311938a54d265e870b4dd89bb900b4999a1b5ec15075a296210b3b20a2bc1d4`。
- 新投影 SHA-256：`ce8e3f87d26015c886a1ea9ed05fc3215a5c4c95f1237bec1784cf601a94f2df`。
- 转换仅将已有字符串内 TAB 编码为 JSON `\t`，另规范 JSON 空白，不改解码值、版本、时间、来源或截图/raw hash。

metadata readiness 的剩余动作是 root 把本验收目录及该附加投影归档、在索引明确链接原件和投影，并按本有限结论机械更新唯一状态权威；不覆盖原件、不改旧 manifest、不需要 suite/截图重跑。本验收已核准备内容，未虚称未知的集成后 commit 已验证。M001 不构成有限行为证据缺失。

历史 c3 lifecycle resize 失败 raw SHA-256 `e246929ecf8675be06fc70a6a4abd00f25fd5e7e8a44a91bdb63b93700c0a4c7` 保留；当时不充分的历史全区间断言和可能非原子 stty 输入，不能单独断言实际根因。后续受控原子输入精确建立旧产品混 pair RED；修复后通过是新事实，不把旧报告 FAIL 改写成 PASS。

root 可据此登记 AC071–075 的有限结果，完成 metadata 机械投影后立即继续已冻结 C 的 076→077。AC014 等待 popup018；AC015/016/032 等待 C 完整证据；原 AC001/002/003/004/041、全部 Linux 宿主、主题/富文本/M2/完整发布、Windows/macOS/HarmonyOS 均不因本切片关闭。tests/dynamic、tests/rich-text、tests/themes 的未来冻结测试不算本次功能交付或 A+B 回归；LinuxVT readiness 另行记录，不等于最终全控件验收。
