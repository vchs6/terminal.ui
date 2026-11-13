package editing_contract

import cjtui.*

func frameAndViewport(): Unit {
    let value = Observable<String>("A中B")
    let ctl = TextEditController()
    let root = TextInput(value, controller: Some(ctl))
    let theme = Theme.parse("schema_version=1\nname=\"editing frame\"\n" +
        "[components.text_input.states.selected.text]\nbackground=\"blue\"\n")
    let app = Application(root, theme: theme)
    app.startHeadless()
    try {
        let full = app.snapshot(4, 1)
        check(full.toPlainText() == "A中B", "full CJK frame exact text")
        check(full.cellAt(1,0).grapheme == "中" && full.cellAt(1,0).width == 2 &&
            full.cellAt(2,0).continuation, "full wide cluster owns two cells")
        ui(app, { => ctl.select(TextSelection(1,2)) })
        let selected = app.snapshot(4,1)
        check(selected.cellAt(1,0).style == selected.cellAt(2,0).style,
            "selected wide cluster has one style")
        check(selected.cellAt(1,0).style != full.cellAt(1,0).style,
            "selected style visible without changing data")
        check(value.get() == "A中B", "selection draw is pure")
        // Width two can expose A or B; it cannot expose half of 中.
        let narrow = app.snapshot(2,1)
        check(narrow.cellAt(0,0).grapheme != "中" ||
            narrow.cellAt(1,0).continuation,
            "narrow frame never paints half-wide glyph")
        check(narrow.cellAt(1,0).grapheme != "中", "right edge cannot start wide glyph")
        check(ctl.snapshot().selection == TextSelection(1,2),
            "resize preserves logical selection")
        app.snapshot(0,1)
        check(!app.caretSnapshot().visible && value.get() == "A中B",
            "zero width hides caret without deleting text")
        app.snapshot(4,1)
        check(root.reference().getOrThrow().viewportSnapshot().offsetY == 0,
            "single line public viewport")
    } finally { app.dispose() }
}
