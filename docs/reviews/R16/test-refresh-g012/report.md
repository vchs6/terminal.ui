# TASK093 G012 正式测试刷新

固定test-only full SHA：`df21f3def32de39a415d1d8d9845b83514dc2902`；patch SHA256：`8e1ae7b9ca59cfffa11923938107b29dc7810737b98198f38076d57fa808b1d4`；受检sourcehash清单SHA256：`3e92b7fdfd365bfe3418d0ffb82e868186b75aadd7f621e82457e7dfec4ada51`。

本交付冻结 test-only 刷新，分别记录有限保守内核的实际运行与完整 Glyph API/行为仍缺失的 RED；不判完整094/096/097或Linux通过。

## 固定输入和独立性

- BASE：`04a5289361d990e5a340ace22bbd50c9b805a9d9`，从主库本地独立clone到 `/workspace/work/glyph-tests-refresh/source`，分支 `test/task093-g012-refresh`。未改main、产品、规范或任务状态，未派子代理，未读产品作者报告或互通作者推理。
- 原093：`daf2a2523c5aacb27e2ea3b564b9b057bd6430de`，root集成901b06a；本轮开始时整个tests/glyphs与原提交无diff。原真实old RED仍保留原件，并逐字复制选定日志到 `old093/`，hash见 `old093/hash.sha256`，包括正常old build0、新API/内部/公开/Rich/session编译RED与readonly blocked。
- 合同：固定BASE中implement-linux-vt-glyph-fallback design G001–G012及tasks/specs；fix-uncertain-glyph-advance design A001–A008及tasks/specs；AGENTS尤其11.1。前者design SHA256 `b10649cf6efc89c19681ba5e426d7f7b08d2be209e39741361dff6d110b951a0`，后者 `adc4395b6f7645c71d1876f77a6003161451f723d7c67f6323d8f03623279d23`。
- 主代理已确认167/084有限正式PASS与产品199有限范围；完整094仍待152及其余指定上游。本角色不重新认证其宿主证据，也不以此提前实现或验收094。
- 执行型：目标、G012规则与原公开签名已固定；变更必要性是原未知设备Auto无条件Unicode golden与已接受保守策略不一致。唯一owner为现有GlyphRenderPolicy/projectTerminalGlyph/TerminalRenderProfile；不补产品API，不建第二内核。
- SDK实际cjc/CJPM均1.2.0；SDK入口 `/workspace/work/validation/sdk/cangjie/envsetup.sh`。独立cache `/workspace/work/glyph-tests-refresh/cache` 从共享只读 `/workspace/work/validation/replay-dependencies/cache` 复制；根与四消费者各自repository配置使用现有relay18973。未使用他人target、skip-script、skip-build或替代backend。
- 角色要求为Sol/high；工具未提供独立serving model/effort认证，不冒称核验。

## 具体变化与独立预期

只修改tests/glyphs共14个文件。G012影响的未知PTY、alias/非具体VT、fstat/VT/KD失败、graphics、not-tty的Auto正文从原文改为手写 `é é 中文 😀 ?? ?? …`，保持原19列与32列行末13空格。diagnostic/source/reason/errno原预期不变；已确证VT mapfail仍Ascii，map/empty/no-question/所有显式Ascii/Unicode旧case完整保留。新增真实未知PTY显式Unicode case保原文；原离线Auto/Unicode/Ascii业务原文断言不变。

新增glyph_conservative_test.cj含5个实际可运行回归：

1. 固定手写logical/scalar事实与原文/??输出：é、e+acute、CJK、单emoji、旗帜模型一致保留；✈VS16、heart/sunVS16、keycap、ZWJ不一致走width个?；显式Unicode全部原样。另有0、负width、非固定7列预算和超预算scalar和。
2. 真实Frame full encoder手写19列、逻辑plain/ANSI原文、head/continuation不变。
3. ZWJ/VS16/两个width1问号的双向diff零字节；新旧各自profile、Unicode↔conservative、宽→窄完整清行。
4. 投影后颜色相等零字节、可见样式变化不静默；五种color override仍独立使用安全device policy，snapshotProfile仍Unicode；颜色facts保持。
5. public Frame ambiguousWide=true保留原width2/逻辑…，设备按所存2列fallback；零面积包括Int64.Max空轴早返回。

旧8个同包@Test不删除；generatedEllipsis原Unicode/Ascii/mapped/missing、-1/0/1/2/3/5列、ambiguous false/true断言保留，并追加conservative policy相同marker规则。该函数仍缺，marker行为执行记blocked，不拿5个partial测试代替它。

PTY原所有native场景及syscall wrapper不变；追加真实Auto的ZWJ→VS16→字面??→ZWJ相等投影零字节、Unicode→Auto双profile、setter唤醒/measure、同值静默、挂载数保持。它们在完整session编译前均未执行。仍使用原真实成功write捕获和UI fence，不生成期待输出或假host图。

正向api消费者追加TerminalGlyphCapabilities六字段可读编译。negative.sh先正常构建该完整正向消费者；失败立即exit2 BLOCKED，未构造/编译只读写入负例。只有正向exit0后才允许原combined fixture与新增六个逐字段mutable-local写入负编译断言；六项各自拒绝才成立，任一字段可写都会失败。没有编译失败当正向gate成功。

独立复核还发现旧combined fixture的不可变参数会掩盖字段可写；实际SDK纯编译控制readonly-control-mutable-parameter exit1（parameter value is immutable）、readonly-control-mutable-local exit0、readonly-control-readonly-local exit1（variable flag is immutable）确认根因。控制源码在readonly-controls/，仅cjc staticlib编译，生成物只在cache，绝未执行，也未补任何产品类型/stub。systematic-debugging用于先查固定语言叶子、复现参数/局部副本差异，再追加六项独立负例；旧combined原件保留但不再单独作为readonly证明。

source-and-diff-check.log实际exit0证明 src/native/build.cj/cjpm.toml相对BASE未改，且public/rich/native wrapper/readonly写入fixture/原glyph_frame_test.cj相对daf2逐字不变。原Unicode/Ascii/mapped/native测试资产未降低。各测试expected来自合同手写，不从产品结果生成；scalar求和只核固定独立事实，不作为expected projection生成器。

## 执行、raw与hash

逐命令argv/cwd/UTC开始结束/真实code/signal见commands.json及每项同名.json；同名.log保存未截断编译器/运行原始字节（包括ANSI）。最终sourcehash.sha256列出全部受检产品src/native/build/manifest和正式tests/glyphs，不包含cache/ELF/CJP/密钥。manifest.json关联最终test-only SHA、patch及hash。test-only.patch供root集成；source工作树内容以固定SHA为准。

此处结果表由最终实际命令生成，见results.md。api-red是添加只读可读性后的初次真实RED；api-final-red是最终可读字段格式化版本的正常消费者复核，后者为最终API证据。baseline build与partial测试受检产品/依赖/环境未变化，按AGENTS11.1复用至test-only提交；README等后续文档编辑不使产品或回归结果失效。

完整internal失败为同一现有类缺ascii/mapped，不能把已存在unicode/conservative说成全缺，也不能把5/5通过称完整内部suite成功。公开API RED来自缺GlyphMode/TerminalGlyphCapabilities及相关接口；Rich/会话最终诊断分类见results.md，任何前置API缺失都单列，绝不替代最小glyph-only RED。readonly仅正向编译尝试，写入负例检查blocked。session编译失败则Node PTY/native运行未启动；GCC编译成功仅证明wrapper可编译，不证明其故障分支已运行。

## 覆盖与未执行范围

- 已实际运行：根正常build；5个有限G012正常同包test/direct runner；完整API/internal/public/rich/session正常编译尝试；readonly正向gate尝试；shell/Node语法、GCC -Werror、diff/source/hash校验。
- 仍blocked：完整Glyph API binary、13项完整同包组合（含Ascii/map/marker；其中5项partial已另行通过）、public离线/File/cache、RichText的glyphMode集成、session/PTY全部native动态分支、readonly六字段写入拒绝行为。按实际编译诊断判阻塞，未运行项不记PASS。
- 真实096仍必须使用最终固定094产品+测试，实际具体Linux VT与真实模拟器的native事实、字体map来源、PNG/hash、raw退出/恢复及制品consumer；本轮未启动宿主矩阵或重跑167/084无关已验内容。TERM=dumb/linux仍是同PTY，不算两个真实终端实现。scalar模型一致不能证明任意字体/宿主物理推进。
- generatedEllipsis只测试纯选择函数；完整前缀预算/重排/实际ellipsis绘制仍由Theme013、085追加、088判定。完整094/041/010/M2/Linux不因本轮通过。

## 技能和验证复用

已读项目提案/需求/架构/用户构造入口、AGENTS、G/A精确设计/tasks/specs。using-superpowers按SUBAGENT-STOP不展开root工作流。实际使用test-driven-development与writing-good-tests：先按固定合同写预期，观察真实完整API/功能缺失RED，不写生产代码，不使用no-op guard或假backend；真实有限实现的新增回归独立记录PASS，不编造旧源已有新接口的RED。

CangjieSkills固定277f2e1234ca5217496966887243c679653887a8，读取cangjie-coding并实际按脚本单进程批量查String.runes、cjpm test发现/no-run/filter，原始摘要在cangjie-docs.log；采用SDK1.2.0事实，不采用技能默认旧版本。verification-before-completion用于实际exit、源未变与最终diff/hash确认。cloud runtime已读并查询当前environment_status：connected/running，observations_current=true、network_policy=enforced；没有新增依赖/桌面/凭据配置。

原old093宽度probe/语法隔离证据按hash保留用于未变化断言的历史，不冒称本轮重跑。新5个测试已实际验证相关宽度事实，不冷跑所有宿主。此次仅有上述外部结构体字段语法纯编译控制，没有产品API声明stub或stub执行。无需重复旧产品全suite，因为本轮产品源未变、完整glyph测试明确因未准入功能阻塞；原suite未声称重新通过。
