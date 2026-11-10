# TASK167 独立有限验收

**最终结论：PASS，限 A001–006 / TASK163–167 的不确定字形推进投影范围；0 open Critical / Important / Minor。R14T083001 在原两宿主配置及本矩阵中判定 CLOSED / VERIFIED。** 固定产品源码、普通包、实际GUI/DSR和修正后colors执行证据齐备。3138历史exit0仍不作为最终colors依据。本文给出验收判断，不修改任务状态；083/084/094/041/010及Linux总门禁由各自后续流程处理。

固定产品 `199f00076c1a79cfa6d0be92e7be09366e1a06af`，集成 `b08c92d130f8d066a6db11c9ca1bf4c9af17e3f0`，正式 glyph 测试 `614d0a2f0e33e54ecc07bd783eaeb0b9957ca557`；最终colors测试 `0d46c35456db148f08bd407825a4fd559467249a`，root集成 `216bb9f35bdf70b621a0d30a4df32fe3c267f90b`，与199的产品/正式glyph字节相同。本角色仅写独立 `/workspace/work/glyph-advance-acceptance`；源码由固定提交选定路径 `git archive` 提取。未读产品作者报告/进度/自评，未与作者通信、派子代理、改产品/正式测试/状态。接收的是正式合同、独立 165 审核、166 执行与原真实失败；没有根据作者预设结论验收。指定 serving model 无可独立核验机制，本报告不认证实际服务模型。

这是 A001–008 已冻结合同下的执行型验收。使用 verification-before-completion，依 AGENTS 11.1 对内容一致范围复用有效执行；using-superpowers 明示 dispatched subagent-stop。实际新运行是源/原件/包完整性审计及原件像素/DSR 复核，没有机械重跑产品 suite。审计脚本、真实结果及全部被核原件的 SHA256 位于 `audit.mjs`、`raw/integrity-audit.json`、`raw/pixel-check-commands.json`、`reviewed-hashes.json`。

## 合同与有限 AC 矩阵

| 范围 | 本次判断 | 实质证据与限制 |
|---|---|---|
| AC163 / A003–004 正式测试 | PASS | 正式测试树与 199 完全相同；新执行 34 public 字面断言、9 同包普通 CJPM 测试，无 skipped/error/fail。手写完整/差分 bytes、宽 head ↔ 两字面 `?` 双向零输出、同投影不同簇、样式拆组、颜色等价、双 profile 切换、右边缘、负宽/零宽、宽>2、Frame 实际预算与巨大空轴均有具体覆盖。missing-private-API 编译 RED 与旧真实物理 RED 分列，不能混为同一失败。 |
| AC164 / A002–005 产品 | PASS | 独立读六源码和产品说明；唯一包内不可变 GlyphRenderPolicy、剩余宽度预算逐 scalar 减法、整簇等宽 ASCII 投影、full/diff 共用逐行投影、实际列与投影样式比较。零轴先返回，无第二持久 Frame/缓存/Unicode 表。现有公开 API、业务/离线 Unicode、成功后基线提交、native/SDK/deps/示例均未改。color override 也由同一 device factory 获得 conservative policy。 |
| AC165 技术审核 | PASS（限定静态/逻辑范围） | 独立 `/workspace/work/glyph-advance-review` 双 PASS，0 C/I/M；本角色再读完整差异及关键调用链，没有把 165 当成物理修复证明。 |
| AC166 普通构建/包/消费者 | PASS（有限范围） | SDK1.2、root build/check、normal bundle、清包 build/check、公开 consumer 正常 build+直接 binary、未改 rich-text build+直接 smoke 都是真 exit0。bundle 的 315 advisory 原样保留，未新增 skip/suppression，不称 lint-clean。 |
| AC166 受影响真实 GUI | PASS（精确配置） | 两真实宿主 × original rich、heart Auto、heart Basic8、heart TrueColor；40 应用阶段、40 完整 DSR 回复、80 原 PNG；详见下文。sun/keycap 未新跑 GUI，只有正式纯/离线 golden 与旧因果事实，绝不算新物理覆盖。 |
| AC166 colors 回归 | PASS（修正后） | CRF001经独立scoped-r1复审已解决；0d46在199上新执行26-stop控制8/8、27-resize控制及28-实际fixture/example均exit0。后者涵盖14精确动作、最终画面/解析/style关闭完整性、q及真实termios。3138旧观察与原FAIL均保留。 |
| AC167 有限综合验收 | PASS | A001–006及交付矩阵证据闭合；原R14T083001在固定两GUI配置下已解决，依据新产品实际行保持、完整DSR位置及源码因果，而非测试数量。完整Linux等上层范围保持独立。 |

## 真实物理修复与图像判断

原 91 真实失败仍保存在 `terminal.ui/docs/reviews/R14/execution-initial`、独立 `terminal-width-recon` 和固定正式 fixture。亲自查看旧 XTerm/VTE green 原 PNG，均能看到第 4 行开头 `AN` 被清除。旧完整 DSR 因果记录为 ZWJ 实际推进4而 canonical2，delta 实际13+89=102列，最终 `4;3`；VS16 心/太阳/keycap 则实际1而 canonical2。这说明旧逻辑 grid PASS 不能证明物理正确。

本次亲自查看两 host 的 rich/heart、显式 Basic8/TrueColor、resize 后图和 native replay 原图共10张新图，另对比2张旧图。新 rich 第3行是 `é and 界 ??`，第4行 `ANSI styles remain structured` 从第一列完整保留；heart 行是 `??Z`，Z紧随两列问号。保留行仍含原 ASCII/CJK/e+0301/单👩/单💻/🇨🇳 bytes；实际字体对旗帜的形状不据此推广成完整字体支持。XTerm 白底下既有 White 文本对比度与此次行覆盖问题分开，不将其当作字形推进变化。

八个真实仓颉应用会话都实际运行 initial→t→t→100×28 到120×34 resize→t→q；仅样式变化时 raw CUP 只定位第3行，不通过全屏重绘掩盖第4行覆盖。应用 inner/outer termios逐字相等、应用/recorder/host真实 exit0；16 个应用 host/Xorg PID 有reaping记录且本次读取 `/proc` 已消失。捕获 UTC、原字节、版本/locale/font/config、源/二进制hash均保存。

独立 native DSR 回放消费同一次应用捕获字节，**不是仓颉产品进程本身**。逐文件核 initial 仅剥 util-linux script header，green/red 完全同字节；查询插入点由正式 native fixture固定。native工具成功路径均恢复termios并正常退出；其源中早期错误返回并非本次成功记录，不能由这些数据声称其所有失败路径也能恢复。40 条完整 `CSI row;col R` 在原 input/output offset 中逐条对应，输入无未解释余字节；ZWJ prefix 为 `3;12`，heart suffix 起点为 `3;3`，完整 delta 都结束 `3;100`，原来的 `4;3` 不再出现。应用 PNG 覆盖实际resize；DSR replay只覆盖100列 initial/green/red，不声称resize后也作过DSR测量。

本角色重运行8个只读 artifact verifier，得到24个应用row4及16个回放row4逐像素不变，全部真实exit0，未修改/重新生成任何PNG。`scene-bytes-audit.json` 的40组完整行/SGR/padding手写审计已读源及核SHA，原业务Unicode/离线文件由正式consumer覆盖。图像、真实回复和源码调用链共同支持有限修复，不将辅助ANSI解析或库内模型作为物理oracle。

## 来源、普通包及复用

`raw/integrity-audit.json` 完整性检查无不一致（实际检查数量见该文件）。320项执行source manifest均逐一核回固定git blob，root集成产品路径逐字等同199，正式测试树身份一致。每个GUI CAPSRC对应实际public consumer或未改packaged示例；同一场景两host二进制hash相同。记录JSON/JSONL严格解析157份均合法，不需要更正投影。执行manifest中全部原件包括Xorg日志已核hash，没有旧“Xorg尚写入而先封hash”的差异。

本角色直接遍历普通CJP全部118个regular成员（原115+3新源码），逐个解出并与固定git blob比较，继而核解包磁盘成员；全部相同，详见 `raw/package-inventory.json`。并非只接受执行者80项局部产品comparison。包内无测试/审核运行依赖；空 `.gitkeep` 省略已明确。普通package并不等于完整release package：不变whole-boundary checker真实exit1于缺 `examples/composition/cjpm.toml`，benchmark也属后续门禁，未改checker跳过。

六项历史回归按内容语义复用：纯colors、rich-text（11组原合同+98 first-fault回归）、runtime core、runtime session、capabilities、resize-coherence。359个原件与执行副本逐一hash一致，77项pre-lint runtime/native清单核对；唯一不同 `terminal_projected_row.cj` 的旧字节 `6f98…`可精确重建，新字节 `93ca…`只将两次无副作用不可变Style默认构造提升为一个局部值。已直接读Style的只读字段/赋值构造/逐字段等号确认等价，111项依赖清单逐一核hash一致。复用不是声称这些命令曾在exact199重跑；变化的设备GUI、正式新测试、包和颜色override有新199执行。

旧负控的 `physical-old` exit1（16实际失败/116旧DSR）保留为必须拒绝的历史证据；原colors08/08b exit1保留为已独立分类的旧设施问题，不能直接计PASS。runtime callback/cleanup/close故障注入的exit1及错误串保留，验的是预期异常传播与真实termios恢复，不将“terminal restore failed”文字吞掉后称所有清理成功。包枚举两个失败、finalizer数量断言错误等外部证据工具尝试保留，修正仅使枚举匹配实际边界，没有改产品/测试期望。验收自身初次archive包含未tracked的cjpm.lock而失败；补充审计初稿误猜stop输出子目录/result.exit字段，实际为stdout JSON/result.code。均已根据原件修正，未运行或改动产品命令；记录见 `raw/adapter-attempts.json`。

## CRF001 修正复审补充

已独立读取 `colors-resize-fixture-review/scoped-r1` 双PASS及0d46三个tests/colors文件完整diff。stop在q前冻结调用者已验grid，等待stdio close后检查decoder尾字节、resize/ESC/row完整性及样式reset，再逐格比较最后画面；保留exit/signal/termios合同。五种非法晚到尾部拒绝，quiet/reset/同样式完整同行三个合法关闭接受，均由真实Node child stdout/close控制验证，synthetic termios标记不冒称产品恢复。原CRF001 FAIL保留，修正仅覆盖设施。root216bb9f产品/正式glyph测试未变。最终166原件现已交齐：`raw/26-final-stop-controls`、`27-final-resize-controls`、`28-final-colors-actual`三命令exit0。stop八例JSON保存在stdout，合成child控制不当作产品termios；28的两个真实PTY session结果均code0/null signal，before/after原字节相等，返回100×40完整grid等于initial，原session bytes与SHA一致。`colors-final-binaries.json`的两个199已构建二进制before/after hash相同，六源码/manifest均绑定199；脚本overlay八文件均绑定0d46。故颜色依赖已满足，没有剩余有限范围阻塞。

## 后续衔接与边界

本结论只涉及163–167有限投影以及原R14T083001的实际物理症状。原缺陷在所列固定配置下判定已解决；没有推断任意字体/宿主皆相容。最终完整性审计5807项无差异，覆盖4348个原件/副本路径；新增colors只补受影响执行，没有重跑已有效产品suite/GUI。执行full1478 payload及curated1454 payload（各另加manifest）hash全部一致，最终manifest分别 `ae0dc6befbad005a60bd6507a5ea2e1ddd6f1b1e45428b271658ef1d58b31a05` 和 `9620ad563107f08894cd119f049f8a54a3498b7c2f4fb3518f16bcadf304c909`。原083两GUI受影响路径已有新199直接证据；decoder/strict String/RichText值、离线、native生命周期、未改示例等内容有效事实可供后续独立083 scoped recheck/084按源范围继续核用。不得把原整份FAIL报告重命名PASS，也不由本角色关闭这些任务。

完整094必须扩展现同一GlyphRenderPolicy/终端projection owner并保留G012 Auto未知PTY保守语义，补其原nativeVT/map/显式Unicode/Ascii/ellipsis/API及测试范围；Theme/M2按M011消费旧/新完整profile及实际投影等价，不能造并行内核或以policy对象身份强制整屏。模型相等仅是保留条件，未证明任意终端/字体/Unicode版本的真实推进。完整Linux、composition/benchmark、其它平台与发布均不在本次通过范围。
