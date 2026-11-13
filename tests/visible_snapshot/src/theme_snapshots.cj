package visible_snapshot

import cjtui.*

func themeSnapshots(): Unit {
    let theme = Theme.parse("schema_version=1\nname='seed background'\n[text]\nbackground='#112233'\n")
    for (local in [false, true]) {
        let root = Text("x").inverse().underline()
        if (local) { root.background(Color.Rgb(17, 34, 51)) }
        let app = Application(root, theme: theme); app.startHeadless()
        try {
            let cells = grid(["x  "])
            region(cells, Rect(0, 0, 3, 1), Style(background: Color.Rgb(17, 34, 51)))
            if (local) {
                region(cells, Rect(0, 0, 3, 1), Style(background: Color.Rgb(17, 34, 51), inverse: true, underline: true))
            } else {
                mark(cells, 0, 0, "x", style: Style(background: Color.Rgb(17, 34, 51), inverse: true, underline: true))
            }
            save(app.snapshot(3, 1), "x  ", cells, if (local) { "theme-local" } else { "theme-seed" })
        } finally { app.dispose() }
    }
}
