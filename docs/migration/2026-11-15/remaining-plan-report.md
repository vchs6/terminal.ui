# 剩余迁移范围与批次计划（元数据审计）

**目前能确认已交付3个下载包；不能诚实地核定全部下载包总数。** 建议把工作固定为7个逻辑组，后续为第4至7组；第5、6组可能需要多卷。“7组”是范围组织方案，不是“总共只需7包”的承诺。

## 已交付与Git覆盖

第一批保留源码、已盘点Git refs/HEAD、315份未提交源码测试和当前交接；第二批保留C008 runtime的7404原件/737原始PNG；第三批保留公开示例ELF、原测试CJP、历史native ELF及来源。范围以各包manifest和README为准。

固定baseline `a5aed685` 的 `docs/reviews` 已含 **180个tar.gz / 111861126压缩字节**，包括隐藏 `.archive-v1`；本轮确认该子树与当前工作树无差异。这些文件可从第一批要求的Git baseline恢复，不应重新当成全量待下载原件。另有99个现存archive-index JSON及26组archive-v1 manifest（36755条记录）可用于去重。

R24 A–E的original-manifest进一步提供原件路径与归档member。E的archive-index自述40022 original、27514 member、12262 aliases、unresolved=0；这只覆盖其已接受的E/AC022/AC031范围，不外推其他历史工作。第三批里的CJP等也可能与此重复，最终应合并映射。

**有归档索引不等于整个原目录已备份。** 例如R16 execution明确复制curated bytes，原始脚本与curated版本可能不同；VM镜像、native工具、源Markdown快照等有明确omission。归档中同一路径可绑定不同历史SHA，不能仅按路径去重，也不能把alias数量当成新增实体文件数。

## 固定逻辑组

| 组 | 范围 | 状态/卷数 |
|---|---|---|
| 1 | 源码、Git refs、未提交源、当前交接 | 已交付1包 |
| 2 | C008原始runtime证据 | 已交付1包 |
| 3 | 原ELF/CJP/native及provenance | 已交付1包 |
| 4 | c008-capacity五份gzip benchmark ELF及custody | 正准备，约28MB原压缩payload；待实际打包确认 |
| 5 | VM镜像及reproduction输入 | 固定此范围，需清点去重后定卷数 |
| 6 | 全342项中尚未交付的独有历史成果/原始证据 | 可多卷，不能承诺仅1包 |
| 7 | 最终覆盖对账、依赖pins、恢复说明与交接 | 收口组；发现的实体缺口归第5/6组 |

## 342项分类的含义

`plan.json.entries`逐项列出审计时全部342个顶层项，文件数/字节原样来自旧审计（28065035840逻辑字节），没有扫描或哈希28GB原件。它采用保守主分类与可重叠组件标签：

- 已Git/三包涵盖：按Git refs范围及三包文件清单标注；若整项文件数和字节与包manifest吻合，标为整项manifest覆盖，未对当前源重哈希。
- 继续迁移队列：独有成果或尚未证明覆盖的安全原件。此项不表示每字节都独有；先对历史archive-index/manifest与包manifest去重。
- 可重取：仅明确固定且干净的CangjieSkills/rules仓库列为pinned upstream；npm-cache只是候选，需补来源/pins证明。SDK、registry、target等没有逐项证明前仍保留在审计队列。
- 重复工作树/生成物：标注已知共享Git对象库的tracked组件与旧审计识别的build/SDK/cache候选；这不授权排除该目录中的ignored原始证据、未提交记录或原ELF。
- 禁区/认证材料：禁区子路径永不迁移，其安全兄弟项仍需对账；SSH身份、private keys、credentials、.env等永不打入包，不输出其值。

主分类计数：reacquirable_pinned_upstream=2；covered_by_parts_manifest=20；unique_or_unresolved_remainder=318；reacquirable_cache_candidate=1；protected_subpaths_plus_unresolved_allowed_evidence=1。组件标签可重叠，故不能相加为342。没有任何整目录仅凭名称被当成可丢弃cache。存在VM路径引用的目录会同时列入5/6组，按文件区分；目录级remaining_group只是主要排队位置。第一批repository-refs还明确列出7个未修改上游shallow checkout为固定版本重取（两项顶层skills/rules、r7-acceptance下4项依赖、主仓库.dev-tools/superpowers），它们没有被误标为已导出Git历史。

## 精确卷数缺少什么

1. 342项的逐文件安全元数据全集：相对路径、类型、字节/模式、是否Git tracked/ignored、必要内容SHA。现inventory只有顶层聚合及有限源文件表。
2. 所有已交付物和main历史archive的统一路径+SHA→可恢复member/commit/blob/alias索引，含压缩custody逻辑原件映射。
3. 现存原件相对历史manifest的增量/漂移核查；curated源码与原件、明确omission、已删除逻辑原件必须区分。
4. 生成物/SDK/cache按确切来源、版本、hash、正常恢复命令逐项证明；目录名不能替代证明。
5. 最终保留原件的去重字节量、逐卷大小上限及真实压缩结果；没有这些不能计算下载卷数。

最后一份覆盖证明必须把每个安全原件映射到“Git commit/blob、迁移包member、历史archive member、gzip custody恢复路径、可重取固定依赖、字节重复alias、明确不迁移理由”之一；未决项不能以cache名称消失。先建立这张表，再依据去重后的压缩体积和每卷上限核定实际总卷数。

## 禁止范围与限制

本轮只读旧inventory/report、主仓库Git元数据、已公布迁移包清单、历史archive-index和压缩manifest。未读取禁区内容、凭据或完整环境值，未构建、联网、清理、上传、重跑验收，未对28GB作全hash扫描。未声称VT、六宿主或Linux最终验收完成。没有修改原件/旧索引；生成的计划本身不在旧342项统计内。
