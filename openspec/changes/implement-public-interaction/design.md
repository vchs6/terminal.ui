# Public interaction primitives design

状态：主代理已采纳下列工程裁决；本件为待微编译与独立preflight的正式候选合同，**所有新增签名未编译验证，产品planned，验证pending**。不是实现完成证明。详细动机见proposal.md，行为投影见specs/；tasks.md是本变更唯一支持任务状态入口。独立整理只写本目录，不编辑产品/正式测试/主仓。

## Governing decisions

以下I001–I014优先于正文历史“推荐/建议”字样；被比较的替代方案不再供实现者自由选择。来源为主代理2026-11-10明确采纳，未改变用户范围。

- I001：采用原草稿A1–A4；Canvas分别跟踪measure/draw，M1全局render保持完整参考；默认动作Target/Ancestor两槽、框架默认居中；只读guard包含Component.reference；selected由唯一resolver解析；caret仅聚焦Canvas自身。
- I002：B1经主代理复核REQ003.11/architecture后修订为Application根未显式声明viewport时默认Vertical兜底；root.viewport(Off)关闭，显式其他axes优先。普通非root Column默认Off，ScrollView默认Vertical；公开指南主体ScrollView、固定菜单/状态条不滚。B2自然基准用于显式viewport与隐式根发生未承接overflow后的第二pass；B3接受变化Bool/边界钳制保持。不得因viewport改变业务显隐。
- I003：采用C1–C5：同Runtime所有权边/宿主记录；modal截断下层app/legacy但未阻止interrupt仍退出全应用；surface填充意图；Modal无anchor，锚点离开clip关闭非modal；nonmodal不trap、Passive不夺焦点、空takeFocus层可成为activeTarget。
- I004：域外焦点请求及显式dispatch错误名统一FocusOutsideDomain；删除DomainViolation备选名。其他新增错误名以正文表为准，不能按实现方便自由替换。
- I005：稳定父项A=TASK-017、B=TASK-037、C=TASK-018；支持编号098–112各五角色按A→B→C。TASK-028仍文本编辑，019菜单/状态条、029基础widgets、020退出恢复、030可选会话能力，不重编号、不借基础通过关闭这些完整任务。
- I006：A准入消费080、084和主题基础088固定验收输入。真实SDK1.2签名微编译（仅声明不冒充实现）在独立preflight之前；preflight/DQ通过后098→099→100→101→102，后续B/C同理。当前工件仅准备，未宣称这些前置已完成。
- I007：发现当前InputDecoder不产Tab，A纳入0x09→tab、CSI Z→backtab的最小同decoder增量及真实PTY焦点验证。KeyEvent继续code/text；不扩完整修饰键、paste、编辑或剪贴板。B其他导航code消费归一化事件，未有设备解码的序列留后续输入合同，不假称全键盘协议已实现。
- I008：resize布局后ensure使用最近已完成帧的有效caret局部rect；新caret逻辑位置由事件明确ensure，paint不得发命令或构成paint→layout反馈。此修正解决原草稿只有事件侧ensure却承诺resize自动保持caret可见的缺口。

- I009：隐式Application根最多两pass：先旧有限布局，无未承接纵向overflow则完整保留旧布局；有则B2重协商有限内容extent，不改实际根外盒。显式fixed高度和独立纵向viewport是overflow摘要屏障。detached全局render不隐建根viewport；mounted全局render完整M1消费同session已提交viewport/offset/层栈，与snapshot逻辑输入一致，不新建session、不读写M2缓存。精确例表见B.2。

- I010：标准键滚是通用viewport能力；phase5每节点先运行用户Ancestor槽，未prevent再尝试该节点viewport默认，接受偏移变化即preventDefault停止后续节点。stopPropagation本身仍不阻默认。ScrollView仅Column+viewport+focusable，不重复登记滚动回调，不新增builtin槽或控件kind；隐式root走同一路径。

## Context

公开运行时基准为 `c3d743d2dd5cb125e4ca435b2842d1b10c501281`；读取时共享仓库 HEAD 为 `fc7667339d39208bbd0c25650696a7f495ca971d`。工作区已有另一任务修改 `openspec/changes/implement-reactive-runtime/tasks.md`，本角色不碰它。整理时HEAD已前进至0912436b647f701e1de607fe03ce1bfba6a9bbf4；来源字节另见provenance.json。运行时设计最终 R001–019 优先，R019 是内部 native 尺寸原子采样修正、原草稿读取时尚未实施；本变更最终消费080固定集成源，不把阶段性工作目录当验收输入，不能说新公共接口已因此可用。原草稿读取时动态 C 的 If/ForEach/NodeRef 混合物理子序列合同已冻结但未落码；本单元A准入要求其080已验固定实现，焦点必须消费它，不重新选重排策略。

主题初始来源 `d4a92238db8abe703f23d74bbbee18b4fbfbc7c4`；整理时读取到当前design T001–016，builder正式名称为withValue而非关键字with；RichText 来源 `7a33ddc7fb93da3f30007e49538cb00821a2d81b` 与最新设计元数据。均区分合同和产品状态。输入独立草稿 `/workspace/work/input-contract-draft/design-draft.md` 只提供根因与需求建议；其中 ctrl/alt/shift、paste、剪贴板和编辑状态 API 未获本件追认。当前 KeyEvent 仍只有 code/text。

已读 AGENTS、总体提案、architecture、ui-construction、REQ-003/009、TASK-017/018/019/028/029/037。原始草稿来源hash及本次来源字节见provenance.json。核心分工：业务拥有数据与动作；视图决定呈现顺序、显隐和组件组合；框架拥有节点、依赖、尺寸、裁剪、焦点、层栈、合成及设备输出。没有业务排序、自动删除业务数据、鼠标、拖动或窗口系统。

c3d743d阶段源码观察到的不足是实质能力缺口：Text/Column/Row 不能公开表达有选择样式与 caret 的输入视图；Application.dispatch 仅实现 capture/bubble/app/legacy/CtrlC；NodeRef 当前只有 isValid/sameNode/notify；尚无 focus、viewport 或 overlay 公共能力。新增一个 Canvas 通用绘制叶即可，不能为 Button/Input/Menu 再加专用 kind。Button 首版根为 Text，Modal 为 Column，Progress/Input/TextArea 为 Canvas，严格沿用主题 T003。

## Goals / Non-Goals

| 单元 | 精确责任 | 可独立证明的最小结果 | 前置与不纳入 |
|---|---|---|---|
| A 公共绘制与键盘目标 | Canvas、measure/paint、受控上下文、enabled/focus、默认动作、逻辑 caret | 用户公共 Button/Progress/InputCaret 三个小消费者可组合；普通域焦点与失效正确 | 消费080完整动态运行时、084富文本、088主题基础；混合重排在本单元正式覆盖。不实现编辑算法与全部控件 |
| B 内容视口 | 同一 viewport 状态与变换、ScrollView、横滚、ensureVisible | 100行、宽表、单行行末 caret、嵌套无双滚、resize钳制 | 消费 A 的事件/节点/绘制；不复制文本编辑器、不做 M2 或数据虚拟化 |
| C 覆盖层 | owner/host/anchor、modal/nonmodal、层合成、关闭与恢复 | 同类组件用于普通区/弹层；多层关闭、域隔离、底层最新画面 | A，B可用于大弹层内容；依赖已有 Frame/装饰。不是第二 renderer，不新增标准控件接口大全 |

A在080固定源上同时覆盖静态和动态混合真实children，不将key/manual重排验证推迟到本变更C覆盖层；TASK-017完整AC只依实际范围证据判定。三个单元不等于三份平行状态权威。

## Decisions

### A: Public Canvas and controlled interaction

#### A.1 推荐精确形状

以下代码块都是**签名草图，未编译验证**。新增类型一类型一文件。Size/Constraints/CaretSnapshot 是不可变值；PaintContext 无公开构造且不能持有可变整屏 Frame。

```cangjie
public struct Size {
    public let width: Int64
    public let height: Int64
    public init(width: Int64, height: Int64)
}
public struct Constraints {
    public let minWidth: Int64
    public let minHeight: Int64
    public let maxWidth: ?Int64
    public let maxHeight: ?Int64
    public let ambiguousWide: Bool
    public init(minWidth!: Int64 = 0, minHeight!: Int64 = 0,
                maxWidth!: ?Int64 = None, maxHeight!: ?Int64 = None,
                ambiguousWide!: Bool = false)
    public func textWidth(text: String): Int64
    public func constrain(size: Size): Size
}
public func Canvas(measure: (Constraints) -> Size,
                   draw: (PaintContext) -> Unit): Component

public class PaintContext {
    public prop size: Size { get }
    public prop clip: Rect { get }
    public prop defaultStyle: Style { get }
    public prop selectedStyle: Style { get }
    public prop focused: Bool { get }
    public prop enabled: Bool { get }
    public func textWidth(text: String): Int64
    public func put(x: Int64, y: Int64, text: String,
        patch!: TextStylePatch = TextStylePatch(), selected!: Bool = false): Unit
    public func put(x: Int64, y: Int64, text: RichText,
        patch!: TextStylePatch = TextStylePatch(), selected!: Bool = false): Unit
    public func fill(rect: Rect, patch!: TextStylePatch = TextStylePatch(),
        selected!: Bool = false): Unit
    public func caret(x: Int64, y: Int64, visible!: Bool = true): Unit
}
```

Size 负数拒绝 IllegalArgumentException。Constraints 下界非负，Some 上界非负且不小于下界；None 只代表测量轴无上界，不能传给 Frame 或设备。返回 Size 必须有限非负，框架用 constrain 得可接受自然尺寸；布局额外按真实可用区域缩小，min 绝不覆盖终端实际边界。装饰/padding 由通用布局加减，measure 收到的是**内容盒**约束，返回内容自然尺寸；draw 的 `(0,0)` 是该内容原点。Canvas 是叶，不收普通 children；其普通容器属性 gap/alignItems/justifyContent 和静态 Text 排版属性 wrap/ellipsis/textAlign 均报 InvalidProperty。通用尺寸、布局权重、八文本样式和装饰照常适用。

Constraints 的 ambiguousWide 是本次字符宽度策略快照，textWidth 委托既有 displayWidth，不复制Unicode表；框架传入会话实际策略。PaintContext.textWidth 委托同策略并检查上下文有效性。消费者可用既有graphemeClusters分簇，需度量显示列时用本次快照的方法，不能私自假定全角/模糊宽度。Constraints纯值可以保存，但后续新策略仍以新调用参数为准。

Canvas.measure 是约束测量，可能一帧多次因 Row 分配宽度而调用；不能假定一次调用或把调用顺序用作业务信号。未声明 viewport 时 size 是实际分配内容尺寸；有 viewport 时 size 是有限逻辑内容 extent，clip 是有效可见区域反变换到该逻辑内容坐标的 Rect，可能 x/y 非零。clip 只是当前绘制窗口，不是修改权限。节点布局盒、内容盒与阴影扩展由同一路径计算；Canvas 的 put/fill 不能越过自己内容区，阴影只能用通用 `.shadow` 扩展并受祖先 clip 约束。

#### A.2 分开跟踪 measure / paint，比 generic getter 少什么歧义

推荐 Canvas(measure,draw) 分别收集 Observable 读依赖：measure 读集合 M、draw 读集合 P，各自重跑后替换自己的旧依赖并复核订阅版本。M 变化标 Layout+Paint，P-only 变化标 Paint；同时出现在 M/P 时取更强分类。约束/字符宽度 profile/影响测量的 style 改变使 measure 失效；纯颜色/选区/caret 可只使 paint 失效。显式 NodeRef.notify(Layout/Content/All) 仍按原语义使测量失效，Style 至少重绘；不给调用者万能“无条件只 paint”绕开真实尺寸变化。

| 真实可行方案 | 优点 | 代价与结论 |
|---|---|---|
| 独立 measure/paint 读跟踪 | 直接对应职责；业务只读所需状态；caret 不污染文本 measure 依赖 | 推荐；需扩展依赖收集器的计算阶段，沿用现 Observable 订阅/版本协议 |
| `Canvas<T>(state:()->T, measure:(T,Constraints)->Size, draw:(T,PaintContext)->Unit)` | 对不观察内部字段的不可变快照模型易理解 | 一个 T 同时装全文与 caret 时任何变化都可能重测；需要调用者拆 T 或另加失效分类。不是免成本替代，不推荐作唯一入口 |
| 两个 getter 快照 `measureState`/`paintState` | 能形成显式缓存边界 | 类型/比较/复制和第三套 API 负担更大；只有实际仓颉跨闭包追踪无法实现时再作替代 |

**M1/M2 严格边界**：上述是依赖与 dirty 的精确分类，不是提前承诺当前 M1 跳过全树 measure。R004 的全局 render 必须继续完整布局/绘制，不能调用未来 M2 缓存；Application 的 M1 也可完整生成目标。caret-only 变化不改变 M 集合、不标 measure dirty，但 M1 参考遍历仍会调用 measure。后续 M2 才可凭 M/约束未变复用测量结果，接受“caret 不重扫大文本”的运行性能断言。本单元不要求M1无重扫；应用可采用纯文本排版模型的不可变缓存，M2另阶段交付，不能偷偷改全局render参考语义。示例可让 measure 读取预计算不可变尺寸、draw 读取 caret，使 M1 的重复 measure 本身为 O(1)；这证明 primitive 不强迫全量文本依赖，不能等同完整编辑器已实现增量布局。

measure/draw 必须纯呈现：可读 Observable 与获准只读 NodeRef 状态；不能写 Observable、改 Component、notify、requestFocus、滚动/层命令、dispatch/snapshot/dispose 或直接终端输出。用户闭包异常按现 Runtime 首错/cleanup/设备恢复契约处理，不提交部分画面。不在锁中调用闭包。

#### A.3 绘制、样式、过期与宽字符

PaintContext 仅在该次 draw 的同步调用链内有效，退出（含异常）即撤销 generation；保留引用后任何属性访问或方法调用报 ExpiredPaintContext。异线程/异 session 优先报 WrongUIContext；同域过期再报 ExpiredPaintContext。其 API 不返回内部 Frame、cells、RuntimeNode 或后端句柄。Rect/Size/Style 拷贝可保存，不能凭拷贝再写入旧上下文。

String/RichText 共用唯一文本验证、整篇簇规则、unicodewidth、Frame 宽簇覆盖/裁剪，不复制宽度表。put 先验证完整值再写；负位置可裁剪，零宽簇不单独占格，坐标运算使用现饱和/受限规则防溢出。新增 clip 适配必须委托同一 Frame 内部裁剪规则：整簇无法完整落入有效 clip 时不绘该簇；覆盖已有宽簇时清其完整占位，不留半簇或孤立 continuation。不能仅 `if(start in clip) Frame.put(...)`，那会让宽簇穿过 clip 右边。

defaultStyle 是主题 resolver 的当前完整文本 Style；selectedStyle 用**同一声明来源**，在当前 focused/disabled 状态基础上临时令 selected=true 后解析得到，仅用于所绘选区，不修改节点状态或触发第二套主题级联。put/fill 的 selected 开关选择这两种基底；Canvas 原有 VisualStates.selected=true 时不被 selected=false 清除。绘制 patch 对相应字段合并在 span patch 之上，但仍在组件显式属性之下：组件显式 > 本次 patch > span > 复用/主题/继承基底。patch 未设字段继续回落，Color.Default/false 是显式值。这是建议的公开高层绘制次序，需与 RichText 第3节共用 resolver，而非 Frame.put 的低层 `span > base` 语义混淆。fill 写带解析样式的真实空格，绝不是透明擦除。

选择区由消费者按字符簇边界切为未选/已选片段，Canvas 不决定选区或编辑算法。RichText 一个 put 内仍按全文分簇，跨 put 边界不承诺重组簇；消费者不能拆开同一簇分别 put。主题外观 disabled 不改变 enabled，焦点颜色也不执行焦点迁移。

#### A.4 enabled、焦点与 activeTarget

```cangjie
// Component 新增，常量/getter同槽替换，默认false/true。
public func focusable(value: Bool): Component
public func focusable(value: () -> Bool): Component
public func enabled(value: Bool): Component
public func enabled(value: () -> Bool): Component

// NodeRef 新增，只读查询可在同UI域getter/measure/draw中调用并建立依赖。
public func isFocused(): Bool
public func isEnabled(): Bool
public func isVisible(): Bool
public func requestFocus(): Unit

// Application 新增。查询不驱动pump/重绘，不改变focus。
public func focusedNode(): ?NodeRef
public func activeTarget(): ?NodeRef
```

focusable 默认 false，enabled 默认 true。isEnabled/isVisible 返回本节点与当前呈现子树普通祖先的有效合取；disabled 的普通父屏蔽整个交互子树。overlay owner 是生命周期归属，不能因触发按钮临时disabled就把弹层所有按钮隐式disabled；跨overlay关系不继承行为enabled。owner hidden 则按C的显式依赖关闭规则处理。主题 VisualStates.disabled 只是外观，永远不能写该行为槽。标准控件用业务 enabled getter 配行为，用同一业务值及 `ref.isFocused()` 投影 visualStates；不建两份可互相覆盖的业务 disabled 状态。

焦点候选 = 当前活动域内、挂载有效、有效可见且 enabled、focusable 的节点。**被 viewport 裁剪到屏外不等于 hidden**，否则无法 Tab 进入第100行；候选进入后调用 B 的 ensureVisible。实际 viewport 为0时保留有效焦点身份但隐藏 caret；尺寸不足不自行 visible(false)。视觉上被 nonmodal 层遮挡也不自动删除焦点，caret 则须服从遮挡。

遍历是当前普通真实 children 序列的深度优先前序，marker 不参与，父可聚焦时先父后孩子；没有 tabIndex 或按业务 key/label 排序。ForEach key 重排/同父 move 保 node identity 和现焦点；仅下一次遍历使用新物理次序。显式 hidden/disabled/focusable(false)/unmount 后，在安全提交边界修复焦点：使用变更前遍历序列中原焦点之后仍有效的第一个候选；没有则取之前的最近有效候选；仍没有才取新域第一个；全空返回 None。原节点仍有效且候选时优先保留，不因重排重选。

Tab 前进/ShiftTab 后退在活动域循环；无当前焦点选首/尾，全空无操作。反向键规范code固定backtab，HT(0x09)解为tab，空参数/无中间字节CSI Z解为backtab，text均空；只接受CSI Z，不误接受SS3 Z或带参数Z。沿唯一InputDecoder处理任意输入分块，KeyEvent仍无shift字段。此最小增量在A交付，完整键盘合同随后继承规范名，不能复制第二decoder。requestFocus 在事件/post/batch 中排队，边界按请求顺序校验，最后成功请求生效；不满足候选条件报 InvalidFocusTarget，跨域模态目标报 FocusOutsideDomain，不静默把请求改成别的节点。生命周期中需 post，不能直接请求。

activeTarget = 有效焦点，否则最近明确takeFocus且仍存活的交互层根，否则当前域的可见 enabled 根（根不要求 focusable），否则 None。候选层根也须可见enabled且位于当前域；打开NonModal/takeFocus=false或Passive不改该目标层。Tab成功进入别处或requestFocus成功后，目标层随新焦点所在层更新。focusedNode 与 activeTarget 不同：空焦点域根可接收 Escape 等域操作，却不会“伪装有焦点”。设备无有效目标时不合成虚假 UIKeyEvent；基础域保留 R015 的 legacy 非 interrupt 兼容路径，modal 域禁外部 app/legacy；未阻止的键盘 interrupt 仍走框架退出策略。显式 dispatch 不隐式改变焦点：目标必须有效、visible、enabled且位于允许域，否则有诊断。这样显式注入不会绕过模态隔离。

当前 `requireContext()` 禁 getter，所以这些新只读查询与现有 `Component.reference()` 的只读分支必须拆出 `requireReadContext()` 等内部 guard：验证 thread nonce/session、不禁止求值、不 pump、不获取写权限。依赖标记由 runtime 管理，不能靠业务在 getter 里缓存另一 session 的 ref 逃逸。只有原 isValid/sameNode 保持跨线程安全，其他新 NodeRef 查询同 UI 域；已失效查询报 StaleReference。Application 查询未 start/已 dispose 返回 None，活跃跨 session 调用仍 WrongUIContext。

#### A.5 默认动作：精确阶段与一次性

```cangjie
public enum DefaultActionPhase { | Target | Ancestor }
public func defaultAction(handler: (UIKeyEvent) -> Unit,
    phase!: DefaultActionPhase = DefaultActionPhase.Target): Component
```

每节点每 phase 一个槽，后写替换；与 onKey/onKeyCapture 是不同槽。同一事件固定域、路径与处理器快照，状态/结构修改在边界生效。次序：

1. 当前域根至目标 capture；目标至域根 bubble。
2. 当前域允许的新 app handler；允许的 legacy handler（保持 interrupt 不交 legacy）。stopPropagation 可跳过尚未执行用户传播，preventDefault 不会停止用户传播。
3. 若未 preventDefault，仅目标节点 Target 默认动作一次。
4. 若仍未 preventDefault，框架 interrupt 退出、Escape 层取消、Tab 导航（按互斥 key 分支；单事件不会执行三个）。成功导航/关闭视为默认已处理。
5. 若仍未处理，沿目标到域根逐节点：先调用该节点用户Ancestor槽一次；若仍未preventDefault，再尝试该节点有效viewport的标准键滚。接受偏移变化即preventDefault停止后续节点；不能移动才到上一层。任何用户Ancestor回调preventDefault/consume同样停止余下默认链，stopPropagation本身不跳过当前viewport或后续默认。没有viewport的节点只运行其用户槽。

`stopPropagation()` **不阻止**3–5；`preventDefault()` 阻止全部未执行默认动作，不改传播标志；`consume()` 两者同时。默认回调 currentTarget 为实际默认所属节点，target 不变，事件 active 延至全部默认完成，之后修改仍 ExpiredEvent。框架不会把“没有业务回调”推断成未处理，是否继续只由 preventDefault 与框架已处理标志决定。用户 Target 默认即使只调用 stopPropagation，祖先滚动仍可发生；实现控件必须在自己完成编辑/激活后 preventDefault。

两个 phase 的必要性：只有一个目标回调无法公共组合 ScrollView；所有祖先回调都在框架 Tab 前又会让自定义容器截走导航。Target 专给确切键盘目标，Ancestor 是明确后续用户回落；每个Ancestor之后的标准viewport动作是同一公开能力的框架语义，不另加builtin槽。同一事件未消费的 PageDown 可让最近可滚动祖先尝试；一旦任一层滚动，必须 preventDefault，绝不同时滚编辑视口与外层。组合控件应让动作所在节点本身 focusable，不能假定一个祖先 Target 回调会替代子目标默认动作。

#### A.6 Caret 请求与会话输出

Canvas.caret 仅声明本次 draw 的逻辑请求；同一节点本次最后一次请求覆盖前次，未请求等价隐藏。不设额外 ANSI/flush API，不由组件调设备光标。首版只有终端原生 caret 的位置/显隐，不加入 shape/blink 协议。

首版只接受 **当前 focusedNode 自身的 Canvas 请求**，其他节点请求不输出（不因绘制顺序抢 caret）。InputCaret 直接让 Canvas 可聚焦；复杂控件如需子节点代领 caret，后续必须显式授权模型，不能私自放宽成任意后代抢占。caret x/y 为内容坐标中的一个待显示单元位置；行末插入点必须把一个空白 caret 单元纳入内容 extent，否则该位置落在右侧边界就隐藏。

会话先变换到终端坐标，再核有效 clip、正 viewport、有效 focused owner、顶层模态域和后续层的实际不透明覆盖。clip外、零宽/高、宽簇 continuation（不是合法显示首格）一律隐藏，不把 caret 钳制到错误位置。透明 hole 不遮挡，带样式空格/阴影格遮挡；即便最终字符/颜色恰好相同也算覆盖，不能靠比较最终像素猜 owner。内部可携带本帧覆盖来源或在合成时检查 caret 对应单元写入，不暴露整屏可变所有权图。

```cangjie
public struct CaretSnapshot {
    public let owner: ?NodeRef
    public let x: Int64
    public let y: Int64
    public let visible: Bool
}
public func caretSnapshot(): CaretSnapshot // Application；只读最近完成的目标帧
```

隐藏值规范 owner=None,x=0,y=0,visible=false；snapshot/设备目标生成更新它，查询本身不重绘；headless 可观察逻辑结果。dispose/新 start 清空。全局 render 返回的 Frame 仍只含画面，不改变签名或触发设备光标输出；不以它代替 Application 的 caret 查询。设备统一比较画面与 caret，caret-only 移动即使网格相同也需要输出。全部输出成功后才更新成功基线；失败沿现恢复围栏。退出原显隐按I015已知管理/未知保留策略恢复，不能从用户 draw finally 发终端控制。

#### A.7 三个极小公共消费者（只解释复用性，不冻结标准控件API）

- Button：`Text(label).themeRole(Button).focusable(true).enabled(enabledGetter).defaultAction(...)`；Enter/空格被激活一次后 preventDefault。其 onClick/label 参数细节留 TASK-029，不需要 Canvas 或 Button kind。
- Progress：`Canvas(constantMeasure, drawProgress).themeRole(Progress)`；draw 读进度，measure 不读进度。用 ctx.fill/put 和默认样式显示，不要以百分比字符串变化迫使布局改变，也不默认抢焦点。
- InputCaret：`Canvas(measureDocument, drawVisibleDocument).themeRole(TextInput).focusable(true)`；measure 读文档/可用宽，draw 另读选区/caret；只绘 clip 内所需行/整簇，ctx.caret 提交行末位置。编辑键在 Target 默认消费，B 负责内容偏移。它只是依赖、选择样式与 caret 消费者，不在本件定义删除/撤销/paste/IME。

### B: Unified viewport and scrolling

#### B.1 公开形状与状态权威

```cangjie
public enum ScrollAxes { | Off | Vertical | Horizontal | Both }
public enum ScrollAlign { | Nearest | Start | Center | End }
public func viewport(axes: ScrollAxes): Component
public func viewport(axes: () -> ScrollAxes): Component
public func ScrollView(body: () -> Unit): Component
public func ScrollView(axes: ScrollAxes, body: () -> Unit): Component

public struct ViewportSnapshot {
    public let width: Int64
    public let height: Int64
    public let contentWidth: Int64
    public let contentHeight: Int64
    public let offsetX: Int64
    public let offsetY: Int64
    public let axes: ScrollAxes
}
// NodeRef；仅具有viewport能力的节点可query/scroll。
public func viewportSnapshot(): ViewportSnapshot
public func scrollTo(x: Int64, y: Int64): Bool
public func scrollBy(dx: Int64, dy: Int64): Bool
// 可用于任何节点；rect是该节点内容局部坐标，None指整个布局盒。
public func ensureVisible(rect!: ?Rect = None,
    horizontal!: ScrollAlign = ScrollAlign.Nearest,
    vertical!: ScrollAlign = ScrollAlign.Nearest): Unit
```

viewport 是通用节点能力，不是 ScrollView 私有 kind；可用于 Column/Row/Canvas，静态 Text 也可选择它，但静态 wrap 仍是既有排版规则。ScrollView 是公开 Column + `.viewport(Vertical)` + `.focusable(true)` 的组合；标准键滚由所有viewport同享的I010语义提供，不另登记回调；显式 axes 构造同理。样式 role 用 Column，不增新主题闭集枚举。Canvas 输入内部水平视口与表格横滚复用同一坐标/offset/clip；输入仅控制自己的逻辑 extent 和 ensureVisible。

NodeRef 挂载代际拥有唯一 offset，不能再让 ScrollView 的业务 Observable 保存第二份可相互覆盖的 offset。query 是不可变、可跟踪的最后提交布局快照，不隐式 measure。挂载后尚无布局时返回 width/height/content/offset全0与当前 axes，之后自动失效。关闭/重建节点归零，key重排/同父move保留。axes 关闭某轴时该轴 offset 归0，其余轴保留钳制。

**默认纵向裁决B1/I009**：Application根没有任何viewport常量/getter声明时有效axes为Vertical；`.viewport(ScrollAxes.Off)`显式关闭，显式Vertical/Horizontal/Both或getter结果优先。声明“未设”与显式Off必须分别保存，不以枚举默认Off丢失presence。普通非root Column默认Off，ScrollView默认Vertical。公开指南将可变长度主体置于ScrollView、固定菜单/状态条留普通布局；同时保留裸根长内容的兜底，不以指南代替默认行为。无新增Application rootScrollAxes选项。detached `render`临时Runtime没有隐式根viewport；mounted `render`完整M1消费已有session的有效viewport/offset/层栈，保持R004同输入等价，不pump第二session、不访问M2缓存。

#### B.2 extent、clip、实际尺寸

viewport 是实际分配内容区；框架最小尺寸只影响期望，不强撑虚拟最小终端。滚动轴测量上界解除为 None，使内容可以大于 viewport；非滚动轴仍受 viewport 内容约束。布局只产有限 contentExtent，不构造全内容大小 Frame，最终目标 Frame 始终实际终端宽高。滚动变换 `screen = contentOrigin + local - offset`，全部绘制/anchor/caret/ensureVisible 共用；视觉 clip 是祖先/宿主/本viewport的交集。

可滚动容器需要两层**几何概念**但不增加节点树：外层分配盒参与父布局，内层内容 extent 装载普通 children。Column 竖滚的内容主轴自然长度含孩子自然/固定/min及gap，不在分配每个孩子时又把它裁成 viewport 高度；有正剩余时按既有权重分配，无正剩余则保留孩子最小/自然基准使其可访问。显式viewport以及隐式根第二pass中，滚动主轴 weighted child 的基准固定为 `max(min, natural或fixed)`，只有额外正剩余才按weight分；普通非滚动布局保持既有 weighted-min 基准。不能把无限上界换成 Int64.Max 去执行乘除。Row 横滚对称；实际 maxSize/面积限制仍拒绝溢出或资源超限，不靠无限虚拟帧。


**隐式根兼容算法（源码推导，尚未产品实测）**：

1. 先用现有有限约束完整布局一次，root外盒由实际终端、显式width/height、min和装饰按既有规则确定，内容viewport高度记V。根的隐式Vertical仅登记能力，不预先改变这一pass的weighted-min基准或孩子分配。按实际分配宽测量wrap，不用未约束自然宽推高度。
2. 同一LayoutNode遍历产生内部纵向overflow摘要：在已分配内容盒内，逻辑内容/普通孩子的实际所需底界超过内容高度即记录未承接overflow；横向截断、阴影扩展不算。摘要至少含是否存在、首个来源node id及是本地自然内容/分配宽wrap/后代传播，内部使用、不增加公共测试hook。显式fixed height的节点在其声明边界截断并停止向外传播；具有Vertical/Both viewport的非root节点把自身内部overflow承接进自己的extent，不向根传播；Horizontal/Off不承接纵向。有效hidden节点不参加布局/摘要。显式root.height同样保留其声明裁剪意图，隐式fallback不得绕过它；显式root.viewport(Vertical/Both)则明确选择根内容滚动，使用下述直接B2路径。
3. 摘要无未承接overflow：直接用第一pass全部位置/尺寸，根contentHeight取V、offsetY=0，不因自然高度不等而重分weights。这保留旧短内容像素。摘要存在：仅再作一次根内容B2协商；内容虚拟高度H=max(V,受约束自然需求)，root外盒仍V，滚动量0..H-V。B2自然需求在显式fixed height处取声明尺寸及既有min/实际约束结果，在独立纵向viewport边界取第一pass已分配的外盒需求，不把内部100行当根的100行。普通未承接子树按自然内容高参与，正余量按既有weights/余数规则分配。
4. 每次目标布局最多两个这样的root pass；第二pass结果直接作为本次布局权威，不因其摘要再开第三pass，也不启用Observable稳定循环。若第二pass仍因显式fixed裁剪或不可满足真实边界留不可见内容，保持既定clip；它不是再次增大终端的理由。内容自然需求计算复用现测量/主题wrap协商，不建第二布局树。后续状态/尺寸变化是下一次正常布局，重新先走第一pass，offset按最终extent钳制。
5. 显式root.viewport(Vertical/Both)、普通ScrollView或任意显式viewport直接采用B2内容协商，不需要根兼容试探pass；root.viewport(Off)完整关闭此兜底。普通非滚动容器仍原规则。

| 输入（均无border/padding/gap，除非写明） | 固定结果 |
|---|---|
| App隐式Column根V=10；两个孩子weight=1、min=0、自然高1与3 | 第一次旧分配5/5，两者都容纳，保持5/5；不采用无条件B2会产生的4/6 |
| 相同根V=10，自然高8与1、weight各1 | 第一次5/5有未承接overflow；第二次B2基准8/1、余量1依既有余数顺序给首项，分9/1，H=10、offset=0；只改变原已截断场景 |
| App裸Column内100个自然高1无weight子项，实际80×24 | 第一次摘要overflow；第二次H=100、viewport=24、offset范围0..76，可访问全部行；未声明显隐不变 |
| App根V=10：固定菜单高1、body ScrollView weight=1、固定状态条高1；body内部100行 | 第一次分1/8/1；body承接100行，根不进入fallback，root offset=0、body offset0..92；固定栏不滚 |
| App裸Text或无独立viewport的普通子树实际可用宽4、高2，wrap Grapheme文字形成3个视觉行 | 第一次按宽4测得高3并记wrap来源；第二次内容高至少3，root外盒高2，可滚到第三行，不使用原未约束单行高度 |
| 实际80×24，minWidth=100/minHeight=30，裸100行且无fixed height | 外盒仍80×24，内容按真实宽度测量，虚拟高100；不建100×30最小终端、不自动hidden |
| 实际根内容V=0，裸100行且无fixed height | 最多两pass，contentHeight=100、初始offset0、合法范围0..100；不绘制、不显示caret，ensure在该零轴不定位；恢复尺寸重新协商/钳制 |
| 空内容、V=0 | contentHeight=0、offset=0，一pass无overflow；无除零/稳定循环 |
| 某普通子树显式height(3)且未启纵向viewport，内有100行 | 它保留高3裁剪，摘要不越过声明边界；祖先implicit root不得借兜底扩成100行 |
| 任意裸长root显式viewport(Off) | 保持旧静态裁剪，root不滚；这是应用明确关闭，不是框架自行隐藏数据 |
| detached render同一未声明viewport的长描述 / mounted render当前App root | 前者离线静态默认；后者消费App有效root策略和offset完整重算，和同逻辑输入snapshot一致 |

根fallback只在Application持久模式启用，owner/host clip仍取实际外盒；层宿主不随root内容虚拟extent扩成超大终端。M2必须消费同一有效策略与overflow摘要语义，不另造“快速根布局”改变上述例表。

`offsetX ∈ [0,max(0,contentWidth-width)]`，Y同理；禁用轴为0。resize/文字缩短/隐藏子项后钳制，保留仍有效焦点身份；不为尺寸不足删数据、改业务 visible。零 viewport 保留合法 offset（按同式钳制）与节点身份，不绘内容、不显示 caret；恢复尺寸再钳制。

#### B.3 命令提交与确定滚动

scrollTo 输入非负，负值 IllegalArgumentException；超最大值钳制。scrollBy 可正负，安全饱和再钳制。无 viewport 的节点报 InvalidProperty，失效/跨session/重入按统一规则。命令在事件/post/batch 进入本轮候选 offset，边界提交；返回 Bool 表示**按最后提交几何和此前已排队 offset 计算，确实接受了一次偏移变化**，不是设备已滚动、不是承诺本轮 resize 后仍同偏移。最终 extent 变化可再次钳制。此 Bool 让公共默认滚动能决定是否 preventDefault；不能把异步设备成功伪装成同步 Bool。

先处理业务/结构提交与依赖稳定，再布局/钳制，再执行 pending ensureVisible。显式滚动之后同 turn 的 focus/ensureVisible 意图按调用次序确定；最后一个确保可见请求可覆盖早先滚动，不能让下一帧自动每次重新确保旧 focus 而阻止用户手动滚动。focus获得时框架产生一次确保请求；新的caret逻辑位置由事件明确调用ensureVisible。viewport尺寸改变时，框架使用最近完成帧保存的、仍属于有效聚焦Canvas的caret局部1×1 rect，布局后产生一次确保请求；同turn有显式新caret ensure时该显式意图覆盖旧帧位置。节点换代/失焦/卸载清除旧记录，旧rect落在缩短后的extent外则丢弃而不报业务命令错误。每帧重绘不会重复产生。paint 中不准 ensureVisible；编辑默认动作变更 caret 后在同一事件请求，框架布局完成后用最新几何计算。

标准viewport默认键固定为：up/down 一行，PageUp/PageDown（精确KeyEvent.code为`pageup`/`pagedown`，与input K002表一致）`max(1,viewportHeight-1)` 行；Horizontal/Both 允许 left/right 一列；Home/End 对竖轴先到首尾，纯Horizontal则首尾列。更复杂 CtrlHome/CtrlEnd 留键盘合同。每节点用户Ancestor先运行，未prevent才尝试这些标准键；没有该轴/无法变化则不消费，让祖先尝试；任一viewport变化即 preventDefault，不把剩余距离再交外层。输入自己的 Target 默认如果已处理 PageDown，必须 preventDefault，外层绝不再滚。

#### B.4 ensureVisible 的精确含义

rect=None 指节点整个布局盒，用框架已提交几何转换；Some(rect) 是内容坐标，非负尺寸且 x/y>=0，目标须落在当前逻辑 contentExtent 中，超出报 InvalidProperty（不能凭无限 rect 强迫 viewport 增长）。空 rect 无操作；caret 用 width=1,height=1 的合法占位格，而不是0宽数学点。

从最近 viewport 祖先向外逐层计算；若目标节点本身有 viewport，Some内容rect先处理它自己的viewport，None布局盒则从父开始。Nearest 在目标完全可见时不动；能容纳时移动最小距离使两端可见；目标比viewport大时保留已经落在目标范围内的窗口，否则向最近一端移动，等距取Start。Start/End对齐相应边，Center 使用向下取整的一半余量；最终钳制。禁用轴不改变偏移，实际viewport为0的轴本次不做定位；后续resize按新几何重新确保焦点/caret。

内层确定后把其有效可见目标片段变换为外层坐标，再外移；不能拿完整文档 rect 让所有祖先一起跳到全文尾。覆盖层的 host 是几何边界，ensureVisible 不会跨 portal 回滚触发节点的普通祖先；overlay 内容自己内部的 ScrollView 正常滚。显式隐藏目标不负责改 visible，报 InvalidProperty。

### C: Overlays and public surface

#### C.1 精确建议入口

```cangjie
public enum OverlayMode { | Modal | NonModal | Passive }
public enum OverlayPlacement { | Center | BelowStart | AboveStart | RightStart | LeftStart }
public enum OverlayCloseReason { | Requested | Escape | OwnerGone | OwnerHidden | AnchorGone }
public enum SurfaceMode { | Transparent | Opaque }
public func surface(value: SurfaceMode): Component
public func surface(value: () -> SurfaceMode): Component

public struct OverlayOptions {
    public let mode: OverlayMode
    public let host: ?NodeRef
    public let anchor: ?NodeRef
    public let placement: OverlayPlacement
    public let closeOnEscape: Bool
    public let takeFocus: Bool
    public init(mode!: OverlayMode = OverlayMode.NonModal,
        host!: ?NodeRef = None, anchor!: ?NodeRef = None,
        placement!: OverlayPlacement = OverlayPlacement.Center,
        closeOnEscape!: Bool = true, takeFocus!: Bool = true)
}
public func overlayHost(value: Bool): Component // 默认false；应用根内建宿主能力
public func openOverlay(content: Component,
    options!: OverlayOptions = OverlayOptions()): OverlayHandle // NodeRef，调用者为owner
public class OverlayHandle {
    public func isOpen(): Bool
    public func content(): ?NodeRef
    public func close(): Unit
    public func closeReason(): ?OverlayCloseReason
}
```

OverlayHandle 无公开构造，为弱 owner/session/id 句柄；openOverlay 只能同 UI 域事件/post/batch 发起。调用时校验已知参数/预留未挂载 content，返回 pending handle；边界构造/挂载成功后 content() 返回真实 ref，pending 时 None。isOpen 表示已接受且未终结（包含 pending），不是画面已经可见；closeReason 为不可变终态或None。关闭后同原UI线程仍可查询该句柄的终态（content返回None），不要求session继续active，也不能以此取得写权限；新session的活动回调查询旧handle仍属跨域。getter均同UI域只读可跟踪，isOpen不是跨线程同步工具。pending close 会取消预留并不运行mount；已关闭close幂等，但跨session/错误线程仍拒绝，不让no-op成为越权入口。构造/mount失败沿 Runtime 停止清理路径，不能留下挂起handle。

modal 强制takeFocus=true，Passive强制false且不能有可交互后代；冲突参数报 IllegalArgumentException。Modal禁止anchor非None，Center为唯一无锚点placement；将此参数组合在入口诊断，不能依后文建议偷偷降级。NonModal 默认takeFocus=true适合popup菜单，应用提示层使用Passive，主动不夺焦点的可交互面板可以NonModal/takeFocus=false。非模态并不自动允许越过当前modal域：owner必须在当前有效域，不能从下层打开层夺走上层焦点。

#### C.2 唯一节点模型：ownership / 普通children / host分清

每层 content 仍是同一 Component 挂载成的 RuntimeNode，具有相同 id/token/bindings/build/cleanup/LayoutNode/Frame。逻辑父关系为 owner，关系种类标记 overlay；此节点不进入 owner 的**普通物理 children 序列**，不占其流式布局空间，不与 If/ForEach marker 混排。覆盖层管理器保存这些同一节点的层记录，不克隆Component、不维护第二套生命周期树。NodeRef.children()（C已冻）只给普通孩子，overlay列举/管理由 handle，不改变已有 children 语义。

宿主是几何/裁剪边界，不是业务owner，不代替生命周期父。None host取会话根宿主；显式host须同session、有效可见、具有overlayHost能力，并且是owner本身或逻辑祖先，防止任意跨分区侵入。host内容区投影到终端后的有效clip是该层最大绘制边界；层可超出owner普通内容clip，但不能超出host有效clip或终端。层子树普通容器内部仍逐级裁剪；shadow扩展只到host clip。根宿主内容范围为实际终端可用区，不受应用min强撑。

事件逻辑路径从content走owner链，但遇活动modal域根截断；host不成为事件父。主题继承从owner逻辑链取得，不从碰巧放置的host取另一份主题。层栈总序由开层提交序排列；依赖子层总在父层上方。移动层只变几何，关闭只卸载所属真实节点。下层仍运行Observable/post并更新状态，关闭后完整生成最新画面，绝不恢复“打开时截图”。

#### C.3 输入域、模态取消与app快捷键

当前域为最高存活Modal及其owner依赖后代层；无Modal时为基础域。Passive从不成为键盘目标、焦点候选或域根，但视觉覆盖仍参与caret遮挡。NonModal/takeFocus=true打开时把焦点放入其内容；不强制陷阱，Tab在当前域的可交互层与基础内容之间循环；域内按绘制层的从下到上顺序，每层内部按真实children前序，层间不按业务key排序。modal域只遍历该modal及其依赖非modal后代，不遍历基础域或兄弟下层。

模态期间 base Application 的新 app handler 和 legacy handler 都不调用，即使事件无人处理也不透传；modal内容根的onKey作为域级快捷入口，无需增第二App。无modal的nonmodal目标按owner逻辑路径冒泡后允许base app/legacy。显式 dispatch 到域外节点报 FocusOutsideDomain，不会因为测试注入而穿透模态。

Escape 在目标默认之后执行：从焦点所属最内层向其owner层上溯找第一个closeOnEscape=true的活动交互层，关闭一层及其依赖后代后消费；Passive跳过。某最内层closeOnEscape=false即阻断向父层取消，不偷偷关闭父层；此阻断已随C2裁决固定。基础无层Escape无框架默认动作。

**键盘 CtrlC/interrupt** 保持运行时 R010：在目标默认之后、未prevent时停止整个Application，包括modal期间；不是自动转成“关闭弹窗”。modal根capture可preventDefault定义业务取消，输入目标有选区时是否copy并prevent由后续输入合同决定。外部SIGINT/SIGTERM/会话stop属于会话取消，不构造可消费键盘事件，依既有恢复流程退出。由此“modal阻断app快捷键”不会错误屏蔽框架退出/恢复。

#### C.4 焦点保存、级联关闭与失败

takeFocus层打开时记录当时有效焦点弱ref；挂载成功后选择层内首个有效候选，没有则focusedNode=None、activeTarget为该域/已取焦点层的可见enabled根，以便Esc。非模态无候选时应仍使其成为当前无焦点目标层，不能把Esc投旧焦点；此“目标层”是session选路状态，不是第二焦点node；activeTarget不以层内首个非focusable孩子替代该根。

关闭owner时先收集完整依赖闭包，包括普通后代拥有的层、层中再开的层；先撤销全部token/订阅/owner队列，随后最深层至父按既有cleanup规则执行各一次。owner显式visible(false)时同步关闭其附层（OwnerHidden）；owner只滚出clip不视为hidden、不销毁业务节点。父层关闭不可留下更高层孤儿；关闭非顶层不能把其以上无依赖兄弟层一并误关。会话dispose/异常关闭全部，继承 R012/R017 聚合错误及native恢复，不在finally抛新错遮首错。

只在被关闭闭包拥有当前焦点或当前目标层时尝试恢复；关闭背景nonmodal/Passive不会抢当前焦点。级联关闭一次合并恢复，不能每关子层就跳一次：优先恢复本次被关闭最外层保存的弱ref（须仍在新域且eligible）；失效时取最近仍存活owner祖先中的首个eligible候选；再按A的原物理后继/前驱规则；最后新域首个；全空保持None/域根activeTarget。关闭顶modal后，下层modal恢复其原有效焦点；触发按钮卸载/禁用后不访问旧ref。

#### C.5 透明、默认modal表面与主题

复用现 Frame.transparent：未写单元是hole，带样式空格是opaque单元；“Default背景色”依然是画了空格，不等于透明。层用透明目标片段或同一合成路径形成贡献，禁止读取stdout或暴露可变全屏Frame。宽簇覆盖仍由Frame统一清理，圆角/阴影也是格级贡献。

`surface(Opaque)` 是**填充意图**，不是 `.background(Color.Default)` 的别名。它在节点分配布局盒内、边框/文字之前，用统一resolver的最终Style填真实空格；没有本地background声明时仍使用已解析继承/主题背景，主题切换自动更新，不能向显式槽写Default压死主题。surface(Transparent)只取消这个额外表面填充，显式 `.background(...)` 或主题角色background本身仍会按T015填充；若需要真正holes，不能同时声明强制本地background。节点阴影不因为surface被扩成整个矩形。

Modal模式为content根提供默认 Opaque surface意图；用户显式surface选择可覆盖默认。NonModal/Passive默认Transparent；可选popup菜单公共组合设置Opaque。此新增默认意图来源位于显式surface之下，不新增主题schema键，不改主题T015的root seed fill：root种子背景仍仅其独立fillStyle，modal surface则是本节点完整有效Style。surface与实际fill来源必须进入dirty/缓存比较，不能只比较八字段Style。这样无背景声明的modal也不漏底，仍能由主题决定背景。

必须区分Modal **窗口表面** 与全屏背景幕：本件默认只让modal content布局盒opaque，周围仍看得到下层但输入隔离；不自动全屏调暗、填空格或加幕布。应用若想背景幕可用同公共组合另画，不能把视觉透明等同输入穿透。

#### C.6 Anchor与尺寸

Center允许anchor=None，按host可用区域居中，整数余量向下取整。四个方向placement要求anchor存在且同session，并且是owner本身或其普通/逻辑后代；本期不支持任意绝对屏幕坐标、自动跟鼠标或拖动。anchor取已提交布局盒经统一滚动/portal变换后的几何，不读业务坐标。

方向候选先首选边，如主方向空间不足则尝试相反边；两个均不足取可用主方向空间更大的一边，等大保留首选。交叉轴start对齐anchor，随后钳制到host；弹层自然尺寸受host实际尺寸约束，min不能强撑。溢出内容靠其公共ScrollView访问，不把整个弹层绘到host外。每次相关layout/scroll/resize重新定位，失效旧/新区及阴影；不改变节点身份/滚动状态。

anchor卸载或有效hidden时关闭AnchorGone；单纯disabled不改变几何锚点，也不隐式禁用已打开弹层，避免触发控件禁用以防重复打开时自闭；owner失效优先OwnerGone。anchor只是被scroll裁剪时不等同卸载：将几何锚点与host求交，非空时用交集；完全空时**关闭anchored非modal层**以避免漂浮菜单，使用AnchorGone原因（此原因也包含当前不可见锚点，不只卸载）。本期禁止Modal带anchor，避免隐含Center位置fallback。零viewport导致所有clip空时不据此关闭modal（其本来无anchor）；anchored nonmodal关闭规则相同且有明确原因，不假称保留。此策略已固定；替代“挂载保留但临时隐藏”会引入隐藏期间焦点归属/恢复/再次夺焦点更多状态，见决策点。

#### C.7 同组件类型复用

普通位置：`Column { SettingsPanel(model) }`；弹层位置：构造**另一个未挂载的** `SettingsPanel(model)`，由owner.openOverlay(..., OverlayOptions(mode:Modal))挂载。同一组件类/业务model，不要求继承Popup、不需要第二build、更不允许同一Component实例同时挂两处。若把已卸载实例重新挂载，按现Runtime生命周期开新代际；不是跨父move，不承诺保留原NodeRef/focus/本地offset。组件公共API在普通与弹层中完全一致，区别只在外部owner/host关系和实际约束。

### Shared errors and lifecycle responsibilities

| 情况 | 建议结果 | 权威责任 |
|---|---|---|
| 不合法负尺寸/上界/参数组合 | IllegalArgumentException，变更前拒绝 | 公共值/入口校验 |
| 错误线程/活动跨session | WrongUIContext，不能驱动他人UI | Runtime现owner thread nonce/session |
| stale NodeRef | StaleReference；原isValid/sameNode例外不变 | 原挂载代际/弱引用 |
| 不适用能力/主题属性 | InvalidProperty | primitive能力矩阵+唯一resolver |
| 不满足focus条件 | InvalidFocusTarget；模态域外另FocusOutsideDomain | focus/router |
| 过期PaintContext | ExpiredPaintContext；任何读/写均拒绝 | paint调用generation |
| getter/measure/draw中修改状态 | ReentrantEvaluation；结构型修改沿ReentrantStructure | 统一阶段guard |
| lifecycle直接结构/焦点/滚动/层命令 | LifecycleReentry；可post下一turn | Runtime安全边界 |
| overlay content重复挂载/预留 | AlreadyMounted；不能半发布层 | 原reserveMount+结构命令 |
| 错host/anchor关系 | InvalidOverlayHost / InvalidOverlayAnchor（固定新码） | overlay预校验与提交复核 |
| 层/命令/依赖/深度超限 | CapacityExceeded；沿RuntimeLimits节点/结构op/dependency预算 | Runtime/overlay，不另无限队列 |
| 回调/绘制失败 | 保留原异常，停session，先撤销再清理，聚合附加清理失败 | 原Runtime/UICleanupException/native围栏 |

新增错误名在本设计固定但尚未实施；微编译/测试不得用另一错误码替代。命令受既有structuralOpsPerBatch等预算，overlay深度计入treeDepth，层content计mountedNodes，measure/draw两份依赖计入公开limits的绑定/依赖预算。每个Canvas固定两份计算记录，不因每帧附加订阅。卸载取消二者、caret请求、viewport pending、focus请求、owner layer；弱handle不让session整树永生。

旧路径保留/迁移：现Text/Row/Column、Frame、Style、Unicode、ansies、单Runtime、render参考保留；仅把当前Application直接interrupt默认移入统一框架默认阶段，不复制旧默认分支；当前设备root目标选择由activeTarget替代；layout的唯一坐标/clip与viewport合并；主题既有resolver继续权威。新增Canvas kind是唯一通用绘制叶能力，不为每个控件再开switch。


## Risks / Trade-offs

- [M1性能误承诺] → 独立依赖集合与dirty类别可验证，但M1完整measure调用数不能以M2标准判失败；纯模型缓存也不等于编辑算法交付。
- [当前主题API推进] → 精确消费T016的StyleRule.withValue及T013/T014只读桥；根包负责runtime/resolver，theme/style纯值子包不得反向import根包。
- [默认动作双执行] → Target消费、框架互斥分支、Ancestor最近可移动者消费有可观察trace；旧interrupt直接分支退役，只保统一默认路径。
- [非滚动几何与虚拟extent混淆] → 最终Frame一直实际尺寸；Constraints无界轴不能用Int64.Max模拟设备；普通非滚动flex原规则保留。
- [owner既是事件归属又被误作行为继承] → 普通祖先disabled合取，跨overlay边不继承行为enabled；owner hidden明确关闭依赖层；样式继承仍遵主题合同。
- [源文件与回归共写] → A/B/C按接受产物串行，测试/产品/审查隔离；后续单位只接固定源，不借共享工作区HEAD推断前置完成。
- [签名语言可行性] → 必须用实际SDK和正常包消费者微编译全部重载/默认参/只读属性/跨包导出，编译失败先调整合同再freeze；不能写Any、公开内部可变状态或额外renderer兜底。

## Alternatives considered

原比较结论已被I001–I003采纳。generic state getter把caret和全文绑到同一失效，双快照getter增加类型/复制协议；数值默认动作priority增隐式排序；无条件把全部根改B2自然基准破坏短weighted布局，已改选有overflow摘要的最多两pass兜底；返回异步scroll ticket不能立即决定默认消费；新overlay renderer复制生命周期；强制background(Default)压死主题；锚点保留挂载暂时隐藏需要额外输入暂停/再现夺焦点协议。各替代技术上可行，但本轮没有胜过已采纳方案的需求证据，不再平行实现。

## Migration Plan

这不是部署或发布变更。主代理将此目录纳入主仓前先安排声明微编译与独立preflight，冻结hash；随后按tasks的固定输入角色链执行A、B、C并各自验收。旧设备root目标选择迁移到activeTarget；旧默认interrupt迁入统一默认阶段；Frame/Layout/Unicode/主题resolver保留唯一权威。没有旧Button/Input公开产品API需要兼容alias。

每阶段提交保持可逆，失败修复只回退该阶段未接受产品提交或作有证据的定点修复，不降低冻结测试/规范。关闭或异常沿现会话清理与设备恢复，不回写旧帧。父AC在各自全范围证据满足时由主代理同步长期任务/验收映射；本目录支持任务勾选不自动关闭父项。

## Verification boundary

本候选保留所有新增签名“未编译验证”状态；API语法微编译、preflight、正式独立测试/实施/审查/执行/验收均有不同证据职责。工件schema校验只能证明OpenSpec格式，不能证明Cangjie语法、产品行为或工程DQ已通过。原草稿和来源hash见同目录provenance.json；不依赖主代理读作者自评。

## I011 同会话公共应用服务的只读装配

新增`public func application(): Application`于NodeRef。返回当前挂载关联的同一个公开Application，不启动会话、不pump、不创建服务/队列/注册表。使用同UI只读context guard，允许getter/measure/draw取得引用；stale报StaleReference、异线程/活动跨域报WrongUIContext，极端无Application关联报SessionInactive。临时render本身不发布NodeRef。返回引用可以由调用者保存，但Application每个方法仍守其已有阶段/线程/stop/post约束，取得引用不带来写权限。由此公共自定义组件和后续TextInput能用同一个Application的post与可选clipboard服务，不添加只为编辑器的NodeRef.copy方法、不要求常规输入构造注入应用回调。关联是当前mount身份，不持有过期RuntimeNode强引用。

## I012 统一resolver的自动行为外观状态

Theme原VisualStates仍只表达外观，不修改业务enabled、焦点或选中值。A阶段统一resolver在既有声明状态上合成实际行为状态：`disabled = !effectiveEnabled || declared.disabled`、`focused = actuallyFocused || declared.focused`、`selected = declared.selected`。effectiveEnabled沿普通祖先合取，跨overlay ownership边不隐式继承，复用A既有行为规则。false不屏蔽真实禁用/焦点；希望调整外观时应用可用原显式样式逐字段覆盖。selected始终由业务/视图声明，不因focus或disabled自动修改。

普通/标准控件不必用NodeRef读取行为态再拼另一套visualStates。Checkbox/Radio可只声明业务selected，实际focused/disabled由同resolver加入，祖先禁用与后链.enabled覆盖会自动呈现。detached全局render使用同Runtime求值的effectiveEnabled，未发布ref仍能显示disabled；无真实focus时actuallyFocused=false，显式focused演示仍有效。已冻结Theme基础085在未启用新行为槽时结果不变；I012是后续A的明确集成增量，不反写Theme基础验收。A正式测试须覆盖离线、祖先disabled、后链.enabled、显式视觉态仅增加/不反写行为、真假focus与selected保持。

## I013 轴关闭值的源码兼容修正

ScrollAxes的关闭值最终为Off（不是未实现草稿None），其余Vertical/Horizontal/Both不变。SDK1.2独立正常consumer已实证根包导出的None构造会使既有裸Option None用法报multiple constructor；Off保留关闭语义且原裸None正常编译，不要求应用为新增轴枚举重写Option值。此阶段尚无该轴产品/正式测试，故不提供冲突None兼容alias。所有本变更axes表与示例以Off为准，Option.None含义不变。

## I014 基础域初始焦点与空层保留

startHeadless/run完成初始挂载与同步稳定后，在首次目标帧之前自动选择基础域物理前序的首个eligible候选；全空保持None。onMount自身不因这一步重新调用，stop已请求则不再选焦点。此前没有焦点且普通结构/显隐/启用变化产生候选时，也在安全边界选首个；已有有效焦点仍按A规则保持/失效回退，不因新增或重排抢焦点。焦点变化照常使只读查询/样式依赖失效，返回初始headless边界前稳定到一致。

C的显式takeFocus空交互层是例外：仍保持focusedNode=None及该层activeTarget，不自动抢回基础域。该层随后产生eligible孩子时选该层内首个；Tab或显式requestFocus仍按当前域导航，成功离层后遵原目标层规则。Passive从不设此保留。此补充只冻结原来未明确的初态，不增加autofocus配置或改变应用数据/显隐。098增加初态/后增候选，108增加空层保留/后增候选的手工期望。

## I015 原生caret显隐：一次有界查询与自动保守降级

本节为root工程裁决，需独立限定preflight，不代表A/020已实施。事实来源 `/workspace/work/cursor-capability-recon/report.md`：真实XTerm398/VTE0.80.1能报告原显隐；Linux6.12.107 tty1无回复且25s/r不恢复原态。不得按TERM猜测。原A.6“退出恢复设备原光标模式”限定为本节：已知可管理并恢复，未知从未改变显隐而保留原态，逻辑caret继续成立。实测候选设计来源 `/workspace/work/cursor-protocol-design/draft.md`，最终权威是本节。

root比较阻塞缓存600ms、异步一次查询、永不查询三条路线，选择异步复用唯一decoder/writer，无缓存与普通输入延迟；Unknown不发送显隐命令，不提供软件caret，不要求应用判断终端能力。DECRQM无nonce：协议报告只在同一会话独占终端输入/输出假设下作依据，不能认证外部并发进程/用户注入同字节，也不保证外部同时改mode25后仍能恢复。

### 1. 生命周期与有界窗口

1. run取得唯一native设备、创建唯一decoder并装配包内mode25接收入口。startHeadless依I014完成挂载/稳定/首焦点；若此时已stop或失败，不发query，不改25。
2. 在首个设备目标输出之前，经唯一writer发送一次 **7 bytes** `ESC [ ? 2 5 $ p`。该次是独立完整输出事务，不拼入用户文本，不占mode25 saved slot；无后台线程。只有完整写成功才进入Pending。原frame baseline不因query提交。
3. 完整写后读取单调时间 `t0`，deadline=`t0+600ms`（检查加法）。在发送前也须确认单调时钟可用，若失败则不查询并保持UnknownClock；发送后读取失败同样UnknownClock。无墙钟/帧数推算。600是保守工程上限，沿用调查窗口；不是所有宿主的响应保证。
4. 立即进入既有UI/输入循环。Pending与Unknown均不得发25h/l；有效逻辑caret仍最终CUP定位。回复从原cjt_read→原decoder路径输入，普通键立即按现行安全边界派发，无查询缓存、无重放、无第二队列。
5. 每次可能读取之前、返回输入之后及安全UI边界检查时钟。`now >= deadline`首先将Pending终结为UnknownTimeout；只有完整reply最后字节在本机被处理时 `now < deadline`才可授权，等于截止也不接受。无法知道OS队列实际到达时刻，不据推测追溯授权。
6. 持续输入不延长deadline。poll超时取既有输入空闲/事件循环要求与剩余探测时间的最小值；探测deadline唤醒本身**不调用decoder.timeout**。100ms键盘idle以距上次实际输入计算，不能把20ms的probe唤醒误当100ms idle。无须等待600ms结束才显示第一帧。
7. 600ms只约束授权窗口；不承诺阻塞write、用户callback或OS调度在600ms内返回。即使UI被callback占用，恢复后先检查deadline，已迟到reply不能升级。单调时钟运行中失败终结Pending为UnknownClock，继续保守运行。
8. 固定使用最小Linux内部FFI `cjt_monotonic_ms(): Int64`（C侧int64_t(void)），CLOCK_MONOTONIC非负毫秒；调用失败、负秒、乘加溢出返回-1。沿native现有编译/FFI桥，不增加产品依赖/public计时API；独立preflight须以实际Linux工具链微编译确认签名/头文件可用，不假称产品已实现。只在Pending及既有输入idle计时所需时读取，结束probe不额外每byte做probe时钟调用。

### 2. 精确状态与限额

每run一个ledger：`NotProbed | Pending(deadline) | Known(originalVisible) | Unknown(reason) | Closed`；originalVisible只接受1/2后写一次。包内字段保留是否query已完整发送、最近完整成功的设备caret输出、是否曾完整成功改变显隐；数据量O(1)，不保留输入payload/报告历史。deadline只允许一次，不自动重试。

| 输入/事件 | 状态结果 | 输出权限 |
|---|---|---|
| 完整query写成功+可用时钟 | Pending | 仅原屏幕/CUP，不改25 |
| Pending内首个精确report `...;1$y` / `...;2$y`，完成时未到deadline | Known(true/false) | 下一安全设备边界管理显隐 |
| 精确status0/3/4 | 消费，保持Pending至正常deadline；可记一个bounded“已见不可用报告”位 | 不升级、不猜永久set/reset可改 |
| 错mode、额外参数、leading zero、非法status、SS3、非精确7bit introducer | 按原/后续Keyboard合同的未知/畸形分支 | 不升级；不误作成功report |
| Pending到期 | UnknownTimeout（可在内部原因附unusable-report） | 不改25 |
| Known后重复/矛盾精确report | 消费，保留首次original | 不覆盖恢复原态 |
| Unknown后迟到完整精确report | 消费，Unknown不再升级 | 不改25 |
| stop/signal/EOF/异常 | Closed；保留已有original供必要cleanup | 未知时没有25恢复输出 |

唯一decoder在既有CSI转移上增加固定精确路径 `ESC[?25;P$y`，P仅ASCII 0..4，总长9bytes。无需9bytes实际缓存，prefix index+单digit即可；正式工程契约匹配状态最多0..9，失配退回同CSI的既有框定/丢弃规则，**不再feed已消费byte、不向别处回放**。识别仅7bit ESC [，不能因现state2也代表SS3便接受ESC O；也不默许raw/UTF8 C1版本取得管理权。超长伪造参数走原/升级后的CSI有界drain，不积累数字，不留任意长“可能回复”buffer。

A现有状态机不另扩展完整Keyboard语义；只增加I007和本单一reply分支。mode25接收者是包内固定接点，不公开构造参数/事件类型：A可在final byte调用无用户回调的包内接收方法，只更新ledger并标设备caret需重算。它不输出、不更改逻辑焦点、不执行业务callback。因此无需通用通知容器/队列。将来Keyboard内部有序通知可承接同一固定分支，退役原InputDecoder时不得并存第二parser。

设备run安装此接点直到停止读输入，因此Pending结束后仍能吞掉完整回复。未来公开独立KeyboardDecoder没有会话接点/不发query，相同字节依其未知CSI规则给UnsupportedSequence；public KeyboardBatch不新增protocol事件。raw/UTF8 C1等其他形态维持F002既有规则。

### 3. 诊断顺序、真正timeout与分块

root明确采纳：600ms probe截止只关闭管理授权，不reset/feed/finish/timeout decoder。跨deadline仍是同一CSI，最后字节到期后完成则吞reply、无KeyEvent、无KeyboardDiagnostic、不能升级。1/2与0/3/4的精确报告在设备会话均视为protocol，不暴露业务输入；重复同理。

**“完整reply”限定同一未被键盘timeout/cancel打断的CSI。** 全Keyboard K002的100ms实际idle仍可对未完成CSI产生IncompleteInput并回normal；随后字节依normal解析，不声称任意间隔后拼起来像reply就能永久吞掉。裸ESC尤其无法与单Esc按键无歧义区分。禁止为此加入长期quarantine或改写K002计时。A当前CSI没有该timeout，升级后按K002新合同；A→Keyboard的测试应区分这一明确阶段差异，不能把A旧timeout实现当完整Keyboard最终语义。

F003的顺序保留：每个已形成key/issue先完成自身普通UI callback和稳定提交，再消费后续byte；probe内部final处理也在其真实流位置同步发生。精确protocol报告没有业务diagnostic callback，不产生新事件队列。坏/非精确CSI在完整Keyboard仍按K002/F002/F003诊断，这些callback可能改焦点，后续paste-start必须看到已提交结果。reply字样在paste/string payload中不能抢占原状态，paste保持原子与目标锁；仅在normal引导的CSI分支识别。

A不为了query引入KeyboardIssue公共接口。现有TCSAFLUSH开头丢输入是原native语义，**本正式工程契约“无丢失”只指查询不新增flush、缓存满丢弃、吞普通已读取按键或重新解码**。完整输入后续若承诺保留open前typeahead，应单独核改TCSAFLUSH，不能在本正式工程契约顺手扩大scope。

输入资源：query额外输入buffer=0、额外事件queue=0、matcher/ledger=O(1)。A原单byte读天然每轮≤1byte；Keyboard K004升级后每UI turn≤4096bytes，原post cutoff/安全提交和OS背压不变。未来Keyboard状态仍O(maxPasteBytes+maxSequenceBytes+常数)，该分支纳入普通sequence预算，不绕过用户很小maxSequenceBytes。默认64容纳9bytes；设置<9时可能SequenceTooLong→Unknown，不另设超预算协议例外。

### 4. 逻辑与物理输出

A.6的CaretSnapshot仍是“最近完成目标帧的逻辑请求”：owner、坐标、visible按焦点Canvas/clip/宽簇/遮挡判定，headless等价。I014初焦点不等probe。设备Pending/Unknown不把逻辑visible改false，也不靠它伪造物理能力。

在每个安全设备边界，用该时刻最新已完成目标caret生成输出；Known刚取得时强制考虑设备caret，即使网格不变。不保留旧reply时的逻辑坐标作为待执行命令。成功基线=完整成功写出的网格/profile+设备caret计划，只有全部字节成功才提交；失败不能提交部分caret。

Known模式：逻辑隐藏则25l；逻辑可见则最后CUP到合法单元并25h。可按既有渲染计划在重绘前临时hide，前提Known且整个计划归同一writer；成功后ledger记录最终模式。Unknown模式：**所有路径，包括首帧、重绘、caret-only、模式初始化和cleanup，均不得含25h/l、25s/r**。逻辑可见时在画面输出后CUP到最新坐标；逻辑隐藏无额外caret CUP，终端光标可能仍停在画面writer最后位置。未知原visible时无请求仍可能显示，原hidden时有请求也不会显现；这是公开自动降级限制，不是逻辑caret失败。

位置变化与能力变化可触发caret-only输出，不新增renderer。全局Frame导出不包含设备模式query和caret。root承诺的是显隐原态恢复，不声称恢复退出前原光标坐标/shape/blink；这些不能由本次mode25调查推导。

### 5. writer与退出：root已裁决依赖重排

当前源码的真实围栏只有write异常→停止run/报告→静默native close；没有partial/zero区分或跨run闩。A新增恢复字节后不能继续援引“沿原围栏”却在任何write错误后盲发25h/l。给A再写一套计数/闩会侵占149唯一权威；本正式工程契约不这样处理。

**root已采纳工程顺序：固定RichText084后，先有限Session148→149→150→151→152；再Glyph094–097/Theme088+load092；随后A098/099（080/084/088保留并新增152），再B/C/Keyboard。** 这是现授权内可逆工程编排，无需新用户许可；计划不等于ready。

依赖证据：session tasks §4 TASK149 inputs列148固定测试、004子合同、已验runtime固定整合、R10、003；没有A102/B107/C112。149.S2唯一实施native byte计数与unsafe闩。有限152不提前关闭paste/cut完整030、020或041，所以`152→A102→B/C→Keyboard114`无环。正式任务卡、Linux计划、输入F001均须由root同步此新前置，不能只改本文。

本正式工程契约消费S008实际固定交付：query/屏幕/25输出/cleanup串行同writer。query任何write失败按S008终止run、首错保留；部分失败闩outputUnsafe且后续屏幕/25/title/2004全部零输出；native termios/signal/buffer清理继续。分配失败属于零设备字节，不伪造已发送query；A可沿既有抛错路径结束且保持原态，不把AllocationFailed写成成功探测。

正常/应用异常/stop/signal/EOF退出：先停止input/probe授权，在唯一cleanup路径按**已经取得original且实际管理过mode25**记录恢复显隐；writer允许才发精确原25h或25l。恢复写成功只表示协议字节完整交付，真实host效果仍须产品证据。若没有实际改变原模式可不发冗余恢复；不得因logical caret曾变化就猜设备变过。任何outputUnsafe禁止恢复输出，报恢复不足并聚合首错，不能由termios成功推导显示模式恢复。零byte故障后的清理按S008既定允许范围；若设备不再可写则明确恢复失败，不能重试到无限循环。恢复自身失败同一闩/聚合，不二次“补救show”。

EOF在A继承现cjt_read -3错误路径也须cleanup；不得声称A已经有Keyboard -4 EOF新语义。K004新增EOF后按F003先finish/有序末尾diagnostics，再stop/cleanup且不生成新设备帧；晚到reply不能在关闭阶段取得授权。signal/stop不额外制造诊断回调。再run创建新ledger/decoder；native进程期unsafe闩不能被新run绕过。

### 6. 只读诊断与生命周期（root采纳唯一公共增量）

现有public struct TerminalCapabilities增加 `public let cursorVisibilityStatus: String`。包内现init尾部新增named参数 `cursorVisibilityStatus!: String = "not-probed"`；不增加public构造/设置/probe接口、不改变颜色source/reason、colorOverride或glyph字段语义。闭集为 `not-probed`、`pending`、`original-visible`、`original-hidden`、`unknown-timeout`、`unknown-clock`。known只说明收到过原态报告，不说明当前像素/恢复成功。诊断无需业务分支，普通应用依旧自动运行。

Application.terminalCapabilities()原只读入口返回完整不可变值快照；每run在其现有颜色能力初始化点建立not-probed，在query完整成功后Pending，同步接收/截止时更新副本不改颜色字段。getter只读不pump/不触发查询，不新增Observable依赖承诺。关闭后保留本run最后诊断；再次run在现能力初始化点重置。未运行first headless返回None；headless不创建/覆盖实际设备能力，曾有run则保留现lastCapabilities原生命周期。挂载/检测前失败保留原有last值，不能伪造本次probe。若查询写失败，执行S008原错误路径，诊断不代替原primary/cleanup结果。状态Closed只是内部ledger，不公开第七字符串；已获得原态在cleanup后仍是original-visible/hidden。

### 7. 正式验证门槛

098正式测试增加：精确7bytequery/9byte报告、0..4及所有分块/错误形态、普通键/UTF8/HT/Backtab/interrupt相对顺序、截止599/600且持续输入不延长、跨截止分块不触发timeout、真正100ms断流单列、Unknown/重复/迟到不升级、known后caret-only更新、snapshot逻辑与物理策略分离。A当前InputDecoder的有限timeout与最终K002完整timeout差别须显式测试，不把A当117。

时间精确判定可用原生link fault clock shim/受控PTY oracle（仅测试，不加公开可写时钟）；短读/错误/overflow路径均有原件。正式实际XTerm/VTE/VT在visible和hidden两种受控初态运行同一无override产品，PNG多帧避blink、原bytes/termios/exit/version/config/src/hash；Unknown全wire无25h/l/s/r，逻辑snapshot与有效CUP仍正确。query/帧/caret-only/cleanup零/部分错误遵S008，unsafe后零后续output并保留native资源清理/首错/reopen拒绝。复用未变S008证据，仅补query/caret新边界，不重复全矩阵。

未来113/114继承同一精确内部reply分支、payload隔离/F003顺序/4096预算，无接点public KeyboardDecoder仍UnsupportedSequence，maxSequenceBytes=8/9/64不豁免9byte报告。reply实际100ms timeout打断后沿K002回normal/诊断，不保证任意间隔可重新拼回。152/080/084/088实际接受后方可098完整准入；独立preflight仅设计事实，不替代该产品屏障。
