# TASK152 前读：待证据矩阵

本文件仅为只读前读产物，状态 **pending / 未开始正式验收**；不是 TASK152 ready、PASS、FAIL 或最终 insufficient_evidence 裁决。TASK151 正在独立执行，需 root 完整交接固定原始事实后才进入正式判断。不得据本文件改变正式任务状态。

固定产品 `83094ca92acab37ed0a38042e2e40ead55049f41`，集成提交 `5b070e285132c27173cc09d0be9d27abd11fbedb`；正式测试 `f8b95815616c850145b647aae57e082c7915dab0`，集成提交 `11729c23da37395efbb941457a2dc0ce92027051`，测试子树 `4bf3044fb7c3a64d0e918455401f4cf214b26638`。正式 S001–S012、delta、TASK152 完整 brief、tasks、原父任务与 REQ010/009/011、AGENTS11/13/14、仓颉约定、Battle7–8/DQ 已前读。设计文件最后提交为 `d0657194529747da9dd2494f84c2fbbea0e16378`；历史草稿字样不取消 root 冻结合同。

独立150源码报告已有 spec/quality PASS、0 C/I/M；S007测试补充亦已有独立双 PASS。此处仅确认这些输入的存在和边界，不继承为产品运行验收结论。总 `artifacts.sha256` 覆盖主报告和补充，共18个条目，前读重新计算全部匹配；补充没有独立同名 manifest，由总表覆盖。未解引用 reviewed-hashes 中指向149作者目录的原件，本轮没有读取149报告、progress、source工作目录或自评，没有与作者交流。

下表每行当前均 **pending，等待151原件**。正式评估时逐行记录 pass/fail/insufficient_evidence、精确原件路径/hash、适用配置和不能推广的范围；不按测试数量投票。

| ID | REQ / AC / 合同 | 必须检查的事实与预期 | 最小证据及边界 |
|---|---|---|---|
| P01 | AC151/152；来源链 | 固定产品、测试、合同与实际构建内容一致；补充包含47 namespace修复 | commit/tree、实际源码 inventory、依赖/SDK/config、编译命令/cwd/UTC/exit及native/consumer/CJP hash；不能仅读报告SHA |
| P02 | AC149/151；S002/S011 | 正常公共消费者能使用7入口、全部字段/枚举，既有裸None兼容 | 普通CJPM消费者源码与构建原件；实际直接执行binary的exit，不以cjpm包装退出替代 |
| P03 | REQ010.4；S003 | 首次无snapshot、open后mount前建立、关闭后保留、每run新id；跨线程getter安全 | headless与真实TTY public记录、生命周期断言；能力getter不输出 |
| P04 | REQ010.4；S003 | Auto真实TTY为Unknown/NoEvidence；声明仅ExplicitConfiguration；完整发送均SentUnconfirmed | Auto/declared与TERM/TMUX/STY假线索负控；不得出现Applied/RestoreConfirmed/VerifiedAdapter生产结果 |
| P05 | REQ010.1–4；S003 | 无请求不发可选控制；Disabled/NoDevice合法请求零输出且核心继续 | no-request、headless、逐项policy独立组合的wire+public记录；非法输入优先于disabled |
| P06 | REQ010.1；S004 | copy空串/Unicode/换行/NUL/ESC/C1保持原始UTF8，仅进入RFC4648数据 | 手写golden、全部三路由实际wire、标准padding/无换行；固定selection c/BEL、无问号查询 |
| P07 | REQ010.1/2/3；S004 | copy65535/65536/65537、title1023/1024/1025、icon1048575/1048576/1048577及多字节预算 | 对应public记录与零输出拒绝；上限是资源策略，不能推定宿主都接收大payload |
| P08 | REQ010.2/4；S004 | 非法UTF8及全部C0/DEL/C1 title拒绝，首个byte offset准确，拒绝前不push | malformed与65标量测试原件、全部wire；不规范化、不静默过滤、不泄漏payload诊断 |
| P09 | REQ010.3；S003/004 | icon预算内Unsupported/NoImageAdapter、零输出、不解析PNG、不发OSC0/1 | 公共结果、wire、真实host icon属性前后hash；不能拿icon-name或界面图片代替 |
| P10 | REQ010.4；S004/005 | 三个typed单层route精确包装，wire含wrapper；无自动mux猜测 | Direct87392/tmux87402/screen87396可达最大长度及字节golden；90000/溢出/非法enum不可达分支明确论证，不造私有输入 |
| P11 | REQ010.4；S006 | inactive id=0；后台/跨会话/getter/build/mount/cleanup为InvalidContext零输出 | 公开context矩阵；event/post/batch/owner同步合法；active options修改有生命周期异常 |
| P12 | REQ010.4；S006 | 既有FIFO/4096/cutoff/owner失效/stop丢弃；copy不增加frame | headless/fifo/cancel-before原件，序列与帧不交错；排队成功不作复制完成 |
| P13 | REQ010.4；S006/008 | 首字节前stop为Cancelled；完整写后stop仍SentUnconfirmed；忽略Failed仍结束run并抛首错 | 写入/停止选择器原始日志、结果、native时序和真实exit；不能只以日志时间接近认定竞争正确 |
| P14 | REQ010.2/4；S007 | Unknown stack不push/pop；无scope NoSavedTitle/NotNeeded；修改但未保存RestoreUnavailable | unknown-title/zero-scope wire、public/cleanup结果；不猜默认原标题 |
| P15 | REQ010.2/4；S007 | 一次push、多次set、一次pop；重复restore零字节NoSavedTitle/NotNeeded；显式pop后close空cleanup；随后set建新scope | ledger完整wire/步骤/cleanup原件，正常/stop/异常各自观察 |
| P16 | REQ010.2/4；S007/008 | 完整push+set零字节失败必须安全pop一次；普通后续API仍Cancelled，首错不丢 | f8补充4个受影响配置：Direct/Tmux/Screen offset0及Direct+callbackFail+uiFail；exact save+pop、steps、deep-copy requery、native pop先于close、termios/exit |
| P17 | REQ010.4；S007/008 | save失败不set；save/set任意部分失败绝不pop或恢复控制 | 每route/每不完整byte offset的结果与exact all-wire；result ParserUnsynchronized、step WriteFailed，准确计数含已完成save |
| P18 | REQ004/010.4；S008 | 唯一writer准确Int64计数，0/short/EINTR/EAGAIN/write=0/永久失败分类正确 | native seam/完整公共消费者原件；成功短写累积，失败屏幕不提交baseline；不宣称managed heap/OOM恢复 |
| P19 | REQ004/010.4；S008 | pre-write allocation失败零输出不污染parser/停止健康session，后续可重试 | allocation seam结果、后续屏幕重试及baseline证据；范围仅现有native buffer seam |
| P20 | REQ004/010.4；S008 | 部分故障后所有屏幕/模式/扩展/cleanup全静默，无CAN/SUB/ST/BEL/reset/pop | 全流与all-wire准确失败前缀、停止poll/post；含既有screen writer部分失败，不仅扩展wire |
| P21 | REQ004/011；S008 | unsafe同进程第二Application/open拒绝；零写失败close后可reopen | 同进程原始PID/open日志、公有失败、真实后续字节；进程重启不是恢复证明 |
| P22 | REQ004/011；S007/008；AC020局部 | 正常/取消/输入失败/callback/UI/title/native组合失败仍完成独立清理，主错及附加错不被覆盖 | before/after termios、signal handlers/masks、native close/free/active、public聚合与exit；视觉恢复不可由termios推出 |
| P23 | S012 | 返回steps与cleanup外层/嵌套steps修改不反写ledger或下次结果 | 正常公共消费者实际mutation+requery；public let或外层clone不是充分证据 |
| P24 | REQ010.1/2/4；真实XTerm | XTerm398 default clipboard拒绝、SetSelection正例、title-off独立负例 | 同一新public binary、原始配置/版本/尺寸、local clipboard hex、真实xproperty标题/图标、c/a/b/r阶段PNG/native grid/全流，结果仍SentUnconfirmed |
| P25 | REQ010.2/4；真实VTE | VTE0.80.1默认与dynamic-title各自效果与恢复程度真实 | 新public consumer运行的插装native viewport文本、widget/PID/maps/module hash、原始PNG/xproperty/clipboard/termios；不称完整cell属性，不用host-only recon代替 |
| P26 | REQ010.1/2/4；真实tmux | default、clipboard-on、outer-denied、passthrough off/on分别验证 | tmux3.5a真实配置/socket与外层配置；区分pane_title/buffer和外层caption/CLIPBOARD目标，负例不可被mux成功覆盖 |
| P27 | REQ010.1/2/4；真实screen | screenplain与显式passthrough，标题支持不推导栈恢复 | screen4.09.01实际链路、精确目标属性/CLIPBOARD、title A/B/restored与全部host原件 |
| P28 | REQ010.1；AC030局部；真实SSH | stock ssh -T+remote script PTY运行实际产品，OSC52目标为本地私有终端 | 真实publickey/KEX/exit日志、remoteCommand/TTY/grid、端点产品binary/source hash、本地clipboard与outer全流；仅私有loopback，不推广跨网/-tt/任意客户端 |
| P29 | REQ010.1/4；无query/OS工具 | 产品不调用shell/xclip/wl-copy、不读clipboard、不发OSC52?，host观察工具与产品分离 | 独立150静态证据+151真实process/syscall或等效记录；fixture的script/ssh/X工具不可误归产品依赖 |
| P30 | REQ010/011；有限真实VT | 无图形可选能力不成为核心前提；S008有限资源路径真实 | root交接实际VT产品探针的固定binary/TTY/config/termios/native/exit；不得借host-only/fontmap模拟提升为完整094/AC041 |
| P31 | AC149/151/152；S010 | 无第二writer/runtime/队列/ANSI或Unicode内核/新依赖；每实体单文件 | 复用固定150源码结论与hash有效性，必要疑点才定点源码读；不机械重跑既有suite |
| P32 | AC151/152；交付 | 正常bundle lint/advisory不隐藏、实际clean package源码清单与普通消费者一致 | 精确CJP外部hash/成员清单、正常命令/exit、331等实际advisory重新按交接核定；旧FAIL原文和修正理由保留，full-boundary缺口不消失 |
| P33 | AC152；归档链 | 每条事实原件可定位，最终hash在host/Xorg退出后冻结，代表PNG实际查看并交叉核对 | manifest、命令/cwd/UTC/exit、截图捕获窗口ID、source/config/binary/hash；省略逐项列source/hash/reason；不归档ELF/CJP/CJO/SDK/cache/私钥/整checkout |

每个host profile必须有完整独立expectation来源，不能由观察结果反填expected。正式host oracle通过本身不免除外部属性、clip、PNG、native-grid及来源审核。VTE text并非完整cell表示，是否满足本增量的具体观察项需逐项说明；不能因oracle只检查非空而宣布完整网格/字体验收。

当前明确待交接项：151全部固定原件及最终manifest；S007四配置正式产品事实；新public consumer真实host/SSH效果；unsafe静默/同进程reopen/资源恢复事实；构建包与复用适用性映射。恢复条件是root完成这些事实交接；本角色不自行poll、不启动候选产品或host，不读取作者目录补材料。

| 父范围 | 本增量最多支持的局部结论 | 必须继续pending的独立剩余 |
|---|---|---|
| REQ010.1 / AC030 | copy结果、真实有限host/SSH本地目标、不主动query | 统一输入真正多行括号paste安全、有效编辑目标、标准copy/cut/paste事务 |
| REQ009 / S009 / TASK028 | 无Applied生产路径，SentUnconfirmed不授权删除的API契约 | 编辑对象/revision/选区/session竞态、undo记录、实际cut保留与迟到确认集成 |
| AC004 | 本有限Session API契约及普通公共消费者 | 全部U1–U5、其他公共构造、交互与生命周期契约 |
| AC008 | 唯一writer计数及不可同步时停止/报告、unsafe闩 | 其他已证安全恢复、完整重同步/重绘矩阵；不能削弱旧保证 |
| AC020 | 本Session正常/取消/异常/组合失败的资源围栏 | 完整光标/全部终端模式恢复及其他交互集成 |
| AC041 / REQ011 Linux | 本有限真实宿主/loopback SSH/原生VT资源事实 | raw/input/paste/resize/固定控制台fontmap094与完整native依赖矩阵 |
| M2 / AC023/024 / full Linux | 当前有限bundle与clean consumer | composition、benchmark、checker缺口，M2、完整主题/编辑/滚动/覆盖层、完整发行边界 |
| 跨平台 | 无本轮结论 | Windows/macOS/HarmonyOS各自真实目标证据；不作为当前Linux前置但不能宣称已支持 |

执行约束：只在本独立目录保存准备材料；不编辑main/产品/正式tests/status；不派子代理；实际serving model无法认证。已读取verification-before-completion、requesting-code-review、cloud-environment-runtime；using-superpowers对子代理明确停止。采用其固定输入/证据原则，按root及AGENTS11.1不机械冷跑、不再次派审查代理。云环境status读取仅确认当前附属环境运行，desktop状态unknown不当作host就绪。前读不产生最终report/findings裁决，后续正式评估再生成。
