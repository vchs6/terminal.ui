# TASK084 独立有限 RichText 验收

**最终结论：PASS_FINITE。原 AC009 与 AC081–084 在冻结 RichText 合同及所列 Linux 终端配置内满足验收；0 open Critical / Important / Minor。** R14-T082-001 已修复并独立复审；R14T083001 在新产品的原两宿主配置内 CLOSED_VERIFIED；CRF001 测试设施缺陷经独立复审及新199实际补跑 ADDRESSED_VERIFIED。原034审核FAIL、原91真实GUI FAIL及3138设施历史结果均保留，未改写成历史PASS。

固定产品 `199f00076c1a79cfa6d0be92e7be09366e1a06af` 包含原 `034685dacd76f1450317b0352411ddc4be112136` RichText、`91c22f82adcd2412d9509b9872ff63450ba81af9` decoder修正以及自动设备投影。其产品/native/未改rich示例/正式rich与glyph测试在集成 `b08c92d130f8d066a6db11c9ca1bf4c9af17e3f0` 和后续 `216bb9f35bdf70b621a0d30a4df32fe3c267f90b` 均相同；最终colors测试为 `0d46c35456db148f08bd407825a4fd559467249a`。本次只写 `/workspace/work/rich-text-acceptance`，不改产品、测试、主仓、状态，不派子代理，不读产品作者报告/进度/自评，不与作者交流。请求模型与实际服务模型没有可独立核验绑定，因此不认证实际serving。

这是冻结合同下的执行型独立验收。已实际读取 verification-before-completion；using-superpowers 对 dispatched subagent 明示停止其工作流。依据 AGENTS11.1，共享同代码/依赖/环境/配置/范围的有效证据，新的完整性核查不冒称重跑产品测试。正式契约为前景/背景两颜色和六布尔，共八字段；brief转述笔误已由root修正，未变更正式契约。

## 逐项合同判断

| 范围 | 判断 | 核查依据 |
|---|---|---|
| AC009 typed值与所有权 | PASS | 亲读TextStylePatch/TextSpan/RichText、Batch/Result源码。let字段、构造规范化独立数组及getter clone维持防别名；不声称仓颉Array本身不可变。None/Some(false)/Color.Default区别明确，空span消除、相邻等patch合并，RichText等价不忽略样式。 |
| 全文分簇/严格String | PASS | RichText先拼全文再调用唯一validatePlainText；richTextClusters整篇分簇，用UTF8字节边界选择首scalar样式。跨span CRLF/组合/ZWJ/旗帜不拆。String构造和Frame.put(String)经同一严格路径拒绝控制；未建立第二Unicode内核。 |
| 样式和Frame/组件集成 | PASS | Frame基础Style在span之下；组件逐字段显式patch在span之上，未覆盖的字段保留。布局测量、paint和低层Frame共享canonical簇/宽度/裁剪，正常Cell保留原Unicode和typed Style。原typed/Frame/layout/decorations/composition证据按内容复用，变化设备输出由163/166覆盖。 |
| 常量/getter/可观察绑定 | PASS | String/RichText共用text绑定键，替换释放旧订阅；相同规范值不mark，纯样式变化Style、文字变化Content。正式bindings测试明确覆盖四种替换、UI域、自动刷新、短文本清旧、换行/resize、零新增measure的样式改变及dispose；原083真实运行证据有效。 |
| decoder白名单与安全边界 | PASS | 唯一decoder框定后调用ansies.parseCSIParams；局部映射全成功才更新patch，未知/畸形无部分应用。CUP/ED/EL/DSR等无设备执行。OSC仅BEL/ST，DCS/SOS/PM/APC仅ST；超限持续隔离，内部ESC/CAN/SUB不释放payload。 |
| UTF8/C1/首错/关闭 | PASS | 先累计实际byte预算，CSI合法UTF8 lead即Malformed；同一byte越预算资源优先，后续byte不覆盖首错。继续SDK UTF8校验，continuation不当rawC1；非法/末尾残缺UTF8永久关闭。finish关闭、绝对原输入byte offset、跨块归一化及异常前缀限制符合合同。 |
| 资源边界 | PASS（源审+公共golden） | 默认4096byte/64参数，允许上限1048576/4096，全部CSI含空字段与颜色操作数计数，第四digit即TooLong；实际introducer/终止符也计byte。控制payload不缓存、失败计数饱和、UTF8 pending常数界、本次输出不长期持有。InputTooLarge前增量guard及渐进内存界来自源码审核，未声称执行不可穷举Int64输入。 |
| AC081独立测试 | PASS | 原缺API编译RED真实exit1，syntax-only scratch仅语法证据；手写golden不以另一次decoder输出为oracle。cc556f4e行为RED真实56失败/98新case且旧11组通过。正式tests的来源/哈希和最终原083 source及clean-package两份11+98、0 first-fault失败、直接binary exit0已核。 |
| AC082独立技术审核 | PASS（原审核+限定修正） | 原完整技术diff审核FAIL明确唯一Important R14-T082-001；六行修正的scoped-r1双PASS、0开放问题。亲读修正及正式98回归，没有只因测试成功默认审核成功。199改变的六个设备投影文件由独立165审核与167验收补齐。 |
| AC083独立执行 | PASS_FINITE | [最终scoped报告](/workspace/work/rich-text-execution-scoped/report.md)在原FAIL保留前提下核定199有限PASS；旧范围按source/SDK/deps复用，变化profile/full-diff/实际设备由163/166及修后colors补验。正常构建、check、bundle、清包消费者直接binary与未改示例有真实exit0。 |
| AC084证据及最终metadata | PASS_FINITE | 本角色直接检查正式合同、源码语义、归档/原件/包成员/hash、真实PNG及原raw，并核最后083/167/CRF001链；最终审计1547项无差异，详见raw/final-audit.json。 |

## 真实GUI与包证据

亲自查看原VTE green PNG，第四行缺失AN；亲自查看199 VTE green及XTerm resized-green原PNG，第四行完整，第三行不确定ZWJ整簇投影为等宽`??`。没有用logical grid的旧PASS掩盖实际失败。166实际未改packaged rich示例分别在XTerm398、XFCE1.1.4/VTE0.80.1执行 initial→t→t→100×28到120×34实际resize→t→q；样式delta只定位第3行。独立167另逐像素核24个应用与16个回放row4观察，未重构PNG；本角色核80原PNG与curated副本逐项相同并直接核40完整DSR记录及其raw_hex/offset。

DSR是**独立native回放实际应用捕获字节**，不是仓颉应用内探测。green/red字节与原捕获一致，initial只剥script header；rich前缀位置3;12、delta结束3;100，未再结束4;3。heart VS16相反方向误差由Auto、Basic8、TrueColor实际应用和回放补齐。应用PNG覆盖resize，DSR仅100列initial/green/red。原始捕获UTC、host/version/font/config、源码/二进制、应用/recorder退出和inner/outer termios恢复都有metadata关联；不把有限模型一致推广为任意字体或所有宿主保证，也不声称本轮实跑sun/keycap。

亲自遍历正常CJP `4ee05e203614c81a1a9e4fd6d2dfc4f8c4acb70ea570b6d9a3aba35affbf9fee` 的全部118 regular成员，与固定199 git blob逐字相同，无tests/reviews运行依赖。源码抽取目录321个受控文件均匹配199，另一个verifier生成的__pycache__明确不是受控源码。正常bundle保留315 advisory，不称lint-clean。原083为317条的旧bundle证据没有冒称新计数。

初查原083 manifest 666项和当时166 draft 1376项均完整；082 scoped33项均相同。082原55项中2个未归档配置通过archive-index映射至外部可读原件并核SHA相同，不盲链至缺失副本。原测试设计、回归、审核、执行的原件/归档链已核；本报告未复制原source/SDK/binary，并在reviewed-hashes.json保留准确绝对路径。

## 最终colors依赖与复用

CRF001原3138 exit0不作为最终依据。已读独立scoped-r1：0d46在q前冻结已验证grid、stdio close后检查UTF8/ESC/row/resize终结及style reset，再比较最终grid；五类非法晚到输出拒绝、三类合法close接受。166对不变199二进制新执行26-stop、27-resize及28真实fixture/example，全为exit0；14动作、真实q/close、最终grid和termios证据齐全。八个overlay文件逐个绑定0d46，实际两二进制前后hash保持；synthetic child控制不冒称真实产品termios。

最后收到独立167 PASS_FINITE、原R14T083001 CLOSED_VERIFIED及083 scoped PASS_FINITE后才作本结论。新执行full manifest1478项、167 manifest28项、CRF001 scoped manifest5项及083的19条hash引用均逐项核实；连同最终产品/fixture绑定，audit.py真实exit0，共1547检查0失败。执行full manifest SHA为`ae0dc6befbad005a60bd6507a5ea2e1ddd6f1b1e45428b271658ef1d58b31a05`；167 manifest SHA为`2f873a060dfaae4423291a78d2444b685c6143eec424d2f8b9187ccab15df3f3`。

按AGENTS11.1，没有重复有效suite、build或GUI。六项pre-lint历史回归为仅局部不可变Style构造提升的语义复用，不称exact199重跑。decoder、typed值、绑定、原String和未改示例范围与原083相关内容一致；设备profile/full-diff投影、包和修正colors有新执行，不能由旧证据单独覆盖。

## 状态机械投影建议与未关闭范围

root可在单一权威`openspec/changes/implement-rich-text/tasks.md`将TASK009、082、083、084标完成，保留已完成081；`docs/acceptance.md`将AC009及AC081–084投影为passed（有限；引用本验收及原/最终独立证据）。AC009仅冻结白名单有界ANSI文本输入范围；AC083/084仅所列文本集成和真实宿主范围。本角色没有应用这些修改。

AC010可见覆盖层完整快照、AC008所有失败恢复、完整094/041字形/VT、M2、完整Linux及发布不因此关闭。完整制品checker仍真实exit1，缺composition/benchmark后续交付；原colors08/08b设施失败、physical-old负控及预期runtime故障退出均保留其原含义，不改成所有命令成功。有限RichText验收通过不是全Linux完成。
