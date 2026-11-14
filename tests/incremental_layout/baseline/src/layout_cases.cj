package incremental_layout_baseline

import cjtui.*

// Breaks: lost flex remainder, gap/inset deduction, inherited or explicit style.
func rowAllocation(): Unit {
    let root = Row {
        Text("AAAA").layoutWeight(1)
        Text("BBBB").layoutWeight(2).foreground(Color.Blue).bold()
        Text("CCCC").layoutWeight(1)
    }.gap(1).padding(left: 1, right: 2).foreground(Color.Red)
    let app = Application(root)
    app.startHeadless()
    try {
        let frame = paired(app, root, 11, 1, " AA BBB C  ", "row allocation")
        cell(frame, 1, 0, "A", 1, false, Style(foreground: Color.Red), "inherited A style")
        cell(frame, 4, 0, "B", 1, false, Style(foreground: Color.Blue, bold: true), "explicit B style")
        cell(frame, 8, 0, "C", 1, false, Style(foreground: Color.Red), "inherited C style")
        cell(frame, 0, 0, " ", 1, false, Style(), "padding remains opaque default blank")
    } finally { app.dispose() }
    println("PASS CASE 1 row flex/gap/padding/style")
}

// Breaks: wrap measured at wrong content width, stale following-child position.
func columnWrap(): Unit {
    let text = Observable<String>("abcdef")
    let root = Column {
        Text({ => text.get() }).wrap(TextWrap.Grapheme).padding(left: 1, top: 1, right: 2, bottom: 1)
        Text("Z")
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, 7, 6, "       \n abcd  \n ef    \n       \nZ      \n       ", "wrapped padded column")
        app.batch({ => text.set("q") })
        paired(app, root, 7, 6, "       \n q     \n       \nZ      \n       \n       ", "shortened wrap moves sibling")
    } finally { app.dispose() }
    println("PASS CASE 2 column wrap/four insets/shortening")
}

// Breaks: unconditional natural negotiation, absent fallback, reference geometry commit.
func implicitRootFallback(): Unit {
    let first = Observable<String>("A")
    let root = Column {
        Text({ => first.get() }).layoutWeight(1)
        Text("B\nB\nB").layoutWeight(1)
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, 1, 10, "A\n \n \n \n \nB\nB\nB\n \n ", "finite 5/5 retained")
        let ref = root.reference().getOrThrow()
        check(ref.viewportSnapshot().contentHeight == 10, "finite root extent")
        app.batch({ => first.set("A\nA\nA\nA\nA\nA\nA\nA") })
        paired(app, root, 1, 10, "A\nA\nA\nA\nA\nA\nA\nA\nB\nB", "overflow natural 8/3")
        check(ref.viewportSnapshot().contentHeight == 11, "fallback extent eleven")
        app.batch({ => check(ref.scrollTo(0, 1), "root accepts scroll") })
        paired(app, root, 1, 10, "A\nA\nA\nA\nA\nA\nA\nB\nB\nB", "mounted reference consumes scroll")
        let before = ref.viewportSnapshot()
        render(root, 1, 4)
        let after = ref.viewportSnapshot()
        check(before.width == after.width && before.height == after.height &&
            before.contentHeight == after.contentHeight && before.offsetY == after.offsetY,
            "different export size does not commit viewport geometry")
        app.batch({ => first.set("A") })
        paired(app, root, 1, 10, "A\n \n \n \n \nB\nB\nB\n \n ", "fallback removed and offset clamped")
        check(ref.viewportSnapshot().offsetY == 0, "root offset clamps after shrink")
    } finally { app.dispose() }
    plain(render(root, 1, 10), "A\n \n \n \n \nB\nB\nB\n \n ", "detached finite layout")
    first.set("A\nA\nA\nA\nA\nA\nA\nA")
    plain(render(root, 1, 10), "A\nA\nA\nA\nA\nB\nB\nB\n \n ", "detached has no implicit root viewport")
    println("PASS CASE 3 root finite/fallback/scroll/reference geometry")
}

// Breaks: explicit viewport transform lost or illegal offset retained on resize.
func explicitViewport(): Unit {
    let root = ScrollView { Text("0"); Text("1"); Text("2") }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, 2, 2, "0 \n1 ", "explicit initial")
        let ref = root.reference().getOrThrow()
        app.batch({ => check(ref.scrollTo(0, 1), "explicit accepts scroll") })
        paired(app, root, 2, 2, "1 \n2 ", "explicit scrolled")
        paired(app, root, 2, 3, "0 \n1 \n2 ", "explicit resize clamps")
        check(ref.viewportSnapshot().offsetY == 0, "explicit offset zero after grow")
    } finally { app.dispose() }
    println("PASS CASE 4 explicit viewport resize/clamp")
}
