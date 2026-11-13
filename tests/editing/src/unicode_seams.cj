package editing_contract
import cjtui.*

// Catches splice-local segmentation, rune/byte caret arithmetic and backward snapping.
func unicodeSeams(): Unit {
    // Each row: initial text/selection, inserted text, final text/caret. All gap counts are manual.
    let rows = [
        ("eX", 1, 1, "\u{0301}", "e\u{0301}X", 1, 1),
        ("👩💻", 1, 1, "\u{200d}", "👩‍💻", 1, 1),
        ("👩‍💻", 1, 1, "🏽", "👩‍💻🏽", 1, 1),
        ("👩💻", 1, 1, "🏽\u{200d}", "👩🏽‍💻", 1, 1),
        ("🇨X", 1, 1, "🇦", "🇨🇦X", 1, 1),
        ("🇨🇦🇺", 1, 1, "🇸", "🇨🇦🇸🇺", 2, 2),
        ("a中b", 3, 1, "e\u{0301}", "ae\u{0301}", 2, 2)
    ]
    for (row in rows) {
        let value = Observable<String>(row[0]); let c = TextEditController(); let changes = Box<Int64>(0)
        let root = TextArea(value, controller: Some(c), onChange: {_ => changes.value++})
        let app = Application(root, theme: plainTheme()); app.startHeadless()
        try {
            ui(app, { => c.select(TextSelection(row[1], row[2])) })
            let before = c.snapshot()
            key(app, root, "text", text: row[3])
            state(c, row[4], row[5], row[5], true, false, "whole-text splice ${row[4]}")
            check(c.snapshot().revision == 1 && changes.value == 1, "one seam transaction")
            check(c.snapshot().selectionRevision == UInt64(row[6]), "manual seam selection revision")
            check(ui(app, { => c.undo() }), "seam undo")
            state(c, row[0], row[1], row[2], false, true, "seam undo selection")
            check(ui(app, { => c.redo() }), "seam redo")
            state(c, row[4], row[5], row[5], true, false, "seam redo")
            check(changes.value == 3 && before.revision == 0 && c.snapshot().revision == 3, "seam notification history")
        } finally { app.dispose() }
    }
    let c = TextEditController(); let root = TextInput(Observable<String>(""), controller: Some(c))
    let app = Application(root); app.startHeadless()
    try {
        key(app, root, "text", text: "👩")
        key(app, root, "text", text: "🏽")
        key(app, root, "text", text: "\u{200d}")
        key(app, root, "text", text: "💻")
        state(c, "👩🏽‍💻", 1, 1, true, false, "emoji across four events")
        key(app, root, "home"); key(app, root, "delete")
        state(c, "", 0, 0, true, false, "forward deletes joined emoji")
    } finally { app.dispose() }
}
