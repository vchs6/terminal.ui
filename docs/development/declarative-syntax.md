# 仓颉声明式语法：固定源码与编译证据

本文投影原 AC-002（REQ-001，TASK-002）的六项语法要求，不新增语法或 API。固定候选为 `c8624c1de5ab7ec6727ef59d9f2897f9cf6b7960`，产品版本 `0.0.0`；已有实际语言证据使用 Linux x86_64 的 cjc/cjpm **1.2.0**。逐成员 SHA-256、原始命令、退出值、诊断及归档定位见 [syntax-map.json](../reviews/Linux-final/syntax-map.json)。本次仅核对源码、现有原件和文档，没有执行编译器、测试或宿主程序。

原 [AC-002](../acceptance.md) 要求分别证明组件块、属性链、状态、条件/列表、自定义组件和回调，并记录失败定位与限制。R12/R13 的独立验收已经接受相应有限运行时、宏和动态构造证据，但没有关闭原 AC-002。本文与映射供最终 TASK-002 独立审核/验收使用；002.d 与最终登记仍为 pending，不代表 Linux、性能、制品或完整跨平台验收。

## 原始源码与普通入口

源码是普通 `.cj` 文件，按仓颉 package/目录组织；类、接口等各自独立文件。框架公开包是 `cjtui`，编译期宏在 `cjtui.macros`。SDK 原生宏处理原始消费者源码，不要求业务手工转写、生成另一份 UI 源码或引入 JS/TS 运行时。宏组件消费者保留这三条导入：

```cangjie
import cjtui
import cjtui.*
import cjtui.macros.*
```

`import cjtui.*` 不引入 `cjtui` namespace；生成代码使用 `cjtui.Component`、`cjtui.Observable<T>`，因此第一条导入有实际用途。类型 `Component`、宏 `@Component` 及普通 `Component()` 构造可并存；宏正例故意定义同名本地类型验证生成引用不会被捕获。仅使用普通组件/显式 getter 的示例可只导入 `cjtui.*`。

在已配置 SDK 1.2.0、stdx、UCD 和项目依赖的环境中，公开示例的普通构建/运行入口是其目录中的 `cjpm build` / `cjpm run`，例如：

```sh
cd examples/reactive
cjpm build
cjpm run
```

这不是本次新执行记录。依赖与环境前提沿用 [environment.md](environment.md)、[dependencies.md](dependencies.md) 和 [产品说明](../product/README.md)；不要求修改共享 SDK、缓存或仓库配置。所有公开示例的实际 `.cj` 成员、manifest 和各自普通入口均列在映射中；源码清单不等同于对每个例子新增一次编译或宿主认证。

## AC-002 六项对应

| 原要求 | 已有原始仓颉消费者 | 实际证据与边界 |
| --- | --- | --- |
| 组件块 | `examples/reactive/src/main.cj` 的 `Column { Text(...) }`；`examples/theme_showcase/src/gallery_view.cj` 的嵌套块 | R12/R13 实际宏正例；最终共同产品源码的 D141 showcase 普通构建及独立 D142 验收。块与属性链使用同一组件模型。 |
| 属性链 | `examples/dynamic/src/main.cj` 的 `Text(...).foreground(...)`；showcase 的 `.height/.layoutWeight/.alignItems/.onMount` | R13 动态例子实际 build/smoke，D141 showcase 实际 build/宿主消费。普通 CJPM 直接消费这些源码。 |
| 状态与绑定 | reactive 的 `@State var count: Int64 = 0`、`Text(@Bind(...))`；宏正例的 private/public/generic State | R13 宏正例普通 build/direct exit 0；R12/R13 原负例记录类型、初值、可见性等限制。普通值表达式只是初值；自动更新用 `@Bind(expr)` 或类型明确的 `{ => expr }`，观察 `Observable.get()` / State getter。 |
| 条件/列表 | `tests/dynamic/src/conditional_cases.cj`、`identity_cases.cj` 和 `examples/dynamic/src/main.cj` 的 `If`、`ForEach<String>` | R13 普通动态消费者 build/direct exit 0，34 组既定行为；包含普通 `if/for` 一次构造与显式响应式组的区别。 |
| 自定义组件 | `tests/runtime/macros/positive/src/{generic_panel,parameter_panel,default_panel,nested_return_panel}.cj`；公开 `examples/composition/src/job_panel.cj`、showcase `GalleryView` | R13 宏正例保留泛型、双接口、带参 init、默认 init、嵌套 lambda return 和 throw；AC021 接受普通手写派生组件组合；D141/D142 接受最终共同产品上的 showcase。 |
| 仓颉回调 | reactive 的 `.onKey({ _ => counter.count++ })`；dynamic 的 `app.onKey { event => ... }`；showcase 按钮、菜单、onMount | R12 reactive、R13 dynamic 原实际编译/运行；D141/D142 showcase 当前共同产品源码消费。回调是仓颉 closure；生命周期清理函数也由仓颉 closure 返回。 |

六项均有产品实际编译证据；声明-only scratch、旧缺 API 的 RED 和语言微探针不作为产品 GREEN。R12/R13 原件及独立验收的原始受检版本仍保留，不能把历史运行改写为 c862 新执行。

## 已验证的形式与限制

`@Component class ...` 为组件添加框架基类、`build` override 和成功构造后的登记。默认根具有 Column 组合盒语义；不是无盒 Fragment。无显式 init 时生成无参构造；带参 init、普通字段初始化、泛型、一个或多个接口均由实际宏正例证明。`build` 每实例首次 materialize 时最多一次，属性依赖变化不等同于重新调用 build。手写 `class X <: Component` 使用 `public override func build(): Unit` 并在构造完成处调用 `finishConstruction()`；宏类不能显式调用或定义该保留名。

当前宏拒绝 open/abstract 组件、自定义 superclass、构造委派和直接构造函数 return；嵌套 lambda return 已有正例，不应误写成仓颉不支持 return。构造 throw 保留用户异常且不登记失败实例。`@State` 仅用于 `@Component` 内带显式类型和初值的可变实例成员，保留声明可见性；拒绝 let/static/重复注解/无类型/无初值/非成员，private State 不因展开成为公开。`@Bind(expr)` 展开成 getter，仍须满足目标属性类型；例如 `Text(@Bind(1))` 被类型检查拒绝。

原负例共有 15 份，各自普通 `cjpm build` 实际 exit 1，定位到原 `fixture.cj` 或 `main.cj`。诊断质量有边界：无类型/无初值的 State 原输出含 SDK `ASTException`，随后在调用处报告 macro evaluation failed；错误 Bind 可定位外层 `@Component` 并显示展开后的类型不匹配；superclass 拒绝来自编译器的双基类检查。它们证明拒绝与源码关联，不证明所有诊断都精确到非法 token，也不应表述为全部友好自定义诊断。完整逐例行列、原字节/hash 见映射。

响应式条件/列表使用以下现有签名，业务表达式与回调继续使用仓颉：

```cangjie
public func If(condition: () -> Bool, thenBody: () -> Unit,
    elseBody!: () -> Unit = {=>}): Unit
public func ForEach<T>(items: () -> Array<T>, key: (T) -> String,
    body: (ListItem<T>) -> Unit): Unit
```

普通 `if` / `for` 只在首次构造执行。`If` 活跃分支可为空、最多一个根；`ForEach` 每 key 必须恰有一个根，复合项用 Row/Column/自定义组件。组本身不额外增加布局盒；key 非空且组内唯一，按业务数组顺序协调，不推断排序。相同 key 更新 `ListItem.value` 并保留组件/节点身份；删除再加入是新代际。这些是 R13 产品行为证据的有限范围，不是完整 ArkUI/ArkTS SDK 兼容声明。

## 复用边界与编辑器事实

按 AGENTS 11.1，c862 的四个宏实现文件及全部正负宏消费者相对已验证 `f07ff633` 内容未变；动态消费者和 reactive/dynamic 公开例子相对 R13 固定产品 `216b2ab5` 未变。`If`、`ForEach`、`ListItem` 声明与 collector 也未变。后续运行时/Observable 有变化，映射不声称整个 R13 产品源码未变或把旧运行算作最终全运行时验收：Observable 的后续修改增加内部编辑提交方法，公开 get/set/宏接口保留；最终产品实际普通编译由共同源码 `f48ca456` 的 D141/D142 证据补充。c862 相对 f48 的 `src/`、`native/`、`build.cj`、根 `cjpm.toml` 和全部公开例子未变；因此这些普通入口的源码/配置绑定保持。

历史 raw 部分已无损迁入分片。映射同时保留逻辑路径、原始独立执行目录、逐原件 SHA-256、R12/R13 验收/归档索引及统一 catalog；本次只读取仍存在的原始执行文件，没有解压或修改归档。

这些证据验证编译器宏处理和源码定位；没有输入能证明任一特定 IDE、语言服务器或插件版本的补全、重命名、宏展开导航、格式化或实时诊断，因此这些编辑器能力为 **pending / insufficient_evidence**，不能由 CLI 编译通过推导。普通 `.cj` 文件形式不是编辑器支持认证。最终独立审核应逐六项检查本文与映射；如需新增编辑器承诺，应固定编辑器/LSP/插件版本并保留原始操作证据。缺失编辑器认证不改写已有 CLI 语法证明。

本投影没有待补的已改变宏/原负例编译项；若后续改动相关源码、依赖、SDK 或构建选项，应按映射对应的普通 CJPM 命令补受影响编译及定位，不能沿用不再相同的证明。最终 TASK-002 独立审核、验收与登记仍待后续角色完成。
