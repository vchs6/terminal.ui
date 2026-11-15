# 下一批历史 gzip custody 队列

已完整定位早期34件保管原件，可按06d、06e两卷执行。100MiB是104,857,600字节；90MB仅为先前规划阈值。尚未生成归档或读取gzip payload。

| 卷 | gzip原件 | gzip字节 | metadata件数/字节 | 源总字节 | 距100MiB余量 |
|---|---:|---:|---:|---:|---:|
| 06d | 16 | 82,539,882 | 59/467,575 | 83,007,457 | 21,850,143 |
| 06e | 18 | 94,272,632 | 50/569,936 | 94,842,568 | 10,015,032 |

## 精确执行范围

06d包含`validation/input-fix-build-headroom-20261114/progress.json`的12条，及其`round1/progress.json`的4条；06e包含`validation/ended-role-build-output-custody-20261115/progress.json`的18条。`queue.json.groups[*].payloads`为原路径、gzip字节/SHA、logical ELF路径/字节/SHA/模式、来源索引及既有index/progress行绑定。两卷logical ELF总数34、SHA各不相同。

metadata范围为上述三个精确目录的全部直接regular文件（06d 40+19件，06e50件）；只从`witness/`选择progress映射的gzip，不递归整个validation或原raw目录。metadata精确文件列表、大小、模式和既有索引SHA在queue中；index自身及未索引后续addendum使用本轮小metadata摘要，不把该摘要伪装成旧receipt。必须原样保留旧index/progress/receipt，不改旧历史状态。

## 非重复证据与限制

已对part01 first-batch-files和part02、03、04、05、06a、06b、06c manifest的9795条记录比对：34个gzip路径、gzip SHA、logical ELF SHA均零命中；三个目录metadata路径也无已交付命中。每份gzip现有stat字节与progress/index声明一致，index中的gzip SHA与progress相同；本轮未重hash payload，交付前须独立核验实际gzip及解压后的ELF SHA/长度。

仅从Git已追踪路径选取36份canonical archive manifest（26个archive-v1 manifest、4个R22 raw-evidence manifest、R22/027和R24 A–E original-manifest）和99个archive-index读取元数据。34组原路径/SHA及gzip路径/SHA没有正面payload member绑定；唯一4条匹配为R24/B对两份frame-cow ELF的bindings+exclusions，明确排除runtime ELF，其余32件无匹配记录。这证明现有canonical索引未提供它们的恢复member；没有逐一解开180个旧tar。来源索引中的hash引用本身不代表payload已经交付。

06e18件的source_indices为空，原progress明确限定为current-byte custody，不应补称历史compiler/source验收；其各自记录的project/HEAD已列出。06d16件保留既有source_indices绑定。两卷源总量和保守tar预算均低于100MiB，实际tar及GitHub交付大小仍需最终测量。

## 后续明确候选（本轮未继续对账）

queue列出已观察到的13组其他ELF witness候选（共60份gzip）及2组可能是compiler/cache packed-target的候选；这些没有进入06d/06e。其exact map、旧Git/archive/前包去重尚未完成，不能径直全打包或按cache名称排除。SDK gzip未列作待迁移ELF。

本轮仅元数据及有限stat，只写本目录report/queue；不build、不VM、不联网、不上传、不大payload hash、不读取完整环境/凭据、不遍历禁区。未断言342项或第六组全部完成。
