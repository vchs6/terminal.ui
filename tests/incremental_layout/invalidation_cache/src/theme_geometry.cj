package incremental_invalidation_cache

import cjtui.*

// Breaks: theme changes that affect measurement are incorrectly cut off as color-only.
func themeGeometry(): Unit {
    let epoch = [Int64(0)]
    let base = Theme.parse("schema_version = 1\nname = \"base\"\n")
    let padded = Theme.parse("schema_version = 1\nname = \"wrap-pad\"\n[components.text.text]\nwrap = \"grapheme\"\n[components.text.spacing]\npadding_left = 1\npadding_right = 1\n")
    let root = Column { Text("abcdef"); Text("Z").padding(0) }
    let app = Application(root, theme: base)
    app.startHeadless()
    try {
        paired(app, root, epoch, 5, 4, "abcde\nZ    \n     \n     ", "theme geometry initial clip")
        advance(app, epoch, { => app.loadTheme(ThemeSource.Prepared(padded)); () })
        paired(app, root, epoch, 5, 4, " abc \n def \nZ    \n     ", "theme wrap and horizontal insets")
        advance(app, epoch, { => app.loadTheme(ThemeSource.Prepared(base)); () })
        paired(app, root, epoch, 5, 4, "abcde\nZ    \n     \n     ", "theme geometry restored")
    } finally { app.dispose() }
}
