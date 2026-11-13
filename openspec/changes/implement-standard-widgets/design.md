# 标准控件公共组合设计

## 准入状态 v2 — 2026-11-13

W001–W007/W006-S由主代理按原文冻结，W007成功SDK1.2形状编译与现宏字节一致性已核验复用；独立增量preflight确认实际Runtime/RichText/Theme/Glyph/交互A与完整键盘输入已接受，S153可进入正式测试。154尚等153冻结测试/真实目标RED，M158仍等S157。正文旧“候选/未编译/前置尚未接受”是历史背景，不改冻结签名或预算；准入事实见[输入清单](../../../docs/reviews/widgets/S/input-manifest.json)，并非标准控件产品通过。

**新增签名已有独立SDK shape编译事实；产品 planned，产品验证 pending；执行依赖尚未接受。** 本件消费未来公共合同，不声称 Canvas/focus/viewport/overlay/Theme 已在产品可调用。原独立来源和字节hash归同目录provenance.json（仅历史输入，不是产品通过）。粗输入/workspace/work/widgets-contract/root-decisions.md 是主代理工程建议，不是用户选定签名，正文推荐仍待正式采纳。

## 1. 权威与边界

来源：主仓 AGENTS、整体提案、requirements、architecture、ui-construction、tasks、ENGINEERING_TASK_DECOMPOSITION；Runtime R001–019（最终裁决覆盖早期建议）、RichText 最终合同、Theme 5c150ec 的 T001–016；交互候选 I001–010/A/B/C。Theme T003 实际名字为 **SplitPane** / `split_pane`，没有 ThemeRole.Split。本件不能将较新合同草图当作上游已验收代码。

标准控件全是 `Component` 公共能力组合。Text 根：Label/Button/Checkbox/Radio/MenuItem；Row/Column 根：HorizontalMenu/PopupMenu/StatusBar/SplitPane；Canvas 根：Progress。主题只用 `themeRole/visualStates/styles/setStyle`，不得读私有主题表。不得新增控件 kind、私有 RuntimeNode/ref 内核读写、第二 layout/renderer/theme/Unicode 内核、输出 ANSI/stdout 或另起 Application。每个工厂只向 collector 注册其返回根一次，不能隐建一个同名 wrapper 使链属性落错节点。

TASK-029 原范围是五个小控件；TASK-019 原 AC-019 是菜单导航/选择/取消/禁用与窄屏状态条。分区原属于 REQ-003.1/TASK-011；SplitPane 在 M 同批交付仅因其是 Row/Column 同类容器封装，记录关联父 TASK-011，不能据此新增分区算法、关闭整个 AC-011 或扩写019历史范围。REQ-002.9 的局部焦点由框架管理，checked/radio/data/order 按根建议采用业务受控值；本件不添加第二份 uncontrolled business state。

## 2. W001：推荐精确公开签名与重载

下面全是**未编译仓颉声明草图**。建议根包 `cjtui`；每个 class/struct/enum 独立小写下划线文件。返回 Component，与现有链式属性和原生组件块 collector 共用；只增加列明的重载，没有 Any、String 属性袋或回调解释器。

```cangjie
public func Label(value: String): Component
public func Label(value: () -> String): Component
public func Button(label: String, onClick: () -> Unit): Component
public func Button(label: () -> String, onClick: () -> Unit): Component

public func Checkbox(checked: () -> Bool, onChange: (Bool) -> Unit,
    label!: String = ""): Component
public func Checkbox(checked: () -> Bool, onChange: (Bool) -> Unit,
    label!: () -> String): Component
public func Radio(selected: () -> Bool, onSelect: () -> Unit,
    label!: String = ""): Component
public func Radio(selected: () -> Bool, onSelect: () -> Unit,
    label!: () -> String): Component
public func Progress(fraction: Float64): Component
public func Progress(fraction: () -> Float64): Component

public struct MenuEntry {
    public let key: String
    public let label: String
    public let enabled: Bool
    public init(key: String, label: String, enabled!: Bool = true)
}
public func HorizontalMenu(items: Array<MenuEntry>, onChoose: (String) -> Unit): Component
public func HorizontalMenu(items: () -> Array<MenuEntry>, onChoose: (String) -> Unit): Component
public func PopupMenu(items: Array<MenuEntry>, onChoose: (String) -> Unit): Component
public func PopupMenu(items: () -> Array<MenuEntry>, onChoose: (String) -> Unit): Component
public func StatusBar(body: () -> Unit): Component
public enum SplitAxis { | Horizontal | Vertical }
public func SplitPane(axis!: SplitAxis = SplitAxis.Horizontal,
    body!: () -> Unit): Component
```

常量 Label/Button/Progress/menu 重载只捕获不可变输入或复制数组，与 getter 路径共用实现。Checkbox/Radio 不给 Bool 初值重载：它易被误认成内部可写状态；固定值可显式传 `{ => false }`。label 的 String 默认空，getter 重载无默认，避免省略 label 时两候选歧义。callbacks 必需，不加可选无操作回调或任意返回值协议。callback 保存普通仓颉闭包，不另跟踪它的“值”；业务可在闭包内读自己的最新模型。菜单没有嵌套 business command 类型。

enabled 没有单独构造参数，使用既有未来公共 `.enabled(Bool)` / `.enabled(() -> Bool)` 唯一行为槽；默认 true。焦点默认 Button/Checkbox/Radio/MenuItem 为 true，其他为 false，可通过相同公开 `.focusable` 后写替换。样式/布局继续返回 Component 接受公用链式重载，未列 checked/selected/fraction setter；动态值改变通过 getter 读取模型。重挂载/重排不能私自改 checked/selected。

SplitAxis 是构造时不可变布局选择，不提供 getter；运行时改变轴用公开 If 切换两种构造并遵守卸载代际，不承诺同根换 kind。Horizontal=左右 Row，Vertical=上下 Column，嵌套任意。最终具名axis在前、具名body在最后；W007已由正常SDK和现宏证实SplitPane原始尾随块绑定，不能回用旧body先axis后失败顺序。

## 3. W002：caption、外观与主题

Label/Button/Checkbox/Radio/MenuEntry.label 都是单行 Unicode **逻辑文字**。空字符串合法；先复用 RichText 冻结公开 `validatePlainText`，再拒 LF、CR、U+2028、U+2029；不允许 ESC/其他非法控制、制表符，非法 caption 沿该公共验证的 IllegalArgumentException，getter 抛错沿 Runtime 清理。U+2028/2029 属本层单行约束，不是新增 Unicode 分段器。允许组合符、ZWJ、中文、emoji；宽度/整簇裁剪/ellipsis 只委托统一 Text 路径。这里不加 RichText caption 重载；需要多行/富文本内容时公共 Text/RichText 仍可自由组合。

ASCII 默认皮肤固定：Label/Button 显示 caption 本身，不暗加方括号；Checkbox false `[ ]`、true `[x]`；Radio false `( )`、true `(*)`；非空 label 在三字符标记后恰好一个 ASCII 空格，空 label 只显示标记。Progress 用 `=` 和 `-`，不是 Unicode 图形标记的 fallback-only 模式。业务文本仍是 Unicode；不假定所有文本终端只支持 ASCII，也不添加 glyph 配置 API 或第二宽度表。glyph097仍作为既有全局终端回退集成的前置接受输入。

角色按 Theme T003 原名。Button/Label/Radio/Checkbox/MenuItem 可接受 Text 三项 wrap/overflow/textAlign；默认源沿主题和框架 Text 默认，不为控件写显式 `.wrap(None)` 压住主题。逻辑 caption 不带换行不代表主题/用户 wrap 后必定一行，用户显式宽度和 Grapheme wrap 可增加视觉行数；这是有意保留的主题能力。若要求永远单显示行，就会冲突 T003 能力矩阵，不能暗禁 wrap 或悄悄丢字段。

主代理追加交互A I012作为上游合同：唯一resolver自动合成 `disabled = !effectiveEnabled || declaredVisualStates.disabled`，`focused = nativeFocused || declaredVisualStates.focused`，`selected = declaredVisualStates.selected`；effectiveEnabled为普通祖先合取、跨overlay边界依A/C原约定，nativeFocused仅当前session真实焦点自身。detached render仍有同Runtime的effectiveEnabled，真实focus为false，但可用显式VisualStates模拟展示。外观false不能屏蔽真实disabled/focus；外观true不反写行为，想改变画面用现显式样式逐字段覆盖。

控件因此不调用reference读取enabled/focus来复制外观状态。Checkbox/Radio只将业务checked/selected getter映射到VisualStates.selected，其他控件不额外安装状态读取getter；统一resolver处理disabled/focused，既不读私有节点也不发布detached假ref。disabled优先selected优先focused沿唯一resolver。该I012补充尚须A正式验收，本件不能把消息裁决当已实现。
公共 `.visualStates(...)` 后写会替换控件默认外观 getter，`.defaultAction(...)` 同 phase 后写会替换控件动作；它们遵守同一 Component 契约，不偷偷变成多个隐藏 builtin 槽。用户要附加监听/阻止请用 onKey/onKeyCapture。外观替换不自动禁用；行为依旧由 enabled 决定。用户改变 themeRole 也仅改变样式且受挂载前约束。这些高级覆盖必须在产品文档明示，不声称内置语义能抵抗显式覆写。

## 4. W003：激活、一次请求与可达时序

只有有效域内、enabled、focused 的 Button/Checkbox/Radio/MenuItem 目标执行 Target 默认动作。识别规范 `enter` 或 `text` 且 text恰好一个 ASCII空格且ctrl/alt/shift均false；不发明 `space` code，不接受 paste(" ")、多字符 text("  ") 或鼠标事件。主代理最终裁决S也等待完整decoder117固定接受源，从首次实现即采用完整修饰位条件，不保留早期只code/text的过渡实现。117使用公共Text/Canvas focus fixture，不依赖标准控件，不形成依赖环。

capture→bubble→app/legacy→Target 的顺序沿 A；之前 preventDefault/consume 必须使 callback=0；stopPropagation 单独不阻止 Target。处理键在调用业务 callback **前** preventDefault，防止成功动作向祖先继续；callback抛错仍保留首错并结束session/恢复设备。正常事件只调用业务一次，不用 onKey 和 defaultAction 同时登记。显式 dispatch 到合法但未聚焦目标仍可触发普通用户监听，控件默认激活不执行、不改变焦点；到 disabled/hidden/域外目标由上游既有错误拒绝。

Button 调用 onClick() 一次。Checkbox 在默认执行时读 checked() **一次**，请求 onChange(!value) 一次，不写模型、不乐观切换本地显示；如果应用不写模型，下帧值不变。Radio 读 selected()一次，false时调用 onSelect()一次，true时0次，但两种合法激活键均消费；多个 Radio 通过应用共同 enum/id/Observable模型实现互斥，不按 label、父树扫描或全局 registry 分组。两个相同 caption 不影响业务 key。

事件路径/处理器/挂载身份和有效 enabled 服从 A 的已提交快照；回调中的结构变化在事件边界提交。若前置 onKey 改业务 enabled 或菜单数据，不能假定这个尚未提交修改已改变当前目标资格；要取消当前事件必须 preventDefault。checked/selected 是业务请求值，明确在默认时最新读取，允许先前业务回调改它。这个区分避免为了“立即禁用”引入第二次结构协调/私有强制flush。跨线程持续写入仍受 Runtime turn 截止，不给控件另开竞态协议。

## 5. W004：Progress 有界绘制与依赖

fraction 是 Float64，求值结果必须 finite 且 0<=v<=1；NaN、±Infinity、负数、大于1均在公开输入被求值时抛 UIException("InvalidProperty", ...)，不裁改业务值、不默认0。常量重载同样在绑定/绘制求值路径验证，保证常量/getter失败时机一致；不得在 measure 读取 fraction 只为提前验证。合法 -0 按0处理。

Canvas measure 仅返回 constraints.constrain(Size(20,1)) 的**内容自然尺寸**，装饰/padding由统一布局另加；显式宽高/主题约束可覆盖，实际 allocation可能0。draw才读取并验证 fraction，依赖 P-only；即使 size/clip为空也先验证，不能让非法模型靠零宽逃过诊断。M1可能仍完整measure，测试检查分类/measure读集不包含fraction，而非强制measure计数不增；M2另验缓存性能。

无 viewport 时 w=PaintContext.size.width，为本次分配内容列数。h=0或w=0不写；h>0仅y=0绘制长w的条，其余行不画额外条。满格数 `floor(v*Float64(w))`，计算先确保现有Frame预算内有限w，结果钳制0..w只防浮点边缘舍入；不能用此钳制接纳非法v。前n列`=`后w-n列`-`，一个ASCII字符占一列，n=0和w=1不除零。两段都用同 PaintContext.defaultStyle，不自行着色，不用selected=true冒充“已完成”状态。optional百分比由应用另组合 Label，不强制扩宽或生成timer。

若应用显式给 Progress viewport，沿 Canvas 合同 size 表示有限逻辑content extent，条按该extent画、clip只限制可见部分；不可用clip.width重算导致滚动时进度比例改变。没有必须indeterminate/动画/进度文本API。theme color-only变化只重画，frame更新由公共运行时驱动。

## 6. W005：菜单数据、身份与导航

MenuEntry 是不可变值；key非空，按字节精确相等，不trim、不从label生成key；label沿第3节。构造非法key报 InvalidKey；一批重复key由 ForEach 原子预检报 DuplicateKey，复用Runtime C同一权威，不先部分挂载。不要求Equatable整数组或额外排序接口；getter每轮提供应用指定顺序。常量数组进入构造复制，getter结果使用上游结构快照；没有对子对象业务callback的解释。

HorizontalMenu=Row role HorizontalMenu；PopupMenu=Column role PopupMenu。ForEach(items,key,body)每key恰一个Text root role MenuItem，正文和enabled getter引用保留的 ListItem.value，不闭包捕获首次 MenuEntry。相同key换label/enabled更新同节点，重排保ref/focus；删除后同key重加是新代际。各 enabled item 默认focusable=true，Tab沿框架真实序列进入/离开；不做roving tabstop、不陷Tab、不额外存储selectedIndex。

公开 ref 表仅保存菜单自己创建的entry key→NodeRef并在onMount/cleanup登记/撤销；保存UI实现本地引用不是复制业务状态。导航使用已经提交、有效的这批entry refs按公共 `menuRoot.reference().children()`实际物理顺序过滤，匹配只调用sameNode/isValid/isEnabled/isVisible；不扫描私有树、不解析任意child AST，不按HashMap迭代或label排序。它因此还能正确反映公开同父move；不把源数组排序回写业务。ForEach下次协调仍按C的数据顺序规则，不新增第二协调算法。手动附加的非entry孩子依Runtime仍参与普通Tab与布局，但不被猜作菜单项，也不由菜单箭头导航/回调管理。

菜单容器的 Ancestor 默认只在event.target是自己注册的entry且当前focusedNode等于它时工作；嵌套菜单完成导航后prevent，所以外菜单不再动作。Horizontal left/right循环、Popup up/down循环；Home/End首/尾enabled entry；禁用/hidden/无效ref跳过，普通祖先disabled已由框架屏蔽。在至少一个eligible候选且识别本菜单导航键时消费，只有一个或已到Home首项也消费，防止错误触发祖先viewport滚动；空/全disabled没有候选不消费不调用callback。选择目标需要变化时public requestFocus，边界提交并由公共ensureVisible保持可达，绝不直接写focus。Popup left/right、Horizontal up/down不声明菜单意义，可交公共viewport/祖先。

每项Target按W003 Enter/Space调用 onChoose(item.key) 一次，只发稳定key，不排序、不修改业务entry、不自动写checked、不自动开子菜单。读取的是当前保留的ListItem，前置事件中的未提交数据更改按W003处理；应用preventDefault可取消。默认不自动关闭Popup：onChoose可执行业务动作并明确调用所持OverlayHandle.close；这让同一PopupMenu可内联使用、选项可更新而不强迫关层。禁止从菜单标签解析Alt助记符、自动submenu、命令字符串或快捷键字典。

## 7. W006：Popup、StatusBar、SplitPane 的公共组合

PopupMenu只返回内容；建议自身 `.surface(Opaque)`提供真实填充而不写background(Default)，主题完整Style控制颜色。应用通过owner NodeRef.openOverlay(PopupMenu(...), OverlayOptions(...))打开；使用既有NonModal/takeFocus、anchor/host/placement/options。内容owner链继承主题，父层关闭/owner gone/anchor clip/模态域全部由overlay C权威管理。Escape沿C关闭一个允许取消层及其依赖，内联Popup没有层时不虚构关闭动作；closeOnEscape=false的阻断不在widget重写。空或全禁用takeFocus popup沿C的activeTarget接Esc，不造可聚焦假菜单项。Popup可含在Modal自定义面板，与普通位置用不同实例共享模型，不创建第二Application。

StatusBar=Row role StatusBar，纯公共Row自然高度，不写显式height默认；普通无装饰单行body自然高1，空body/多行body严格沿既有Row自然规则，主题和用户布局声明正常生效。主代理在本轮消息明确撤销粗输入“严格默认高1”：它会要求height(1)显式槽压住主题，或增加私有intrinsic规则。标准四主题role可将height1作为主题值配置；这属于主题产物的后续正式修改，不在本草稿暗改预置。应用需要固定一行时显式.height(1)，padding/border与实际空间按原规则收敛。

StatusBar不占据屏幕底部；应用Column将它放在主体ScrollView/weighted内容之后。不能用绝对终端写入、resize时私自隐藏、无视实际height/min强撑布局。此为已收到主代理采纳的工程裁决W006-S，优先于root-decisions.md旧建议，其余候选仍待冻结。

SplitPane只选择Row/Column和ThemeRole.SplitPane，原weight/gap/border/padding/裁剪/余量/viewport规则照常；不强制两个孩子、不加分隔符glyph、不设隐式权重、不接鼠标/resize键、不增加最小窗口模型。手动resize、浮动窗口均排除。完整固定菜单+主体ScrollView+StatusBar由应用同Column组合，根默认viewport政策沿交互B，避免误以为StatusBar自动fixed定位。

## 8. 可行替代与推荐裁决

| 决策 | 可行替代 | 推荐与可达冲突 |
|---|---|---|
| 受控选择值 | Bool初值+内部状态、统一State对象 | getter+请求callback；内部状态会与业务竞争，统一对象增加现无必要协议 |
| enabled参数 | 每重载再加Bool/getter构造参数 | 仅公共.enabled，避免N×2重载和视觉值双权威；默认行为与主题VisualStates明确分离 |
| Label/Button富文本caption | String/RichText各getter四重载 | 本轮String/getter足够，RichText自定义组合仍可用；不擅增富文本控件目标 |
| 默认控件标记 | Unicode符号+glyph映射 | 固定ASCII皮肤，主题控制样式；不新增glyph key或Unicodekernel |
| 菜单发现 | 任意子AST扫描、专有MenuItem class | immutable MenuEntry+ForEach；公开单项MenuItem构造本轮不增，避免“容器需识别任意控件” |
| 箭头排序 | 原源数组、独立selectedIndex | 用自己refs过滤实际children顺序，支持公共同父move；按源数组导航会与已变物理布局冲突 |
| 菜单选择即关闭 | 内置隐式overlay所有权 | onChoose由应用关闭，可内联/重用；自动关闭需要未列公开参数或私有层查询 |
| 单行caption | 强制height1/wrapNone | 只拒逻辑换行，保留T003文字wrap能力；不能同时承诺无限视觉单行和可覆盖wrap |
| StatusBar高度 | 显式height(1)、私有默认height | 主代理W006-S采纳自然Row；单行通常1，主题可配height1，应用显式可覆盖 |
| Progress尺寸 | 显式width20/height1 | Canvas自然measure20×1，主题与用户尺寸仍可配置；draw-only读取fraction |
| onKey禁用当前动作 | 事件中强制结构flush | 已提交路由资格+preventDefault取消，checked/latest读值独立；禁止重入协调 |

建议主代理逐项采纳W001–W006并冻结上表，不把这里“推荐”留给产品作者随意决策。正式冻结前必须验证：重载/命名参数/尾随块正常编译、MenuEntry及SplitAxis跨包可见、公开refs导航与主题disabled投影无guard循环、StatusBar自然Row与主题height优先级。不能把只通过声明SDK微编译称为产品行为通过。

## G001：公共视觉状态缺口及已采纳上游修正

R004的detached render不发布NodeRef，reference()返回None；现有公共.enabled为只写链，visualStates getter不能知道后链.enabled(false)或祖先disabled。直接默认disabled=false会使离线帧与mounted帧主题不同；构造enabled参数也不能解决后写槽/祖先有效值问题。因此当前签名是候选，不得直接产品ready。

主代理已采纳交互A I012，精确合成见W002；这是未来上游合同修订，不是本件增加私有读取或新API。该决策消除了设计选择留白，**产品准入仍等待I012对应A固定接受源**。正式测试必须包括detached与mounted在effectiveEnabled相同时同disabled样式、disabled祖先、后链.enabled(false/getter)、显式visualStates(false)不能屏蔽真实态、显式visualStates(true)仅模拟外观、不反写行为，以及Checkbox/Radio业务selected与disabled/focused优先级。主题原测试未设置行为槽时其原结果保持。

## 9. 失败、资源、迁移和证据

getter/业务callback/纯绘制失败沿Runtime统一UIException/原异常与cleanup/native恢复，不吞异常。行为、focus、menu ref map随挂载生命周期撤销，旧key同名不复活旧ref；应用业务数据不被卸载删除。数字容量沿Frame/RuntimeLimits，菜单不设隐含业务条数上限；超预算用现CapacityExceeded。禁止用隐藏daemon轮询控件值或每item持续计时器。

现有Text/Row/Column/Frame/Style/Unicode及默认动作/overlay保留唯一权威；当前没有本件旧公开控件实现需要退役，不造legacy兼容别名或第二renderer。若固定集成源发现已有重叠实现，由主代理定位并在同L3列明复用/迁移/删除后再ready，禁止盲删。

签名验证是语言事实；独立测试包含手工预期帧、事件trace、业务值未变、生命周期及原始终端key/恢复日志。作者自测不能替代独立执行/验收。详细AC、角色和输入freeze见tasks.md；当前全部产品证据为空，不能用本文静态检查或hash宣布AC-019/029完成。

## 最终调度与公开入口裁决补充

主代理最终明确采纳：S153–157也等117；PopupMenu仅可复用内容、默认surface(Opaque)、onChoose不自动close，由业务显式handle.close；enabled仅公共属性槽；Checkbox/Radio仅getter受控。以上为确定选择，不再留实现者另选分支。其余尚未正式freeze的候选及上游接受门禁不因本消息自动通过。

## W007 主代理正式接纳及SDK签名修正

本change已成为019/029及153–162唯一任务状态入口，docs/tasks只保编号/原AC引用，旧候选“尚未转移”措辞不再适用。用户范围与S等待117/Popup内容默认Opaque且不自动close/StatusBar自然Row/I012统一态裁决均已采纳，产品仍planned。原provenance/root-decisions独立原件仅来源，不是消费者构建依赖。

SplitPane最终精确签名为`public func SplitPane(axis!: SplitAxis = SplitAxis.Horizontal, body!: () -> Unit): Component`。SDK1.2固定现宏已正常编译原始`SplitPane { ... }`及`SplitPane(axis: SplitAxis.Vertical) { ... }.width(20)`；旧body先axis后的签名使named axis尾随块报重复axis，故修正未实现API签名而不改宏/不要求用户显式lambda对象。其他新增重载/泛型callback/Float64 API同轮仅语言验证，不是产品GREEN。
