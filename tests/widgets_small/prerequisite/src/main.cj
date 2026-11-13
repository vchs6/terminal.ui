package widgets_small_prerequisite

import cjtui.{Application, Canvas, Color, Column, Component, Constraints, KeyEvent, Observable, PaintContext, Size, StyleKeys, StyleValue, Text, Theme, ThemeRole, VisualState, VisualStates, render}

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception(name) }
}

main(): Int64 {
    let calls = [0]
    let text = Observable<String>("A")
    let handles = Array<?Component>(1, repeat: None)
    let root = Column {
        handles[0] = Some(Text({ => text.get() }).themeRole(ThemeRole.Button)
            .enabled({ => true }).focusable(true).visualStates(VisualStates(selected: true))
            .setStyle(StyleKeys.foreground, StyleValue<Color>.Value(Color.Yellow), state: VisualState.Selected)
            .defaultAction({ event => calls[0]++; event.preventDefault() }))
        Canvas({ constraints: Constraints => constraints.constrain(Size(2, 1)) },
            { context: PaintContext => context.put(0, 0, "==") })
    }
    let first = handles[0].getOrThrow()
    let app = Application(root)
    app.startHeadless()
    check(app.focusedNode().getOrThrow().sameNode(first.reference().getOrThrow()), "native focus public shape")
    app.dispatch(first.reference().getOrThrow(), KeyEvent("text", text: " ", ctrl: false, alt: false, shift: false))
    check(calls[0] == 1, "public default action executes once")
    check(app.snapshot(2, 2).toPlainText() == "A \n==", "public Text/Canvas exact frame")
    check(app.stats().mountedNodes == 3, "public stats")
    text.set("B")
    check(app.snapshot(2, 2).cellAt(0, 0).style.foreground == Color.Yellow, "structured selected style")
    let owner = first.reference().getOrThrow()
    let accepted = spawn { => app.post(owner, { => text.set("C") }) }
    check(accepted.get(), "worker owner post accepted")
    check(app.snapshot(2, 2).toPlainText() == "C \n==", "worker post drained at boundary")
    app.dispose()
    check(app.stats().mountedNodes == 0 && app.stats().subscriptions == 0, "cleanup stats")
    check(render(Text("e\u{301}界"), 3, 1).toPlainText() == "e\u{301}界", "public Unicode")
    check(Theme.parse("schema_version = 1\nname = \"S-prereq\"\n").name == "S-prereq", "Theme public parse")
    println("PREREQUISITE_PUBLIC_CONSUMER_PASS")
    0
}
