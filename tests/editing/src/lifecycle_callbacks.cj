package editing_contract
import cjtui.*

// Catches stale mount identity, duplicate binding and callbacks seeing partially committed state.
func controllerLifecycle(): Unit {
    let c = TextEditController(); let source = Observable<String>("abc")
    let root = TextInput(source, controller: Some(c)); let app = Application(root)
    app.startHeadless(); app.snapshot(2, 1)
    let old = c.snapshot()
    let duplicate = Application(TextArea(source, controller: Some(c)))
    errorCode("AlreadyMounted", { => duplicate.startHeadless() })
    check(c.isValid(), "failed duplicate keeps original binding")
    ui(app, { => c.selectAll(); c.replaceSelection("XYZ") })
    app.dispose()
    source.set("abc")
    check(!c.isValid(), "unmount invalid")
    let valid = spawn { !c.isValid() }; check(valid.get(Duration.second * 5), "isValid background after close")
    for (action in [{ => c.snapshot(); () }, { => c.selectAll() }, { => c.undo(); () },
        { => c.redo(); () }, { => c.copy(); () }, { => c.cut(); () }]) {
        errorCode("StaleReference", action)
    }
    app.startHeadless()
    try {
        exact(c, "abc", 0, 0, 0, 0, "remount same text/revisions resets private identity")
        check(!c.snapshot().canUndo && !c.snapshot().canRedo, "remount empty history")
        app.snapshot(2, 1)
        check(ref(root).viewportSnapshot().offsetX == 0, "remount offset zero")
        check(!ui(app, { => c.replaceSelection("!", ifUnchanged: Some(old)) }), "old mount guard false")
        let thread = spawn {
            errorCode("WrongUIContext", { => c.snapshot(); () })
            errorCode("WrongUIContext", { => c.selectAll() })
            errorCode("WrongUIContext", { => c.replaceSelection("x"); () })
            errorCode("WrongUIContext", { => c.undo(); () })
            errorCode("WrongUIContext", { => c.copy(); () })
            c.isValid()
        }
        check(thread.get(Duration.second * 5), "live controller thread guard")
        let otherRoot = TextInput(Observable<String>("other")); let other = Application(otherRoot)
        other.startHeadless()
        other.batch({ => errorCode("WrongUIContext", { => c.snapshot(); () }); errorCode("WrongUIContext", { => c.selectAll() }) })
        other.dispose()
    } finally { app.dispose() }
}

func callbackTransactions(): Unit {
    let c = TextEditController(); let peer = TextEditController()
    let source = Observable<String>(""); let peerSource = Observable<String>("")
    let appBox = Box<?Application>(Option<Application>.None); let trace = Box<String>("")
    let peerBox = Box<?Component>(Option<Component>.None); let changes = Box<Int64>(0); let issues = Box<Int64>(0); let submits = Box<Int64>(0)
    let guard = { =>
        check(c.isValid(), "callback isValid allowed")
        for (action in [{ => c.select(TextSelection(0, 0)) }, { => c.selectAll() },
            { => c.replaceSelection("x"); () }, { => c.undo(); () }, { => c.redo(); () },
            { => c.copy(); () }, { => c.cut(); () }]) {
            errorCode("LifecycleReentry", action)
        }
    }
    let rootBox = Box<?Component>(Option<Component>.None)
    let root = Column { rootBox.value = Some(TextInput(source, controller: Some(c),
        onChange: { text =>
            changes.value++
            let s = c.snapshot()
            check(s.text == text && s.selection == TextSelection(1, 1) && s.revision == 1 &&
                s.canUndo && !s.canRedo && source.get() == "A", "onChange committed before callback")
            trace.value += "change;"; guard()
            peer.replaceSelection("P")
            check(appBox.value.getOrThrow().post({ =>
                trace.value += "post;"; c.selectAll()
            }), "onChange may post")
            source.set("external")
        }, onSubmit: { text =>
            submits.value++; check(text == c.snapshot().text, "submit stable local text")
            trace.value += "submit;"; guard()
        }, onIssue: {_ =>
            issues.value++; check(c.snapshot().text == "external", "issue after rejection")
            trace.value += "issue;"; guard()
        }))
        peerBox.value = Some(TextInput(peerSource, controller: Some(peer)))
    }
    let app = Application(root, theme: plainTheme()); appBox.value = Some(app); app.startHeadless()
    try {
        key(app, rootBox.value.getOrThrow(), "text", text: "A")
        check(changes.value == 1 && peerSource.get() == "P", "callback can operate different editor")
        check(c.snapshot().text == "external" && !c.snapshot().canUndo, "callback source write external replacement")
        app.snapshot(12, 2)
        check(trace.value == "change;post;", "post is later turn")
        key(app, rootBox.value.getOrThrow(), "enter")
        key(app, rootBox.value.getOrThrow(), "paste", text: "\u{1b}")
        check(submits.value == 1 && issues.value == 1 && changes.value == 1, "notifications exact")
        check(trace.value == "change;post;submit;issue;", "notification order")
    } finally { app.dispose() }
    // Callback failures preserve business commits and revoke controller state.
    for (phase in ["change", "submit", "issue"]) {
        let v = Observable<String>(""); let ctl = TextEditController()
        let node = TextInput(v, controller: Some(ctl),
            onChange: {_ => if (phase == "change") { throw Exception("EDIT_CALLBACK") }},
            onSubmit: {_ => if (phase == "submit") { throw Exception("EDIT_CALLBACK") }},
            onIssue: {_ => if (phase == "issue") { throw Exception("EDIT_CALLBACK") }})
        let a = Application(node); a.startHeadless(); var caught = false
        try {
            if (phase == "change") { key(a, node, "text", text: "A") }
            else if (phase == "submit") { key(a, node, "enter") }
            else { key(a, node, "paste", text: "\u{1b}") }
        } catch (e: Exception) { caught = e.message == "EDIT_CALLBACK" }
        check(caught && !ctl.isValid(), "callback exception cleanup ${phase}")
        check(v.get() == if (phase == "change") { "A" } else { "" }, "business write not rolled back")
        a.dispose()
    }
    callbackIllegalArgumentCommit()
}

// F003/E002: a user's IllegalArgumentException is not an editor size rejection.
func callbackIllegalArgumentCommit(): Unit {
    let value = Observable<String>(""); let ctl = TextEditController()
    let sentinel = IllegalArgumentException("EDIT_ONCHANGE_ILLEGAL_ARGUMENT_SENTINEL")
    let changes = Box<Int64>(0); let issues = Box<Int64>(0); let tooLarge = Box<Int64>(0)
    let cleanup = Box<Int64>(0); let observed = Box<?TextEditSnapshot>(Option<TextEditSnapshot>.None)
    let node = TextInput(value, controller: Some(ctl), onChange: { text =>
        changes.value++
        let s = ctl.snapshot(); observed.value = Some(s)
        check(text == "x" && value.get() == "x" && s.text == "x" &&
            s.selection == TextSelection(1, 1) && s.revision == 1 &&
            s.selectionRevision == 1 && s.canUndo && !s.canRedo,
            "literal x source/local transaction committed before throwing onChange")
        throw sentinel
    }, onIssue: { issue =>
        issues.value++; if (issue == TextEditIssue.InputTooLarge) { tooLarge.value++ }
    }).onMount({_ => { => cleanup.value++ }})
    let app = Application(node); app.startHeadless()
    var caught = false; var same = false; var message = ""
    try {
        try { key(app, node, "text", text: "x") }
        catch (error: IllegalArgumentException) {
            caught = true; same = refEq(error, sentinel); message = error.message
        }
        check(caught && same && message == "EDIT_ONCHANGE_ILLEGAL_ARGUMENT_SENTINEL",
            "key-default onChange preserves original IllegalArgumentException type/message/identity")
        let seen = observed.value.getOrThrow()
        check(changes.value == 1 && value.get() == "x" && seen.text == "x" &&
            seen.selection == TextSelection(1, 1) && seen.revision == 1 &&
            seen.selectionRevision == 1 && seen.canUndo && !seen.canRedo,
            "throwing onChange keeps committed business and immutable local snapshot")
        check(issues.value == 0 && tooLarge.value == 0,
            "user IllegalArgumentException is not InputTooLarge or another edit issue")
        let stats = app.stats()
        check(!ctl.isValid() && cleanup.value == 1 && stats.mountedNodes == 0 &&
            stats.activeBindings == 0 && stats.subscriptions == 0 && stats.pendingPosts == 0,
            "throwing key-default callback follows failure cleanup and revokes controller")
    } finally { app.dispose() }
    check(cleanup.value == 1, "callback failure cleanup remains exactly once after dispose")
}
