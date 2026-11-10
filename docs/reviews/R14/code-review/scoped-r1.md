# TASK082 round1 限定复核

**Spec compliance：PASS。Task quality：PASS。R14-T082-001：ADDRESSED。** 当前开放 Critical 0 / Important 0 / Minor 0；关闭原 Important 1，无新增发现。

固定产品为 `91c22f82adcd2412d9509b9872ff63450ba81af9`（tree `d5b0e4c34cf2400415980450a1178400f7885d2b`），正式测试固定为 `cc556f4e4548c51c3d99e5a06768e61b41932d75`。相对首轮 `034685dacd76f1450317b0352411ddc4be112136`，产品只变更 `src/text/ansi_text_decoder.cj` 的6行；测试增加1个回归文件并更新 README/main，不修改旧断言。本轮仅裁原 finding 和该修复的直接影响，未重开无关文件。主仓集成 `27f9c8c` 的 src 与固定产品差异为空。

## 修复判断

`src/text/ansi_text_decoder.cj:113` 在现有合法 UTF-8 lead 分支内，仅当 state 为 Csi 时立即调用原 `issue(MalformedSequence)`。因此 `ESC [ C2` 的 C2 到达时已发出语法首错，A0 后续越界不再改变种类。原 `countByte` 位于该分支之前，因此若 C2 本身越过 budget，则同 byte 的 `SequenceTooLong` 仍优先。`issue` 的 fault guard 保留第一次问题并清有界 CSI 缓冲，没有重复诊断或新状态来源。

提前诊断没有更改 state，也没有提前返回。后续仍进入同一 UTF-8 pending 路径并调用 SDK `String.fromUtf8`；非法 continuation 或 finish 时残缺 scalar 仍执行 `InvalidUtf8` fail-close。同一失败调用不交付 batch，已交付旧 batch 不回滚，符合原异常流契约。完整 scalar 仍按已失败 CSI drain 到 final，既不泄漏正文，也不重启嵌套 C1/SGR。正常 Text 状态中的 UTF-8 C1 introducer、普通 continuation，以及 ControlString 隔离均不命中新 guard。

这是在既有输入状态机的正确职责位置修正 byte-order 诊断，无新公开 API、缓存、额外解析器、依赖或持有状态，未发现修复直接引入的质量或兼容问题。

## 核实的证据

审核读取实际6行产品 diff、冻结回归测试及原始输出；不使用作者报告、自评或 progress。`scoped-r1-sourcehashes.json` 将首轮79个受审产品文件与固定新源逐个核对，只有 decoder 的 hash 改变；3个测试变更文件与独立 cc556f4 源逐字节相同。正式全部测试文件、实际 SDK/依赖、最终 cjp、两个实际 consumer 二进制 hash 均核对成功。

| 原件 | 实际结果与适用范围 |
|---|---|
| 独立测试角色 old034 build/direct | build exit0；直接二进制 exit1；旧11组 PASS，新98案例共56个失败检查，准确暴露前缀缺失诊断与后续错误替换。原件复制至 `r1/raw/independent-red-*`。 |
| r1-green | build及直接测试总 exit0；旧11组和新增98案例全部通过，回归失败数0。包括预算3/4立即诊断、预算2同 byte资源优先、全块/每切点/逐byte/空块、绝对offset、去重、隔离、非法/残缺UTF-8关闭和正常C1。 |
| r1-bundle | 普通 cjpm bundle exit0；保留原 lint 警告，不声明零警告或完整发布通过。 |
| r1-clean-consumer | 最终cjp解包后公开consumer构建与直接运行exit0，完整同一正式矩阵通过；source diff为空，仅consumer manifest相对path调整。 |

三个最终 GREEN 日志 `.meta` 的 staged-tree 都与固定产品 tree 完全相同，SHA256 与原件相符；`r1/raw/log-audit.json` 保留逐条 source/exit/hash 关系。独立 RED 的 build/direct exit 文件与 raw日志均保留，未将失败数和案例数混用。`r1/raw/final-artifact-check.log`、`formal-test-check.log`、`environment-check.log` 给出实物核对结果。

依据 AGENTS11.1，以上覆盖、固定代码、环境及配置的证据有效，本轮未重复运行任何 suite，也未重复原独立观察 probe；该 probe 的反例已经包含于冻结正式回归的立即前缀案例。复核结论来自修复控制流审查与已核实原件，不因作者 GREEN 自动通过。

## 保留与边界

首轮 `report.md`、`findings.json`、probe 和 raw 未覆盖，原 `SHA256SUMS` 全部验证成功，见 `r1/raw/prior-evidence-preserved.log`。本轮独立source位于 `r1/source`，记录位于 `r1/raw`，新增报告、findings及sourcehashes使用 scoped-r1 前缀；清单为 `scoped-r1-SHA256SUMS`。

未编辑产品、正式测试或主仓，未创建子代理，未联系产品作者。本次只关闭 R14-T082-001。此前完整制品边界缺 composition/benchmark 的失败仍按首轮报告保留；TASK083、TASK084与完整Linux发布不由本轮审核代替或提前关闭。
