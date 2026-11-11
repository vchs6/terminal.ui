# SDD ledger — plan: docs/linux-completion-plan.md

基线 31a7017e6bb522e3f4bcabd2f01abe1d81ea2170，与 origin/main 同步且工作区干净。用户本次明确“完成 Linux 阶段的所有工作”；先前自主实施、独立角色、适合模型、直接 main 集成授权有效。本次不以某一有限增量完成作为整个 Linux 任务结束。

已读 Superpowers using/brainstorming/writing-plans/subagent-driven-development/parallel-agent 及现有工程规范；用户已长期退出重复确认/菜单流程，需求和路线明确，按已批准目标进行工程细化，不再要求逐方案确认。主代理只契约/集成，不代写正式测试与产品。

独立完整性审计 /root/linux_scope_audit（指定 Astra/high）交付 /workspace/work/linux-completion-audit/{scope.md,scope.json,inspection.json}，69 条 REQ 与 66 个原稳定 TASK/AC；识别 014/018 语义依赖环、31 个尚未完整通过的 Linux 产品 TASK，明确 R10 失败命令是完整 bundle checker 而不是运行过 check-product.sh release。现有许可裁决、可选图片图标不支持回退均保留。

独立源码/语言审计 /root/linux_source_audit（指定 Sol/high）交付 /workspace/work/linux-source-audit/report.md 与 probe。SDK1.2 宏/状态属性/绑定闭包、跨包派生挂载、ThreadLocal、Thread.currentThread.id、Mutex 重入通过；open 基类 init 内 attach(this) 被真实拒绝，派生初始化后调用 protected 挂载方法可行。没有产品改动。键盘 parser 尚无 paste 域；后续编辑前必须补。

独立构建/解析调查 /root/linux_build_recon（指定 Sol/high）进行正常宏 CJPM bundle/干净消费和中心仓 TOML/官方 stdx API 验证。宏 package 自动识别已通过，不需要私人 cjc flags。旧 registry relay18972失效，调查者用独立18973，不修改他人缓存/服务。

L001–L004 裁决见总计划。近期先冻结 Frame 原语：它只消费已验 Unicode/Style/Frame 输入，和完整宏/主题/焦点后续工作无循环。任务状态只由具体 change 与 docs/tasks.md 维护；AC 最终结果只由 docs/acceptance.md 维护。只追加各阶段实际交接，绝不在恢复时重复派已完成任务。

Frame阶段最终5c2a7e7已实现并独立review/execution/功能验收，准备最终metadata。新增运行时架构草稿 /workspace/work/linux-runtime-contract/design-draft.md 待主代理正式冻结；宏带参/泛型/接口/WeakRef补证 /workspace/work/linux-source-audit/supplement/report.md 已通过，early-return原生允许但宏必须显式拒绝/处理。额外宿主 /workspace/work/linux-console-hosts/report.md 已准备真实QEMU Linux内核VT80×25+tmux/screen；仅环境探针，不是产品pass，后续固定源必须真实运行。完成本Frame后继续runtime，不结束全Linux工作。

Frame具体变更已最终metadata独立PASS（候选dde27d1），主代理机械关闭070并准备正常main checkpoint；不结束本用户任务。下一阶段已获得原生宏/泛型/接口/带参init/线程局部/WeakRef及普通CJPM/源码包消费实证，runtime草稿与root裁决记录待正式冻结。无需重复R8–R11功能或重新讨论已选路线。

Frame已正常推送6a7b240（远端/本地一致、clean）。当前继续[reactive runtime](changes/implement-reactive-runtime/tasks.md)：主代理采用草稿并在design第6节落实R001–014，A+B首单元071–075，动态结构C076–080。独立names微探针确认宏/类型Component可共存，限定名必须`import cjtui`，已纳入契约；不重复运行探针。新runtime进度以其progress为恢复入口，全部Linux任务仍活动。

2026-11-10恢复交接：runtime A+B产品源c3d743d通过独立073（含F001–007修复），074完成core255/宏/12PTY/旧Frame/正常bundle/干净包消费/真实XTerm与VTE PNG，但resize旧oracle失败；没有伪称075或整个Linux通过。独立resize_root_cause识别两query混pair、stty两次SET及合法旧帧inflight，R019合同fc766冻结；测试原dddbdd9（main6d703bf）先强RED、产品原61ce9e5（main0912436）三文件原子采样修复，当前限定独立审核与受影响074复验。原始失败保留，具体进度见runtime progress。

后续已交付而不要重派：C正式32组测试3ee1a9b（/workspace/work/dynamic-tests），RichText正式测试e6b3229+6d3ae13（/workspace/work/rich-text-tests）；均未集成，产品等075/080屏障。Theme正式合同5c150ec，085测试原74b1a5ac（/workspace/work/theme-tests/source）等待最终报告；产品等080/084。RichText与Theme已独立preflight ready，状态不代表产品实现。

实际Linux VT产品探针已在QEMU内核tty1运行旧6a7b240三个场景，退出恢复通过且有16张原始PNG；字体缺少CJK/emoji/组合符，不能将逻辑Unicode网格等同真实显示。字形草案主代理选择保守整簇等宽ASCII占位、复用边框映射，未知PTY保留Unicode；没有可用NFC依赖，绝不手写表。093–097预留自动字形子接口，080/084后、主题产品前；完整041仍等最终场景。离线render/snapshot默认逻辑Unicode，显式Ascii可供排版/ellipsis确定验证；设备run默认Auto，公共选项只是高级覆盖。正式稿和preflight仍待完成。

独立交互草案/workspace/work/interaction-contract-draft整理为A/B/C正式候选：098–102公共Canvas/focus(父017)、103–107viewport(父037)、108–112overlay(父018)。主代理采纳原推荐，ScrollView默认Vertical、普通Column不隐式滚动；Tab/backtab最小解码进入A。完整输入/编辑草案/workspace/work/input-contract-draft继续，113–117归一化输入/paste/EOF子接口、118–122编辑，原稳定028编辑/030可选会话/020恢复/019菜单编号保持，不按主代理口误重编号。上述皆未冻结/未实施，不提前关闭父AC。M2草案/workspace/work/m2-contract-draft完成，待主代理正式收敛；完整Linux剩余仍连续执行。

Runtime A+B最终075有限PASS已机械集成（产品0912436，R12/acceptance，AC071–075 passed）。原VTE metadata保留并追加strict JSON projection，原hash不变。076动态32组test-only已集成bc91577/真缺API RED，077可立即fresh Terra/high产品实施；不要重派测试/重跑A+B全suite。Rich测试已集成3f60142+7ba2cd4，Theme测试105337d；三者RED证据归R13/R14/R15，各自产品屏障不变。Glyph G010最终6d30da4独立补preflight ready，093作者glyph_test_author正写，R16。Interaction候选d10eb13已独立preflight中；M2/session/input/widgets草稿处于各自目录，尚未产品准入。

环境于本轮恢复：filesystem/原进程与raw保留、旧agents丢失。按cloud-runtime status确认新环境ready/enforced，恢复SDD ledger不重派已完成工作。077原产品167集成266，DYN-F001独立初审FAIL；先独立10c4ee3补两回归RED再fix216集成5de，当前原审者复核round1，079/080仍待。远端main仍1d2af2c已验A+B；未推known-failing C候选。089准备83fac077965bbf0ba573e81463486e4fdb344125已交，尚未集成、async-only强RED等088；不要重写。

已新增正式候选：Glyph最终a0eae999无未决Important且正式093测试daf2a252已集成901b06a（产品等080/084）；交互最终a0eae999独立design_reviewed，I011 application/I012自动行为态/I013 Off已收敛；Session最终d065719无未决Important（S007 pop ledger/S012深层copy），Input F002–005最终88ed5f7四PF独立verified；M2 M011/M012及Widgets W007候选c7328d0，M2三finding已verified，widgets只provenance minor刚机械修。全是设计/测试准备，不是产品实现。各原件目录保留，R16/R17等主代理归档中。

真实host补证：库存sshd+ssh -T+remote util-linux script真PTY，独立SSH正/负OSC52及title stack12原始PNG/158非秘密hash，目录/workspace/work/session-extension-recon/ssh，report3dc9d9e13ac3f49d095b8e59cbb4b4f022ddf74bae0df1588dc6a57f38f0e755；不冒充ssh -tt库存成功，gid5权限失败保留，不能复制private keys。实际VT S004四精确序列补探针无grid/cursor副作用、无支持确认，/workspace/work/linux-vt-product-probe/osc-probe 58hash/6PNG；root最初污染假设被真实结果否定，Session Unknown合同未变。两补项仍协议环境事实，非产品151/最终041 PASS。

2026-11-10：TASK078 scoped-r1独立双PASS（DYN-F001关闭），079固定216b2ab独立执行PASS，080 Astra/high有限PASS，原AC015/016/032原文范围充分。627执行清单文件与18验收文件、两个严格JSON最终Xorg-artifact投影已验证；原Xorg捕获后正常退出只追加日志prefix证据保留，不修改原件。root正在机械归R13并登记状态，不重复套件。新TASK009 rich_text_implementation_resume Sol/high（仓颉语言适用，AGENTS13.2）从9bc493f独立实施，正式081测试3f60142/7ba2cd4已固定。环境恢复仅重建代理连接，保留原文件/relay/有效证据。

TASK089 async测试准备原83fac077已机械集成179c851，78路径/22场景；真实async-only RED必须等088基础Theme，故089不勾选、026不准入。TASK148独立Sol/high session_test_author准备正式消费者与真实旧产品RED；有限宿主协议只作事实输入。新的cursor_protocol_design Astra/high仅外部候选设计：依据真实VT不回显隐查询/不支持save-restore，root选择Unknown保留显隐、已知才管理并恢复，详细输入兼容待候选及独立审查，不实施/不提前验A或020。

Task076–080 complete：独立080 PASS与716份原始归档逐字节/hash再核后，root登记AC076–080及原AC015/016/032 passed；任务077–080勾选。R13执行含627清单项+manifest本体，验收含18项+manifest本体；另加archive-index两文件，清楚区别计数，20原始PNG保留。原FAIL/正式RED不改；两个最终Xorg-artifact投影独立保存且链接原件。未关闭014/018/008/020/Linux总目标。现在持续TASK009。

独立linux_final_scope_audit指出041最终全组件/M2验收与M2 Admission原完整041形成语义环。root以L005显式采用已定L002分阶段输入：124要求完整功能M1库与已冻设备子接口，原041完整AC在M2后最终汇合，仍pending；不减少008/020实际M1恢复前置。

root已采纳I015异步一次600ms、唯一decoder/writer、Unknown不改显隐、只读cursorVisibilityStatus诊断和最小Linux单调FFI。152提前为A实际writer前置；F006明确未来键盘继承和deadline/100msidle区别。仅formal候选，独立限定preflight后设计准入，当前A未实施。

2026-11-10 df9612e：I015/F006/L006与complete-linux-integration候选已固定，repository/OpenSpec22项通过（仅元数据）。cursor_i015_preflight与linux_closeout_preflight分别Astra/high独立限定设计核，不读作者自评；实际A/收尾产品未准入。原scope audit /workspace/work/linux-final-scope-audit/report.md/mapping.json覆盖34原项，无套件/产品通过结论。TASK113 keyboard_test_preparation Sol/high仅prepare，真实puremissingAPI RED可先做，完整focus/modal/152等未具备则不关闭113/不准入114。当前唯一产品作者仍TASK009 Sol/high，首次开发rich11组GREEN不代替082–084。

59bea180独立linux_closeout_preflight限定规划通过，LC-PF001快照glyphMode、002五独立原结果/文件/状态、003021WP005/原010020M1边全部verified。root机械迁移001/002/003/004/008/010/020/021/023/024/041唯一状态到complete-linux-integration/tasks；全部planned，未改AC事实/未准入未来产品。027仍theme唯一状态，追加C006完整独立测试/实现/审核/执行/验收L4；无重复M2/Session链。I015与F007限定Astra设计核无Important，实际A/完整113仍缺152/084/088等产品输入。

TASK009固定原034685d已集成d8c5be0（local，082/083/084未通过不推新产品checkpoint）；082独立真实probe确认CSI nonASCII lead先出现但延迟到完整scalar才判语法，后byte资源可能抢首错。root核design5/6 ASCII边界与首个问题立即报，裁定C2已是非法CSIbyte，当时Malformed；后续UTF8验证继续、samebyte资源优先不变。按SDD fix-loop准备round1/5，独立Sol/high formalregression先实际RED，再原产品作者修，根不改产品/tests。完整Linux任务继续。

TASK148独立Sol/high正式test-only4093a7ab已集成c24f796，19files1071行，正常旧9bc库实际missingAPI RED1、声明syntax仅compile0从未运行、native夹具22checks和11负控0；277未来产品配置尚未执行，不投影AC148/030通过。113准备b7bb95b集成9137972，真实puremissingAPI RED1，但focus/modal/EOF/152上游缺失，113不勾/114不准入。098 fresh独立interaction_a_test_preparation Sol/high只准备A，084/088/152仍屏障。唯一Rich产品009原034685d独立082双FAIL，R14-T082-001 Important，先独立正式回归RED，再同原产品作者round1；根不改代码/测试。

TASK009 round1原91c22f8/main27f9c8c独立082限定双PASS、R14T082001关闭，083已开始固定源独立执行（rootbuild/check、rich98+旧11、runtime/dynamic/session/macropositive和受影响Frame/layout等实际0，包/GUI仍在执行，尚非083PASS）。098 preparedb004fe597已集成但不关闭098；103/108独立Sol/high测试准备而非产品准入。完整Linux目标持续，下一产品149仍严格等084。

TASK083独立实际FAIL R14T083001，两真实GUI t delta仅CUP第3行却第4行AN被擦；原物理PNG推翻width2逻辑模型PASS。root先读systematic-debugging，独立terminal_width_recon Sol/high完整DSR+实际重放/单变量验证👩ZWJ💻 host4/canonical2，VS16 host1/canonical2，不能全局改4/改示例/减少固定padding/永久全重绘。root候选fix-uncertain-glyph-advance 163–167：提前同一G005/G007/G010私有owner，默认device conservativeUnicode按唯一逐scalar宽度和与Cell.width一致才直出，否则整簇等宽?；逻辑/离线Unicode不改、不新生产查询、不要求程序员分支。G012/L007修未知PTY旧假设，094完整native/map/publicAPI仍后置，避免084↔094循环。当前候选待独立preflight和正式163，083/084不通过、Session149不准入；完整Linux仍活动。

正式163 test-only614d0a2已集成main23ac7aa，真实old91rootbuild0/public34PASS/现存devicefactory断言执行RED，24新privateAPI编译missing分列，136完整DSR/70原PNG与物理oracle/freshVS16事实，240testfiles239manifest。独立preflight1113ba18无Important，fresh glyph_advance_implementation Sol/high已从23ac7aa实施164，唯一产品作者，目录/workspace/work/glyph-advance-implementation/source，事实ledger/report同父dir。163仅勾测试交付，AC163–167仍pending；未关闭083/084/041/Linux。

测试准备103原da4934b已集成b288dda，31case记录/8明确recipe/actualupstreammissingBLOCKED、无行为RED；108原aa6b1de已集成7d543d2，真实既有baseline0、overlaygate77、无新overlay编译执行/strongRED。A/B/C仍各自actualsource/interface-map准入，准备不是完成。R14执行FAIL667原件、widthrecon current34+history34 PNG与DSR、082scopedPASS已机械归R14，962原件再核；R23 preflight+163外部事实200原件不重复tests内70PNG，roothash再核。未来依次持续，不停有限增量。

2026-11-11 Glyph093–097有限子接口最终PASS：独立095/096/097完成，当前源1f67/rootb3，final09733项矩阵明确30pass+有限P30pass+接口pass/layoutpending+父pending，0C/I/M。R16/execution保留真实kernel7轮/GUI2宿主39原PNG、21PPM、普通uid1000产品及受控GIO失败；P30仅本固定kernel正常组合，不关闭full041等父项。rootfresh1391sourcecopy2782SHA全同。097已封存curated41文件/40index/artifacts603d70f0…，独立机械归档中。Theme085固定原74b1+追加2b16交付已准；013025唯一产品Terra/high ACTUAL GO最终BASE81cd29c/独立theme-implementation源，当前正在实施，不等ThemeGREEN才开始。后续按086087088→089真实RED026→交互/输入/控件→完整M1→M2→finalrelease，不以此次有限通过结束用户全部Linux目标。
