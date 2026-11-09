# R7 独立验收验证

受检版本：`e2c122de616207c9e5166a9c89416233b8b81268`。日期：2026-11-09。角色：独立验收验证，未承担作者、代码审核、测试设计或原生测试执行。

本轮四项调查/文档验收已有充分证据；建议 AC-044 **passed（顺序文档）**、AC-045 **design_reviewed（独立设计审核）**、AC-046 **passed（Linux 原生构建可行性调查）**、AC-047 **passed（许可来源调查）**。这不表示 Linux 产品实现、正式集成或许可授权通过。Linux 全量产品 AC 仍为 **pending**，bitarray 声明冲突及最终分发材料/授权核实门槛仍未清。

## 隔离、固定输入及方法

以 `git clone --no-hardlinks` 建立本角色目录 `repo/`，detached checkout 上述完整 SHA；最终 `git status --short` 为空。仅在 `/workspace/work/r7-acceptance` 写脚本、下载及报告；未修改主仓库、未提交、未推送、未联系维护者。未读取作者隔离目录、过程推理或自评。仓内 README/索引仅作为待核声明；仓内历史日志只做摘要清单核验，不作独立运行结果。

读取 AGENTS、R7/input、TASK-044/045/046/047 及 AC、分解/Battle 证据规则。独立审核输入为 `/workspace/work/r7-independent-review/{independent-review.md,re-review.md,findings.json}`；执行事实来自另一角色初测与复测报告、机器结果及其原始日志。通过云技能工具读取并应用 `c5/verification-before-completion`，实际核对固定内容、命令退出值、原始输出和验收映射；AGENTS §11 允许不变结果复用，本角色不重复承担原生执行或重跑 766 编译。

所有实质检查命令及退出值见 [validation.txt](validation.txt)；可复现脚本为 [audit.mjs](audit.mjs)、[check-contract.mjs](check-contract.mjs)、[check-provenance.mjs](check-provenance.mjs)、[check-unicode-source.mjs](check-unicode-source.mjs)、[check-execution.mjs](check-execution.mjs)。初始只读探索未完整转存，未声称其为带时序的执行日志；validation 末尾明确列出实际准备命令及自定义入口。

## AC-044：Linux 顺序与全量闭合

独立从 docs/tasks.md 表格及卡片解析 **37 个产品任务**，DFS 全图无环。TASK-024 的传递前置恰为 **33 个**：001–023、025–032、037、041；缺失 Linux 集合=[]，额外/非 Linux 集合=[]。038/039/040 每项显式等待 024，不是 Linux 前置。详见 [contract-results.json](contract-results.json)。

逐项检查集成归属：023 包含 009、021、022、027、030、031、032；027 覆盖四主题/完整组件并依赖编辑和滚动；031 覆盖 M2 与 M1 对照并包含 037；020 只等待 Linux 后端 041 及共同前置。文件快照、ANSI 输入、主题、编辑、动态构造、可选会话能力报告、示例、基准、制品与整体验收均进入闭包。可选宿主能力允许明确 unsupported/unknown，不等于删除能力报告契约。

REQ-011、NFR-07、架构、提案及主/增量规格保留 Windows/macOS/HarmonyOS 为未来 required，当前 Linux 全部通过后再推进；Linux 不能外推为四平台通过。现行任务/提案的旧授权反例用 rg 未命中（退出 1，表示无匹配）；当前 Linux 实施已授权，但产品 L3 前置/DQ 与发布边界仍存在。基线到受检版本的 src/examples/benchmarks/tests 无变更，未把本轮文档当产品实现。

## 工具、仓库与规格一致性

复用主仓库既有锁定 node_modules 作为只读工具，在本角色目录建立工具解析链接；未安装新依赖。实际 Node 为 v24.22.1、OpenSpec 1.14.3、smol-toml 1.4.2，与 package.json 约定一致。`docs/development/tools.lock.json`、`package-lock.json`、`scripts/setup-development.mjs` 与初次独立受检 `9a5c7034...` 逐字节一致。

`npm run check` 退出 **0**：仓库/配置/本地链接/任务映射检查成功；`openspec validate --all --strict --no-interactive` **8 passed、0 failed**。另逐 Requirement 核对活动变更到主规格，**28 段全部原文相同**，包含本轮 terminal-session 与 distribution 阶段条款。该检查不验证产品能力。

native/SHA256SUMS **23/23**、licenses/SHA256SUMS **27/27** 一致，均退出 0。两份 shell 脚本 `bash -n` 和生成器 `node --check` 退出 0。保存证据摘要只证明固定字节；独立来源核对如下。

## AC-047：确切包、来源及许可边界

从 `/workspace/work/validation/replay-dependencies/archives` 只读取得四份原 cjp，分别独立 SHA256，比对 R5 中心仓索引和 R7 索引全部相同；解包只写本角色目录。独立通过网络对索引四个仓库 `git fetch --depth=1 URL COMMIT`，checkout 固定提交，没有读取作者克隆。对原包每个实际文件与 Git 对象对应路径重新比较，区分字节一致、仅 CRLF/LF、实质差异及上游缺失。重新取得的 **12 份许可/归属原文**与仓内保存字节及索引摘要全部一致；原包 README/清单保存副本也逐字节相同。

| 包 | 固定上游 commit | 同字节 / 仅换行 / 实质差异 / 上游缺失 |
|---|---|---|
| bitarray 0.1.0 | `c6c5a40a5ed2a51199cb3a8b9702c01a8da1e694` | 14 / 0 / 0 / 4 |
| unicode 0.1.0 | `a12b0d8009e3111cc3f98563026a5b2dbfaf149f` | 1 / 37 / 3 / 1 |
| unicodewidth 0.1.113 | `b3d9c8c8684f3a093a2e9d9d306ec36a3eb67cb5` | 1 / 34 / 0 / 0 |
| ansies 1.3.113 | `dac6fe9ab1407cd533153e98b091cda0d8610713` | 108 / 0 / 2 / 13 |

逐文件摘要/差异列表与独立取得来源见 [provenance-results.json](provenance-results.json)。计数、实质差异及缺失路径全部匹配固定索引，非仅作者汇总通过。

明确保留的对应关系边界：ansies 上游清单为 1.3.105，原包为 1.3.113；差异是清单和一个测试文件，另有 13 个包内 macrocall 生成物，上游缺少这些文件，不能称完整固定发行版一致。unicode 有 3 个 README/测试差异和包独有 `unicode/unicodewidth.cj` 宽度封装（本角色实际读取），因此上游 Mulan 文本不能当所有包字节都已证实同源。unicodewidth 全部 35 个包文件仅换行差异或相同，许可证补入和最终制品归属仍待做。bitarray 缺失的 4 项是包内示例缓存/lock，与真实源码对应必须分开描述。

本角色直接读取并再次发现：bitarray 原包和固定上游 README 的许可证写“无。”；根 LICENSE 首行写 unicodewidth4cj，MIT 版权行写 cfgif4cj contributors，而独立 LICENSE-MIT 写 Rust Project Developers。unicodewidth 的合并 LICENSE 也有 cfgif4cj 错置。ansies TextStyle 源码实际 import bitarray 并使用 PartitionedBitArray，不能凭应用不调用或只删直接依赖证明制品不含它。以上事实支持“冲突已定位、尚未解除”；没有作“法律禁止使用”或“许可已经批准”的结论。

Unicode 官方 license.txt、terms_of_use（跳转 copyright.html）、17.0.0/ucd/ReadMe 三份本角色重新联网获取，均 HTTP 200，**与保存原文逐字节相同**；原始 UCD zip 的 ReadMe 也相同。17.0.0/ucd/LICENSE.txt 实际 HTTP 404，未虚构自带许可文件。完整 SHA/实际终点见 [unicode-official-results.json](unicode-official-results.json)。官网 v3 ©1991–2026 与数据 ReadMe ©2025 分别保留；Data Files 的 /Public/ 范围与 Unicode License v3 链可定位。最终生成表/归档的版权、许可随附及所有发布门槛仍需真实制品核实。

## AC-046：独立原生执行事实与复用边界

初次执行在 `9a5c7034...` 的独立目录证明正常 consumer 构建缺少四个 native 符号（实际编译退出 1，为预期失败）、原库生成器及七张表、C/ASM/静态归档、显式链接、dependency-owned FFI 和官方 766 条分段向量。原始 grapheme 日志明确 `GraphemeBreakTest17 raw total=766 failed=0`，空串另输出一个空簇，不能混入 766 个官方向量。NFD 只证明 é 样本，不是规范化全量。

初次 run-transitive 退出 1，ITE-001 的 adapter-owned 阶段复用了旧 exe；这份失败保留，未被作者 PASS 取代。最终 e2c122d 独立执行仅复测受影响 transitive 路径；本角色读取原始复测执行、trace、最终状态、编译/运行日志，并逐一核对 6 份 rawLogIndex SHA，全部吻合。

修复证据足够证明本次重新链接：trace 的 `mktemp -d` 创建 `adapter-owned-target.lQE8CF`；先 `[[ ! -e .../release/bin/main ]]`，后 `[[ -x .../release/bin/main ]]`；实际 consumer 编译行同时包含该新 target 的 output-dir、`-lnative_adapter`、`-lunicodedata` 与 exe 输出。原始日志随后明确：

```text
Run current project: ... /workspace/work/r7-independent-test/retest-native-probe/adapter-owned-target.lQE8CF/release/bin/main
PASS transitive FFI through intermediate static adapter
cjpm run finished
```

原始 retest-execution.log 记录 **run_transitive_exit=0**。其 set -e 链及脚本 set -euo pipefail 对嵌套构建/运行和断言形成成功状态证据；嵌套命令没有逐个打印数字，不夸称存在逐项独立数值记录。最终状态原文记录 `official_unicode_manifest_cmp_exit=0`，consumer 只 import adapter、无 root link-option/FFI；adapter 输出 static 并拥有 FFI，unicode 清单已恢复原包。故新日志证明实际新 consumer 编译、链接及运行，超出单纯脚本自报 PASS。完整实际命令行见 [execution-evidence.json](execution-evidence.json)；原始独立目录仍保留完整日志。

766 结果复用依据由本角色重新核对，不依赖新 commit 名称推断：

- unicode cjp：`d810505f62b43417ce673fb9c811f740503d3df88665307557544eae6d073c4c`；UCD zip：`2066d1909b2ea93916ce092da1c0ee4808ea3ef8407c94b4f14f5b7eb263d28e`，实际输入均相同。
- run-native.sh：`4470e67f35e5dafe8f6910d737f88345c792043c75a8df967ef54b80815a2742`；generate-conformance.mjs：`202453714f7fe5a3f35d5bc2eb7a67765c8864f9d06d9ccdb2be579e2ba2ac0f`。两者及全部 templates 从初次到最终 Git diff 为空；已记录模板 SHA 逐一相同。
- 官方 GraphemeBreakTest：`e2d134d2c52919bace503ebb6a551c1855fe1a1faec18478c78fff254a1793ec`；生成源码：`08eee34893b887f996786649cb4e2ec05a7ed3f55c6a58082e2a7b81d07aef71`，实际独立执行文件摘要吻合。
- SDK/CJPM 仍为同一路径 1.2.0，同一 Linux x86_64 环境；复测复制的是独立执行者自己的源码/native 输出，没有继承 consumer target。原始与复测 native archive 摘要 `96f0552e197c0f02a7860f13cd0174617df639315252221828785103628e0c03`，独立执行 cmp 退出 0。

只有 run-transitive.sh 改为 fresh target（最终 SHA `613c25077512af6ccfe2c11bed0228ed4d457e9bbfabf45cd28417ea0e0a9050`），未改变官方分段受检对象。无需重跑完整 766；本角色也未执行编译。

## AC-045 与最终状态建议

独立审核 findings 保留原始受检版本、反例、首次部分修复和最终复核；IR-001–003 在固定最终 SHA 均 verified，re-review 仅判 design_reviewed。验收者再次核对授权入口、044/046/047 单一交付拆分、045 消费三者、skill 引用可定位以及工具复用事实，没有从审核结论推导运行或法律通过。

| AC | 建议状态 | 可关闭的本轮范围 | 保留边界 |
|---|---|---|---|
| AC-044 | passed | Linux 顺序、无环、全量前置闭合、非 Linux 后置 | 产品能力仍 pending |
| AC-045 | design_reviewed | 独立审核、必需发现修复复核与 DQ 设计记录 | 不代判产品或许可授权 |
| AC-046 | passed（调查） | Linux x86_64 原生根因、生成/链接、跨 static adapter FFI、766 分段及空串风险 | 产品 hook、干净 cjp 生命周期、规范化全量、终端会话及其他平台未验 |
| AC-047 | passed（调查） | 固定源码/原包对应、完整许可来源、差异和冲突可复核 | bitarray 等授权/归属门槛及最终制品许可未清 |

当前固定 repo 的任务/AC 仍未勾选完成，这是本次交付前的状态；本角色不修改状态权威。主代理可据此登记本轮调查/审核结果，不能把 TASK-001/003/004/041、其他 Linux 产品 AC 或发布许可改为通过。
