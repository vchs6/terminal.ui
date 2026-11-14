package incremental_invalidation_cache

import cjtui.*

// Breaks: typed style/list/RichText equality is treated as a new effective output.
func typedStyleEquality(): Unit {
    let epoch = [Int64(0)]
    let version = Observable<Int64>(0)
    let rule = StyleRule().withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Red))
    let root = Text({ => let _ = version.get(); RichText([TextSpan("A"), TextSpan("B")]) })
        .styles({ => let _ = version.get(); [StyleUse.Inline(rule)] })
        .bold({ => let _ = version.get(); true })
        .wrap({ => let _ = version.get(); TextWrap.Grapheme })
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 3, 1, "AB ", "typed style initial")
        advance(app, epoch, { => version.set(1) })
        paired(app, root, epoch, 3, 1, "AB ", "typed RichText StyleUse Bool enum equal").noTarget()
    } finally { app.dispose() }
}
