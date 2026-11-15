# Linux 工作成果分批迁移

这是执行型交付修正：聊天中的环境文件链接无法下载，改由 GitHub 仓库提供同一份已校验压缩包；不修改产品或迁移包内容。

- [下载第一批源码与交接包](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part01.tar.gz)（12,961,852 字节）
- [SHA256 校验文件](terminal-ui-migration-20261115-part01.tar.gz.sha256)

SHA256：`e3d7aea881db2ae3f7afc8fe7a8dce71f379777b2a25635914be96bd02113b0a`。

包含本地分支/工作树固定提交、独立成果仓库的补充 Git 对象、315 份未提交源码和测试文件，以及最新工具、审核与交接记录。解压后阅读包内 README.md 和 HANDOFF.md，再运行：

```bash
python3 restore.py /你的路径/新工作目录
```

目标目录必须尚不存在，恢复需要 Git、Python 3 及 GitHub 网络访问。恢复固定工作快照为 `a5aed68544d7681a522400d2f061e5cf64532ee4`，不是发布版本。包内独立核查记录了 Git bundle 解包、对象完整性和归档文件校验；尚未声称在新电脑完成构建。

**这不是全部原始证据备份。** 原始终端日志、截图、大型二进制及工具链仍待后续分批交付；旧环境原件继续保留。

## 第二批：原始跨终端测试证据

- [下载第二批](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part02.tar.gz)（10,096,232 字节）
- [SHA256 校验文件](terminal-ui-migration-20261115-part02.tar.gz.sha256)

SHA256：`33f2864cb281a1b1fae5dea6b12f922ebe3b74c19365366ecc09471726eab6ae`。

本批包含实际 C008 runtime 目录的 7,404 份常规原件（原件共 30,849,827 字节），其中 737 张原始 PNG；覆盖 XTerm、VTE、tmux、screen、SSH 已执行记录和 VT 已执行的启动/诊断记录。失败尝试按原样保留，**不代表 VT 或 Linux 最终验收通过**。

压缩包根目录为 `work/` 和 `migration-part02/`。校验后，解压到第一批 restore.py 创建的迁移根目录（该目录内已有 work/）：

```bash
sha256sum -c terminal-ui-migration-20261115-part02.tar.gz.sha256
tar -xzf terminal-ui-migration-20261115-part02.tar.gz -C /第一批恢复目标目录
```

`migration-part02/manifest.json` 记录每个原件的路径、字节、模式和 SHA256；`omissions.json` 明确列出本批排除项。原有 gzip 原件及恢复映射按原字节保留；第一批已含的重复元数据在本批仍是相同原件。旧证据中的 `/workspace/work` 路径需映射到迁移根目录的 work/，不改写原始索引。

本批排除 SSH 身份目录（仅保留确认服务已停止的 cleanup 记录）、进程通信 FIFO、3 份 VM cpio 镜像和 2 个 native supervisor ELF。镜像、原二进制及其他历史证据仍待后续批次，认证材料不进入交付。

[第二批独立完整性核查报告](part02-independent-report.md)记录逐原件与归档验证结果；机器可读结果见[核查记录](part02-independent-findings.json)。

## 第三批：原始二进制、测试 CJP 与来源记录

- [下载第三批](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part03.tar.gz)（12,190,296 字节）
- [SHA256 校验文件](terminal-ui-migration-20261115-part03.tar.gz.sha256)

SHA256：`815499a90ce9cd5d56383c30fa2fe9c8a97e77a7caf2fca775d5883414530c0f`。

本批原样保存两份公开示例可执行文件（composition、theme_showcase）、用于这次测试的普通源码 CJP、两份历史 VT supervisor 可执行文件，以及对应构建和来源记录。没有重新构建原件。公开示例与 CJP 对照已有固定历史哈希，VT supervisor 是旧执行阶段保留件，**不是最新公平调度修复生成物，也不代表真实 VT 验证已经通过**。本批 CJP 不是已完成最终正式交付验收的发布包。

与第二批相同，校验后解压到第一批恢复目标目录：

```bash
sha256sum -c terminal-ui-migration-20261115-part03.tar.gz.sha256
tar -xzf terminal-ui-migration-20261115-part03.tar.gz -C /第一批恢复目标目录
```

`migration-part03/manifest.json` 记录12份原件的路径、字节、模式与哈希。`restore-map.json` 记录公开示例另外两份字节相同的 canonical 副本位置；为减少体积，不重复装入两份19MB副本。需要重现原目录布局时，按映射从已恢复的主 ELF 复制到对应 examples/.../target/release/bin/main，并保留权限。

本批未包含 SDK、stdx 动态库或完整运行闭包，恢复后二进制能否运行仍取决于本机 Linux 架构及相应运行库；本批只证明原二进制字节已迁移。VM 镜像、历史性能基准原二进制与其他历史证据仍待后续批次。

[第三批独立完整性报告](part03-independent-report.md)及[机器可读核查记录](part03-independent-findings.json)记录原件与归档验证、历史来源证据边界。
