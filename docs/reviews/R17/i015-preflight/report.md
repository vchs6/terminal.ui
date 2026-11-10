# I015 限定独立设计 preflight

结论：**design_reviewed；execution_ready=false**。固定受审提交 `df9612e66418750c6cb712b3ff035c1789ef8292`。本轮无 Critical/Important（Battle blocker/major）发现，`findings.json` 为 `[]`。这是新增合同的设计结论，不是 A、020、008、041 或任何产品行为 PASS。

## 身份、范围与方法

本角色由 root 单独派发，只在 `/workspace/work/cursor-i015-preflight` 写审查证据和独立 C 微编译文件；未派子代理、未修改主仓/产品/正式 tests，未执行产品测试或重跑 host recon，未读取 `/workspace/work/cursor-protocol-design` 候选作者报告或草稿。正式合同自身的设计说明仅作为受审规范，不作为通过证据。未认证实际 serving model。

决策型限定审查：核 I015/A.6、I015 tasks 前置、唯一新增 public 只读诊断、native monotonic ABI、F006、Session tasks 附录/S008 与 L006。I001–014、其他功能设计只核相接接口，没有重开已裁决设计。使用固定文件及现有源作为接口事实，并做独立 byte/时间边界推演。主仓 HEAD 审查期间前进至 `47da4412a2858d496756b4e781cb998f1f11d587`，仅两个 progress 文件变化；17 个受审文件逐字节与固定提交相同，快照及 SHA256 见 `reviewed-hashes.json`。

读取并按 AGENTS §§10–11、ENGINEERING_TASK_DECOMPOSITION §§3/8、BATTLE_PROTOCOL §§3.1/6 执行。Superpowers using-superpowers 明示被派发子代理忽略；实际采用 requesting-code-review 的 reviewer 模板（只读、不得再派代理）和 verification-before-completion 的证据门槛。cloud-environment-runtime 已读取并以 environment_status 确认当前 managed executor running；没有环境安装/网络更改。OpenSpec explore 用于既有合同只读核查，明确授权的微编译/审查产物不作产品实现或新 change。CLI 初次裸命令不在 PATH（exit127），随后找到并复用仓库 `node_modules/.bin/openspec` 1.14.3，status exit0；没有据此标记产品完成。具体入口及来源记录见 `raw/skills-and-workflow.json`。

## 逐接口判断（全部为设计层 PASS）

| 接口/边界 | 结果与定位 |
|---|---|
| 单一 decoder/writer/noqueue | PASS。I015 §§1–3/5、tasks:407–409、F006:321 规定原 cjt_read→唯一 decoder CSI 状态的固定包内接点；匹配状态0..9、单digit、O(1) ledger，不回放、不加输入缓存/事件队列、不产生业务回调。writer及bytes/unsafe唯一归149，A只消费152固定交付；Keyboard随后替换原decoder，不并存。 |
| 7byte query / 9byte精确报告 | PASS。仅 `ESC[?25$p` 查询；报告 `ESC[?25;P$y`、ASCII P=0..4，严格7bit introducer。1/2才授权，0/3/4消费但仍Pending；错mode/多参数/leading zero/非法status/SS3/C1不授权，走既有未知/畸形规则。原InputDecoder state2兼有SS3/C1，I015明确禁止据此误接纳。 |
| 一次600ms窗口 | PASS。I015:444–451，先确认时钟、完整query事务后取t0，检查deadline加法；now>=deadline先结束Pending，最终byte在本机处理时now<deadline才Known，不能按OS推测到达时间补授权。持续输入不延长；回调/阻塞write没有600ms返回承诺。无重试、无TERM猜测、没有nonce伪认证。 |
| 600deadline与100idle | PASS。I015:449/476–478、F006。deadline唤醒绝不调用decoder.timeout；idle基于上次真实输入。例：t=580开始CSI、t=600唤醒、t=610完成同一未中断报告→吞报告、不授权、不合成issue/key。真正100ms idle打断则按K002 IncompleteInput/normal，余字节不被长期quarantine吞掉。A只继承当前裸ESC timeout，完整CSI timeout由Keyboard交付，阶段差异显式。 |
| 时钟失败与overflow | PASS（契约及可表达性）。I015:446/450–451：发送前失败不query，发送后/运行中失败为UnknownClock；无墙钟/帧数代替探测时间。负秒、clock_gettime失败和乘加溢出返回-1。正式实现仍须证明失败路径不会把短poll/无数据当真实100ms idle；本审查没有执行故障时序，也没有从编译成功推导该行为通过。 |
| late/duplicate/cancel | PASS。I015:455–478。设备接点持续到停读，Known首个original不再覆盖，Unknown永不重新升级，精确晚到报告消费无业务事件；stop/signal/EOF关闭授权。仅同一未被timeout/cancel打断的CSI有“完整报告”语义；不承诺任意间隔重组。 |
| payload / UTF8 / 输入预算 | PASS。I015:480–484、F006、K002/F002/F003。报告只在normal引出的CSI分支识别，paste/string中的同字节不抢占；有效UTF8续字节不伪作C1，引导只7bit；F003已形成key/issue先完成回调提交再消费后续byte。maxSequenceBytes=8可SequenceTooLong且不得授权，9/64可容纳报告；4096每turn仍归K004，额外buffer/queue均0。A未宣称已支持完整paste/UTF8诊断。 |
| 逻辑CaretSnapshot与物理权限 | PASS。A.6:171–189和I015:488–494。逻辑请求继续由焦点Canvas/clip/宽簇/遮挡生成；Pending/Unknown不把逻辑visible改false。Known在安全边界读最新逻辑请求，首次Known即使grid不变也强制考虑caret；不保存reply时坐标供迟后执行。 |
| Known / Unknown wire | PASS。Known逻辑hidden→25l、visible→最后CUP+25h；Unknown所有路径均无25h/l/s/r，有效逻辑caret只定位，hidden无额外caret CUP。明确原hidden不会因CUP显现，原visible无请求仍可能出现。Frame导出不含设备query/caret；未承诺坐标/shape/blink原态恢复。 |
| 成功基线 / 写失败 | PASS。I015:490/504–508和S008:163–169。query不提交frame；grid/profile+caret全部输出成功才提交设备基线。任意部分write使唯一outputUnsafe进程闩成立，后续屏幕/25/title/2004零输出且再open拒绝；零字节失败仍终止本run，cleanup限S008允许范围。allocation未发送，不能记成功probe。 |
| 正常/异常/EOF恢复 | PASS。I015:506–508。仅有original且实际管理过mode25时恢复精确原h/l；未实际改变可省冗余恢复。停止输入/授权后单cleanup，unsafe只静默native资源清理；恢复错误聚合保留首错，不二次补救show。A现-3 EOF错误也cleanup，后续Keyboard -4/finish顺序显式相接；产品真实效果另验。 |
| 只读TerminalCapabilities | PASS。I015:512–514；现src/terminal_capabilities.cj与application.cj:34/189。唯一新增`public let cursorVisibilityStatus:String`，包内init末尾named默认`not-probed`，不新增public构造/set/probe。六值闭集仅描述probe结果，known不等于当前像素/恢复成功。返回不可变完整快照、不pump/查询、不新增Observable依赖；颜色字段/override语义不动。 |
| 诊断生命周期 | PASS。I015:514。在现run能力初始化点重置，query完整成功/报告/到期更新；关闭保留最后状态，内部Closed不映射第七字符串。首次headless None，headless不覆盖设备last快照；挂载/检测前失败保留上次值；query失败仍走原primary/cleanup错误，不用diagnostic代替错误。 |
| 真实152屏障与无环 | PASS（规划）。I015:500–502/522，tasks:405–409，Session tasks:172–174，L006:54，F006。084→有限148→149→150→151→152→Glyph097→Theme088/092→A098–102→B/C→Keyboard。149的正式输入是148、004子合同、已验runtime、R10、003，未要求A；有限152不提前验未实现paste/cut，也不关闭完整030/020/041，所以无反向环。 |

## DQ-01–14

以下 PASS 限新增合同与任务定义的规划质量；不包括尚未交付的源、实际准入或产品验证。

| DQ | 结果 | 依据 |
|---|---|---|
| 01 层级 | pass | 098测试、099实现、100审核、101执行、102验收为既有L3；I015只扩各自同一交付，不让L2直接编码。 |
| 02 单目标 | pass | query/设备caret基线/恢复/只读诊断共同服务A原生caret；writer计数及unsafe归149，没有塞第二会话实现。 |
| 03 定义 | pass（规划） | Shared L3 card + I015附录继承字段、列新增源码职责、152输入和第7节预期；真实源/接口map仍为ready必需。 |
| 04 边界 | pass | 仅核心显隐查询、保守降级、只读状态和native时钟；不做软件caret/形状/blink/第二parser/新public时钟。 |
| 05 可判验收 | pass | §7与098/101/102明确7/9bytes、599/600、真实idle、错误形态、payload、预算、故障、三host双初态及diagnostic生命周期。未将这些计划记为已跑。 |
| 06 依赖 | pass（规划） | S008来源及152有限验收不依赖A，新增152→A屏障真实；080/084/088保留。执行就绪仍false。 |
| 07 父目标 | pass | A只验本次逻辑/授权/物理/降级四层；完整020/008/041/030及最终Linux汇合保留。 |
| 08 无重复 | pass | decoder、writer、ledger职责唯一；无input queue或第二ANSI路径；Keyboard继承而非复制。 |
| 09 集成 | pass | 100核固定diff、101真实host/故障执行、102证据充分性；113/114继承F006且116/121验新增模式组合。 |
| 10 不确定性 | pass（规划） | 三host只复用有限事实；未知自动保留，ABI仅独立编译可表达性。实际时钟/FFI/runtime/恢复证据留098/099/101，不伪造前置。 |
| 11 L4 | pass | 附录明确先接writer/C时钟，再decoder/report/loop/caret成功基线/cleanup，测试手写golden与原图证据可检查。 |
| 12 追踪 | pass | 正式change design/tasks/spec、input F006、Session附录及L006相符；本轮固定SHA/17快照/raw hashes，任务仍planned。 |
| 13 流程 | pass（本审查） | 已有root采纳裁决、本轮独立preflight；规范/技能/OpenSpec证据可定位。后续角色ready技能/已验源/接口map不能由本报告代替。 |
| 14 治理 | pass | 新增有界ledger/matcher/C ABI必要性明确；原writer扩展唯一，原decoder随后单路径替换；未知不猜恢复、无平行兼容实现。 |

**执行准入 DQ-03/06/10/13：not_checked / 未满足，不记pass。** 152、084、088尚未实际固定交付；`admission/interface-map.json`、正式角色技能与固定实际writer/resolver输入也须按各自门槛核验。仅合同存在或OpenSpec planning complete不能启动A实现。080是否已接受不替代其余缺失前置。

## 新增 C ABI 微编译

文件 `source/monotonic_abi.h`、`monotonic_abi.c`、`link_consumer.c` 是独立工具链可表达性见证。`raw/compile.sh` 编译/链接但**未执行生成二进制**，没有stub产品、没有仓颉功能实现或假产品PASS。host为Linux 6.18.57 x86_64、gcc14.2.0、glibc2.41。

`gcc -std=c11 -Wall -Wextra -Wconversion -Werror -pedantic -fPIC -O2` exit0，消费者链接exit0，`nm`显示`T cjt_monotonic_ms`和`U clock_gettime`。`_POSIX_C_SOURCE 200809L`与原native文件一致，`<stdint.h>/<time.h>`提供准确`int64_t(void)`、`timespec`、`CLOCK_MONOTONIC`，当前Linux libc链接无需新增-lrt。没有运行native/build.sh或重新构建已有产品。

溢出可表达性：以`sec <= (INT64_MAX - floor(nsec/1e6))/1000`前置保护乘加；最后可表示边界是sec=9223372036854775、毫秒余数807，808拒绝；t0+600可先检查t0<=9223372036854775207。静态断言编译成功且数学界线已独立核对。返回非负值与-1无重叠。该证据不验证真实产品故障处理、FFI接线、poll/idle行为或调度精度；这些必须由正式测试覆盖。

## 复用事实和证据界线

读取允许的`/workspace/work/cursor-capability-recon/report.md`并逐字节核18个response：XTerm/VTE两初态的12个报告均恰9byte并与1/2原态/反转/恢复记录相符，VT两初态共6个response均0byte。另记录6个原output.ansi、metadata及原SHA256SUMS的哈希。详见`raw/recon-reviewed-bytes.json`。未重跑、重画或生成host图；本次没有重新进行像素恢复验收。原调查说明无回应不等于不能控制，且VT 25s/r失败，足以支撑Unknown不改显隐的设计。它不能证明新产品probe/异常/取消/partial恢复通过。

明确未重新判断：I001–014内部设计、完整Keyboard/Editing行为、完整Session可选功能、其他宿主与所有Linux完成性、Cangjie新字段签名编译与产品FFI行为。原因：本派单只核新增接口；现有有效证据按AGENTS §11复用，新增产品证据尚未交付。完整仓颉shape不是本C微编译的结论。

本报告后续只对root裁决产生的I015受影响修文或ABI调整限定复核，未变内容不重跑原套件或recon。
