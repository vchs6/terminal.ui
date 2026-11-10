package runtime_contract

import cjtui.*

// Catches repeated build, stale generations, effects skipped, and wrong root layout.
func constructionAndLifetime(): Unit {
    let value = Observable<String>("A")
    let root = CountingPanel(value)
    let mounts = Box<Int64>(0)
    let cleanups = Box<Int64>(0)
    root.padding(1).onMount({ owner =>
        check(owner.isValid(), "onMount receives live generation")
        mounts.value++
        { => cleanups.value++ }
    })
    check(root.builds == 0 && root.reference().isNone(), "construction defers build and reference")
    let app = Application(root)
    emptyStats(app, "unstarted app has no resources")
    check(app.stats().builds == 0 && app.stats().frames == 0, "unstarted counters are zero")
    check(!app.post({ => throw Exception("unstarted post ran") }), "post rejects inactive session")
    app.startHeadless()
    check(root.builds == 1 && mounts.value == 1, "first materialization builds and mounts once")
    let old = ref(root)
    let first = app.snapshot(6, 4)
    picture(first, "      \n A    \n tail \n      ", "custom root is a styled Column layout box")
    value.set("BC")
    picture(app.snapshot(6, 4), "      \n BC   \n tail \n      ", "longer binding updates without rebuild")
    value.set("Z")
    picture(app.snapshot(6, 4), "      \n Z    \n tail \n      ", "shorter binding clears prior content")
    picture(first, "      \n A    \n tail \n      ", "snapshot is an independent frame copy")
    check(root.builds == 1 && app.stats().builds >= 1, "build counter includes the custom component build")
    let savedStats = app.stats()
    app.dispose()
    check(cleanups.value == 1 && !old.isValid() && old.sameNode(old), "dispose cleans once; expired identity remains comparable")
    check(root.reference().isNone(), "disposed component publishes no reference")
    code("StaleReference", { => old.notify(ChangeKind.All) }, "expired notify rejects generation")
    check(app.stats().builds == savedStats.builds, "dispose preserves cumulative build count")
    emptyStats(app, "dispose releases every current resource")
    check(savedStats.mountedNodes > 0, "stats is an independent snapshot")
    app.dispose()
    check(cleanups.value == 1, "dispose is idempotent")
    app.startHeadless()
    let current = ref(root)
    check(current.isValid() && !old.isValid() && !old.sameNode(current), "remount creates a new complete identity")
    check(root.builds == 1 && mounts.value == 2 && app.stats().builds == 0, "remount reuses build and resets session counters")
    picture(app.snapshot(6, 4), "      \n Z    \n tail \n      ", "remount reevaluates retained getters")
    code("AlreadyMounted", { => Application(root).startHeadless() }, "same instance cannot mount into two sessions")
    check(current.isValid(), "rejected second mount leaves first session valid")
    app.dispose()
    check(cleanups.value == 2, "each mount owns exactly one cleanup")
    code("ConstructionAlreadyFinished", { => DoubleFinish(); () }, "duplicate completion rejected")
}

func collectorRecovery(): Unit {
    let broken = BrokenPanel()
    failsWith("BUILD_SENTINEL", { => Application(broken).startHeadless() }, "build exception reaches consumer")
    check(broken.attempts == 1 && broken.reference().isNone(), "failed construction has no active reference")
    code("ConstructionFailed", { => Application(broken).startHeadless() }, "failed instance is never retried")
    check(broken.attempts == 1, "retry does not invoke failed build")
    picture(render(Column { Text("fresh"); Row { Text("X"); Text("Y") } }, 5, 2),
        "fresh\nXY   ", "nested failed collector restores clean construction context")
    let inside = Gate()
    let release = Gate()
    let worker = spawn {
        let tree = Column { inside.open(); release.awaitOpen(); Text("worker") }
        render(tree, 6, 1).toPlainText()
    }
    inside.awaitOpen()
    let frame = render(Column { Text("main") }, 6, 1)
    release.open()
    picture(frame, "main  ", "concurrent collectors do not steal children")
    check(worker.get(Duration.second * 5) == "worker", "worker owns its complete declaration")
}
