# Linux 主题阶段恢复交接（2026-11-11）

执行环境不可用；本记录用于恢复，不代表主题或 Linux 阶段验收通过。控制面曾显示 running，但实际命令报 `No usable execution environment is available`。未能继续运行探针、打包及独立执行。

## 已保存的源码与开发结果

- 候选源码：[wip/linux-theme-foundation](https://github.com/vchs6/terminal.ui/tree/wip/linux-theme-foundation)，固定 `97df09638e2912cbee3313c23c4254e0a1708a5e`。
- 完整审核范围：`81cd29cdf173cd02a390f3d992037de395caafaf..97df09638e2912cbee3313c23c4254e0a1708a5e`。产品提交为 `0e46237`、`1d2d815`、`b024d91`、`3a52f55`、`97df096`；独立测试 overlay 为 `dc77f8c`、`0185c9d`，勿将已在 main 的测试重复作为产品集成。
- main 在本交接前为 `d1b790a`；字形093–097已有限验收，主题产品尚未合入。
- 主题值、TOML、单一样式解析、Application 接线及 wrap/ellipsis/四边 padding 已形成开发候选。开发验证包含完整 values/integration、Glyph 离线与7个受控设备配置，以及正向门禁后的16个编译负例。这些不替代086/087/088独立审核、执行和验收。
- 16负例的前11项保留在 `themes-c1`，磁盘耗尽后按相同输入续5项于 `themes-c1-resumed`，各自按预期 exit1。Errno28原件保留。旧实现者的可重建 target 清理后恢复约4.5GB；源码、原始日志、SDK、缓存及独立执行者证据未删除。

## 独立086尚未完成

审查者已阅读主要源码，但未形成最终 spec/quality 双判定。以下是固定源码的静态发现或待验证风险，不能写成已运行探针结果：

1. `src/theme/theme_decoder.cj`：构造器提前校验 variables 类型，可能抢在版本/根必需字段校验前。反例：`schema_version=2\nname="x"\nvariables=1\n`，契约要求优先 UnsupportedVersion；缺 schema_version 变体同理。
2. `validateVariables`：先拒绝未知字段，再检查记录的 type/value，可能使较晚 extra 错误抢先于较早 value 类型错误。输入：`schema_version=1\nname="x"\n[variables.v]\ntype="bool"\nvalue="bad"\nextra=true\n`。
3. `component.cj`：setStyle 两个重载在重入检查前调用 detachPaddingSlot，可能在拒绝 getter 内修改时仍改变 padding 绑定标志；需真实 Application/Observable 探针。

有上游位置时外层 catch 会重新附调用者 sourceName；不能仅凭内部 `<memory>` 字面量认定来源标签缺陷。已有独立来源控制通过。

恢复后先完成086的必要探针、预置/包配置余项及报告，再集中处理确认的问题、限定复核。普通 bundle、干净消费者及独立087/088未完成，不得推断通过。

## 恢复定位

原工作区 `/workspace/work/terminal.ui`；实现者 `/workspace/work/theme-implementation/source`；审查者 `/workspace/work/theme-review`；独立执行准备 `/workspace/work/theme-execution`。

- SDK env：`/workspace/work/validation/sdk/cangjie/envsetup.sh`，已验证版本1.2.0。
- 固定契约：[design](design.md)，SHA256 `084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4`；T009按键位置 Lexer token.value 原始UTF8字节计1024边界。
- 开发原件：实现目录下 `checkpoint-a-raw`、`checkpoint-b-raw`、`integration-c1`、`glyph-c1`、`themes-c1`、`themes-c1-resumed`。环境恢复后核实其可用性；不能据本交接重建或伪造原件。
- 持久主代理恢复日志：`.superpowers/sdd/root-linux-continuation.md`（本地忽略文件，可能尚未写入此次环境中断）。
- 状态权威仍是 [tasks](tasks.md)；完整目标继续按 [Linux总计划](../../../docs/linux-completion-plan.md)，Theme通过后仍有异步加载、交互、输入编辑、控件、完整M1、M2及最终Linux制品验收。

用户要求降低Token消耗：复用现有独立角色与内容有效证据，同功能内补充用例并入整体验证，合并归档，不为每个L4补充另开审核/代理。测试作者、实现、审核、执行、验收仍分离。版本保持0.0.0，不发布。
