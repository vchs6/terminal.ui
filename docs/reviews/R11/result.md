# R11：Linux 连续实施的帧合成增量

最终技术版本 `5c2a7e7` 在原有 Frame/Cell 上增加透明单元、合成、复制/缩放、清除、有界分配和完整 UTF-8 文件快照。普通空格仍不透明；copy/resized 保留显式透明孔，composite 跳过透明。零面积极值兼容旧行为。

## 实际验证

| 入口 | 结果与证据 |
| --- | --- |
| 新公开消费者 | 独立执行 150 个断言及 15 个字面文件字节检查，通过；[执行报告](execution/report.md) |
| contract/coordinates/colors/layout/decoration | 五项实际回归退出0，按固定内容、依赖和环境复用原始结果，没有伪称再次执行 |
| 标准 bundle | 实际执行自带 lint，退出0；原 warning 全保留 |
| 实际源码包及普通消费者 | 62个文件与源一致；正常解包build/check通过；只改临时依赖路径的冻结消费者再通过150+15检查 |
| 完整包检查器 | 实际退出1，仍缺后续 composition 项目；完整 Linux/release 尚未验收 |

首次新 API 的真实 RED、透明孔复制的定向 RED 与修复后结果均有原件；[测试契约](test-design/report.md)、[初轮审核](review/review-round1.md)、[最终限定复核](review/recheck-f003.md)、[有限验收](acceptance/report.md)分别记录范围。首次契约预检发现预算与旧零面积测试冲突，已修规格保留旧断言；未以测试迎合实现。

本增量关闭的是 Frame 层 AC005/007 和相应质量门槛。AC010 的文件原语已有证据，实际应用可见覆盖层快照仍待后续集成。本轮未新增框架 GUI 截图，已有截图采集方式将在完整交互实现后复用。

## 证据归档

各角色目录的 SOURCE_SHA256SUMS.txt 记录按字节复制的选定原件。排除 `.cjp` 本体、ELF、SDK、依赖缓存、target 和重复解包产品源码；实际包摘要、逐文件审计、运行命令、退出码与新文件原件均保留。支持环境调查只说明宏/TOML/宿主可行性，不冒充新功能验收。

当前执行目标仍是[完成全部 Linux](../../linux-completion-plan.md)，不是在该增量结束。后续持久组件、状态、交互、主题、M2、完整应用及 release 的状态见[唯一工程任务](../../tasks.md)。
