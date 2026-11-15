# 第五组迁移独立审核

结论：**通过本次字节保存及有界归档安全核验；未发现阻断问题。** 本审核仅只读、哈希和流式列成员，没有解包至磁盘、执行VM/ELF/deb脚本、构建、联网或上传。

- 原件48/48的普通文件类型、权限、大小、SHA-256与manifest完全一致。
- 外层tar恰有49个普通文件：48个原件及`migration-part05/manifest.json`；无缺失、多余、重复、绝对/越界路径或链接。49个成员的uid/gid为1000/1000、owner/group为agent/agent。原件权限保留；内嵌manifest为0600，内容与本地manifest逐字节一致。
- 全归档90,995,785 bytes，SHA-256 `82658e9aa729d6142cbaf79a41a1a19812efbc69907441f2e427e67ee7a09e0a`，重算Git blob `1a3ade1573422fd07af5810e19a6d55c17019bf1`，均与delivery一致。本子审核不证明Git对象/远端持久性。

四个gzip/newc二级镜像均完整读到TRAILER并验证gzip，未见非零尾随解压数据。旧readiness镜像17成员（5目录、3文件、9符号链接）；三个C008镜像各73成员（19目录、41文件、13符号链接）。完整成员列表、文件hash、链接目标保存在findings。未见重复、绝对/越界成员名、宿主认证目录、`.ssh`、`.env`、`.git`等路径或PEM私钥标记。BusyBox链接均指向guest内`busybox`；loader链接`../../lib64/ld-linux-x86-64.so.2`留在guest根内。镜像内没有设备节点；guest链接没有被误当作外层tar违规。本检查不声称完成任意二进制或嵌套官方deb内容的全面秘密扫描。

| C008镜像 | 历史SHA-256绑定 |
| --- | --- |
| `vt-control-diagnostic-once/diagnostic.cpio.gz` | `1a70c540d44a3d0653a2d275eec18776908565675776077ebc14caf470c01cc0`；diagnostic-record的initrd_sha256及diagnostic-index一致 |
| `vt-preparation/final-public.cpio.gz` | `1c7a31379fe434ab92a80ea232993e9372c961d8787705c9d003570cdad534eb`；r3 allocation-plan及preserved-old-artifacts的旧制品记录一致 |
| `vt-preparation-r3/final-public-r3.cpio.gz` | `6272e760737aeb42ea207e938e8f1b8e79e4ebccfe6734e4bd91697c250a309c`；r3 artifact-receipt的initrd_sha256一致 |

以上均是已有实际记录，不是新造历史pin；记录路径及本次记录文件hash见findings。历史记录文件自身不在此48原件范围中，依赖原工作区/其他迁移组保存。

`diagnostic-record.json`的qemu_argv中`-kernel`明确指向`/workspace/work/linux-console-hosts/packages/linux`；原件及迁移成员SHA-256均为`2b2358b37674d2505350528875bb17afae2a36522a9e8a9417eaca65a7da0e08`，也匹配保留的installer-SHA256SUMS。17个官方deb均匹配保留Packages.xz的大小/SHA；Packages.xz匹配保留InRelease的SHA-256/大小条目。这只核对保存的获取记录与字节：**本次未验证OpenPGP签名**，原linux-console-hosts报告也明确当时无gpgv、仅保留InRelease而不声称验签。

这批是旧诊断镜像和工具，不证明最新fairness6a修复，不新增VT/Linux产品通过结论。审核没有扩大到全SDK、历史全链或运行复验。
