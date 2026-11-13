package widgets_small_contract

import cjtui.{Application, Button, Checkbox, Column, Label, Observable, Radio, TextWrap}

func captionMatrix(): Unit {
    // All C0, DEL and C1 controls, plus every logical newline, for each
    // caption-bearing S factory and its constant/getter overload.
    for (point in 0..160) {
        if (point >= 32 && point < 127) {
            continue
        }
        captionRejected(String(Rune(UInt32(point))))
    }
    for (value in ["a\nb", "a\r\nb", "a\rb", "a\u{2028}b", "a\u{2029}b"]) {
        captionRejected(value)
    }
    equal(frame(Label("e\u{301}"), 1, 1), "e\u{301}", "combining cluster intact")
    equal(frame(Label("👩‍💻Z"), 2, 1), "👩‍💻", "ZWJ cluster intact")
    equal(frame(Label("👩‍💻Z"), 1, 1), " ", "ZWJ cluster clipped whole")
    equal(frame(Label("界AB").width(2).wrap(TextWrap.Grapheme), 2, 2), "界\nAB", "logical single line can visually wrap")

    let caption = Observable<String>("界A")
    let root = Column {
        Button({=> caption.get()}, {=> ()})
        Checkbox({=> false}, {_: Bool => ()}, label: {=> caption.get()})
        Radio({=> false}, {=> ()}, label: {=> caption.get()})
    }
    let app = Application(root)
    app.startHeadless()
    equal(app.snapshot(8, 3).toPlainText(), "界A     \n[ ] 界A \n( ) 界A ", "all getter captions initial")
    caption.set("Z")
    equal(app.snapshot(8, 3).toPlainText(), "Z       \n[ ] Z   \n( ) Z   ", "all getter captions shorter")
    caption.set("")
    equal(app.snapshot(8, 3).toPlainText(), "        \n[ ]     \n( )     ",
        "all getter captions empty with no separator")
    app.dispose()
}

func captionRejected(value: String): Unit {
    expectCaptionError(
        {
            =>
            frame(Label(value), 12, 2);
            ()
        },
        "Label constant control"
    )
    expectCaptionError(
        {
            =>
            frame(Label({=> value}), 12, 2);
            ()
        },
        "Label getter control"
    )
    expectCaptionError(
        {
            =>
            frame(Button(value, {=> ()}), 12, 2);
            ()
        },
        "Button constant control"
    )
    expectCaptionError(
        {
            =>
            frame(Button({=> value}, {=> ()}), 12, 2);
            ()
        },
        "Button getter control"
    )
    expectCaptionError(
        {
            =>
            frame(Checkbox({=> false}, {_: Bool => ()}, label: value), 12, 2);
            ()
        },
        "Checkbox constant control"
    )
    expectCaptionError(
        {
            =>
            frame(Checkbox({=> false}, {_: Bool => ()}, label: {=> value}), 12, 2);
            ()
        },
        "Checkbox getter control"
    )
    expectCaptionError(
        {
            =>
            frame(Radio({=> false}, {=> ()}, label: value), 12, 2);
            ()
        },
        "Radio constant control"
    )
    expectCaptionError(
        {
            =>
            frame(Radio({=> false}, {=> ()}, label: {=> value}), 12, 2);
            ()
        },
        "Radio getter control"
    )
}
