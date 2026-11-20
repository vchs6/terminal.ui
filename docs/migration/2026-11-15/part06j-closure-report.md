# 小缺口收尾：06j可直接执行

06j仅需保存两个原路径的metadata gzip（每份1,054,953字节，同SHA），加三份既有小保管元数据；共5件、2,121,229源字节。`queue.json.files`是精确路径/大小/模式/SHA列表。两个gzip路径均原样保存，有意复制相同字节，不引入alias恢复步骤；三份context元数据在06i已交付，本卷有意复制以便独立解释，不算新增独有数据。

| 原路径（相对validation/round1-cache-fix-headroom-20261114） | 字节 | 说明 |
|---|---:|---|
| old-roots-noncandidates-before.json.gz | 1,054,953 | 旧index.files精确绑定 |
| old-roots-noncandidates-after.json.gz | 1,054,953 | 与before完全同SHA |
| index.json | 9,482 | 原sealed index，不修改 |
| old-roots-result.json | 449 | 30,303条noncandidate不变receipt |
| combined-summary.json | 1,392 | 原round1保管/清理边界receipt |

两个gzip SHA均为`2284f66e8075033bed4a583627db22dc33d616534bda621b4012cbdcaa43da9e`；已对实际压缩bytes计算并匹配旧index，gzip CRC/EOF通过。每份解码为10,934,020字节JSON、30,303条目录/文件保管元数据记录；只含path、stat、type、sha256和符号链接target字段，没有文件内容/env/token/password字段。只检查结构和键，不打印记录内容；未读取记录所指向的文件。它们在R24/C bindings838/839及exclusions368/369明确标为未published/repacked；与全部10501交付manifest记录比对亦无payload命中。

原index SHA为`aa25c43f3aa46140c35fc142de8f2ee190c5d10c1ef720956cdd6b6885656bf8`，9,482字节；gzip各自旧index行号在queue中。已有e144 source_index引用after gzip，保留两历史路径可直接满足原引用。

## packed124已覆盖，绝不重传

`task020-intermediates-store-20261114/packed-build-targets.tar.gz`（3,880,864字节；SHA `769d6469a2c4f4012b14f45d144bf54247035a63356811b108d649f86865b0aa`）已存在旧Git archive-v1：

- manifest：`docs/reviews/R22/.archive-v1/manifest.jsonl.gz`第396行。
- shard：`docs/reviews/R22/.archive-v1/part-000006.tar.gz`。
- 实际member：`docs/reviews/R22/020/intermediates/packed-build-targets.tar.gz`。

已只读流式访问这个实际旧member，恰好1个regular成员，压缩字节/长度/SHA与源packed tar一致；不只依靠hash引用。恢复时从part01保存的Git历史取该shard，再按member取出原packed tar；按queue给出的同shard map/restore.py成员恢复原124逻辑路径。map、restore脚本、pack脚本和phase2 receipts的exact旧member/SHA均已列出，无需重传。

packed tar自身已流式核验gzip完整性及67个regular对象：名称全为安全`objects/<SHA256>`，无重复、绝对/父级/反斜线名称、链接或特殊文件；每个实际对象内容SHA等于对象名且匹配map。67个对象共36,785,760字节，覆盖全部124条映射、64,823,224逻辑字节；没有缺失或额外对象。67对象清单及124条原路径→member/字节/SHA/模式映射都在queue中。本轮未落盘解包或执行payload。

## 139份decoded ELF身份补核

直接读取前80条logical decoded ELF SHA：c008-capacity5、linux-final-capacity20、round2 final21、先前queue34，计80个唯一值；与新59条decoded SHA（59个唯一值）交集为0，合计139个不同decoded ELF身份。此项比对原ELF SHA，不拿gzip封装SHA或tar manifest成员SHA代替；未重跑已独立通过的59份payload/CRC。

## 有限validation custody核对

只枚举有index的保管根及task020根、限定witness/elf-witness/gzip/round1/round2元数据子目录，读取37份index和21份progress：95个不同gzip引用均可对应已知集合；有限实体枚举96条gzip路径恰为93份validation ELF witness、上述2份JSON gzip、1份已覆盖packed tar。没有发现额外物理gzip路径或额外逻辑gzip保管引用。其他记录是compiler删除审计、no-op、clone disposal或既有artifact引用，不能把删除审计hash当待迁移原件。

这项结论仅覆盖queue列出的有限metadata roots；没有扫描SDK、raw/log、依赖/build/project目录、凭据或禁区。不得据此宣称第6组全部历史日志或342项已完成。
