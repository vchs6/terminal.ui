package incremental_invalidation_cache

import cjtui.*

// Breaks: pure span style remeasures, or text changes with equal style leave stale graphemes.
func spanChanges(): Unit {
    let epoch = [Int64(0)]
    let text = Observable<String>("中A")
    let color = Observable<Color>(Color.Red)
    let root = Column {
        Text({ => RichText([TextSpan(text.get(), style: TextStylePatch(foreground: Some(color.get()), bold: Some(true)))]) })
        Column { Text("B"); Text("C") }
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 4, 3, "中A \nB   \nC   ", "span initial")
        advance(app, epoch, { => color.set(Color.Blue) })
        let styled = paired(app, root, epoch, 4, 3, "中A \nB   \nC   ", "span style only")
        styled.noLayout()
        check(styled.frame.cellAt(0, 0).style == Style(foreground: Color.Blue, bold: true) &&
            styled.frame.cellAt(1, 0).continuation && styled.frame.cellAt(1, 0).style == Style(foreground: Color.Blue, bold: true), "span lead/continuation raw style")
        advance(app, epoch, { => text.set("文B") })
        paired(app, root, epoch, 4, 3, "文B \nB   \nC   ", "span same width text changes").reducedMeasure()
        advance(app, epoch, { => text.set("q") })
        paired(app, root, epoch, 4, 3, "q   \nB   \nC   ", "span width shrinks clears continuation").reducedMeasure()
    } finally { app.dispose() }
}
