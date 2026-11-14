# Theme styles implementation plan

> For agentic workers: REQUIRED SUB-SKILL superpowers:subagent-driven-development，按依赖连续完成后继续Linux总计划。

**Goal:** typed逐属性样式、完整分类TOML、四主题及安全显式加载。
**Architecture:** Style最终值不改，presence-aware声明→唯一resolver→现Runtime/LayoutNode/Frame；上游Lexer预算预检+Parser，不做CSS或第二TOML解析器。
**Tech Stack:** SDK1.2.0，cangjie_toml0.2.3+官方stdx1.2.0-beta.02.1及现依赖，产品0.0.0。
**Spec:** design1–10（10节主代理最终裁决优先）、fixtures/themes固定字节、REQ001/002/008；完整027展示等基础控件。

## Global constraints

测试作者/产品作者/审核/执行/验收角色独立，主代理只契约/集成；一Cj实体一文件。公共原API/旧像素语义保留，统一Component/Style/LayoutNode/Frame/Unicode/ANSI。正式产品等runtime C和richtext固定通过，禁止并行写同一权威文件。模板TOML设计输入不是已实现产品；固定hash不得实现时偷偷换值。第三方许可按用户裁决保留原件，不自设声明冲突门；不publish。

## Review focus

1. Unset/Value/Reset、状态、多named来源以及父继承不能混为一个resolved值丢来源。
2. 失败/淘汰/旧session主题请求不可改当前已接受值，latest失败不能让旧合法意图复活。
3. Lexer有效路径含table+dotted+inline，不被字符串/quoted键内字符误计；小文件也必须在Parser前限预算。
4. wrap按分配宽测量、ellipsis整簇，四边pad/极端阴影仍保持原帧/约束，不只改paint漏高度。
5. 提交不得调用业务getter/build/mount，不重建NodeRef/编辑/焦点；背景填充与span背景区分。

## Tasks

- [x] TASK-085（WP005/testing）：冻结基础typed resolver/schema/布局/四preset公共测试、固定期望与缺API RED。
- [x] TASK-013（WP003/implementation）：typed声明/来源解析、继承/复位、完整布局属性及wrap/ellipsis接入。
- [x] TASK-025（WP006/implementation）：同一主题值的完整TOML schema、上游Lexer预算/Parser、四预置及普通依赖/制品配置；与013共享必要同一产品周期，不建第二resolver。
- [x] TASK-086（WP005/verification）：013/025固定技术diff独立spec/quality审核。
- [x] TASK-087（WP005/testing）：基础主题独立执行、原回归/正常bundle、干净stdx/路径消费和实际四主题样例。
- [x] TASK-088（WP005/acceptance）：原AC013/025完整基础范围和制品/元数据独立验收；027完整组件展示仍不关闭。
- [x] TASK-089（WP005/testing）：冻结ThemeRequest/latest-wins/失效/worker有界/UI提交独立测试与真实RED。
- [x] TASK-026（WP006/implementation）：显式load/reload、有界worker/候选信箱/原子UI提交/可观察结果，保留节点与业务状态。
- [x] TASK-090（WP005/verification）：固定异步加载增量与基础跨界独立spec/quality审核。
- [x] TASK-091（WP005/testing）：独立乱序/失败/关闭/同源重载、受影响回归及正常制品公开消费。
- [x] TASK-092（WP005/acceptance）：原AC026、元数据与集成独立核对，继续控件/027整展示。
- [ ] TASK-027（WP006/implementation）：全部基本组件可用后交付四主题统一showcase、窄屏/状态组合/Unicode与ASCII真实跨宿主截图，复用前述主题代码；状态不靠提前几段文字就关闭。

## L3 admission / inputs / roles

各项为L3；013父WP003/REQ001，025/026/027父WP006/REQ008，085–092父WP005/REQ007。classification execution：用户已定主题目标，design10记录可逆工程细化而非改变目标；workflow本tasks，change本目录。必需技能主代理brainstorming/writing-plans/SDD，作者TDD/仓颉coding/search_docs/systematic-debugging/verification，审核review，验收verification，实际记录progress，来源复用R11/skills.json与AGENTS14固定工具，不把安装当实际使用。指定模型测试Sol/high，产品Terra/high，审核/验收Astra/high，执行Sol/medium，serving不可核验时只记指定配置。

085准入等独立builder/DQ01–14通过本合同/固定presets；只公共消费者，不改产品。013/025产品等085及runtime080+richtext084固定源，原011/012/006已验接口与R11正常TOML/stdx、额外parser资源实证可复用。013原004消费本design完整子接口，014后续复用不构成反向前置。025原003消费已验中心仓精确版本，完整003仍最终汇合。086→087→088顺序；089可在合同冻结后准备、真实RED等基础固定；026等088/089，090→091→092；027等全部019/028/029/037等控件与026完成。Linux父AC不能因本增量提前全过。

## File ownership / L4

085创建tests/themes公共独立项目/按实体helper/run.sh/README，run-slice等其他固定接线后顺序追加。先手工逐字段来源/状态/reset/继承/fill/富文本golden，再配置全字段合法/非法/位置/Rune边界/资源cases、实际wrap高度与四边padding网格、四preset与固定fixtures等价；旧产品正常build后consumer真缺API RED，固定test-only。不可由resolver或parser产生自己的预期。

013/025改Component声明槽与bindings目标、Runtime节点解析缓存、唯一LayoutNode测量/paint、src/exports.cj及cjpm/dependency环境说明；新增src/style的StyleValue/VisualState/VisualStates/StyleKey/StyleKeys/StyleRule/StyleUse/TextWrap/TextOverflow/Dimension各实体文件，src/theme的ThemeRole/ThemePreset/Theme/ThemeLocation/ThemeDiagnostic/ThemeException及独立pure解析/预算函数，跨包不得新增内部可变表公开以解编译。若根与子包依赖成环，先报并按单向依赖调整职责，不用root↔theme互导。styles键闭集与typed accessor、完整resolved来源mask/fill→继承/状态→wrap/ellipsis/four pad→Lexer+schema→preset/产品可编辑themes→正常stdx清单/文档； product-only固定提交，不改冻结测试或原断言。precise ThemeRequest/ThemeResult/ThemeInfo/ThemeSource接口在026实施，此前Theme及Application theme构造支持足以独立使用基础主题，不出伪成功load实现。

086只固定base..product+tests+contract审spec/quality，无未决Critical/Important；发现具体反例回主代理→独立测试RED→原作者修→定点复核。087自有SDK/cache/忽略registry与官方stdx配置，普通build/directbinary真exit，适用旧结果按内容复用；正常bundle不skip，干净解包例子/同测试源consumer只改manifest path，SDK/stdx前置写清，不能借作者私有target/cjo。088逐原件/hash/制品/AC，文档投影机械核，不重跑相同suite。

089创建tests/theme-loading（可复用theme值fixture，预期独立），以真实同步握手/FIFO或有界任务控制验证旧慢/新快/新失败不复活、同文件外改无自动动作、reload源冻结、SessionClosed/无文件、queued旧session不污染、worker最多1+最新pending、请求终态不改、应用state/refs不变、失败候选活树引用/布局预检、R017清理围栏兼容。先基础产品真实缺load API RED，固定test-only，不用sleep/假future绕过。026新增ThemeSource/ThemeRequest/ThemeResult/ThemeInfo/有界loader各单实体，与Application/Runtime安全UI信箱集成；锁外IO/Parser/用户代码，主锁排序、session令牌/结果可观察、候选先验证后提交；固定产品。090–092同前审核/执行/验收角色分离，另核最新失败保旧、外部snapshot与全局M1一致、资源释放，不仅报用例数。

027正式文件examples/theme_showcase独立公共项目和产品说明，所有组件同一数据/逻辑切换4主题，状态/窄屏/装饰退化/可见层导出不设主题特殊渲染kind；跨真实宿主原始PNG+版本/config/grid/source/time/hash/raw。具体控件调用/布局在其依赖可用后作为本任务L4补齐并单独测试/审核/执行/验收，当前为planned不可直接编码，不伪造ready。预置文件字节已冻结不等于展示已交付。

## Quality / old path / DQ

必要性：原字段无法区分Unset/Reset/默认且无主题配置/切换；canonical owner唯一StyleRule声明、resolver解析、Theme不可变数据、Runtime绑定/身份/调度、LayoutNode/Frame画面。旧字段如保留仅作解析缓存，不保留第二级联；Style不改成可选。新增source mask/fill intent有span/背景真实用途，预算扫描是上游测得资源缺口的薄适配，不写TOML/Unicode内核。兼容：旧普通链/默认Classic画面保持；新四边padding/排版来自明确公共构造要求。无持久schema升级，v1未知字段明确诊断，不自动改写用户文件。复杂度：partial状态/typed键/loader队列是明确需求必要状态；不新增CSS/selector/脚本/层级include、自动watcher/新语言runtime或通用插件系统。

preflight逐项：085/013/025接口同design/fixtures；013和025同代码周期避免双resolver，026基于已独立可用基础，不互相前置；085/089 run-slice顺序接线；086/087/088与090/091/092都是固定输入/独立职责；027未来控件依赖保留且planned。共享Component/Layout写屏障明确，不让多产品作者并行改同一权威。Review focus全部映射085/089或027后续，parser预算/继承/request/richtext边界先裁决，文件职责/退役/兼容/证据/状态单权威齐全。独立DQ检查缺口解决前只准备合同，不派正式产品。

### TASK027完整M1 showcase L4（独立质量角色，唯一状态仍本文件）

正式范围消费[Linux收尾C006](../complete-linux-integration/design.md)并沿本theme T001–T016，新增字段不重复定义API。实际输入=092/084/097/112/117/122/157/162及完整021；021不反等027，027完成后才冻结124的完整功能M1库。完整产品准入仍需实际输入、固定正式测试及命令/hash；独立测试设计准入不代表产品ready，具体当前阶段见下述准入记录。

027.a独立Sol/high测试作者在tests/theme_showcase/普通consumer手写同业务/尺寸四主题全部基本组件和focused/selected/disabled预期、切换后节点/编辑选择/undo/焦点/滚动不丢、非法文件旧主题保持、主动reload原子成功；实际缺showcase/行为RED与工具自检后冻结test-only。027.b独立Sol/high或Terra/high作者在已定examples/theme_showcase/和产品themes/README用公开API实施，无theme特判内核；四preset canonical bytes沿已冻fixture。027.c独立Astra/high固定完整diff双verdict，不读作者自评。027.d独立Sol/medium正常CJPM build→直接smoke与真实键操作，至少一真实GUI同一场景四套原PNG/完整grid/style/version/config/source/time/hash；跨host自动降级沿C008完整矩阵，不用TERM假实现。027.e独立Astra/high逐原AC027完整组件/状态/窄屏/切换保持/可见层快照/主题分发核原件与source/cjp，root仅机械集成，不把基础四文本图当全showcase。CLI tests/theme_showcase/run.sh为开发测试入口，实际product project启动文档在examples/theme_showcase/README.md；入ready前固定具体命令与正式源。

## 2026-11-11 基础产品准入

085正式设计原74b1a5ac与追加2b16ce9固定交付，原47文件/16负例/4preset不变，真实缺Theme API RED保留，后续布局断言尚未GREEN。097最终有限字形验收通过，080/084/152及097固定源码已集成，013+025可按原合同进入同一产品周期；086/087/088及实际Theme能力未提前通过。追加证据见[R15测试刷新](../../../docs/reviews/R15/glyph-refresh/report.md)。

### 085 / 013025 的 T009 词法键预算补充 L4

原085固定交付不变；实施中新明确的转义预算测量按design末T009澄清，由本L4继续补齐，不新建解析器或独立产品内核。顺序：独立上游Lexer实证/决策Battle确认正式文字→独立测试角色追加所有键上下文的1024/1025、103个plain a与103次U转义、值位置控制（原所有预期保留）→固定test-only及实际missing-target RED/工具控制的真实边界→013025原作者实现同一Lexer guard并跑完整正式测试→086/087/088按新增冻结合同审核、执行和验收。未完成新增测试固定前，原作者不得自行定义转义预算或改预期。实际文件由测试作者按tests/themes既有生成输入及capacity实体组织，新增Cj类型仍一实体一文件；无公开API改变。

### 013025 同一产品周期的顺序实现检查点

013025仍为一个完整产品范围，086审全部BASE..最终产品，不分别接受半成品。为控制单次实现范围，原作者在同一隔离树串行完成：A仅typed style/immutable Theme及完整TOML依赖、Lexer预算、schema/诊断、readFile/preset/四配置、普通values真实执行；B仅现Component声明槽/唯一resolver/继承与presence/fill/explicit mask及Application theme入口、真实integration来源状态部分；C同一LayoutNode分配宽度wrap/overflow/四边padding、Glyph marker上下文/cache/快照与全部正式085、回归和正常包消费。每检查点提交固定product-only代码和纯raw，主代理继续调度下一点而不合入未独审的局部实现；A/B不关闭013025/085/088。三段不允许第二resolver/Frame/TOML路径或重复树；后续026仍等完整088。

## 2026-11-11 基础验收与异步准入

013/025与085–088当前基础范围由独立088接受，固定8d，产品已集成main73abef3；026/027/090–092与完整Linux/M2未完成。089原179c851冻结资产的真实foundation正向0后async-only probe1已交付，22行为场景未执行；026原实现角色已ACTUAL GO，BASE73abef3，唯一loader/Runtime/cache路径。证据见[R15基础验收](../../../docs/reviews/R15/acceptance/report.md)、[独立执行](../../../docs/reviews/R15/execution/report.md)、[异步RED](../../../docs/reviews/R15/async-red/report.md)。T087-G01 wholechecker实际1（themes允许表/缺composition/benchmark）保持最终023.a–d OPEN，不改为release通过。

## 2026-11-14 TASK027 正式测试准入

当前 status=in_progress：027.a正式测试、027.b实现、027.c独立源码审核及027.d独立构建/合成PTY已完成；真实GUI验证进行中，027.e独立验收待证据冻结；父复选框保持未完成。输入源固定 main `39d56c0f7ca2d751a9ce5fb4e18913636fdff43a`，完整AC021已由独立验收 `53c8ecc8b57756d857e08fb3209ebf975e2bd6e389696cc33d7d555669b45ddc` 接受为 `PASS_AC021_M1_U1_U5`；主题092与四preset固定字节及其余功能前置沿[实际输入manifest](../../../docs/reviews/R22/027/input-manifest.json)，SHA256 `80862cf7d9f7bd9d80351dcb40fab96fd96f5216888e71163dc1997cf3a77e28`。027.a已由独立Sol/high角色冻结同场景完整组件/四主题/状态保持/文件重载用例；固定测试与产品组合源为 `b5de3dd6610e90fcdcd951c5703a1429ec13b417`。独立Astra/high审核发现模态内功能键转发缺口，修复一轮后spec/quality均PASS_SCOPED（索引 `8d5da0f5f659d66a7860c7ca92164e6e6be92a487efe3d3b4c8d59002e87e401`）；独立Sol/medium正常构建一次、smoke、7个PTY及2个模态键用例均通过，9个进程termios精确恢复（索引 `768d1ad0ad00f02c2e9d36a0b8732418173155d1f2782acdc1171cc8c7d0bd05`）。这些不替代真实GUI与027.e验收，不把预置文件或文字图视为完整showcase。C006已定目标、单挂载场景及公开API不变，具体可复现样例布局/文案/按键由builder在授权范围内确定。027完成后再冻结完整M1并进入M2，最终Linux/023/024保持开放。
