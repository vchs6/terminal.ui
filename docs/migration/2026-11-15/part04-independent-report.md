# 第四批迁移独立核查

结论：PASS。

- Git blob `ae4c364226605a6746122fb8301ce588efadc053` 流式读取：28189699 bytes，SHA-256 `adbfa1516c9c41caabdb8055aa1ae65809ecaebc79bd8e9adc01c8803dfc316c`；与 delivery.json 及指定值一致。
- 23 个原件逐一核对普通文件类型、完整字节数、SHA-256、权限；全部与 manifest 一致。
- tar 有 24 个逻辑普通文件（23 payload + 1 manifest），成员路径安全、无重复、无链接/稀疏文件，嵌入 manifest 与外部原件逐字节一致。全部成员完整字节散列、size、mode、uid/gid、uname/gname、mtime 与原件一致。
- 物理 tar 另含 24 个 PAX 扩展元数据头，仅含 mtime；已核头校验和、PAX 记录边界、终止零块与后续全零填充。PAX 是元数据记录，不是额外逻辑 payload。
- 五个 gzip 从归档成员流式解压，gzip 完整性检查通过；原始 ELF magic、size、SHA-256 与 restore-map.rows 的原始及 verified_decompressed 字段一致。未运行 ELF。
- receipt-index 的 5 个 archives 映射及 14 个 files 映射均与 restore-map/manifest 一致。
- 未生成归档副本、ELF 或临时仓库，未构建、运行 VM、访问网络、启动子代理或读取认证材料/环境值。仅写本报告与 JSON。

本结论仅证明当前原字节迁移，未改写历史 performance/provenance，不等同最终 Linux 验收。

问题：无
