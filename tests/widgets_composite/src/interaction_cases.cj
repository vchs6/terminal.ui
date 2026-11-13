package widgets_composite

import cjtui.*

// Breaks caught: source-order navigation, unrelated-child scanning, wrong axis,
// missing wrap/skip, Tab trapping, double requests, incomplete modifier checks.
func navigation(popup: Bool): Unit {
    let entries = [MenuEntry("a", "A"), MenuEntry("b", "B", enabled: false), MenuEntry("c", "C")]
    let calls = [0]
    let components = Array<?Component>(2, repeat: Option<Component>.None)
    let root = Column {
        components[0] = Some(if (popup) { PopupMenu(entries, {_ => calls[0]++}) } else { HorizontalMenu(entries, {_ => calls[0]++}) })
        components[1] = Some(Text("outside").focusable(true))
    }
    let menu = components[0].getOrThrow()
    let outside = components[1].getOrThrow()
    let captured = Array<?UIKeyEvent>(1, repeat: Option<UIKeyEvent>.None)
    let app = Application(root).onKeyEvent({ event => captured[0] = Some(event) })
    app.startHeadless()
    try {
        let refs = mounted(menu).children(); let a = refs[0]; let b = refs[1]; let c = refs[2]
        focus(app, a)
        let next = if (popup) { "down" } else { "right" }
        let previous = if (popup) { "up" } else { "left" }
        let orthogonal = if (popup) { "left" } else { "up" }
        for ((key, want) in [(next, c), (next, a), ("home", a), ("end", c), (previous, a), (orthogonal, a)]) {
            app.dispatch(app.focusedNode().getOrThrow(), KeyEvent(key))
            focused(app, want, "M02 literal focus trace c,a,a,c,a,a")
            check(captured[0].getOrThrow().defaultPrevented == (key != orthogonal), "M02 navigation consumed iff own axis")
        }
        app.batch({ => mounted(menu).moveBefore(c, a) })
        let physical = mounted(menu).children()
        check(physical[0].sameNode(c) && physical[1].sameNode(a) && physical[2].sameNode(b), "M02 manual physical order c,a,b")
        focus(app, c)
        app.dispatch(c, KeyEvent(next))
        focused(app, a, "M02 manual move follows physical children")
        check(entries[0].key == "a" && entries[1].key == "b" && entries[2].key == "c", "M02 navigation does not reorder business array")
        let extra = Text("X").focusable(true)
        app.batch({ => mounted(menu).insertBefore(a, extra) })
        focus(app, c)
        app.dispatch(c, KeyEvent(next))
        focused(app, a, "M02 skip application-owned child")
        focus(app, mounted(extra))
        app.dispatch(mounted(extra), KeyEvent(next))
        app.dispatch(mounted(extra), KeyEvent("enter"))
        focused(app, mounted(extra), "M02 nonentry receives no menu navigation")
        check(!captured[0].getOrThrow().defaultPrevented && calls[0] == 0, "M02 nonentry no choose/consume")
        focus(app, a)
        app.dispatch(a, KeyEvent("tab"))
        focused(app, mounted(outside), "M02 Tab leaves last eligible physical entry")
    } finally { app.dispose() }
}

func navigationBoundaries(): Unit {
    let calls = [0]
    let single = PopupMenu([MenuEntry("a", "A"), MenuEntry("b", "B", enabled: false)], {_ => calls[0]++})
    let captured = Array<?UIKeyEvent>(1, repeat: Option<UIKeyEvent>.None)
    let app = Application(single).onKeyEvent({ event => captured[0] = Some(event) })
    app.startHeadless()
    try {
        let a = mounted(single).children()[0]
        focus(app, a)
        for (key in ["up", "down", "home", "end"]) {
            app.dispatch(a, KeyEvent(key))
            focused(app, a, "M02 single eligible focus stable")
            check(captured[0].getOrThrow().defaultPrevented && calls[0] == 0, "M02 single navigation consumed without selection")
        }
        app.batch({ => mounted(single).children()[1].notify(ChangeKind.Style) })
    } finally { app.dispose() }
    for (disabled in [false, true]) {
        let empty = PopupMenu(if (disabled) { [MenuEntry("a", "A", enabled: false)] } else { Array<MenuEntry>() }, {_ => calls[0]++})
        let event = Array<?UIKeyEvent>(1, repeat: Option<UIKeyEvent>.None)
        let zero = Application(empty).onKeyEvent({ e => event[0] = Some(e) })
        zero.startHeadless()
        try {
            check(zero.focusedNode().isNone(), "M02 empty/all disabled no focus candidate")
            zero.dispatch(mounted(empty), KeyEvent("down"))
            check(!event[0].getOrThrow().defaultPrevented && calls[0] == 0, "M02 no eligible candidate no menu consumption")
        } finally { zero.dispose() }
    }
}

func activationMatrix(popup: Bool): Unit {
    let calls = [0]; let chosen = [""]
    let menu = if (popup) { PopupMenu([MenuEntry("a", "A"), MenuEntry("b", "B")], { k => calls[0]++; chosen[0] = k }) }
        else { HorizontalMenu([MenuEntry("a", "A"), MenuEntry("b", "B")], { k => calls[0]++; chosen[0] = k }) }
    let event = Array<?UIKeyEvent>(1, repeat: Option<UIKeyEvent>.None)
    let app = Application(menu).onKeyEvent({ e => event[0] = Some(e) })
    app.startHeadless()
    try {
        let refs = mounted(menu).children(); let a = refs[0]; let b = refs[1]
        focus(app, a)
        app.dispatch(b, KeyEvent("enter"))
        check(calls[0] == 0, "M02 unfocused legitimate entry does not choose")
        for (key in [KeyEvent("enter"), KeyEvent("text", text: " ")]) {
            app.dispatch(a, key)
            check(event[0].getOrThrow().defaultPrevented, "M02 valid activation consumed")
        }
        check(calls[0] == 2 && chosen[0] == "a", "M02 Enter and Space request key exactly once")
        for (mask in 1..8) {
            for (key in [KeyEvent("enter", ctrl: (mask % 2 == 1), alt: (mask / 2 % 2 == 1), shift: (mask / 4 == 1)),
                KeyEvent("text", text: " ", ctrl: (mask % 2 == 1), alt: (mask / 2 % 2 == 1), shift: (mask / 4 == 1))]) {
                app.dispatch(a, key)
                check(!event[0].getOrThrow().defaultPrevented && calls[0] == 2, "M02 all seven modifier combinations excluded")
            }
        }
        for (key in [KeyEvent("paste", text: " "), KeyEvent("text", text: "  "), KeyEvent("text", text: "\u{a0}")]) {
            app.dispatch(a, key)
        }
        check(calls[0] == 2, "M02 paste/multi/non-ASCII spaces excluded")
    } finally { app.dispose() }
    for (mode in 0..4) {
        let requests = [0]
        let targetSlot = Array<?Component>(1, repeat: Option<Component>.None)
        let parent = Column {
            targetSlot[0] = Some(if (popup) { PopupMenu([MenuEntry("a", "A")], {_ => requests[0]++}) }
                else { HorizontalMenu([MenuEntry("a", "A")], {_ => requests[0]++}) })
        }
        let target = targetSlot[0].getOrThrow()
        if (mode == 0) { parent.onKeyCapture({ e => e.preventDefault() }) }
        if (mode == 1) { parent.onKey({ e => e.preventDefault() }) }
        if (mode == 3) { parent.onKeyCapture({ e => e.stopPropagation() }) }
        let current = Application(parent)
        if (mode == 2) { current.onKeyEvent({ e => e.preventDefault() }) }
        current.startHeadless()
        try {
            let ref = mounted(target).children()[0]
            focus(current, ref)
            current.dispatch(ref, KeyEvent("enter"))
            check(requests[0] == (if (mode == 3) { 1 } else { 0 }), "M02 capture/bubble/app prevent; stop alone permits once")
        } finally { current.dispose() }
    }
    let disabledCalls = [0]
    let disabledMenu = Column { HorizontalMenu([MenuEntry("a", "A")], {_ => disabledCalls[0]++}) }.enabled(false)
    let disabledApp = Application(disabledMenu)
    disabledApp.startHeadless()
    try {
        var rejected = false
        let child = mounted(disabledMenu).children()[0].children()[0]
        try { disabledApp.dispatch(child, KeyEvent("enter")) } catch (_: UIException) { rejected = true }
        check(rejected && disabledCalls[0] == 0, "M02 disabled ancestor rejects activation")
    } finally { disabledApp.dispose() }
}

func affectedS02(): Unit {
    let calls = [0]
    let controls = [Button("B", { => calls[0]++ }), Checkbox({ => false }, {_ => calls[0]++}), Radio({ => false }, { => calls[0]++ })]
    for (control in controls) {
        let app = Application(control)
        app.startHeadless()
        try {
            let ref = mounted(control)
            focus(app, ref)
            for (mask in 1..8) {
                app.dispatch(ref, KeyEvent("enter", ctrl: (mask % 2 == 1), alt: (mask / 2 % 2 == 1), shift: (mask / 4 == 1)))
                app.dispatch(ref, KeyEvent("text", text: " ", ctrl: (mask % 2 == 1), alt: (mask / 2 % 2 == 1), shift: (mask / 4 == 1)))
            }
            check(calls[0] == 0, "S02 shared complete modifier exclusions")
        } finally { app.dispose() }
    }
}
