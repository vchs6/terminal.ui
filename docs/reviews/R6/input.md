# R6 跨平台补充审核输入

日期2026-11-09。基线 f998e158cf5ccd8b4743c24316e5ed6c9a8a6f26（已推送R5完成版本）。本轮用户新增“支持跨平台，也要支持鸿蒙OS”。先前文档修订、必要验证、独立审核和main推送授权继续适用；没有产品实现或发布授权。

目标：将跨平台及HarmonyOS从待调查候选提升为必需产品目标；四目标矩阵Linux/Windows/macOS/HarmonyOS为工程细化，不虚称用户指定具体OS/SDK版本或CPU。主框架仍为字符终端，共用公开UI和视图源码；终端宿主/权限/ABI逐目标调查冻结；OpenHarmony和鸿蒙作为SSH客户端都不能替代HarmonyOS本地运行。标题/图标/剪贴板仍是可选宿主能力。

采用既有活动变更 refine-terminal-ui-contracts，不另造整项目提案。使用openspec-update-change修订已有proposal/design/tasks与terminal-session/distribution场景（用户已直接授权新增需求修订，不重复索取同一授权），openspec-sync-specs同步主规格，brainstorming核对已选平台后端方向，verification-before-completion检查；沿用R5已安装锁定OpenSpec1.14.3/Superpowers7.0.0和workspace cache/XDG配置，不重复安装工具。

分工：GPT-6.1 Sol/high只读官方平台/鸿蒙资料与本地SDK帮助，只写platform-evidence.md；主代理编写跨平台规格与任务映射；未参与本轮撰写的独立审核者审查固定commit及证据。R5历史审核不外推为R6通过。本轮TASK-042文档与来源核对、043独立审核；未来产品后端TASK-038–041仍planned。TASK-001/003/004调查/冻结范围、TASK-020/023/024集成责任同步，不新增GUI/PTY产品目标。

请审核：REQ-011/NFR-07、长期架构/会话/依赖、主/增量规格、四后端依赖无环及最终制品闭合；source资料是否被夸大；不得把官方工具链可用、模拟器、日志输出、OpenHarmony或远程Linux当本地核心验收。缺少鸿蒙设备/跨工具链实测应如实pending，不判文档任务必须现在实现平台后端，也不把必需平台降为可选。

受审版本用完整commit记录；本轮最多3次修复复核或60分钟有效执行。写入independent-review.md和findings.json，按Battle字段定位问题；只许独立审核者写审核结果，不修改规格。通过结论仅design_reviewed，产品仍pending。
