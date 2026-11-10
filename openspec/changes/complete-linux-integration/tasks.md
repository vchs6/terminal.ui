# Linux完整集成 Implementation Plan（候选）

> For agentic workers: REQUIRED SUB-SKILL superpowers:subagent-driven-development；原任务编号保留，独立角色按固定合同/正式测试/产品提交交接，无子代理再派子代理。

**Goal:** 关闭有限单元以外的Linux全部集成、示例、恢复、制品和最终AC证据缺口。
**Architecture:** 消费既有统一公开API和各变更唯一内核，按功能M1→M2→最终矩阵顺序汇合；不新增平行产品链。
**Tech Stack:** 仓颉SDK1.2.0、现有依赖、Linux native桥；版本0.0.0；无新增产品依赖。
**Spec:** design.md C001–C009、docs/requirements.md与docs/acceptance.md原文，各功能正式design精确接口优先。

## Global Constraints

主代理只契约/集成；测试编写Sol/high、产品Sol/high或Terra/high、独立审核和复杂验收Astra/high、确定命令执行Sol/medium，各自目录和上下文，固定输入，不交接产品作者推理/自评。纯证据索引和AC投影由原验收职责承接，不另造五角色。任何真实产品/示例/发行检查行为变化须测试作者先给真实反例，再产品作者修，独立审核、独立执行、独立验收；若没有源码缺口则按实际证据关闭，不造无谓代码。

一个实体一文件，纯函数内聚；无第二renderer/parser/Unicode表/runtime。未变code/deps/env/config/scope证据按AGENTS11.1复用，不能因新任务/文档再冷跑。真实新增/受影响失败必须验证。正常bundle与repositorycheck不是完整release。所有required需有独立证据；不publish。当前全部候选planned，仅规划，不与原tasks建立第二完成台账；独立preflight后root机械指定唯一状态入口。

## Review Focus

1. partial输出后误发恢复/误提交成功基线：008逐byte故障和020同一writer协议检测。
2. 快照遗漏已提交层/viewport或旧Frame别名：010独立空网格ANSI解读和逐cell字面golden。
3. 示例借私有路径或手动flush：021公开源码消费与U1–U5交互结果审查。
4. 主题showcase只有文件/文本没有全部组件或丢编辑状态：027沿theme唯一入口完整同场景四主题检查。
5. package看似成功但少文件/子进程非零被掩盖：023真解包/直接binary/故意错误负控，024逐原AC核raw。

## Shared L3 card fields

以下与各卡合成完整定义：`level=L3; goal=G001; classification=execution; workflow_ref=本tasks; openspec_change_ref=complete-linux-integration; status=planned; evidence_refs=[]`。属于原任务的具体WP/REQ/原AC沿docs/tasks，不重编号，不制造父L3嵌套L3。`preconditions`=独立preflight无未决Important+该卡全部实际输入固定+共享作者写屏障；没有则仅准备、不准入产品。`required_skills`=TDD/仓颉coding（代码角色）、verification、按需systematic-debugging、SDD/review（各实际职责）；来源复用docs/reviews/R11/skills.json及AGENTS14固定参考，实际使用由对应角色落盘。`decision_refs=C001–C009/L001–L006`；兼容为保留现已冻结API/原断言，不造新公共签名。`quality_governance`：必要性为原完整AC缺口，canonical owner是功能design现路径，旧路径只补真实缺口不保留并行机制，复杂度限测试/集成/必要小修。影响/风险在各卡和Review Focus。工具/SDK/终端须实际可用并有raw；不认证无法观测的实际serving model。

每个有产品行为的原任务L4按五活动顺序：独立测试作者冻结正常/边界/失败字面golden与实际RED/缺证据；独立产品作者取得固定测试后写最小产品/example/checker并固定提交；独立审核者只收合同/test/source/diff/raw双verdict；执行者按确定入口构建并直接binary记录真exit/raw/SHA/UTC，实际宿主原PNG；验收者按原AC和源/原件/hash判断，root只集成状态。各角色不同agent/工作目录，不把一个作者自测当最终GREEN。仅文档冻结/证据投影任务由独立审查/验收原职责完成，无假RED要求。

## M1集成卡

- [ ] 1.1 原TASK-008：按C002关闭完整输出失败与基线契约（WP002/REQ004；implementation及独立质量活动）。

输入=070/R10、已接受152/117/112/122/162及最终M1全部模式/帧/caret、固定测试。输出=tests/output_recovery/正式消费者及原生fault夹具、现src/application.cj/frame.cj与native/cjtui_terminal.c必要真实缺口、产品恢复说明与R22/008证据。排除M2算法。
L4 008.a：手写相同帧/缩短/仅样式/resize/能力切换与C002所有截断位置预期；正常build/direct命令及期望停止/unsafe。008.b：固定来源回放原R10并仅补新writer/caret/input边界，真实RED只因产品违反正式策略。008.c：产品作者修对应唯一owner，固定提交。008.d：独立双审核→测试执行；native资源/错误/输出raw不可用时不足。008.e：按AC008原文接受安全恢复或明确停止分支，记录可证明边界，不用只零输出断言替代成功baseline确认。CLI入口 `tests/output_recovery/run.sh`（普通development test wrapper，不是产品依赖）。

- [ ] 1.2 原TASK-010：按C003交付实际可见层彩色/纯文本文件（WP002/REQ005；implementation及独立质量活动）。

输入=084/112/107/088/097实际接受源、Frame既有文件原语；不依赖M2。输出=tests/visible_snapshot/、普通CJPM消费者、必要现Application.snapshot/Frame文件写错误修复、R22/010。公开签名严格C003，禁止新screen-export kernel。
L4 010.a：手写Unicode/Auto=Unicode/Ascii框架生成标记且业务Unicode不转码，以及嵌套层/滚动/透明/样式空格/宽簇完整Cell和文件golden，snapshot保存后继续变更检查旧副本。010.b：独立ANSI消费从空屏解释目标，纯文本无ESC，真实目录/NUL/不可写路径throw，测试先固定。010.c：现产品真实失败才补唯一API，未缺行为则无无谓实现。010.d：独立diff审核和正常bundle/clean consumer（仅相应变化）+实际文件检查，记录直接binary。010.e：原AC010完整范围验收，CLI `tests/visible_snapshot/run.sh`。

- [ ] 1.3 原TASK-020：按C004形成全部功能M1模式/资源恢复输入（WP004/REQ004/011；implementation及独立质量活动）。

输入=008/152/117/122/112/162及I015实际输入；不会反向等待最终041/M2。输出=tests/session_lifecycle/、同一Application/native必要恢复小修、完整C004模式表及M1证据manifest。排除额外会话writer/模式所有者。
L4 020.a：独立测试列每种退出/原可见隐藏/knownunknown/原2004/title/termios/handler/owner以及业务+清理双错误，手工判定表固定。020.b：复用有效原件，补最终所有新增模式真实PTY和实际host可确认结果，unsafe零后续output。020.c：有真实缺陷才独立作者修最小路径。020.d：双审核→独立执行→有限M1恢复验收；CLI `tests/session_lifecycle/run.sh`。020.e：M2/release影响部分再补后由024核完整原AC020，候选卡不提前宣称最终所有源码恢复PASS。

- [ ] 1.4 原TASK-021：按C005交付完整M1 U1–U5和composition（WP005/REQ001–005；implementation及独立质量活动）。

输入=全部M1功能112/117/122/157/162/092/097/084，保留原010完整可见快照与020 M1阶段恢复输入（不等M2后完整041）；不依赖027完整展示/M2/最终041。输出=examples/minimal/、examples/composition/普通CJPM源码/README、tests/composition/正式用例、产品公开构造文档。具体新增仓颉实体按其命名独立文件，不在main.cj塞所有type；单一main只入口。
L4 021.a：独立测试按C005明确U1–U5入口、字面画面/业务事件/焦点和可见状态，旧缺composition为真实交付RED。021.b：独立作者实现完整可编译应用与 --smoke，界面不用私有API/Frame坐标/flush，source review可拒绝内核特判。021.c：独立固定diff双审核。021.d：独立正常build+直接smoke/真实键操作+窄屏resize/固定视口，原图/raw按C008。021.e：AC021完整便利性与复用结果验收，CLI `tests/composition/run.sh`；普通entry在各项目README固定。

027不是本处第二复选框：依theme唯一tasks展开C006完整L4，消费021并在124前完成。上述M1交付与027全部接受后，按M012冻结完整功能M1 LIBsource/cjp/deps/SDK/native。123–147按既有M2变化继续，不在这里另造022/031算法或benchmark任务。

## 最终证据和制品卡

### 2.1 最终调查与契约汇合协调组（无L3状态）

下面五个原稳定任务分别承接自己的结果/状态/文件/原AC，共用真实host执行原件及共同复用/验收活动，不复制五套实现或质量链。共同planning_gaps=最终源/test/cjp/宿主与命令manifest尚未产生；各卡进入ready前固定实际输入，不能把未来文件名当现有通过证据。

- [ ] 2.1.1 原TASK-001：最终Linux目标与支持矩阵冻结（WP001/REQ003/004/007/011；调查verification）。

输入=各平台/颜色/Glyph/Session/input原始事实、最终功能源、C008实际host矩阵；完整最终判断在147后，M1子接口可先冻结。独立交付 `docs/development/linux-support.md` 和 `docs/reviews/Linux-final/platform-matrix.json`，准确OS/CPU/ABI/SDK、TTY/非TTY/权限/固定console/模拟器/SSH配置与已测限制，其他OS列后续required。L4 001.a汇合固定来源与原件hash；001.b独立host执行角色给真实矩阵；001.c原调查角色写事实/限制并固定docs；001.d独立审核/验收按原AC001确认，不以TERM替代真实实现。具体最终执行命令manifest缺失前保持planned。

- [ ] 2.1.2 原TASK-002：完整原始声明式语法证据冻结（WP001/REQ001/002；语言verification）。

输入=071–080宏/绑定/动态与所有公开例子实际原始仓颉源码、正负例raw/SDK/定位限制；不等待与语法无关的最终041。独立交付 `docs/development/declarative-syntax.md` 与 `docs/reviews/Linux-final/syntax-map.json`。L4 002.a按原AC002逐组件块/链/状态/条件列表/自定义组件/回调映射固定源码与普通CJPM入口；002.b复用内容未变原正负例，变化部分由独立执行补真实编译/定位；002.c语言文档记录已验证限制与编辑器事实，禁用声明stub替代；002.d独立审核/验收每语法条款。最终源/命令未固定时planned，不与001/041绑定为一个状态。

- [ ] 2.1.3 原TASK-003：最终依赖/native消费事实冻结（WP001/REQ004/005/006/011；依赖verification）。

输入=最终cjpm清单/SDK1.2/deps及传递项、003既有R7/R8+Theme TOML/stdx实际输入、native闭包与干净消费；M1版本证据可供124，最终M2后核变化。独立交付更新 `docs/development/dependencies.md`、`docs/development/central-packages.json` 及 `docs/reviews/Linux-final/dependency-manifest.json`，同步产品README/build前置。L4 003.a固定所有版本/来源/hash与使用职责/缺口；003.b独立执行正常clean build/link/公开consumer（复用未变证据）；003.c依赖文档给准确工具链/运行闭包/缓存可用范围与实际license原文归属；003.d独立审核/验收原AC003，不恢复用户否定的许可冲突阻塞。最终源和全消费命令缺失时planned。

- [ ] 2.1.4 原TASK-004：完整U1–U5公共构造契约冻结（WP001/REQ001/002；接口verification）。

输入=021/027实际公开应用与全部功能正式design/API/包/错误/状态生命周期；C001各分段接口已冻事实保留。独立交付更新 `docs/ui-construction.md`、`docs/architecture.md` 与 `docs/reviews/Linux-final/construction-map.json`，产品说明同步准确入口。L4 004.a逐U1–U5源码调用映射语法/实际签名/职责/错误与固定消费者；004.b独立检查源码无需私有API/坐标/flush/内核特判及真实运行；004.c契约角色整理最终公共接口而非新建API；004.d独立审核/验收原AC004逐条，设计稿不替代编译。尚无全部最终consumer/src hash则planned。

- [ ] 2.1.5 原TASK-041：M1设备输入与最终全Linux适配证据（WP004/REQ011/003/004/009；平台verification/必要原owner修复）。

输入=已验native/TTY/尺寸/输入/输出/恢复子接口，M1完整020与C008设备事实；最终完整源还消费147。独立交付 `docs/development/linux-session.md`、`docs/reviews/Linux-final/linux-session-m1.json` 与 `docs/reviews/Linux-final/linux-session-final.json`。L4 041.a在124前固定M1 SDK/native/deps/ABI/输入输出/尺寸/恢复子接口manifest（不关闭完整AC041、不等待147）；041.b在M2后同源C008实际固定console/模拟器/mux/SSH场景补受影响输入/Unicode/布局/固定变化尺寸/全部恢复；041.c有真实缺陷回原独立测试/作者小修且双审核、相关执行，禁第二平台/渲染内核；041.d独立最终验收原AC041全部范围与exacttermios/bytes/PNG，不以M1 manifest勾选本卡完成。最终host/命令/hash缺失是planning_gaps，M1与最终状态由同一原卡分阶段交付，不创重复041状态。

017/026/030等跨任务父AC汇合由024同一验收职责引用各现有正式链与组合结果；不新增实现任务，不因支持编号相加关闭父。

- [ ] 2.2 原TASK-023：按C009交付最终正常源码cjp与干净消费（WP005/REQ006；implementation/交付及独立质量活动）。

输入=所有required最终源、027/021/147和2.1证据、0.0.0清单与实际依赖前置。输出=cjpm.toml include/实际buildscript必要修正，scripts/check-product.sh、scripts/check-bundle.mjs及最终包文件manifest/raw/hash，产品包不含开发工具/证据/凭据。包外保存cjp供验收，禁止publish。
L4 023.a：独立测试作者给缺themes/showcase/benchmark/compat/workloads/绝对路径和smoke掩盖非零的负控，使旧checker实际RED（不篡改产品期望）。023.b：独立产品作者完善必要include和release接线，正常cjpm bundle且不skip既定lint。023.c：独立双审核、再由独立执行运行 `scripts/check-product.sh release`，实际列包解包+新cache+普通相对path consumer、示例和benchmark正常build/directbinary，所有真exit0且负控真非零。023.d：验收者逐文件/hash/SDK/依赖/版本前置与无私有路径核，不拿单bundle作为完整release。入口若既有脚本因实际新增项目需扩充，精确原行为由正式负控约束，不能静默跳过任一required。

- [ ] 2.3 原TASK-024：按C009完整Linux独立整体验收（WP005/REQ007；acceptance，无新产品实现）。

输入=固定最终源/cjp/public例子/benchmark/tests/产品文档、所有独立review和实际raw清单、023完整release。输出=docs/reviews/Linux-final/独立report/findings/逐34原AC与required细条/NFR矩阵、所有宿主原图索引/元数据投影provenance，保留失败历史。不重复旧有效套件；有真实缺口回相应角色修后限定复验。
L4 024.a：验收者Astra/high核最终source/package/deps与各原件hash、真exit/fullrelease、版本/配置/原PNG，拒绝stub/TERM假宿主/ANSI重绘图。024.b：逐原AC和跨任务组合同源证据判断功能/M2实际局部工作与成本/恢复/便利性/支持范围；未决required或Important不得通过。024.c：独立最终whole-branch审核按SDD final-review要求一次有界全局审查，保留finding与修复证据；不重开已接受无变化单元。024.d：root机械状态投影、更新产品完成说明、direct-main推送并确认remoteSHA；无publish。最终用户答复只在全部Linux原范围接受后称完成，否则持续执行实际剩余事项。

## Preflight与状态准入

自查：C002–C009各有明确原任务/输入/输出/路径/独立角色/原AC，接口不扩张，001/002/003/004/041各自独立状态/文件/原AC，汇合组无状态且共享证据；027/022/031/030仍原权威，不重复。M1→M2→最终矩阵无完整041前置循环；021→027单向；各补充consumer只能消费已实际存在上游。

下一步独立preflight按工程DQ逐项核候选、与原34AC/各正式design/现发行脚本的一致性。尚未获得结论，不能据此直接开始本change产品；当前Rich等原有已准入工作继续。若固定合同需要新公共API，回root单独精确化/preflight，不能以收尾名义随意扩展。
