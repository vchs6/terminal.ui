# TASK-093 glyph contract tests

独立测试资产；生产实现与真正产品 GREEN 由后续固定产品/独立执行提供。本目录不修改产品、其他冻结 suite、Theme085 fixtures 或任务状态。冻结合同 `a0eae9998f8f72410148c1845840fde591e23d9b` 的 G001–G011（从初始 `d504ca6` 补充包内工厂/profile 和精确 errno 分支）。

## 正常执行

```bash
source /workspace/work/validation/sdk/cangjie/envsetup.sh
# 根目录和四个consumer可各自配置cangjie-repo.toml；复制种子到自己的cache，勿改共享seed。
# [repository.cache] path = "/absolute/own/cache"
# [repository.home] registry = "http://127.0.0.1:18973"
cjpm build
mkdir -p /tmp/glyph-logical-files
CJTUI_GLYPH_FILES=/tmp/glyph-logical-files tests/glyphs/run.sh all
```

入口可单独选 `api`、`public`、`negative`、`internal`、`rich`、`session`。`public` 单独运行时必须设置存在的 `CJTUI_GLYPH_FILES`。所有 CJPM 构建/测试均走正常 build.cj，不使用 skip-script/skip-build。`all` 故障即停止；RED 取证分别调用各入口。

`api` 是最小正常跨包消费者，只引用 glyph 新 API 与已存在 Text/Application/Frame/ColorMode；缺 RichText/Theme 不可能成为此项 RED 的原因。`rich` 单独消费 RichText 前置 API，不能拿其缺失代替 glyph 专用 RED。二者的清单由 SDK1.2 `cjpm init` 生成后追加路径依赖，最终执行真实 binary。

`internal` 在独立临时目录复制真实生产 src/native/build.cj/manifest，加上本目录的同根 package `_test.cj`，再执行正常 `cjpm test`。未公开包内状态、没有环境注入 policy、没有替代投影/宽度/布局实现。生产工厂为 `GlyphRenderPolicy.unicode()/ascii()/mapped(bitmap)`；profile 为原 init 尾追加 `glyphPolicy!`。

`negative` 是正常路径依赖消费者，检查六个 diagnostic 字段不能写。缺类型/依赖不会被误计为负例通过。

## 独立预期

| 范围 | 固定断言 |
|---|---|
| G002/G003 | 两个原构造、默认 Auto、三值相等、setter 返回原 receiver、getter 保留请求值、run 前/headless/offline diagnostics None |
| G005 | 单可打印 ASCII/单 BMP mapped 且宽1放行；é/e+acute/中/文/emoji/VS/ZWJ、0/1/2/4列、负宽拒绝；整簇等宽问号；`?` 缺失用空格 |
| bitmap | 8192 长度，0/8191/8193拒绝，成功复制后输入修改不影响策略；高位 BMP 最后一 byte；空map；所有 BMP 成员 mapped 仍不证明组合簇 |
| 装饰 | 三组角→`+`、横→`-`、竖→`|`；专用 ASCII 不 mapped→`?`；shadow 通用占位；实际 Frame encoder 与逻辑导出 |
| G006 | generatedEllipsis 的 -1/0/1/2/3/5列、…mapped/missing、ambiguousWide=false/true；调用真实 displayWidth 验证…分别1/2列；字面…缺字仅一个`?` |
| G007 | offline Unicode→Ascii→Unicode 缓存失效；设备 setter 独立 wake、布局 measure 增加、同值输出静默；挂载数保留、默认 snapshot 不受设备配置/最近诊断污染 |
| G008 | 中→文、中→?? 原簇/续格结构不同但投影相同零字节；颜色与 glyph 同时等价；新旧各自profile；宽→窄完整行清残留；相同投影profile变更静默 |
| G009 | render/snapshot默认及显式三mode仍保留业务Unicode；plain/ANSI File完整快照；原簇跨RichText span组合/ZWJ保持；裁剪/覆盖与Frame maxCells边界 |

预期字符串直接手写在测试中，不从产品输出生成 golden。源文本 `é é 中文 😀 ✈️ 👩‍💻 …` 手算19列；固定 SDK 现有 displayWidth 的独立实算也为19，wide为20。public 的30列行补11空格；PTY的32列行补13空格。内部 Bitmap 手填 ASCII 32–126、é、组合 acute、ZWJ、…、✈、中、文、VS16、FFFD 位；没有复制 Unicode 数据表/算法。

## 真实PTY与原生故障边界

`session/native/glyph_syscall_wrap.c` 只属于测试 executable，使用现 syscall 符号的合法 link-wrap：fstat/isatty/ioctl/malloc/calloc/free/write。生产库不读取 `CJTUI_GLYPH_TEST_*`，不添加公开 hook。实际 fd0/fd1 都是 Linux PTY，只有测试 wrapper 为 fd1 反馈合成具体VT身份/映射；VT查询若误用stdin即失败。其它终端打开/输入/尺寸/恢复走真实 syscall。

正常 map 手写104个 pair：95个可打印ASCII、é/…/中/文/acute/ZWJ/VS16/✈和重复é；entryCount 是 pair 数104，不是去重后103。最大65535 pair仍允许重复。验证一次262140 bytes临时分配、一次capacity65535读取、读取后free；更新/override/snapshot不重探。

| native scenario | diagnostics |
|---|---|
| real PTY（TERM=dumb 或 linux） | unknown/not-concrete-linux-vt，保Unicode；换TERM不算真实VT |
| mapped、minor63、65535重复pair | nativeVt=true/mapKnown=true/linux-vt-unimap，errno0；Auto保é/…，宽簇及组合占位 |
| empty、no-question | known成功，reason ascii-fallback-unavailable；`?`不可映射则空格保列 |
| alias tty0/console/tty、minor64、非字符设备 | unknown/not-concrete-linux-vt，不读map |
| isatty false | unknown/not-tty，nativeError0 |
| fstat/VT_GETMODE/KDGETMODE失败 | unknown/vt-query-failed，原EIO5/EACCES13 |
| graphics mode | unknown/not-text-mode，nativeError0，不读map |
| map读取失败 | nativeVt=true/mapKnown=false/linux-vt-unavailable/map-query-failed，EACCES13；Auto保守Ascii |
| 临时分配失败 | nativeVt=true/mapKnown=false/linux-vt-unavailable/map-allocation-failed，nativeError0；Unicode override仍保Unicode且保留原诊断 |

`write` wrapper 在真实 stdout write 成功后逐字节保存已成功写出的相同内容，不改变真实写入结果；UI输入回调报告作为刷新 fence，零字节断言基于 fence 前后此文件精确长度，不靠等待一段时间猜测输出完成。退出后还核对 capture 与 script 实际 PTY stream 完全相等。报告保留 raw、stderr、syscall trace、profile、实际exit和termios前后值。

合成分支是 syscall 行为验证，不是 Linux VT视觉证据。真正具体VT/真实VTE或xterm、font来源、PNG/hash、宿主矩阵及制品检查属于096。此 suite 的真实PTY仅证明未知PTY/实际运行/恢复分支。

## 明确边界

本增量只测实际投影、policy、marker函数与上下文/缓存接线。没有 TextOverflow 前缀布局断言；不能把 `generatedEllipsis` 函数测试称为“完整 ellipsis 排版通过”。Theme013完成后由085追加先预留三列的实际布局/绘制测试。

允许的 declaration-only 语法隔离若需要，应放仓库外、仅编译不运行、不提交、不计产品GREEN。正式RED来自未补声明的旧产品正常构建和真实消费者/同包测试。test-only固定提交和原始命令/exit/UTC/sourcehash在093交付报告中关联；实现作者不得修改这些冻结预期。
