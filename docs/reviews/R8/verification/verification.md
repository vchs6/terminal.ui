# TASK-053 Linux首片独立验收

结论：**Linux首个有限切片技术交付通过独立验收。** AC-048–052建议登记passed；AC-053的合同/证据核验已通过，最终证据复制与状态登记后的集成检查尚待固定提交，届时补充附录后闭合。没有未解决的本片必需技术缺陷。本结论不代表完整框架、全量Linux能力、其他OS或发行验收通过。

## 固定输入与独立性

验收者角色只核验有限交付合同、固定源码及独立质量证据，不承担测试设计、实现、审核或测试执行。独立`git clone --no-hardlinks`至`/workspace/work/first-slice-acceptance/repo`；初始受检`0aa45e210c96f45ed2c7fdb1f6f982e8d29268a4`，文档/证据修正后受检`14370a107d6e5558e5ec31aea7edd2de9f3c43b3`。实际`git diff --exit-code`证明两者的src/native/build.cj/cjpm.toml/examples/tests/scripts/package锁及CI与已审`2ad6c5ceeb0068d3b2b2d5efe010059965b9415a`相同。原生阶段另有固定`a3032bdd9559c56cf9265f5af5f33c55fe275e41`证据，其覆盖范围单列，不将该旧阶段当全部运行通过。

只读取固定仓库、交接的独立审核和执行产物；未读作者私有目录、自评或过程推理；未改产品、测试或主仓，未提交推送，未派子代理。主仓node_modules仅通过本验收副本中的临时symlink只读复用。技能实际读取：verification-before-completion、cloud-environment-runtime；using-superpowers的被派子代理豁免适用。读取项目现有OpenSpec apply技能，实际status/apply均退出0；ready，六任务pending符合验收前状态。状态登记由协调者执行。

## 有限合同逐项核验

| 合同 | 正式源码与独立证据 | 当前判断 |
|---|---|---|
| 正常Linux源码构建，不使用调查目录 | build.cj pre-build/pre-test调用随附native/build.sh；固定Unicode包/UCD SHA校验，包内缓存、C/GNU工具；cjpm.toml声明本包FFI；docs/product/native-build.md列工具及离线输入。src/native/example无调查绝对路径、Node或Python调用。 | 通过：最终fresh完整入口普通build/check成功，exit0 |
| Unicode薄适配 | src/unicode.cj仅用unicode.GraphemeIterator与unicodewidth.StringWidth，空输入显式空数组；无复制数据表或平行算法。旧原生独立消费者9断言、clean cjp消费者及隔离trace原始记录已核。 | 通过：原生及最终公开消费者实际结果与唯一适配源码一致 |
| Color/Style/Cell/Frame公开签名 | src/frame.cj可逐项对应design Public slice contract：值样式、只读Cell/尺寸、Frame方法。tests/contract通过import cjtui.*消费，无内部API。 | 通过：固定公开消费者及最终完整入口原始结果支持 |
| 宽簇、控制输入、零/负尺寸、极值坐标 | Frame校验完整text后裁剪；覆盖清整簇、零宽簇忽略；CRLF/LF还原原x；控制C0/C1拒绝；尺寸乘积与cx累加防溢出。contract/coordinate-boundary和独立复核记录分别覆盖。 | 通过：固定公开消费者及最终完整入口原始结果支持 |
| 完整快照 | Frame.toPlainText保留列空白、行间LF、无尾LF/ESC；toAnsi由ansies编码SGR/CUP，绝对行位置、不换行滚屏、末尾reset，零面积为空。 | 通过：固定公开消费者及最终完整入口原始结果支持 |
| Text/Row/Column与样式、条件/列表/函数 | src/component.cj统一构造收集、串行Mutex、finally恢复栈；measure/draw经过同一Frame，子属性优先并继承色/粗体；无示例特判。contract含if/for/custom function、嵌套异常后重新构造。 | 通过：固定公开消费者及最终完整入口原始结果支持 |
| 有界键盘与取消 | src/application.cj InputDecoder保留跨poll UTF8状态、未知串常量状态丢弃，Ctrl-C首先处理；公开KeyEvent与onKey符合签名。后续独立RED确证先前UTF8丢失、SOS payload泄漏与取消失败，并保留原始反例。 | 通过：最终PTY事件与取消结果闭合原RED |
| 真实尺寸及终端资源清理 | Application使用cjt_size，resize失效基线；finally调用close；native C拥有平台ABI、原子owner、保存/恢复termios/handlers，non-TTY先拒绝。native-session原C模块回归与真实PTY职责明确。 | 通过：固定公开消费者及最终完整入口原始结果支持 |
| M1差分与失败基线 | Application每轮完整Frame，changesSince含style/宽簇信息；空差分不write，writeScreen完整成功后才赋baseline。失败抛出进入finally，不继续已失同步会话。独立审核E5记录partial/EIO与EINTR短写C注入。 | 支持按合同停止报错；不声称Application整栈故障注入覆盖 |
| minimal用户构造 | examples/minimal源码只用Application/Column/Row/Text、颜色和q停止；无坐标、ANSI或flush；产品说明写q/Ctrl-C及Linux ANSI TTY。 | 通过：实际minimal可执行程序真实PTY正常退出及恢复，非fixture替代 |
| CI和失败传播 | .github/workflows/ci.yml检测src进入product，slice调用check-product.sh→build/check/test→run-slice.sh all；all含native-session/native-smoke/contract/coordinates/integration。消费者先build再直接运行binary，set-e传播非零；PTY异常设置exitCode1。cjpm test零测试结果不作为行为通过依据。 | 通过：完整冷入口至末尾exit0，独立测试消费者直接执行 |
| 源码cjp边界 | 清单包含build.cj/native/src/examples/docs/product/第三方声明，排除开发资料/cache/target/本地repo配置/预编译.a/.o；check-bundle允许必要源输入，保留完整release composition/benchmark门槛。 | 通过：最终源码包37文件边界及clean普通消费者build/直接binary均核到原始证据；完整release仍未通过 |
| 独立审核 | native F049-01修复复核a3032bd双approve；whole初审6发现保留failed，re-review-1/2对应49ed/2f85闭合六项；entry-review在2ad双passed但明确端到端待TASK052。 | 通过：审核链完整，最终cold入口原始exit0闭合入口发现 |
| 状态与剩余范围 | README/product/需求/架构明确首片有限实现、完整REQ仍pending；本片不替代响应式、编辑、滚动、主题配置、覆盖层、M2、全量Linux或其他OS。proposal旧禁止及requirements旧禁止已在14370a1更正并独立核对。 | 通过有限范围核验；最终登记待集成核对 |

## 已核证据与检查

实际命令/退出码/SHA见`commands.json`、`validation.txt`；原始`npm-check.log`在14370a1重新运行通过，仓库检查与OpenSpec strict均0，9项通过/0失败。Bash/Node入口语法检查退出0；这些不能证明产品运行通过。技术内容同一性由git diff实际退出0支持，未以新commit日期代替内容判断。

初始RED四份原始输出已随14370a1入库：red-native-smoke/red-contract/red-integration-build显示真实缺源码/依赖；red-integration-runtime显示真实ENOENT。独立测试交付报告记录各命令退出1；原始log本身未内嵌命令/退出值，故仅将其作为错误输出与报告交叉证据，不虚构附加记录。后续input-boundary/native-session/sos-escape原始RED保留可见失败断言及实际事件/退出数值。当前测试直接二进制入口修复可从固定测试历史核对；产品实现提交未改独立测试断言。

原生执行报告native-report.md/json的12个实际产物已重新计算SHA及大小，全部一致，详见native-artifact-check.json。实际normal build日志exit0；解包消费者只依赖cjtui路径、无手动FFI，输出clusters=4, columns=7。隔离执行取消UCD/proxy变量，strace记录无产品开发目录/缓存/UCD访问；ldd明确仍需仓颉SDK运行库与系统库。原生阶段cjpm run的包装exit0本身不当断言依据，另有直接隔离执行输出与exit0支持。

## 边界

许可按用户最新指令保留真实归属，不重开声明冲突调查或审批。未上传源码包、发行或联系第三方。cjp生成使用skip-test/skip-lint只证明有限源码包与独立消费，不等于完整发行质量门槛。

没有重跑整套native/contract/全部PTY：其独立执行由TASK052完成，验收应检验原始结果、输入同一性和可观察行为。完整Application写故障真实TTY端到端、官方全Unicode conformance新一轮、全部控制协议、线程穷举、性能和全框架仍不被本验收外推为已覆盖。

## 最终独立执行证据交叉核验

已读取TASK052最终slice-report.md、slice-results.json、slice-artifacts.json以及原始日志和原始minimal/快照/trace；未采用协调者或执行者的通过结论代替原始核验。`check-execution.mjs`实际退出0，结果见[execution-evidence-check.json](execution-evidence-check.json)和[原始验收输出](execution-evidence-check.log)。

- 15条执行命令的原始cwd、完整command、UTC起止及最后数值退出码逐一与机器记录一致；其中首次2f85冷入口真实exit1保留，最终2ad fresh入口17:00:26–17:08:55到完整结束提示且exit0。前置日志明确该副本开始时无target/.cjtui-build/两原生归档。新入口只改build-before-check，没有删除真实检查。
- 完整冷入口原始行为包含C owner只允许一个opener且完整恢复、setup SIGTERM后read=-2；公开Frame/Unicode/构造/控制注入/极值断言均到达。134条PASS仅作为输出完整性对照，并非验收理由本身；真正依据为对应输入、精确断言、源码路径和可观察结果。cjpm test零本地用例不承担行为证据。
- 11个真实PTY场景完整出现：q/Ctrl-C/SIGINT/SIGTERM/resize/OSC前缀Ctrl-C/UTF8前缀Ctrl-C/分片UTF8/两SOS正常退出0，回调异常按契约退出1；各记录termios restored。分片UTF8观察恰为text/中与text/q，两个SOS恰为text/q，无payload事件。resize测试设施要求真实8列重新绘制并拒绝长行泄漏，异常要求非零，不以包装exit0掩盖。
- 独立读取minimal-pty.mjs确认启动examples/minimal/target/release/bin/main，wrapper只记录termios、不代应用恢复；原始stdout182字节确实含cjtui/中文/👩‍💻/ANSI，stderr空，application-exit文件为0，wrapper exit0且无signal，before/after原始完整值相同。该示例源及交付包全部文件与最终源码相同。
- 31个最终产物SHA-256与大小全部重新计算匹配；源码包SHA为`2edd4ae9f120db34c0dbcc9e721bc75b1a60d21d3e12fc5fd320b06dc2793fb3`。直接读取tar类型/路径，37文件均为常规源文件/归属材料，无link或生成库/cache/测试开发目录；逐个tar抽取的字节与本验收14370a1副本相同，不只信任执行者reuse布尔值。
- clean消费者清单只有cjtui相对路径，无FFI/link flags；原始普通build和直接binary均exit0，CLUSTERS=4/COLUMNS=7，nm记录包含cjt_open/cjt_close/cjt_buffer_write。plain原始字节精确为3行16列（宽簇续格不重复输出）、保留尾空格、无尾LF/ESC；ANSI独立reset/绝对行定位/结束reset且无LF。
- 隔离复制binary执行取消UCD/代理变量并exit0；重新检查文件trace没有产品checkout/依赖cache/UCD路径，ldd仍显示仓颉运行库及系统库。cache前后清单字节相同，最终immutability原始日志exit0。不能据此推导脱离SDK运行库可运行，也不声称已验证所有设备写故障。

验收设施首次读取机器JSON时误用了字段tests而实际为suite，导致本验收脚本TypeError/exit1；未执行产品或改其源码。保留execution-evidence-check-initial-error.log，修正本地字段读取后完整审计exit0。该记录不属于产品测试失败，亦未隐去。

## 验收登记建议

| AC | 建议状态 | 有限依据 |
|---|---|---|
| AC-048 | passed | 独立冻结合同及真实missing-source/program RED、后续真实故障RED、默认执行入口和退出传播已核。 |
| AC-049 | passed | 正常build hook、公开Unicode、clean source-cjp消费者及无开发目录运行依赖证据；无手动FFI补救。 |
| AC-050 | passed | Frame/样式/组件/M1/Application公开路径、真实PTY和实际minimal已按本片合同对应。 |
| AC-051 | passed | 固定native/whole审核及全部必需发现独立修复复核；入口问题由最终fresh执行闭合。 |
| AC-052 | passed | 独立执行命令、数值退出、原始输出、环境/源码/制品摘要逐一交叉核对。 |
| AC-053 | pending final integration | 首片技术验收通过；协调者复制证据并登记状态后，验收者核对最终提交技术源未变与证据可用，再补附录建议passed。 |

未通过本片外推的完整产品AC保持原pending，完整OpenSpec产品变更不因此归档或声称完成。
