package incremental_invalidation_cache

import cjtui.*

// F1: changing effective focused wrap must invalidate the Text and its following sibling geometry.
func focusWrapRegression(): Unit {
    let epoch = [Int64(0)]
    let root = Column {
        Text("abcdef").width(3).focusable(true)
            .setStyle(StyleKeys.textWrap, StyleValue<TextWrap>.Value(TextWrap.Grapheme), state: VisualState.Focused)
        Text("Z").focusable(true)
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 3, 4, "abc\ndef\nZ  \n   ", "F1 initially focused wrap")
        let next = root.reference().getOrThrow().children()[1]
        advance(app, epoch, { => next.requestFocus() })
        let stable = epoch[0]
        let actual = app.snapshot(3, 4)
        let full = render(root, 3, 4)
        check(epoch[0] == stable, "F1 stable focus epoch")
        check(full.toPlainText() == "abc\nZ  \n   \n   ", "F1 independently literal full layout")
        println("F1 literal full=[${full.toPlainText()}] target=[${actual.toPlainText()}] epoch=${stable}")
        equalCells(actual, full, "F1 focus removes wrap")
    } finally { app.dispose() }
}
