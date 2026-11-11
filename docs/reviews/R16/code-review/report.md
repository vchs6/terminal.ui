# TASK095 独立固定代码审核

审核结论：**spec PASS（固定代码的本增量范围）；quality PASS；Critical 0 / Important 0 / Minor 0。可交 TASK096 执行。** 这不是 TASK096/097、真实宿主或完整 Linux 验收通过。

受检产品为 `7681999e501ca3a6d019648bca34528e6eaa990c` → `1f67e27358254e9daef637b5c2f5a93707ee7cef`，18 文件，258+/73-，产品提交没有测试修改。以 git archive 建立独立 `/workspace/work/glyph-review/source`，逐字节核对变更文件与提交。合同为正式 G001–G012、A001–A008、AGENTS 11.1/13/14；正式测试为 df21f3def32de39a415d1d8d9845b83514dc2902 加 bfd0715cc342fe7c334bd7ce222cdda9c4fb37d5、dc6fdbfb4003a3151dab21d8de7cf7e54a1598b9。根树 ca565720f4a7c63330ad6e07bf25d1c198da2498 的 24 个 glyph 测试文件均与此 lineage 字节一致，两次修正仅涉及 session fixture 的公开 Observable 访问和持久 serial holder。

未读取产品作者 task-094-report、自评或作者 progress，未与作者交流，未派子代理，未改产品、正式测试、main 或任务状态。只读取交接允许的原始输出、固定源码与正常 CJP。使用 verification-before-completion、receiving-code-review 和 cloud runtime 技能；实际审核模型供应信息不可认证，不以请求的角色标签作为运行模型证明。

## 合同与真实调用链

| 合同 | 核对结果与依据 |
|---|---|
| G001/G004/G011 | `native/cjtui_glyphs.c:16` 只接实际 stdout：isatty → fstat → S_ISCHR/major 4/minor 1..63 → VT_GETMODE/KDGETMODE/KD_TEXT。别名和未确证身份均停在 unknown，不读 unimap。没有打开第二 VT、font write、VCS、DSR 或全局字体缓存。 |
| 有界读取与生命周期 | 确证文本 VT 后一次 malloc(65535 × sizeof unipair)，该 Linux ABI 为 262140 字节；一次 GIO_UNIMAP，entry_ct 为 unsigned short，不能越过分配容量；unicode 同为 u16，bitmap 索引最多 8191。核对 entries 指针后才遍历；成功、map-query-failed、map-invalid 均 free。重复 pair 保留原计数，空 map 合法。分配失败 errno 不外泄为 syscall errno；实际 syscall 错误先保存 errno 再 free。 |
| G002/G003 | GlyphMode 三值与 reexport、两个现构造的尾追加参数、默认 Auto、getter/setter 返回语义正确。六项 capabilities 为 public let、构造包内，无 bitmap 暴露。探测在 run 已成功 open 的 try/cleanup 围栏内，显式 Unicode/Ascii 仍探测；headless/render/snapshot 不探测、不覆盖最近事实。基线没有 theme 参数，本次没有删除或抢先实现 Theme085 API。 |
| G005/G010 | 沿已有 GlyphRenderPolicy/projectTerminalGlyph/TerminalRenderProfile 扩展；mapped 工厂只接受 8192 字节并防御复制。单 BMP、可打印、单 scalar、存储宽度 1、唯一 displayWidth==1 且 mapped 才放行。Ascii 只放行可打印 ASCII；其它正宽完整簇按已有宽度回退。边框与 Frame.borderClipped 复用 borderGlyphs 数据；专用 ASCII 缺失 → ? → 空格为有限回退。无 NFC、第二宽度表或替代 Frame。 |
| G006/G007 | generatedEllipsis 是真实生产缓存选择调用使用的纯函数。ellipsis narrow=1 才选 …，mapped 还要求该位；ambiguousWide=true 回点串，0/1/2/3+ 列严格预算。Runtime 当前 Frame 只采用 false，调用显式传 false。真实 TextOverflow 前缀布局尚未实施，不计通过。 |
| 离线/缓存 | Application.snapshot 与顶层 render 在入口采用 offlineGlyphPolicy，Auto==Unicode。设备 run 调用 private snapshotWithPolicy，不误走公开默认 Unicode。produce 的 marker 内容加入 cached Frame key；measuredGlyphMarker 保护 measurement，mounted render 也选择 policy。模式切换清 measurement、置 changed、保留节点。当前缓存 key 足以区分本合同 marker 的有效结果，不靠对象身份。 |
| G008/A004 | full/diff 使用同一 projectTerminalRow/encodeTerminalRow；old/new 各自用对应 profile。宽簇回退拆为独立 ASCII 列，因此 中→文、宽簇→字面 ?? 可真零输出；空间 placeholder 也由实际 glyph bytes 编码。颜色仍先走原 projectTerminalStyle，尺寸/零面积早返回和成功提交边界保留。 |
| G009/G012/A003–005 | 默认未知 PTY 选 conservativeUnicode，逐 scalar 从已存宽度预算减去唯一 displayWidth，避免求和溢出；不一致整体回退。显式 Unicode 与离线 Unicode 原样；Ascii 离线仅控制生成策略，业务 Frame/文件数据保持原 Unicode。文档保留映射别名、未知字体、UTF-8 前置、会话内 map 固定和物理推进限制。 |
| Session S008/R10 | `native/cjtui_terminal.c`、session_extension_state、session_encoding、颜色 native 原件与 BASE 不变；新增 probe 不引用 writer/unsafe/emitted/global mode，不清 process unsafe latch。run 原 cleanup、错误聚合、AllocationFailed 重试及成功后提交 baseline 逻辑保留。 |

## 独立反例检查

- **pump 中改变 glyphMode**：run 在 pump 前捕获 requestGlyphMode/policy，frame 仍按该 policy 产生；提交的 baselineGlyphMode 是实际使用的旧请求值。pump 若把配置改为另一个值，下一轮比较仍不等，即便 produce 清 changed 也继续刷新；不会把新配置错误记为旧画面的基线。这是同一安全边界快照，并非丢失更新。未扩大现同步/跨线程约定。
- **mounted render 与 snapshot 交替**：mounted render 更换 measuredGlyphMarker/measurement，snapshot 的 cachedGlyphMarker 独立记录已缓存 Frame。切回旧 cached Frame 可复用；下一次需要重排时 measurement 已被正确失效。不发现错误 policy Frame 复用。
- **map 已含中文/组合成员**：width==2 的中文、两个 scalar 的 e+acute、emoji/VS/ZWJ 仍不能通过单列单 scalar gate。不会把槽位存在当作推进或 shaping 证明。
- **?、边框 fallback 缺失与空 map**：bitmap 先校验专用 fallback，再 ?，最后空格；fallback 字节在 row 中真实逐列写入，非旧硬编码问号。空 map 的空间与字面空间规范化等价，不留下续格。
- **ambiguousWide=true / 最大空轴 / 非 BMP**：沿已有 Cell.width 与 Frame 预算；mapped 非 BMP 不能索引 bitmap；ellipsis true 不塞入一列；full/diff 零面积先返回。没有固定 width<=2 的新限制。
- **只读字段假阳性**：正式 negative.sh 先 build 完整公开 API，再对六字段各用 `var local=value` 赋值。原始 negative.log 有正向 build success，随后六个各自字段 immutable 诊断，最终 PASS；不是仅不可变参数被拒绝。

## 证据复用与独立验证

按 AGENTS 11.1 复用相同内容、依赖、环境和范围的既有 raw；没有为换审核角色重跑冷 SDK 或完整 suite。以下是审核已读取的开发运行证据，不能替代 TASK096 的独立实际宿主执行。

| 原始证据 | 审核可得结论 |
|---|---|
| baseline-build.log / baseline-api.log | 原根 build success；旧 API 实际 missing GlyphMode 编译 RED，保留失败，不抹除。 |
| api.log / negative.log | 正常公开 API build/run PASS；六字段 mutable-local 编译拒绝，在正向 gate 后执行。诊断声明与最终 CJP 的固定文件一致。 |
| public-current.log / rich-current.log | 离线模式、缓存内容相等复用/不同 marker 失效、原文及文件快照、跨 span 组合/ZWJ 保留的原始 PASS。 |
| internal-current.log | 13/13、0 skipped/error/failed；包含严格 mapped/ascii、copy ownership、边框、marker、full/diff/G012/色彩投影。 |
| session-final.log + glyph-session-final | 25 个真实 PTY/合成 syscall 分支；本审核重新读取每个 result code=0、before/after termios 相同、实际 stdout.raw 与 write capture 字节相同。mapped/minor63/65535重复/空map/缺?/缺边框/失败/override/alias 均在列表。它们不是实际 kernel VT。 |
| session-regression.log + session-regression | 36 cases / 0 failures；本审核核 36 个 check.passed 与 termios，并抽核零字节故障原生 trace 的安全后续/重开、恢复。原 writer 文件字节未变，不据此伪造全 830 重跑。原 830/S008 仍是既有验收权威。 |
| runtime-current.log / regression-runtime.log | 公开生命周期/绑定/缓存及 macros、12 个 PTY 恢复/失败分支的原始 PASS，后者报告 failures=0。错误场景 exit=1 是测试期望，不抹为成功退出。 |
| bundle-current.log / package-current.log | 正常 bundle success，日志有 **353 次 warning 文本出现**，不是 lint clean；清包公开消费者 build/run PASS。制品门禁边界见下。 |

独立执行命令及结果（cwd `/workspace`，2026-11-11 UTC；具体核对时间在 evidence-check.json）：

1. `git -C /workspace/work/terminal.ui archive 1f67e27358254e9daef637b5c2f5a93707ee7cef | tar -x -C /workspace/work/glyph-review/source`，exit 0。
2. `source /workspace/work/validation/sdk/cangjie/envsetup.sh && cjc --version && cjpm --version`，exit 0；Compiler/Package Manager 均 1.2.0，x86_64-unknown-linux-gnu。
3. `gcc -std=c11 -Wall -Wextra -Werror -fPIC -O2 -c /workspace/work/glyph-review/source/native/cjtui_glyphs.c -o /workspace/work/glyph-review/glyphs-review.o`，exit 0；这是 native 编译检查，无实际 VT 行为主张。
4. `sha256sum /workspace/work/glyph-implementation/source/target/cjtui-0.0.0.cjp` 与 `tar -xzf ... -C /workspace/work/glyph-review/package`，exit 0。CJP SHA256 为 `66c740eefb3dc4162295df0f23450b25a60d748ad3d2193b5f935cfa66f5408c`。
5. `node /workspace/work/glyph-review/check-evidence.mjs`，最终 exit 0：18 changed source、24 official tests、143 actual CJP regular-file members 全字节匹配固定来源；25 glyph case 与36 Session case raw 复核通过；所读 log 的既有 hash 重新计算核对。

审查脚本首次因交接所列 `/workspace/work/glyph-implementation/artifacts.sha256` 实际不存在而 ENOENT 退出 1，已按真实缺失记入 reviewed-hashes.json，随后独立生成完整所读 raw 的 SHA256。没有以缺失的作者 manifest 作为已验证证据。一次抽读猜测的 `035-fault-set-Direct-0/check.json` 路径不存在，改由枚举真实36目录完成检查；不属产品失败。

143 个 CJP 文件与固定提交逐字节相同，包含新增 native/cjtui_glyphs.c、manifest FFI、源码及公共文档；没有 tests/SDK/cache/本地配置/对象文件。制品中 **没有完整 composition 示例和 benchmarks**，保留为既有未来交付门禁不足，不据正常 bundle 声称整体制品完备。reviewed-hashes.json 存 actual members 每项 hash；源码副本/CJP/ELF/CJO/SDK 不进入本审核 curated artifacts。

## 后续范围

TASK096 必须在最终产品做真正 kernel text VT（可采用真实 QEMU kernel tty1）和实际 GUI host 验证，包含正常 Auto、Unicode/Ascii、原生 map/错误分支准确标注、termios/原始输出/PNG/hash/source/binary/UTC。当前 PTY 即使 TERM=linux 也只是未知 PTY；合成 syscall 或受控 kernel policy 不等于自然权限故障。不得用旧 probe、logical ANSI replay 或模型宽度证明真实视觉。

Theme013 实际 ellipsis 布局、完整041、全部 Linux、M2/full composition/benchmarks 及发布均不在此 PASS 范围。未发现需要在交096前修复的 Critical/Important，既有不足明确留给其原任务，不将它们伪装为本次代码缺陷或已闭合验收。
