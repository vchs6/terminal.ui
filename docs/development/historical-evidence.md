# 历史审查与迁移证据

清理前的固定 Git 提交为 `61e25f009f8f26c991c3f2ba758987db83bedc4a`。该版本中的审查报告、原始数据、目录索引和迁移卷可按需查阅。

- [历史轮次索引](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/README.md)
- [归档 catalog](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/archive-v1/catalog.json)和[归档操作说明](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/scripts/review-archive/README.md)
- [历史迁移说明及完整卷索引](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/migration/2026-11-15/README.md)

Markdown 引用优先定位固定版本中的实际 Git 文件。归档成员须按对应轮次的 manifest 和恢复工具查找。若已从保留祖先的部分克隆取得项目，可用 `git show 61e25f009f8f26c991c3f2ba758987db83bedc4a:<仓库相对路径>` 读取具体 Git 文件，缺少的历史 blob 由远端按需提供。日常开发使用[当前交接](continue-linux.md)和[本地夹具](../../tests/fixtures/)。
