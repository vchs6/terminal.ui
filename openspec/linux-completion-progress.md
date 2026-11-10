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
