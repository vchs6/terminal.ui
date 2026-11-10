package runtime_contract

import cjtui.*

// Catches recursive draining, queue order changes, stale owner execution, lost
// state invalidation under a full queue, and nested batches creating extra frames.
func schedulerTurns(): Unit {
    let value = Observable<String>("0")
    let root = Text({ => value.get() })
    let app = Application(root, limits: RuntimeLimits(pendingPosts: 2))
    let trace = Box<String>("")
    app.startHeadless()
    app.snapshot(3, 1)
    check(app.post({ => trace.value += "1"; check(app.post({ => trace.value += "3" }), "nested post accepted") }), "first post accepted")
    check(app.post({ => trace.value += "2" }), "second post accepted")
    check(!app.post({ => trace.value += "overflow" }), "full queue returns false")
    check(app.stats().pendingPosts == 2, "stats counts pending accepted work")
    let worker = spawn { value.set("B") }
    worker.get(Duration.second * 5)
    picture(app.snapshot(3, 1), "B  ", "full post queue cannot drop state invalidation")
    check(trace.value == "12" && app.stats().pendingPosts == 1, "turn cutoff preserves FIFO and defers nested post")
    app.snapshot(3, 1)
    check(trace.value == "123" && app.stats().pendingPosts == 0, "later turn executes nested post exactly once")
    let frames = app.stats().frames
    app.batch({ =>
        value.set("1")
        app.batch({ => value.set("2"); value.set("3") })
        check(value.get() == "3", "batch reads its written business state")
    })
    picture(app.snapshot(3, 1), "3  ", "nested batch publishes latest value")
    check(app.stats().frames <= frames + 1, "outer batch creates at most one target frame")
    let old = ref(root)
    check(app.post(old, { => trace.value += "old-owner" }), "live owner post accepted")
    app.dispose()
    check(!app.post(old, { => trace.value += "expired-owner" }), "expired owner post rejected")
    app.startHeadless()
    check(app.post({ => trace.value += "4" }), "new session accepts work")
    app.snapshot(3, 1)
    check(trace.value == "1234" && !old.isValid(), "old session owner queue cannot leak into remount")
    app.dispose()
    let failingValue = Observable<String>("before")
    let failing = Application(Text({ => failingValue.get() }))
    failing.startHeadless()
    check(failing.post({ => failingValue.set("after"); throw Exception("POST_SENTINEL") }), "failing post is initially accepted")
    failsWith("POST_SENTINEL", { => failing.snapshot(5, 1); () }, "post failure preserves original exception")
    check(failingValue.get() == "after", "failed batch does not roll back business effects")
    emptyStats(failing, "post failure releases session resources")
}
