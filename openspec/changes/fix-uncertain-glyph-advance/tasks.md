# Unicode advance compatibility Implementation Plan

> For agentic workers: REQUIRED SUB-SKILL superpowers:subagent-driven-development，按独立五角色执行，本change先解决实际R14T083001再继续完整Linux。

**Goal:** 设备自动等宽投影，阻止复杂Unicode宽度不相容破坏未受影响行。
**Architecture:** 提前消费既规划G005/G007/G010唯一私有policy/投影，canonical Frame/Unicode布局不变，full/diff比较投影列。
**Tech Stack:** SDK1.2.0、现unicode/unicodewidth/ansies，0.0.0，无新依赖/生产查询/终端模式。
**Spec:** design A001–008，原REQ004/005/011及user自动降级、GlyphG012衔接。

## Global Constraints

独立测试/产品/审核/执行/验收分别目录/context；root只合同/集成。模型163Sol/high、164Sol/high（仓颉）、165Astra/high、166Sol/medium、167Astra/high，actualserving不可核则不认证。一个实体一文件，无新publicAPI/第二内核/复制Unicode表/生产DSR/改wrap mode/改示例逃避。不改业务/离线Unicode，普通程序不判断终端。no publish，direct-main授权保留。固定BASE91c22f8+原正式rich cc556f4；R14实际GUI FAIL与nativeDSR是输入事实不是修复PASS。来源未变证据按AGENTS11.1复用，变化必须补实测。

## Review Focus

1. sum溢出/negative/zero-area极值误放行或巨额分配：163纯边界与Frame实际预算。
2. 只修full未修delta或fallbackwide vs字面ASCII结构被判不同：163投影列字面golden和零bytes。
3. 错改逻辑Unicode/Frame文件或color override绕过：163公开consumer与oldbyte断言，166清包。
4. 仅模型通过仍物理越行：163/166完整DSR+原PNG两GUI，ZWJ/VS16相反误差。
5. 新privatepolicy与094/M2平行或依赖环：165 source所有权与后续接口diff，167实际范围边界。

## Shared L3 fields

level=L3，goal=G001，classification=execution，workflow_ref=本tasks，change_ref=fix-uncertain-glyph-advance。163/165/166/167 parentWP005/REQ007，164 parentWP002/REQ004005，并追踪原009/041而非L3嵌套。共同preconditions=独立preflight无Important+对应上游实际fixedSHA+共享写屏障；实际状态以上方逐项任务及最终验收为准；最初准入时status为planned、evidence_refs为空，现固定交付与证据见下方完成记录。必需skills TDD/仓颉coding/verification（代码角色），systematic-debugging已用于根因、SDD/review（相应角色）；工具来源复用AGENTS14/R11实际记录，按角色落盘真实使用。兼容=既有public签名/离线bytes/Frame预算不变；quality必要性actualrowcorruption，canonical_owner=GlyphRenderPolicy/projectTerminalGlyph/TerminalRenderProfile/Frame原full-diff，旧路径由统一投影承接不并存，复杂度仅两不可变policy+逐簇scalar和+有界row投影。风险/影响见design，工具与最终命令ready前固定。

- [x] TASK-163（testing）：独立formal测试/行为RED，tests/glyph_advance/正常消费者+同package临时copy测试+真实host回归oracle；保留old83物理FAIL。
- [x] TASK-164（implementation）：src/{glyph_render_policy,terminal_glyph_projection,terminal_render_profile,terminal_capabilities,frame}.cj及必要纯row helper/产品说明；只A002–005最小子接口，fixedproduct-only commit。
- [x] TASK-165（verification）：完整BASE→fixed技术diff独立spec/quality双verdict，核Gowner/离线/Color/style/列等价；不读作者自评、不重复有效套件。
- [x] TASK-166（testing）：fixedsource163、受影响回归、normalbundle/清包与实际两host原图/DSR/row4保持/恢复。
- [x] TASK-167（acceptance）：独立原件/hash/源码包/真实效果判断R14T083001关闭和有限投影范围；root机械集成→原083限定复验/084，不停Linux。

## L4

163.a从A003手写保留/替代/??style/列golden并验证实际唯一库scalar值；缺事实回root。163.b构造canonicalwide替代与两个width1问号、相同投影变更/反向/policy切换zero-output、零面积与actualbudget/invalidwidth；旧assertions不改。163.c实际old91普通build/纯profile missingAPI RED和已证物理RED分列，真实新fixture有负控，不以重新实现相同width模型作hostoracle。163.d冻test-only与命令/SDK/raw/sourcehash/正式执行README。CLI tests/glyph_advance/run.sh，consumer通常project下正常CJPM依赖，实际host入口在README精确固定。

164.a接fixed163和接口owner，先两policy/纯project helper及profile旧构造兼容；164.b统一full/diff投影列与device工厂，离线Unicode不动，颜色8属性沿原projectTerminalStyle；164.c固定163GREEN与必要旧Frame/Color/0-area和普通包消费者，不写正式期望，product-onlycommit，append开发report。新privateCj语法用SDK1.2实际编译，不加publictesthook。未来Ascii/map/nativeAPI留094，不提前塞满本实现。

165.a完整技术包+源/test/raw，对照A规则及94后续衔接；165.b双verdict/具体反例，回root→独立test→原product修→scopedreview，不私联；165.c原FAIL保留。

166.a独立cache/config固定新source正常build/test/direct，按内容复用083既有成功/原317lintwarnings不伪称lint-clean；166.bnormalbundle不skip与新清包publicconsumer，仅manifest路径改；166.c真实XTerm/VTE同原未改示例 t/t/resize/t/q、ZWJ/VS16及保留类、DSR/row4原PNG与退出恢复，hash在自有host退出后定稿且保留captureUTC；166.d逐命令/原件manifest/作用范围curated不带ELF/checkout/sourceMarkdownsnapshots。旧whole包边界1仍后续任务，不能改checker跳过。

167.a独立核实际newsource/integratedsource、所有原件/副本hash/真exit/strictJSON与原PNG，不机械重跑suite；167.b判A001–006及actualR14T083001，unknown策略不说font全证；167.c记录纯G子接口给094/Theme/M2，原094/041/010/Linux不提前关闭；167.d交root映射本163–167状态及R14 source/受影响范围，083/084独立角色据当前源与复用事实继续。

DQ候选自查：独立目标/输入/输出/paths/上下游单向，163→164→165→166→167→083/084→149→094，094消费该纯owner而非反向前置，无L3重叠状态；Glyph原全部native/preset/M2任务仍原权威。该句为初始准入约束：独立preflight通过与163固定前不准入164；现163–167已按顺序完成，见下方实际完成记录。

## 实际完成记录

163–167有限范围已由[独立167最终验收](../../../docs/reviews/R23/acceptance/report.md)确认PASS，0 open C/I/M；产品199f000（集成b08c92d）、正式测试614d0a2（集成23ac7aa）、修后colors设施0d46c35（集成216bb9f）。[166实际测试与80张原PNG](../../../docs/reviews/R23/execution/report.md)及[165双审](../../../docs/reviews/R23/code-review/report.md)分别独立；旧R14真实FAIL和CRF001初审FAIL保留。R14T083001只在该固定两宿主/字体配置及有限矩阵CLOSED_VERIFIED，不承诺任意host/font。原083/084由各自后续独立角色收尾，完整094/041/010/M2/Linux不随本件关闭。
