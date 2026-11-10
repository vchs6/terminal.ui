# TASK152 有限 Session 增量独立验收

**结论：PASS，仅限冻结的 Session 增量及本报告列明的实际配置。** 当前必需证据已齐，无未关闭的产品缺陷或证据缺口。验收过程中发现的真实宿主异常/取消自动标题恢复缺证据，已由151新增三例实际运行并经本角色独立核实关闭。此结论不关闭完整 TASK030、004、008、020、041、M2、完整 Linux 或发行验收。

产品为 `83094ca92acab37ed0a38042e2e40ead55049f41`（root集成 `5b070e285132c27173cc09d0be9d27abd11fbedb`）；正式测试为 `f8b95815616c850145b647aae57e082c7915dab0`（root集成 `11729c23da37395efbb941457a2dc0ce92027051`），测试子树 `4bf3044fb7c3a64d0e918455401f4cf214b26638`。已独立从git对象取得所需源码/正式oracle，未依赖149作者工作目录。

正式 S001–S012、delta、完整152 brief、tasks、REQ010及相关REQ009/011、原030/004/008/020/041范围、AGENTS11/13/14、仓颉约定和Battle/DQ均已读取。历史“草稿”标题未用于取消冻结合同。[逐REQ/AC的33项矩阵](acceptance-matrix.md)列出判定、证据和范围；[机器可读矩阵](acceptance-matrix.json)保留精确原件目录。父任务的剩余范围见下表。

## 固定证据链与复核方法

151最终实际consumer SHA256为 `dc5c0dde2548b9bd9ac74d5a390e82b6a2ee65cdf5777eb6668e2fda74a3677a`。实际CJP外部原件SHA256为 `51ece35ab68c3391f796407d7452decdb89b3f625a7b9a8eb7f468865706a7b2`，不将其复制入验收归档。

151最终封存：

| 原件 | SHA256 |
|---|---|
| report.md | `2a6b9433e43fc7746e7c70502228367d9621841c1b1a077106ea410c898fe34e` |
| manifest.json | `b5e58ba3406dadfe1b6f525485f0f5f2605400957572c970532e268b08aed264` |
| artifacts.sha256 | `71c92113358cb154145d536bfad9f960c9b73a04c0e1cd5693e5ff05342155da` |

独立重新计算上述hash，核对4731个manifest条目的原件与curated副本逐字节相等、4732个artifact条目匹配、curated目录实际4733文件且无额外文件；53个相对Markdown链接可定位。封存时间晚于最后新增Xorg退出。2749个先前已核输入保持原hash，唯一变更为有记录的151 results.json加入补证，未改变此前原始运行证据。初次封存的五份原件仍按原bytes/hash在外部initial目录保留，curated保留准确wrapper/index。[最终封存核验](raw/final-seal-verification.json)记录全部核对范围。主代理已将同一封存原件放入[公共151归档](/workspace/work/terminal.ui/docs/reviews/R18/execution/report.md)，额外archive wrapper不改变原报告。

本角色没有重新构建或运行候选产品、host、suite；以下为对151实际原件的离线重断言与来源检查：

- [语义核验](raw/semantic-verification.json)：297组检查，包含固定源码/test/contract及实际binary、全部278已执行配置、14真实host、资源和进程trace，结果无失败。278通过导入独立git archive的固定f8 oracle重新消费原件；host另用固定字面量和标准Base64核对实际wire、xprop、clip、PNG、native文本及SSH事实，未依赖151摘要判定。
- [生命周期核验](raw/lifecycle-verification.json)：仅追加3个新真实XTerm原件，没有重复已有278/14；检查26bytes完整save+A+B+pop、public结果、原生调用顺序、真实属性、PNG/native-grid、输入事件和资源恢复。
- [实际包核验](raw/package-verification.json)与[clean源码核验](raw/clean-source-verification.json)：读取真实tar内138个regular members，全部等于830 git blob；clean consumer构建后的138份实际源码仍相同。未运行完整发布checker以外的新门禁。
- [advisory计数](raw/bundle-advisory-verification.json)：从正常 `cjpm bundle` 原始stdout重新统计331条warning；没有skip、压低等级或零warning声明。
- [复用链及SSH资源](raw/reuse-and-ssh-resource-verification.json)：95份相关源码与830固定对象匹配，12个已复用原日志hash与独立150记录吻合；不解引用149作者目录。独立150已核真实原件，151再次核hash，本角色按AGENTS11.1复用，不因角色变化冷跑旧回归。两条SSH客户端termios亦逐字节恢复。

亲看8张代表原PNG：XTerm enabled A、VTE dynamic B、tmux allow restored、screen plain B、SSH enabled A，以及补充error owned/after和cancel after。实际画面均为稳定的 `CJTUI_SESSION_READY`，tmux含真实状态条、VTE含原宿主菜单。相同PNG hash符合本场景不重绘画面的行为；标题效果通过同阶段真实xprop验证，不能从画面文字或相同图片推断。64张成功运行原PNG的hash已核，不声称逐张肉眼查看；归档还保留2张失败SSH helper PNG，共66张，失败图不计入成功场景。

## 关键语义判定

能力快照、结果及实际宿主效果保持分离。Auto真实TTY为Unknown/NoEvidence，DeclaredSupported只表达ExplicitConfiguration，所有完整OSC发送仍为SentUnconfirmed。没有证据将其升级为Applied或RestoreConfirmed。无请求、禁用、headless/NoDevice、非法输入均有零输出证据；活动/非活动、owner/getter/mount/cleanup/后台/跨session等上下文、FIFO/4096/cutoff/失效owner由正式公开消费者和固定审查覆盖。对停止先后及序列串行性结合既有唯一writer锁的源码证据与边界运行判断，不以日志时刻冒充全部调度竞争实测。

copy接受有效Unicode及NUL/ESC/C1为Base64数据；title严格拒绝C0/DEL/C1及非法UTF8。UTF8字节预算、首个错误offset、空值和padding等实际结果符合合同。三route最大wire为87392/87402/87396，均小于90000；不可达溢出/非法enum不伪造私有输入。图片预算内返回Unsupported/NoImageAdapter且无OSC1替代，预算外零输出失败；图标属性前后hash相同仅证明本配置未改变，未虚称存在图片adapter。

S007安全scope重点原件038/125/230/277完整push后set零字节失败，all-wire精确为一个save加一个pop，Direct/Tmux/Screen分别14/34/22bytes；277保留首个device错误及callback/UI两项附加错误。cleanup和深层副本重查一致，后续普通copy仍Cancelled；pop先于实际native close。对应部分set的039/126/231仅有save加一个失败前缀，8/18/12bytes，cleanup零字节ParserUnsynchronized、同进程reopen拒绝，没有盲发pop或其他控制。

S008全部正式不完整offset原件重新通过exact all-wire断言；包括旧屏幕writer部分失败。实际计数与native write累加相等，失败后没有继续poll/屏幕/模式/可选输出，零写失败与部分失败的reopen不同。275多失败聚合保留设备ParserUnsynchronized主错和三个附加错；276业务先错保留callback主错并仍完成安全pop。termios、三个signal handler/mask及native close均有实际记录；这不证明视觉模式已恢复。native allocation seam的通过不扩大为仓颉managed heap/OOM可恢复。

独立三route strace原件共15份，只有三次consumer execve，其余clone均为CLONE_THREAD，无产品fork/vfork/其他exec/shell/clipboard工具。空的GUI进程快照未被采用为证明。唯一runtime/writer、无新依赖、每实体文件、S011名称兼容及S012深层副本，复用固定150独立spec/quality双PASS并核源链；未发现与实际原件相冲突的新事实。

## 真实宿主和补证边界

14个profile覆盖XTerm398默认拒绝/SetSelection允许/title禁用，VTE0.80.1静态/dynamic标题，tmux3.5a默认/clipboard-on/outer-denied/passthrough-off/on，screen4.09.01普通/透传及两条真实SSH。允许配置的本地CLIPBOARD原hex等于 `CJTUI_HOST_中😀\nLOCAL`，拒绝配置保留自有seed；结果均不因观察成功变为Applied。VTE dynamic pop后为空，screen普通Unknown栈不pop且B保持，tmux允许路径恢复pane hostname；这些目标和限制没有被混称为通用原标题恢复。

VTE采用插装GTK module从真实TerminalWidget取当前viewport文本，四阶段PID/widget/100×28 metadata与PNG关联。接受其作为本有限Session场景的原生当前文本证据；它不是完整cell颜色、宽字符续单元或字体映射证明。其他host的native print/capture是宿主读取，屏幕未改动阶段还有原PNG/全流交叉支持，不将末阶段native文件描述为每阶段完整cell导出。host-only recon不计入产品运行。

SSH是stock OpenSSH私有loopback `ssh -T` 加远端util-linux script PTY；实际remote TTY/grid、publickey认证、KEX、exit0、远端 `TERM=dumb` 和本地clip正负例均可核查。客户端及远端termios恢复；未读取/复制/哈希私钥。结论不推广到跨网、`-tt`、resize/disconnect、任意SSH客户端或Wayland。

验收发现 `tests/session_extensions/README.md:56` 明确要求异常/取消恢复的真实宿主前后状态，初次278 PTY及14显式r路径不足。经root转交，151用同一consumer在真实XTerm398 Direct声明栈上补 `ledger-close/error/cancel`，未改产品、正式consumer或oracle，也未发r。新增三例all-wire均26bytes、写入顺序7/6/6/7，自动pop一次先于唯一close，前后真实标题相同；error/cancel还实际捕获退出前B。error含UI及native-close返回值注入，主错为callback、extras=2，实际native close仍0，不能称真实tcsetattr失败。正常关闭在单callback完成，无中间B截图；完整wire/native/结果与前后真实属性足以证明此场景，不编造截图。新增3例/8PNG关闭该证据缺口，但不声称每个host都跑过完整异常矩阵。

## 剩余完整范围

| 父范围 | 本次可接受的局部证据 | 仍pending或明确未通过 |
|---|---|---|
| REQ010.1 / TASK030 | 可选copy/标题/图标降级、有限真实host/SSH本地目标、结果真实性 | 统一输入的括号paste与有效目标、paste快捷键隔离，以及编辑cut组合 |
| REQ009 / TASK028 | 当前OSC无Applied，不授予默认删除许可 | 真实编辑revision/选区/session身份/undo、未确认cut保留及迟到确认集成 |
| TASK004 | 有限Session公共接口与正常消费者 | U1–U5及全部其他构造/交互契约 |
| TASK008 | 新OSC失败停止、准确计数、全局unsafe闩 | 其他安全重同步/重绘完整矩阵；不能删除原保证 |
| TASK020 | 本增量正常/取消/异常资源围栏与代表真实host自动标题清理 | 全部光标/终端模式及完整交互组合恢复 |
| TASK041 / 实际kernel VT | headless/NoDevice、真实PTY/GUI/mux/有限SSH | 当前830 kernelVT产品运行未执行；旧6a7b/OSC VT仅历史事实。完整VT、094字体/map、096/097及平台组合仍需后续实际执行 |
| M2 / TASK023/024 / Linux完整交付 | 当前真实包与clean Session消费者 | 完整checker实际exit1：缺composition；benchmark/checker/M2/完整主题编辑滚动覆盖层及全Linux发行仍未闭合 |
| Windows/macOS/HarmonyOS | 无本轮通过结论 | 各自真实目标仍pending，不由Linux局部结果替代 |

对kernel VT的范围裁决来自正式151卡和固定148矩阵：它们明确列XTerm/VTE/tmux/screen/真实SSH及故障资源义务，父映射明确保留完整固定控制台/输入/native依赖范围；没有发现本轮必须新增830 kernelVT运行的条文。因此P30记录当前证据不足并归完整041/094后续，不把它当本有限Session增量已测，也不因root说明而自动提升通过。没有更改原AC或缩减Linux最终目标。

## 独立性、治理与归档

本角色只编辑本独立验收目录；没有修改main、产品、正式tests或状态，没有派子代理，没有与149或测试作者交流，也未读取149报告/progress/source工作目录/自评。实际serving model不可独立认证。using-superpowers对子代理明确停止；实际使用verification-before-completion、requesting-code-review的固定输入/独立审查原则和cloud-environment-runtime；自身核验helper出现格式误解时读取并应用systematic-debugging。依AGENTS11.1复用有效事实，未因技能形式重复运行产品。

自身首版离线helper误要求零写场景也存在wire文件，造成ENOENT；调查正式session_fault.c后确认capture仅正写创建文件。修正为只有native记录零写，或fault-screen无扩展字节时才允许文件缺失，并以all-wire长度等于全部native write计数交叉约束。首版脚本及失败输出保留于raw，不把它描述为产品缺陷。151此前manifest/launcher/SSH loader/canonical输入等设施失败及初次覆盖缺口同样保留，不归零抹除。

DQ复核：有限单一目标、执行型分类、固定输入/需求映射、独立角色边界、可判定AC、父范围/集成归属、具体L4、未知及质量治理均可定位；发现的必需证据不足已实际补足后再裁决，不以计数或预算代替证据。验收结论与root负责的任务状态维护分离。

本目录只归档报告、矩阵、findings、有限核验脚本/raw和hash；本地source副本、实际ELF/CJP/CJO、SDK/cache、整checkout及私钥均不归档。[hash-manifest.json](hash-manifest.json)列外部原件与省略理由，报告与矩阵保留稳定原件路径。复现离线核验脚本需从固定git对象恢复其明确引用的oracle源副本；脚本不启动产品。主代理可据本有限结论集成148–152实际状态，完整父项仍按上表保持待验。
