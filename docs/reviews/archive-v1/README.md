# 评审资料无损归档

以 `f0b6b3f9c32a0de1050ee2b1c7bbab4834ab734c` 的评审资料为基准，26 组原件按轮次压缩到各组 `.archive-v1/`，统一由 [catalog.json](catalog.json) 索引。原始 Markdown、PNG、校验与证据索引、文档链接目标及现用配置保留原路径；原报告和历史索引没有重写。

| 原始资料 | 文件数 | 字节数 |
| --- | ---: | ---: |
| 迁移前 | 36,756 | 453,165,327 |
| 保留原路径 | 3,800 | 107,293,030 |
| 仅在归档中存储 | 32,956 | 345,872,297 |

分片、清单与目录历史合计 51,756,740 字节；迁移本体净减少 294,115,557 字节（约 280.5 MiB），新增说明和审计包另计。原有 Git 历史保持不变，Git 对象占用与检出文件占用分别统计。

在仓库根目录查询、验证或恢复：

```sh
node scripts/review-archive.mjs --root . list
node scripts/review-archive.mjs --root . verify
node scripts/review-archive.mjs --root . resolve docs/reviews/R11/acceptance/SOURCE_SHA256SUMS.txt
node scripts/review-archive.mjs --root . restore docs/reviews/R11/acceptance/SOURCE_SHA256SUMS.txt /tmp/R11-SOURCE_SHA256SUMS.txt
```

恢复前校验完整分片及原始内容，目标已存在时拒绝覆盖。归档保留完整历史权限；保留在检出目录的文件遵循 Git 的执行位语义，允许普通检出的读写权限归一化。外部 SDK、缓存或历史工作目录中的文件不属于此目录归档；其来源仍由各原报告说明。旧校验清单若引用已归档路径，先恢复文件再运行原校验命令。

[迁移执行报告](audit/execution.md)记录逐组数量、原始哈希、全部移除文件的恢复验证及三项额外保留决定。[工具说明](../../../scripts/review-archive/README.md)说明分片、保留策略和中断恢复。历史目录版本以哈希命名保存在 `catalog-history/`，封存时的目录记录可继续还原。

后续新增资料使用新的归档版本，不覆盖现有分片、清单或历史结论。

[最终工具复审](audit/source-review.md)与[70 项独立工具测试](audit/tool-tests.md)分别给出源码和实际执行结论。[审计原件包](audit/evidence.tar.gz)及[逐成员哈希清单](audit/manifest.json.gz)保留初始失败、修复、独立测试、迁移和恢复记录；所有 1,696 个审计成员已逐项核验。生产轮次分片仍位于各轮次目录，没有重复打入审计包。

[独立最终验收](audit/acceptance/report.md)：`PASS_CURRENT_REVIEW_ARCHIVE`，包含标准 umask022 的完整新检出验证。其[原始证据包](audit/acceptance/raw-evidence.tar.gz)和[归档索引](audit/acceptance/archive-index.json)保留实际命令、原件校验与检出结果。
