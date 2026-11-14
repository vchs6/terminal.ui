package incremental_invalidation_cache

import cjtui.*

// Breaks: actual content width/four separate inset keys are missing from the measure cache.
func wrapInsets(): Unit {
    let epoch = [Int64(0)]
    let text = Observable<String>("abcdef")
    let left = Observable<Int64>(1)
    let right = Observable<Int64>(2)
    let top = Observable<Int64>(1)
    let bottom = Observable<Int64>(1)
    let root = Column {
        Text({ => text.get() }).wrap(TextWrap.Grapheme)
            .setStyle(StyleKeys.paddingLeft, { => StyleValue<Int64>.Value(left.get()) })
            .setStyle(StyleKeys.paddingRight, { => StyleValue<Int64>.Value(right.get()) })
            .setStyle(StyleKeys.paddingTop, { => StyleValue<Int64>.Value(top.get()) })
            .setStyle(StyleKeys.paddingBottom, { => StyleValue<Int64>.Value(bottom.get()) })
        Text("Z")
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 7, 6, "       \n abcd  \n ef    \n       \nZ      \n       ", "wrap four insets")
        paired(app, root, epoch, 6, 6, "      \n abc  \n def  \n      \nZ     \n      ", "wrap actual narrower constraint")
        advance(app, epoch, { => left.set(2); right.set(1) })
        paired(app, root, epoch, 6, 6, "      \n  abc \n  def \n      \nZ     \n      ", "same inset sum different left right")
        advance(app, epoch, { => top.set(0); bottom.set(2) })
        paired(app, root, epoch, 6, 6, "  abc \n  def \n      \n      \nZ     \n      ", "same inset sum different top bottom")
        advance(app, epoch, { => text.set("q") })
        paired(app, root, epoch, 6, 6, "  q   \n      \n      \nZ     \n      \n      ", "wrapped shrink moves following sibling")
        advance(app, epoch, { => text.set("abcdef"); left.set(1); right.set(2); top.set(1); bottom.set(1) })
        paired(app, root, epoch, 7, 6, "       \n abcd  \n ef    \n       \nZ      \n       ", "wrap original constraints restored")
    } finally { app.dispose() }
}
