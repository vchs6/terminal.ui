package widgets_composite_prerequisite

import cjtui.*

// These verify existing primitive assumptions, not missing widget behavior.
// They are never linked as substitute factories into the target consumer.
func originalContracts(): Unit {
    let theme = Theme.readFile("../fixtures/local-theme.toml")
    let roots = [Row { Text("S") }.themeRole(ThemeRole.StatusBar), Row { Text("L"); Text("R") }.themeRole(ThemeRole.SplitPane)]
    let colors = [Color.Yellow, Color.Magenta]
    for (i in 0..roots.size) {
        let app = Application(roots[i], theme: theme)
        app.startHeadless()
        try { check(app.snapshot(2, 1).cellAt(0, 0).style == Style(foreground: colors[i], background: Color.Black), "public role text inheritance exact Style") }
        finally { app.dispose() }
    }
    let height = Theme.parse("schema_version = 1\nname = \"row-height\"\n[components.status_bar.spacing]\nheight = 1\n")
    let app = Application(Column { Row { Text("A\nB") }.themeRole(ThemeRole.StatusBar); Text("Z") }, theme: height)
    app.startHeadless()
    try { check(app.snapshot(4, 3).toPlainText() == "A   \nZ   \n    ", "public Row role theme height") }
    finally { app.dispose() }
    check(render(Row {
        Column { Text("A").layoutWeight(1); Text("B").layoutWeight(1) }.height(3).layoutWeight(1)
        Text("C").layoutWeight(1)
    }, 5, 3).toPlainText() == "A  C \n     \nB    ", "original nested axis allocation")
}
