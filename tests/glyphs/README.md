# TASK-093 glyph contract tests

独立测试资产；生产实现与真正产品 GREEN 由后续固定产品/独立执行提供。本目录不修改产品、其他冻结 suite、Theme085 fixtures 或任务状态。原正式测试 `daf2a2523c5aacb27e2ea3b564b9b057bd6430de`（root集成901b06a）与真实old RED保留在历史；本轮按固定基线 `04a5289361d990e5a340ace22bbd50c9b805a9d9` 的 G001–G012、fix-uncertain-glyph-advance A001–A008刷新。原G001–G011合同为 `a0eae9998f8f72410148c1845840fde591e23d9b`。167/084有限正式接受不等于完整094已准入；094仍待152及全部指定上游。

## 正常执行

```bash
source /workspace/work/validation/sdk/cangjie/envsetup.sh
# 在固定候选source根目录执行；先复制共享只读种子到自己的cache。
# cp -a /workspace/work/validation/replay-dependencies/cache /absolute/own/cache
# 根目录与 tests/glyphs/{api,public,rich,session} 各自配置cangjie-repo.toml：
# [repository.cache] path = "/absolute/own/cache"
# [repository.home] registry = "http://127.0.0.1:18973"
cjpm build
mkdir -p /tmp/glyph-logical-files /tmp/glyph-pty-artifacts
CJTUI_GLYPH_FILES=/tmp/glyph-logical-files \
  CJTUI_GLYPH_ARTIFACTS=/tmp/glyph-pty-artifacts tests/glyphs/run.sh all
```

入口可单独选 `api`、`public`、`negative`、`internal`、`internal-conservative`、`rich`、`session`。`public` 单独运行时必须设置存在的 `CJTUI_GLYPH_FILES`。所有 CJPM 构建/测试均走正常 build.cj，不使用 skip-script/skip-build。`all` 故障即停止；RED 取证分别调用各入口，不能把未到达项写成已运行。

`api` 是最小正常跨包消费者，只引用 glyph 新 API 与已存在 Text/Application/Frame/ColorMode；缺 RichText/Theme 不可能成为此项 RED 的原因。`rich` 单独消费 RichText 前置 API，不能拿其缺失代替 glyph 专用 RED。二者的清单由 SDK1.2 `cjpm init` 生成后追加路径依赖，最终执行真实 binary。

`internal` 在独立临时目录复制真实生产 src/native/build.cj/manifest，加上本目录的同根 package `_test.cj`，再执行正常 `cjpm test`。未公开包内状态、没有环境注入 policy、没有替代投影/宽度/布局实现。生产工厂为 `GlyphRenderPolicy.unicode()/ascii()/mapped(bitmap)`；profile 为原 init 尾追加 `glyphPolicy!`。

`negative` 先正常编译 `api` 正向消费者（包含六字段可读性），exit非0即返回2并报告BLOCKED，绝不编译/计数只读负例。只有正向编译exit0后才构建写入负例；保留原combined fixture，另外逐字段对 `var local = value` 副本赋值，六项必须分别拒绝，任一字段可写即失败。不可变参数自身也会拒绝可写struct字段，因此旧combined fixture单独不能证明字段readonly。缺类型/依赖不会被误计为readonly通过。`api` 正向成功还会实际运行binary。

`internal-conservative` 只在正常生产临时副本加入 `glyph_conservative_test.cj`，运行5个有限内核回归。它不含缺失的Ascii/map/marker/API，单独成功只能证明已存在partial owner的G012兼容，不代替 `internal`、`api` 或完整094。

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
| G012/A003–005 | 实际displayWidth逐scalar独立事实；保留é/e+acute/CJK/单emoji/flag，VS16/ZWJ整簇等宽??；Unicode原样；full/diff同投影、wide/字面??双向静默、旧新各自profile、颜色独立、ambiguousWide与零面积边界 |

预期字符串直接手写在测试中，不从产品输出生成 golden。源文本 `é é 中文 😀 ✈️ 👩‍💻 …` 手算19列；固定 SDK 现有 displayWidth 的独立实算也为19，wide为20。public 的30列行补11空格；PTY的32列行补13空格。内部 Bitmap 手填 ASCII 32–126、é、组合 acute、ZWJ、…、✈、中、文、VS16、FFFD 位；没有复制 Unicode 数据表/算法。

## 真实PTY与原生故障边界

`session/native/glyph_syscall_wrap.c` 只属于测试 executable，使用现 syscall 符号的合法 link-wrap：fstat/isatty/ioctl/malloc/calloc/free/write。生产库不读取 `CJTUI_GLYPH_TEST_*`，不添加公开 hook。实际 fd0/fd1 都是 Linux PTY，只有测试 wrapper 为 fd1 反馈合成具体VT身份/映射；VT查询若误用stdin即失败。其它终端打开/输入/尺寸/恢复走真实 syscall。

正常 map 手写104个 pair：95个可打印ASCII、é/…/中/文/acute/ZWJ/VS16/✈和重复é；entryCount 是 pair 数104，不是去重后103。最大65535 pair仍允许重复。验证一次262140 bytes临时分配、一次capacity65535读取、读取后free；更新/override/snapshot不重探。

| native scenario | diagnostics |
|---|---|
| real PTY（TERM=dumb 或 linux） | unknown/not-concrete-linux-vt，Auto保守Unicode；换TERM不算真实VT；显式Unicode保原文 |
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

## G012刷新、固定文件与执行边界

G012只覆盖旧未知设备Auto透出条款：未知PTY、alias/非具体VT、fstat/VT/KD失败、graphics、not-tty均选conservativeUnicode；diagnostic原事实/errno不变。固定19列原文的设备Auto手写golden为 `é é 中文 😀 ?? ?? …`；显式Unicode仍为原文 `é é 中文 😀 ✈️ 👩‍💻 …`。原Ascii/map/空map/已证VT mapfail及Unicodeoverride全部case保留。离线Auto确定等于Unicode，业务原文不投影。保守marker也必须遵守…narrow1/wide2和0/1/2/3/5列规则，不能误当Ascii。

唯一已存在partial owner是 `src/glyph_render_policy.cj`、`src/terminal_glyph_projection.cj`、`src/terminal_render_profile.cj`，设备默认工厂 `src/terminal_capabilities.cj`；后续094在同一类/helper/profile扩展Ascii/map/marker，不另建第二owner。`src/style/glyph_mode.cj`、`src/terminal_glyph_capabilities.cj`、`native/cjtui_glyphs.c` 是合同未来文件；Application API归 `src/application.cj`、运行缓存归 `src/runtime_session.cj` 和现布局。主包为cjtui，根reexport GlyphMode，包内测试不提升公开性。

本轮独立源 `/workspace/work/glyph-tests-refresh/source`、cache `/workspace/work/glyph-tests-refresh/cache`、完整报告和逐命令UTC/exit/raw/hash `/workspace/work/glyph-tests-refresh/report`。受检BASE的design/hash和最终测试hash见该处 `manifest.json`、`sourcehash.sha256`。原old真实RED原件 `/workspace/work/glyph-tests-evidence/final/{baseline-build,api-red,internal-red,public-final-red,rich-red,session-red,negative-blocked}.log`；原测试与新测试各自固定，保留旧RED而不覆盖。

本轮已观察根build exit0、有限conservative 5/5 exit0；完整api/internal/public/rich/session正常编译各exit1。完整行为未运行，readonly正向gate失败exit2 BLOCKED。各项raw及UTC/exit见上述report的同名log/json；最终版本对应 `api-final-red` 与 `readonly-final-blocked`，实际结果汇总为 `results.md`。外部SDK纯编译控制证实mutable字段+不可变参数exit1、mutable字段+var副本exit0、readonly字段+var副本exit1；控制仅编译、绝未执行，不代表产品readonly通过。

未来094/096执行固定候选：先根 `cjpm build`，再 `tests/glyphs/run.sh api`（完整跨包正向API），然后逐项 `public`、`negative`、`internal`、`rich`、`session` 或上述 `all`；按每项实际exit与日志记录run/blocked。session编译失败时PTY/native断言未执行。真实096 VT与宿主截图/hash/恢复证据仍必需；保守模型相等不是任意字体物理推进证明。

## 明确边界

本增量只测实际投影、policy、marker函数与上下文/缓存接线。没有 TextOverflow 前缀布局断言；不能把 `generatedEllipsis` 函数测试称为“完整 ellipsis 排版通过”。Theme013完成后由085追加先预留三列的实际布局/绘制测试。

允许的 declaration-only 语法隔离若需要，应放仓库外、仅编译不运行、不提交、不计产品GREEN。正式RED来自未补声明的旧产品正常构建和真实消费者/同包测试。test-only固定提交和原始命令/exit/UTC/sourcehash在093交付报告中关联；实现作者不得修改这些冻结预期。
