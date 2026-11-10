# TASK-068 review index

初轮固定版本 `883444195725224985f29060253017432abaa7f3` 的完整报告已冻结于 [review-round1.md](review-round1.md)：按当时 design，spec PASS / quality PASS，无 Critical/Important/Minor。本文件后续记录 scoped 复核；不覆盖初轮判断或把后续规格澄清倒算为作者违反原契约。

主代理随后作 F003 规格澄清：copy/resized 是数据复制，必须保留普通 opaque Frame 经 clear 形成的透明孔；只有 composite 跳过透明。初轮曾明确指出该组合按原 design 会恢复默认 opaque 空格。F003 的具体使用反例为源 `X[透明]Z` 复制后叠到 `ABC`，应得到 `XBZ`；原实现得到 `X Z`。

**最终固定 `5c2a7e7d956b5d8c0284e96514276608616bf8a6`：Spec PASS / Quality PASS，无未决 Critical/Important/Minor。** [F003 scoped 复核](recheck-f003.md)已核新增独立 RED 与完整 composition GREEN（165 PASS，exit 0），结合初轮覆盖 `31a7017..5c2a7e7` 有限技术范围。原轮报告保持原貌；结论不关闭全部 Linux、完整 TASK-010 或 TASK-069/070 的独立执行/验收义务。

## 后收到的旧回归 raw

原件均为 `/workspace/work/frame-implementation/{name}.{stdout,stderr,exit}`，副本在本目录 `raw/`，摘要与完整 raw 内容索引为 `regression-raw-addendum.json`。审核者只读并统计，没有重复运行，也没有阅读作者 report。

| name | 实际 exit | PASS 行 | FAIL/SKIP 行 | stderr |
|---|---:|---:|---:|---|
| contract | 0 | 109 | 0/0 | 空 |
| coordinates | 0 | 2 | 0/0 | 空 |
| colors | 0 | 1944 | 0/0 | 空 |
| layout | 0 | 114 | 0/0 | 2 条原有 unused expression 警告，tests/layout/src/main.cj:27、28；无 error |
| decoration | 0 | 59 | 0/0 | 空 |

这些结果补齐初轮报告中“尚未收到5回归raw”的时间性限制，仍是作者开发证据，不伪称本角色独立执行或 TASK-069 已完成。新 composition 原 raw 为 140 PASS、exit 0。已核实旧5消费者在基线至8834441完全未改。F003 会要求新的相关证据，不能用以上原轮 raw 声称新语义已通过。
