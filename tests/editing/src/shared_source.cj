package editing_contract
import cjtui.*

// Catches equal-string origin guessing, shared caret/history and snapshot queries pumping source changes.
func sharedSource(): Unit {
    let source = Observable<String>("abcd"); let a = TextEditController(); let b = TextEditController()
    let first = Box<?Component>(Option<Component>.None); let second = Box<?Component>(Option<Component>.None)
    let reads = Box<Int64>(0)
    let root = Column {
        first.value = Some(TextInput(source, controller: Some(a)))
        second.value = Some(TextInput(source, controller: Some(b)))
        Text({ => if (a.isValid()) { reads.value++; "${a.snapshot().selection.caret}" } else { "-" } })
    }
    let app = Application(root, theme: plainTheme()); app.startHeadless()
    try {
        app.snapshot(2, 3)
        ui(app, { => a.select(TextSelection(4, 4)) })
        key(app, first.value.getOrThrow(), "text", text: "X")
        state(a, "abcdX", 5, 5, true, false, "own token keeps own history")
        state(b, "abcdX", 0, 0, false, false, "peer independent selection/history")
        app.snapshot(2, 3)
        check(ref(first.value.getOrThrow()).viewportSnapshot().offsetX == 4 &&
            ref(second.value.getOrThrow()).viewportSnapshot().offsetX == 0, "view offsets independent")
        let guard = a.snapshot(); let oldReads = reads.value
        let worker = spawn { source.set("xy") }; worker.get(Duration.second * 5)
        check(a.snapshot().text == "abcdX" && a.snapshot().revision == guard.revision,
            "snapshot reads committed local state without source pumping")
        check(!ui(app, { => a.replaceSelection("BAD", ifUnchanged: Some(guard)) }), "actual source invalidates pending guard")
        state(a, "xy", 2, 2, false, false, "external clamps first only")
        state(b, "xy", 0, 0, false, false, "external keeps peer caret")
        let rev = a.snapshot().revision; let sel = a.snapshot().selectionRevision
        source.set("xy"); app.batch({ => })
        check(a.snapshot().revision == rev + 1 && a.snapshot().selectionRevision == sel,
            "external equal set advances text only")
        source.notify(); app.batch({ => })
        check(a.snapshot().revision == rev + 2 && a.snapshot().selectionRevision == sel,
            "external equal notify advances text only")
        app.snapshot(2, 3)
        check(reads.value > oldReads, "snapshot dependency tracks editor view")
        let peerSnapshot = b.snapshot()
        check(!ui(app, { => a.replaceSelection("BAD", ifUnchanged: Some(peerSnapshot)) }), "foreign controller snapshot false")
    } finally { app.dispose() }
}
