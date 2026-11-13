package widgets_small_contract

import cjtui.{Application, Button, Checkbox, Color, Column, Label, Observable, Radio, Style, StyleUse, Theme, ThemeSource, VisualStates, StyleRule, StyleKeys, StyleValue, VisualState, KeyEvent, render}

func stateTheme(): Theme {
    Theme.parse("schema_version = 1\nname = \"S states\"\n" +
        "[text]\nforeground = \"white\"\nbackground = \"black\"\n" +
        "[styles.test.text]\nforeground = \"cyan\"\n" +
        "[styles.test.states.focused.text]\nforeground = \"blue\"\n" +
        "[styles.test.states.selected.text]\nforeground = \"yellow\"\n" +
        "[styles.test.states.disabled.text]\nforeground = \"red\"\n")
}

func styleIs(actual: Style, color: Color, name: String): Unit {
    assertEvent(actual == Style(foreground: color, background: Color.Black), name)
}

func themeCases(): Unit {
    let theme = stateTheme()
    let rule = StyleRule()
        .withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Cyan))
        .withValue(StyleKeys.background, StyleValue<Color>.Value(Color.Black))
        .withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Blue), state: VisualState.Focused)
        .withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Yellow), state: VisualState.Selected)
        .withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Red), state: VisualState.Disabled)
    let detached = Checkbox({ => true }, { _: Bool => () }).styles([StyleUse.Inline(rule)])
    assertEvent(detached.reference().isNone(), "detached render has no public ref")
    // Detached render uses a public inline rule with the same literal palette.
    styleIs(render(detached, 3, 1).cellAt(0, 0).style, Color.Yellow, "detached selected")
    assertEvent(detached.reference().isNone(), "detached render does not publish fake ref")
    let disabled = Checkbox({ => true }, { _: Bool => () }).styles([StyleUse.Inline(rule)]).enabled(false).visualStates(VisualStates(disabled: false))
    styleIs(render(disabled, 3, 1).cellAt(0, 0).style, Color.Red, "detached disabled beats selected")
    let ancestor = Column { Radio({ => true }, { => () }).styles([StyleUse.Inline(rule)]) }.enabled(false)
    styleIs(render(ancestor, 3, 1).cellAt(0, 0).style, Color.Red, "detached ancestor disabled")

    let button = Button("B", { => () }).styles([StyleUse.Named("test")])
    let app = Application(button)
    app.loadTheme(ThemeSource.Prepared(theme))
    app.startHeadless()
    styleIs(app.snapshot(1, 1).cellAt(0, 0).style, Color.Blue, "mounted native focused")
    // Public appearance false cannot suppress real focus.
    button.visualStates(VisualStates(focused: false, disabled: false))
    styleIs(app.snapshot(1, 1).cellAt(0, 0).style, Color.Blue, "explicit false preserves native focus")
    app.dispose()

    let selected = Radio({ => true }, { => () }).styles([StyleUse.Named("test")])
    let selectedApp = Application(selected)
    selectedApp.loadTheme(ThemeSource.Prepared(theme))
    selectedApp.startHeadless()
    styleIs(selectedApp.snapshot(3, 1).cellAt(0, 0).style, Color.Yellow, "selected beats native focused")
    selectedApp.dispose()

    let enabled = Observable<Bool>(false)
    let root = Column {
        Checkbox({ => true }, { _: Bool => () }).styles([StyleUse.Named("test")])
            .enabled({ => enabled.get() }).visualStates(VisualStates(disabled: false))
    }
    let inherited = Application(root)
    inherited.loadTheme(ThemeSource.Prepared(theme))
    inherited.startHeadless()
    styleIs(inherited.snapshot(3, 1).cellAt(0, 0).style, Color.Red, "mounted getter-disabled and explicit false")
    enabled.set(true)
    styleIs(inherited.snapshot(3, 1).cellAt(0, 0).style, Color.Blue, "later visualStates replaces builtin selected getter")
    root.enabled(false)
    styleIs(inherited.snapshot(3, 1).cellAt(0, 0).style, Color.Red, "mounted ancestor disabled exact style")
    inherited.dispose()

    let calls = [0]
    let visual = Button("B", { => calls[0]++ }).styles([StyleUse.Named("test")])
        .visualStates(VisualStates(disabled: true, selected: true, focused: true))
    let simulated = Application(visual)
    simulated.loadTheme(ThemeSource.Prepared(theme))
    simulated.startHeadless()
    styleIs(simulated.snapshot(1, 1).cellAt(0, 0).style, Color.Red, "declared disabled wins all state layers")
    simulated.dispatch(visual.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(calls[0] == 1, "visual disabled true does not disable behavior")
    visual.foreground(Color.Green)
    styleIs(simulated.snapshot(1, 1).cellAt(0, 0).style, Color.Green, "explicit per-field foreground override")
    simulated.dispose()

    let fakeFocusCalls = [0]
    let focusPair = Column {
        Button("A", { => () }).styles([StyleUse.Named("test")])
        Button("B", { => fakeFocusCalls[0]++ }).styles([StyleUse.Named("test")])
            .visualStates(VisualStates(focused: true))
    }
    let focusApp = Application(focusPair)
    focusApp.loadTheme(ThemeSource.Prepared(theme))
    focusApp.startHeadless()
    let refs = focusPair.reference().getOrThrow().children()
    assertEvent(focusApp.focusedNode().getOrThrow().sameNode(refs[0]), "declared focused does not move native focus")
    styleIs(focusApp.snapshot(1, 2).cellAt(0, 1).style, Color.Blue, "declared focused paints unfocused second view")
    focusApp.dispatch(refs[1], KeyEvent("enter"))
    assertEvent(fakeFocusCalls[0] == 0, "declared focused true does not activate unfocused target")
    focusApp.dispose()

    let wrapped = Application(Label("ABCD"))
    wrapped.loadTheme(ThemeSource.Prepared(Theme.parse("schema_version = 1\nname = \"S wrap\"\n[components.label.text]\nwrap = \"grapheme\"\n[components.label.spacing]\nwidth = 2\n")))
    wrapped.startHeadless()
    equal(wrapped.snapshot(2, 2).toPlainText(), "AB\nCD", "widget leaves theme wrap and width unshadowed")
    wrapped.dispose()
}
