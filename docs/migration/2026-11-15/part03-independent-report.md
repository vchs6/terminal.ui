# 第三批迁移独立核验

结论：在下述静态迁移范围内通过，未发现字节、权限或归档成员偏差。报告独立读取原件及归档，不采用 manifest 的 historical_pin_verified 作为证据。

核验对象：`/workspace/shared/downloads/terminal-ui-migration-20261115-part03.tar.gz`，12,190,296 bytes，SHA-256 `815499a90ce9cd5d56383c30fa2fe9c8a97e77a7caf2fca775d5883414530c0f`。

- manifest 的12个原件均为 regular file；逐项 stat/sha256sum 的 size、SHA-256、权限全部一致。ELF 为0700，其余为0600（JSON mode 分别为448/384）。
- restore-map 两个 canonical 原件与各自 primary 经 cmp 比较一致；size、SHA-256及0700模式全部一致。未创建或恢复副本。
- tar 恰含14个成员：12个 payload 加 `migration-part03/manifest.json` 和 `migration-part03/restore-map.json`；完整成员列表与期望列表精确一致，14个名称均唯一、相对路径、无 `..` 分量或反斜线，全部 regular，无目录/链接/特殊文件。gzip 完整性检查通过。
- tar 中12个payload分别流式读取全字节SHA-256，与原件/manifest全部一致；tar显示size及权限逐项一致。两份控制metadata经流式cmp与磁盘文件精确一致，均0600。
- manifest SHA-256：`a3baa7fc8a0133e338d1391a300952b4aff6fa2a5e95aed4870f3d395e115e0f`；restore-map SHA-256：`2467791d4aa7b92d69235d3afae9790b389534687305b738a3476eef131e5c13`。

历史绑定：原 build-index 的两个 executable 记录绑定当前公开ELF路径、size、SHA-256及权限（历史33216去除regular类型位后为448），均一致；archive_sha256 绑定当前普通CJP SHA-256。package-source-proof 的 archive/sha256 对应同一CJP，记录 fixed_commit `d7e9d1445f98021a798d223de97b97b45239de93`、source_tree `0121ec3815cef7971d325533fda66fdc57675d7a`、333个普通源成员及空differences。这里只核对既有证据的绑定，未重新证明源码内容。CJP只列目录：392个唯一成员（含目录），无绝对路径、`..`分量或反斜线；未解包。

旧supervisor：两份原件当前字节、size、0700模式及归档副本均通过。`vt-preparation-r3/artifact-receipt.json`（不属于本批payload）记录的 native_elf_sha256/bytes 与r3原件一致；该receipt不记录模式。`vt-preparation/artifact-receipt.json` 不存在，因此第一份旧supervisor未取得额外历史pin。本批保留当前固定旧产物，不证明它们来自某源码重建，也不涉及最新6a或新公平调度supervisor。

限制：未运行任何ELF/CJP、构建、VM、网络、子代理或认证材料读取；未写入解包产物。未重跑运行依赖解析或验证依赖在目标机可用。两个既有ELF说明文本列出 libcangjie-runtime.so、libboundscheck.so、libm.so.6、libc.so.6，这些依赖本批未携带。setup-receipt明确记录runtime未执行及既有xclip/后续QA等缺口；迁移一致性不关闭这些缺口。未独立重验主源码未变、第二批内容、Git历史真实性或外部签名。本报告不构成最终release、VT/Linux运行验收或actual VT修复验收。
