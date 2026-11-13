package widgets_small_contract

import cjtui.{Application, Button, Checkbox, Column, Component, Label, Observable, Progress, Radio, UIException, render}

// The literals here are independent, hand-specified W001-W004 expectations.
// This is a normal public CJPM consumer. It becomes executable when the
// prerequisite public API is delivered; no declarations or product helpers
// are supplied by this test package.
func equal(actual: String, expected: String, caseName: String): Unit {
    if (actual != expected) {
        throw IllegalStateException("${caseName}: got [${actual}], expected [${expected}]")
    }
}

func frame(root: Component, width: Int64, height: Int64): String {
    render(root, width, height).toPlainText()
}

func expectCaptionError(action: () -> Unit, caseName: String): Unit {
    var rejected = false
    try {
        action()
    } catch (_: IllegalArgumentException) {
        rejected = true
    }
    if (!rejected) {
        throw IllegalStateException("${caseName}: expected IllegalArgumentException")
    }
}

func expectInvalidProperty(action: () -> Unit, caseName: String): Unit {
    var code = ""
    try {
        action()
    } catch (error: UIException) {
        code = error.code
    }
    equal(code, "InvalidProperty", caseName)
}

func staticCaptions(): Unit {
    equal(frame(Label("ok"), 4, 1), "ok  ", "Label constant")
    equal(frame(Button("Go", {=> ()}), 4, 1), "Go  ", "Button constant")
    equal(frame(Button({=> "Go"}, {=> ()}), 4, 1), "Go  ", "Button getter")
    equal(frame(Checkbox({=> false}, {_ =>}, label: ""), 4, 1), "[ ] ", "Checkbox empty")
    equal(frame(Checkbox({=> true}, {_ =>}, label: "Y"), 5, 1), "[x] Y", "Checkbox selected")
    equal(frame(Radio({=> false}, {=> ()}, label: ""), 3, 1), "( )", "Radio empty")
    equal(frame(Radio({=> true}, {=> ()}, label: "Y"), 5, 1), "(*) Y", "Radio selected")
    equal(frame(Checkbox({=> false}, {_ =>}, label: {=> "Y"}), 5, 1), "[ ] Y", "Checkbox label getter")
    equal(frame(Radio({=> false}, {=> ()}, label: {=> "Y"}), 5, 1), "( ) Y", "Radio label getter")
    equal(frame(Label("界"), 2, 1), "界", "wide Unicode intact")
    equal(frame(Label("界"), 1, 1), " ", "wide Unicode clipped whole")
    equal(
        frame(
            Column {
                Label("A");
            Button("B", {=> ()})
            },
            2,
            2
        ),
        "A \nB ",
        "raw block"
    )
}

func latestCaptions(): Unit {
    let name = Observable<String>("界A")
    let app = Application(Label({=> name.get()}))
    app.startHeadless()
    equal(app.snapshot(4, 1).toPlainText(), "界A ", "getter initial")
    name.set("Z")
    equal(app.snapshot(4, 1).toPlainText(), "Z   ", "getter shorter clears tail")
    name.set("")
    equal(app.snapshot(4, 1).toPlainText(), "    ", "getter empty clears tail")
    app.dispose()
}

func invalidCaptions(): Unit {
    expectCaptionError(
        {
            =>
            frame(Label("a\nb"), 4, 1);
            ()
        },
        "LF"
    )
    expectCaptionError(
        {
            =>
            frame(Button("a\rb", {=> ()}), 4, 1);
            ()
        },
        "CR"
    )
    expectCaptionError(
        {
            =>
            frame(Label("a\u{2028}b"), 4, 1);
            ()
        },
        "U+2028"
    )
    expectCaptionError(
        {
            =>
            frame(Label("a\u{2029}b"), 4, 1);
            ()
        },
        "U+2029"
    )
    expectCaptionError(
        {
            =>
            frame(Checkbox({=> false}, {_ =>}, label: "a\u{1b}b"), 8, 1);
            ()
        },
        "ESC"
    )
    expectCaptionError(
        {
            =>
            frame(Radio({=> false}, {=> ()}, label: "a\tb"), 8, 1);
            ()
        },
        "TAB"
    )
}

func progressFrames(): Unit {
    equal(frame(Progress(0.0), 20, 1), "--------------------", "zero natural bar")
    equal(frame(Progress(0.5), 20, 1), "==========----------", "half natural bar")
    equal(frame(Progress({=> 0.5}), 20, 1), "==========----------", "half getter bar")
    equal(frame(Progress(1.0), 20, 1), "====================", "full natural bar")
    equal(frame(Progress(-0.0), 1, 1), "-", "negative zero")
    equal(frame(Progress(0.5).width(0), 0, 1), "", "zero width")
    equal(frame(Progress(0.5).width(1), 1, 1), "-", "one column floor")
    equal(frame(Progress(0.5).width(20).height(2), 20, 2), "==========----------\n                    ",
        "height two only first row")
    equal(frame(Progress(0.5).height(0), 20, 0), "", "zero height")
    expectInvalidProperty(
        {
            =>
            frame(Progress(-0.1).width(0), 0, 1);
            ()
        },
        "negative at zero width"
    )
    expectInvalidProperty(
        {
            =>
            frame(Progress(1.1).width(0), 0, 1);
            ()
        },
        "over one at zero width"
    )
    expectInvalidProperty(
        {
            =>
            frame(Progress(Float64.NaN), 1, 1);
            ()
        },
        "NaN"
    )
    expectInvalidProperty(
        {
            =>
            frame(Progress(Float64.Inf), 1, 1);
            ()
        },
        "positive infinity"
    )
    expectInvalidProperty(
        {
            =>
            frame(Progress(-Float64.Inf), 1, 1);
            ()
        },
        "negative infinity"
    )
}

main(): Int64 {
    staticCaptions()
    latestCaptions()
    invalidCaptions()
    progressFrames()
    captionMatrix()
    themeCases()
    progressGeometry()
    eventCases()
    lifecycleCases()
    0
}
