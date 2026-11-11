# TASK088 逐条验收矩阵

结论 PASS_FOUNDATION_SCOPE。状态区分执行通过、限定复用、保留的最终发行门禁和后续排除范围；没有42项全平台通过含义。精确原件位于087 artifacts/raw，相应逐文件hash及命令见本验收raw摘要。

| ID / 合同 | 义务 | 状态 | 最终独立判断 |
|---|---|---|---|
| T88-01 / AC085–088 | 固定来源与角色 | passed | 338条执行前后源/tests/native记录等8d，16组实际命令/UTC；563原件copy及564index全同，环境375deps/371stdx核实。lock仅5条记录排序漂移另明示。 |
| T88-02 / AC085 | 正式测试及RED | passed | 原085固定74b根正常build0、values因缺cjtui.theme exit1、negative门禁未进入；本次正式76文件对8d且原16negative/4preset字节同，新增合同断言未降级。 |
| T88-03 / AC086 | 独立审查闭环 | passed | 独立086完整原审→round1四项修复→8d删除4行无引用helper，最终source spec/quality PASS；未替代087实际证明。 |
| T88-04 / T002/T013/T016 | typed声明与查询 | passed | 最终values完整正向验证36typed keys、三态/相等/不可变查询；公开类型与访问限制结合固定源/复用真实编译负例成立。 |
| T88-05 / T002/T012 | 真实正向与负例门禁 | passed_with_scoped_reuse | 最终values/integration新build/direct0。16同fixture的旧type/access错误及前置正向gate成立，相关公开声明未变；按限定scope复用，非8d新negative执行，C1缺pre-run身份仍保留。 |
| T88-06 / T004/T011 | 声明slot与兼容 | passed | 正式来源/spacing/runtime断言通过：slots替换与解绑、getter Unset和删除区分、widthAuto/ValueAuto/Reset；单声明权威源码与086相符。 |
| T88-07 / T004/086-I03 | padding slot mutation安全 | passed | 两个拒绝setter回归均真实执行，ReentrantEvaluation后原uniform padding仍更新到2,2、旧位置清空且mounted不变；源先checkDefinitionChange再slot改变。 |
| T88-08 / T003/T014 | role和primitive能力 | passed | 17role schema及实际primitive检查通过，role挂载后拒改，不授予新kind能力；全局能力投影/named非法目标均正常公开测试。 |
| T88-09 / T001/T011 | 四来源逐属性 | passed | integration手写逐字段来源golden通过；explicit/reversed styles/role/global/继承default共用resolver，数组copy/清空行为已证。 |
| T88-10 / T001/T002 | 状态次序与Reset | passed | values/integration状态golden通过；每来源内Disabled→Selected→Focused→Normal，后named normal优先，Reset终止且false/0/Default保留。 |
| T88-11 / T001/T013 | 继承与root seed | passed | 真实Frame证明root8文本seed、父解析继承、子role覆盖/Reset默认；非文本属性不继承，公开文档已解释。 |
| T88-12 / T015 | 背景三来源与fill | passed | integration逐cell证明三种fill来源：root背景-only、本地完整Style、继承不fill；Classic空白inverse/underline兼容，hidden/clip有效。 |
| T88-13 / T013/T015 | presence/cache相等 | passed | 同值background但fill来源变化及同值foreground显式mask变化均真实重新绘制；resolver/Runtime/LayoutNode/Frame保持唯一。 |
| T88-14 / T011/§9 | 富文本explicit mask | passed | RichText公开回归和本次mask golden通过；本组件explicit/Reset压span，继承非explicit，span背景不填盒。 |
| T88-15 / T001/T004 | 全部装饰渲染 | passed | 装饰cascade和旧decoration有效复用通过：派生border fg/Reset、ValueDefault、独立shadow槽、shadow便捷入口及极端偏移。 |
| T88-16 / T001/T004/T005 | 全部间距渲染 | passed | 全部spacing正式Frame断言通过，四边pad/width/min/weight/gap/alignment有实际输出；sat/checked路径保持。 |
| T88-17 / T005/T014 | 实际分配宽wrap | passed | 最终integration与clean同源consumer执行Row flex/Column约束宽重测，祖先高及兄弟位置golden通过；测量与paint共用allocateMain。 |
| T88-18 / T005/T014 | wrap零宽与簇边界 | passed | 宽0硬行、CRLF、大簇独占裁剪行、无末尾假行、组合零宽簇及显式height/viewport测试通过。 |
| T88-19 / T005/G006 | 真实ellipsis前缀预算 | passed | 最终offline/controlled/GUI证明真实ellipsis预算：ABC…与A...区分，0..4/整簇/exactfit/clip/垂直隐藏规则通过，未只验marker helper。 |
| T88-20 / T005/G007 | Glyph布局上下文/cache | passed | 正式Glyph布局/cache/逻辑文件断言成功；同mounted root mode往返、分配宽/padding/span前缀以及device/offline隔离已证。 |
| T88-21 / T005/G004/G012 | 实际run的policy接线 | passed | 3输入control+7profile原件重断言，fd1 map仅controlled synthetic，缺marker104pair映射保持；实际A...→ABC…→A...且同setter无多余row。 |
| T88-22 / T009/§3–4 | 闭集完整schema | passed | 最终values执行所有36property/17role/10variable kinds/4states、literal/reset/ref/unused-invalid/闭集错误，源码guard/schema单路径。 |
| T88-23 / T009/§3–4 | 原生类型与范围 | passed | 最终schema源类型/printable/name/Int64/Color等全部断言完成；原生date/time不冒string，无Float中转整数。 |
| T88-24 / T009/§6/086-I01–02 | 首条诊断与声明序 | passed | 修复root优先及variable value/extra双向正式回归新执行成功；源声明序、syntax/version/rootrequired/forwardref按合同。 |
| T88-25 / T009/T014 | 诊断Rune与source | passed | source/name/keyPath/Rune位置及ref值/nearest-parent允许fallback的正式断言通过，无伪造位置。 |
| T88-26 / T009 | 同步readFile与路径 | passed | readFile有限读取、UTF8/空NUL、明确绝对来源与literal特殊路径、parse label不同文件的正式断言通过；不主张异步reload。 |
| T88-27 / T009/T016 | 完整联合预算 | passed | 原全部联合预算及危险深输入通过；边界有些合法进入下游SyntaxError/UnknownKey，不伪称这些文档schema有效。 |
| T88-28 / T009末澄清 | encoded key所有上下文 | passed | encoded-key151输入属于192个生成输入整体hash核对；6contexts×11spellings及103转义/直接/值comment控制按原断言成功，未改预算。 |
| T88-29 / T009 | 上游唯一Lexer/Parser | passed | 上游public Lexer原始token预算→Parser唯一语义路径；累积prefix/dotted/inline栈、comment计token和错误边界由源码审及本次正式实测支持。 |
| T88-30 / T010/T014 | 四preset同模型 | passed | 4canonical/test/shippedTOML逐byte同，preset公开parse/schema路径与独立规则golden成功，source标签/只读bridge无cwd依赖。 |
| T88-31 / T010/T015 | Classic兼容与四主题Frame | passed | 最终四preset手写Frame颜色/空白/重用accent规则通过，Classic原默认像素保持；这是基础场景。 |
| T88-32 / AC087/T010 | 真实四主题宿主 | passed | 两真实GUI各4preset及各2Glyph mode共12原PNG，实际trace==stdout/native viewport、binaryhash、80×25/termios/exit通过；只接受当前基础场景。 |
| T88-33 / AC013/T011 | 仅样式变化更新/身份 | passed | 仅样式/state/presence变更真实Frame更新且mounted回归通过；不将未来026主题提交/编辑全状态保持冒充本轮。 |
| T88-34 / AC087 | 受影响旧回归 | passed_with_scoped_reuse | contract/layout/decoration/runtime-core/RichText原件按95执行前201来源复用；仅decoder4行无引用删除不同，新final positives重验受影响语义。274旧Glyph源及39PNG仅不变backend事实。 |
| T88-35 / T012/T013 | 正常依赖与公共路径 | passed | 正常TOML0.2.3与官方stdx1.2.0-beta.02.1/SDK1.2证据，375deps及371stdx文件hash；单向包与Alignment根入口兼容，clean路径无作者target。 |
| T88-36 / T012/AC087 | 正常bundle/lint | passed_foundation_release_gate_open | 8d正常cjpm bundle0且491实际warning保留；wholechecker真实exit1保留OPEN_TASK023，不能把其themes拒绝变成通过或本轮漏交主题。 |
| T88-37 / T010/T012 | 实际CJP完整成员 | passed | 实际CJP SHA29ce7c…，175成员逐byte等8d及clean构建后源，四themes已交；安全/product-only边界独立检查，缺composition/benchmark仍后续。 |
| T88-38 / T012/AC087 | clean公开消费者 | passed | 实际解包source-only主库build0、完整正式integration源仅manifest dep路径改动、build/direct0；没有复制private cjtui target或隐藏stdx flags。 |
| T88-39 / AC088 | strict metadata/原件封存 | passed | 168strictJSON、563原件copy/564index/565files，无异常成员；12正常host与Xorg已退出后seal，原PNG不重画，1643省略生成件hash核实。 |
| T88-40 / AC088 | 早期证据时间限制 | provenance_limit_preserved | C1执行后hash不能追认pre-proof；95 pre201只按原范围复用；8d新执行单独338pre/post证明。早期lock记录和final锁仅依赖顺序差异，字节差异公开。 |
| T88-41 / AC013/025/085–088 | 公开说明及机械投影 | passed | 文档已解释visualStates外观/rootseed/encodedkey/stdx与后续加载；原AC013025及085–088有限foundation可接受，机械投影不改主仓。 |
| T88-42 / T006–008/026/027 | 排除后续范围 | excluded_followup_pending | T006–008/026/089异步、027全部控件showcase、TASK023 whole-release/完整Linux/M2/其他平台仍pending。 |
