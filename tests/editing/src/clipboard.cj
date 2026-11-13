package editing_contract

import cjtui.*
import std.collection.ArrayList

func isCopy(result: SessionResult): Bool {
    match (result.operation) { case SessionOperation.CopyLocalText => true; case _ => false }
}

func clipboardConservative(): Unit {
    let source = Observable<String>("copy me")
    let ctl = TextEditController()
    let changes = ArrayList<String>()
    let issues = ArrayList<TextEditIssue>()
    let root = TextInput(source, controller: Some(ctl),
        onChange: { text => changes.add(text) },
        onIssue: { issue => issues.add(issue) })
    let app = Application(root)
    app.startHeadless()
    try {
        check(ui(app, { => ctl.copy() }).isNone() && ui(app, { => ctl.cut() }).isNone(),
            "no selection has no session result")
        check(issues.size == 0 && changes.size == 0, "no selection no callbacks")
        ui(app, { => ctl.select(TextSelection(0,4)) })
        let c = ui(app, { => ctl.copy() }).getOrThrow()
        check(isCopy(c) &&
            c.status == SessionStatus.Unsupported && c.emittedBytes == 0,
            "headless copy returns actual Unsupported result")
        state(ctl, "copy me", 0, 4, false, false, "copy never deletes")
        check(issues.size == 1 && issues[0] == TextEditIssue.ClipboardUnavailable,
            "copy unavailable once")
        let x = ui(app, { => ctl.cut() }).getOrThrow()
        check(isCopy(x) &&
            x.status == SessionStatus.Unsupported && x.emittedBytes == 0,
            "headless cut exposes actual unsupported result")
        state(ctl, "copy me", 0, 4, false, false, "unconfirmed cut retains selection")
        check(issues.size == 2 && issues[1] == TextEditIssue.ClipboardUnavailable &&
            changes.size == 0, "one cut issue and zero deletion")

        let ordinary = app.copyLocalText("direct")
        check(isCopy(ordinary) &&
            ordinary.status == SessionStatus.Unsupported,
            "ordinary public copy works without editor")
        let saved = ctl.snapshot()
        ui(app, { => ctl.select(TextSelection(4,4)) })
        ui(app, { => ctl.select(TextSelection(0,4)) })
        check(ctl.snapshot().selection == saved.selection &&
            ctl.snapshot().selectionRevision > saved.selectionRevision,
            "move away and back keeps coordinate but changes identity")
        check(!ui(app, { => ctl.replaceSelection("", ifUnchanged: Some(saved)) }),
            "delayed result cannot delete after move away and back")
        state(ctl, "copy me", 0, 4, false, false, "stale guard preserves original")
        check(issues.size == 2, "guard false itself has no issue")

        let beforeExternal = ctl.snapshot()
        source.notify()
        // The guard compares actual Observable source version, including a pending notify.
        check(!ui(app, { => ctl.replaceSelection("", ifUnchanged: Some(beforeExternal)) }),
            "same-text external notify invalidates delayed result")
        app.batch({ => })
        check(ctl.snapshot().revision == beforeExternal.revision + 1,
            "external notify advances local text revision")
    } finally { app.dispose() }
}
