package rich_text_contract

import cjtui.*

func bindingContract(): Unit {
    let old = Observable<String>("old")
    let next = Observable<RichText>(RichText([TextSpan("new", style: TextStylePatch(foreground: Some(Color.Red)))]))
    let last = Observable<String>("last")
    let calls = [Int64(0)]
    let target = Text({ => old.get() })
    let app = Application(target)
    app.startHeadless()
    check(app.snapshot(5, 1).toPlainText() == "old  " && app.stats().subscriptions == 1, "String getter mounted")
    let worker = spawn {
        uiError("WrongUIContext", { => target.text(RichText("bad")); () }, "mounted RichText setter is UI-owned")
        uiError("WrongUIContext", { => target.text({ => RichText("bad") }); () }, "mounted RichText getter setter is UI-owned")
    }
    worker.get(Duration.second * 5)
    target.text({ => calls[0]++; next.get() })
    let first = app.snapshot(5, 1)
    check(first.toPlainText() == "new  " && first.cellAt(0, 0).style.foreground == Color.Red &&
        app.stats().subscriptions == 1, "RichText getter replaces String subscription")
    let count = calls[0]
    old.set("stale")
    app.snapshot(5, 1)
    check(calls[0] == count, "String dependency detached after typed replacement")
    let stable = app.stats()
    next.set(RichText([TextSpan("n", style: TextStylePatch(foreground: Some(Color.Red))),
        TextSpan("ew", style: TextStylePatch(foreground: Some(Color.Red)))]))
    app.snapshot(5, 1)
    check(app.stats().frames == stable.frames && app.stats().measures == stable.measures &&
        app.stats().paints == stable.paints, "equal normalized RichText target generates no frame/layout/paint")
    let beforeStyle = app.stats()
    next.set(RichText([TextSpan("new", style: TextStylePatch(foreground: Some(Color.Blue)))]))
    let blue = app.snapshot(5, 1)
    check(blue.cellAt(0, 0).style.foreground == Color.Blue && app.stats().paints > beforeStyle.paints &&
        app.stats().frames > beforeStyle.frames && app.stats().measures == beforeStyle.measures,
        "style-only span mutation paints without layout")
    let beforeText = app.stats()
    next.set(RichText("Z\nQ"))
    check(app.snapshot(5, 1).toPlainText() == "Z    " && app.stats().measures > beforeText.measures,
        "content and line changes trigger layout at unchanged viewport and clear old cells")
    check(app.snapshot(5, 2).toPlainText() == "Z    \nQ    ", "typed multiline survives resize")
    target.text({ => last.get() })
    check(app.snapshot(5, 1).toPlainText() == "last " && app.stats().subscriptions == 1,
        "String getter replaces RichText and releases old dependency")
    let beforeOld = app.stats().frames
    next.set(RichText("stale"))
    app.snapshot(5, 1)
    check(app.stats().frames == beforeOld, "old RichText dependency cannot update String getter")
    target.text(RichText("fixed"))
    check(app.snapshot(5, 1).toPlainText() == "fixed" && app.stats().subscriptions == 0,
        "RichText constant removes String getter")
    target.text({ => next.get() })
    check(app.snapshot(5, 1).toPlainText() == "stale" && app.stats().subscriptions == 1,
        "RichText getter replaces constant")
    target.text("plain")
    check(app.snapshot(5, 1).toPlainText() == "plain" && app.stats().subscriptions == 0,
        "String constant removes RichText getter")
    app.dispose()
    check(app.stats().subscriptions == 0 && app.stats().activeBindings == 0, "dispose releases typed text state")
    let initial = Application(Text({ => next.get() }))
    initial.startHeadless()
    check(initial.snapshot(5, 1).toPlainText() == "stale", "RichText getter constructor public overload")
    initial.dispose()
    println("PASS: String/RichText binding replacement and invalidation")
}
