package editing_contract
import cjtui.*

// Catches hard-coded editor style, fake focus state and selection overriding explicit styles.
func themeFrames(): Unit {
    let theme = Theme.parse("schema_version=1\nname=\"four roles\"\n" +
        "[components.generic.text]\nforeground=\"cyan\"\n" +
        "[components.text.text]\nforeground=\"yellow\"\n" +
        "[components.text_input.text]\nforeground=\"green\"\n" +
        "[components.text_input.states.focused.text]\nunderline=true\n" +
        "[components.text_input.states.disabled.text]\ndim=true\n" +
        "[components.text_input.states.selected.text]\nbackground=\"blue\"\n" +
        "[components.text_area.text]\nforeground=\"magenta\"\n" +
        "[components.text_area.states.focused.text]\nunderline=true\n" +
        "[components.text_area.states.disabled.text]\ndim=true\n" +
        "[components.text_area.states.selected.text]\nbackground=\"blue\"\n")
    let c = TextEditController(); let input = Box<?Component>(Option<Component>.None); let area = Box<?Component>(Option<Component>.None)
    let ac = TextEditController()
    let root = Column {
        Text("T")
        Canvas({_ => Size(1, 1)}, {p => p.put(0, 0, "C")})
        input.value = Some(TextInput(Observable<String>("I"), controller: Some(c)))
        area.value = Some(TextArea(Observable<String>("A\nB"), controller: Some(ac)))
    }
    let app = Application(root, theme: theme); app.startHeadless()
    try {
        let first = app.snapshot(3, 5)
        cell(first, 0, 0, "T", 1, false, Style(foreground: Color.Yellow))
        cell(first, 0, 1, "C", 1, false, Style(foreground: Color.Cyan))
        cell(first, 0, 2, "I", 1, false, Style(foreground: Color.Green, underline: true))
        cell(first, 0, 3, "A", 1, false, Style(foreground: Color.Magenta))
        check(app.caretSnapshot().visible && app.caretSnapshot().owner.getOrThrow().sameNode(ref(input.value.getOrThrow())),
            "editor Canvas itself owns caret")
        ui(app, { => c.selectAll() })
        let selected = app.snapshot(3, 5)
        cell(selected, 0, 2, "I", 1, false, Style(foreground: Color.Green, background: Color.Blue, underline: true))
        ui(app, { => ref(area.value.getOrThrow()).requestFocus(); ac.select(TextSelection(0, 2)) })
        let lf = app.snapshot(3, 5)
        cell(lf, 0, 3, "A", 1, false, Style(foreground: Color.Magenta, background: Color.Blue, underline: true))
        cell(lf, 1, 3, " ", 1, false, Style(foreground: Color.Magenta, background: Color.Blue, underline: true))
        cell(lf, 0, 4, "B", 1, false, Style(foreground: Color.Magenta, underline: true))
        check(ac.snapshot().text == "A\nB", "selected LF display space is not content")
        input.value.getOrThrow().foreground(Color.Red)
        area.value.getOrThrow().foreground(Color.Red)
        let explicit = app.snapshot(3, 5)
        check(explicit.cellAt(0, 2).style.foreground == Color.Red && explicit.cellAt(0, 3).style.foreground == Color.Red,
            "explicit foreground beats selected and role")
        input.value.getOrThrow().enabled(false); area.value.getOrThrow().enabled(false)
        let disabled = app.snapshot(3, 5)
        check(disabled.cellAt(0, 2).style.dim && disabled.cellAt(0, 3).style.dim && !app.caretSnapshot().visible,
            "real disabled appearance and focus eligibility")
    } finally { app.dispose() }
    // Theme visual disabled does not disable the actual input behavior.
    let ctl = TextEditController(); let node = TextInput(Observable<String>("x"), controller: Some(ctl))
        .visualStates(VisualStates(disabled: true))
    let a = Application(node, theme: theme); a.startHeadless()
    try { key(a, node, "text", text: "y"); check(ctl.snapshot().text == "yx" && ref(node).isEnabled(), "visual disabled remains editable") }
    finally { a.dispose() }
}
