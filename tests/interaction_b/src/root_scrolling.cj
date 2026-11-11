package interaction_b

import cjtui.*

// Catches missing root fallback, enlarged Frame, and fake focus on an empty focus domain.
func rootLongContent(): Unit {
    let root = Column({ => hundredRows() }).minWidth(100).minHeight(30)
    let app = Application(root)
    app.startHeadless()
    try {
        let frame = app.snapshot(80, 24)
        check(frame.width == 80 && frame.height == 24, "B01 actual Frame 80x24")
        let state = ref(root).viewportSnapshot()
        check(state.height == 24 && state.contentHeight == 100, "B01 finite extent 100")
        check(app.focusedNode().isNone(), "B04 empty focus domain stays None")
        check(app.activeTarget().getOrThrow().sameNode(ref(root)), "B04 actual root activeTarget")
        app.dispatch(app.activeTarget().getOrThrow(), KeyEvent("down", text: ""))
        offset(root, 0, 1, "B04 implicit root defaults once")
        app.batch({ => check(ref(root).scrollTo(0, 76), "B01 accept tail") })
        let tail = app.snapshot(80, 24)
        check(tail.cellAt(0, 0).grapheme == "r" && tail.cellAt(1, 0).grapheme == "7" &&
            tail.cellAt(2, 0).grapheme == "6", "B01 first visible tail row r76")
        check(tail.cellAt(1, 23).grapheme == "9" && tail.cellAt(2, 23).grapheme == "9",
            "B01 final row r99")
    } finally { app.dispose() }
}

// Literal cells discriminate 5/5 vs 4/6, and 9/1 vs 5/5.
func rootWeightedCompatibility(): Unit {
    let short = Column({ =>
        Text("A").layoutWeight(1)
        Text("B\nB\nB").layoutWeight(1)
    })
    let app = Application(short)
    app.startHeadless()
    try {
        picture(app.snapshot(1, 10), "A\n \n \n \n \nB\nB\nB\n \n ", "B02 short weighted 5/5")
        offset(short, 0, 0, "B02 short no overflow")
    } finally { app.dispose() }
    let overflow = Column({ =>
        Text("A\nA\nA\nA\nA\nA\nA\nA").layoutWeight(1)
        Text("B").layoutWeight(1)
    })
    let other = Application(overflow)
    other.startHeadless()
    try {
        picture(other.snapshot(1, 10), "A\nA\nA\nA\nA\nA\nA\nA\n \nB", "B02 overflow weighted 9/1")
        check(ref(overflow).viewportSnapshot().contentHeight == 10, "B02 no third pass growth")
    } finally { other.dispose() }
}

// Catches overflow escaping an independent viewport and scrolling fixed chrome.
func fixedChromeAndBarriers(): Unit {
    let body=Box<?Component>(Option<Component>.None)
    let root = Column({ =>
        Text("MENU").height(1)
        body.value = ScrollView({ => hundredRows() }).layoutWeight(1)
        Text("STAT").height(1)
    })
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(4, 10)
        check(ref(body.value).viewportSnapshot().height == 8, "B01 body receives eight rows")
        check(ref(root).viewportSnapshot().contentHeight == 10, "B02 independent viewport barrier")
        app.batch({ => ref(body.value).scrollTo(0, 92) })
        picture(app.snapshot(4, 10),
            "MENU\nr92 \nr93 \nr94 \nr95 \nr96 \nr97 \nr98 \nr99 \nSTAT", "B01 fixed chrome tail")
        offset(root, 0, 0, "B02 chrome root remains still")
    } finally { app.dispose() }
    let fixed = Column({ => Column({ => hundredRows() }).height(3) })
    let fixedApp = Application(fixed)
    fixedApp.startHeadless()
    try {
        fixedApp.snapshot(4, 10)
        check(ref(fixed).viewportSnapshot().contentHeight == 10, "B02 fixed-height overflow barrier")
        fixedApp.batch({ => check(!ref(fixed).scrollBy(0, 1), "B02 fixed barrier no movement") })
    } finally { fixedApp.dispose() }
    let off = Column({ => hundredRows() }).viewport(ScrollAxes.Off)
    let offApp = Application(off)
    offApp.startHeadless()
    try {
        offApp.snapshot(4, 3)
        offApp.batch({ => check(!ref(off).scrollBy(0, 1), "B02 explicit Off closes fallback") })
        offset(off, 0, 0, "B02 Off offset")
    } finally { offApp.dispose() }
}

// Catches unconstrained-width natural measurement hiding actual-width wrap overflow.
func wrappedAndEmptyRoot(): Unit {
    let root = Text("ABCDEFGHIJKL").wrap(TextWrap.Grapheme)
    let app = Application(root)
    app.startHeadless()
    try {
        picture(app.snapshot(4, 2), "ABCD\nEFGH", "B02 actual width wrap initial")
        check(ref(root).viewportSnapshot().contentHeight == 3, "B02 wrapped natural height three")
        app.batch({ => ref(root).scrollTo(0, 1) })
        picture(app.snapshot(4, 2), "EFGH\nIJKL", "B02 wrapped third visual row accessible")
        app.snapshot(4, 0)
        check(ref(root).viewportSnapshot().contentHeight == 3, "B02 zero viewport retains finite content")
    } finally { app.dispose() }
    let empty = Column({ => () })
    let emptyApp = Application(empty)
    emptyApp.startHeadless()
    try {
        let frame = emptyApp.snapshot(0, 0)
        check(frame.width == 0 && frame.height == 0, "B02 zero Frame stays zero")
        let state = ref(empty).viewportSnapshot()
        check(state.contentHeight == 0 && state.offsetY == 0, "B02 empty zero extent")
    } finally { emptyApp.dispose() }
}

func detachedRootPolicy(): Unit {
    let root = Column({ => Text("0\n1\n2\n3\n4\n5") })
    picture(render(root, 1, 3), "0\n1\n2", "B02 detached no implicit viewport")
    check(root.reference().isNone(), "B02 detached never publishes ref")
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(1, 3)
        app.batch({ => ref(root).scrollTo(0, 3) })
        picture(app.snapshot(1, 3), "3\n4\n5", "B02 mounted offset")
        picture(render(root, 1, 3), "3\n4\n5", "B02 mounted render consumes committed offset")
    } finally { app.dispose() }
}
