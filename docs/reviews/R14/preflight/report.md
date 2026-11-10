# Rich text 独立 builder / preflight

审查日期：2026-11-10 UTC。指定模型 Astra/high；工具未暴露可核验的实际 serving model / effort，故不声称已验证。未派下级。基线 `9cd654cde81170fce893040d1ebbda7bc920bc81`；候选为未提交文件，精确副本在本目录 `reviewed/`，每文件 SHA-256 见 `reviewed-sha256.json`。以下行号均指副本，主代理后续修文不改变本轮结论对象。

结论：**changes_required**。六项 Important 应在 TASK-081 冻结 oracle 前修文；它们是契约歧义/矛盾，不是已实现产品缺陷。TASK-009 仍受 runtime A+B 与固定测试的前置约束。无需新增完整终端模拟器、Unicode 内核、语言探针或让用户重新裁决已授权范围。

审查范围：四份 rich-text 候选文件、runtime 正式 R001–R016、AGENTS、工程 DQ、REQ-001.4 / REQ-005.1–.4 / AC-009，以及现 Frame / Style / Component / LayoutNode / layout / exports / text_validation / Unicode 实现。依赖调查仅复用 `text-contract-audit/draft.md`、原始 probe-run/build 日志与 source-sha256；未读取产品实现者的报告或自评。逐项核对现源码与调查哈希，Frame/Style/Component/Layout/验证/Unicode/编码/manifest 均相同；没有重复编译已验语言/库 probe。候选源码API尚未实现，本轮仅静态契约推演，不宣称产品或测试通过。

## Important 发现与最小修文

### RTP-001：成员 API 的 receiver 缺失

位置：design.md:44–50，runtime R009。

`Text(RichText)` 是顶层构造函数；同一代码块随后把 `text(RichText)` 与 `put(...)` 也写成顶层函数，仅 put 前有所属注释。消费者按块抄写 `text(value)` 无法知道更新哪个组件；测试作者按 R009 写 `node.text(value)` 又与此精确签名表不同。

最小修文：明确后两组分别是 `Component` 成员 `text(value: RichText / () -> RichText): Component`、`Frame` 成员 `put(...)`，保留两种顶层 `Text` 构造。typed setter 复用 R009 的 Text 叶约束、UI 所有权、常量/getter 替换订阅、InvalidProperty/WrongUIContext 等既有规则，不增加另一错误协议。

### RTP-002：RichText → 根包 validateText 与现导出方向冲突

位置：design.md:13,53；src/text_validation.cj:1–3；src/exports.cj:5。

当前唯一 `validateText` 位于根包，根包已经导入 `cjtui.text`。若按交付清单将 RichText 放 `cjtui.text` 并直接调用根包验证器，须反向依赖根包；既没有冻结合法访问途径，也违背包无环原则。不能由实现者悄悄复制校验循环规避。

最小修文：采纳主代理提出的公共纯文本验证边界：`public func validatePlainText(value: String): Unit` 位于 `cjtui.text`，根包公开重导出；根包旧 `validateText` 内部函数只委托。唯一算法下沉，非法 C0/DEL/C1 仍抛 IllegalArgumentException，LF/CRLF、跨 span 拼接与原纯 String 行为不变。依赖图固定为 `cjtui -> cjtui.text -> cjtui.style/Unicode/ansies/SDK`，`cjtui.style` 不回指 text/root。公开的验证器有独立的输入校验用途，不暴露内部集合或状态；不需要为它创造第二规则。

### RTP-003：资源阈值没有唯一计量口径

位置：design.md:100,106,119；tasks.md 的 4095/4096/4097、63/64/65 边界。

`maxSequenceBytes=4` 时 raw `[9B,33,31,6D]` 共4bytes，而 `ESC[31m` 共5bytes；若先规范成7bit再计量，两者都5bytes。候选未说明包含 introducer/final，也没说明是否计原始编码。独立作者无法手算上述关键边界。参数计数也没有明确是操作数个数、SGR 操作个数，或空字段是否计数。

最小修文：按原始输入 bytes 从 introducer 首byte到完整终止符末byte计数（含两者）；raw C1 一byte、UTF8 C1 两bytes，规范化不改变计数；`>` 上限才越限，终止符使总长超限也须报错且消费结束。参数按分号分隔字段计，包括空字段、38/48模式与通道；空参数 SGR 作为一个隐式0。单token前导零仍计digits。明确无法组成SGR的未知CSI也受序列byte上限，而参数/decimal token 上限适用于哪个可辨认的SGR候选状态；不能要求在final到来前预知final。

### RTP-004：每序列诊断去重、闭合时机和错误优先级不完整

位置：design.md:102,119,125,127。

输入 `ESC[1<HT>2<ESC>[31m` 在 HT 时已记 Malformed；遇第二 ESC 又按“取消当前残留”记 Malformed。文本允许一条旧序列一个或两个相同问题。若畸形后继续超长，也可能额外 TooLong；这与“逐事件”“相同issue序列”等价如何比较未冻结。`feed(ESC]payload)`、随后 `finish()` 的 Unsupported/Incomplete 时点也应明确，而不是让测试推测。

最小修文：序列只有一个主要问题槽；首个语法或资源故障在可判定时立即返回本批，后续取消/超限/闭合不重复主要问题；无故障的未知完整序列闭合时报一次 Unsupported；尚未闭合的 finish 可额外追加 Incomplete。同byte同时触发两种条件的优先级固定，例如先资源后语法；完整SGR含多个语义错误按从左到右第一错误定 kind，且不改变任意样式。明确诊断比较为按产生顺序合并各batch的 `(kind,offset)` 序列，批次切分本身不参与等价。

### RTP-005：空字段在扩展颜色操作数中的含义不唯一

位置：design.md:110,116–119。

`ESC[38;2;;128;255m` 同时遇到“空字段=全8字段复位”和“RGB缺参数/非十进制=Malformed”。可产生 Rgb(0,128,255)、整条拒绝，甚至错误地执行全局reset；三个期望无法兼容。`38;;1` 的空模式也一样。

最小修文：顶层SGR空字段等价操作0；38/48消费的mode及channel必须非空十进制，空operand=Malformed整条不应用，操作数不能回落成顶层SGR。表内“空参数/空字段”明确仅指顶层操作。主代理已选择此方向；无需为了兼容标准扩展新增colon语法。

### RTP-006：异常流的分块等价与批次失败原子性矛盾

位置：design.md:102,129。

输入 bytes `[41,FF]`。单次 feed 整块因 InvalidUtf8 失败，不交付 A；拆成 `[41]` / `[FF]`，第一批交付 A，第二批失败且不回滚。这不是实现缺陷，而是既定批次原子性导致的必然差异，因此不能无条件保证不同分块内容等价。

最小修文：对完整流成功 feed 并 finish 的情况，归一化内容/样式/诊断序列与分块无关；异常流保证同类输入故障及永久关闭，已交付前缀可随分块变化，不回滚，也不承诺错误批次内前缀交付。InputTooLarge 同样受此批次语义约束。一次 parse 整体失败无 Result 保持不变。无需新增事务缓存以强求全流原子性。

## 已自洽的边界与实施提醒

- `TextSpan` 惰性、RichText拼接后验证，解决 `["\r","\n"]` 合法而单独 `"\r"` 非法的问题；span不先做独立合法性判断。Frame先全值验证再写避免部分变更。无需新 Unicode 分段算法。
- 首scalar取patch、组件显式逐字段优先、Frame style为base能够自洽；`e`/组合音标跨style仍一簇，后续patch只影响下一簇。组件 `.foreground(Blue)` 可覆盖ANSI Red而保留span bold；组件 `.bold(false)` 也必须覆盖span true。继承自父的Red属于base，允许子span Blue覆盖。相同规范span相等不等于所有渲染等价值都必须相等，这不是缺陷。
- raw C1仅在无pending UTF8时识别，D2 9B、D2 9C必须是普通scalar；控制串内同样先维护UTF8边界。非法payload UTF8也fail-close，与“payload不缓存”兼容；最多3尾bytes足够，无需保存整个payload。
- OSC用BEL/ST，DCS/SOS/PM/APC仅ST；超限隔离、嵌套ESC与CAN/SUB不放行payload均自洽。闭合后才恢复正文，不能因超限清状态。分块ST、连续ESC需oracle，但不需终端模拟器。
- SGR0与None不同、22同时关闭bold/dim、38/48完整原子消费均清楚。未知/错误SGR整条无效；能力投影仍由既有输出profile承担。
- IllegalArgumentException用于limits/纯文本输入；AnsiTextException固定DecoderClosed、InputTooLarge、InvalidUtf8可与runtime UIException并存，因为分别是流与UI生命周期错误。闭合后的空feed也必须DecoderClosed。
- 源码里的 validateText 与 Frame 各调用graphemeClusters；候选“一次”建议理解成统一对拼接全文分簇，而非硬性要求整个调用链只能调用库一次。实现可以共享分段结果，但不要复制算法或让性能措辞改变String行为。
- 共享文件“禁止并行改同权威”是有效屏障，不能只检查072结束：TASK-077也可能在075后修改Component/Layout及tests/run-slice。实际派单必须登记009与077的先后及固定集成SHA；081新目录可独立写，run-slice追加按所有者顺序。现计划已承诺此禁并行原则，故不另记必修缺陷，但放行009时必须落实。

## DQ-01–14

本表是候选计划审查，pass不表示实现/功能通过。共享任务字段是工程规范允许的等价记录，不强迫复制五份冗长模板。

| DQ | 结果 | 范围、理由与修正 |
|---|---|---|
| 01 | pass | 081/009/082/083/084均明确L3，父WP仅组织。 |
| 02 | pass | 009是一个typed文本端到端结果，解析是输入适配；其他角色各有单一固定产物。 |
| 03 | pass | shared admission提供目标、输入、边界、交付、验收方式、治理；当前为候选/待准入，未伪称ready。进入ready需补13项所列证据。 |
| 04 | pass | 不含键盘、设备执行、overlay、主题和M2，调用方及String兼容明确。 |
| 05 | fail | RTP-001、003–006使公共调用与oracle不能唯一判定；补最小规则后复核。 |
| 06 | pass | 081→009→082→083→084无环，009等待runtime072–075；这是合法planned依赖，不能提前ready。 |
| 07 | pass | 原AC009映射本链；完整AC008/010/003明确留后续，未伪称关闭。 |
| 08 | pass | 唯一Unicode/Frame/Style路径与禁止共享文件并行修改明确；009和077派单需落实实际顺序。 |
| 09 | fail | RTP-001/002使成员API与跨包接口未闭合；修后现083已能承接Frame/组件/runtime/bundle集成，无需新增任务。 |
| 10 | pass | 已验语言/依赖与待实现框定分开；不把probe当产品通过。 |
| 11 | pass | L4有具体golden/RED/固定提交/执行/制品检查；oracle缺口已记05，不另造步骤。 |
| 12 | fail | 候选仍要求“原AC009状态需转移”，docs/tasks未指向新change/081–084；冻结时补唯一状态入口及本报告哈希引用，避免平行维护。 |
| 13 | not_checked | 已列各角色技能与模型，但rich-text当前没有可定位的必需技能来源/版本/可用性证据链接；应直接复用现runtime等有效记录并列路径，不重复安装/运行。未完成该映射不得宣称ready。 |
| 14 | fail | 新旧路径处理和复杂度理由充分；RTP-002尚未固定唯一验证器及包方向，修后可复核。 |

复核只需针对上述修文、DQ12/13证据链接和固定hash；不重新运行语言/依赖微探针。009真正准入仍检查runtime固定产物和081固定测试，后续实现审核/执行/验收不得用本报告代替。
