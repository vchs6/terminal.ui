# 持久组件与响应式运行时：独立接口草稿

状态：主代理采用并细化的正式候选契约，2026-11-10；下列原草稿仅在不与第6节最终裁决冲突时有效。独立 builder/preflight 通过后冻结测试、实施。范围为 TASK-002/004 子接口、014 构造部分、015/016/032；014 跨弹窗 AC 仍在 018 后汇合。

身份记录：委派指定 `Astra/high` 作架构判断；本角色当前可见开发者身份为 Codex、based on GPT-6，未获得可核验的运行时具体模型变体/effort 元数据。因此记录“指定 Astra/high，实际具体变体不可核验”，不把指定配置冒充实测身份。主代理为正式契约裁决者与作者。

依据：brief、AGENTS、requirements REQ-001/002/003/004.8/009.1、ui-construction、architecture、linux-completion-plan；源码只取 `31a7017` 的 Component/Application/KeyEvent/export 起点；语言报告及 probe/base_library.cj、subclass.cj；正常 CJPM/bundle 探针报告。使用 brainstorming 技能组织取舍；按明确委派直接交草稿，不提问、不派代理、不写实施计划。以下签名是待编译冻结的接口草案，已有探针只证明构造机制与宏打包，不证明本文完整 API。

## 1. 推荐划分与拒绝的替代方案

沿用一个 Component 构造模型、一个持久 Runtime、一个 Frame 路径。首个可测单元 A 为构造/身份，B 为绑定/调度，C 为混合结构。A 的生命周期与句柄先冻结，B/C 按该接口交互；C 依赖 B 的失效和安全提交。事件最小协议属于 A/B，焦点、完整键盘解码、主题、编辑、overlay、M2 各自仍是下游单元。

每帧重建 build 虽易实现，却破坏局部身份、交互状态和性能要求；不选。动态 ForEach 包成容器虽省协调逻辑，却不能满足 A/X/B/C 同序列；不选。全业务事务回滚需要追踪应用数据和任意副作用，既无既定承诺又不可实施；只保证单项结构提交先校验、后修改，batch 不承诺业务事务回滚。

## 2. 单元 A：构造、节点代际与公共事件

### 2.1 构造和最小公开签名

```cangjie
// cjtui；保留所有现有工厂/链式属性/构造重载。
public open class Component {
    public init()
    public open func build(): Unit
    protected func finishConstruction(): Unit
    public func reference(): ?NodeRef
    public func key(value: String): Component
    public func onMount(effect: (NodeRef) -> (() -> Unit)): Component
    public func onKey(handler: (UIKeyEvent) -> Unit): Component
    public func onKeyCapture(handler: (UIKeyEvent) -> Unit): Component
}
public func Text(value: String): Component
public func Text(value: () -> String): Component
public func Row(body: () -> Unit): Component
public func Column(body: () -> Unit): Component

public class NodeRef {
    public func isValid(): Bool
    public func sameNode(other: NodeRef): Bool
    public func notify(change: ChangeKind): Unit
}
public enum ChangeKind { Bindings | Content | Style | Layout | Structure | All }
```

`NodeRef` 无公开构造、无裸 Component/RuntimeNode 指针暴露；内部标识至少为 `(runtime session nonce, node serial, mount generation)`。isValid 可任意线程读取；notify 可任意线程投递，失效 ref 明确抛 RuntimeException(StaleReference)，不静默触发别的节点。sameNode 比较完整身份，不仅 serial。reference 只在活动 UI 域查询；未挂载返回 None。同实例不能同时挂载到两个父/会话（AlreadyMounted）；两个视图共享业务 Observable，分别实例化组件。

`@Component class Counter { @State var count: Int64 = 0; init(label: String) { ... }; func build(): Unit { ... } }` 在 `cjtui.macros` 中由原生编译期宏处理：添加基类 Component、build 的 public override、每条成功构造路径末尾的 finishConstruction。无 init 时生成无参 init；支持带参数显式 init 与普通字段/方法，不覆盖原参数初始化。首版拒绝自定义 superclass、泛型组件、继承组件、构造委派链、用户显式 finishConstruction/冲突生成名；支持接口的具体语法若未额外实证则明确报 unsupported，不能悄悄丢弃。显式 init 的 early-return/throw AST 路径必须做独立负向/正向语法验证：抛出路径不登记，不在 finally 中 attach。

Component 的 open init 只初始化基类字段，绝不 attach(this) 或虚调用 build；SDK1.2 已明确拒绝前者。最终派生类构造完成后调用 protected 方法，保存到当前线程 collector；同实例重复 finish 为 ConstructionAlreadyFinished。Row/Column/Text 走相同登记协议；新开放 Component 本身保留可构造的空组合根语义，公开手写派生类需显式调用 finishConstruction，宏是常规入口。

build 延迟到运行时首次 materialize，每 Component 实例最多调用一次，构造异常则该实例永久 failed，不重试其半构造结果。缓存的是子描述/属性 getter/事件定义，不缓存首次求值结果。重挂载该实例不再次 build，但创建新挂载代际、重新求值绑定/运行 onMount。build 内普通 if/for 是一次性构造；动态变动必须用 If/ForEach。每个 collector 是 ThreadLocal 栈，try/finally 恢复；建 detached 描述可在未拥有运行节点的线程执行，挂载/变更仅 UI 域，不能把不同线程、不同 Application 的孩子串在一起。

静态声明位置是一次构造中 collector 的稳定 ordinal；显式 key 在该逻辑父的直接声明范围内唯一，字符串按字节精确相等、非空。key 在首次挂载后不可变。动态组使用其稳定 group id + item key 区分静态声明和其他组，因此两个组可各有 key "a"。每个实例的对象存活不等于旧 NodeRef 存活；移位保留代际，卸载再挂载必须换代际。组件实例自身的 @State 是该对象拥有的数据，复用实例时保留；运行节点拥有的焦点/滚动/控件局部状态随卸载销毁，新代际重新初始化，不能混为同一种所有权。一次卸载先标记整个子树无效并撤销队列 token，再释放订阅/活动事件/布局引用，最后由孩子到父执行清理函数，最多一次。清理抛错仍继续清理其余资源，保留首错并汇报后续错误计数。

`onMount` 在节点和首批绑定完成后、首帧前执行，返回清理函数；副作用本身抛错则失败退出当前 session 并清理已登记的资源。卸载取消的是运行时持有的闭包/订阅；应用主动持有的 Component 描述仍可持有业务回调定义，框架不能承诺销毁应用引用的对象。

### 2.2 事件边界（不抢先实施焦点系统）

```cangjie
// KeyEvent 保留 code/text；增加公开构造用于 headless 注入。
public init(code: String, text!: String = "")
public class UIKeyEvent {
    public let key: KeyEvent
    public let target: NodeRef
    public prop currentTarget: NodeRef { get }
    public prop defaultPrevented: Bool { get }
    public func preventDefault(): Unit
    public func stopPropagation(): Unit
    public func consume(): Unit
}
// Application 旧 onKey((KeyEvent)->Unit) 保留；新增：
public func onKeyEvent(handler: (UIKeyEvent) -> Unit): Application
```

显式目标入口用于本阶段测试，后续焦点管理只负责选目标。dispatch 固定当前有效父链：根到目标 capture，再目标到根 bubble，最后域内 application handler；同节点 capture/bubble 是两个明确阶段。consume = preventDefault + stopPropagation；单独 preventDefault 仍冒泡，单独 stopPropagation 不阻止默认动作。未来控件默认动作在路由后执行且尊重 defaultPrevented。旧 Application.onKey 在新 application handler 后且未 consume/stop 时执行一次；默认处理之后不再调用旧 handler。任何回调只能取得当次事件对象，退出 dispatch 后的传播修改抛 ExpiredEvent。

当前无 modal 的 domain 就是整个 Application；预留内部 `dispatchInDomain(target, domainRoot, event)`，后续焦点/overlay 必须限制父链及 app handler 到允许域，不能把“未处理”作为穿透 modal 的依据。本单元不声称已实现 modal/focus。回调中的结构操作排队到完整事件路由后，因此该事件沿旧有效路径完成；应用希望立即阻止祖先回调须调用 stopPropagation。框架不在遍历中半移除节点。失效/跨 session target 在 dispatch 开始前拒绝。

### 2.3 A 的职责/验收

文件：component.cj、component_collector.cj、runtime_node.cj、node_ref.cj、mount_scope.cj、ui_key_event.cj、runtime_exception.cj；宏分 component_macro.cj/state_macro.cj/bind_macro.cj。每个类/结构/接口/枚举独立文件；函数按职责合并。现 kind 0/1/2 可暂保留为三种基础布局 primitive，不能为 Button/Menu/业务组件增加 kind。用户组件只组合公开组件/事件；后续高级 paint context 以现 Frame 提供的受控绘制入口扩展 primitive，不复制宽度/合成内核。

独立验收：参数 init 正向及宏负向诊断定位；构造后 build=0、首次 materialize=1、属性失效/remount 后仍=1；嵌套/异常 collector 清理；同实例双挂载失败；移位 ref 保持、卸载 ref 失效、重新挂载旧 ref 不复活；事件 capture/bubble/默认阻止分别计数；每个 cleanup 恰一次。

## 3. 单元 B：可观察值、typed 绑定与同一 UI 调度

### 3.1 签名与跟踪

```cangjie
public class Observable<T> {
    public init(initial: T)
    public init(initial: T, equals!: (T, T) -> Bool)
    public func get(): T
    public func set(value: T): Unit
    public func notify(): Unit
}
// 实际链式返回类型仍为 Component，保留旧常量重载；以下新增：
public func foreground(value: () -> Color): Component
public func background(value: () -> Color): Component
public func width(value: () -> Int64): Component
public func height(value: () -> Int64): Component
public func visible(value: Bool): Component
public func visible(value: () -> Bool): Component
// 所有已有 Bool/Int64/Color/Alignment/BorderStyle 链属性按同型闭包扩展；
// shadow 的复合输入保留常量，新增 getter 对应独立 ShadowSpec 时另行冻结。
```

@State 要求有显式类型和初值，变换为私有 Observable<T> + public mut prop；拒绝 static/let/重复注解、无类型/初值及 unsupported 成员，并保留源码位置。宏 State 与 runtime Observable 不同名。`@Bind(expr)` 只生成 `{ => expr }`；直接 typed closure 同等支持。`Text("${x}")` 是普通初值，`Text(@Bind("${x}"))` 或 `Text({ => "${x}" })` 保存计算规则，不能声称任意仓颉表达式都会自动变绑定。

每个绑定记录 getter、目标属性、依赖集、挂载 token。UI 求值期间 Observable.get 自动登记，条件分支变化后用本次依赖替换上次依赖。读值和该状态版本在 Mutex 下取得；求值后安装订阅并复核版本，期间写入则再入队，避免“读取后、订阅前”丢更新。嵌套 collector 保存/恢复 ThreadLocal；后台 get 不登记 UI 依赖。getter 不可改 Observable、节点、结构或递归驱动 snapshot/dispatch，统一抛 ReentrantEvaluation（防止读写循环）。

Observable 的 value/version/订阅元数据线程安全；set 可在后台调用，只更新数据并投递去重失效，绝不在后台运行绑定/节点/用户 callback。锁内不调用 equals/user getter/回调、不等待 UI；自定义 equals 的候选值在锁外比较后，提交需重查 version，冲突重试有界。建议更简单的初版：无 equals 时每次 set 都增加版本；有 equals 时 UI 绑定目标仍做按属性值相等过滤。若自定义 equals 导致实现负担，可在冻结时删除该重载而不承诺泛型 ==。Observable<T> 不深拷贝应用可变 T；线程安全承诺覆盖值槽，T 内部突变由应用同步，并调用 notify。禁止把“get 一个可变对象”当作深度可观察。

节点 notify(Bindings) 重算其已保存全部属性 getter；Content/Style/Layout 分别重算该类别 getter 并传播相应 dirty；Structure 仅重算该节点直接声明动态组的数据 getter；All 合并以上。它们不重新 build、不递归扫整树。Observable.notify 通知所有订阅它的绑定，多视图均更新。普通变量修改后通过相应 ref.notify 定向重读 getter；只设置 dirty 而继续使用旧值不合格。

同一属性的后续常量或 closure 链调用替换该属性当前 binding 并解除其旧依赖，最后一次调用生效。visible(false) 保留挂载/状态/订阅，但不占布局、不绘制、不成为后续输入目标；If(false) 才卸载。尺寸/显隐变化影响布局，纯颜色/属性变化只标记 paint；M1 可全量布局绘制但不能重建描述，dirty 分类必须为后续 M2 保留。

### 3.2 调度、导出与生命周期

```cangjie
// Application 所有既有 init/run/stop/onKey 等保留。
public func post(action: () -> Unit): Bool
public func post(owner: NodeRef, action: () -> Unit): Bool
public func batch(action: () -> Unit): Unit
public func startHeadless(): Unit
public func snapshot(width: Int64, height: Int64): Frame
public func dispatch(target: NodeRef, event: KeyEvent): Unit
public func dispose(): Unit
public func render(root: Component, width: Int64, height: Int64): Frame
```

run/startHeadless 建立 `(Thread.currentThread.id, session nonce)` 所有权；不能仅凭可复用线程 id。run 的 poll/唤醒入口与 headless snapshot/dispatch 进入同一个 Runtime.pump；后两者是公开驱动边界，不提供测试私有 flush。startHeadless 完成首次挂载/稳定求值，执行 onMount；headless 无真实设备/能力探测。run 自动处理 post/state 失效，空闲100ms poll 不 build、不布局、不绘制；最多检查设备尺寸与队列。建议队列写入唤醒 poll，若首版只沿用100ms poll，必须公开自动更新延迟上界且无任何全树工作。

post 可任意线程调用，按入队序号 FIFO，成功返回 true；未启动/已结束/队列满返回 false。owner 重载额外绑定挂载代际；入队时过期返回 false，执行前过期则取消闭包并释放引用。无 owner 的 app post 生命周期属于 session，可更新业务状态，但任何旧 NodeRef 操作仍拒绝。stop 可任意线程请求退出并唤醒；session 退出注销其所有队列 token。不能把上次 run 的工作带进下一次 run。

batch 只在 UI 域调用，可嵌套；最外层完成后稳定求值、结构提交、最多形成一个目标帧。输入回调、单个 post 自动包在 batch 内。外部线程用 post { app.batch { ... } }，后台多个直接 set 可被合并但不保证原子观察。批内 Observable.get 看见已写入数据；节点结构读取看已提交序列，尚未提交的结构命令不对读取伪造结果。当前 post 里再次 post 的工作属于后续 turn。回调抛错不回滚业务值，丢弃该失败回调尚未提交的结构命令，session 报错清理退出。

snapshot 只在 startHeadless/run 的有效 UI 域调用，先处理调用前已入队任务和失效至稳定，然后读取同一完整 Frame；不能在绑定/绘制/dispatch 未结束时重入。dispatch 自动完成其安全批次，可在后续 snapshot 看到当前结果。dispose 清理 headless/session；重复调用无副作用，run 正常/异常退出自动 dispose 当前 session。Application 本体可再次启动，根实例 build 仍只一次、挂载 token 更新。

保留 render(root,w,h) 终端无关：若 root 在当前 UI session 内，它委托该 session 的 snapshot；若 detached，创建相同 Runtime 的临时“求值导出”session，materialize/求值/协调/绘制后 finally 释放，不触发 onMount/cleanup effects，不发布 NodeRef、不接收 post，不能影响一个别的活动 session。纯导出不是业务副作用执行入口；build/getter 的用户代码仍可能首次执行，要求其无副作用。临时/持久两种入口共享节点/绑定/Frame 实现，不另建导出构造器。导出本身不探测终端、不提交终端 baseline。

默认可配置 RuntimeLimits 建议：pending posts=4096、mounted nodes=100000、bindings/node=128、dependencies/binding=4096、structural ops/batch=10000、stabilization passes=64、tree depth=512。理由分别为阻止后台生产者压垮队列、合理大型TUI上界、覆盖现有属性集合、宽扇入误用保护、大批列表操作、阻止循环失效、递归栈保护；都不是业务数据上限。具体正整数构造参数须在正式签名冻结时逐个写明，Frame 容量继续使用 Frame 契约。state 失效不占有界 post 槽：每个绑定一个 dirty bit + 唤醒，不能因队列满丢更新。超限结构/依赖/深度明确 CapacityExceeded，超稳定轮数 UnstableUpdate 终止 session 并清理；post 满返回 false。预算应将持续后台写入造成的不稳定与纯用户循环同样有界处理并诊断。

### 3.3 B 的职责/验收

文件：observable.cj、binding.cj、dependency_collector.cj、ui_dispatcher.cj、runtime_session.cj、runtime_limits.cj、change_kind.cj；application.cj 仅桥接设备循环/公开生命周期，render 导向同 Runtime。状态锁、队列锁之间不能嵌套执行用户代码。

独立验收：多视图共享/动态依赖切换/相同属性结果不产帧；后台 get 不污染依赖；订阅安装竞态不丢 set；state 锁外执行 callback；旧代际 post 取消；定向 notify 运行该 getter 而非全树；无输入若干 poll 时 build/布局/绘制计数均不增加；导出无 TTY 且最新值可见；run/headless 对同状态给同 Frame；失败/限额/循环能退出并释放资源。

## 4. 单元 C：If/ForEach 与手动操作共享一个序列

### 4.1 公开形状与数据更新

```cangjie
public func If(condition: () -> Bool, thenBody: () -> Unit,
               elseBody!: () -> Unit = { => }): Unit
public func ForEach<T>(items: () -> Array<T>, key: (T) -> String,
                      body: (ListItem<T>) -> Unit): Unit
public class ListItem<T> {
    public let key: String
    public prop value: T { get }
}
// NodeRef：逻辑父节点操作自身直接孩子；返回值延后取，避免虚假有效 ref。
public func children(): Array<NodeRef>
public func insertBefore(anchor: NodeRef, child: Component): Unit
public func append(child: Component): Unit
public func moveBefore(child: NodeRef, anchor: NodeRef): Unit
public func moveToEnd(child: NodeRef): Unit
public func remove(child: NodeRef): Unit
```

If/ForEach 自身没有布局盒子；在父唯一物理 child sequence 登记稳定不可见 group-end marker，children() 只返回真实直接子节点。首版 ForEach 每个 key 的 body 必须且只能登记一个根 Component（根可 Row/Column/用户组件）；If 每个活跃分支也最多一个根，空分支合法。这保留列表各项 A/B/C 作为同级直接孩子，并避免首版多根 key 的拆分歧义；违反时 ConstructionRootCount，后续需要多根 Fragment 时另扩展，不暗中套容器。

ListItem.value 是只读可观察值槽。key 不变但 T 换成新对象时，保留该 key 的 Component/节点/局部状态并更新槽，使用 `Text(@Bind(item.value.name))` 可看到新值；不能只保留旧 body 的初次 T 闭包。body 每个新 key 的实例只调用一次；删除 key 卸载并丢弃实例，再加同 key 是新代际。items 返回的一批 Array 在协调时作为不可变快照使用；框架按其既有顺序，绝不排序业务数据。key 全量先求值并检查非空、同组唯一，再调用新增 body；重复 key 在任何树变更前报 DuplicateKey。取 key/getter 不允许节点/状态重入。

### 4.2 建议冻结的准确重排规则

**槽位算法**：当前父序列中，按当前顺序找出归此 group 所有的真实节点槽位，记作 S；先按新数据 key 顺序取得保留或新建节点 Q。以 Q 依次替换 S 的前 min(|S|,|Q|) 个位置，删除 S 的剩余槽位，Q 多出的节点紧接最后一个原 S 槽位插入；S 为空时才放在 group 的稳定 end marker 之前。manual 节点和其他组的节点/marker 都不作为 S，不被移除或直接移动；其相对顺序恒定，但两侧声明节点可变化。完成后去掉旧 key 的节点并按生命周期清理。布局/事件/children() 只消费这一份序列，不能维护第二个列表再拼接渲染。

例（竖线是内部 marker，不是组件）：

| 已提交序列 / 操作 | 结果 |
|---|---|
| A B C \|；insertBefore(B,X) | A X B C \| |
| A X B C \|；keys=[C,B,A] | C X B A \|，三个 key 的 ref/局部状态不变 |
| A X B C \|；keys=[B,C] | B X C \|，A 卸载；X 仍在其原相对 manual 次序 |
| A X B C \|；keys=[] | X \|；三个声明节点卸载，X 保留 |
| X \|；keys=[D,E] | X D E \|；不猜 X 应夹在哪两个新 key 中 |
| A X B C \|；keys=[D,A,B,C] | D X A B C \|；新节点采用第一个声明槽，溢出紧跟最后声明槽 |

这选择保留 manual 节点的序列位置语义，**不承诺 X 永远跟随 key A 或永远在 key B 前**。若业务要此锚定，它应在更新后明确调用 moveBefore；框架不猜测手动元素和业务数据的关系。替代“移旧key到目标节点旁”的算法同样可实现，但会使 manual 被拖到不同相对间隙；主代理需明确选一种并以表冻结，不能交实现者自由推断。

手动 move 允许同父的声明节点，保留声明 owner/key；下一次该组数据变更/Structure notify 时仍按当前 S 协调。手动 remove 声明节点会立即在本次提交卸载它并移除所属记录；下一次 group 协调若 items 仍有该 key，按新实例重建，不修改业务 items。数据未失效则不会自发重建。manual 插入永不因某组数据更新消失，仅显式 remove 或父卸载消失。end marker 不向用户暴露、不移动，组空后也保留；显式 move 可以把声明节点移到 marker 之后，下一次协调 S 仍从全父序列搜集，溢出新节点跟随最后所属槽，因此 Q 的物理顺序仍与数据顺序相同；清空后再次加项才回到 marker 前，行为必须有反例测试。

### 4.3 操作提交、错误和重入

所有结构操作只允许活动 UI 域，在事件/post/batch 收集，在最外安全边界按调用顺序执行。children() 是提交序列快照，不能回写。insertBefore/append 的 child 必须是未挂载且未被其他待提交命令预留的完整描述；成功提交后再通过 child.reference() 获取真实 ref。不允许把已挂载 child 再 insert；同父移动用 move。同一 batch 插入再操作它，需用后续 post 在挂载后取得 ref，本阶段不提供临时 ref。

每条命令执行前检查有效代际、父归属、容器能力、重复挂载/循环，失败抛具体 RuntimeException；该命令树结构无变化，之前成功命令仍保留，不宣称整个 batch 原子。anchor 必须为当前父活跃直接孩子；anchor 先被本批 remove，后续 insert 报 StaleAnchor，不退化为 append。move(child,child) 是验证后 no-op；移到现有相邻位置也是 no-op。跨父 move 明确 CrossParentMove 拒绝；业务可移除旧实例、随后重新挂载/插入另一个或已卸载实例，此过程生命周期重启，不冒充保持焦点的 reparent。remove 已失效/非本父 child 明确错误，非静默成功。

同批的显式命令先按请求序提交，再运行此前因状态失效排队的结构 getter；因此“改 items 后手动 remove”可能在本轮 group 协调时又出现仍在 items 中的 key，应用应以其业务数据或下一 post 明确最终意图。同组数据更新合并到当前最新数组。新增描述先在隔离 collector 完成 build/校验，单项协调成功才挂进真实序列；构造失败不改该 group 已提交树，用户代码副作用不回滚。卸载 cleanup 及 onMount 如需结构修改必须 post 到下一 turn，直接操作抛 LifecycleReentry。

绑定求值、key 求值、build collector、布局/绘制遍历禁止调用 NodeRef 结构变更或 dispatch/snapshot，抛 ReentrantStructure；正常事件回调允许提交命令但不直接改树。结构提交时禁止递归提交；后代/父卸载先使其全部 token 无效，后续 owner-bound 命令取消，显式无 owner 命令若引用已失效对象则报告错误。错误策略与 B 一致：记录已完成副作用，清理 session、停止；不继续绘制半失败批次。

### 4.4 C 的职责/验收与跨阶段出口

文件：dynamic_group.cj、list_item.cj、child_sequence.cj、structural_command.cj、keyed_reconciler.cj、conditional_group.cj；一个可观察顺序是唯一状态权威。identity/mount/unmount 调 A；数据依赖/批次/dirty 调 B；布局只读取提交后的真实子序列，现 Frame 原语完全保留。

独立验收：上表逐项；相同 key 新数据对象更新 Text；两个组同 key 互不串；声明节点手动移到 marker 外；空组加项/删除组父；不同组穿插与 manual 相对次序；重复/空 key 无半挂载；失效 anchor/跨父/重复插入/祖先循环/批中先删后移；卸载后后台队列和旧 ref 都不能修改新节点；所有操作后 M1 快照顺序和 children() 相同。焦点/滚动后续消费 NodeRef 与该序列；M2 消费 dirty/bounds，不改变公开 API。

## 5. 正式冻结前最少需要裁决/实证的点

1. 槽位规则的完整表、手动 remove 声明节点后重建、跨父 move 拒绝：这是本草稿最重要的外部行为选择。
2. 临时 render 抑制生命周期 effects、持久 headless 正常运行 effects：同一个 runtime 的模式差异须公开，不能为了纯导出暗藏另一棵模型树。
3. 事件最小协议此次冻结、focus/modal 路由后续验收；不能将其未完成包装成 REQ-009.1 全通过。
4. Observable 默认每次 set 失效、属性结果相等才抑制渲染，建议先省去自定义 equals 重载以减少并发比较复杂度；有 typed equals 时必须锁外且版本复核。
5. 带参 init、early return/异常、宏冲突诊断、泛型 ForEach+ListItem+闭包、KeyEvent 新签名、全部公开类型跨包可见性：独立最小消费者实际 CJPM 编译/运行，再冻结精确语法。重用正常 macro 子包/bundle 证据，不重跑与本接口无关的 TOML/全Linux套件。

以上选择由主代理收敛、经独立 builder check 后交测试作者；本角色未运行产品测试或宣称任何新功能已完成。

## 6. 主代理最终裁决（优先于上述草稿）

R001：采用 A+B 作为首个完整可验交付（071测试、072产品、073审核、074执行、075验收），C为随后同接口交付（076测试、077产品、078审核、079执行、080验收）。不为A单独引入短命挂载内核。原稳定014/015/016/032最终AC保持全范围；072只交付各自明确子接口，077后再核015/016/032，014等018。014对013的主题前置本次只消费已有Style默认，主题集成仍待013；016对008的差分/失败前置只消费已有差分与D027停止报错恢复围栏，完整安全重同步矩阵仍待008；富文本增量解析归009。此为分阶段准入，不删除原AC。

R002：宏支持泛型组件、一个或多个接口、带参init，均已有SDK1.2真实编译证明；拒绝自定义superclass、open/abstract组件、构造委派链、冲突生成名。直接构造函数return本期明确诊断拒绝；嵌套lambda/函数return不得误拒。throw不登记。@State生成属性保留原visibility（含private），后端存储private，要求显式类型/初值、可变实例成员。包名限定生成引用，消费者明确三条导入：`import cjtui`、`import cjtui.*`、`import cjtui.macros.*`；星号导入不绑定namespace是已验语言事实。宏不得静默擦掉接口/泛型或暴露private状态。

R003：Observable仅提供`init(initial:T)`、get/set/notify，无自定义equals重载。set每次推进版本/标脏；typed目标属性结果相等则无新画面。锁只保护槽/版本/订阅元数据，绝不在锁内运行用户代码。监听安装后版本复核；后台持续写入在turn入口截断，以后写入进入下一turn，不因正常后台生产者触发64次稳定错误。同步生命周期/结构失效循环才受passes预算。后台State失效不消耗post队列容量，队列满不能丢State更新。

R004：全局`render(root,width,height)`始终为完整M1参考生成；当前owner域中先安全稳定绑定，再完整布局/绘制，绝不委托未来M2缓存。detached使用同Runtime临时模式，抑制onMount/cleanup用户副作用，不发布ref，退出释放所有订阅。持久Application.snapshot返回独立Frame副本；临时与持久共享同一节点/绑定/布局实现。后续M2可据此逐帧等价比较。

R005：UI拥有者是thread id加session nonce；允许同线程多个idle headless session，活动回调不能跨session进入别的UI。NodeRef使用WeakRef或等效非拥有句柄，引用不得使已dispose session整树永生；isValid跨线程安全，其他读/写操作按UI域契约。isValid与sameNode在失效后仍可查询；notify失效明确StaleReference。mount代际不可复活。

R006：`RuntimeLimits`公开构造（所有命名参数，均Int64正数）：`init(pendingPosts!:Int64=4096,mountedNodes!:Int64=100000,bindingsPerNode!:Int64=128,dependenciesPerBinding!:Int64=4096,structuralOpsPerBatch!:Int64=10000,stabilizationPasses!:Int64=64,treeDepth!:Int64=256)`。理由同3.2，深度256限制递归栈；不限制业务数据量。Application两个现有init均追加`limits!:RuntimeLimits=RuntimeLimits()`。Frame面积预算不变。post满返回false，其他超限抛`UIException`，避免未定义RuntimeException。

R007：`public class UIException <: Exception`公开只读`code:String`，`public init(code:String,message:String)`；错误code固定：StaleReference、AlreadyMounted、ConstructionAlreadyFinished、ConstructionFailed、DuplicateKey、InvalidKey、ConstructionRootCount、WrongUIContext、SessionInactive、ExpiredEvent、ReentrantEvaluation、ReentrantStructure、LifecycleReentry、StaleAnchor、CrossParentMove、InvalidParent、CapacityExceeded、UnstableUpdate、InvalidProperty。宏非法源码为编译诊断，运行时参数负值/limits非正沿既有IllegalArgumentException。普通用户回调异常保留原异常，额外清理失败聚合附加，不能吞首错。新的约束若实际语言迫使签名修正须在测试冻结前报主代理，不擅改契约。

R008：`public class RuntimeStats`无公开构造，公开只读Int64属性`mountedNodes,activeBindings,subscriptions,pendingPosts,builds,measures,paints,frames`；`Application.stats():RuntimeStats`返回独立快照。前三者是session当前存量，pendingPosts当前待执行未取消量；builds/measures/paints/frames为当前session累计次数（每Component.build/每LayoutNode.measure/每节点paint调用/每生成目标Frame一次计数），start重置，dispose保留末次累计但当前存量归0。未start全0。用于公开诊断/基准和无空闲树工作证明，不是私有测试hook。

R009：全部已有单参数Color/Bool/Int64/Alignment/BorderStyle链属性增加同名`() -> T`重载，原常量签名不变；无参bold等保留。`text(value:String):Component`和`text(value:()->String):Component`只用于Text叶；visible默认true，增加常量/getter。widthAuto/heightAuto清除对应getter。shadow本次常量复合签名保留，动态复合对象后续Style契约另定，不以任意字符串反射替代typed绑定。常量/闭包后写替换同属性旧依赖，挂载后更新限UI域并标脏。

R010：旧onKey(KeyEvent)原先不会收到interrupt，保持该行为；新UI事件可consume/preventDefault CtrlC，未阻止默认则退出。capture→bubble→新app handler→旧handler（未停止且非interrupt）→默认动作。stopPropagation仅停止传播、不等于preventDefault；事件完成后修改报ExpiredEvent。后续modal的域隔离不能借未处理事件泄漏app快捷键。KeyEvent公开`init(code:String,text!:String="")`且保留现有内部调用兼容。

R011：设备run空闲poll最多100ms，不做build/layout/paint；此为框架正常无阻塞回调下等待上界，不是包括用户耗时的硬实时保证。post FIFO取turn入口截止序列，post中新post留下一turn。batch合并帧，异常不回滚业务副作用。snapshot/dispatch/batch/dispose仅安全UI边界；dispose幂等。onMount/cleanup允许post下一turn，禁止直接结构操作。headless与run使用同session逻辑；旧native设备恢复围栏保留，finally不可抛异常。

R012：清理先撤销整树token/订阅/队列，再孩子到父执行已登记cleanup；全部尝试、每个最多一次。run任何挂载/绑定/回调/cleanup异常不得越过native close：在非抛finally恢复termios/模式，围栏外组合错误并抛出，保留既有D027的primary/restore错误形状。不能将新增cleanup抛在finally而掩盖原错或跳过close。

R013：C完整采用4.2槽位表；唯一物理序列包含内部group marker，绝不按业务数据之外的规则排序。保留key新T更新ListItem.value；manual不归组所有，删除数据不删除manual。同父move保代际，跨父拒绝。普通原生if/for是一次build；响应式If/ForEach是公开动态构造，不混淆。一个key一个根是首版显式限制，复合根可用Row/Column。结构错误按4.3，不虚称全batch事务。

R014：原全局parents+Mutex构造栈退役，ThreadLocal collector唯一；旧每100ms无条件render退役，dirty/resize驱动目标生成；原LayoutNode/Frame/Style/Unicode/ansies保留为唯一权威。产品组件不直接输出ANSI，后续控件通过公开组合与受控通用primitive，不加Button专用kind。基准或导出不能维护第二组件树。

R015：public Component()及宏组件根默认Column纵向容器语义，是有布局盒的组合节点；build收集的直接孩子按声明顺序参与同Column测量/绘制，公开布局/样式同等生效，不暗设无盒Fragment。当前无focus阶段，run路由目标为有效可见root；后续017才由focus选择目标。显式dispatch目标自身或任一祖先visible(false)时抛UIException(InvalidProperty)，不进入节点/app新UI回调。设备root隐藏时不构造虚假UIKeyEvent、不调用节点/新UIhandler，仍调用旧onKey处理非interrupt，interrupt默认stop；后续焦点/域路由须保持隐藏节点不可接收输入。dispatch开始后沿已固定路径完成，回调属性修改在安全边界生效，不在同次路由半移除目标。

R016：headless中显式dispatch未prevent的interrupt，在该dispatch最外安全边界停止并清理session，返回时ref无效、订阅/owner队列释放。跨线程stop只发停止请求，headless在下一个安全UI边界处理，后台绝不运行用户cleanup；dispose可主动结束且幂等。普通typed属性getter中的snapshot/dispatch或Observable写报ReentrantEvaluation；动态condition/items/key/body构造属于结构上下文，其递归snapshot/dispatch/NodeRef结构操作报ReentrantStructure；任何求值中直接Observable写仍报ReentrantEvaluation。不同session活动域越界仍WrongUIContext，不为错误上下文静默重新驱动别的session。

R017：SDK Exception无可用suppressed/cause附加API，不能只把额外清理失败写stderr。新增单文件`public class UICleanupException <: Exception`，`public let primary:Exception`、`public prop cleanupFailures:Array<Exception>{get}`、`public init(primary:Exception,cleanupFailures:Array<Exception>)`；构造复制数组，getter返回副本。附加列表只含primary之后的清理失败；message以前primary.message起，按实际清理顺序以分号追加每条附加message，最后追加cleanup failures数量，不丢首错。框架无附加失败时仍抛原对象/类型；仅清理失败取首个作primary，其后作附加。有附加才包装；若已有UICleanupException，展开到最内primary并按顺序拼接旧/新附加，不反复嵌套。构造本身允许空列表，但框架不为无附加错误做空包装。native close仍在非抛finally执行；任何已有primary再遇restore失败，将Exception("terminal restore failed")追加为附加并聚合保留原对象。仅业务primary+restore时消息仍以“原message; terminal restore failed”为前缀，再附加清理计数，保留D027组合形状而非要求整串逐byte相同；无其他首错且只有restore一错仍直接抛该原错。stderr可辅助，不是唯一诊断返回通道。

### 编译实证来源

主代理冻结前读取`/workspace/work/linux-source-audit/{report.md,supplement/report.md,names/report.md}`和`/workspace/work/linux-build-recon/report.md`。这些是开发证据，不是正式产品通过；随本轮归档选取源码/raw/hash，无SDK/cache/二进制混入产品。独立preflight核合同与任务，正式测试取得缺API RED，然后产品正常CJPM编译验证全部精确API。TOML证据供后续主题使用，本变更不增TOML依赖。
