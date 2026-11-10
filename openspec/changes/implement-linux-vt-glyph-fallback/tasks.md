# Linux VT glyph adaptation implementation plan

> For agentic workers: REQUIRED SUB-SKILL superpowers:subagent-driven-development。主代理冻结及独立preflight后按以下独立角色顺序执行；本草稿作者不实施产品。

**Goal:** 普通应用自动适配已知Linux文本VT字形，保留逻辑Unicode和默认离线快照，提供后续Theme013生成标记上下文。
**Architecture:** 实际stdout只读探测→不可变内部policy→现Runtime/布局上下文和TerminalRenderProfile→同Frame投影/比较；单一分簇/宽度/Frame/ANSI所有权。
**Tech Stack:** 仓颉SDK/CJPM1.2.0、unicode0.1.0/unicodewidth0.1.113/ansies1.3.113、Linux原生ioctl；无新第三方依赖。
**Spec:** design.md G001–G009、specs/terminal-output/spec.md、decisions.md、REQ001.7/004.2–.7/005.4–.6/011。

## Global constraints

用户指定独立测试/产品/审查/执行/验收；编号093–097保留本增量，交付追踪父TASK041、L2归WP004，无新增L5。正常应用默认Auto，override高级可选；未知PTY保持Unicode但不报覆盖率已知。独立角色目录/固定版本交接，不传作者推理或自评。主代理只冻结、调度、集成及分歧处理。禁止发布。

产品作者等080和084最终固定源已集成；本增量097后theme013/025才可开始产品写入，085测试可以按原冻结API准备并追加mode场景，不并发改Component/Application/Runtime/LayoutNode/Frame等同一权威文件。Theme013实际ellipsis按本policy预留三列，085追加端到端测试、088验收；093–097不提前实现或声称完整ellipsis通过。

一实体一小写下划线文件；遵循根包→style/text叶包依赖方向，不为测试公开内部可变bitmap，不造第二Frame、Unicode表/算法、布局树或ANSI内核。NFC已证伪，不实现优化、不删重音、不改UTF8console模式。原颜色、宽簇、富文本、恢复及文件Unicode断言保留。完整041最终AC仍待全Linux宿主/场景；本tasks为该增量唯一状态，docs/tasks只映射编号，不复制进度。

## File responsibility map

- 新建`src/style/glyph_mode.cj`：三个公共mode及相等比较，根exports统一reexport。
- 新建`src/terminal_glyph_capabilities.cj`：只读诊断快照/原生解码；`src/glyph_render_policy.cj`：包内不可变policy和bounded bitmap所有权；`src/glyph_projection.cj`：实际编码和生成标记使用的纯函数。每文件按职责/单实体组织，可合并纯函数但不混类型。
- 新建`native/cjtui_glyphs.c`及现native/build.sh/build.cj/FFI接线：同stdout只读探测、限额和失败分类；保留原颜色探测二进制/作用域隔离。
- 修改`src/application.cj`：现init追加参数、setter/getter/诊断，run设备policy与offline参数明确分流、wake及profile基线。
- 修改`src/runtime_session.cj`/`src/layout.cj`/现LayoutNode：同一produce/renderLayout传内部policy并纳入缓存键，未来文字布局可直接消费marker函数；不是提前引入TextOverflow。
- 修改`src/terminal_render_profile.cj`/`src/frame.cj`/现边框数据：glyph投影与同row比较、共享ASCII组，Frame公开导出保持logical。
- 新增独立`tests/glyphs`公共消费者/真实PTY会话/原生验证及同package纯函数单测；093只写测试资产与运行说明，不写产品。现测试接线顺序追加，不重写其他角色待集成run-slice。
- 修改产品README/native-build/生成标记语义说明；必要公开examples只用普通Application(root)，另一个高级示例可显式override，不作为普通用户必需步骤。

## Review focus

1. 实际stdout不是stdin/TERM，VT别名/权限/空map/资源上界不得误报全部支持。
2. `中→??`与`中→文`投影相同仍可能raw续格结构不同，设备比较必须静默。
3. GlyphMode变更同时使profile和布局缓存失效，交替snapshotUnicode/Ascii不能复用错误policy；run不能误用默认Unicode公开snapshot。
4. 多码点/非BMP/VS/ZWJ即使成员mapped也不能声称组合支持；NFC不得用错误依赖或手写表伪造。
5. 离线Ascii仅选择生成标记，业务原文仍Unicode；原文…低层缺字为一列?，生成...是三列布局输入，不能混为encoder替换。

## Shared L3 admission fields

全部level=L3，parent=TASK041（追踪父项；L2=WP004），classification=execution：主代理已选A、未知PTY保Unicode、离线显式mode和既有UTF8前置；重要可逆细化见decisions.md，冻结/preflight未过前均planned。change_ref本目录，workflow_ref本tasks，requirement_refs见Spec。required_skills：主代理brainstorming/writing-plans/SDD；测试/产品作者TDD、用户固定CangjieSkills渐进search_docs、必要systematic-debugging及verification；审核requesting/receiving-code-review；执行/验收verification。实际使用证据随角色补progress，复用已记录云技能/固定SDK资料，不以“已安装”代替实际使用。

模型按用户流程：093 Sol/high；094 Terra/high；095与097 Astra/high；096 Sol/medium。记录指定配置，serving工具未暴露则如实不可核验。输入为主代理冻结合同hash、080/084最终集成SHA、093固定测试、原glyph调查可复现原始结果。公开制品检验用各自cache、正常cjpm build/bundle，不skip脚本、不依赖他人target。

质量治理共同项：必要性为实际VT缺字且现profile不投影字符；canonical owner=既有Frame逻辑、Unicode适配、TerminalRenderProfile输出和Runtime布局缓存。旧raw glyph直接输出/比较迁移为同一投影，公开Unicode导出保留，现border ASCII数据抽取复用不保留两套表。兼容例外仅已知VT可见退化与明确Ascii override；无持久schema/用户数据迁移。新增bitmap/profile/layout-key是需求必要有界状态，不添加监听器、字体栈或新公共policy层。风险为map只证明槽位、别名/外部换字体与UTF8会话前置，按design公开限制不声称精准视觉或语义恢复。

## TASK-093：独立测试设计与真实RED

- [ ] TASK-093（testing，status planned）：交付固定测试资产、独立预期、实际缺API RED和复现命令。

**Inputs / depends_on:** 主代理冻结design+独立preflight通过；可先在当前旧源做缺API RED，正式执行基线等080/084；不能依据产品作者实现生成预期。
**Scope / deliverables:** tests/glyphs正常消费者、同package纯函数单测、native read分支验证与真实PTY会话脚本/README；手算BMP bitmap/列数/marker预期，测试接线独立提交。排除产品补API、真实ellipsis布局实现、重写085fixture/API。
**Acceptance AC-093 / verification:** 默认及显式API正常consumer编译意图可定位，旧产品正常构建后新consumer因真实缺GlyphMode等失败；内部纯函数未实现同样真实RED（不手写替代实现）。正常/边界/失败预期独立且与design相符，固定test-only SHA。
**Impact / compatibility:** 只测试/说明/必要测试入口，旧断言原样保留；内部测试使用合法同package构建，不能改product导出为测试开洞。
**L4:**
1. 独立手算Auto/Unicode/Ascii、mapped/missing/empty map、knownVT mapfail/unknownPTY和`é/e+acute/中文/emoji/VS/ZWJ`输出/原宽度；至少覆盖map条目重复与bitmap长度错误。
2. 对纯projectTerminalGlyph与generatedEllipsis固定输入写预期：width0、1、2与现Frame资源边界；marker可用0/1/2/3/5列和…mapped/missing，ambiguousWide=false/true均用现displayWidth实算（true时…非单列回点串）；字面…始终w1，不把内部helper测试叫ellipsis布局测试。
3. 写公共Application init/set/get/诊断None，render/snapshot显式参数与默认Unicode逻辑原文、File完整快照、richtext跨span原簇保持；API overload shape由正常SDK编译核实。
4. 写设备diff用例中→文/中→??静默、宽→窄清残留、颜色与glyph同时等价、profile变化、setter唤醒/缓存切换；native分支覆盖fstat/ioctl失败、errno、空map/65535条、实际fd/非VT不读map。使用现符号合法link-wrap覆盖syscall失败，不向产品加特殊环境开关/回调。
5. 正常旧源构建及新consumer实际RED，记录命令/exit/诊断、固定test-only提交；自洽检查不过不交产品作者。

## TASK-094：产品子接口及Linux VT自动字形降级

- [ ] TASK-094（implementation，status planned）：交付可独立运行的设备字形适配与后续Theme013布局policy输入。

**Inputs / depends_on:** TASK080、084固定源已集成，093固定测试，合同preflight通过；产品独占共享权威文件。
**Scope / deliverables:** 精确公共API、原生只读bitmap、包内policy/真实纯函数、现Frame编码+投影后diff、run模式唤醒、offline参数/布局缓存key、产品说明与普通无override样例；产品提交只含实现与必要调用者/说明，不改093冻结测试。
**Acceptance AC-094 / verification:** 新测试及受影响颜色/Frame/runtime/富文本回归有真实结果；相同应用在实际VT不改业务文本而输出确定fallback、未知PTY原Unicode，纯文件不受设备字体污染；真实NFC缺口保留；actual ellipsis排版仍明确待013。
**Impact / compatibility:** Application/Runtime/Layout/Frame/native/exports及正常构建；构造兼容、theme参数合并约束和原颜色语义不变，主仓一实体一文件。
**L4:**
1. 按冻结SDK和正常包可见性实现enum/只读cap/policy；先验证同package纯函数边界、map冻结副本与一次分配上界，避免root↔text循环。
2. 接实际stdout只读探测到run既有cleanup，新增native构建/FFI，正常错误转诊断保守policy，不提权/写font；不以PTY换TERM作为成功证据。
3. 同Frame输出统一glyph投影、抽取现border ASCII对应组；比较新旧各自profile的同canonical row，移除raw glyph/continuation直接changed路径。
4. mode变化纳入wake+布局dirty；设备produce显式policy、offline snapshot/render默认Unicode及单缓存policy key；实现真实marker纯选择函数，不提前实现TextOverflow/省略前缀布局。
5. 保留原文/宽簇/富文本/离线ANSI颜色与异常cleanup，正常构建并运行093及受影响旧回归；固定product-only SHA和可复现环境、限制说明。

## TASK-095：独立固定代码审查

- [ ] TASK-095（verification，status planned）：交付独立spec/quality双判定、findings与受检hash。

**Inputs / depends_on:** 094固定base..product、093测试、冻结合同；不读产品作者自评代替推理。
**Scope / deliverables:** 审核真实调用链、native资源/errno/只读性、跨包可见性、row diff与缓存/布局policy边界；排除改产品/测试作者文件。
**Acceptance AC-095 / verification:** Critical/Important全部明确处置；无未决必须缺陷才能交096；核对没有字体API、Unicode副本或测试专用hooks，Theme085 API未漂移，097范围不超证据。
**L4:** 逐review focus核固定源码→独立反例→回主代理派原测试/产品作者修复→固定修复提交定点复核→产spec/quality双结论。无依据不发明反对意见，不机械全suite重跑。

## TASK-096：独立执行与真实宿主证据

- [ ] TASK-096（testing/execution，status planned）：独立正常构建运行固定产品/测试并留raw与制品证据。

**Inputs / depends_on:** 095无未决必须缺陷、固定最终product/test/contract SHA；独立目录/cache/SDK及实际可用VT/模拟器。
**Scope / deliverables:** 正常cjpm build/directbinary exit、内部/公开suite、受影响旧回归、正常bundle/解包纯路径consumer，真实LinuxVT与未知模拟器各自原始字节/profile/PNG/hash和恢复证据。原已验证内容按AGENTS11相关性复用，不机械重复。
**Acceptance AC-096 / verification:** 记录每条真实exit及环境/版本/尺寸/字体来源/用户权限；VT有实际ioctl/raw与图像对应，失败分支不因截图合格就算正常；图像不生成/重绘、不以换TERM计宿主。缺环境明确insufficient_evidence，不能假成功。
**L4:** 独立cache正常构建→直接binary实际exit→按固定矩阵执行→实际VT同普通无override应用和显式override诊断→正常bundle干净consumer只改manifest路径→冻结raw/PNG/hash/source，记录相关内容证据复用依据。完整ellipsis图像/布局等013，不能用helper画假图替代。

## TASK-097：有限子接口独立验收与主代理集成投影

- [ ] TASK-097（acceptance，status planned）：逐项核对glyph子契约、制品元数据及后续Theme013可消费输入，不关闭完整041。

**Inputs / depends_on:** 095独立审核、096真实执行、固定原件/副本/制品/hash、093–094合同与结果。
**Scope / deliverables:** 逐G001–G009/AC093–096判定、有限glyph子接口结论、公共文档与真实证据索引，明确pending/insufficient_evidence；把新policy/marker输入交主代理冻结到Theme013任务，不改085公共API。
**Acceptance AC-097 / verification:** 证据原件与hash一致、无作者自测替代独立结果；分别判断未知PTY/实际VT/故障/Unicode文件/diff和marker函数；三列ellipsis实际前缀排版未实现则准确写待013/085追加/088，不能据此升级全Linux通过。
**L4:** 核原始执行与源/制品内容一致→逐接口/场景/失败边界判定→主代理做状态/编号映射与公开说明集成→允许theme产品进入；完整041仍等输入/尺寸/恢复/全组件/M2/全部宿主最终场景汇合。

## DQ / preflight checklist

本草稿只检查到planned：稳定编号/父项、scope/inputs/deps/deliverables/AC、文件职责、mode精确签名、native资源确值、原文/生成标记/投影三边界、旧路径迁移、失败策略及有限验收均可定位。ready需主代理冻结、独立preflight、080/084及093固定输入满足。所有checkbox不勾选；status/evidence随实际角色填入，不提前伪造通过。

G012前置修订候选：094消费fix-uncertain-glyph-advance已接受167纯owner+原084，而不是反向阻塞R14。093测试作者在实际094前按最终G012补conservative deviceAuto期望，旧纯unicode/ascii/mapped及native矩阵不改，先固定正式test-only。G005/G007/G010仅一份GlyphRenderPolicy/projectTerminalGlyph，164已交子接口由094扩展，禁止复制。原094/095/096/097状态不因新补丁通过。
