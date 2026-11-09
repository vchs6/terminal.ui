# R6 跨平台规格补充结果

结论：**design_reviewed**。未参与本轮撰写的GPT-6 Astra独立审核无必需缺陷，[findings.json](findings.json)为空；[独立报告](independent-review.md)含DQ-01–14、官方抽查及实际验证。

基线f998e158cf5ccd8b4743c24316e5ed6c9a8a6f26；受审64418db53921895e43fe7d928f806507908cd087。后续收尾只更新状态/结果/导航和验证记录，不改变已审规格或平台证据。R5原报告和结论保留，不外推为本轮审核。

## 变更

- 新增REQ-011与NFR-07跨平台要求，Linux、Windows、macOS、HarmonyOS为必需目标，具体版本/CPU/SDK/ABI/终端宿主需调查冻结；四目标矩阵为工程细化，不虚称用户逐一指定版本或CPU。
- 共用公开API和视图源码，平台差异由会话/依赖适配承担；保持字符终端边界，不引入GUI、PTY或Shell产品范围。
- TASK-038–041分别承担Windows/macOS/HarmonyOS/Linux，TASK-020汇合，再进入示例/主题展示与TASK-023/024跨目标制品/整体验收。37个产品任务依赖无环。
- 交叉编译、日志、OpenHarmony或鸿蒙作SSH客户端不能替代HarmonyOS目标实际执行与交互证据；可选剪贴板/标题/图片图标仍按能力处理。
- Unicode原生数据/归档须按目标工具链和ABI构建消费，不能复用Linux二进制作为跨平台通过。

## 证据与范围

[平台官方资料](platform-evidence.md)核对仓颉1.2.0通用/ohos工具链、hdc及沙箱/termios限制；本机只读检查SDK版本、帮助和随包运行库目录。独立审核抽查主要官方原文及原生C/ASM资料，详见其报告。没有安装鸿蒙IDE/镜像或执行鸿蒙、Windows、macOS构建部署/设备交互，不声称已实现支持。

最终检查输出见[validation-final.txt](validation-final.txt)：仓库/引用/任务检查及OpenSpec严格校验8项通过，37产品任务无环，27项delta与主规格一致，四平台责任与集成映射通过，无产品源码改动。未重跑R5未变化的语言/依赖探针，按既有规则复用其限定证据。

本轮TASK-042/AC-042文档和TASK-043/AC-043独立设计审核完成，状态权威在既有变更tasks.md。产品AC-001–032及037–041仍pending，新增平台后端不具备ready或完成结论。版本仍0.0.0，按用户授权直接提交推送main，不发布。
