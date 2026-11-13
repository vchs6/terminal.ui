package editing_contract
import cjtui.*

// Catches a private offset owner, half-wide drawing, paint-time scrolling and stale caret ownership.
func exactViewport(): Unit {
    let c = TextEditController(); let source = Observable<String>("A中B")
    let root = TextInput(source, controller: Some(c)); let app = Application(root, theme: plainTheme())
    app.startHeadless()
    try {
        let initial = app.snapshot(4, 1)
        cell(initial, 0, 0, "A", 1, false, Style())
        cell(initial, 1, 0, "中", 2, false, Style())
        cell(initial, 2, 0, "", 0, true, Style())
        cell(initial, 3, 0, "B", 1, false, Style())
        let viewport = ref(root).viewportSnapshot()
        check(viewport.contentWidth == 5 && viewport.contentHeight == 1 && viewport.axes == ScrollAxes.Horizontal,
            "extent includes one caret cell")
        check(app.caretSnapshot().visible && app.caretSnapshot().x == 0, "first caret logical gap0")
        app.snapshot(2, 1)
        ui(app, { => ref(root).scrollTo(0, 0) })
        check(app.snapshot(2, 1).toPlainText() == "A ", "right-clipped wide glyph leaves blank")
        ui(app, { => ref(root).scrollTo(1, 0) })
        let wide = app.snapshot(2, 1)
        cell(wide, 0, 0, "中", 2, false, Style()); cell(wide, 1, 0, "", 0, true, Style())
        ui(app, { => ref(root).scrollTo(2, 0) })
        check(app.snapshot(2, 1).toPlainText() == " B", "left-clipped wide glyph leaves blank")
        check(!app.caretSnapshot().visible, "manual offset hides offscreen caret")
        ui(app, { => c.select(TextSelection(3, 3)) })
        // Navigation is the public safe-domain ensureVisible trigger.
        key(app, root, "end"); app.snapshot(2, 1)
        check(ref(root).viewportSnapshot().offsetX == 3 && app.caretSnapshot().x == 1 && app.caretSnapshot().visible,
            "gap4 caret visible through sole viewport owner")
        app.snapshot(0, 1)
        check(!app.caretSnapshot().visible && ref(root).isFocused(), "zero width keeps focus hides caret")
        app.snapshot(2, 0); check(!app.caretSnapshot().visible, "zero height hides caret")
        app.snapshot(5, 1)
        check(ref(root).viewportSnapshot().offsetX == 0, "resize clamps offset")
        ui(app, { => c.selectAll(); c.replaceSelection("Q") })
        check(app.snapshot(2, 1).toPlainText() == "Q " && ref(root).viewportSnapshot().offsetX == 0,
            "short content clamps and clears stale cells")
        let cover = ui(app, { => ref(root).openOverlay(Text("ZZ").width(2).height(1),
            options: OverlayOptions(mode: OverlayMode.NonModal, takeFocus: false)) })
        app.snapshot(2, 1)
        check(!app.caretSnapshot().visible && ref(root).isFocused(), "opaque overlay hides underlying focused caret")
        ui(app, { => cover.close() }); app.snapshot(2, 1)
        check(app.caretSnapshot().visible, "closing overlay restores current caret")
    } finally { app.dispose() }
}
