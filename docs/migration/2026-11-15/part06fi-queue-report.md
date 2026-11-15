# Round2 历史 custody 队列

已给出59份ELF witness完整精确map，并确定下一卷06f。queue为机器可执行清单，原payload未读取、未重hash。

| 范围 | gzip件数 | gzip字节 | metadata件数/字节 | 源总字节 |
|---|---:|---:|---:|---:|
| 06f：e124+A+B | 15 | 83,404,622 | 89/7,639,691 | 91,044,313 |
| 若复制所有三根direct metadata以便独立恢复 | 15 | 83,404,622 | 98/7,679,263 | 91,083,885 |

06f根目录为`validation/reviewed-e124-runtime-witnesses-20261114`（3份）、`accepted-unit-a-elf-witnesses-20261114`（6份）、`accepted-unit-b-elf-witnesses-20261114`（6份）。`next_volume.payload_root_ids`选择payload，`next_volume.metadata_files`给新增metadata精确路径、大小、模式、旧index SHA和行号。保守tar预算91,736,537字节，低于100MiB（104,857,600字节）；实际成包/远端限制仍由执行角色核准。

原13组“60 gzip”实际为58份ELF+两个同SHA的metadata gzip。原先单列的`ended-cache-counterexample-headroom-20261114`经`ELF_payload_map`证实另有1份ELF，已重分类；因此本清单为14个根、59个不同原ELF SHA，总gzip 326,757,793字节。06f后剩44份完整rows也已列出，不需重新索取路径。

## 排重证据

与part01–06e的9938条已交付manifest逐项对照：59份gzip路径/gzip SHA/原ELF SHA均无直接命中；再与part05独立核验所记录四份CPIO中实际file成员SHA比对，亦无命中。没有解开或读取CPIO大payload。

只读36份canonical archive manifest与99个archive-index，相关230条hash记录处于exclusions、bindings、local_runtime_witness_receipts和index_bindings；没有59份ELF/gzip的正面payload member绑定。R22/027 `member=excluded-generated-runtime`为排除标记，不能当成可恢复archive member。保管receipt中的gzip路径/hash也不表示gzip已在旧Git tar中。

三根metadata中9份已有exact旧archive member：`metadata_already_in_Git_archive`保留路径、SHA、canonical manifest/json pointer、raw-evidence.tar.gz及member；默认新增清单排除这些。所需progress/storage-map可按这些旧Git成员恢复。若执行者希望每卷可独立恢复，可有意再复制这些少量元数据，使用第二行预算，并在manifest明确标记原覆盖；不能算成新增独有payload。另有9组新metadata路径具有相同旧SHA；queue明确列出别名，路径标签仍保留before/after语义，执行者可按alias恢复以减少重复。

## 完整后续边界

`custody_roots`为全部14组给出既有index/progress、restore脚本、metadata摘要以及安全metadata相对路径清单；只允许根目录direct regular文件及map明确指向的elf-witness direct metadata，不递归其他raw/SDK。`payloads`为59件给出gzip路径/字节/SHA、原ELF路径/字节/SHA/模式、source_index/hash、map行和index.files行。现有stat大小与旧index/map字节一致、两处压缩SHA一致；真正payload hash/CRC/解压后ELF完整性须交独立角色。

`round1-cache-fix-headroom-20261114`的两个1,054,953字节`.json.gz`同SHA `2284f66e...`是e144 map引用的source_index metadata，已单列support，既非ELF也不能丢弃。

`task020-intermediates-store-20261114/packed-build-targets.tar.gz`另列：3,880,864字节、旧SHA `769d6469a2c4f4012b14f45d144bf54247035a63356811b108d649f86865b0aa`，map含124条actual build output/object member映射。尚未做exact旧archive/前包或可重取对账，不凭名称排除，不纳入06f。

本轮只metadata/index/progress/stat，无build、VM、网络、上传、子代理、原日志env扫描、凭据读取或禁区遍历。不声称全342项或全部迁移已完成。
