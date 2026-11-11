package interaction_c

import cjtui.*

func modalDomains(): Unit {
    let calls = Box<String>("")
    let base = Box<?Component>(None)
    let root = Column {base.value = Some(Text("base").focusable(true))}.viewport(ScrollAxes.Off)
    let app = Application(root).onKeyEvent({_ => calls.value += "APP;"}).onKey({_ => calls.value += "LEGACY;"})
    app.startHeadless()
    let outer = Column {Text("outer").focusable(true)}
    let popup = Column {Text("popup").focusable(true)}
    let button = Box<?Component>(None)
    let confirm = Column {
        button.value = Some(
            Text("confirm")
                .focusable(true)
                .onKeyCapture({_ => calls.value += "Tc;"})
                .onKey({_ => calls.value += "Tb;"})
                .defaultAction({_ => calls.value += "Td;"}))
    }
        .onKeyCapture({_ => calls.value += "Cc;"})
        .onKey({_ => calls.value += "Cb;"})
        .defaultAction({_ => calls.value += "Ca;"}, phase: DefaultActionPhase.Ancestor)
    let first = Box<?OverlayHandle>(None)
    let second = Box<?OverlayHandle>(None)
    let third = Box<?OverlayHandle>(None)
    app.batch({
        => first.value = Some(
            node(base.value.getOrThrow()).openOverlay(outer, options: OverlayOptions(mode: OverlayMode.Modal)))
    })
    app.batch({=> second.value = Some(node(outer).openOverlay(popup))})
    app.batch({
        => third.value = Some(node(popup).openOverlay(confirm, options: OverlayOptions(mode: OverlayMode.Modal)))
    })
    calls.value = ""
    app.dispatch(node(button.value.getOrThrow()), KeyEvent("text", text: "x"))
    check(calls.value == "Cc;Tc;Tb;Cb;Td;Ca;", "D01 modal route truncates owner chain and both application handlers")
    calls.value = ""
    code("FocusOutsideDomain", {=> app.dispatch(node(base.value.getOrThrow()), KeyEvent("text"))},
        "D02 explicit dispatch cannot bypass highest modal")
    check(calls.value == "", "D02 domain rejection precedes user callbacks")
    app.dispatch(node(button.value.getOrThrow()), KeyEvent("escape"))
    check(calls.value=="Cc;Tc;Tb;Cb;Td;","D03 Escape after Target consumes before Ancestor")
    check(
        reason(third.value.getOrThrow()) == "Escape" && first.value.getOrThrow().isOpen() &&
            second.value.getOrThrow().isOpen(), "D03 Escape closes only closest allowed layer")
    calls.value = ""
    app.dispatch(app.activeTarget().getOrThrow(), KeyEvent("interrupt"))
    check(!nodeReferenceAlive(root) && !first.value.getOrThrow().isOpen() && !second.value.getOrThrow().isOpen(),
        "D04 unprevented modal interrupt exits whole application")
    check(!calls.value.contains("APP;") && !calls.value.contains("LEGACY;"),
        "D04 modal interrupt never calls base handlers")
    released(app, "D04 interrupt releases complete session")
}

func nodeReferenceAlive(component: Component): Bool {
    component.reference().isSome()
}

func escapeBarrierAndPrevent(): Unit {
    let root = Column {Text("base").focusable(true)}.viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    let modal = Text("modal").focusable(true)
    let blocker = Text("blocker").focusable(true).onKeyCapture({
        event => if (event.key.code == "interrupt") {
            event.preventDefault()
        }
    })
    let parent = Box<?OverlayHandle>(None)
    let child = Box<?OverlayHandle>(None)
    app.batch({
        => parent.value = Some(node(root).openOverlay(modal, options: OverlayOptions(mode: OverlayMode.Modal)))
    })
    app.batch({
        => child.value = Some(node(modal).openOverlay(blocker, options: OverlayOptions(closeOnEscape: false)))
    })
    app.dispatch(node(blocker), KeyEvent("escape"))
    check(parent.value.getOrThrow().isOpen() && child.value.getOrThrow().isOpen(),
        "D05 closest closeOnEscape false blocks parent cancellation")
    app.dispatch(node(blocker), KeyEvent("interrupt"))
    check(node(blocker).isValid(), "D06 preventDefault keeps modal application active")
    app.dispose()
}

func emptyLayerReservation(): Unit {
    let base = Box<?Component>(None)
    let root = Column {base.value = Some(Text("base").focusable(true))}.viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    focused(app, node(base.value.getOrThrow()), "F01 I014 initial physical first base candidate")
    let empty = Column {Text("empty")}
    let handle = Box<?OverlayHandle>(None)
    app.batch({=> handle.value = Some(node(root).openOverlay(empty))})
    check(app.focusedNode().isNone(), "F02 empty takeFocus nonmodal reserves no-focus state")
    target(app, node(empty), "F02 activeTarget is layer root rather than nonfocusable child")
    app.batch({=> node(root).append(Text("new base").focusable(true))})
    check(app.focusedNode().isNone(), "F03 new base candidate cannot steal empty-layer reservation")
    let late = Text("late").focusable(true)
    app.batch({=> node(empty).append(late)})
    focused(app, node(late), "F04 first late candidate inside reserved layer takes focus")
    app.dispatch(node(late), KeyEvent("tab"))
    focused(app, node(base.value.getOrThrow()), "F05 nonmodal Tab wraps to base physical first")
    app.batch({=> handle.value.getOrThrow().close()})
    focused(app, node(base.value.getOrThrow()), "F05 closing background layer does not restore over current focus")
    let noTake = Text("noTake").focusable(true)
    app.batch(
        {
            =>
                node(root).openOverlay(noTake, options: OverlayOptions(takeFocus: false));
                ()
        }
    )
    focused(app, node(base.value.getOrThrow()), "F06 nonmodal takeFocus false preserves focus")
    let hint = Text("hint")
    app.batch(
        {
            =>
                node(root).openOverlay(hint, options: OverlayOptions(mode: OverlayMode.Passive, takeFocus: false));
                ()
        }
    )
    focused(app, node(base.value.getOrThrow()), "F07 passive never takes focus or reserves target")
    app.dispose()
}
