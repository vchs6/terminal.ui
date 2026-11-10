package interaction_b

import cjtui.*

// Catches paint feedback and caret using full document coordinates without offset.
func canvasHorizontalCaret(): Unit {
    let caret = Observable<Int64>(0)
    let input = Canvas({ _ => Size(13, 1) }, { ctx =>
        ctx.put(0, 0, "abcdefghijkl")
        ctx.caret(caret.get(), 0)
    }).viewport(ScrollAxes.Horizontal).focusable(true)
    let app = Application(input)
    app.startHeadless()
    try {
        picture(app.snapshot(4, 1), "abcd", "B01 Canvas initial window")
        app.batch({ =>
            caret.set(12)
            ref(input).ensureVisible(rect: Rect(12, 0, 1, 1))
        })
        picture(app.snapshot(4, 1), "jkl ", "B03 line-end 1x1 caret")
        check(app.caretSnapshot().visible && app.caretSnapshot().x == 3, "B03 transformed caret")
        app.batch({ => ref(input).scrollTo(0, 0) })
        picture(app.snapshot(4, 1), "abcd", "B03 manual scroll not undone by old focus")
        check(!app.caretSnapshot().visible, "B03 offscreen caret hidden")
        picture(app.snapshot(4, 1), "abcd", "B03 paint does not re-ensure")
        app.batch({ => ref(input).ensureVisible(rect: Rect(12, 0, 1, 1)) })
        app.snapshot(4, 1)
        picture(app.snapshot(2, 1), "l ", "B03 resize uses last completed caret")
        offset(input, 11, 0, "B03 resized caret visible")
    } finally { app.dispose() }
}
