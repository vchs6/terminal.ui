# TASK-051 第3次定点复核：构建与检查入口顺序

**spec-compliance: passed（入口源码契约范围）。code-quality: passed。** 新入口缺陷已经完成源级修复和审核；其全新clone端到端运行验证待TASK052，本报告不代签该执行结果。原SLICE-051-001–006保持verified，产品源码未变，不重开。有效修复复核预算已用3/3。

固定版本：2ad6c5ceeb0068d3b2b2d5efe010059965b9415a。比较基准：2f85fcbe4c422f4f45b69875feb4728f9bea3f8f。独立no-hardlinks副本fetch并detached checkout；只阅读固定差异、入口源和指定的独立执行原始失败日志，未读取实现者自评。未修改产品/测试/规范，未提交推送，没有重新执行全量SDK套件。此前review.md、findings.json、re-review.md和re-review-2.md完整保留。

## 失败事实及定位

独立执行日志：`/workspace/work/first-slice-execution/logs/slice-product.log`。原始记录为2026-11-09T16:53:41Z，cwd=`/workspace/work/first-slice-execution/slice-repo`，命令=`scripts/check-product.sh slice`，SDK/cjpm 1.2.0，最终exit_code=1：

```text
Error: can not find the library 'unicodedata' which is listed in 'ffi.c' field at ./cjpm.toml
Error: can not find the library 'cjtui_terminal' which is listed in 'ffi.c' field at ./cjpm.toml
Error: cjpm check failed
```

旧入口先`cjpm check`，再在slice分支执行`cjpm build`；而原生归档是正常构建hook产物。新clone尚无归档时，check先失败，后续构建根本不可到达。这是验证入口次序缺陷，并不要求改变产品依赖声明、补入预编译库或跳过真实检查。

## 源级复核

唯一修改文件为`scripts/check-product.sh`，4增3删；未改src/native/tests、cjpm.toml、build.cj或CI工作流。根目录顺序现在是`cjpm build → cjpm check`，slice继续执行`cjpm test → tests/run-slice.sh all`。正式build hook有机会先生成`libunicodedata.a`和`libcjtui_terminal.a`，不依赖前次工作目录的构建残留。

| 入口 | 固定版本行为 | 真实检查保留情况 |
|---|---|---|
| 根目录，slice/release | build → check | 根check保留；slice的test及all保留。build移出slice分支，对release增加了构建前置。 |
| 所有引入的examples/benchmarks | build → check → test | 三个命令均保留，只互换原build/check顺序。 |
| 干净解包产品根目录 | build → check | 解包后两个命令均保留，只调整先后；不使用主目录缓存制品代替解包构建。 |

release分支仍要求minimal、composition及rendering项目及源码；bench、cjpm bundle、check-bundle、临时干净解包、两个示例smoke和解包benchmark全部保留。原有slice早退位置及“不代表最终产品/release验收”说明保留。没有删除真实检查、忽略失败、放宽制品边界或降低release门槛。`set -euo pipefail`保留，新增/调整的build失败依旧停止入口。

构建职责仍在正式hook，脚本仅编排正常命令；没有重复实现原生构建、手写FFI链接、预制通过结果或针对示例的旁路。

## 实际短检查

在固定版本执行以下命令，全部退出0：

```sh
bash -n scripts/check-product.sh
git diff --check 2f85fcbe4c422f4f45b69875feb4728f9bea3f8f..HEAD
git diff --name-only 2f85fcbe4c422f4f45b69875feb4728f9bea3f8f..HEAD
git diff 2f85fcbe4c422f4f45b69875feb4728f9bea3f8f..HEAD -- src native tests cjpm.toml build.cj .github/workflows/ci.yml
git status --short
git rev-parse HEAD
```

name-only唯一输出`scripts/check-product.sh`；限定产品/测试/依赖差异为空；工作树状态为空；HEAD为2ad6c5ceeb0068d3b2b2d5efe010059965b9415a。未运行`check-product.sh slice/release`；bash语法检查不能冒充SDK或端到端通过。

## 新入口发现状态

- id：SLICE-ENTRY-051-001。
- category：code_quality / build-verification-entry。
- original_revision：2f85fcbe4c422f4f45b69875feb4728f9bea3f8f（任务交接的失败版本；原始日志本身未内嵌SHA，定位同时依靠固定任务交接）。
- fix_revision：2ad6c5ceeb0068d3b2b2d5efe010059965b9415a。
- target：scripts/check-product.sh 根入口、示例/benchmark循环、解包入口。
- contract_ref：implement-linux-first-slice/design.md D-020、TASK049/052正常构建与实际入口检查；AGENTS.md §11证据纪律。
- severity：major。
- claim：新clone在build hook创建FFI归档前check，导致正式slice入口提前失败。
- reproducer：在无native归档的固定新clone中配置SDK1.2.0及所需官方依赖输入，执行`scripts/check-product.sh slice`；预期正常build准备后继续真实check/test，旧版观察为缺少两归档且exit1。
- status：**fixed；独立代码审核已通过。端到端verified由TASK052的新clone实际执行结果完成，不在本静态任务中虚报。**
- evidence_refs：上述独立原始失败日志、固定差异、bash -n及diff检查、本报告入口对照表。

下一步已明确：TASK052从fresh clone完整补测固定2ad6c5c并提供真实命令/退出值；通过后可将此入口发现转为verified。TASK053据完整执行证据验收。当前没有需要继续修改产品的审核发现。
