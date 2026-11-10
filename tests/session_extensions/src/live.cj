package session_extensions
import cjtui.*
import std.env.*
import std.convert.*
foreign func cjt_test_arm(mode: Int32, offset: Int64, sequence: Int32): Unit
func live(scenario: String): Unit {
    let selectedRoute = match (getVariable("CJTUI_SESSION_ROUTE") ?? "Direct") {
        case "TmuxPassthrough" => SessionRoute.TmuxPassthrough
        case "ScreenPassthrough" => SessionRoute.ScreenPassthrough
        case _ => SessionRoute.Direct
    }
    let disabled = scenario == "disabled"
    let declared = getVariable("CJTUI_SESSION_DECLARE_STACK") == Some("1") || scenario == "ledger" || scenario == "ledger-close" || scenario == "ledger-error" || scenario == "ledger-cancel" || scenario.startsWith("fault-save") || scenario.startsWith("fault-set") || scenario.startsWith("fault-restore")
    let options = SessionOptions(route: selectedRoute,
        clipboard: if (disabled || scenario == "policy-independent") { SessionPolicy.Disabled } else if (scenario == "declared" || scenario == "policy-reverse") { SessionPolicy.DeclaredSupported } else { SessionPolicy.Auto },
        title: if (disabled || scenario == "policy-reverse") { SessionPolicy.Disabled } else if (scenario == "declared" || scenario == "policy-independent") { SessionPolicy.DeclaredSupported } else { SessionPolicy.Auto },
        titleStack: if (disabled) { SessionPolicy.Disabled } else if (declared) { SessionPolicy.DeclaredSupported } else { SessionPolicy.Auto })
    let display = Observable<String>("CJTUI_SESSION_READY")
    let root = Text({ => display.get() }).onMount({ _ => { =>
        note("disposed", "yes")
        if (getVariable("CJTUI_SESSION_UI_FAIL") == Some("1")) { throw Exception("SESSION_UI_CLEANUP_SENTINEL") }
    } })
    let app = Application(root).sessionOptions(options)
    app.onKey { event =>
        if (event.text == "x") {
            capabilities("live", app)
            if (scenario == "fault-screen") { unsafe { cjt_test_arm(1, Int64.parse(getVariable("CJTUI_SESSION_OFFSET") ?? "1"), 1) }; display.set("CHANGED_FRAME") }
            else if (scenario.startsWith("fault")) { fault(app, scenario) } else {
                unsafe { cjt_test_arm(0, 0, 1) }
                exercise(app, scenario)
            }
        }
        if (scenario == "host") {
            if (event.text == "c") { unsafe { cjt_test_arm(0, 0, 1) }; capabilities("live", app); result("host.copy", app.copyLocalText("CJTUI_HOST_中😀\nLOCAL")) }
            if (event.text == "a") { result("host.title.A", app.setHostTitle("CJTUI_HOST_TITLE_A")) }
            if (event.text == "b") { result("host.title.B", app.setHostTitle("CJTUI_HOST_TITLE_B")) }
            if (event.text == "r") { result("host.restore", app.restoreHostTitle()) }
            saveRecords()
        }
        if (event.text == "q") { app.stop() }
        if (event.text == "e") { throw Exception("SESSION_CALLBACK_SENTINEL") }
    }
    var failed = false
    try { app.run() } catch (error: Exception) {
        failed = true
        note("run.error", error.message)
        if (let Some(aggregate) <- (error as UICleanupException)) {
            note("run.primary", aggregate.primary.message)
            note("run.extras", "${aggregate.cleanupFailures.size}")
            for (i in 0..aggregate.cleanupFailures.size) { note("run.extra${i}", aggregate.cleanupFailures[i].message) }
        }
    }
    note("run.failed", "${failed}")
    capabilities("after", app)
    cleanup(app)
    result("after.inactive", app.copyLocalText("after"))
    if (scenario.startsWith("fault") && scenario != "fault-allocation" && scenario != "fault-eintr" && scenario != "fault-short") {
        let reopenRoot = Text("REOPEN_FRAME")
        let reopened = Application(reopenRoot)
        reopenRoot.onMount({ _ => check(reopened.post({ => reopened.stop() }), "reopen stop queued"); { => } })
        var refused = false
        try { reopened.run() } catch (error: Exception) { refused = true; note("reopen.error", error.message) }
        note("reopen.refused", "${refused}")
    }
}
func exercise(app: Application, scenario: String): Unit {
    match (scenario) {
        case "wire" | "declared" => wireVectors(app)
        case "bounds" => boundaries(app)
        case "invalid" | "disabled" => invalidInputs(app); result("disabled.copy", app.copyLocalText("valid")); result("disabled.title", app.setHostTitle("valid")); result("disabled.restore", app.restoreHostTitle()); result("disabled.icon", app.setHostImageIcon([0u8])); app.stop()
        case "ledger" =>
            result("restore.empty", app.restoreHostTitle())
            let first = app.setHostTitle("A"); result("set.A", first)
            let second = app.setHostTitle("B"); result("set.B", second)
            check(first.steps.size == 2 && second.steps.size == 1, "one save per scope")
            first.steps[0] = second.steps[0]
            check(operation(second.steps[0].operation) == "SetHostTitle", "separate operation step arrays")
            result("restore.1", app.restoreHostTitle())
            result("restore.2", app.restoreHostTitle())
            note("after.explicit.cleanup", "${app.sessionCleanupResults().size}")
            result("set.C", app.setHostTitle("C"))
            result("restore.3", app.restoreHostTitle())
            result("restore.4", app.restoreHostTitle())
            app.stop()
        case "ledger-close" | "ledger-error" | "ledger-cancel" =>
            result("set.A", app.setHostTitle("A")); result("set.B", app.setHostTitle("B"))
            if (scenario == "ledger-close") { app.stop() }
        case "unknown-title" => result("set.A", app.setHostTitle("A")); result("restore.1", app.restoreHostTitle()); app.stop()
        case "policy-independent" | "policy-reverse" => result("policy.copy", app.copyLocalText("f")); result("policy.title", app.setHostTitle("A")); app.stop()
        case "no-request" => app.stop()
        case "cancel-before" => app.stop(); result("cancelled", app.copyLocalText("never"))
        case "fifo" =>
            check(app.post({ => result("fifo.1", app.copyLocalText("1")); check(app.post({ => result("fifo.3", app.copyLocalText("3")); app.stop() }), "nested copy accepted") }), "fifo1 accepted")
            check(app.post({ => result("fifo.2", app.copyLocalText("2")) }), "fifo2 accepted")
        case _ => throw Exception("unknown scenario ${scenario}")
    }
}
func fault(app: Application, scenario: String): Unit {
    let mode: Int32 = match (scenario) { case "fault-eintr" => 2; case "fault-eagain" => 3; case "fault-zero" => 4; case "fault-allocation" => 5; case "fault-short" => 6; case _ => 1 }
    let at = Int64.parse(getVariable("CJTUI_SESSION_OFFSET") ?? "0")
    let which: Int32 = if (scenario.startsWith("fault-set")) { 2 } else { 1 }
    if (scenario.startsWith("fault-restore")) { result("prepare", app.setHostTitle("A")) }
    unsafe { cjt_test_arm(mode, at, which) }
    let value = if (scenario.startsWith("fault-restore")) { app.restoreHostTitle() }
        else if (scenario.startsWith("fault-save") || scenario.startsWith("fault-set")) { app.setHostTitle("A") }
        else if (scenario == "fault-title-unicode") { app.setHostTitle("中😀e\u{301}") }
        else { app.copyLocalText("f") }
    result("fault", value)
    if (mode == 2 || mode == 5 || mode == 6) {
        result("healthy.after", app.copyLocalText("f")); app.stop()
    } else {
        result("cancelled.after", app.copyLocalText("must not emit"))
        check(app.post({ => throw Exception("POST_AFTER_DEVICE_FAULT") }) == false, "fault rejects later posts")
        if (getVariable("CJTUI_SESSION_CALLBACK_FAIL") == Some("1")) { throw Exception("SESSION_LATE_CALLBACK_SENTINEL") }
        // Intentionally ignore Failed. The outer safe boundary must still throw.
    }
}
