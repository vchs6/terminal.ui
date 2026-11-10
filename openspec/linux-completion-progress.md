# SDD ledger — plan: docs/linux-completion-plan.md

基线 31a7017e6bb522e3f4bcabd2f01abe1d81ea2170，与 origin/main 同步且工作区干净。用户本次明确“完成 Linux 阶段的所有工作”；先前自主实施、独立角色、适合模型、直接 main 集成授权有效。本次不以某一有限增量完成作为整个 Linux 任务结束。

已读 Superpowers using/brainstorming/writing-plans/subagent-driven-development/parallel-agent 及现有工程规范；用户已长期退出重复确认/菜单流程，需求和路线明确，按已批准目标进行工程细化，不再要求逐方案确认。主代理只契约/集成，不代写正式测试与产品。

独立完整性审计 /root/linux_scope_audit（指定 Astra/high）交付 /workspace/work/linux-completion-audit/{scope.md,scope.json,inspection.json}，69 条 REQ 与 66 个原稳定 TASK/AC；识别 014/018 语义依赖环、31 个尚未完整通过的 Linux 产品 TASK，明确 R10 失败命令是完整 bundle checker 而不是运行过 check-product.sh release。现有许可裁决、可选图片图标不支持回退均保留。

独立源码/语言审计 /root/linux_source_audit（指定 Sol/high）交付 /workspace/work/linux-source-audit/report.md 与 probe。SDK1.2 宏/状态属性/绑定闭包、跨包派生挂载、ThreadLocal、Thread.currentThread.id、Mutex 重入通过；open 基类 init 内 attach(this) 被真实拒绝，派生初始化后调用 protected 挂载方法可行。没有产品改动。键盘 parser 尚无 paste 域；后续编辑前必须补。

独立构建/解析调查 /root/linux_build_recon（指定 Sol/high）进行正常宏 CJPM bundle/干净消费和中心仓 TOML/官方 stdx API 验证。宏 package 自动识别已通过，不需要私人 cjc flags。旧 registry relay18972失效，调查者用独立18973，不修改他人缓存/服务。

L001–L004 裁决见总计划。近期先冻结 Frame 原语：它只消费已验 Unicode/Style/Frame 输入，和完整宏/主题/焦点后续工作无循环。任务状态只由具体 change 与 docs/tasks.md 维护；AC 最终结果只由 docs/acceptance.md 维护。只追加各阶段实际交接，绝不在恢复时重复派已完成任务。

Frame阶段最终5c2a7e7已实现并独立review/execution/功能验收，准备最终metadata。新增运行时架构草稿 /workspace/work/linux-runtime-contract/design-draft.md 待主代理正式冻结；宏带参/泛型/接口/WeakRef补证 /workspace/work/linux-source-audit/supplement/report.md 已通过，early-return原生允许但宏必须显式拒绝/处理。额外宿主 /workspace/work/linux-console-hosts/report.md 已准备真实QEMU Linux内核VT80×25+tmux/screen；仅环境探针，不是产品pass，后续固定源必须真实运行。完成本Frame后继续runtime，不结束全Linux工作。
