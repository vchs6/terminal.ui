# 2026-11-20 全局逐文件 metadata 恢复快照

本次重新扫描记录 **1,077,804 项、28,008,244,375 逻辑字节**，另列 148,535 个目录。纳入 264 个仓库记录、15 份已交付清单、131 份固定基线历史索引和 180 个基线 tar.gz 路径。本次结果与 11 月 15 日独立取样，旧报告、摘要和阶段记录保存在 snapshot-20261115。

| 类别（互斥） | 文件/节点数 | 逻辑字节 |
|---|---:|---:|
| 未找到恢复证明 | 285,227 | 20,889,981,625 |
| 首包导出HEAD + 当前Git clean | 488,792 | 3,435,511,879 |
| .git/bare元数据，需单列refs/bundle恢复边界 | 206,360 | 1,166,390,147 |
| 迁移包manifest有member；当前原件SHA待核 | 10,377 | 965,191,788 |
| 旧索引仅原路径hash引用，未闭环 | 10,259 | 932,747,486 |
| 旧索引有exact member/copy；当前原件SHA待核 | 62,422 | 353,182,240 |
| 当前clean blob与已导出a5 baseline相同 | 5,978 | 235,671,813 |
| 7固定shallow上游的tracked clean文件 | 8,389 | 29,567,397 |

所有包/旧archive SHA均来自既有metadata。**没有重新hash原件；size相同不等于SHA相同。** 历史exact locator表示索引声明可恢复member/copy；本轮没打开archive payload验证。Curated lineage与仅hash引用均不能证明原报告/原测试已迁移。Git证据绑定当前status、HEAD/index blob、首包精确refs或a5 baseline；不是全文件SHA扫描。

已交付清单中有 10,505 条显式 member 记录。历史 locator 中有 112,499 条带显式 member、18,206 条只带 copy 或其他 locator。另列 52,433 条历史 hash 引用，显式 member 为 0。

源体节点包括13,907 个FIFO、1,063,744 个常规文件、2 个socket、151 个符号链接。扫描使用节点自身的 stat 信息。Git 恢复边界为内容 blob 和 Git 模式，catalog 另外记录原节点模式和类型。

Git 对象存储和其他 Git 元数据单列，共 206,360 项、1,166,390,147 逻辑字节。首包 refs 和 bundle 的证明范围为可达历史。不可达对象、hooks、配置、reflog 和本地认证另有各自的保管边界。

历史原路径仅有 hash 引用的未闭环项为 **10,259 项、932,747,486 B**。另有 1,428 个 curated 原路径 lineage 记录仍未闭环。两项可重叠，具体证据见摘要和 evidence 表。

未闭环curated lineage原路径示例：

- `glyph-acceptance/README.md`
- `glyph-acceptance/acceptance-matrix.json`
- `glyph-acceptance/acceptance-matrix.md`
- `glyph-acceptance/finalize.py`
- `glyph-acceptance/findings.json`
- `glyph-acceptance/pending-matrix.json`

SDK/cache本轮**0文件获得完整可重取免迁证明**。目录名、旧索引excluded声明、只有SHA均不足；仍需来源URL/版本/包hash/恢复命令/所需native闭包。七个声明固定上游有准确HEAD pins和clean tracked证据，catalog未读remote配置；重取来源locator仍需外部现成证明。

- `CangjieSkills` @ `277f2e1234ca5217496966887243c679653887a8`
- `cangjie-rules` @ `40bacab1dafc7c5710a9b14c5c5c86898feed63c`
- `r7-acceptance/upstreams/ansies` @ `dac6fe9ab1407cd533153e98b091cda0d8610713`
- `r7-acceptance/upstreams/bitarray` @ `c6c5a40a5ed2a51199cb3a8b9702c01a8da1e694`
- `r7-acceptance/upstreams/unicode` @ `a12b0d8009e3111cc3f98563026a5b2dbfaf149f`
- `r7-acceptance/upstreams/unicodewidth` @ `b3d9c8c8684f3a093a2e9d9d306ec36a3eb67cb5`
- `terminal.ui/.dev-tools/superpowers` @ `bb92a77741419a4ab5f06e711a283343f1ada0c3`

逻辑custody单列：5,490逻辑原件，0逻辑路径当前存在，5,490有当前物理gzip，128有迁移包物理member、5,362有历史exact locator（两者可重叠）；尚需map/receipt、physical SHA与包member联核。现有清单引用 20 份 progress 或 restore-map，提供 128 条映射记录。两个已移除的首包派生暂存副本仍按 cleanup receipt 对账，原字节由已发布 part01 同名成员保管。

优先候选队列（未读内容）：**7,801安全小报告/测试原件、31,227,880B**，每件≤200KB，均未找到exact member闭环。先做有限SHA及来源复核，再决定保留原字节；不能直接把全部候选打成无限分卷。较宽小文件队列另有36,833项（含待核旧exact locator）。

- `theme-showcase-archive/report.md` — 597B；unresolved
- `validation/e146-runtime-headroom-20261114/report.md` — 667B；unresolved
- `validation/e146-runtime-headroom-20261114/round2/report.md` — 698B；unresolved
- `validation/e146-runtime-headroom-20261114/round4/report.md` — 817B；unresolved
- `projection-execution-archive/report.md` — 841B；unresolved
- `validation/e146-runtime-headroom-20261114/round3/report.md` — 842B；unresolved
- `keyboard-tests/integration-profile-fix/report.md` — 887B；unresolved
- `validation/ended-129-bundle-intermediates-20261114/report.md` — 907B；unresolved
- `widgets-small-tests/typing-fix/report.md` — 941B；unresolved
- `widgets-small-tests/initial-theme-fix/report.md` — 968B；unresolved
- `review-archive-execution/cli-v1/report.md` — 1098B；unresolved
- `linux-final-construction-review/round1/report.md` — 1106B；unresolved

大数据全部位于host RAM：

- `catalog.sqlite3`：完整files/directories/repositories/evidence/inputs/logical_custody表；路径以/workspace/work为根。
- `unresolved.jsonl`：全部未闭环物理节点；`source-sha-obligations.jsonl`：包/旧exact locator的当前SHA义务。
- `logical-custody.jsonl`：逻辑缺失与物理gzip/member区分；`priority-original-candidates.jsonl`：本轮优先队列；`small-safe-candidates.jsonl`：宽候选。

RAM目录：`/dev/shm/terminal-ui-migration-20261115-host/global-catalog-restored-20261120`。常规sandbox namespace看不到该RAM，读取需require_escalated。

SQLite quick_check 返回 ok。独立 SQL 核对显示类型和互斥类别均合计 1,077,804 项、28,008,244,375 逻辑字节。禁区和受保护路径记录 0，Git 错误 0，scan 错误 0，未识别 Git root 0 个。Git status 对预检发现的受保护索引项另设路径排除。审计没有打开候选原日志或包载荷，也没有对原件批量重新计算 SHA。

这份catalog收敛了逐文件metadata边界与具体待办；没有宣称整迁移验收完成，也没有用目录汇总推算剩余分卷。

可移交的 gzip 账本位于 `/dev/shm/terminal-ui-migration-20261115-host/global-catalog-restored-20261120/compressed-ledger`。完整 SQL 导出通过重新导入、SQLite quick_check、逐表计数和 schema 对比。六份 JSONL 均通过逐行解析与解压字节校验。各文件的压缩字节数和 SHA-256 见本目录的 `operation-record.json`。
