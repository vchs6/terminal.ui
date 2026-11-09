# R8 首个Linux可运行切片

用户指出仓库没有实现源码，并要求继续实施；此前已授权Linux ANSI优先、按任务性质选择模型及独立子代理。最新明确许可冲突无需由本项目解决，包能使用即可；本轮不设置此阻塞，保留实际归属，不改第三方原文、不发布中心仓包。

基线868a3f6722e89e03232785469940a0e510a12103；有限切片合同与唯一任务状态位于openspec/changes/implement-linux-first-slice/design.md、tasks.md，执行ledger为同目录progress.md。已确认目标直接落码，不重复要求用户批准已有授权。此切片实现构建/Unicode、Frame/Style、Text/Row/Column及render、M1差分、LinuxApplication/KeyEvent、真实minimal。全量组件/编辑/滚动/主题配置/响应式/M2及其他OS仍未完成。

模型与职责：测试设计Sol/high，只改正式测试并冻结RED；原生与UI分别Terra/high独立clone，顺序实现，不改测试；原生局部审核Sol/high、整片审核Astra/high，均固定版本新clone；执行Sol/medium，fresh clone/产物、不采用作者自测；最终验收另独立Sol/high，按原始结果判断。主代理仅管理合同、调度、文档、集成和状态，未代写产品/测试代码。只传递需求、固定交付和实际反例，不共享作者过程推理或自评。

技能使用：复用R7锁定工具（OpenSpec1.14.3、本地Superpowers7.0.0）及已有SDK1.2.0安装；当前另实际读取云using-superpowers、brainstorming、writing-plans、subagent-driven-development、using-git-worktrees和fix-loop/final-review参考。OpenSpec创建具体有限变更，既有需求不变，skip_specs=true；读取schema工件指令、status/apply推进，不创建整项目重复提案。原始需求已充分讨论及确认，不重新启动问题/审批循环。实现者和测试作者按角色使用TDD/排障/验证，审核者独立验证实际反例。云技能无可用semver，不虚构与本地内容逐字节相同。

构建/验证环境为SDK1.2.0、Debian13 x86_64、GCC/GNU ar、Node/util-linux测试设施。受管环境CJPM不继承proxy，测试用既有R5只读curl registry relay及忽略的本地repo配置；这些不进入产品。产品仅需要仓颉与文档列明Linux构建工具，UCD/cjp固定SHA，正常用户/CI默认官方来源。生成数据/archives/binaries/SDK/开发cache不提交，归属文件保持原文。

审核事实：native构建入口caller allowlist缺陷修复；整片首次审核6个实际缺陷，原作者统一修复，第二轮仅控制串UTF8 residual定点修复，全部6项已在2f85fcbe4c422f4f45b69875feb4728f9bea3f8f由原Astra复核verified。执行者fresh clone另发现冷入口check先于build，最小脚本修复到2ad6c5ceeb0068d3b2b2d5efe010059965b9415a已独立审核通过；全量执行/最终验收不由审核结论代签。原始失败和后续成功分别保存，不改写历史。

本轮审核预算按每轮最多3次有效复核/60分钟，native局部1次，整片源及入口共3次；不以规避预算为由关闭必需问题。副作用仅构建/本地测试与已授权main推送，不上传发行包或联系外部维护者。验收必须区分首片可运行与整个框架完成，不能用零测试、作者自测或CJPM吞异常的退出0伪称通过。
