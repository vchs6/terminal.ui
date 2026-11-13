package session_lifecycle

import cjtui.*

// PREPARATION ONLY: public consumer, not compiled/run and not a RED result.
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
    let app = Application(root)
    app.onKeyEvent({ event =>
        let run = generation.value
        if (event.key.text == "r") {
            record("probe-${run}", app.terminalCapabilities().getOrThrow().cursorVisibilityStatus)
        }
        if (event.key.text == "s") {
            // Queries read a previously completed frame; they do not render.
            let focus = app.focusedNode().getOrThrow()
            if (run == 2) {
                check(focus.sameNode(surface.value.getOrThrow().reference()), "restart starts with base focus")
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
            layer.value = Some(surface.value.getOrThrow().reference().openOverlay(content,
                options: OverlayOptions(mode: OverlayMode.NonModal, takeFocus: true)))
            record("opened", "queued")
        }
        if (event.key.code == "interrupt" && run == 1 && scenario == "prevented") {
            event.preventDefault(); record("prevented", "yes")
        }
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
            check(app.post(saved.value.getOrThrow(), { => stalePosts.value++ }), "owner post queued before stop")
            app.stop()
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
            let before = getters.value
            getterFault.set(false); drawFault.set(false); state.set("NEXT")
            check(getters.value == before, "no getter runs while session closed")
        }
        record("closed-${run}", "0/0/0/0")
    }
    check(stalePosts.value == 0, "no first-session post leaked to second session")
    app.dispose(); check(cleanups.value == 2, "idempotent dispose after both runs")
}
