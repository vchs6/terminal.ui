package editing_contract

import cjtui.*
import std.collection.ArrayList

func unicodeTransactions(): Unit {
    let value = Observable<String>("e")
    let ctl = TextEditController()
    let changes = ArrayList<String>()
    let root = TextArea(value, controller: Some(ctl), onChange: { text => changes.add(text) })
    let app = Application(root)
    app.startHeadless()
    try {
        ui(app, { => ctl.select(TextSelection(1, 1)) })
        key(app, root, "text", text: "\u{0301}")
        state(ctl, "e\u{0301}", 1, 1, true, false, "combining joins existing base")
        // Joining at a base uses whole-result segmentation, not byte/rune offsets.
        ui(app, { => ctl.selectAll() })
        check(ui(app, { => ctl.replaceSelection("e\u{0301}X") }), "replace with two clusters")
        state(ctl, "e\u{0301}X", 2, 2, true, false, "combining cluster one gap")
        key(app, root, "backspace")
        state(ctl, "e\u{0301}", 1, 1, true, false, "backspace one whole cluster")
        check(ui(app, { => ctl.undo() }), "undo combining deletion")
        state(ctl, "e\u{0301}X", 2, 2, true, true, "undo selection")
        check(ui(app, { => ctl.redo() }), "redo combining deletion")
        state(ctl, "e\u{0301}", 1, 1, true, false, "redo selection")

        ui(app, { => ctl.selectAll() })
        check(ui(app, { => ctl.replaceSelection("中👩🏽‍💻🇨🇦") }), "Unicode insertion")
        state(ctl, "中👩🏽‍💻🇨🇦", 3, 3, true, false, "three grapheme gaps")
        ui(app, { => ctl.select(TextSelection(3, 1)) })
        state(ctl, "中👩🏽‍💻🇨🇦", 3, 1, true, false, "reverse selection")
        key(app, root, "delete")
        state(ctl, "中", 1, 1, true, false, "reverse selection deletes two whole clusters")

        ui(app, { => ctl.selectAll() })
        check(ui(app, { => ctl.replaceSelection("a") }), "replace all")
        key(app, root, "text", text: "\u{0301}")
        state(ctl, "a\u{0301}", 1, 1, true, false, "join across inserted boundary")
        key(app, root, "backspace")
        state(ctl, "", 0, 0, true, false, "joined cluster deleted together")
        check(changes.size == 10, "one notification per changed Unicode transaction")
    } finally { app.dispose() }
}
