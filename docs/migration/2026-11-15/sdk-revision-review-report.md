# SDK/stdx 历史回执修订再审

**通过，原 R1 回执保管问题闭环。** 结论绑定输入清单 SHA-256 `1075caa430fd969d59f4e149ba38c2cafdb6c6a985220cdc2f8e3fde3c4dd6b4` 及本次复算的脚本 SHA。**原 R2 交付条件仍未满足**。源端有两份原归档，合计 264,992,703 B，尚缺接收端取得并验过两包的证据。官方地址当前可用性未经联网核实。固定清单（原路径：`/workspace/work/migration-sdk-proof-revision/input-manifest.json`） · 本轮摘要与实测结果（原路径：`/workspace/work/migration-sdk-proof-review/revision-review/findings.json`）

清单将 SDK tar、stdx ZIP 及 494 B 原回执列为三个必需输入，合计 264,993,197 B。已逐一复核长度和 SHA，再将随附回执与旧安装树的原件逐字节比较。此次另行复核了交付记录内八项文件 SHA，结论取自固定脚本、输入实物与独立运行。发行内容未变，上轮 SDK 778 文件、22 链接和 stdx 370 发行文件的逐成员结果仍适用。前轮成员审核（原路径：`/workspace/work/migration-sdk-proof-review/report.md`）

## 一次实际恢复

在专用 RAM 新根运行固定 `restore.sh`，随后运行固定 `verify.sh`，均退出 0。独立检查确认：

- `migration-evidence/stdx/install.original.json` 保留原安装绝对路径，原样 494 B、模式 `0600`、SHA-256 `a8c7c4e5750cf9f5f2e381a24e3e8f47496a56cc8971318d634bd152f0830dec`。
- 新 stdx 安装目录的 `install.json` 是另一 inode 上的 `0600` 常规文件。独立从原 JSON 仅替换 `installation` 并重编码，与新文件逐字节相等。本次新根含空格，新回执为 569 B，其 SHA 只适用于此次路径。
- `linux-build-recon/stdx-env/linux_x86_64_llvm` 的链接文本及实际解析结果都指向新根的 stdx 版本目录。两回执和链接均使用预期路径。复制与迁址逻辑（原路径：`/workspace/work/migration-sdk-proof-revision/restore.sh:44`） · 交付验收逻辑（原路径：`/workspace/work/migration-sdk-proof-revision/verify.sh:64`）

## 写入边界与失败路径

三个输入的 SHA 检查全部先于写入。分别替换 SDK、stdx、回执为坏输入时，三次均退出 1，目标和同级临时目录均未创建。以正确输入测试含隐藏标记的非空目录、指向该目录的普通符号链接，以及已成功恢复的新根，三次均拒绝，原数据保留。修订脚本在目标父目录内创建暂存目录，完成后才通过 GNU `mv -T` 发布。接收端应使用稳定输入、可信可写父目录及其下全新、规范的绝对目标路径。若使用已有空目录，成功发布会替换该空目录自身的 inode 和权限。输入与目标检查（原路径：`/workspace/work/migration-sdk-proof-revision/restore.sh:17`） · 发布（原路径：`/workspace/work/migration-sdk-proof-revision/restore.sh:68`）

在试验副本上把证据回执权限改为 `0644`，以及把活动回执换成旧路径，各自触发验收失败。历史回执原件、源归档及项目源码保持原样。此次未执行编译器、环境初始化脚本或应用。结构化负例记录（原路径：`/workspace/work/migration-sdk-proof-review/revision-review/findings.json`）

接收方在交付目录运行以下两条命令，将 `/absolute/new-project-root` 替换为实际新根。验收通过后，SDK、stdx 和原始回执这三项的本机恢复才有接收端实证。

```bash
bash ./restore.sh /absolute/new-project-root \
  ./cangjie-sdk-linux-x64-1.2.0.tar.gz \
  ./cangjie-stdx-linux-x64-1.2.0-beta.02.1.zip \
  ./stdx-install.original.json
bash ./verify.sh /absolute/new-project-root
```

原样独立审查记录随06m3的independent-review目录交付；本页只将旧环境绝对路径链接显示为原路径文字。
