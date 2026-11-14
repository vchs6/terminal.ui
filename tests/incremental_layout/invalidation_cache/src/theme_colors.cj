package incremental_invalidation_cache

import cjtui.*

// Breaks: global theme revision invalidates geometry despite only effective colors changing.
func themeColors(): Unit {
    let epoch = [Int64(0)]
    let initial = Theme.parse("schema_version = 1\nname = \"red\"\n[text]\nforeground = \"red\"\n")
    let next = Theme.parse("schema_version = 1\nname = \"blue\"\n[text]\nforeground = \"blue\"\n")
    let root = Column {
        Text("A")
        Text("B").foreground(Color.Green)
        Text("C").setStyle(StyleKeys.foreground, StyleValue<Color>.Reset)
    }
    let app = Application(root, theme: initial)
    app.startHeadless()
    try {
        let first = paired(app, root, epoch, 3, 3, "A  \nB  \nC  ", "theme initial inherited and masked")
        check(first.frame.cellAt(0, 0).style.foreground == Color.Red, "initial inherited red")
        var request: ?ThemeRequest = None
        advance(app, epoch, { => request = Some(app.loadTheme(ThemeSource.Prepared(next))) })
        let second = paired(app, root, epoch, 3, 3, "A  \nB  \nC  ", "theme pure color")
        second.noLayout()
        check(request.getOrThrow().result().isSome(), "prepared theme committed synchronously at boundary")
        check(second.frame.cellAt(0, 0).style.foreground == Color.Blue &&
            second.frame.cellAt(0, 1).style.foreground == Color.Green &&
            second.frame.cellAt(0, 2).style.foreground == Color.Default, "inheritance explicit and reset masks")
        check(second.after.builds == second.before.builds, "theme retains identity/builds")
    } finally { app.dispose() }
}
