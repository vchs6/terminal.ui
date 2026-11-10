# Component宏/类型同名及生成代码名字解析微探针

2026-11-10，SDK1.2.0 x86_64 Linux。新目录`/workspace/work/linux-source-audit/names`；没有改动原报告/probe/supplement、主仓product/tests或Frame，没有重跑泛型/线程/完整suite。仅新增名字解析消费者及最小库/宏。

## 结果

1. **类型Component与宏Component可同名导入，无需改宏名或加macro alias。** 精确双星号导入的消费者同时编译运行`@Component`、`let value: Component`、`Component()`通过。
2. **仅`import auditnames.*`不会将包名auditnames绑定为可用namespace。** 生成`auditnames.Component`和`auditnames.Observable<Int64>`会报undeclared auditnames；不能在正式契约中假定星号import已允许全限定访问。
3. **另加`import auditnames`后，生成全限定引用可用。** 即使业务本包自行声明Component和Observable<T>，宏仍用auditnames.Component作父类、auditnames.Observable<Int64>作State存储；继承/读取/写入运行结果通过。@Component仍指向宏。

因此，使用`import cjtui.*`和`import cjtui.macros.*`这一习惯本身不会产生类/宏同名冲突；若正式宏生成`cjtui.Component`/`cjtui.Observable<T>`，还需要将namespace导入要求或其他已验证名字策略写入正式构建/源码契约。这里仅报告最小合法形状，没有自行改变用户习惯或选择最终导入政策。

## 实际通过的三种消费者

### A. 精确双星号导入，类名/宏名分开解析

`dual_wildcard.cj`：

```cangjie
import auditnames.*
import auditnames.namespacemacros.*

@Component
class Custom {
    public func build(): String { "custom" }
}
main(): Int64 {
    let component: Component = Custom()
    if (component.build() != "custom" || Component().build() != "library-base") { return 1 }
    return 0
}
```

该最小宏生成未限定的Component父类型。通过编译、动态override调用和普通Component构造，不只是宏能被找到。

### B. 全限定生成代码，包namespace显式导入

`normal.cj`：

```cangjie
import auditnames.*
import auditnames.macros.*
import auditnames

@Component
class Custom {
    @State var number: Int64 = 3
    public func build(): String { "number=${number}" }
}
```

Component宏生成`<: auditnames.Component`；State宏生成`auditnames.Observable<Int64>(3)`；消费者仍可用未限定Component类型和Component()构造。读取3、setter后读取8、基类普通构造均通过。

### C. 本包业务同名声明不会捕获全限定生成引用

`shadow.cj`使用与B相同imports，再声明：

```cangjie
class Component {}
class Observable<T> { init() {} }
```

业务仍能构造自己的Component及Observable<Int64>()；宏展开Custom可赋给auditnames.Component，并能经其build读出@State setter设置的9。业务Observable没有带initial参数构造和get/set，因此若宏被其捕获，消费者将不能编译；实际编译运行通过。业务Component也不是open基类，生成代码使用库类型的事实同样经继承检查和赋值确认。

## 预期负向与位置

`wildcard_qualified_negative.cj`只含前两条星号imports，却使用生成全限定类型的宏；编译按预期失败。原始诊断在`raw/wildcard-qualified-negative.compile.log`，定位调用处`wildcard_qualified_negative.cj:4:1`的@Component，并给展开片段中的：

```
undeclared type name 'auditnames'
class Custom <: auditnames.Component
undeclared identifier 'auditnames'
private let _state_number = auditnames.Observable<Int64>(3)
```

这不是类/宏同名歧义，而是包namespace未导入。宏包自身的import-path或编译时依赖不能替代消费者的名字作用域。

## 原始证据

复现：`bash /workspace/work/linux-source-audit/names/run.sh`。只构建本微探针，最后退出0；三个正向消费者退出0，负向消费者被明确检查为失败且诊断符合预期。

```
PASS exact dual wildcard imports distinguish @Component macro, Component type and Component() class constructor
PASS wildcard type Component + macro Component imports: @Component, explicit Component type and Component() constructor coexist
PASS consumer Observable/Component shadows do not capture generated auditnames.Observable<T>/auditnames.Component; @Component remains macro
```

源码：base.cj、namespace_macros.cj、macros.cj、dual_wildcard.cj、normal.cj、shadow.cj、wildcard_qualified_negative.cj；原始编译/运行日志在raw；source-sha256.txt记录源hash，evidence-sha256.txt记录本报告和日志hash。此结果不新增完整宏语义或运行时验收结论。
