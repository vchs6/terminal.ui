# Linux 工作成果迁移：第一批

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
