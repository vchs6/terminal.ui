# 实际执行结果

| 记录 | exit | 范围 |
|---|---:|---|
| capture-mutable-red | 1 | 真实public Application.onKey捕获var，正常编译1ERROR RED |
| capture-holder-build | 0 | 标准Array holder正常跨包构建成功 |
| environment | 0 | 实际SDK1.2.0/固定父提交bfd0715 |
| unchanged-contract-check | 0 | expected/native/G012/产品无改动，仅3行修复 |
| capture-holder-run | 0 | 真实公共dispatch触发所存onKey，6项计数检查通过；非Glyph Session |
| precommit-check | 0 | 仅Session fixture，3增3删；whitespace通过 |
| final-verification | 0 | 全部源码hash通过，独立树clean，仅1个test文件提交 |

原1ERROR保留；正常public控制与正式Glyph Session分开。Session/PTY/native本轮没有执行，等待root独审后的094复跑。
