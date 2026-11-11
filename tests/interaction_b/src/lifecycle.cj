package interaction_b

import cjtui.*

// Catches query invoking measure and missing prelayout zero snapshot.
func readonlyPrelayoutAndStale(): Unit {
    let measures=Box<Int64>(0)
    let observed=Box<Bool>(false)
    let node = Canvas({ _ => measures.value++; Size(8, 8) }, { _ => () })
        .viewport(ScrollAxes.Both)
        .onMount({ mounted =>
            let s = mounted.viewportSnapshot()
            observed.value = s.width == 0 && s.height == 0 && s.contentWidth == 0 &&
                s.contentHeight == 0 && s.offsetX == 0 && s.offsetY == 0
            code("LifecycleReentry", { => mounted.scrollBy(1, 1) }, "B02 lifecycle direct scroll")
            { => () }
        })
    let app = Application(node)
    app.startHeadless()
    check(observed.value, "B02 before first layout snapshot zero")
    app.snapshot(4, 4)
    let saved = ref(node)
    let before = measures.value
    saved.viewportSnapshot()
    saved.viewportSnapshot()
    check(measures.value == before, "B02 readonly query does not measure")
    app.dispose()
    code("StaleReference", { => saved.viewportSnapshot() }, "B02 stale query")
}

func noViewportCapability(): Unit {
    let child=Box<?Component>(Option<Component>.None)
    let root = Column({ => child.value = Text("X") }).viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(4, 2)
        code("InvalidProperty", { => ref(child.value).viewportSnapshot() }, "B02 no viewport query")
        app.batch({ => code("InvalidProperty", { => ref(child.value).scrollBy(0, 1) }, "B02 no viewport scroll") })
    } finally { app.dispose() }
}
