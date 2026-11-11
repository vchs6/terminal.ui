package interaction_b

import cjtui.*

// Same literal document and finite grid, using only the documented public combination.
func constructorComposition(): Unit {
    for (useConstructor in [false, true]) {
        let root = if (useConstructor) { ScrollView({ => Text("a\nb\nc\nd\ne\nf") }) }
            else { Column({ => Text("a\nb\nc\nd\ne\nf") }).viewport(ScrollAxes.Vertical).focusable(true) }
        let app = Application(root)
        app.startHeadless()
        try {
            picture(app.snapshot(1, 3), "a\nb\nc", "B01 public combination initial")
            app.dispatch(ref(root), KeyEvent("down", text: ""))
            picture(app.snapshot(1, 3), "b\nc\nd", "B04 common kernel once")
            offset(root, 0, 1, "B04 no duplicate callback")
            check(ref(root).viewportSnapshot().contentHeight == 6, "B02 same natural baseline")
        } finally { app.dispose() }
    }
}
