package widgets_small_contract

import cjtui.{Application, Color, Column, Label, Observable, Progress, Row, ScrollAxes, Style, Theme}

func progressGeometry(): Unit {
    equal(
        frame(
            Row {
                Progress(0.5);
            Label("|")
            },
            22,
            1
        ),
        "==========----------| ",
        "natural content width twenty"
    )
    equal(
        frame(
            Column {
                Progress(0.5);
            Label("|")
            },
            20,
            2
        ),
        "==========----------\n|                   ",
        "natural content height one"
    )
    equal(frame(Progress(0.5).width(6).padding(left: 1, right: 1), 6, 1), " ==-- ", "padding outside content bar")
    for (fraction in [0.0, 0.5, 1.0, -0.0]) {
        equal(frame(Progress(fraction).width(0).height(2), 0, 2), "", "valid zero width")
        equal(frame(Progress(fraction).height(0), 20, 0), "", "valid zero height")
    }
    equal(frame(Progress(0.0).width(1), 1, 1), "-", "zero at width one")
    equal(frame(Progress(1.0).width(1), 1, 1), "=", "full at width one")
    for (invalid in [-0.1, 1.1, Float64.NaN, Float64.Inf, -Float64.Inf]) {
        for (width in [0, 1, 20]) {
            for (height in [0, 1, 2]) {
                expectInvalidProperty(
                    {
                        =>
                        frame(Progress(invalid).width(width).height(height), width, height);
                        ()
                    },
                    "constant invalid extent matrix"
                )
                expectInvalidProperty(
                    {
                        =>
                        frame(Progress({=> invalid}).width(width).height(height), width, height);
                        ()
                    },
                    "getter invalid extent matrix"
                )
            }
        }
    }

    let model = Observable<Float64>(0.5)
    let progress = Progress({=> model.get()})
    let app = Application(progress)
    app.startHeadless()
    equal(app.snapshot(20, 1).toPlainText(), "==========----------", "reactive Progress half")
    assertEvent(app.stats().subscriptions == 1, "fraction belongs to one dependency readset, not measure and paint")
    let initial = app.stats()
    model.set(1.0)
    equal(app.snapshot(20, 1).toPlainText(), "====================", "fraction mutation repaints")
    assertEvent(
        app.stats().subscriptions == 1 && app.stats().builds == initial.builds && app.stats().paints > initial.paints,
        "fraction is paint-only with no structure rebuild; M1 measure count unconstrained")
    app.dispose()

    let viewport = Progress(0.5).viewport(ScrollAxes.Horizontal).width(5).height(1)
    let scrolling = Application(viewport)
    scrolling.startHeadless()
    equal(scrolling.snapshot(5, 1).toPlainText(), "=====", "viewport draws twenty-column logical half before clip")
    let ref = viewport.reference().getOrThrow()
    assertEvent(ref.viewportSnapshot().contentWidth == 20, "viewport logical natural width twenty")
    ref.scrollTo(8, 0)
    equal(scrolling.snapshot(5, 1).toPlainText(), "==---", "scroll clips same logical bar without rescaling")
    scrolling.dispose()

    let theme = Theme.parse(
        "schema_version = 1\nname = \"S Progress\"\n" +
            "[components.progress.spacing]\nwidth = 8\nheight = 2\npadding_left = 1\npadding_right = 1\n" +
            "[components.progress.text]\nforeground = \"green\"\nbackground = \"black\"\n")
    let themed = Progress(0.5)
    let themedApp = Application(themed, theme: theme)
    themedApp.startHeadless()
    let before = themedApp.snapshot(8, 2)
    equal(before.toPlainText(), " ===--- \n        ", "theme dimensions padding, first content row only")
    assertEvent(
        before.cellAt(1, 0).style == Style(foreground: Color.Green, background: Color.Black) &&
            before.cellAt(6, 0).style == Style(foreground: Color.Green, background: Color.Black),
        "filled and empty segments share defaultStyle")
    themed.width(6).height(1)
    equal(themedApp.snapshot(8, 2).toPlainText(), " ==--   \n        ", "explicit dimensions beat theme")
    themedApp.dispose()
}
