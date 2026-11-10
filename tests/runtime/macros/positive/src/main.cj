package runtime_macro_positive

import cjtui
import cjtui.*
import cjtui.macros.*

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
    println("PASS: ${name}")
}

func checkFrame(frame: Frame, want: String, name: String): Unit {
    check(frame.toPlainText() == want, "${name}: got [${frame.toPlainText()}], want [${want}]")
}

func failedConstruction(): Unit {
    try { ParameterPanel("bad", 3, true) } catch (error: Exception) {
        check(error.message.contains("CTOR_SENTINEL"), "constructor preserves throw")
        Text("safe")
    }
}

main(): Int64 {
    let generic = GenericPanel<Int64>("G", 7)
    let named: Named = generic
    let provider: Provider<Int64> = generic
    let base: cjtui.Component = generic
    check(generic.builds == 0 && generic.count == 4, "parameter assignments survive macro before deferred build")
    check(named.name() == "G" && provider.current() == Some(7), "generic parameters and both interfaces survive expansion")
    generic.select(9)
    check(provider.current() == Some(9), "private generic State works inside declaring class")
    let app = Application(base)
    app.startHeadless()
    checkFrame(app.snapshot(5, 1), "G:4  ", "macro root uses public runtime")
    generic.count = 8
    checkFrame(app.snapshot(5, 1), "G:8  ", "public State getter/setter binds without namespace capture")
    check(generic.builds == 1, "macro build remains one-time")
    app.dispose()
    let parameter = ParameterPanel("P", 4, false)
    let parameterApp = Application(parameter)
    parameterApp.startHeadless()
    checkFrame(parameterApp.snapshot(7, 1), "P:4:5  ", "explicit init retains ordinary and State initialization")
    parameter.increment()
    checkFrame(parameterApp.snapshot(7, 1), "P:4:6  ", "private State remains reactive through public action")
    parameterApp.dispose()
    checkFrame(render(Column { failedConstruction() }, 4, 1), "safe", "throwing init never registers failed instance")
    let defaultPanel = DefaultPanel()
    check(defaultPanel.builds == 0, "missing constructor is generated and build deferred")
    checkFrame(render(defaultPanel, 5, 1), "n=2  ", "generated no-arg constructor completes declaration")
    defaultPanel.count = 3
    checkFrame(render(defaultPanel, 5, 1), "n=3  ", "generated State remains current on rematerialization")
    check(defaultPanel.builds == 1, "temporary render does not rebuild macro instance")
    checkFrame(render(NestedReturnPanel(), 6, 1), "nested", "nested lambda returns are not rejected as constructor returns")
    let ordinary = cjtui.Component()
    checkFrame(render(ordinary, 2, 1), "  ", "public Component constructor coexists with Component macro")
    return 0
}
