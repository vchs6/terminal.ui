# 外部依赖与适配边界

当前开发版本 `0.0.0`，未发布；SDK/CJPM 验证基线为 `1.2.0`。2026-11-09 用户授权比较中心仓 unicode、unicodewidth 并评估 ansies 后选型，替代原先未经实测固定 unicode 单库的限制。随后用户明确：许可声明冲突无需由本项目解决，包可用即可；保留原始许可证和归属，不等待上游澄清。R5/R7 中相反的自设阻塞政策只属于历史记录。

本次冻结依赖事实对应产品源码 `d7e9d1445f98021a798d223de97b97b45239de93`、正常源码 CJP SHA-256 `05c99476961be72022f0ea98adb3d283453b9b41fd7adcbf428880d24d6de86f`。这是原 TASK-003 的独立文档投影，**最终 TASK-003 验收、TASK-023 的 T087 fresh-cache/发行/源码包核对及完整 Linux 验收仍 pending**。以下事实不改变必需平台范围。

## 1. 选型与唯一职责

| 依赖 | 固定版本 / 关系 | 职责与缺口 |
|---|---|---|
| [ansies](https://pkg.cangjie-lang.cn/package/ansies) | `1.3.113`，直接 | ANSI 生成及实际支持的终端回复解析；不因此获得完整富文本、键盘或终端模拟器解析能力 |
| [unicodewidth](https://pkg.cangjie-lang.cn/package/unicodewidth) | `0.1.113`，直接 | 唯一显示宽度来源，含模糊宽度策略；不提供字符簇分段 |
| [unicode](https://pkg.cangjie-lang.cn/package/unicode) | `0.1.0`，直接 | 字符簇分段及规范化提供方；cjtui 使用分段，不调用其宽度算法；需要原生数据构建 |
| [cangjie_toml](https://pkg.cangjie-lang.cn/package/cangjie_toml) | `0.2.3`，直接 | Theme TOML lexer/parser；其 `stdx.serialization.serialization` 导入需要外置 stdx 二进制输入 |
| bitarray | `0.1.0`，ansies 传递项 | ansies TextStyle 的位存储；实际依赖，不能因应用未直接调用而省略 |
| Cangjie stdx | `1.2.0-beta.02.1`，外置二进制前置 | 对应 SDK `1.2.0`；不是新选择的中心仓包，也不随 cjtui vendoring |

unicodewidth 不提供分段，单独使用不能满足编辑；unicode 的宽度在 R5 心形/国旗样本与所需策略不符，不能独自满足宽度。两库职责互补，不重复调用宽度兜底，不复制第三方数据表或另建平行 Unicode 内核。实际接口是 `widthCjk()`，不是 unicodewidth README 的过时 `width_cjk()`。正式适配位于 `src/text/unicode.cj`：空输入直接返回空数组，过滤了早期 unicode 空串额外空簇现象。

## 2. 来源、校验与实际输入

完整固定版本、官方索引记录、原包 SHA-256、许可来源与使用职责见 [central-packages.json](central-packages.json)。[最终依赖/native 清单](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/Linux-final/dependency-manifest.json)保存独立 F1 来源绑定、167 项实际依赖源码/清单文件摘要、生成器输入、四个 native 归档及选定 SDK/stdx 文件集的封存摘要。**文件集摘要不等于原始发行包摘要**；保留原清单的绝对路径仅用于证据保管定位，不作为用户安装要求。

| 输入 | 官方来源 | 原始载荷 SHA-256 |
|---|---|---|
| ansies `1.3.113` | `https://pkg.cangjie-lang.cn/registry/pkg/ansies/1.3.113` | `396ead6ab841eddd12b196fb657848587c4514a435c536146810ee5675344940` |
| unicodewidth `0.1.113` | `https://pkg.cangjie-lang.cn/registry/pkg/unicodewidth/0.1.113` | `6fa20716cc224c4d774ca83e5a20ebaa1f86b52ac495cff392655dc2b34eea94` |
| unicode `0.1.0` | `https://pkg.cangjie-lang.cn/registry/pkg/unicode/0.1.0` | `d810505f62b43417ce673fb9c811f740503d3df88665307557544eae6d073c4c` |
| cangjie_toml `0.2.3` | `https://pkg.cangjie-lang.cn/registry/pkg/cangjie_toml/0.2.3` | `297998b23b08f2a43bb6821765c8991b3a078ceb31649068e777db8cb8a5f398` |
| bitarray `0.1.0` | `https://pkg.cangjie-lang.cn/registry/pkg/bitarray/0.1.0` | `3c5d7f12e9a1ce68295fb547f0892016911e1cef54218343102a2101ece4d01c` |
| stdx Linux x64 `1.2.0-beta.02.1` | [官方发行 ZIP](https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.2.0-beta.02.1/cangjie-stdx-linux-x64-1.2.0-beta.02.1.zip) | `0d35811d84a770315c6fa2d1090a10568b3f7c763a1d1d54a1433b324f76afc0` |
| Unicode UCD `17.0.0` | `https://www.unicode.org/Public/17.0.0/ucd/UCD.zip` | `2066d1909b2ea93916ce092da1c0ee4808ea3ef8407c94b4f14f5b7eb263d28e` |

SDK 的独立封存范围是 cjc、cjpm、`libcangjie-runtime.so` 与 `libboundscheck.so`，不是完整 SDK 安装树或 SDK 发行归档。stdx 安装文件集覆盖 125 项；其摘要与上述 ZIP 摘要分别记录。R8 记录的 C 工具为 GCC `14.2.0`、GNU ar/binutils `2.44`；F1 沿用 SDK/依赖/native 输入并确认四归档字节连续，但未单独封存 GCC/ar 二进制或所有系统工具版本，不能声称这些已有完整最终工具链封存。

## 3. 当前正常 Linux 构建与链接

`build.cj` 在 `pre-build` / `pre-test` 调用随包 `native/build.sh`。它在包内 `.cjtui-build` 使用 `flock`、校验官方 unicode CJP 与 UCD；构建 unicode 包自带的 `generator`（声明版本 `1.0.0`，无额外包依赖），生成数据，再由 GCC 编译上游 `library.c` / `data.S`、GNU ar 生成 `libunicodedata.a`。生成器的源码、清单和上游 C/ASM/header 输入摘要见最终清单。`.cjtui-build/native-ready` 仅检查 Unicode 归档的复用；三个产品 C 桥归档在 hook 调用时重新编译。

| 静态归档 | 用途 |
|---|---|
| `native/libunicodedata.a` | 官方 Unicode 属性/分段/规范化数据查询，数据来自固定 UCD |
| `native/libcjtui_terminal.a` | POSIX 终端会话、输入、单调时钟、缓冲写出 |
| `native/libcjtui_capabilities.a` | 终端能力检测 |
| `native/libcjtui_glyphs.a` | 字形探测支持 |

根清单通过 `[ffi.c]` 持有并传递四项链接输入，普通消费者无须自行声明 Unicode FFI 或手工 `-L/-l`。这是 cjtui 已实现的自动集成；**上游 unicode `0.1.0` 原包本身仍没有这套自动构建 hook**。验证目标是 Linux x86_64 / GNU / cjnative；C ABI、上游头文件的平台尺寸类型和 `data.S` 不能据此推导为其他 CPU/对象格式兼容。

源码 CJP 包含 hook、native 源码与许可证；`*.a`、`*.o`、`.cjtui-build`、`target`、`cjpm.lock` 均被清单排除。这里记录的四归档是消费时构建输出，不是塞入源码包的预编译文件。CJPM include/exclude 的适用对象是源码 CJP，不是 GitHub 源码 ZIP；依据仍为 [官方 1.2.0 手册](https://cj-docs.gitcode.com/zh/1.2.0/tools/source_zh_cn/cmd-tools/cjpm_manual.html)。

构建准备与下载规则见 [产品构建说明](../product/native-build.md)：Bash、curl、tar、unzip、sha256sum、realpath、flock、GCC 和 GNU ar；先加载 SDK 环境，再提供 stdx 的官方归档兼容目录。以下路径由用户按安装位置替换，只需准备一次目录映射：

```sh
sdk_dir=/path/to/cangjie
stdx_dir=/path/to/cangjie-stdx-linux-x64-1.2.0-beta.02.1
stdx_layout=/path/to/user-owned-stdx-layout
source "$sdk_dir/envsetup.sh"
mkdir -p "$stdx_layout"
ln -s "$stdx_dir" "$stdx_layout/linux_x86_64_llvm"
export CANGJIE_STDX_PATH="$stdx_layout"
cjpm build
```

必须能从 `${CANGJIE_STDX_PATH}/linux_x86_64_llvm/static/stdx` 找到官方 stdx 文件；实际 ZIP 的 `static/stdx` 在解包目录直属层，所以需要上述映射。可用 `CJTUI_UCD_ARCHIVE` 指向校验相同的本地 UCD ZIP；首次没有输入缓存时仍需访问官方中心仓及 Unicode 下载源。`--skip-script` 会跳过必需的 native hook。构建会写入包内缓存/归档，不能把包目录设为只读。

## 4. 干净消费证据与运行闭包

独立 F1/F2 以新解包的上述 CJP 对照固定 Git 源码，333 个成员全部相同。`benchmarks/rendering/workloads`、`benchmarks/rendering/compat`、`benchmarks/rendering` 三个公开项目及三个既有独立设备/runtime fixture 的六次正常 `cjpm build -j 1 --target-dir …` 均退出 0，未改产品依赖或跳过 hook。新 compat ELF 为 `8a80880135436869bc4272322721ce51f8daabf8c550a3baf593374d858c854f`；diagnostic ELF 为 `d52f443b32588013eafc814b73ce2e8ee5393698cc19caf3a5de99a3cb8e3b98`。两个有限 `unicode_cells` 公开消费 smoke 的产品执行及 Cell/caret/sample 验证均退出 0；28 个受影响设备/runtime 检查通过。原始外部 metadata/selector 错误及修正保留在证据中，未伪造产品重跑。确切命令、环境、产物、摘要及限制见最终清单绑定的独立原件。

这里的“干净”指**新包解包和正常构建入口**；独立执行复用了既有官方依赖 cache、声明的 SDK/stdx 及已校验 UCD，不是空缓存、密封环境、断网或首次联网下载验证。历史 CJPM 直接联网失败时使用的本地 HTTP relay 只转发官方原字节并校验原包，不是产品依赖或用户必需部署。hook 不改共享官方源码 cache。

四个 native `.a` 是静态链接输入，不是动态运行库。R8 的独立复制消费者执行与文件访问 trace 表明，该**历史产物**运行无需 checkout/cache/UCD；其 `ldd` 仍需要 SDK 的 `libcangjie-runtime.so`、`libboundscheck.so` 及 Linux 的 libc/libm/libstdc++/libgcc_s/libpthread/libdl 和 ELF loader，见 [原始运行日志](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/R8/execution/logs/slice-runtime.log)。F1/F2 的新 ELF 已实际运行并绑定相同选定 SDK runtime 字节；此证据子集中没有最终 D7 ELF 的新 `ldd`/文件访问审计，不能把旧日志改标为新 ELF 的完整运行闭包审计。继续保留 SDK runtime 库搜索环境；最终发行闭包由 TASK-023 核对。

## 5. 许可原文、归属与来源边界

保持根项目 MulanPSL-2.0，不将第三方双许可改写或合并为根许可。实际原文在随包 `third_party/licenses`：

| 对象 | 原文 / 归属及确切来源限制 |
|---|---|
| ansies | `ansies/LICENSE`、`README.OpenSource`；MulanPSL-2.0，固定镜像提交 `dac6fe9ab1407cd533153e98b091cda0d8610713`。实际运行库源码相符，但镜像声明 `1.3.105`，中心仓为 `1.3.113`，清单/测试/生成物有差异，不能称完整包等于该上游版本 |
| unicode | `unicode/LICENSE`、`README.OpenSource`；MulanPSL-2.0，固定提交 `a12b0d8009e3111cc3f98563026a5b2dbfaf149f`。生成器/C/ASM/运行库大部分仅换行不同；README/测试有差异，包独有 `unicode/unicodewidth.cj` 未对应到该历史，不夸大完整源码对应 |
| unicodewidth | `unicodewidth/LICENSE*`、`COPYRIGHT`、`README.OpenSource`；MIT/Apache-2.0，固定提交 `b3d9c8c8684f3a093a2e9d9d306ec36a3eb67cb5`，全部 35 文件对应（1 个逐字节、34 个仅换行差异）；Rust Project Developers / 原文件版权与合并 LICENSE 中的 `cfgif4cj` 原文均保留 |
| bitarray | `bitarray/LICENSE*` 与原 README/清单；固定提交 `c6c5a40a5ed2a51199cb3a8b9702c01a8da1e694`，14 个源/文档/清单字节对应，另 4 个是示例 cache/lock。索引 MIT/Apache-2.0、README“无。”、LICENSE 错项目名及版权差异仍如实登记；按用户裁决不恢复为实施/交付阻塞 |
| cangjie_toml | `cangjie_toml/LICENSE`；实际 `0.2.3` 包 MIT 原文，Copyright (c) 2025 Shibo Meng |
| stdx | `cangjie_stdx/LICENSE`；官方 Apache-2.0 with Runtime Library Exception。外置 stdx 发行包还带上游 open-source notice，分发该发行内容时保留其原件 |
| UCD 17 | `UNICODE-DATA-LICENSE.txt`；官方 Unicode License v3，数据头 ©2025 与已取得许可文本 ©1991–2026 保留原样；不以其他库许可替代 Unicode 数据归属 |

[历史固定来源与差异](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/R7/evidence/licenses/README.md)、[原证据索引](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/R7/evidence/licenses/evidence-index.json)继续保留，不改历史原件。原证据所写的“冲突阻塞发布”已经用户后续裁决替代；本轮记录事实和原文保管，不声称矛盾已经消失，也不建立新的法律审查等待流程。最终源码 CJP 的 333 成员比对包含随包许可证，归属材料的实际发行/源码包核对仍由 TASK-023 承担。

## 6. 历史验证与必需的后续范围

R5 的普通 unicode 直接依赖链接缺 `libunicodedata`，隔离生成并显式链接才成功；R7 确认原因是上游缺自动 native 构建，调查过依赖副本 FFI 与中间静态适配库持有 `[ffi.c]` 两种路径。R8 转成随包 hook、正式适配和普通独立消费者。前两阶段的手动链接限制保留为历史，不能继续描述为当前 cjtui 普通消费缺口；也不能反向称上游原包已自带集成。[R7 风险处置](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/R7/risks.md)与 [R8 独立验收](https://github.com/vchs6/terminal.ui/blob/61e25f009f8f26c991c3f2ba758987db83bedc4a/docs/reviews/R8/verification/verification.md)保留其各自产物/范围。

R5 代表样本覆盖 ASCII、CJK、组合、ZWJ、肤色、心形/国旗 emoji 与 `widthCjk`；R7 的 Unicode 17 官方 GraphemeBreakTest 766 条分段用例通过。它们仍不等于规范化全量、编辑换行或字体一致性证明，不声明完整 IME、BiDi、所有字形支持；word boundary / line breaking 不是 unicode 包已经实现的能力，框架行为另有契约。旧 M1 CJP `29cab0…`、旧 M2 CJP `857243…` 的正常消费/headless/正确性证据保持原身份和可复用范围，不改标为新 ELF 的 CPU/native 输出测量。

REQ-011 的 Linux、Windows、macOS、HarmonyOS 均保留；先完成 Linux 全部功能和验收，再调查实施其他目标。当前实际依赖/native 消费证据仅 Linux x86_64 / SDK 1.2.0；Windows COFF、macOS Mach-O、HarmonyOS ABI、C/ASM 工具链、沙箱/终端权限及其他 CPU 均 pending。跨编译 target 存在或复用 Linux 归档不构成通过，缺证目标也不妨碍 Linux 阶段独立实施。T087 fresh-cache/发行/源码包核对未完成前，不宣布 TASK-023 或最终依赖/整个平台发行链已经闭合。
