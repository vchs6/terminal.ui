# Linux ANSI 依赖许可来源调查（2026-11-09）

只读调查 `/workspace/work/terminal.ui`；所有下载、归档及报告均在本隔离目录。没有修改产品仓库，没有提交，没有联系维护者。目标是固定来源与矛盾，不作法律许可通过结论。README“无。”是缺失/矛盾声明证据，不等同明确禁止使用；这里的“阻塞发布”指项目既有许可核实门槛尚未满足，不是法律认定不得分发，也不据此阻塞Linux内部构建。

## 当前结论

| 对象 | 已取得的确切证据 | 尚未闭合的事项 |
|---|---|---|
| ansies 1.3.113 | 取得同作者历史的 GitHub 镜像固定提交 `dac6fe9ab1407cd533153e98b091cda0d8610713` 的完整双语 MulanPSL-2.0；包中108个文件逐字节一致，全部实际运行库源码一致 | 原README给的AtomGit地址不可取（403）；镜像声明版本1.3.105，包为1.3.113；清单、一个测试文件及macrocall生成物有差异，不能称整个包等同固定上游发行版；发行时仍须收纳许可及归属并验证实际制品 |
| unicodewidth 0.1.113 | 上游 `b3d9c8c8684f3a093a2e9d9d306ec36a3eb67cb5` 清单确为0.1.113；包全部35个文件对应上游：1个逐字节一致，34个仅CRLF/LF不同，无新增/实质差异；取得LICENSE、LICENSE-MIT、LICENSE-APACHE、COPYRIGHT、README.OpenSource | 中心仓包未包含许可文本；需补齐分发材料。合并LICENSE的2026版权行写成 `cfgif4cj contributors`，不能擅自改写；独立LICENSE-MIT和源文件指向Rust Project Developers且有逐文件双许可声明。未做最终制品许可审查 |
| unicode 0.1.0 | 元数据指向作者仓库；固定提交 `a12b0d8009e3111cc3f98563026a5b2dbfaf149f` 的清单也是0.1.0，取得完整MulanPSL-2.0；包42文件中1个逐字节一致、37个仅换行不同（含生成器、C/ASM原生源、现有运行库）；README/测试有差异 | 包独有 `unicode/unicodewidth.cj` 35行宽度封装不在已取上游历史内；当前证据不能把包的全部文件称作确切上游内容。包无完整LICENSE；仍需保留中心仓Mulan声明、处理新增文件来源与实际分发材料；不得以旧的上游.a充当本轮构建输出 |
| bitarray 0.1.0 | 作者仓库固定提交 `c6c5a40a5ed2a51199cb3a8b9702c01a8da1e694`（提交说明“添加许可证和示例程序等。”）；清单0.1.0；中心仓14个源码/文档/清单文件逐字节一致，另外4个是未跟踪示例构建缓存/lock；取得三个完整许可证文件 | **README仍写“无。”；根LICENSE首行错误指定 `unicodewidth4cj`，其MIT版权又指定 `cfgif4cj contributors`；独立MIT又指定Rust Project Developers。** 因此这是取得了更多互相冲突的授权证据，不能宣布冲突已消解，仍阻塞包含bitarray的发行结论 |
| Unicode 17.0.0 数据 | 官方UCD17 ReadMe与具体数据头明确版本/©2025 Unicode/terms链接；官方terms明确Data Files适用Unicode License v3（除具体例外），已取完整v3文本；本轮保存官网2026版权版本并记录hash | 需在生成表/原生静态库的分发材料中保留Unicode版权与许可；这是可落地的许可材料来源，不等于已对最终制品完成归属检查 |

上述“已取得”解决了许可证全文找不到、Unicode数据许可不知道从哪里取得、unicodewidth确切源对应关系三个证据缺口。bitarray冲突仍是明确发布阻塞；ansies/unicode不能写成逐字节对应完整固定发行版。只在文档写MIT/Mulan、从其他仓库复制一份模板、或未调用TextStyle，均不能据此声称发布门槛已通过。

## 固定来源

- ansies镜像：[固定树](https://github.com/cangjielanguage-sig/ansies4cj/tree/dac6fe9ab1407cd533153e98b091cda0d8610713)，[LICENSE](https://github.com/cangjielanguage-sig/ansies4cj/blob/dac6fe9ab1407cd533153e98b091cda0d8610713/LICENSE)。中心仓元数据repository=null，README给 `https://atomgit.com/vchuoshen6/ansies4cj`；该URL的git读取返回403，不能把镜像来源误说成中心仓明确链接。
- unicode：[作者固定树](https://gitcode.com/vchuoshen6/libunicode/tree/a12b0d8009e3111cc3f98563026a5b2dbfaf149f)，[LICENSE](https://gitcode.com/vchuoshen6/libunicode/blob/a12b0d8009e3111cc3f98563026a5b2dbfaf149f/LICENSE)。本次Git读取该登记URL成功。
- unicodewidth：[固定树](https://atomgit.com/cj-awesome/unicodewidth4cj/tree/b3d9c8c8684f3a093a2e9d9d306ec36a3eb67cb5)，[LICENSE-MIT](https://atomgit.com/cj-awesome/unicodewidth4cj/blob/b3d9c8c8684f3a093a2e9d9d306ec36a3eb67cb5/LICENSE-MIT)，[LICENSE-APACHE](https://atomgit.com/cj-awesome/unicodewidth4cj/blob/b3d9c8c8684f3a093a2e9d9d306ec36a3eb67cb5/LICENSE-APACHE)。匹配的是 `feat/unicodewidth4cj-1.1.3` 分支而非main（main仍是0.1.0）。
- bitarray：中心仓登记 `https://gitcode.com/vchuoshen6/libbitarray.git`；README同时给AtomGit同作者同仓库；本次clone [AtomGit作者仓库](https://atomgit.com/vchuoshen6/libbitarray)，[固定LICENSE](https://atomgit.com/vchuoshen6/libbitarray/blob/c6c5a40a5ed2a51199cb3a8b9702c01a8da1e694/LICENSE)，[固定README](https://atomgit.com/vchuoshen6/libbitarray/blob/c6c5a40a5ed2a51199cb3a8b9702c01a8da1e694/README.md)。未将Gitcode/AtomGit品牌迁移本身当作授权推论；包内容对应另有全文件比较支撑。

固定内容以Git对象读取。仓库仅保存最小证据索引、许可与声明原文及差异；完整源码归档保留在隔离工作目录，不加入仓库。证据索引的固定commit/URL及SHA可用于重新取回和核对。

## Unicode17许可链

1. 本轮既有隔离探针所用 `UCD-17.0.0.zip` SHA256记在 `ucd17-archive-sha256.txt`。本次未更改该文件。
2. ZIP内ReadMe和官网 `https://www.unicode.org/Public/17.0.0/ucd/ReadMe.txt` 内容指向 `https://www.unicode.org/terms_of_use.html`；已取ReadMe及代表文件头完整原文。
3. terms跳转至 `https://www.unicode.org/copyright.html`；Data Files目录范围包含 `/Public/`，第109–110行明确“all Unicode Data Files and Unicode Software”使用Unicode License v3，除具体发布点例外。
4. `https://www.unicode.org/license.txt` 完整条款已存 `unicode-license-v3.txt`：要求版权与许可声明随全部Data Files/Software或关联文档提供，禁止未经书面许可用版权人名称促销。不能把Mulan或Rust的MIT声明代替Unicode数据归属。
5. `https://www.unicode.org/Public/17.0.0/ucd/LICENSE.txt` 返回404，已记录；没有虚构“UCD17自带LICENSE文件”。现取官网v3是©1991–2026，数据文件是©2025，均保存原文，不自行替换年份。

## 移除bitarray/替代依赖的可执行性评估（未实施）

确切包中运行库唯一 `import bitarray` 在 `ansies.api/text_style.cj`；它以 `PartitionedBitArray` 存储64位样式字段。TextStyle与StyledText使其成为真实传递依赖，CJPM清单固定要求0.1.0。单纯应用层“不调用TextStyle”、静态链接器碰巧去掉符号、或只删除直接依赖行，不能证明下载/分发内容已不含bitarray。

技术上可在有适用ansies授权的固定源码基础上，独立编写UInt64位域存储，替换该私有字段实现并去掉依赖；必须保留公开行为（颜色、14样式位、toInteger/fromInteger、构造与比较），验证源码/lock/最终制品没有bitarray，保留ansies Mulan许可及修改记录。该路线无需复制bitarray实现，但本报告没有认定当前许可矛盾可通过“删代码”自动获得法律解决，也没有实施fork或变更产品选型。另一条路线是以有明确授权的ANSI依赖替代ansies，需另做能力/解析行为/公共契约比较。两者均属于具体依赖路线变更，应由主任务根据授权和决策审查处理；不是本次只读调查的成果。

不建议把错误项目名擅自修成bitarray后宣称授权成立。可闭合条件是取得适用于该确切源码的无歧义授权证据，或实际移除相关源码/对象/制品依赖并完成新路线审查。未联系维护者，也未发送消息。

## 完整调查目录（隔离留存，以下部分不随仓库提交）

- `*-registry-metadata.json`：2026-11-09官方实时完整原始响应（含README和publisher）；`evidence/*/*.cjp`：先前官方获取的确切原包，本次SHA256逐一匹配项目R5索引。
- `source-manifest.json`：实际clone URL、固定commit、完整提交信息、上游清单和包hash、最佳全文件比较。
- `package-upstream-comparison.json`：所有已取历史commit与**原始cjp**的逐文件比较，明确区分字节相同、仅换行差异、实质差异和上游缺文件。没有拿已构建缓存冒充原包。
- `source-differences.diff`：原包与最接近固定commit差异原文，含unicode宽度封装、测试注释、ansies清单差异；macrocall生成物/示例构建缓存仍在原cjp和清单中，但不扩印其diff。
- `evidence/*/LICENSE*`、`COPYRIGHT`、`README.OpenSource`、`package-README.md`、`package-cjpm.toml`：固定上游许可/归属和原包声明分别保留，未相互覆盖。
- `unicode-license-fetch.json`、`unicode-terms.html`、`unicode-license-v3.txt`、`ucd17-*`：官方数据许可原文和取回状态。
- `SHA256SUMS`：除工作clone/.git和checksum文件自身外，全部证据的SHA256。

## 仓库保存范围

本目录保存 `evidence-index.json`（固定来源、版本、hash和对应关系）、`source-differences.diff`、四包的许可/归属和原始README/清单，以及Unicode官方许可原文。大源码归档、原cjp、全量Unicode数据不提交；原cjp摘要与R5相同。仓库内 `SHA256SUMS` 只校验实际保存的文件，不沿用隔离目录的全量清单。

包原始README以 `package-README.md.txt` 保存（原始字节不变），避免其上游相对链接被误作本项目导航。
