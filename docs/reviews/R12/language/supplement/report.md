# TASK-002 构造函数/泛型/接口与 WeakRef 补证

2026-11-10，SDK1.2.0，x86_64-unknown-linux-gnu。独立目录：`/workspace/work/linux-source-audit/supplement`。没有修改主仓、Frame、正式tests，未重跑旧probe或全suite。原`linux-source-audit/report.md`和`probe/`保留不变。

输入是主代理追加问题及`linux-runtime-contract/design-draft.md`，草稿不是已冻结契约。语言知识仍按用户指定cangjie-coding的search_docs.py查询；查询/读取了WeakRef/CleanupPolicy、FuncDecl/ClassDecl/Block/PrimaryCtorDecl、Token.kind和diagReport契约。本目录只验证语言构件，不实现NodeRef/Observable运行时。

## 1. 可直接用于正式冻结的事实

| 问题 | SDK1.2实测结果 | 证据 |
|---|---|---|
| 带参显式init是否能自动加基类/尾部挂载 | 可以。宏保留参数和原body，在前面插入super()，正常结尾插finishConstruction()；普通let/var字段赋值与State setter均保留。 | component_macros.cj、constructors.cj、raw/constructors.{compile,run}.log |
| 成功/throw路径是否正确 | 成功构造登记恰一次；throw发生时不执行末尾finish、零新增挂载；构造时build=0，后续经基类引用调用build后为1。 | constructors.cj中Configured及计数断言 |
| init中early return是否合法 | **合法**。未加宏的native_early_return.cj编译/运行退出0。只把finish追加在末尾不能覆盖该成功返回路径。 | raw/native-early-return.{compile,run}.log |
| 能否显式拒绝early return并定位 | 可以。宏遇到RETURN token用diagReport报AUDIT_INIT_RETURN，编译失败定位原文件9:22的return关键字。 | macro_early_return.cj、raw/macro-early-return.compile.log |
| 泛型@Component class<T> | **可以**。ClassDecl保留genericParam，只修改父类型/构造/build；实际GenericCounter<Int64>编译链接运行通过。不能以SDK不支持为由排除泛型。 | constructors.cj:GenericCounter<T> |
| 已有接口是否可保留 | **可以**。原`<: Named & ValueProvider<T>`保留，自动加AuditBase成为基类+两个接口；通过Named和ValueProvider<Int64>两种接口引用调用验证。 | 同上，跨包auditsupplement公共接口 |
| 泛型State属性/Bind | 可以。`@State var selected: ?T = None`生成私有`Observable<?T>`存储及mut prop getter/setter；赋Some(42)，闭包和泛型接口均读到42。 | component_macros.cj:State，constructors.cj |
| WeakRef真实包/约束 | `std.ref.WeakRef<T> where T <: Object`。普通class Session可作T，无Equatable约束。 | weak_ref.cj、raw/weak-ref.{compile,run}.log |
| WeakRef最小API | `WeakRef<Session>(session, CleanupPolicy.EAGER)`；`.value: Option<Session>`；`.cleanupPolicy`；`.clear(): Unit`。持强引用时正常读取，clear后None，均通过。 | 同上 |

## 2. 已编译的原始@Component/@State源码形状

本轮宏采用目标名字Component/State/Bind，位于独立macro package audit_component_macros；基类/Observable/接口位于另一普通静态包auditsupplement，消费者通过import和静态链接使用：

```cangjie
@Component
class Configured {
    let label: String
    var ordinary: Int64
    @State var count: Int64 = 1
    public var builds: Int64 = 0
    public init(label: String, initial: Int64, fail: Bool) {
        if (fail) { throw Exception("requested failure") }
        this.label = label
        ordinary = initial
        count = initial + 1
    }
    public func build(): Unit { builds++ }
}

@Component
class GenericCounter<T> <: Named & ValueProvider<T> {
    let label: String
    @State var selected: ?T = None
    public var builds: Int64 = 0
    public init(label: String) { this.label = label }
    public func build(): Unit { builds++ }
    public func name(): String { label }
    public func current(): ?T { selected }
}
```

实际AST细节：init成员在SDK1.2是`FuncDecl`且`keyword.value == "init"`，不是PrimaryCtorDecl；前置只读inspect宏的原始输出保留于raw/inspect-consumer.compile.log。宏修改FuncDecl.block.nodes，保留原参数、字段赋值和类genericParam；用模板的modifiers将build改为public override。基类仍是无副作用public init()，protected finishConstruction()里才登记this。

原有两个接口的TypeNode逐一保留，新增AuditBase为第一项并补`&` tokens；没有用重建无类型参数的新类文本覆盖原声明。该方法已验证接口语义和泛型属性语义，不只是看到展开文件。

探针只模拟attach计数和显式后调用build，没有实现“首次materialize至多一次”的运行时guard；build只调用一次是本探针调用流程，不代表语言强制或产品已完成。Observable<T>仅最小值槽，无equals、订阅、锁或调度；本轮结果不依赖泛型相等运算。

## 3. early return必须按真实语言事实处理

原生init允许return；因此如果正式契约选择支持任意成功构造路径，需做识别构造函数return的控制流插桩，而不能只在body末尾append。也不能把finish放finally：throw路径同样会挂载半构造对象。

本探针选择明确拒绝return：

```
error: AUDIT_INIT_RETURN: constructor return requires control-flow instrumentation; this probe rejects it
==> /workspace/work/linux-source-audit/supplement/macro_early_return.cj:9:22:
9 | if (early) { return }
  |              ^^^^^^
```

通过`diagReport(ERROR, quote($(token)), message, hint)`保留调用处Token原始位置；消费者没有手工改写源码。此策略只是当前最小探针的明确边界，不说明语言不能支持early return。扫描构造body所有RETURN token的保守算法也会拒绝嵌套lambda中的return；正式宏若要支持该场景，需按AST作用域区分，不能误写成SDK限制。

带参数显式init正向覆盖非委派构造；用户自写super/this构造委派、多个构造重载、泛型where约束、泛型显式父类、自定义继承链、生成名冲突、没有显式类型/初值的State、初始化期逃逸等未由本轮完整覆盖。支持泛型和接口已有正向证据；其余边界可逐项冻结/诊断，不能把所有未测形式概括为“仓颉不支持”。

## 4. WeakRef使用边界

实际可用代码：

```cangjie
import std.ref.{WeakRef, CleanupPolicy}
let session = Session(42)
let weak = WeakRef<Session>(session, CleanupPolicy.EAGER)
match (weak.value) {
    case Some(live) => use(live)
    case None => ()
}
weak.clear()
```

EAGER的活动契约是GC尽快回收弱引用目标，但不保证立即或一定回收；DEFERRED会尽可能保留直到内存不足。不需要/不应依赖强制GC或精确回收时点判定NodeRef失效；NodeRef应同时核对session disposed/nonce/node generation。disposed session尚有其他强引用时weak.value仍可Some，**弱引用不等于有效性检测**。

读取.value得到Some(live)后，该局部值临时强持有目标，这是完成一次安全检查/操作所需；不要把它永久缓存回NodeRef。闭包、owner token或清理回调若直接捕获session，仍会形成其他强引用，单加WeakRef不能修复这些保留链。`.clear()`适合显式撤销该weak链接，但本轮没有实现或验证框架的并发回收协议。

首次编译用`weak.value != None`时编译器报泛型推断错误；改为穷举match后通过，不添加Session相等约束。正式实现可采用match/unwrapping，避免把Option判空写成需要T相等的表达式。

## 5. 命令、原始产物与适用性

仅新增场景的复现入口：`bash /workspace/work/linux-source-audit/supplement/run.sh`。这次完整新入口执行退出0；随后仅调整early-return诊断为精确Token定位，重编宏和该负向消费者；正向分支生成代码不变，未重复运行无关旧probe。最终源码hash在raw/source-sha256.txt。

原始产物：raw/toolchain.log、component-macros.compile.log、base-library.compile.log、constructors.compile.log、constructors.run.log、native-early-return.compile.log、native-early-return.run.log、macro-early-return.compile.log、weak-ref.compile.log、weak-ref.run.log。空compile日志对应无诊断成功编译；run.sh中的set -e和逐步命令表达其成功前提。预期负向单独检查非零退出、错误标识及源位置。

正向输出：

```
PASS explicit parameter init preserves ordinary assignments and State setter; success attaches once, throw attaches zero, build deferred
PASS generic @Component class<T> preserves two interface declarations; generic State<Option<T>> getter/setter and Bind closure
PASS SDK1.2 std.ref.WeakRef<T>(T,CleanupPolicy.EAGER), .value Option<T>, .cleanupPolicy and .clear()
```

未运行此前全部probe、产品build/test、Frame测试或完整Linux suite；本报告不声称正式运行时或产品验收完成。
