# Linux 全阶段源码、公共 API 与语言可行性审计

审计基线：`/workspace/work/terminal.ui`，`31a7017e6bb522e3f4bcabd2f01abe1d81ea2170`；起始 `git status --short` 为空。2026-11-10。本角色只读主仓源码/契约，新增独立语言探针和本报告；没有修改产品/tests、安装工具、重跑全 suite，也没有把作者自评/任务勾选当成证明。

读取范围：AGENTS.md、docs/development/proposal.md、docs/ui-construction.md、docs/architecture.md、docs/requirements.md、docs/theme-config.md、docs/terminal-session.md；src/native、现有 tests/examples/scripts、清单；R5 的探针源码及原始编译/运行日志。下文“现有”由源码/API直接支持；测试源码只用于识别覆盖范围，不表示本角色重新运行通过。

## 1. 审计结论

当前可复用的是静态 Text/Row/Column 构造、受约束布局、结构化样式/Unicode字符簇、单帧绘制、整行差分、Linux raw TTY 生命周期及自动颜色属性映射。它不是可直接增加几个组件就完成的完整 Linux 框架。

最关键的缺口是持久运行节点与生命周期、可观察状态/绑定/调度、声明与命令式操作共享的子序列，以及基于节点的输入域。现有 `Component` 同时承载静态描述和可变样式，`LayoutNode` 每次 render 重建，不能承担稳定身份。必须先冻结这两个边界再实施编辑、菜单、模态和 M2，避免每个组件各自维护一套身份/通知/输入机制。

TASK-002 的宏路线已有 SDK1.2 独立正向证据：类宏、成员宏、生成 getter/setter 观察钩子、表达式保留为闭包可一起编译运行。本探针没有证明完整 ArkUI 源文件语法、自动依赖图、动态协调、负向诊断或产品构建/制品入口。这些应继续冻结和验收，不能据此把 TASK-002 整体标完成，也无需重做已通过的尾随 lambda 探针。

## 2. 已有公共 API 与复用边界

| 能力 | 实际入口/文件 | 可复用事实与限制 |
|---|---|---|
| 组件块/属性链 | src/component.cj:9、192、212、216 | `Text(String): Component`、`Column/Row(() -> Unit): Component`；attach/parents 收集嵌套调用，属性链就地修改并返回同一 Component。只有 kind 0/1/2。 |
| 布局配置 | Component.width/height/widthAuto/heightAuto/minWidth/minHeight/layoutWeight/padding/gap/alignItems/justifyContent/textAlign | 固定/自然/最小尺寸、权重、间距和对齐已有；参数负值和不适用属性抛 IllegalArgumentException。没有百分比、滚动、内容切换节点、结构变更入口。保留已有消费者语义。 |
| 字符装饰 | Component.border/borderColor/shadow、Frame.fillRect/drawBorder/drawShadow | Single/Rounded/Double/Ascii、可控偏移阴影；阴影不参与布局，绘制服从祖先裁剪。可继续复用字符绘制和宽字符覆盖规则。 |
| 样式 | src/style/{color,style,color_mode,border_style}.cj、src/exports.cj | Color含默认/基础/明亮/索引/RGB；Style不可变值含六项布尔文字属性。Component各文本属性是Option，能区分未设置；没有通用三态“未设置/设置/复位”、命名样式或主题。 |
| 字符/网格 | src/text/unicode.cj:7、22；src/cell.cj；src/frame.cj | graphemeClusters、displayWidth；Frame.put、cellAt；Cell公开读grapheme/width/continuation/style，构造非公开。Frame覆盖延续单元会清理完整旧字符。不能直接复制为图层系统。 |
| 完整快照 | Frame.toPlainText()/toAnsi(colorMode!) | 完整当前Frame字符串；纯文本保留列空格/LF、无末尾额外LF；ANSI绝对行位置和SGR reset。没有面向应用的文件保存结果API，当前Frame也不包含不存在的覆盖层。 |
| M1绘制 | src/layout.cj:274 `render(Component,Int64,Int64): Frame` | 每次新Frame、新LayoutNode、递归measure和paint；适合保留为M1正确性参考。布局取整采用整数mulDiv及最大余数，平局声明顺序；不能把差分少输出当M2局部布局。 |
| 交互入口 | src/application.cj:3 | `Application(root[, colorMode!])`、onKey/stop/run、colorMode/colorModeAuto/terminalCapabilities；一个应用级 `(KeyEvent)->Unit` handler。run每轮完整render、readByte(100)，Ctrl-C直接终止。没有节点事件、消费/阻止默认、focus、UI提交入口。 |
| 输入 | src/key_event.cj、src/input_decoder.cj | KeyEvent仅code/text；解码文本Rune、enter/backspace/escape、无参数方向CSI/SS3、interrupt；控制串丢弃。没有修饰键、Tab、Home/End/Delete、语义编辑命令和Paste事件。 |
| 输出适配 | src/ansi_encoding.cj、color_mapping.cj、terminal_render_profile.cj、terminal_capabilities.cj | ansies编码；原始结构化颜色保留，输出时投影；终端检测/来源/reason、保守降级、ncv过滤已有。此能力模型仅颜色属性，不等同宿主剪贴板/标题/图标支持。 |
| Linux后端 | src/terminal_bridge.cj；native/cjtui_terminal.c | stdin/stdout TTY检查、termios保存/raw/恢复、信号保存恢复、winsize、poll、完整write循环、单会话active；write失败抛错退出，不提交失败帧基线。可在此边界补输入批次/唤醒/模式/宿主输出。 |

当前 examples/layout 和 colors 的“动态”仅是业务回调保存 Component 引用并修改样式，run 的整帧轮询碰巧呈现变化；它不证明 state订阅、自动定向失效、动态文本、结构或后台调度。`Component.value`为不可变String，公开没有改文本的方法。

## 3. 状态、身份、动态子序列：必须补的核心

代码证据：component.cj只有全局 `parents: ArrayList<Component>` 和构造互斥锁；Component没有key/父/挂载/订阅/资源/运行id；children不公开；Application.root不可变；LayoutNode只有component/children/测量行缓存，每次render重新创建。

| 缺口 | 必需契约 | 建议文件边界（候选名，不是现有/已冻结API） |
|---|---|---|
| 轻量描述 vs 持久节点 | 描述保留属性计算/子构造规则；运行节点保存身份、当前属性、局部状态、布局和资源。禁止拿LayoutNode重新分配地址当稳定id。 | component.cj保留公开构造兼容；新增 component_description.cj、runtime_node.cj、node_id.cj；layout_node.cj变为运行节点可缓存的布局结果或明确临时度量类型。 |
| 身份/引用 | key范围在父节点内；声明位置+父+显式key定位；重复key拒绝；引用含会话/代际，卸载失效。重排保留同节点局部状态。 | component_key.cj、component_ref.cj、reconciler.cj；所有focus/scroll/overlay只接收有效受控引用。 |
| Observable/Binding | getter登记当前求值依赖，setter只标记失效；binding保存闭包，动态分支重算后替换依赖，卸载取消订阅；普通值不承诺变化。 | observable.cj、binding.cj、subscription.cj；宏只生成接入这些公开运行时能力的代码，不能内建另一套状态内核。 |
| 调度/通知 | 唯一UI执行域；后台post提交；回调期间结构操作排队；批次合并内容/样式/布局/结构失效；关闭后提交明确失败。需要能唤醒poll，不能100ms全树遍历充当定向更新。 | ui_dispatcher.cj、update_batch.cj、invalidation.cj；application.cj拥有循环；native后端补受控唤醒机制。 |
| 条件/列表 | 保存可重新执行的构造规则；key重排、分支卸载清资源；if/for只在首次Column构造执行不合格。 | conditional_content.cj、keyed_content.cj，或同一描述模型的构造函数；通过reconciler提交。 |
| 同序列动态操作 | create/insertBefore或index/move/remove与声明节点同一个children；描述只管理自身归属节点，不清空手工插入项。业务负责数据排序/保留。 | child_sequence.cj、view_mutation.cj；禁止“动态专用容器”替代。 |

冻结时必须明确：同一批内锚点先被移除、非法index、重复key、跨父move、循环祖先关系、卸载后请求、回调递归变更、父卸载与后续排队操作的结果。建议校验完整批次后原子提交结构，失败不出现半次挂载；这是待Battle确认的工程选项，不能误写为已有要求已选定实现。

## 4. 合成、透明Cell与M2

`Cell`只有grapheme/width/continuation/style；`blankCell()`恒为带默认样式空格。Frame构造用blankCell填满；没有透明覆盖tag、copy/composite/resize/clear API。layout.paint对于未设背景选择不写未用区域，能够在同一Frame顺序绘制时保留下层，**这只是绘制操作的no-op，不是可保存/复制的透明单元**。tests/decoration 中“None transparent”“unset empty areas transparent”的断言不能证明first-class透明缓冲存在。

建议保留最终Frame为完整不透明合成目标，另外显式定义绘制层的coverage（透明/不透明Cell，或受控稀疏写入）；这样不改变既有Frame快照默认空格语义。若扩充Cell为三态，必须定义旧cellAt/blank/ANSI序列行为的兼容性。不能用空String、Default背景、width=0或continuation冒充透明。

候选边界：cell.cj维护字符完整关系；paint_layer.cj保存coverage；paint_context.cj提供局部坐标/clip/style的公开受控绘制能力；compositor.cj按栈合成到Frame；frame.cj保留唯一宽字符写入/覆盖规则；layout.cj拆开measure/arrange/paint，避免组件操作全屏Frame。

必须验收上层只覆盖底层宽字符的一半时的整字符清理/留白规则、透明穿透与有样式空格覆盖、负坐标及祖先clip、移动/缩小/关闭旧新范围和阴影、底层状态持续变化。叠层关闭必须重新合成最新底层，不能恢复打开时截图。

M2目前完全缺失：没有dirty树、缓存布局、旧/新paint bounds、局部绘制或成本计数。应在持久节点和绘制context接口冻结后实现；保留现有完整render作M1 oracle，再分别记录布局节点数/绘制单元数/时间/分配/输出字节。颜色只失效paint，尺寸/间距扩展至依赖祖先/相邻节点；resize允许全量。public API不应为M2再变。

## 5. 输入、焦点、编辑、滚动和模态

| 子系统 | 现状与具体缺口 | 文件/接口边界 |
|---|---|---|
| 键盘归一化 | code/text无法表达mods、handled、preventDefault。Tab/Ctrl快捷键多数被 `first < 32` 丢弃；参数CSI被统一丢弃。 | key_event.cj定义稳定键/修饰字段；input_decoder.cj只做有界协议解析；新增 input_event.cj、paste_event.cj、edit_command.cj及协议映射。不要将富文本ANSI解析混进键盘。 |
| 括号粘贴 | 当前CSI200~/201~被消费但不建立paste状态；payload仍按正常text/enter/interrupt解码。示例q等业务快捷键会收到粘贴中的q；Ctrl-C会立即终止。 | 在输入基础阶段补paste模式、跨块聚合/有界限制/取消；native会话负责开启与恢复2004；Paste作为文本事件整体进入编辑目标。此结论由控制流可直接推导，本角色未新增产品测试。 |
| 路由/焦点 | 只有Application.handler；无focusable/disabled、目标/父链、捕获拦截、域或恢复。 | event_router.cj、focus_manager.cj、input_domain.cj；路由使用RuntimeNode parent链；事件消费与阻止默认分开；模态未处理事件也不得落下层app。 |
| 文本编辑 | 无输入组件/模型；现有Text multiline仅按换行分行，无自动wrap/ellipsis/selection/cursor/history。 | text_input.cj、text_area.cj、edit_buffer.cj、selection.cj、edit_history.cj；使用公开graphemeClusters/displayWidth，光标/选区以簇边界，不按UTF8字节或Rune删除。单行Enter提交、多行换行；剪切失败不删选区。 |
| 滚动 | layout只裁剪超界内容，没有scroll offset/extent/viewport/ensureVisible，超界内容不可访问。 | scroll_state.cj、scroll_view.cj与布局viewport变换；默认纵向、表格允许横向、单行编辑内部水平光标视口；滚动状态属于节点，受控ref用于scrollTo/ensureVisible。不能由框架隐藏业务面板。 |
| 覆盖层 | 无host/stack/owner/anchor/modal。边框阴影是普通组件装饰，不能当弹窗。 | overlay_manager.cj、overlay_entry.cj、modal.cj；host决定clip，owner关系关闭附属层；focus restoration保存有效句柄并按存活可交互节点回退；视觉最高层可非交互。 |

顺序约束：先归一化/Paste与运行节点身份，再focus/router；scroll与editable widgets复用同一节点局部状态/输入路由；overlay复用focus域与compositor。不得先在每个菜单/输入框自行抓Application.onKey。

## 6. 全基础组件、样式主题与富文本

现有正式组件仅Text/Row/Column。tests/contract的 `if(frozenCondition())`、普通for和`custom(): Unit`只证明构造时if/for/函数复用；没有动态条件/列表/自定义组件生命周期。基础组件应全部建立在公开描述/状态/事件/绘制context上，不向kind整数不断追加业务特判。

| 首版范围 | 当前 | 建议职责文件 |
|---|---|---|
| 单行/多行文本、富文本、标签 | Text支持String及显式换行；无spans/wrap/truncate/label类型 | text.cj或保持Text工厂在component.cj并移内聚实现；rich_text.cj、text_span.cj、text_layout.cj、label.cj。ANSI富文本适配独立ansi_text_parser.cj，复用ansies适用解析及Style，禁止设备控制透传。 |
| 单行/多行输入 | 不存在 | text_input.cj、text_area.cj，复用第5节编辑模型。 |
| 按钮、单选/复选 | 不存在 | button.cj、radio_button.cj、checkbox.cj；disabled阻止事件；默认局部状态和显式绑定各有单一权威。 |
| 进度条、状态栏 | 不存在；手工Text不等于完成这些契约 | progress_bar.cj、status_bar.cj；数值范围/无效值及窄屏布局冻结；状态栏进入正常布局。 |
| 水平/弹出菜单 | 不存在 | menu_bar.cj、popup_menu.cj、menu_item.cj；键盘导航、跳过disabled、选择/取消、modal域。 |
| 模态窗与分区/内容切换 | Row/Column有分区基础；其余不存在 | modal.cj、split/切换构造按实际公共契约命名；共享overlay/context，普通和模态复用同一用户面板。 |

主题当前没有加载器、预置文件、命名样式、theme版本/状态覆盖；只有继承Style和Component的Option字段。建议补 style_value.cj（未设置/值/复位）、style_patch.cj、named_style.cj、theme.cj、theme_loader.cj、theme_diagnostic.cj、theme_request.cj，并保留现有style/color及color_mapping为唯一投影边界。schema未知字段/引用/类型/重复/版本错误定位；候选解析校验完后UI批次原子替换，失败保留旧主题；请求先后按发起序而不是完成序；无默认文件监听。

配置解析需先验证SDK1.2可用TOML依赖；现有manifest只有ansies/unicode/unicodewidth，没有现成主题解析依赖。四预置dark/light/high-contrast/classic及同一组件展示应用均缺失。逐属性顺序显式>后声明命名样式>主题>默认；每来源disabled>selected>focused>normal；布局/边框/padding不继承；主题不得设定业务选择或显隐。

## 7. 宿主可选能力、会话及交付边界

剪贴板、标题、实际图片图标的源码/API全部缺失；TerminalCapabilities不是它们的能力报告。应新增 host_capability.cj、host_operation_result.cj、clipboard_request.cj、title_request.cj、icon_request.cj（按最终实体名拆一类型一文件）并由同一会话后端提交。能力supported/unsupported/unknown与结果applied/sent_unconfirmed/unsupported/unknown/failed分开。

- clipboard只在显式请求下发送经限长UTF8/Base64编码的OSC52或已验证等效通道；不主动读剪贴板、不执行远端xclip冒充本地；失败/不支持不能先删选区。Paste属于核心输入单独实现。
- 标题经OSC2或已验证通道，拒绝ESC/BEL/C0/C1注入；没有可靠效果确认只报sent_unconfirmed。保存/恢复只在通道有已验证语义时承诺，不能默认恢复某硬编码标题。
- 实际图片图标无可验证宿主适配时返回unsupported/unknown即符合能力边界；不能OSC1名称或终端图片替代；不得为此引入GUI产品后端。

native/cjtui_terminal.c目前只修改termios/信号，不开启备用屏幕/括号粘贴或统一拥有光标模式。新增模式应登记实际开启与可恢复状态，在正常/取消/异常同一路径尽量逐项清理并保留错误。已有write完整循环和Application成功后更新baseline可复用；部分写失败后会退出，不盲目继续绘制，因此没有实现“安全重同步后继续”，也不应声称已实现。进一步可恢复输出需逐真实终端故障证据；安全确认不了就停止符合既定边界。

src/frame.cj的快照字符串可复用；应加从当前合成目标读取的导出入口及文件失败结果，不能拿终端差分作文件。tests/terminals有真实终端运行/PNG/原始记录基础脚本，但本角色未重新运行，不以其存在声称Linux全部验收；固定控制台/SSH/tmux等没有真实环境结果时保留待验。

examples/composition及benchmarks/rendering不存在（benchmarks当前无文件）；scripts/check-product.sh release与check-bundle.mjs明确要求这两个项目，release仍有实质缺口。minimal/layout/colors没有统一--smoke完整组合入口。制品白名单当前只含src/native及产品目录；若正式引入独立宏包，必须把宏源码/清单作为产品纳入bundle检查，验证干净解包宏编译及示例，而非引用开发仓外宏路径。

## 8. TASK-002 语言事实与隔离探针

已用用户指定 `/workspace/work/CangjieSkills/.agents/skills/cangjie-coding/SKILL.md`，所有语言知识查询经其scripts/search_docs.py；没有绕过脚本读知识库。查询主题：宏定义/quote/VarDecl、prop getter setter、观察状态、尾随lambda。活动知识页能提供独立macro package、std.ast解析/生成、属性getter/setter契约；未检索到语言自带可观察状态或ArkUI组件运行时，不能把无搜索结果当“不可能”的证明。

已有R5原始证据可复用：trailing正向、plain_block只返回末表达式、binding初值与显式闭包差异、negative/mutable_capture_negative报错定位。本角色只读这些源码/日志，没有重复执行。主仓src/tests/examples中没有任何自定义宏、@State、Observable/Binding实现。

新增探针目录 `/workspace/work/linux-source-audit/probe/`：

| 文件 | 证明内容 |
|---|---|
| macros.cj | 独立 `macro package audit_macros`；`@Component`解析ClassDecl并追加成员；`@State`解析VarDecl生成私有存储+public mut prop，get/set插入计数钩子；`@Bind(expr)`生成保留表达式的闭包。 |
| main.cj | 原始源码含嵌套`@Component class Counter`、`@State var count: Int64 = 1`，build引用count；先取值再改count并运行binding，断言初值1/新值9、读2次写1次、生成成员可调用。 |
| run.sh、logs/* | 实际cjc/cjpm1.2.0；宏编译/消费者编译、运行退出0、源文件sha256。最终命令：`bash /workspace/work/linux-source-audit/probe/run.sh`。 |

实际直接cjc入口：`cjc --compile-macro macros.cj --output-dir bin`，消费者`cjc main.cj --import-path bin -o bin/main`。SDK1.2拒绝`--compile-macro`与`--output-type`同用，且不允许宏模式指定`-o`文件名；宏是编译期依赖，无需给消费者添加不存在的`-laudit_macros`。这些CLI差异已在最终run.sh纠正；CJPM路径依赖和bundle入口仍需产品集成验证。

运行输出：

```
PASS SDK1.2 nested class/member macros, generated getter/setter observation hooks, expression closure binding
LIMIT hooks are counters only; no dependency graph, scheduler, node identity or product syntax contract
```

判定：优先宏路线有实证基础，无需因“语言事实不明”暂停全部Linux工作。但下一次冻结须给U1–U5/U6–U9真实原始源码，决定State声明位置/业务对象共享方式、自动表达式包装覆盖范围、自定义组件参数/build/return语义、条件列表key写法、源码形式/构建/编辑器限制、错误定位与不支持项。探针没有生成依赖收集器和刷新循环，不能把`@Bind`显式包装作为用户接受全部语法的替代；宏是否能完全承载最终承诺需针对最终语法继续最小验证。

## 9. 建议先冻结的六个接口单元

这是给主代理的边界建议，不是代替OpenSpec/L3准入的实施计划，也没有新增用户范围。公共名字/签名应一次小批次冻结后交给独立测试/实现角色，避免先造所有组件。

| 单元 | 应冻结的输入/输出/不变量 | 可并行关系与验收焦点 |
|---|---|---|
| A 构造语法与运行时协议 | 描述/Binding/State/自定义组件原始源码；typed key/ref；dirty kinds；UI post/batch；统一child sequence及错误。 | 最先完成语言/接口冻结；运行时实现与宏前端可按此接口分工，不能各改签名。验收重排保局部状态、混合插移删、卸载取消、共享状态、后台提交。 |
| B 字符绘制/层合成 | Cell coverage、paint context局部clip、layer→最终Frame、宽字符覆盖、旧新paint bounds。 | A的node/ref类型冻结后可与C并行；Frame和Unicode保留单一路径。验收透明/空格、半宽覆盖、阴影/关闭最新底层、快照含可见层。 |
| C 输入/交互协议 | Key/Paste/EditCommand、路由消费与preventDefault、focus/ref/input domain、scroll viewport、受控/默认状态。 | 核心协议不等宏完整实现；依赖A身份；overlay组装依赖B+C。验收paste含快捷字符、模态隔离、失效焦点回退、Unicode编辑和滚动可达。 |
| D 样式/主题/组件库 | 三态属性patch、状态优先、主题原子提交；全部基础组件只使用公开A/B/C接口；富文本ANSI安全入口。 | 主题parser和静态数据可在接口冻结后并行；交互组件等待C，popup/modal等待B+C。验收四主题同一应用及U2/U4/U5无内核特判。 |
| E Linux会话/输出/导出 | 模式登记恢复、poll唤醒、完整/部分写结果、宿主能力/结果、当前Frame导出。 | 与A运行时共享调度接口、与B共享Frame；不依赖后续非Linux平台。复用已有颜色/TTY测试，只增受影响协议/模式/失败验证。 |
| F M2与产品闭环 | 缓存/dirty传播/counters、M1对照；公开composition/smoke/benchmark/bundle入口与真实宿主证据格式。 | M2等待A+B稳定，制品/文档可随各单元更新，最终合并验收必需Linux范围。非Linux留后续；真实环境缺失不能伪通过，publish不在本轮范围。 |

建议交接给测试作者的固定输入是本表外部行为、正式契约与受检SHA，不发送实现者推理或预设通过结论。现有contract/layout/decoration/colors/capabilities/native-session/application-lifecycle适合作回归子集；它们缺失的state/key/lifecycle/透明/编辑/层/主题/M2/组合场景须由独立测试角色按契约补齐，不能只扩展当前静态测试数量。

## 10. 主代理追加问题：自定义类继承/构造挂载与线程安全语言事实

追加仍限定独立language probe，没有实现运行时。源码 `probe/base_library.cj`、`subclass.cj`、`thread.cj`、`base_init_negative.cj`；日志与源hash在probe/logs。最终`bash probe/run.sh`退出0，正向与预期负向均执行。

### 10.1 自动继承、override和State<T>存储：可行

实际通过的调用源码（为区分第一轮探针，宏名暂用AutoComponent/BoxState；其位置与目标@Component/@State一致）：

```cangjie
import audit_macros.*
import auditbase.*

@AutoComponent
class CustomCounter {
    @BoxState var count: Int64 = 7
    public var builds: Int64 = 0
    public func build(): String { builds++; "count=${count}" }
}
```

类宏用ClassDecl修改upperBound/superTypes自动加`<: AuditBase`，找到build的FuncDecl并补`public override`，添加无参init。字段宏把明确类型/初值var转为：

```cangjie
private let _box_count = AuditState<Int64>(7)
public mut prop count: Int64 {
    get() { _box_count.get() }
    set(value) { _box_count.set(value) }
}
```

`@Bind(custom.count)`展开为`{ => custom.count }`。AuditBase、AuditState<T>编译在独立`auditbase`静态库，使用方编译链接后通过，**包含跨package可见性证据**。派生对象构造后builds仍0；经基类引用调用一次build得到count=7；赋值count=9后Binding得到9，builds仍1。证明“custom对象构造一次/后续特定绑定重算”有语言基础；If/ForEach只重建受管理结构的真实运行时仍待实现/验证。

当前产品Component不是open、init不是public、也没有可override的build；需要明确修改其公共继承契约。宏若生成跨package代码，不能调用库私有attach；本探针采用基类protected方法进入内部attach，无须将构造栈或父节点暴露public。生成无参init仅覆盖无用户构造函数/无参数的最小情况；带参数、自定义init、显式superclass/接口、泛型组件和重名成员要继续定义规则，不能盲目重复添加init或覆盖用户继承。

### 10.2 open基类构造函数中attach(this)：SDK1.2明确拒绝

预期负向原始源码`base_init_negative.cj`含：

```cangjie
public open class AuditBase {
    public init() { attach(this) }
    public open func build(): String { "base" }
}
```

实际cjc拒绝：`'this' cannot be used as an expression in the constructor of open class`，定位该行。不能把现Component改open后把attach(this)挪入基类init并假定可编译。

通过的替代最小shape：

```cangjie
public open class AuditBase {
    public init() {}
    protected func finishConstruction(): Unit { attach(this) }
    public open func build(): String { "base" }
}
// 宏在最终派生class中生成：
public init() { super(); finishConstruction() }
```

attach只登记对象，不在基类构造中虚调用build；后续统一构造/挂载阶段再调用build。探针确认派生@State存储已初始化。是否允许用户自定义组件继续继承、如何保证只attach一次和只build一次属于产品生命周期契约，需要runtime guard，而不是依赖编译器替框架保证。

### 10.3 Thread/ThreadLocal/Mutex：SDK1.2实际可用

通过的签名/行为：

- `Thread.currentThread.id: Int64`；spawn子任务和主线程id不同；标准库契约保证所有**存活仓颉线程**id不同，结束后可能复用。
- `ThreadLocal<Int64>()`、`get(): ?Int64`、`set(Some(value))`、`set(None)`；worker初次get为None，worker设置不改父线程值，None移除；实测通过。这是仓颉线程局部变量，不应按OS pthread TLS或固定Linux内核线程id解释。
- `std.sync.Mutex`可重入：同线程lock两次，tryLock第三次为true，unlock三次后正常退出；有活动语言契约和实际运行双重证据。现有constructionLock嵌套没有死锁并非偶然。

没有发现SDK提供终端框架专属“UI线程”类型或自动UI域；框架可在run进入时记录当前仓颉线程id，并用存活会话代际判断owner。不能只保存裸id跨会话永久信任，因为id可能复用；同一id也不自动等于允许在回调中直接修改正在遍历的结构。

语言事实支持的最小安全设计：依赖求值上下文放ThreadLocal，嵌套求值用stack/保存恢复并在finally清理；仅UI执行域开启collector，后台读取State不污染当前UI绑定。State存储/订阅表用Mutex保护；取订阅快照后释放锁，再向UI dispatcher投递失效，禁止持State锁执行业务/绑定回调或等待UI，避免跨锁死锁。节点树/焦点/布局/绘制只由UI loop变更；后台结果通过明确post，订阅卸载和队列项都核对有效代际。后台是否允许直接State.set再自动入队，或必须post内set，需要在对外并发契约中明确选择，不能靠mutex默认为任意线程更新全树安全。

全局constructionLock仅保护构造栈，不是运行时同步机制。若后台也能建描述，应用间不能共享全局parents而错误附着；可将构造上下文改成ThreadLocal并限定挂载到UI提交，但必须保留嵌套/异常清理与同序列操作规则。此为设计建议，未新增正式实现。
