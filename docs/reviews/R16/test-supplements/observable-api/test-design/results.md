# 实际执行结果

| 记录 | exit | 范围 |
|---|---:|---|
| observable-private-value-red | 1 | 正常公共consumer真实private-field编译RED |
| observable-getset-build | 0 | 正常公共get/set consumer构建成功 |
| environment | 0 | 实际SDK1.2.0/固定父提交 |
| unchanged-contract-check | 0 | 期望/native/G012/产品无改动 |
| observable-getset-run | 0 | 实际binary运行9项响应式检查通过；非Glyph Session |
| precommit-check | 0 | 仅Session fixture，8增8删；whitespace通过 |
| final-verification | 0 | 全部源码hash通过，独立树clean，仅1个test文件提交 |

正式Glyph Session/PTY/native没有执行；不声称Session GREEN。原094 FAIL与独立公共consumer RED均保留。
