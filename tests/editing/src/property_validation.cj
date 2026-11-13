package editing_contract
import cjtui.*

func editorPropertyValidation(): Unit {
    for (decorate in [{node: Component => node.wrap(TextWrap.Grapheme)},
        {node: Component => node.overflow(TextOverflow.Ellipsis)},
        {node: Component => node.textAlign(Alignment.Center)}]) {
        errorCode("InvalidProperty", { =>
            let app = Application(decorate(TextArea(Observable<String>("a\nb"))))
            try { app.startHeadless(); app.snapshot(2, 2) } finally { app.dispose() }
        })
    }
    for (bad in ["x\r", "x\ty", "x\u{1b}y"]) {
        let source = Observable<String>("valid"); let c = TextEditController()
        let app = Application(TextArea(source, controller: Some(c))); app.startHeadless()
        var caught = false
        try { source.set(bad); app.snapshot(4, 2) } catch (_: Exception) { caught = true }
        finally { app.dispose() }
        check(caught && source.get() == bad, "invalid external source diagnosed without changing business value")
    }
    let source = Observable<String>("A"); let c = TextEditController()
    let root = TextArea(source, controller: Some(c)); let app = Application(root); app.startHeadless()
    try {
        ui(app, { => c.select(TextSelection(1, 1)); c.replaceSelection("\r\nB\rC") })
        state(c, "A\nB\nC", 5, 5, true, false, "programmatic edit normalizes CRLF/CR too")
        let before = c.snapshot()
        ui(app, { => illegal({ => c.replaceSelection("\t"); () }) })
        exact(c, "A\nB\nC", 5, 5, before.revision, before.selectionRevision, "invalid program edit has no local effects")
    } finally { app.dispose() }
}
