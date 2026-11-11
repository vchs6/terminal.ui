# TASK097 独立有限 Glyph 验收

**PASS_FINITE_SCOPE；Critical / Important / Minor 均为 0。** 接受固定 TASK093–097 的本轮 Glyph 范围；P30 仅接受实际记录的当前二进制、宿主与正常 Direct 组合。完整041、输入/resize、所有路由和父故障场景、Theme真实ellipsis布局、whole Linux/M2/full release仍未关闭。

33 项独立矩阵结果为：30 项 passed、1 项 P30 passed_finite_subset、1 项接口通过而后续布局 pending、1 项父范围 pending。后两项是明确排除的后续范围，不作为本轮必须通过项冒报。详见 [逐项矩阵](acceptance-matrix.md)、[机器矩阵](acceptance-matrix.json)、[findings](findings.json) 与 [机械投影建议](proposed-integration.json)。本报告不修改主仓任务状态，不自行启动 Theme 工作。

## 冻结合同、版本与独立性

完整097brief、G001–G012、A001–A008、AGENTS11.1/13/14、Session152/P30与父041边界均已前读。旧Unknown→Unicode文字由明确G012/A005覆盖，设备Auto采用conservativeUnicode；没有待用户裁定的冻结合同矛盾。G006仅涉及真实生成marker接口/上下文，不能推导未来TextOverflow布局通过。

- BASE：`7681999e501ca3a6d019648bca34528e6eaa990c`。
- 产品：`1f67e27358254e9daef637b5c2f5a93707ee7cef`；集成root：`b3b24f896672336797cec009cfe0cd830a955aa7`。
- 正式093：`df21f3def32de39a415d1d8d9845b83514dc2902`，加独立测试设施修正 `bfd0715cc342fe7c334bd7ce222cdda9c4fb37d5` / `dc6fdbfb4003a3151dab21d8de7cf7e54a1598b9`。正式测试从固定root取，不使用旧product提交中的测试。
- 096 index SHA256：`9e08fce5eccbb44c4a035a175c828667911cc19ecb157da2824e9920229eab43`；manifest：`a1f9ff4cb1c7804d4e04c8e78c3060c7b1041e06cb9c2eefbb09cf0c3807f597`。

097只读独立095、096原件与允许的正式测试/固定Git对象；没有读取094作者工作树、report、progress或自评，没有作者交流或子代理，没有修改产品/正式tests/main状态，没有运行候选产品。采用固定纯oracle离线重断言及独立原件解析，按AGENTS11.1复用已有效执行，未机械重跑大型suite。实际serving model/effort无法独立认证。

应用了 verification-before-completion、cloud-environment-runtime；仅在自身核验脚本问题时使用systematic-debugging。前读阶段的NOT_ASSESSED及33项pending原字节保留，不能与本最终结果混用。

## 独立核验结果

本轮验证命令均为只读证据核验，见 [命令记录](raw/command-record.json) 与随包脚本。以下结果文件记录脚本实际UTC、断言和失败数；无候选产品冷重跑。

| 核验 | 独立结果 |
|---|---|
| `python3 verify_integrity.py` | exit0：1389份原件/curated副本逐字节一致；1390条index含manifest，1391实际文件含index，无额外文件；206份JSON严格解析；外部25项省略件hash匹配。 |
| 来源与包 | 475份执行源匹配固定root；36外部输入、296依赖文件重新hash。实际CJP143个成员全等product Git blob及clean构建后源码。 |
| `node verify_oracles.mjs` | exit0：25份正式Glyph原件以固定正式常量/golden重新核验；36份聚焦Session故障原件与2份新kernelSession均通过未改`verifyLive`。 |
| `python3 verify_hosts.py` | exit0：7个真实kernel轮次、2个GUI宿主的原trace写/read输入fence、native、profile、termios、UID和退出状态交叉核验；旧/新guest archive文件内容完全一致，仅25项mode修正。 |
| native map / 图像 | 4个真实成功GIO trace的303个返回pair全部等于独立1212byte map；39原PNG hash匹配，21原PPM/PNG解码RGB逐像素一致，10张代表PNG直接视觉检查。 |
| 正式RED lineage | 原正常根build0；API与internal各exit1，原日志hash一致且明确缺产品符号。getter/setter与capture holder修复的独立审核均仅设施语义更正，未改oracle预期。 |

[完整性结果](raw/integrity.json)、[oracle结果](raw/oracle-verification.json)、[宿主结果](raw/host-verification.json)、[map对照](raw/native-map-crosscheck.json)、[视觉记录](raw/visual-inspection.json) 和 [RED原件核验](raw/red-lineage-verification.json) 为本报告直接依据。机械断言数量包含大量逐文件hash检查，不能当作产品单元测试数量。

096正常SDK1.2.0根/API/public/rich构建与直接binary均0；完整API正向后，combined及六个var-local能力字段负例真实拒绝写入。正式internal13/13、0skip/error/failed；Glyph25实际PTY/合成syscall与native owner/setup-signal均0。PTY合成ioctl场景不作为真实VT证据。471份精确许可复用raw已在096复制并重算，097仅从此副本读；36 focused Session重新oracle断言，既有runtime/12PTY结果按固定来源复用，不声称全830新执行。

源码与独立095支持单一policy/bitmap所有权、8192防御复制、有限回退、conservativeUnicode宽度预算、投影列等价diff、同一布局入口、marker内容cache key、setter实际变化与pump前请求基线。中途pump修改和mounted复杂交替的细节由源码与095证明，未虚构新增专门动态case。现有session writer/encoding/color/unicode的对应源字节未被产品改动；新探测不取得第二终端owner。

## 真实宿主与UTF8前置

普通host消费者main与正式093完全相同，无syscall wrapper，默认`Application(root)` Auto。实际binary SHA256为 `a7fb0a3fdea37b8007c98cbde73349662a2a5f787aba7e181496dc8822f58253`。GUI是XTerm398及XFCE1.1.4/VTE0.80.1，实际Xorg `:196`、80×25与已记录字体，各9阶段；实际XTEST按键/p fence、stdout增量、nativeprint或GTK viewport、原图和termios相互对应。VS16/literal阶段真实write零增量；高级模式往返不改变source/caps；窄化后无第二列残留。VTE文本读取不是完整cell属性；XTerm打印可将combining acute显示为合成é。

真实QEMU10.0.13 TCG Linux6.12.107+deb13-amd64、tty1 char4:1/KD_TEXT、80×25、720×400 QMP原图。root Auto八阶段、真正UID/EUID1000 Auto、显式Unicode/Ascii、self-launcher seccomp仅拒绝GIO的Auto共五轮Glyph；另有两轮正式Session。产品及QEMU均正常exit0，各轮termios完整恢复。GIO在实际fd1每run一次，65535容量返回303pair，root与UID1000 observer的1212bytes一致。普通用户真实成功不能被错误描述为自然EACCES；errno13是明确受控注入。

UTF8输出前置只在这条实际启动链成立：bootcmdline无覆写、sysfs默认1、无codec/font修改，再以显式Unicode的native解码é/中/文和原PNG建立经验交叉证据。没有把键盘IUTF8、fontmap或语言环境单独当成输出UTF8证明，也没有声称查询了当前每console编码模式。产品不读vcs、不改font/codec；self-owned VM只读native observer的vcs/vcsu/vcsa合法用于独立观察。显式Unicode图中的缺字方块是当前字体事实，不能反向把字体调到“全绿”。

实际plain及ANSI文件独立保留完整Unicode内容，不受最近设备map/profile污染。Auto未知GUI采用conservativeUnicode，真实VT采用map投影；文件默认/显式Auto仍按Unicode离线语义。真实生成marker的接口已证，但字面ellipsis的单元投影不等于Theme真实截断布局。

## P30有限结论与保留边界

新正式148消费者binary SHA256 `d05618b0c5ab040fd42cdd6391ca9317ea280b64a40648150f5917dd3868cb18`，在当前真实tty1执行Direct、mode0、无故障的`wire`和`unknown-title`，session wire分别156bytes与6bytes。未修改的正式`verifyLive`对两套新native/wire/results原件通过。实际退出native屏幕仅`CJTUI_SESSION_READY`及空格，原PNG相符，未出现OSC payload泄漏，close0、termios及信号恢复成立。

实际copy/title状态是`SentUnconfirmed`，icon是`Unsupported / NoImageAdapter`，未知title恢复是`RestoreUnknown / RestoreUnavailable`。这些结果不表示终端执行成功或恢复已确认。结合上述Glyph实际VT场景，P30可以记录“当前二进制在所列kernel VT有限组合通过”；不能据此关闭完整041、输入/resize、所有Session路由和父级全部错误组合。

正常bundle exit0，353条lint warning按真实日志保留，无关闭lint。实际CJP SHA256 `af3787677dc9e0aacc318dc49c6df3c3c09fcf2af3b4bb88a352e19ec1a7e670`，143成员字节核验和clean公开消费者直接运行通过；whole checker仍exit1，缺composition及benchmark范围，fullrelease仍pending。

096所有原helper失败仍保留：默认npm cache、早到按键、旧0700部署使UID1000 exec127、计数/helper问题、Fontconfig缓存warning和首次seal时序；权限修复仅mode不改binary。097自身三次辅助脚本失败也保留首次脚本/输出：ANSI SGR干扰warning计数、真实PTY没有合成syscall日志、bytes/str比较。修正未变产品、原件、正式oracle或通过预期。一次摘要展示对list调用items的异常只影响工具输出展示。

095 addendum说明root把作者session子树清单路径转述错了；原ENOENT记录保留，实际25场景清单不能解释为全作者树manifest。独立095 code PASS和其原report字节不变，此问题不构成产品缺陷或作者造假。

本结论允许root将固定093–097有限结果机械记录为已接受，再明确准入Theme013/025；Theme085追加控制输入已固定仍不等于真实ellipsis GREEN。097不自行开工Theme，不改父任务为全通过。

## 制品与公共引用

独立095公共记录：`docs/reviews/R16/code-review/`（含handoff-correction）；096公共原件：`docs/reviews/R16/execution/`。详细精确source/config/binary/font/UTC由其manifest/index追溯，并由本轮重算；不复制SDK、ELF、CJP、cache、整源码工作树或作者报告。

本交付为`/workspace/work/glyph-acceptance/curated-r16-acceptance`，包含本报告、findings、33项矩阵、固定hash、校验脚本、实际结果及保留的失败尝试；`artifacts.sha256`覆盖所有归档文件但不自包含。外部输入与未复制大件由[hash manifest](hash-manifest.json)和[reviewed hashes](reviewed-hashes.json)说明。最终seal后不再改文件。
