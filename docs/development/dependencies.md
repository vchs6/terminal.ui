# 外部依赖与适配边界

2026-11-09 用户授权比较中心仓 unicode、unicodewidth 并评估 ansies 后选型；该授权替代原先未经实测固定 unicode 单库的限制。当前开发版本0.0.0、SDK验证基线1.2.0，清单不代表产品发布或集成通过。

## 1. 选型与唯一职责

| 依赖 | 固定版本 | 职责 | 本轮结论 |
|---|---|---|---|
| [ansies](https://pkg.cangjie-lang.cn/package/ansies) | 1.3.113 | ANSI序列生成与实际支持的终端回复解析 | 代表SGR/光标生成可编译运行；完整富文本/键盘解析不因此成立 |
| [unicodewidth](https://pkg.cangjie-lang.cn/package/unicodewidth) | 0.1.113 | 唯一显示宽度来源，含模糊宽度策略 | ASCII、CJK、组合、ZWJ、肤色、心形/国旗emoji代表样本及widthCjk通过；不是分段库 |
| [unicode](https://pkg.cangjie-lang.cn/package/unicode) | 0.1.0 | 字符簇分段及规范化，不使用其宽度算法 | 非空代表分段/NFD通过；有原生数据构建前提，空串迭代额外空簇需薄适配过滤 |
| bitarray（传递） | 0.1.0 | ansies依赖 | 包摘要核对；许可证来源有冲突，发布前须解决 |

采用职责互补：unicodewidth不提供字符簇分段，单独使用不能满足编辑；unicode的宽度在本轮心形/国旗样本与所需策略不符，不能独自满足宽度。两个库不重复调用宽度互相兜底，也不复制第三方数据表或自写平行Unicode内核。真实API为 widthCjk()，不是unicodewidth包README过时的width_cjk()。

## 2. 可复现证据与限制

来源、中心仓索引和实际cjp摘要见 [元数据](../reviews/R5/evidence/dependency-metadata.json)、[证据入口](../reviews/R5/evidence/README.md)。全部结论仅覆盖记录版本、Linux x64/SDK1.2.0及代表样本，完整Unicode一致性、平台适配和制品验收仍pending。

unicode0.1.0直接CJPM依赖在本环境链接失败，缺少libunicodedata符号。隔离实验通过生成器、Unicode17 UCD数据、C/ASM构建该原生库并显式链接后运行；这证明有可行调查路径，不表示普通用户仅cjpm build就能使用。TASK-003必须把源码来源、校验、工具版本、构建/链接、许可及干净消费转成正式可复现契约，TASK-023验证真正制品；未解决前不声明依赖即插即用，也不把探针二进制混入制品。

CJPM在本环境直接联网失败；隔离验证脚本通过本地HTTP relay使用继承代理/CA连接官方中心仓，未改写下载内容，实际cjp按索引SHA256核对。本relay只是本轮网络环境工具，不是产品运行依赖。

unicodewidth数据表标识Unicode17.0.0；unicode原生数据来源及版本见重跑脚本。字符簇、宽度与终端字体的差异由策略/矩阵明确；R5未执行官方完整一致性测试；R7补跑Unicode17官方GraphemeBreakTest的766条分段用例全部通过，仍非规范化全量/编辑换行/字体一致性证明，不声称支持完整IME、BiDi或所有字形。word boundary/line breaking不是unicode包已实现能力，相关编辑/换行需要单独契约和验证。

## 3. 许可证与发布门槛

中心仓声明：ansies、unicode为MulanPSL-2.0；unicodewidth为MIT/Apache-2.0；bitarray索引元数据为MIT/Apache-2.0，但其README许可证章节写“无。”。本轮下载包中未发现完整LICENSE文本，不能把元数据声明当作完成了分发许可审查。

TASK-003/023须核对上游授权来源、完整许可证文本、Unicode数据许可及必要归属，解决bitarray声明冲突。当前只登记原始证据与风险，不作法律许可通过结论，不发布。保持根项目MulanPSL-2.0许可，不将第三方双许可合并成根许可。

CJPM制品规则依据：[官方1.2.0手册](https://cj-docs.gitcode.com/zh/1.2.0/tools/source_zh_cn/cmd-tools/cjpm_manual.html)。include/exclude约束源码cjp而不是GitHub源码zip；后续须用真实bundle与干净解包验证依赖路径及构建，不以配置字符串替代证据。

## 4. 跨平台集成门槛

REQ-011要求Linux、Windows、macOS、HarmonyOS。现有日志仅Linux x64/SDK1.2.0；其他目标的仓颉标准库/运行库、CJPM依赖、unicode原生生成/汇编归档及链接必须分别验证。不得将Linux生成归档或仅存在交叉编译target当作通过。尤其要核对Windows COFF、macOS Mach-O与鸿蒙目标ABI、C/ASM工具链及沙箱文件/终端权限；此处是调查维度，不是已判兼容或不兼容。TASK-003/004当前先提供Linux可复现消费方法；其他目标在Linux全部功能验收后调查和实施。缺证目标保持pending并阻止完整跨平台发行结论，不阻塞Linux阶段构建、功能实施或其独立验收。

## 5. Linux优先风险复核（R7）

普通build同样缺少libunicodedata，根因为官方包无自动原生构建脚本，而非探针使用skip-script。固定源码/UCD17生成原生库后，在依赖副本补FFI声明以及由中间静态适配库自行拥有 `[ffi.c]` 两种路径已运行；后者保持unicode官方清单原样且可传递到独立消费者，作为推荐集成边界。这不表示中心仓原包已自带该集成。主库清单本轮不改；正式构建、FFI传递与干净制品归TASK-003/023。详见[风险处置](../reviews/R7/risks.md)。

本轮已取得固定上游许可证原文及Unicode数据许可来源；unicodewidth全包仅换行差异，ansies/unicode仍有版本/文件对应边界，bitarray声明冲突仍待核实。许可正文找到不等于最终分发许可通过，见[来源与差异](../reviews/R7/evidence/licenses/README.md)。

## 6. 当前用户裁决（后于R7）

用户明确许可证冲突无需由本项目解决，包可用即可。以上R5/R7的自设许可阻塞政策已被该裁决替代；当前实施/交付核对实际可构建、链接和运行，保留原始许可/归属，继续编码，不等待上游澄清。

## 7. 正式Linux构建切片

正式build.cj、native/build.sh及src/unicode.cj已经实现，普通消费者与源码包干净解包消费已独立验证；构建要求与离线输入见[产品构建说明](../product/native-build.md)。R5/R7关于当时“尚未正式集成”的描述保留为历史，当前实际结果按R8及本切片验收记录判断。
