package editing_prerequisites

import cjtui.*
func check(ok: Bool, label: String): Unit { if (!ok) { throw Exception(label) } }
func ui<T>(app: Application, action: () -> T): T {
    let result = Box<?T>(Option<T>.None)
    app.batch({ => result.value = Some(action()) })
    result.value.getOrThrow()
}
main(): Int64 {
    let decoder = KeyboardDecoder()
    let batch = decoder.feed([0x1bu8, 0x5b, 0x41])
    check(batch.events.size == 1 && batch.events[0].code == "up", "accepted decoder")
    let modifiers = KeyEvent("right", ctrl: true, shift: true, alt: false)
    check(modifiers.ctrl && modifiers.shift && !modifiers.alt, "accepted key modifiers")
    let theme = Theme.parse("schema_version=1\nname=\"118 prerequisite\"\n" +
        "[components.generic.text]\nforeground=\"cyan\"\n" +
        "[components.text.text]\nforeground=\"yellow\"\n" +
        "[components.text_input.text]\nforeground=\"green\"\n" +
        "[components.text_area.text]\nforeground=\"magenta\"\n")
    let source = Observable<String>("x")
    let canvas = Canvas({_ => Size(6, 2)}, {p =>
        p.put(0, 0, source.get(), selected: true)
        p.caret(0, 0)
    }).focusable(true).viewport(ScrollAxes.Both)
    let app = Application(canvas, theme: theme)
    app.startHeadless()
    try {
        let frame = app.snapshot(3, 1)
        let ref = canvas.reference().getOrThrow()
        check(frame.cellAt(0, 0).grapheme == "x", "public Canvas/Frame")
        check(frame.cellAt(0, 0).style.foreground == Color.Cyan, "four-role theme schema Generic sample")
        check(ui(app, { => true }), "generic batch result helper")
        check(ref.application().sessionCapabilities().isSome(), "public I011/session association")
        check(ref.isFocused() && app.caretSnapshot().visible, "Canvas own focus/caret")
        check(ref.viewportSnapshot().contentWidth == 6, "accepted viewport")
        app.batch({ => ref.ensureVisible(rect: Rect(5, 0, 1, 1)) })
        app.snapshot(3, 1)
        check(ref.viewportSnapshot().offsetX == 3, "accepted viewport command")
        app.dispatch(ref, KeyEvent("text", text: "Q"))
        let result: SessionResult = app.copyLocalText("independent")
        check(match (result.operation) { case SessionOperation.CopyLocalText => true; case _ => false } &&
            result.status == SessionStatus.Unsupported, "actual headless session result")
        check(app.post({ => source.set("y") }), "accepted post")
        app.snapshot(3, 1)
    } finally { app.dispose() }
    println("PASS TASK118 prerequisite public APIs (editor deliberately excluded)")
    0
}
