package widgets_composite

import cjtui.*

func open(app: Application, owner: NodeRef, content: Component, options: OverlayOptions): OverlayHandle {
    let held = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
    app.batch({ => held[0] = Some(owner.openOverlay(content, options: options)) })
    held[0].getOrThrow()
}

// Breaks caught: automatic menu layers/close, swallowed Esc, opaque background
// reset, orphan nested layers, stale restored frame/focus or invalid ownership.
func popupOwnership(): Unit {
    let model = Observable<String>("ijklmnop")
    let triggerSlot = Array<?Component>(1, repeat: Option<Component>.None)
    let root = Column {
        triggerSlot[0] = Some(Text("abcdefgh").focusable(true))
        Text({ => model.get() })
        Text("qrstuvwx")
    }.viewport(ScrollAxes.Off)
    let trigger = triggerSlot[0].getOrThrow()
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(8, 3)
        focus(app, mounted(trigger))
        let calls = [0]
        let popup = PopupMenu([MenuEntry("a", "X")], {_ => calls[0]++}).width(3).height(1)
        let handle = open(app, mounted(trigger), popup, OverlayOptions(mode: OverlayMode.NonModal))
        equal(app.snapshot(8, 3).toPlainText(), "abcdefgh\nijX  nop\nqrstuvwx", "M03 popup has public opaque surface")
        let entry = mounted(popup).children()[0]
        focus(app, entry)
        app.dispatch(entry, KeyEvent("enter"))
        check(calls[0] == 1 && handle.isOpen(), "M03 choose does not close")
        app.batch({ => model.set("IJKLMNOP") })
        app.batch({ => handle.close() })
        check(handle.closeReason().getOrThrow() == OverlayCloseReason.Requested, "M03 business explicit close reason")
        focused(app, mounted(trigger), "M03 explicit close restores trigger")
        equal(app.snapshot(8, 3).toPlainText(), "abcdefgh\nIJKLMNOP\nqrstuvwx", "M03 exposes latest base frame")
        let held = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
        let closeMenu = PopupMenu([MenuEntry("close", "Close")], {_ => held[0].getOrThrow().close()})
        held[0] = Some(open(app, mounted(trigger), closeMenu, OverlayOptions(mode: OverlayMode.Modal)))
        let closeEntry = mounted(closeMenu).children()[0]
        focus(app, closeEntry)
        app.dispatch(closeEntry, KeyEvent("text", text: " "))
        check(!held[0].getOrThrow().isOpen(), "M03 onChoose may explicitly close held handle")
        focused(app, mounted(trigger), "M03 callback close restores trigger")
    } finally { app.dispose() }
}

func popupEscapeBoundaries(): Unit {
    for (mode in 0..4) {
        let triggerSlot = Array<?Component>(1, repeat: Option<Component>.None)
        let root = Column { triggerSlot[0] = Some(Text("T").focusable(true)) }
        let trigger = triggerSlot[0].getOrThrow()
        let prevent = [mode == 3]
        let app = Application(root).onKeyEvent({ event =>
            if (prevent[0] && event.key.code == "escape") { event.preventDefault() }
        })
        app.startHeadless()
        try {
            focus(app, mounted(trigger))
            let values = if (mode == 0) { Array<MenuEntry>() } else { [MenuEntry("a", "A", enabled: false)] }
            let popup = PopupMenu(values, {_ => ()})
            let handle = open(app, mounted(trigger), popup,
                OverlayOptions(mode: OverlayMode.Modal, closeOnEscape: mode != 2))
            check(app.focusedNode().isNone(), "M03 empty/all-disabled has no fake focus item")
            app.dispatch(app.activeTarget().getOrThrow(), KeyEvent("escape"))
            if (mode == 3) {
                check(handle.isOpen(), "M03 app preventDefault blocks Escape")
                prevent[0] = false
                app.dispatch(app.activeTarget().getOrThrow(), KeyEvent("escape"))
                check(!handle.isOpen(), "M03 later allowed Escape closes")
            } else if (mode == 2) {
                check(handle.isOpen(), "M03 closeOnEscape false blocks close")
                app.batch({ => handle.close() })
            } else {
                check(!handle.isOpen() && handle.closeReason().getOrThrow() == OverlayCloseReason.Escape,
                    "M03 empty/all-disabled activeTarget Escape closes")
            }
            focused(app, mounted(trigger), "M03 canceled layer restores focus")
        } finally { app.dispose() }
    }
    let inline = PopupMenu([MenuEntry("a", "A")], {_ => ()})
    let app = Application(inline)
    app.startHeadless()
    try {
        let ref = mounted(inline).children()[0]
        focus(app, ref)
        app.dispatch(ref, KeyEvent("escape"))
        check(ref.isValid(), "M03 inline popup does not invent closed overlay")
        focused(app, ref, "M03 inline Escape leaves focus")
    } finally { app.dispose() }
}

func nestedPopup(): Unit {
    let triggerSlot = Array<?Component>(1, repeat: Option<Component>.None)
    let root = Column { triggerSlot[0] = Some(Text("base").focusable(true)) }
    let trigger = triggerSlot[0].getOrThrow()
    let app = Application(root)
    app.startHeadless()
    try {
        focus(app, mounted(trigger))
        let parent = PopupMenu([MenuEntry("p", "Parent")], {_ => ()})
        let parentHandle = open(app, mounted(trigger), parent, OverlayOptions(mode: OverlayMode.Modal))
        let p = mounted(parent).children()[0]
        focus(app, p)
        let child = PopupMenu([MenuEntry("c", "Child")], {_ => ()})
        let childHandle = open(app, p, child, OverlayOptions(mode: OverlayMode.Modal))
        let c = mounted(child).children()[0]
        focus(app, c)
        app.dispatch(c, KeyEvent("escape"))
        check(parentHandle.isOpen() && !childHandle.isOpen(), "M03 Esc closes child layer only")
        focused(app, p, "M03 nested close restores valid parent entry")
        let again = PopupMenu([MenuEntry("d", "Dependent")], {_ => ()})
        let dependent = open(app, p, again, OverlayOptions(mode: OverlayMode.Modal))
        app.batch({ => parentHandle.close() })
        check(!parentHandle.isOpen() && !dependent.isOpen(), "M03 parent explicit close closes dependent layer")
        focused(app, mounted(trigger), "M03 parent closure restores base trigger")
    } finally { app.dispose() }
}

func popupOwnerAndAnchor(): Unit {
    for (anchorCase in [false, true]) {
        let components = Array<?Component>(2, repeat: Option<Component>.None)
        let root = Column {
            components[1] = Some(Column {
                components[0] = Some(Text("anchor").focusable(true))
            })
            Text("fallback").focusable(true)
        }
        let anchor = components[0].getOrThrow()
        let owner = components[1].getOrThrow()
        let app = Application(root)
        app.startHeadless()
        try {
            app.snapshot(16, 4)
            focus(app, mounted(anchor))
            let menu = PopupMenu([MenuEntry("a", "A")], {_ => ()})
            let handle = open(app, mounted(owner), menu,
                OverlayOptions(mode: OverlayMode.NonModal, anchor: Some(mounted(anchor))))
            if (anchorCase) { app.batch({ => mounted(owner).remove(mounted(anchor)) }) }
            else { app.batch({ => mounted(root).remove(mounted(owner)) }) }
            check(!handle.isOpen(), "M03 owner/anchor invalidation closes popup")
            check(handle.closeReason().getOrThrow() == (if (anchorCase) { OverlayCloseReason.AnchorGone } else { OverlayCloseReason.OwnerGone }),
                "M03 owner/anchor exact reason")
            check(!mounted(root).children().isEmpty(), "M03 ordinary root remains usable")
            app.snapshot(16, 4)
        } finally { app.dispose() }
    }
}
