package runtime_contract

import cjtui.*

// Catches wrong phase order, stopped propagation leaking to app, treating stop
// as preventDefault, expired mutation, and dispatch to hidden ancestors.
func routedEvents(): Unit {
    let trace = Box<String>("")
    let leaf = Box<?Component>(Option<Component>.None)
    let parent = Box<?Component>(Option<Component>.None)
    let saved = Box<?UIKeyEvent>(Option<UIKeyEvent>.None)
    let mode = Box<String>("normal")
    let root = Column {
        parent.value = Some(Row {
            leaf.value = Some(Text("x").onKeyCapture({ event => trace.value += "Tc" })
                .onKey({ event =>
                    trace.value += "Tb"
                    saved.value = Some(event)
                    check(event.target.sameNode(ref(leaf.value.getOrThrow())) &&
                        event.currentTarget.sameNode(ref(leaf.value.getOrThrow())), "target/currentTarget identify leaf")
                    if (mode.value == "consume") { event.consume() }
                    if (mode.value == "prevent") { event.preventDefault() }
                    if (mode.value == "stop") { event.stopPropagation() }
                    if (mode.value == "hide") { parent.value.getOrThrow().visible(false) }
                }))
        }.onKeyCapture({ _ => trace.value += "Pc" }).onKey({ _ => trace.value += "Pb" }))
    }.onKeyCapture({ _ => trace.value += "Rc" }).onKey({ _ => trace.value += "Rb" })
    var app: ?Application = None
    app = Some(Application(root).onKeyEvent({ event =>
        trace.value += "N"
        if (mode.value == "prevent") { check(event.defaultPrevented, "preventDefault is visible through later phases") }
    }).onKey({ event => trace.value += "O"; check(event.code != "interrupt", "legacy handler never receives interrupt") }))
    let session = app.getOrThrow()
    session.startHeadless()
    let target = ref(leaf.value.getOrThrow())
    session.dispatch(target, KeyEvent("text", text: "a"))
    check(trace.value == "RcPcTcTbPbRbNO", "capture root-to-target then bubble then new and old application handlers")
    let expired = saved.value.getOrThrow()
    code("ExpiredEvent", { => expired.preventDefault() }, "expired event cannot prevent default")
    code("ExpiredEvent", { => expired.stopPropagation() }, "expired event cannot stop propagation")
    code("ExpiredEvent", { => expired.consume() }, "expired event cannot consume")
    trace.value = ""; mode.value = "consume"
    session.dispatch(target, KeyEvent("text", text: "b"))
    check(trace.value == "RcPcTcTb", "consume stops subsequent propagation")
    trace.value = ""; mode.value = "prevent"
    session.dispatch(target, KeyEvent("interrupt"))
    check(trace.value == "RcPcTcTbPbRbN" && target.isValid(), "preventDefault on interrupt preserves session but keeps bubbling")
    trace.value = ""; mode.value = "hide"
    session.dispatch(target, KeyEvent("text", text: "h"))
    check(trace.value == "RcPcTcTbPbRbNO", "visibility change does not truncate fixed current route")
    trace.value = ""
    code("InvalidProperty", { => session.dispatch(target, KeyEvent("text", text: "z")) }, "hidden ancestor excludes target")
    check(trace.value == "", "hidden dispatch enters no UI handler")
    parent.value.getOrThrow().visible(true)
    leaf.value.getOrThrow().visible(false)
    code("InvalidProperty", { => session.dispatch(target, KeyEvent("text")) }, "hidden target excluded")
    leaf.value.getOrThrow().visible(true)
    trace.value = ""; mode.value = "stop"
    session.dispatch(target, KeyEvent("interrupt"))
    check(trace.value == "RcPcTcTb" && !target.isValid(), "stopPropagation alone does not prevent interrupt default exit")
    emptyStats(session, "interrupt default closes headless session")
    session.dispose()
}
