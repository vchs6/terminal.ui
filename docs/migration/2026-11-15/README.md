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

目前固定为7个逻辑交付组，第六组十五卷发布后已交付20个下载包。尚未覆盖的历史输入在第6组继续对账；第6组可能分卷，因此 **7个逻辑组不等于总共只有7个下载文件；实际总卷数尚未核定**。

| 组 | 内容 | 状态 |
|---|---|---|
| 1 | 源码、Git引用、未提交源码、当前交接 | 已交付1包 |
| 2 | C008原始runtime证据和截图 | 已交付1包 |
| 3 | 原公开ELF、测试CJP、旧native及来源 | 已交付1包 |
| 4 | 五份性能基准gzip ELF及custody | 已交付1包 |
| 5 | VM镜像与复现输入 | C008相关原件已交付1包；其余历史输入在第6组对账 |
| 6 | 尚未覆盖的独有历史成果和原始证据 | 已交付十五卷（历史gzip ELF、原路径小报告、目录账本及SDK输入）；其他目录继续逐文件对账 |
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

## 第六组第一卷：历史二进制原件（part06a）

- [下载第六组第一卷](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06a.tar.gz)（90,909,862 字节）
- [SHA256 校验文件](terminal-ui-migration-20261115-part06a.tar.gz.sha256)

SHA256：`77b360183bacc9b1f499b1a40e2ec68c9b051b11127a4b69bc74cf631098a451`。

本卷保存linux-final-capacity第一轮保管的20份原ELF的gzip文件及既有回执、恢复映射、来源记录和恢复工具：共71份原件，另附migration-part06a/manifest.json。每个gzip对应原始二进制字节，不通过重新构建替代；已有历史性能/功能结论和旧索引保持原样。此前仓库归档保留了大量日志与哈希引用，但相应ELF payload明确不在其交付范围。本卷补交这些原始字节，不重复运行旧测试或基准。

```bash
sha256sum -c terminal-ui-migration-20261115-part06a.tar.gz.sha256
tar -xzf terminal-ui-migration-20261115-part06a.tar.gz -C /第一批恢复目标目录
```

恢复后原gzip位于work/linux-final-capacity/gzip/；restore-map.json中的20行包含gzip和解压ELF的大小/哈希及原始路径。原恢复脚本保留旧/workspace/work前缀，使用前应在本地副本中映射新根目录并创建相应父目录，保留原映射不改写。也可以直接按映射流式读取gzip校验旧证据，无需立即解压全部原二进制。

本卷**不含round2的另外21份压缩ELF，也不代表第六组全部历史原件已迁移完成**。第六组继续按未覆盖原件分卷，实际下载文件总数尚未核定；本卷只验证迁移完整性，不构成新的Linux验收或性能测试结论。

[第六组第一卷独立核查报告](part06a-independent-report.md)与[机器可读记录](part06a-independent-findings.json)记录71原件、完整归档和20份gzip还原317,561,592字节原ELF的核验结果。

## 第六组第二、三卷：第二轮21份历史二进制（part06b / part06c）

| 卷 | 下载 | 大小 | 内容 |
|---|---|---|---|
| 06b | [下载第二卷](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06b.tar.gz) | 53,783,785 字节 | 前10份gzip和全部第二轮保管记录 |
| 06c | [下载第三卷](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06c.tar.gz) | 53,861,580 字节 | 其余11份gzip |

- [06b校验文件](terminal-ui-migration-20261115-part06b.tar.gz.sha256)：`05231d0eeaba8b9253ec876c8d4c22634585f5e421481dcaaf9eddd3e7949b31`。
- [06c校验文件](terminal-ui-migration-20261115-part06c.tar.gz.sha256)：`bc133b37fa46d1431f5a57ca304b9513184888ac760cf85114338c0adf2d65ca`。

校验后依次解压两卷到第一批恢复目标目录：

```bash
sha256sum -c terminal-ui-migration-20261115-part06b.tar.gz.sha256
sha256sum -c terminal-ui-migration-20261115-part06c.tar.gz.sha256
tar -xzf terminal-ui-migration-20261115-part06b.tar.gz -C /第一批恢复目标目录
tar -xzf terminal-ui-migration-20261115-part06c.tar.gz -C /第一批恢复目标目录
```

两卷合用恢复work/linux-final-capacity/round2/gzip/的21份原件。第二卷含75份payload及manifest，第三卷含11份payload及manifest。第二轮完整21件映射以restore-map-final.json和receipt-index-final.json为准；restore-map.json、receipt-index.json是保留的partial10历史快照，不应当作迁移缺失或覆写成新结论。原路径仍按/workspace/work前缀映射，使用原gzip按原ELF大小和SHA校验；没有重建或执行二进制。

06a、06b、06c三卷共交付两轮41份历史gzip原ELF及记录。其他目录的未覆盖原件仍需继续对账，**三卷通过不表示整个第六组收口，更不表示Linux最终验收通过**。

[06b独立核查报告](part06b-independent-report.md)、[06b机器记录](part06b-independent-findings.json)、[06c独立核查报告](part06c-independent-report.md)及[06c机器记录](part06c-independent-findings.json)验证两卷21件不重不漏，流式还原378,506,472字节，并保留partial10与final21各自原状态。

## 第六组第四、五卷：更早34份保管原件（part06d / part06e）

| 卷 | 下载 | 大小 | 校验 |
|---|---|---|---|
| 06d | [下载](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06d.tar.gz) | 81,275,980 字节 | [校验文件](terminal-ui-migration-20261115-part06d.tar.gz.sha256) |
| 06e | [下载](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06e.tar.gz) | 92,837,342 字节 | [校验文件](terminal-ui-migration-20261115-part06e.tar.gz.sha256) |

06d保存validation/input-fix-build-headroom-20261114的12份gzip及round1的4份，共75份payload和manifest；06e保存validation/ended-role-build-output-custody-20261115的18份gzip，共68份payload和manifest。旧index、progress、before/verified回执与恢复脚本原样保留；未重建或执行二进制。

```bash
sha256sum -c terminal-ui-migration-20261115-part06d.tar.gz.sha256
sha256sum -c terminal-ui-migration-20261115-part06e.tar.gz.sha256
tar -xzf terminal-ui-migration-20261115-part06d.tar.gz -C /第一批恢复目标目录
tar -xzf terminal-ui-migration-20261115-part06e.tar.gz -C /第一批恢复目标目录
```

原gzip位于三个保管目录各自的witness/下，逐原ELF路径、大小、SHA和模式见各自progress.json/index.json。原恢复工具仍含旧绝对路径，应在本地副本中映射/workspace/work前缀，保留原始索引。06e的source_indices为空，只保管捕获时的现存字节，不补称历史compiler/source验收。

[队列审计报告](part06de-queue-report.md)和[精确队列](part06de-queue-queue.json)记录与9795条已交付记录及canonical历史索引的对账范围。未发现34份gzip及原ELF哈希的已交付命中或历史payload恢复member；哈希引用本身不代表原字节已交付。

[06d独立报告](part06d-independent-report.md)、[06d机器记录](part06d-independent-findings.json)、[06e独立报告](part06e-independent-report.md)、[06e机器记录](part06e-independent-findings.json)及[只读审计脚本](part06de-audit-readonly.py)确认34gzip流式还原611,443,464字节，相关记录和归档全部匹配。脚本保留旧工作环境路径，跨机器复核须映射根目录。

第六组目前五卷共75份历史gzip原ELF，加第四批另5份，已交付80份逻辑原件。其他历史目录仍在对账，未据此声明第六组或Linux验收完成。

## 第六组第六至九卷：59份ELF保管原件（part06f / g / h / i）

| 卷 | ELF件数 | 下载 | 大小 | 校验 | 审核 |
|---|---|---|---|---|---|
| 06f | 15 | [下载](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06f.tar.gz) | 82,898,446 字节 | [校验文件](terminal-ui-migration-20261115-part06f.tar.gz.sha256) | [核查报告](part06f-independent-report.md) |
| 06g | 16 | [下载](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06g.tar.gz) | 89,460,006 字节 | [校验文件](terminal-ui-migration-20261115-part06g.tar.gz.sha256) | [核查报告](part06g-independent-report.md) |
| 06h | 16 | [下载](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06h.tar.gz) | 86,577,855 字节 | [校验文件](terminal-ui-migration-20261115-part06h.tar.gz.sha256) | [核查报告](part06h-independent-report.md) |
| 06i | 12 | [下载](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06i.tar.gz) | 64,817,235 字节 | [校验文件](terminal-ui-migration-20261115-part06i.tar.gz.sha256) | [核查报告](part06i-independent-report.md) |

四卷覆盖14个validation保管目录，原gzip、before/after/verified回执、progress/index及恢复脚本按原路径保存。各卷migration-part06*/manifest.json记录所有原件，elf_payloads严格区分59份ELF见证与其他元数据。06f/g/h/i分别113/154/137/159份payload，外加各自manifest。

本轮为方便独立恢复，有意随卷重复少量已有Git exact archive member的metadata，不把这些重复元数据算成新增ELF。[队列审计报告](part06fi-queue-report.md)和[精确队列](part06fi-queue-queue.json)说明全部59个原ELF SHA各异，未命中此前交付记录或四份CPIO实际成员，canonical历史索引中的相关引用均未提供正面payload恢复member。

```bash
sha256sum -c terminal-ui-migration-20261115-part06f.tar.gz.sha256
sha256sum -c terminal-ui-migration-20261115-part06g.tar.gz.sha256
sha256sum -c terminal-ui-migration-20261115-part06h.tar.gz.sha256
sha256sum -c terminal-ui-migration-20261115-part06i.tar.gz.sha256
tar -xzf terminal-ui-migration-20261115-part06f.tar.gz -C /第一批恢复目标目录
tar -xzf terminal-ui-migration-20261115-part06g.tar.gz -C /第一批恢复目标目录
tar -xzf terminal-ui-migration-20261115-part06h.tar.gz -C /第一批恢复目标目录
tar -xzf terminal-ui-migration-20261115-part06i.tar.gz -C /第一批恢复目标目录
```

旧/workspace/work前缀仍需在本地副本中映射，不覆写原历史索引。各卷完整机器核查记录为part06*-independent-findings.json。06g旧index的14条范围外fallback/cache引用未在本卷读取或补称已交付；06i两个历史source_index未枚举相应ELF digest，仅其原索引SHA及完整custody回执一致，见报告限制。四卷验证的是原始字节迁移，不重建程序，不补造历史compiler/source验收或更改Linux结论。

round1-cache-fix-headroom的两份同SHA metadata JSON.gz和另一个packed-build-targets归档仍在下一轮对账，不因目录名cache而默认排除。第六组九卷加第四批5份，累计移交139份逻辑ELF原件；第六组全部历史成果覆盖和第七组最终交接仍未收口。

## 第六组第十卷：两份库存元数据见证（part06j）

- [下载06j](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06j.tar.gz)（2,103,699 字节）
- [SHA256校验文件](terminal-ui-migration-20261115-part06j.tar.gz.sha256)

SHA256：`08873ae2298cd363dfc44d6008d0941cb578b3a75088bfca2f5f0e06d7260df2`。

本卷为元数据，不新增ELF：两个同SHA的old-roots-noncandidates-before/after.json.gz保留各自原路径，每份解码为30,303条目录/文件保管元数据；另带原index、result、combined-summary三份上下文，后者有意与06i重复以方便独立解释。只保存path/stat/type/sha256/symlink-target字段，没有所列文件的内容。

```bash
sha256sum -c terminal-ui-migration-20261115-part06j.tar.gz.sha256
tar -xzf terminal-ui-migration-20261115-part06j.tar.gz -C /第一批恢复目标目录
```

恢复到work/validation/round1-cache-fix-headroom-20261114/。原index与历史状态不改。[独立报告](part06j-independent-report.md)、[机器记录](part06j-independent-findings.json)及[只读审计脚本](part06j-audit-readonly.py)核验5原件和6个tar成员。环境恢复后于2026-11-20重新核对全部源文件并重建派生压缩包，其SHA256及Git blob与此前独立验证的冻结包完全相同；[恢复核对记录](part06j-restored-verification-20261120.json)据此复用原独立结果，不重跑无变化范围。

### 已在Git内的packed124不重复下载

[小缺口对账报告](part06j-closure-report.md)与[精确恢复映射](part06j-closure-queue.json)确认旧packed-build-targets.tar.gz实际字节已在Git历史：shard为docs/reviews/R22/.archive-v1/part-000006.tar.gz，member为docs/reviews/R22/020/intermediates/packed-build-targets.tar.gz。可从第一批恢复的Git仓库提取：

```bash
tar -xOf docs/reviews/R22/.archive-v1/part-000006.tar.gz docs/reviews/R22/020/intermediates/packed-build-targets.tar.gz > packed-build-targets.tar.gz
```

提取后应为3,880,864字节，SHA256为769d6469a2c4f4012b14f45d144bf54247035a63356811b108d649f86865b0aa。同一shard中的packed-build-targets-map.json、restore.py、pack.py和phase2 receipts也有exact member绑定，见queue.support_old_member_bindings（位于packed_target下）。67个实际对象已按SHA验证，覆盖124条逻辑映射；不因hash引用就认定原件已迁移。

对账另确认前80份与新增59份decoded ELF SHA无交集，共139个不同原ELF身份。有限validation保管根未发现额外gzip缺口；这不代表SDK、所有raw/log或整工作目录已经完整迁移，第六组全局覆盖及第七组最终交接仍待收口。

2026-11-20恢复环境后，临时宿主RAM缓存已从已发布的固定GitHub提交重新取回，并逐对象验证大小、SHA256和Git blob SHA1；[缓存恢复记录](git-cache-restoration-20261120.json)不改变原件或历史验证结论。

## 第六组第十一、十二卷：目录账本阶段与原路径报告（part06k / part06l）

| 卷 | 下载 | 大小 | 校验 | 审核 |
|---|---|---|---|---|
| 06k | [下载](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06k.tar.gz) | 48,092,495 字节 | [校验文件](terminal-ui-migration-20261115-part06k.tar.gz.sha256) | [独立报告](part06k-independent-report.md) |
| 06l | [下载](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06l.tar.gz) | 4,223,266 字节 | [校验文件](terminal-ui-migration-20261115-part06l.tar.gz.sha256) | [独立报告](part06l-independent-report.md) |

### 06k：目录账本阶段包

本包保留2026-11-20恢复的全局目录metadata快照，包含完整SQL和六份JSONL压缩导出、审计脚本、报告与计数、旧2026-11-15历史小报告。19份payload加控制清单共20个tar成员，均为metadata/审计材料。**目录账本不是其列举的全部原文件备份，也不是第七组最终交接。**

解压后在migration-catalog-20261120/下：compressed-ledger/catalog.sql.gz可用SQLite导入，六份JSONL分别给未闭环、lineage、逻辑custody及SHA义务等队列。所列/workspace/work路径需映射到本地迁移根目录；不改变原记录。账本记录1,077,804节点、28,008,244,375逻辑字节，SQLite quick_check、SQL重导入schema/逐表计数已通过，metadata未采集所列文件内容或实际环境值。[阶段报告](catalog-stage-20261120-report.md)与[摘要](catalog-stage-20261120-summary.json)说明约20.9GB未证明类别不能当成全是独有成果，更不能凭cache/target名称排除。

```bash
sha256sum -c terminal-ui-migration-20261115-part06k.tar.gz.sha256
tar -xzf terminal-ui-migration-20261115-part06k.tar.gz -C /新的空暂存目录
```

### 06l：7,801个原路径小报告与测试原件

本包保存已逐内容SHA与发布内容检查通过的7,801个原路径文件，共31,227,880原始字节。包含863项未被现有恢复证据覆盖的不同内容，另6,938路径与已交付、旧exact member或本批内其他文件同字节，**有意重复保留以便直接按原路径恢复，不计作6,938份新增独有数据**。另8份审核上下文和1份控制清单，总7,810个tar成员。全部1,666个不同内容SHA都通过发布审核，暂缓/待复核为0。[内容审查报告](report-candidates-20261120-report.md)与[分类摘要](report-candidates-20261120-summary.json)保留重复恢复依据的范围及限制。

本包work/树与先前恢复文件可能重名，先解压到新的空暂存目录，再按需要合入已有工作目录并保留本地修改。审核账本在migration-reports-20261120/audit/，package-manifest.json逐文件保存路径/字节/模式/SHA与分类。并未执行这些源码、脚本或旧测试，也不补称原Linux验收结论。

```bash
sha256sum -c terminal-ui-migration-20261115-part06l.tar.gz.sha256
tar -xzf terminal-ui-migration-20261115-part06l.tar.gz -C /新的空暂存目录
```

两卷独立审核只覆盖各自冻结范围。SDK/依赖输入与剩余大原件的覆盖证明、旧exact member对当前原件SHA联核、第七组最终恢复与交接仍在推进，不能据目录数量或此小文件集合声明全部迁移完成。

## 第六组第十三至十五卷：离线SDK/stdx输入（part06m1 / m2 / m3）

**三卷必须一起使用。** 它们保存原发行输入，不传输约854,845,304字节的重复展开树。SDK是Linux x64的1.2.0，stdx是Linux x64的1.2.0-beta.02.1，不表示其他平台已支持。

| 卷 | 下载 | 大小 | 校验 | 审核 |
|---|---|---|---|---|
| 06m1 | [下载](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06m1.tar.gz) | 83,104,663 字节 | [校验文件](terminal-ui-migration-20261115-part06m1.tar.gz.sha256) | [独立核验](part06m1-independent-report.md) |
| 06m2 | [下载](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06m2.tar.gz) | 83,239,360 字节 | [校验文件](terminal-ui-migration-20261115-part06m2.tar.gz.sha256) | [独立核验](part06m2-independent-report.md) |
| 06m3 | [下载](https://github.com/vchs6/terminal.ui/raw/refs/heads/main/docs/migration/2026-11-15/terminal-ui-migration-20261115-part06m3.tar.gz) | 96,035,644 字节 | [校验文件](terminal-ui-migration-20261115-part06m3.tar.gz.sha256) | [独立核验](part06m3-independent-report.md) |

m1/m2各含SDK tar的连续84,000,000字节，m3含余33,602,997字节、原stdx ZIP、494字节历史回执、固定input-manifest、已修订并独立实测的restore.sh/verify.sh与审查记录。每卷outer manifest及三卷实际分片均经完整字节核验；按001/002/003拼接得到原SDK 201,602,997字节，无重叠缺口。

先在一个新的空暂存目录解压三卷，再进入sdk-inputs-20261120，按固定顺序拼接并验原输入：

```bash
sha256sum -c terminal-ui-migration-20261115-part06m1.tar.gz.sha256
sha256sum -c terminal-ui-migration-20261115-part06m2.tar.gz.sha256
sha256sum -c terminal-ui-migration-20261115-part06m3.tar.gz.sha256
tar -xzf terminal-ui-migration-20261115-part06m1.tar.gz -C /新的空暂存目录
tar -xzf terminal-ui-migration-20261115-part06m2.tar.gz -C /新的空暂存目录
tar -xzf terminal-ui-migration-20261115-part06m3.tar.gz -C /新的空暂存目录
cd /新的空暂存目录/sdk-inputs-20261120
cat parts/cangjie-sdk-linux-x64-1.2.0.tar.gz.001 parts/cangjie-sdk-linux-x64-1.2.0.tar.gz.002 parts/cangjie-sdk-linux-x64-1.2.0.tar.gz.003 > cangjie-sdk-linux-x64-1.2.0.tar.gz
sha256sum -c SHA256SUMS.inputs
```

[三个必需输入清单](sdk-input-manifest.json)：SDK tar SHA256为8c5fd944cd9cc51ee63d4a240e3ecc4f540345dae1468e8b47c927ecf2ba998f；stdx ZIP为0d35811d84a770315c6fa2d1090a10568b3f7c763a1d1d54a1433b324f76afc0；原回执为a8c7c4e5750cf9f5f2e381a24e3e8f47496a56cc8971318d634bd152f0830dec。三者共264,993,197字节。

接收方核验原输入后，在可信Linux文件系统选择一个尚不存在的新SDK根。该根与已恢复的项目工作根分开，以免覆盖已有工作目录：

```bash
bash ./restore.sh /新的独立SDK根目录 ./cangjie-sdk-linux-x64-1.2.0.tar.gz ./cangjie-stdx-linux-x64-1.2.0-beta.02.1.zip ./stdx-install.original.json
bash ./verify.sh /新的独立SDK根目录
```

恢复脚本只解包、恢复权限与配置链接；原494字节回执按0600独立保存为migration-evidence/stdx/install.original.json，另生成指向新根的active回执。SDK 778文件和22链接、stdx 370发行文件及兼容链接在独立RAM新根已实际还原逐项核验。SDK envsetup.sh和编译器没有在本轮自动执行，应用/工程也未编译。后续开发入口可指向新SDK根的validation/sdk/cangjie/envsetup.sh和linux-build-recon/stdx-env；按项目依赖文档配置CANGJIE_STDX_PATH。

[独立修订审核](sdk-revision-review-report.md)和[机器记录](sdk-revision-review-findings.json)保留正常恢复、坏输入、旧路径active回执、回执mode及已有目标拒绝的实际结果。恢复记录原现场绝对路径属历史证据，不冒充新机配置。

官方下载本轮未完成整包重取验证，因此提供现场固定原档作离线输入。三卷可取得并通过接收方SHA验收后，SDK/stdx展开树可由这些原档恢复，不必再逐目录复制。此范围不包括仓颉包源缓存、负控修改、native/system依赖或全部编译闭包；整体历史成果与第七组交接仍未收口。
