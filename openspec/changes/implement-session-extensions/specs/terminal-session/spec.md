# Spec Delta

## MODIFIED Requirements

### Requirement: Report capabilities separately from operation results
框架 SHALL 分项报告 Supported、Unsupported、Unknown及来源，候选协议、应用声明与实际支持证据分开；终端名称或成功write不能证明效果。操作 MUST 区分Applied、SentUnconfirmed、Unsupported、Unknown、Failed；只有可靠真实效果确认可Applied，本版OSC通道不能产生Applied。Auto无请求不发扩展控制，显式copy/title在Unknown时可按固定Direct候选尝试；明确禁用/无设备零输出。

#### Scenario: Do not equate bytes written with host effect
- **WHEN** 后端完整写出标题或剪贴板控制但没有宿主确认
- **THEN** 返回SentUnconfirmed，能力保持原值，不宣称本地标题或剪贴板已改变，即使显式声明Supported也不能返回Applied

#### Scenario: Report rejected or partial operations
- **WHEN** 功能明确禁用、恢复无安全动作或输出仅部分成功
- **THEN** 分别返回Unsupported、Unknown或Failed及原因；部分输出停止后续设备控制并进入统一清理，不默认继续屏幕刷新

#### Scenario: Ordinary explicit call with unknown host
- **WHEN** 应用在真实TTY显式调用复制或标题，默认Auto没有可信权限证据
- **THEN** 使用固定Direct候选，不要求用户配置；完整发送为SentUnconfirmed且capability仍Unknown，不从TERM白名单升级Supported，不主动探测或读剪贴板

#### Scenario: No optional request and no graphical host
- **WHEN** 核心应用没有发起任何宿主扩展操作，或在无设备headless会话请求合法可选操作
- **THEN** 前者零扩展控制输出，后者返回Unsupported/NoDevice；核心界面不因图形能力缺失失败

### Requirement: Clipboard targets the terminal user's local device
复制 SHALL 通过终端OSC52只写固定CLIPBOARD选择器c；SSH目标为用户本地终端。支持声明不等于确认，Unknown显式请求可尝试且仅完整发送返回SentUnconfirmed。粘贴 SHALL 由终端投递文本事件，MUST 不主动OSC52问号查询、读取剪贴板、运行xclip/wl-copy或shell替代。本版没有可靠Applied确认，剪切默认保留源内容。

#### Scenario: Copy from a remote application
- **WHEN** 用户从真实SSH应用复制合法文本
- **THEN** 仅通过绑定TTY发送固定OSC52，实际目标为本地终端；没有远端clipboard工具或shell子进程，产品返回SentUnconfirmed，真实本地效果由独立宿主夹具验证

#### Scenario: Receive pasted text without querying clipboard
- **WHEN** 用户通过终端粘贴多行文本且终端投递括号粘贴事件
- **THEN** 通过统一输入路径把内容作为粘贴文本交给有效目标，不逐键触发快捷命令，不发送剪贴板读取查询；此输入集成仍是TASK030完整AC的一部分

#### Scenario: Copy channel unavailable
- **WHEN** 请求复制但通道明确不支持或无设备
- **THEN** 返回Unsupported且零输出，其他键盘编辑继续可用；Unknown但有固定Direct候选时显式尝试不能假报Applied

#### Scenario: Clipboard data cannot inject controls
- **WHEN** 复制内容包含中文、多行、NUL、ESC或C1控制标量且为有效UTF8
- **THEN** 原始UTF8完整Base64编码进入固定帧，不透传任何原始payload控制字节，不截断、不规范化、不改变换行

### Requirement: Distinguish title from actual image icon
标题 SHALL 通过固定OSC2设置，支持未知与执行程度分开。标题和title-stack SHALL 分项报告；未知栈不自动push/pop。实际图片图标 MUST 独立报告，本版无adapter返回Unsupported，不能以OSC1图标名称、OSC0或界面内图片替代；标题控制内容必须在零输出前拒绝。

#### Scenario: Set a supported host title
- **WHEN** 应用显式请求合法标题，通道已声明支持或默认Direct候选可尝试
- **THEN** 通过唯一writer发送OSC2；完整发送SentUnconfirmed；不改变icon-name，报告是否能尝试原标题恢复

#### Scenario: Reject unsupported image icon request
- **WHEN** 应用请求设置预算内PNG字节但没有已验证图片图标adapter
- **THEN** Unsupported/NoImageAdapter且零输出，不读取图片路径、不解析PNG、不发OSC1冒充效果

#### Scenario: Reject control sequence injection
- **WHEN** 标题包含U+0000–001F或U+007F–009F任一标量、非法UTF8或超限
- **THEN** Failed并定位首个错误UTF8 byte offset，不push标题栈、不写出部分标题，不静默过滤

#### Scenario: Title support does not imply title stack support
- **WHEN** OSC2可用但栈没有可信证据或高级明确声明
- **THEN** 可以发送标题但恢复状态为Unavailable，禁止自动push/pop或发送猜测的默认标题

### Requirement: Restore only session state that can be restored
退出、取消及可处理异常 SHALL 清理由自身创建的资源；标题仅在完整发出合法保存、拥有scope且输出仍安全时尝试pop。完整保存/恢复无回执仍SentUnconfirmed，不承诺原值已恢复。未知原值 MUST 明确Unavailable，不发送默认标题；失败保留逐项诊断，继续独立termios/信号/资源清理。一个会话最多同时拥有一个title scope。

#### Scenario: Restore saved host state
- **WHEN** 路径明确声明支持title-stack，首次合法标题设置已完整push且之后正常或取消退出
- **THEN** 只pop一次并记录SentUnconfirmed；重复设置不重复push，显式restore后退出不重复pop

#### Scenario: Do not fabricate restoration
- **WHEN** 原标题未知、未保存或恢复写入失败
- **THEN** 报告Unknown/RestoreUnavailable或Failed；其他独立清理继续，不声称宿主回到原状态

#### Scenario: Balance an owned stack scope
- **WHEN** push完整发送而后续set在零字节失败，且通道仍允许安全清理
- **THEN** 在清理中至多一次pop释放本会话创建的scope；save或set部分写入则禁止继续发送pop

#### Scenario: Restore resources after callback and cleanup failure
- **WHEN** 业务回调异常且UI cleanup或title恢复再次失败
- **THEN** 聚合主错误与各cleanup错误，无条件继续native termios/信号/资源恢复；不因可选恢复异常越过既有native关闭围栏

## ADDED Requirements

### Requirement: Bound session extension payloads before output
框架 SHALL 在输出前严格验证UTF8与长度：clipboard最多65,536 UTF8 bytes、title最多1,024 bytes、icon最多1,048,576 bytes，每个完整wire序列含包装最多90,000 bytes。Base64使用RFC4648 padding且无换行；空clipboard明确清空。超限MUST Failed且零输出，不截断、拆复制覆盖或修改payload；数字只表示框架资源上限。

#### Scenario: Byte boundaries include multibyte text
- **WHEN** 文本byte数等于上限或增加一个byte超限，或多字节字符跨边界
- **THEN** 等于上限完整编码；超限零输出Failed/PayloadTooLarge，长度按UTF8 bytes不是字符数/显示列

#### Scenario: Fixed clipboard bytes and no query
- **WHEN** 复制空字符串或任意有效预算内字符串
- **THEN** 分别生成ESC ] 52 ; c ; BEL或ESC ] 52 ; c ; Base64 BEL；永不以问号替代payload或把用户文本放入selector

### Requirement: Serialize optional operations in the existing UI session
框架 SHALL 使用既有Application会话、UI owner和唯一设备writer；同步操作返回一次typed结果，背景通过现有post FIFO提交。MUST 不新增运行时或写入线程；错误context、失效会话、停止前取消均零输出失败。序列与帧输出不交错，操作不强制重绘；排队成功不等于复制完成。

#### Scenario: UI callback and background post
- **WHEN** 当前UI回调直接调用复制，或后台通过有效post提交
- **THEN** 在对应UI turn同步执行并返回结果；后台直接调用失败InvalidContext；post中新post延至下一turn

#### Scenario: Stop and expired owner
- **WHEN** post的owner失效、队列满、或会话在closure执行前停止
- **THEN** 遵循既有拒绝/丢弃语义不输出copy；开始发送后取消不能伪装零副作用，失败短写进入统一故障处理

### Requirement: Fail closed when output parser synchronization is lost
发生部分写入失败时框架 SHALL 返回实际已写wire计数并停止所有后续屏幕/模式/扩展控制。MUST 不凭空用CAN/ST/BEL恢复，静默关闭仍恢复termios/信号/内存并诊断视觉状态未恢复；同进程后续设备open不得清除不安全闩而假装同步。零字节失败及正常关闭保留原有可恢复保证。

#### Scenario: Partial OSC or DCS write
- **WHEN** 在OSC52、标题、push/pop或单层DCS包装任一byte位置发生部分失败
- **THEN** Failed且计数精确，后续无屏幕、title-pop或恢复转义；仍运行所有非输出清理；同进程新Application不能绕过输出不安全状态

#### Scenario: Complete write followed by stop
- **WHEN** 全部wire bytes已成功写出后才收到停止请求
- **THEN** 返回SentUnconfirmed而非Cancelled或Applied，安全清理已拥有的scope并保留其确认程度

### Requirement: Multiplexer routes are explicit and bounded
框架 SHALL 只提供Direct、显式单层TmuxPassthrough、显式单层ScreenPassthrough三种固定生成路径；MUST 不根据TERM/TMUX/STY自动包装、修改终端/mux配置或接受任意控制串。高级声明仅表示使用意图，不能证明外层权限或Applied。

#### Scenario: Explicit single layer route
- **WHEN** 应用选择单层tmux或screen高级route发送固定生成操作
- **THEN** 分别按tmux ESC倍写或screen固定DCS包装，包含包装计总长度；内层OSC用BEL，只有固定已验证序列可进入wrapper

#### Scenario: Outer terminal denies clipboard
- **WHEN** tmux接受操作而外层终端拒绝OSC52
- **THEN** 产品仍只报告SentUnconfirmed，不能把pane buffer或tmux成功当用户本地剪贴板Applied

### Requirement: Confirmed copy and matching revision gate destructive cut
编辑剪切消费者 SHALL 仅在copy结果Applied且编辑对象、session、捕获revision和选区身份仍匹配时删除捕获文本；SentUnconfirmed、Unknown、Unsupported、Failed默认保留内容与选区。MUST 不以write成功、测试夹具效果或声明支持生成删除许可。本版OSC无Applied路径，完整cut验收归后续编辑集成。

#### Scenario: Unconfirmed copy retains source text
- **WHEN** 用户触发剪切而OSC52完整发送仅得到SentUnconfirmed
- **THEN** 原文和选区保留，不新增删除撤销记录，可提示已发送未确认

#### Scenario: Revision changes before reliable confirmation
- **WHEN** 未来可确认adapter返回Applied但编辑revision或session/选区身份已变
- **THEN** 不删除任何文本，不对新选区执行迟到剪切
