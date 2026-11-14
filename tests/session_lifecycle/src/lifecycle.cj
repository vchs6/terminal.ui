package session_lifecycle

import cjtui.*
import std.env.*

// Formal public consumer; PTY protocol replies are test wire, not host acknowledgement.
// All actual terminal I/O belongs to Application.run; these files are barriers.
func lifecycle(scenario: String): Unit {
    let generation = Box<Int64>(0)
    let mounts = Box<Int64>(0)
    let cleanups = Box<Int64>(0)
    let layerCleanups = Box<Int64>(0)
    let stalePosts = Box<Int64>(0)
    let getters = Box<Int64>(0)
    let getterFault = Observable<Bool>(false)
    let drawFault = Observable<Bool>(false)
    let state = Observable<String>("BASE")
    let saved = Box<?NodeRef>(Option<NodeRef>.None)
    let old = Box<?NodeRef>(Option<NodeRef>.None)
    let layer = Box<?OverlayHandle>(Option<OverlayHandle>.None)
    let oldLayer = Box<?OverlayHandle>(Option<OverlayHandle>.None)
    let layerRef = Box<?NodeRef>(Option<NodeRef>.None)
    let surface = Box<?Component>(Option<Component>.None)
    let root = Column {
        surface.value = Some(Canvas({ _ => Size(8, 1) }, { p =>
            if (drawFault.get()) { throw Exception("L020_DRAW") }
            p.put(0, 0, "BASE"); p.caret(1, 0)
        }).focusable(true).overlayHost(true))
        Text({ =>
            getters.value++
            if (getterFault.get()) { throw Exception("L020_GETTER") }
            state.get()
        })
    }.viewport(ScrollAxes.Off).onMount({ mounted =>
        mounts.value++; saved.value = Some(mounted)
        { =>
            cleanups.value++
            check(!mounted.isValid(), "root token revoked before cleanup")
            if (generation.value == 1 && (scenario == "cleanup" || scenario == "callback-cleanup")) {
                throw Exception("L020_CLEANUP")
            }
        }
    })
    let hostAuto = getVariable("CJTUI_020_HOST_AUTO").getOrDefault({ => "0" }) == "1"
    let app = Application(root)
    if (!hostAuto) { app.sessionOptions(SessionOptions(title: SessionPolicy.DeclaredSupported, titleStack: SessionPolicy.DeclaredSupported)) }
    record("session-policy", if (hostAuto) { "Auto/NoTitleRequest" } else { "DeclaredSupported-title-stress" })
    app.onKeyEvent({ event =>
        let run = generation.value
        if (event.key.text == "r") {
            record("probe-${run}", app.terminalCapabilities().getOrThrow().cursorVisibilityStatus)
        }
        if (event.key.text == "s") {
            check(unsafe { cjt_lifecycle_owner() } == -1, "competing native owner refused")
            if (!hostAuto) {
                let title = app.setHostTitle("L020-${run}")
                check(title.status == SessionStatus.SentUnconfirmed && title.issue == SessionIssue.NoIssue, "title wire delivery unconfirmed")
                match (title.restore) { case TitleRestoreState.SaveSentUnconfirmed => (); case _ => check(false, "title scope saved unconfirmed") }
            }
            let icon = app.setHostImageIcon([])
            check(icon.status == SessionStatus.Unsupported && icon.issue == SessionIssue.NoImageAdapter, "missing image adapter does not fail UI")
            record("title-${run}", if (hostAuto) { "Auto/NoTitleRequest/NoImageAdapter" } else { "SaveSentUnconfirmed/NoImageAdapter" })
            // Queries read a previously completed frame; they do not render.
            let focus = app.focusedNode().getOrThrow()
            if (run == 2) {
                check(focus.sameNode(surface.value.getOrThrow().reference().getOrThrow()), "restart starts with base focus")
                check(!old.value.getOrThrow().isValid(), "old root remains invalid in restart")
                expectCode("StaleReference", { => old.value.getOrThrow().requestFocus() })
                expectCode("WrongUIContext", { => oldLayer.value.getOrThrow().isOpen(); () })
            } else {
                check(focus.sameNode(layerRef.value.getOrThrow()), "first run layer owns focus")
            }
            expectCode("LifecycleReentry", { => app.run() })
            record("state-${run}", app.terminalCapabilities().getOrThrow().cursorVisibilityStatus)
        }
        if (event.key.text == "o" && run == 1) {
            let desiredVisible = app.terminalCapabilities().getOrThrow().cursorVisibilityStatus == "original-hidden"
            let content = Canvas({ _ => Size(8, 1) }, { p =>
                p.put(0, 0, "LAYER1"); p.caret(1, 0, visible: desiredVisible)
            }).focusable(true).onMount({ mounted =>
                layerRef.value = Some(mounted)
                { =>
                    layerCleanups.value++
                    check(!mounted.isValid(), "layer token revoked before cleanup")
                }
            })
            layer.value = Some(surface.value.getOrThrow().reference().getOrThrow().openOverlay(content,
                options: OverlayOptions(mode: OverlayMode.NonModal, takeFocus: true)))
            record("opened", "queued")
        }
        if (event.key.code == "interrupt" && run == 1 && scenario == "prevented") {
            event.preventDefault(); record("prevented", "yes")
        }
        if (event.key.text == "e" && run == 1) {
            check(unsafe { cjt_lifecycle_eof(if (scenario == "pipe-hup") { 1 } else { 0 }) } == 0, "real pipe transport armed")
        }
        if (event.key.text == "z") { record("pipe-key", "z") }
        if (event.key.text == "x" && run == 1) {
            match (scenario) {
                case "getter" => getterFault.set(true)
                case "draw" => drawFault.set(true)
                case "post" => check(app.post({ => throw Exception("L020_POST") }), "failing post queued")
                case "callback" | "callback-cleanup" | "callback-close" => throw Exception("L020_CALLBACK")
                case _ => throw Exception("ASSERT:unexpected trigger")
            }
        }
        if (event.key.text == "q") {
            // Accepted in this callback, revoked at stop before any next pump.
            if (scenario == "worker-stop" && run == 1) {
                let token = saved.value.getOrThrow()
                let worker = spawn {
                    check(app.post(token, { => stalePosts.value++ }), "worker owner post queued")
                    app.stop(); true
                }
                check(worker.get(Duration.second * 5), "business worker joined by consumer")
                record("worker", "joined")
            } else {
                check(app.post(saved.value.getOrThrow(), { => stalePosts.value++ }), "owner post queued before stop")
                app.stop()
            }
        }
    })
    app.onKeyboardIssue({ issue =>
        if (scenario == "pipe-hup") {
            check(issue.kind == KeyboardIssue.IncompleteInput, "EOF diagnoses unfinished CSI")
            record("pipe-issue", "IncompleteInput")
        }
    })
    for (run in 1..3) {
        generation.value = run
        var failure: ?Exception = None
        try { app.run() } catch (e: Exception) { failure = Some(e) }
        if (let Some(e) <- failure) {
            record("error-${run}", e.message)
            if (let Some(aggregate) <- (e as UICleanupException)) {
                record("primary-${run}", aggregate.primary.message)
                var extras = ""
                for (item in aggregate.cleanupFailures) { extras += item.message + "\n" }
                record("extras-${run}", extras)
            }
        }
        if (scenario == "tty-hangup") {
            check(run == 1 && failure.isSome(), "destroyed endpoint must report failure")
            empty(app)
            check(cleanups.value == 1 && layerCleanups.value == 1, "HUP UI cleanups once")
            record("closed-1", "0/0/0/0")
            app.dispose(); return
        }
        let titleCleanup = app.sessionCleanupResults()
        if (hostAuto) {
            check(titleCleanup.isEmpty(), "Auto without title request owns no title scope")
            record("title-closed-${run}", "Auto/NoTitleScope")
        } else {
            check(titleCleanup.size == 1, "one owned title scope cleanup")
            check(titleCleanup[0].status == SessionStatus.SentUnconfirmed, "title pop unconfirmed")
            match (titleCleanup[0].restore) { case TitleRestoreState.RestoreSentUnconfirmed => (); case _ => check(false, "not host confirmed") }
            record("title-closed-${run}", "RestoreSentUnconfirmed")
        }
        let expected = scenario == "close" || scenario == "callback-close" || (run == 1 && (scenario == "getter" || scenario == "draw" || scenario == "post" ||
            scenario == "callback" || scenario == "cleanup" || scenario == "callback-cleanup" ||
            scenario == "callback-close"))
        check(failure.isSome() == expected, "expected run failure ${run}")
        empty(app)
        check(cleanups.value == run && mounts.value == run, "once-only root mount cleanup per run")
        check(layerCleanups.value == 1, "first-run layer cleaned once across restart")
        check(stalePosts.value == 0, "no stopped owner post executed")
        if (run == 1) {
            check(!layer.value.getOrThrow().isOpen(), "first-run layer closed")
            check(!layerRef.value.getOrThrow().isValid(), "old layer reference invalid")
            old.value = saved.value; oldLayer.value = layer.value
            // Mutating an unsubscribed Observable must not evaluate a getter.
            let endedToken = old.value.getOrThrow()
            let closedWorker = spawn {
                check(!app.post(endedToken, { => throw Exception("CLOSED_WORKER_RAN") }), "closed worker owner post refused")
                check(!app.post({ => throw Exception("CLOSED_WORKER_APP_RAN") }), "closed worker app post refused")
                true
            }
            check(closedWorker.get(Duration.second * 5), "closed producer joined by consumer")
            let before = getters.value
            getterFault.set(false); drawFault.set(false); state.set("NEXT")
            check(getters.value == before, "no getter runs while session closed")
        }
        record("closed-${run}", "0/0/0/0")
    }
    check(stalePosts.value == 0, "no first-session post leaked to second session")
    app.dispose(); check(cleanups.value == 2, "idempotent dispose after both runs")
}
