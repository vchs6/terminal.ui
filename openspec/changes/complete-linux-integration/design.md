# Linux收尾契约（候选，非产品通过）

## C001 范围、权威与顺序

用户授权完成Linux全部已约定能力，保留0.0.0、SDK1.2.0、原生仓颉组件块/宏/尾随Lambda、唯一Component/RuntimeNode/LayoutNode/Frame/Style/Unicode/ansies路径。全部函数签名沿各正式design；本变更不造新公共API。开发工具不进入产品依赖。

本变更候选承接原008/010/020/021/023/024的执行细化与001–004/041最终证据汇合；原027仍以implement-theme-styles/tasks.md为状态权威。原030只按152+117+122与真实host/paste/cut汇合，不重开实现链。现阶段不转移原状态、不标ready；独立preflight通过后root机械映射唯一入口。docs/acceptance.md始终唯一AC台账。

顺序：已接受运行时→富文本084→有限Session152→Glyph097→Theme088/092→交互A102/B107/C112→键盘117→编辑122→控件157/162→本变更008/010/020/021及主题027的完整M1交付→冻结M1库/依赖/SDK/native→M2 123–147→最终平台041/源cjp023/完整Linux024。相互无关的只读探针和测试准备可并行，缺上游功能的准备不算完整RED/准入。共享源仅一个产品作者顺序修改。

M1输入与最终矩阵分段按总计划L002/L005：008/020先满足全部M1模式和输出恢复，041已冻结M1设备子接口可供124，不以M2后的完整041反向阻塞124。M2后发生变化补相关恢复与实际终端结果，再关闭完整041/020；其他OS为后续required。

## C002 输出提交与故障（原008）

消费R10围栏、Session S008唯一byte计数/进程期unsafe闩、最终M1帧和caret、模式2004/title。正常相同帧且caret/有效profile相同零屏幕更新；文本变短、样式变化、尺寸/能力变化按唯一后端输出。只有整次输出成功才提交设备成功基线；失败不把目标帧当已显示。

正式故障表由测试作者对当前实际编码序列枚举：写前0字节、CUP/SGR/文本UTF8/恢复控制的每个截断位置、短写后成功、EINTR、0返回、EIO；根输出与可选OSC/DCS共享writer，不另搭通道。短写后继续并成功属于成功，发生致命错误后是否安全仅按实际返回字节与既有正式策略判断。S008要求任何partial+fatal即unsafe，停止后续frame/mode/title/clipboard字节、保留首故障并执行termios/signal/free；同进程再open拒绝，不盲发CAN/ST/SGR宣称恢复。zero+fatal仍终止当前run，但不凭空置partialunsafe；具体重开结果按S008。模拟可确认安全的纯内存后端再present完整帧不得冒充真实TTY恢复能力。

为每个实际支持的恢复路径给出原始字节+完整网格或停止证据；不存在安全同步证据时明确停止和报错，不能为了覆盖“恢复成功”弱化S008。固定源/预算/设备错误、业务异常与cleanup异常同时发生时原primary不被遮蔽；清理至少一次且没有无主native资源。既有R10失败/断言保持，内容未变证据复用，新writer/caret/input必须补相应变化。

## C003 当前可见层快照（原010）

唯一公开入口 Application.snapshot(width:Int64,height:Int64,glyphMode!:GlyphMode=GlyphMode.Unicode):Frame；继续 Frame.toPlainText():String、toAnsi(colorMode!:ColorMode=ColorMode.TrueColor):String、writePlainText(path:String):Unit、writeAnsi(path:String,colorMode!:ColorMode=ColorMode.TrueColor):Unit。旧双参调用继续有效；精确glyphMode参数沿Glyph G002/G007，消费097实际接受源。无另一个screen-export模型。snapshot消费本次稳定提交的主树+层+viewport，整个目标帧不依赖上次设备差分。无设备/headless必须可用，不做flush、不发控制或依赖实际stdout能力。

固定公共consumer建立底层Unicode/RichText、边框/阴影、透明层和有样式空格、嵌套modal/nonmodal、层移动/缩小/关闭、被挡底层新数据及滚动；逐cell/style/宽簇和手工字面网格断言。快照原件保存后新更新不得反改旧Frame。ANSI文件只有完整目标与样式，独立从空网格解析等于目标；纯文本为完整网格且无ESC。Unicode/颜色/字形选择分别沿正式离线策略，不能把设备降级偷偷施于逻辑文件。默认Unicode及离线Auto=Unicode；显式Ascii影响框架生成的ellipsis标记，不转码业务Unicode；边框遵循Glyph正式布局/设备投影契约，不在此新增离线边框转码承诺。正式010须手工核Unicode/Auto/Ascii生成标记及同一业务文本，Frame文件方法不增加glyph参数。路径NUL/目录/不可写/短写错误明确抛出，不承诺未经需求要求的原子文件替换；测试实际SDK错误结果，不能伪成功吞异常。

## C004 全模式和资源恢复（原020）

按同一Application.run覆盖实际终端termios/raw、signal handler、native owner、已管理的原光标显隐、2004括号粘贴、可验证title scope、已知基线及UI资源。正常stop/q、CtrlC未prevent、业务事件异常、getter/draw异常、post异常、EOF/HUP、取消/信号与业务+cleanup双失败均有准确结果/原件；不承诺不可捕获SIGKILL后执行cleanup。光标沿正式I015自动Unknown保留策略，不能假定进入前visible；title未知不可说已恢复；实际图片图标NoImageAdapter不是核心启动失败。

同一进程按允许情况重启验证无残存订阅/post/focus/caret/layer/worker污染；unsafe输出时只允许无终端字节的原生清理且再次open仍拒绝，不能用测试wrapper擦除错误状态。精确termios/handler/进程回收及窗口原图相互印证；截图不能单独证明模式。M1全部功能交付后形成M1恢复输入，M2及release调整影响到的部分补最终验证。

## C005 完整公开应用（原021）

交付 examples/minimal 和 examples/composition 正常CJPM项目，保留其他已接受示例。U1最小 styled Text；U2水平菜单+主体容器+StatusBar+主题；U3真实仓颉后台任务进度/状态、短长内容/颜色自动更新；U4同一自定义组件既用于普通容器又用于弹层、圆角/阴影、弹出菜单及嵌套modal；U5用同一公开primitive构造不同业务例如日志筛选与任务看板，不改内核、不靠坐标/手动flush/私有类型。U1–U5允许由两个项目的明确入口/场景构成，不能五次改名算不同业务。

composition使用真实TextInput/TextArea、Checkbox/Radio/Button/Progress/SplitPane、纵向滚动和菜单/快捷键，业务决定排序/可见/等待状态；宽窄/固定视口和resize按已定规则，focus/选择/业务状态在主题切换与弹层关闭后保留。无Shell/PTY/模拟器/GUI运行依赖。提供普通交互启动和 --smoke 明确有限成功/错误非零退出；smoke只测启动/状态不冒充真实键操作。

评价公开源码入口样板、重复配置、显式坐标、手动刷新、私有API和同组件复用，不设置虚构行数门槛。测试作者先给字面画面/交互预期和独立源码公开性检查，产品作者实现示例/真实缺口，独立审核可以因构造不便或内核特判拒绝，不能只数内置控件。

## C006 四主题完整展示（原027，状态仍在theme）

消费T001–T016四个规范预置主题及021公共组件场景；产品theme配置文件和内嵌preset canonical bytes一致，按公开主题接口选择/主动重载。为每套主题在同一最终场景覆盖文本、输入、按钮、选择、菜单、进度、状态条、分区、弹层/边框/阴影、focused/selected/disabled；同样尺寸/业务内容/操作脚本，只变化主题。至少一真实GUI终端保留四套原PNG+完整网格/样式/版本/源/time/hash，不从ANSI画截图；其他真实终端的自动降级与全功能覆盖按C008完成，不要求相同capability颜色pixel相等。

四套切换不重建已挂节点，不丢编辑选区/undo/焦点/滚动/待处理业务状态；非法文件保持旧主题，主动reload成功后原子整帧可见。普通应用可完整能力声明，不加TERM/终端特判。027实际L4由theme唯一tasks追加，不能在这里建第二复选框。021不依赖027全展示，theme展示消费021，避免循环。

## C007 最终契约和依赖冻结（原001–004/041）

按34个Linux原任务（001–032/037/041）与required细条逐一汇合，extension结果诚实、不把Unsupported当核心失败；Windows/macOS/HarmonyOS只列后续required。冻结受检OS/CPU/ABI、SDK/cjpm、所有直接传递依赖来源/版本/锁定、native Unicode构建和动态链接闭包、普通干净缓存与离线重放可用范围、TTY/非TTY与权限/固定console/模拟器支持配置。未测版本/环境明确边界，不泛称所有Linux均已支持。

002使用原始仓颉组件块/链/@Component/@State/@Bind/If/ForEach/ListItem/尾随Lambda实际CJPM正负例、原始错误定位及编辑器限制，不用声明stub或手工转写后源码替代。004把U1–U5调用逐条映射实际签名/包/错误/状态/布局/事件生命周期。003保留包实际license/归属，不恢复用户否定的许可冲突阻塞。未变证据按AGENTS11.1复用，最终新增stdx/TOML/native前置需公开真实消费说明。

## C008 最终实际宿主矩阵

相同最终公开应用/固定src与测试脚本在XTerm398、XFCE1.1.4/VTE0.80.1、tmux3.5a、screen4.9.1、真实LinuxVT tty1固定80x25、真实OpenSSH连接+远端PTY通路运行（版本以实际执行为准，不编造），记录源码/SDK/依赖/二进制hash、原ANSI bytes、标准输入事件、尺寸、配置/能力来源、UTC/进退结果、精确termios和原PNG。保留现有合法环境探针与限制，不能换TERM冒充不同实现。SSH具体-T+远端script通路已证可用但resize未证，不凭空承诺转发。mux/SSH用可记录的独立自有终端与剪贴板，不读用户剪贴板。

共同核心脚本覆盖初态、键盘编辑/Unicode/emoji、粘贴为数据、菜单禁用/导航、层嵌套/关闭/焦点、滚动、后台进度、尺寸/固定小视口、主题和自动降级、正常退出；异常/取消/short write可由同源受控模式分别执行而非每个host重做全偏移矩阵。GUI/VT截图为实际运行像素；mux/SSH可截图外层真实宿主，须同时记录内层真实进程/版本/config/来源，不伪称独立图形实现。原图不重画，PPM可无损转换附原件。不能从截图推断宿主应用了OSC52/title，沿真实协议结果和拒绝profile证据判断。没有支持的实际图片图标适配仍返回Unsupported。

## C009 完整制品与最终验收（原023/024）

最终正常cjpm bundle不skip已定lint，含src/native构建、README/实际依赖与license、minimal/composition、rich/dynamic等正式已保留公开示例、四主题+showcase、benchmark/rendering compat/workloads与运行说明，源码包不带开发规范/OpenSpec/skills/CI/缓存/凭据/历史checkout/二进制依赖缓存。明确SDK/stdx/TOML/原生工具链前置，所有包内消费者使用相对包路径，无工作区绝对路径。

release checker逐实际项目核存在和内容，不只读manifest include：列包全文件hash、临时新cache正常解包构建，公开示例/benchmark按正式入口直接运行二进制取真exit（不能只cjpm run），检查故意错误非零可检出。tests/开发工具不进入产品包。版本0.0.0，保留name/version占用调查但不publish、不因未发布谎称注册成功。

024独立验收固定最终库/cjp/examples/bench/docs/tests/raw manifest，逐34原AC/required细条/NFR/组合边界判断，审原件/拷贝/hash/元数据/实际exit/fullrelease输出，不重复无变化旧套件。M2含真实局部工作+M1同帧、CPU/分配/输出/负面负载，原143–147独立证据归用；完整release并不是单个bundle或repositorycheck。缺必需功能/证据则不mark总阶段passed，持续补齐。不存在可review的完整来源或未决Important不能出完成结论。root只在024接受后机械投影原AC，direct-main push已授权，不自动publish。
