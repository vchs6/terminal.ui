package widgets_composite

import cjtui.*

// Breaks caught: forced status height/bottom docking, implicit split weights or
// separators, wrong axis/rounding, virtual minimum screen, private visibility.
func statusAndSplitFrames(): Unit {
    equal(render(Column { StatusBar {}; Text("Z") }, 4, 2).toPlainText(), "Z   \n    ", "M04 empty natural Row")
    equal(render(Column { StatusBar { Text("OK") }; Text("Z") }, 4, 2).toPlainText(), "OK  \nZ   ", "M04 natural single row")
    equal(render(Column { StatusBar { Text("A\nB") }; Text("Z") }, 4, 3).toPlainText(), "A   \nB   \nZ   ", "M04 natural multiline")
    equal(render(Column { StatusBar { Text("A\nB") }.height(1); Text("Z") }, 4, 3).toPlainText(), "A   \nZ   \n    ", "M04 explicit status height")
    equal(render(Column { StatusBar { Text("OK") }; Text("Z") }, 1, 2).toPlainText(), "O\nZ", "M04 narrow status does not disappear")
    let status = Column { StatusBar { Text("A\nB") }; Text("Z") }
    equal(render(status, 0, 2).toPlainText(), "\n", "M04 zero width has row separator")
    equal(render(status, 4, 0).toPlainText(), "", "M04 zero height")
    let theme = Theme.parse("schema_version = 1\nname = \"status-height\"\n[components.status_bar.spacing]\nheight = 1\n")
    let themed = Application(Column { StatusBar { Text("A\nB") }; Text("Z") }, theme: theme)
    themed.startHeadless()
    try { equal(themed.snapshot(4, 3).toPlainText(), "A   \nZ   \n    ", "M04 ordinary theme height1") }
    finally { themed.dispose() }
    let override = Application(Column { StatusBar { Text("A\nB") }.height(2); Text("Z") }, theme: theme)
    override.startHeadless()
    try { equal(override.snapshot(4, 3).toPlainText(), "A   \nB   \nZ   ", "M04 explicit height beats theme") }
    finally { override.dispose() }
    let horizontal = SplitPane { Text("A").layoutWeight(1); Text("B").layoutWeight(1) }
    equal(render(horizontal, 5, 1).toPlainText(), "A  B ", "M04 horizontal odd remainder")
    let vertical = SplitPane(axis: SplitAxis.Vertical) { Text("A").layoutWeight(1); Text("B").layoutWeight(1) }
    equal(render(vertical, 1, 5).toPlainText(), "A\n \n \nB\n ", "M04 vertical odd remainder")
    equal(render(horizontal, 1, 1).toPlainText(), "A", "M04 horizontal narrow")
    equal(render(vertical, 1, 1).toPlainText(), "A", "M04 vertical narrow")
    equal(render(horizontal, 0, 0).toPlainText(), "", "M04 zero screen")
    equal(render(SplitPane { Text("A"); Text("B") }, 5, 1).toPlainText(), "AB   ", "M04 no implicit weights")
    equal(render(SplitPane { Text("AAAAAAAA").layoutWeight(1); Text("BBBBBBBB").layoutWeight(2); Text("CCCCCCCC").layoutWeight(3) }, 8, 1).toPlainText(),
        "ABBBCCCC", "M04 original TASK011 largest remainder")
    let nested = SplitPane {
        SplitPane(axis: SplitAxis.Vertical) { Text("A").layoutWeight(1); Text("B").layoutWeight(1) }.height(3).layoutWeight(1)
        Text("C").layoutWeight(1)
    }
    equal(render(nested, 5, 3).toPlainText(), "A  C \n     \nB    ", "M04 nested two axes")
    let app = Application(horizontal)
    app.startHeadless()
    try {
        let refs = mounted(horizontal).children()
        app.snapshot(0, 0)
        check(refs[0].isVisible() && refs[1].isVisible(), "M04 zero viewport does not rewrite business visible")
    } finally { app.dispose() }
}
