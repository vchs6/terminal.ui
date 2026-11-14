package incremental_invalidation_cache

import cjtui.*

// Breaks: equal resolved Style hides a change in explicit text mask or local background fill.
func styleSources(): Unit {
    let epoch = [Int64(0)]
    let foreground = Observable<StyleValue<Color>>(StyleValue<Color>.Unset)
    let background = Observable<StyleValue<Color>>(StyleValue<Color>.Unset)
    let theme = Theme.parse("schema_version = 1\nname = \"red-seed\"\n[text]\nforeground = \"red\"\n")
    let root = Column {
        Canvas({ _ => Size(3, 2) }, { context =>
            context.put(0, 0, "A", patch: TextStylePatch(foreground: Some(Color.Blue)))
        }).width(3).height(2)
            .setStyle(StyleKeys.foreground, { => foreground.get() })
            .setStyle(StyleKeys.background, { => background.get() })
    }
    let app = Application(root, theme: theme)
    app.startHeadless()
    try {
        let first = paired(app, root, epoch, 3, 2, "A  \n   ", "inherited seed permits Canvas patch")
        check(first.frame.cellAt(0, 0).style.foreground == Color.Blue &&
            first.frame.cellAt(2, 1).style == Style(), "no local fill, patch is blue")
        advance(app, epoch, { => foreground.set(StyleValue<Color>.Value(Color.Red)) })
        let masked = paired(app, root, epoch, 3, 2, "A  \n   ", "equal effective color new explicit mask")
        masked.noLayout()
        check(masked.frame.cellAt(0, 0).style.foreground == Color.Red, "explicit source overrides Canvas patch")
        advance(app, epoch, { => background.set(StyleValue<Color>.Value(Color.Default)) })
        let filled = paired(app, root, epoch, 3, 2, "A  \n   ", "same background value new fill source")
        filled.noLayout()
        check(filled.frame.cellAt(2, 1).style == Style(foreground: Color.Red), "local Default background fills with complete inherited style")
        advance(app, epoch, { => foreground.set(StyleValue<Color>.Unset); background.set(StyleValue<Color>.Unset) })
        let restored = paired(app, root, epoch, 3, 2, "A  \n   ", "source masks and fill removed")
        restored.noLayout()
        check(restored.frame.cellAt(0, 0).style.foreground == Color.Blue && restored.frame.cellAt(2, 1).style == Style(), "restored patch and unfilled blank")
    } finally { app.dispose() }
}
