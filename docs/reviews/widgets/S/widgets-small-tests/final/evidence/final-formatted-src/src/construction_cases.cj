package widgets_small_contract

import cjtui.{Application, Button, Checkbox, Column, Label, Progress, Radio, TextWrap}

func constructionCases(): Unit {
    let root = Column {
        Label("L").width(6)
        Button({=> "B"}, {=> ()}).focusable(false).width(6)
        Checkbox({=> false}, {_: Bool => ()}, label: "C").enabled(true).width(6)
        Radio({=> true}, {=> ()}, label: {=> "R"}).width(6)
        Progress({=> 0.5}).width(6)
    }
    let app = Application(root)
    app.startHeadless()
    equal(app.snapshot(6, 5).toPlainText(), "L     \nB     \n[ ] C \n(*) R \n===---",
        "all five raw block roots and chains")
    assertEvent(root.reference().getOrThrow().children().size == 5 && app.stats().mountedNodes == 6,
        "one collector root per factory; chain does not create wrappers")
    app.dispose()
    expectInvalidProperty(
        {
            =>
            Label("L").gap(1);
            ()
        },
        "Text-root Label has no gap capability"
    )
    expectInvalidProperty(
        {
            =>
            Button("B", {=> ()}).gap(1);
            ()
        },
        "Text-root Button has no gap capability"
    )
    expectInvalidProperty(
        {
            =>
            Progress(0.5).wrap(TextWrap.Grapheme);
            ()
        },
        "Canvas-root Progress has no text-wrap capability"
    )
}
