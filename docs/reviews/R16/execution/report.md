# TASK096 独立执行报告

结论：**PASS（本次有限执行范围），未发现产品 Critical / Important / Minor。交独立097判断需求验收。** 未改主仓、产品、正式测试或任务状态；未发布。完整041、Linux、M2/fullrelease及Theme013实际ellipsis布局不据此关闭。

## 固定输入与独立性

产品 `1f67e27358254e9daef637b5c2f5a93707ee7cef`，BASE `7681999e501ca3a6d019648bca34528e6eaa990c`；独立detached clone固定root集成 `b3b24f896672336797cec009cfe0cd830a955aa7`。产品区与1f67字节相同。Official093为df21f3def32de39a415d1d8d9845b83514dc2902 + bfd0715cc342fe7c334bd7ce222cdda9c4fb37d5 + dc6fdbfb4003a3151dab21d8de7cf7e54a1598b9，24份正式测试与095冻结hash逐项相同。

已读G001–G012/A001–A008、AGENTS11.1/13/14和完整096brief、真实tests/glyphs README、Session152边界。无子代理，无作者报告/progress/自评/工作树读取或沟通。仅按root允许精确读取095列出的纯raw/原件，并核hash；095交接清单更正已记录。实际serving model无法认证。使用cloud runtime、verification-before-completion及设施故障时systematic-debugging；执行记录采用executing-plans的记录原则，未把实施者写产品/派审查代理流程套到本独立固定源执行。

SDK实际cjc/cjpm1.2.0，cjnative x86_64-unknown-linux-gnu；自有cache复制只读seed，既有registry18973，无新relay。UCD17 SHA2066d190…与正式构建核对。每consumer/root忽略配置记录在 [inputs](raw/fixed-inputs-and-binaries.json)；296份依赖文件hash、SDK/runtime/native archives、消费者源码/manifest/binary、完整source/test inventory均保留。root与解包产品tracked/shipped源码检查均无修改；本报告不是源码审核的替代。

## 正常构建、测试与制品

逐命令精确command/cwd/start/end UTC/actualexit在 `raw/<label>/meta.json`，stdout/stderr并列；入口工具为 `tools/run.py`。正常构建均未跳build.cj/native脚本。

| 独立新执行 | 实际结果/原件 |
|---|---|
| 根cjpm build | exit0，raw/root-build |
| glyph api/public/rich | 正常build后直接binary，均exit0；raw/glyph-api、glyph-public、glyph-rich |
| readonly | 正向API正常编译后，原combined+六mutable-local逐字段均因immutable拒绝；整个检查exit0，raw/glyph-negative。非missingAPI假阳性。 |
| internal | 正常生产临时副本+cjpm test，13/13，0skip/error/failed，exit0；raw/glyph-internal |
| session/native | 正常consumer build+25实际PTY/合成syscall场景exit0；逐场景真实stdout=write capture、exit0、exact termios。raw/glyph-session。不是实际VT证据。 |
| native-session | owner/setup-signal正常C fixture exit0，raw/native-session |
| 受影响旧回归 | 精确复用095已核同1f67/SDK/依赖/配置/测试scope：36 Session focused原件及runtime/12PTY日志。471个exact-listed raw文件再次重算hash匹配。raw/reuse-verified-manifest.json、scope-and-reuse.json、reused-prior。没有重跑或声称重跑完整830。 |
| cjpm bundle | exit0，正常mandatory lint **353条diagnostic/353 warning文本**，无skip/suppression；raw/bundle、bundle-advisories.json |
| 实际CJP/clean | CJP SHA `af3787677dc9e0aacc318dc49c6df3c3c09fcf2af3b4bb88a352e19ec1a7e670`；143个regular member全部逐字节等于1f67 git blob。干净extract正常rootbuild0；独立正常公开API consumer仅manifest依赖路径变化，build+directbinary0。raw/package-members.json、clean-build、clean-api-build-run；构建后143文件仍原字节。 |
| full bundle checker | 实际exit1：缺examples/composition/cjpm.toml；143member清单也无benchmarks/rendering。保留未来whole-product gate不足，不称fullrelease通过。raw/whole-bundle-check。 |

Formal helper/marker/缓存/投影检查覆盖Ascii/mapped/ConservativeUnicode、真实displayWidth、old/new各profile、等价零输出、边框fallback、只读copy ownership与离线业务Unicode；不是完整TextOverflow布局验收。

## 同一新公开消费者：真实GUI与kernelVT

`host-consumer/src/main.cj` **逐字节等于官方tests/glyphs/session/src/main.cj**，另建正常path manifest，**无syscall wrapper**。普通 `Application(root)` 默认Auto，业务不分终端；仅高级显式mode诊断/切换。binary SHA `a7fb0a3fdea37b8007c98cbde73349662a2a5f787aba7e181496dc8822f58253`。日志中的branch fixtures只用于正式25场景，不进入此普通消费者。

XTerm398与XFCE1.1.4/VTE0.80.1：独占自有Xorg :196，80×25，实际XTEST输入。Monospace/DejaVu Sans Mono12配置；fontconfig样本来源Noto Sans CJK JP/DejaVu Sans/DejaVu Sans Mono及文件hash在raw/font-*.json/log，不能推为任意font覆盖。九阶段initial→ZWJ→VS16→literal??→Unicode→Auto→Ascii→Auto→narrow，各有原PNG/native/profile/actualstdout切片、UTC/window配置。两host均未知具体VT，source=unknown/not-concrete-linux-vt，未读unimap；模式override不改facts。两host的VS16和literal等价变更真实stdout均0，Auto恢复安全G012，BOX原生屏幕锚点保留，narrow清残留。产品exit0、hostexit0、exact termios恢复，Xorg退出0。raw/gui/{xterm,vte}和summary。

XTerm的native print可能将e+acute显示成é；VTE独立GTK观察模块只读实际viewport/widget文本，保留PID/widget/geometry metadata，是插装开发observer，非完整cell属性证明。实际stdout仍保留合同业务原文。两真实实现不能外推任意模拟器物理推进。

QEMU实际10.0.13 TCG、-cpu max PC/SeaBIOS/VGA/PS2、Linux6.12.107+deb13-amd64，kernel SHA2b2358b37674d2505350528875bb17afae2a36522a9e8a9417eaca65a7da0e08；真实具体 `/dev/tty1` major4/minor1、KD_TEXT、80×25、QMP原始720×400屏幕。无host bind mount/SDK路径；新guest带实际runtime/双loader/libtinfo/linux terminfo闭包。自有observer可只读此私有VM vcsu/vcsa，**产品没有VCS/font/codec写或额外VT打开**。

| 新固定产品实际VT | facts/行为 |
|---|---|
| root Auto（8阶段） | nativeVt=true,mapKnown=true,303pairs,linux-vt-unimap,errno0；mode切换只探一次。映射可保é/直线边框，缺字/宽簇/组合整簇等宽占位；中→文/??及wide→narrow实际native清残留。 |
| ttyowner uid/euid/gid1000普通App Auto | 真正产品运行exit0，非旧mapprobe替代；同303map/facts与Auto屏幕。 |
| root Unicode/Ascii | 都仍探测并保留303map原事实；Unicode raw原文，实际VGA缺字方块明确保留为override限制；Ascii整簇问号和ASCII边框。 |
| root Auto + controlledseccomp denial | 仅自有test launcher拒绝GIO_UNIMAP ioctl，实际EACCES13；nativeVt=true,mapKnown=false,entryCount0,linux-vt-unavailable/map-query-failed，Auto Ascii正常运行。**受控kernel-policy注入，绝非自然权限失败。** |

每场景GIO_UNIMAP均实际stdout fd1、一次/run、capacity65535→实际303或errno；独立只读fontmap在root与ttyowner1000各读303pair，同1212字节，hash a0b62239…；pair数非去重bitmap数，map不证明非BMP/shaping或精准像素。正式PTY fixtures另覆盖分配失败/别名/未知/最大重复map等，native分配失败不是managedOOM。

UTF8前置证据：实际boot cmdline无codec override，sysfsdefault_utf8=1；init/observer/product raw无ESC%G/codec或font变更；显式Unicode场景实际native cells包含é/中/文并对应原VGA PNG。该组合是**本冻结启动链的经验核对**；sysfs默认、IUTF8、keyboard mode、fontmap任一项都不是当前per-console输出编码查询。未偷偷切换模式。

所有7个正常VT轮产品exit0、QEMUexit0、termios有效flags+cc逐字段相等；每run kernel/initrd/source/binary/uid/UTC/QMP/serial/strace/profile/exits各有原件。rootAuto使用修部署权限前archive，其余用仅权限修正archive；每轮result.json写实际archiveSHA，对应旧archive/guest manifest均保留/以hash映射，binary内容相同。没有因纯权限修正冷重跑有效root证据。

## P30：有限Session与当前Glyph组合

同冻结产品的正式148公开consumer正常构建，binary SHA `d05618b0c5ab040fd42cdd6391ca9317ea280b64a40648150f5917dd3868cb18`。其已有native recording seam只记录成功写，选mode0无故障注入，真实stdio绑定tty1。实际Direct `wire` 与 `unknown-title` 两场景，调用copy/title/icon/restore并正常退出；完整results/native/exact wire/all-wire在raw/vt/session-*。**未修改的正式verifyLive oracle重新验证这两份实际kernel数据，exit0**，raw/vt-session-formal-oracle.json。

实际cap clipboard/title/titleStack=Unknown/NoEvidence；copy/title=SentUnconfirmed；icon=Unsupported/NoImageAdapter；unknown restore及cleanup=Unknown/RestoreUnavailable、零恢复输出。wire156bytes、unknown-title6bytes；termios恢复/close0/run.failed=false，实际native EXIT屏幕仍CJTUI_SESSION_READY，原PNG没有base64/title payload泄漏。没有clipboard确认/Applied/RestoreConfirmed声明。

这补充Session152 P30缺少当前kernel组合的**有限普通App证据**，不关闭全部041/输入/resize/错误路径/每route/全宿主矩阵。095/152已有S008计数、unsafe闩、安全pop及R10恢复 authority保留，实际VT本轮无故障并不替代其全故障范围。

## 首次失败、验证和归档

全部首次失败/限制分类见raw/attempts-and-classifications.json：npm默认cache254、GUI/VT过早发键collector、uid1000部署0700导致exec127、后处理把3个日志文件误计case、空pixel-diff bbox helper；原raw/失败、旧archive及manifest保留。它们没有改产品/正式oracle，也不被算作正常产品成功。图像bbox helper当时未建文件stdout，工具原错误在分类metadata中准确转录；后续正确pixel检查通过。

`verify-evidence-attempt2` **261检查exit0**；`vt-session-formal-oracle` exit0；`final-checks` exit0：**21对QMP PPM→PNG RGB完全相同，39张真实PNG，9个正常host run**，hash只在owned host退出后采样，所有本轮正常QEMU/Xorg已reap。亲看XTerminitial、VTEAuto、VT rootAuto/uid1000/Unicode/受控mapfail及Session退出代表原图；不声称肉眼逐张验39图。PNG没有生成/重绘或ANSI渲染；raw PPM/PNG/native/trace都保留。

最终curated目录 `curated-r16-execution`；manifest逐项source→copy/hash，省略的产品源码、SDK、cache、runtime/ELF/CJP/CJO/whole checkout/wholeMD source仅保留输入hash映射，不进入curated；无私钥。报告、findings/scope、原命令和初始FAIL均在其中。最终source/deps/env/消费者/二进制hash与归档核对见raw/fixed-inputs-and-binaries.json、host-artifacts-after-exit.json、source-inventory.json及artifacts.sha256。
