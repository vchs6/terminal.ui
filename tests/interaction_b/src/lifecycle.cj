package interaction_b

import cjtui.*

// Catches query invoking measure and missing prelayout zero snapshot.
func readonlyPrelayoutAndStale(): Unit {
    var measures: Int64 = 0
    var observed = false
    let node = Canvas({ _ => measures++; Size(8, 8) }, { _ => () })
        .viewport(ScrollAxes.Both)
        .onMount({ mounted =>
            let s = mounted.viewportSnapshot()
            observed = s.width == 0 && s.height == 0 && s.contentWidth == 0 &&
                s.contentHeight == 0 && s.offsetX == 0 && s.offsetY == 0
            code("LifecycleReentry", { => mounted.scrollBy(1, 1) }, "B02 lifecycle direct scroll")
            { => () }
        })
    let app = Application(node)
    app.startHeadless()
    check(observed, "B02 before first layout snapshot zero")
    app.snapshot(4, 4)
    let saved = ref(node)
    let before = measures
    saved.viewportSnapshot()
    saved.viewportSnapshot()
    check(measures == before, "B02 readonly query does not measure")
    app.dispose()
    code("StaleReference", { => saved.viewportSnapshot() }, "B02 stale query")
}

func noViewportCapability(): Unit {
    var child: ?Component = None
    let root = Column({ => child = Text("X") }).viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(4, 2)
        code("InvalidProperty", { => ref(child).viewportSnapshot() }, "B02 no viewport query")
        app.batch({ => code("InvalidProperty", { => ref(child).scrollBy(0, 1) }, "B02 no viewport scroll") })
    } finally { app.dispose() }
}
