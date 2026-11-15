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

## 第四批：五份性能基准原 ELF 的压缩原件

- [下载第四批](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part04.tar.gz)（28,189,699 字节）
- [SHA256 校验文件](terminal-ui-migration-20261115-part04.tar.gz.sha256)

SHA256：`adbfa1516c9c41caabdb8055aa1ae65809ecaebc79bd8e9adc01c8803dfc316c`。

本批包含 c008-capacity 保存的五份既有性能基准 ELF 的 gzip 原件，以及原恢复映射、逐项 custody 回执和相关记录。23份原件以原路径/字节/权限保存，另有 migration-part04/manifest.json；不重新构建二进制，不改写原性能或来源结论。

```bash
sha256sum -c terminal-ui-migration-20261115-part04.tar.gz.sha256
tar -xzf terminal-ui-migration-20261115-part04.tar.gz -C /第一批恢复目标目录
```

原压缩件恢复到 work/c008-capacity/gzip/01.gz 至05.gz。原 restore-map.json 为每份 gzip 记录原始 ELF 的路径、大小、模式、SHA256 与 gzip SHA256。无需立即解压全部二进制；检查旧证据时可按映射流式读取。若要恢复可执行文件，先在本地副本中映射旧 /workspace/work 前缀并创建父目录，再按原大小/哈希核验并恢复权限；保留原映射不改写。原 restore.py 保留旧绝对路径，不能在新机器不经映射就直接运行。

本批并不包含其他capacity目录保管的全部历史ELF，也不表示Linux最终验收通过。

## 总体交付安排与批数边界

目前固定为7个逻辑交付组，第五批发布后已交付5个下载包。尚未覆盖的历史输入在第6组继续对账；第6组可能分卷，因此 **7个逻辑组不等于总共只有7个下载文件；实际总卷数尚未核定**。

| 组 | 内容 | 状态 |
|---|---|---|
| 1 | 源码、Git引用、未提交源码、当前交接 | 已交付1包 |
| 2 | C008原始runtime证据和截图 | 已交付1包 |
| 3 | 原公开ELF、测试CJP、旧native及来源 | 已交付1包 |
| 4 | 五份性能基准gzip ELF及custody | 已交付1包 |
| 5 | VM镜像与复现输入 | C008相关原件已交付1包；其余历史输入在第6组对账 |
| 6 | 尚未覆盖的独有历史成果和原始证据 | 待逐文件对账，可能分卷 |
| 7 | 最终覆盖索引、依赖pins、恢复说明和交接 | 待收口 |

[第四组发布前的盘点报告](remaining-plan-report.md)和[342项范围清单](remaining-plan.json)说明现有证据与未决项。旧baseline的docs/reviews已含180个历史tar.gz，合计111,861,126压缩字节，随第一批要求的Git clone恢复；不能重复计算为待打包原件，也不能仅因存在归档就认定原目录全部覆盖。最终总卷数需按路径+SHA+归档member/custody恢复映射完成去重后确定。

[第四批独立核查报告](part04-independent-report.md)与[机器可读记录](part04-independent-findings.json)确认23原件、完整归档字节和五份解压ELF的哈希。云端为节省空间以Git blob保留本批压缩包，工作树标为skip-worktree；远端和新clone仍包含完整文件，原gzip原件未删除。

## 第五批：C008 VM镜像、内核与复现工具

- [下载第五批](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part05.tar.gz)（90,995,785 字节）
- [SHA256 校验文件](terminal-ui-migration-20261115-part05.tar.gz.sha256)

SHA256：`82658e9aa729d6142cbaf79a41a1a19812efbc69907441f2e427e67ee7a09e0a`。

本批包含48份原件：C008三份历史initramfs（最初启动、R3启动、一次控制诊断），原始基础initramfs、原测试内核、QEMU/宿主工具的原下载deb包、对应官方获取元数据，以及linux-console-hosts和linux-vt-product-probe的复现probes与报告。没有重新打包VM镜像或运行其中程序。三份C008镜像属于既有未完成VT验收的历史阶段，**不包含最新6a399c88公平调度修复，不代表真实VT或Linux已通过**。

```bash
sha256sum -c terminal-ui-migration-20261115-part05.tar.gz.sha256
tar -xzf terminal-ui-migration-20261115-part05.tar.gz -C /第一批恢复目标目录
```

原件恢复在work/下对应的linux-final-host-actual、linux-console-hosts和linux-vt-product-probe路径；migration-part05/manifest.json记录逐文件字节、权限与SHA256。第二批已有启动/诊断命令和结果；第一批保留operator和测试契约；第三批保留原公开应用与旧supervisor二进制。本批提供原安装包，未重复装入可由这些deb重建的完整hosts解包树。

复现前应映射旧/workspace/work前缀，并在相容的Linux x86_64环境中按已归档probes/获取记录准备QEMU及其库。不得将initramfs直接解到宿主根目录，也不应把导入证据当作应自动启动的程序。工具包仅证明原下载字节被保存，原获取报告未证明InRelease签名已经验证，本次也未新增签名验证或在新机器重跑VM。SDK/stdx及其他历史复现输入仍按第6、7组覆盖清单补齐，不能据此声称所有环境依赖已完整迁移。

本批压缩包和Git blob在云端专用宿主共享内存中暂存，工作树标记skip-worktree；原始镜像与安装包仍在原目录。访问该暂存Git对象需宿主执行命名空间，新clone直接从GitHub取得完整文件，不依赖此临时路径。

[第五批独立核查报告](part05-independent-report.md)、[机器可读记录](part05-independent-findings.json)与[只读审计脚本](part05-audit-readonly.py)记录48原件、完整归档、四个CPIO内部清单与历史绑定核验。审计脚本保留原工作环境路径，跨机器运行需按迁移根映射，不作为产品运行依赖。
