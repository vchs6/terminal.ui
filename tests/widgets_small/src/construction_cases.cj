package widgets_small_contract

import cjtui.{Application, Button, Checkbox, Column, Label, Progress, Radio, StyleKeys, StyleRule, StyleUse, StyleValue, TextWrap}

func constructionCases(): Unit {
    let root = Column {
        Label("L").width(6)
        Button({ => "B" }, { => () }).focusable(false).width(6)
        Checkbox({ => false }, { _: Bool => () }, label: "C").enabled(true).width(6)
        Radio({ => true }, { => () }, label: { => "R" }).width(6)
        Progress({ => 0.5 }).width(6)
    }
    let app = Application(root)
    app.startHeadless()
    equal(app.snapshot(6, 5).toPlainText(), "L     \nB     \n[ ] C \n(*) R \n===---", "all five raw block roots and chains")
    assertEvent(root.reference().getOrThrow().children().size == 5 && app.stats().mountedNodes == 6,
        "one collector root per factory; chain does not create wrappers")
    app.dispose()
    expectLegacyPropertyError({ => Label("L").gap(1); () }, "Label legacy constant gap rejects with IllegalArgumentException")
    expectLegacyPropertyError({ => Button("B", { => () }).gap(1); () }, "Button legacy constant gap rejects with IllegalArgumentException")
    expectInvalidProperty({ => Label("L").setStyle(StyleKeys.gap, StyleValue<Int64>.Value(1)); () }, "Label typed gap rejects with InvalidProperty")
    expectInvalidProperty({ => Button("B", { => () }).gap({ => 1 }); () }, "Button getter gap rejects with InvalidProperty")
    let incompatible = StyleRule().withValue(StyleKeys.gap, StyleValue<Int64>.Value(1))
    expectInvalidProperty({ => frame(Label("L").styles([StyleUse.Inline(incompatible)]), 2, 1); () }, "Label resolved Inline gap rejects with InvalidProperty")
    expectInvalidProperty({ => Progress(0.5).wrap(TextWrap.Grapheme); () }, "Canvas-root Progress has no text-wrap capability")
}

// LEGACY-PROP-001 preserves this old shortcut's concrete exception type.
func expectLegacyPropertyError(action: () -> Unit, caseName: String): Unit {
    var rejected = false
    try { action() } catch (_: IllegalArgumentException) { rejected = true }
    if (!rejected) { throw IllegalStateException("${caseName}: expected IllegalArgumentException") }
}
