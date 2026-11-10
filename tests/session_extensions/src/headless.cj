package session_extensions
import cjtui.*
func headless(): Unit {
    unsafe { cjt_test_arm(0, 0, 1) }
    let noneCompatibility: ?Int64 = None
    check(noneCompatibility.isNone(), "root wildcard import preserves bare Option None")
    let held = Array<?Application>(1, repeat: Option<Application>.None)
    let root = Text({ =>
        if (let Some(app) <- held[0]) { result("getter", app.copyLocalText("getter")); contextOperations(app, "getter") }
        "CJTUI_SESSION_READY"
    }).onMount({ _ =>
        let app = held[0].getOrThrow()
        result("mount", app.setHostTitle("mount")); contextOperations(app, "mount")
        { => result("cleanup.context", app.copyLocalText("cleanup")); contextOperations(app, "cleanup.context") }
    })
    let app = Application(root)
    held[0] = Some(app)
    check(app.sessionCapabilities().isNone(), "no capability snapshot before first run")
    result("inactive", app.copyLocalText("x")); contextOperations(app, "inactive")
    app.startHeadless()
    capabilities("headless.capabilities", app)
    let firstId = app.sessionCapabilities().getOrThrow().sessionId
    result("headless.copy", app.copyLocalText("text"))
    result("headless.title", app.setHostTitle("title"))
    result("headless.restore", app.restoreHostTitle())
    result("headless.icon", app.setHostImageIcon([0u8]))
    let snapshotReader = spawn { app.sessionCapabilities().getOrThrow().sessionId }
    check(snapshotReader.get(Duration.second * 5) == firstId, "capability getter is safe across threads")
    let worker = spawn { [app.copyLocalText("wrong thread"), app.setHostTitle("thread"), app.restoreHostTitle(), app.setHostImageIcon([0u8])] }
    let workerValues = worker.get(Duration.second * 5)
    result("worker", workerValues[0])
    for (i in 0..4) { result("worker.${i}", workerValues[i]) }
    let other = Application(Text("other"))
    other.startHeadless()
    app.batch({ => result("cross.session", other.copyLocalText("cross")); contextOperations(other, "cross.session") })
    other.dispose()
    app.batch({ => result("batch", app.copyLocalText("batch")) })
    var locked = false
    try { app.sessionOptions(SessionOptions()) } catch (error: UIException) {
        locked = error.code == "LifecycleReentry"
    }
    check(locked, "active session options are immutable")
    check(app.post({ => result("post.1", app.copyLocalText("one")); check(app.post({ => result("post.3", app.copyLocalText("three")) }), "nested post accepted") }), "post1 accepted")
    check(app.post({ => result("post.2", app.copyLocalText("two")) }), "post2 accepted")
    app.snapshot(24, 3)
    check(!records.contains("post.3\t"), "nested post deferred at turn cutoff")
    app.snapshot(24, 3)
    check(records.contains("post.3\t"), "nested post later turn")
    let frameCount = app.stats().frames
    result("clean.copy", app.copyLocalText("clean"))
    app.snapshot(24, 3)
    check(app.stats().frames == frameCount, "copy does not dirty UI frame")
    // Default queue cap and dropping queued copies on close.
    for (_ in 0..4096) { check(app.post({ => throw Exception("DROPPED_POST_EXECUTED") }), "default pendingPosts 4096") }
    check(!app.post({ => }), "4097th post is rejected")
    app.dispose()
    check(!app.post({ => }), "post after close is rejected")
    check(app.sessionCapabilities().getOrThrow().sessionId == firstId, "last snapshot retained")
    cleanup(app)
    app.sessionOptions(SessionOptions(clipboard: SessionPolicy.Disabled))
    app.startHeadless()
    check(app.sessionCapabilities().getOrThrow().sessionId != firstId, "new run new snapshot ID")
    app.dispose()
}

func contextOperations(app: Application, key: String): Unit {
    result("${key}.copy", app.copyLocalText("context"))
    result("${key}.title", app.setHostTitle("context"))
    result("${key}.restore", app.restoreHostTitle())
    result("${key}.icon", app.setHostImageIcon([0u8]))
}
