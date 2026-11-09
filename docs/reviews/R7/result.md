# R7 结果：Linux 优先及平台／依赖风险调查

本轮文档、调查、独立执行和验收完成；产品仍为0.0.0开发状态，尚无框架实现。固定技术版本为e2c122de616207c9e5166a9c89416233b8b81268；后续收尾提交只登记证据和状态，不改变该版本受检脚本、依赖或契约。

- AC-044 passed：Linux全量任务闭合，非Linux后置；四平台required目标保留。
- AC-045 design_reviewed：三个设计/治理发现均由原独立审核者复核verified。
- AC-046 passed（调查）：定位普通构建原生缺失，验证固定输入生成、链接及静态适配库拥有FFI的传递路径；Unicode17官方766分段用例通过，空串薄适配需求保留。
- AC-047 passed（来源调查）：独立联网比对四包固定源码和12份许可/归属原文，Unicode官网许可链另核；没有认定法律授权已通过。

独立测试曾发现旧脚本复用可执行文件，初次run-transitive退出1。作者修复后，独立执行者从新target实际编译、链接并运行，退出0。原失败及修复记录完整保留。只有未变脚本、输入、环境及对象的766/原生结果复用，受影响路径重新执行。

## 证据与独立角色

| 角色 | 模型与隔离 | 交付 |
|---|---|---|
| 原生调查／脚本修复 | Sol/high，作者隔离目录 | [复现入口](evidence/native/README.md) |
| 许可来源调查 | 另一Sol/high，独立目录 | [固定来源](evidence/licenses/README.md) |
| 独立审核 | Astra/high，新clone/固定版本 | [初审](independent-review.md)、[复审](re-review.md)、[发现](findings.json) |
| 独立测试执行 | Sol/medium，另一clone及新构建目录 | [初测失败](execution/report.md)、[修复复验](execution/retest-report.md)、原始日志及结果JSON |
| 独立验收验证 | 另一Sol/high，新clone，独立网络获取来源 | [逐项验收](verification/verification.md)、[实际命令与输出](verification/validation.txt) |

主代理只负责文档、协调、集成及状态登记。新用户要求的后续产品测试设计、代码编写、审核、执行、验收五个角色分离流程已写入AGENTS13.2，不以作者自测替代独立验收。当前有界探针不是产品代码交付，未据此声称未来流程已经执行。

## 仍需完成

Linux产品TASK-001/003/004/041及所有产品AC保持pending。下一阶段须将已验证原生路线转为正式构建入口/干净制品消费，完成平台/构造契约，再按前置L3实施；固定Linux控制台和模拟终端的输入、尺寸、失败与恢复仍需产品实测。其他平台在Linux全部功能及验收完成后推进。

bitarray README及许可项目名/版权归属冲突尚未澄清，ansies/unicode包与上游差异、最终制品归属核实仍是发布前门槛，不阻塞Linux内部开发。没有联系维护者、没有发布，也没有把风险来源调查通过称为所有风险消除。

该活动变更仅登记本轮规格/证据完成，不归档成产品完成。技能与复用记录见[skills.md](skills.md)，发现处理见[response.md](response.md)。
