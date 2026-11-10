package runtime_contract

import cjtui.*

// Catches frozen values, lost multi-view subscriptions, stale branch dependencies,
// background evaluation, and equal typed targets producing frames.
func observableBindings(): Unit {
    let choose = Observable<Bool>(true)
    let left = Observable<String>("L")
    let right = Observable<String>("R")
    let calls = Box<Int64>(0)
    let owner = Thread.currentThread.id
    let root = Text({ =>
        check(Thread.currentThread.id == owner, "getter evaluates on UI owner")
        calls.value++
        if (choose.get()) { left.get() } else { right.get() }
    })
    let app = Application(root)
    let second = Application(Text({ => left.get() }))
    app.startHeadless()
    second.startHeadless()
    picture(app.snapshot(3, 1), "L  ", "initial branch")
    picture(second.snapshot(3, 1), "L  ", "second view shares observable")
    check(app.stats().subscriptions == 2 && second.stats().subscriptions == 1, "views own separate dependencies")
    let initialCalls = calls.value
    let initialFrames = app.stats().frames
    right.set("Q")
    app.snapshot(3, 1)
    check(calls.value == initialCalls && app.stats().frames == initialFrames, "inactive branch causes no getter or frame")
    choose.set(false)
    picture(app.snapshot(3, 1), "Q  ", "conditional getter switches dependency")
    let switchedCalls = calls.value
    left.set("M")
    app.snapshot(3, 1)
    check(calls.value == switchedCalls, "old branch subscription is removed")
    picture(second.snapshot(3, 1), "M  ", "shared state still updates another view")
    let before = app.stats().frames
    right.set("Q")
    app.snapshot(3, 1)
    check(calls.value == switchedCalls + 1 && app.stats().frames == before, "equal typed target reevaluates without frame")
    let work = spawn { right.set("B"); right.get() }
    check(work.get(Duration.second * 5) == "B" && calls.value == switchedCalls + 1, "background set/get runs no UI getter")
    picture(app.snapshot(3, 1), "B  ", "UI boundary consumes background invalidation")
    app.dispose()
    emptyStats(app, "disposing one view releases its subscriptions")
    left.set("S")
    picture(second.snapshot(3, 1), "S  ", "other view survives first disposal")
    second.dispose()
}

// Catches leaked replaced subscriptions, category notify that fails to reread,
// unrelated getter sweeps, missing typed setters, and auto-size stale bindings.
func replacementAndNotify(): Unit {
    let first = Observable<String>("old")
    let second = Observable<String>("new")
    let plain = Box<String>("A")
    let chosenCalls = Box<Int64>(0)
    let otherCalls = Box<Int64>(0)
    let chosen = Box<?Component>(Option<Component>.None)
    let tree = Column {
        chosen.value = Some(Text({ => first.get() }).text({ => second.get() }))
        Text({ => otherCalls.value++; "U" })
    }
    let app = Application(tree)
    app.startHeadless()
    let target = chosen.value.getOrThrow()
    picture(app.snapshot(5, 2), "new  \nU    ", "last getter replaces prior getter")
    check(app.stats().subscriptions == 1, "replacement has no old dependency")
    target.text("fixed")
    picture(app.snapshot(5, 2), "fixed\nU    ", "constant replaces getter")
    check(app.stats().subscriptions == 0, "constant detaches old observable")
    first.set("bad"); second.set("bad")
    picture(app.snapshot(5, 2), "fixed\nU    ", "replaced sources cannot overwrite constant")
    target.text({ => chosenCalls.value++; plain.value })
    picture(app.snapshot(3, 2), "A  \nU  ", "getter replaces constant after mount")
    let r = ref(target)
    let before = chosenCalls.value
    let unrelated = otherCalls.value
    plain.value = "B"
    r.notify(ChangeKind.Style)
    picture(app.snapshot(3, 2), "A  \nU  ", "Style notify does not reread content")
    check(chosenCalls.value == before, "category notify targets its getter category")
    r.notify(ChangeKind.Content)
    picture(app.snapshot(3, 2), "B  \nU  ", "Content notify rereads ordinary captured variable")
    plain.value = "C"
    r.notify(ChangeKind.Bindings)
    picture(app.snapshot(3, 2), "C  \nU  ", "Bindings notify rereads saved getter")
    check(otherCalls.value == unrelated, "targeted notify does not sweep sibling getter")
    let stable = app.stats()
    let frozenCalls = chosenCalls.value
    for (_ in 0..3) { app.snapshot(3, 2) }
    check(chosenCalls.value == frozenCalls && app.stats().measures == stable.measures &&
        app.stats().paints == stable.paints && app.stats().frames == stable.frames,
        "idle boundaries perform no getter/layout/paint/frame work")
    app.dispose()
    let natural = Text("XYZ").width({ => 1 }).widthAuto().height({ => 1 }).heightAuto()
    picture(render(natural, 4, 1), "XYZ ", "auto dimensions remove previous getters")
    let all = Column { Text("x").text({ => "y" }).textAlign({ => Alignment.End }).width(5) }
        .foreground({ => Color.Red }).background({ => Color.Blue })
        .bold({ => true }).dim({ => false }).italic({ => true })
        .underline({ => false }).inverse({ => true }).strikethrough({ => false })
        .width({ => 5 }).height({ => 3 }).minWidth({ => 0 }).minHeight({ => 0 })
        .layoutWeight({ => 1 }).padding({ => 0 }).gap({ => 0 })
        .alignItems({ => Alignment.Start }).justifyContent({ => Alignment.Start })
        .border({ => BorderStyle.None }).borderColor({ => Color.Cyan }).visible({ => true })
    let styled = render(all, 5, 3)
    picture(styled, "    y\n     \n     ", "typed overloads share existing layout path")
    check(styled.cellAt(4, 0).style == Style(foreground: Color.Red, background: Color.Blue,
        bold: true, dim: false, italic: true, underline: false, inverse: true, strikethrough: false),
        "typed style getters retain all exact attributes")
    illegal({ => Text("x").width(-1); () }, "negative constant layout remains rejected")
    illegal({ => render(Text("x").width({ => -1 }), 2, 1); () }, "negative bound layout rejected")
    picture(render(Text("ok"), 2, 1), "ok", "invalid getter leaves no collector residue")
}

func subscriptionRace(): Unit {
    let value = Observable<String>("old")
    let didRead = Gate()
    let didSet = Gate()
    let first = Box<Bool>(true)
    let owner = Thread.currentThread.id
    let writer = spawn {
        didRead.awaitOpen()
        check(Thread.currentThread.id != owner, "race writer runs on an actual different thread")
        value.set("new")
        didSet.open()
    }
    let root = Text({ =>
        let read = value.get()
        if (first.value) {
            first.value = false
            didRead.open()
            didSet.awaitOpen()
        }
        read
    })
    let app = Application(root)
    app.startHeadless()
    writer.get(Duration.second * 5)
    picture(app.snapshot(3, 1), "new", "set after read before subscription installation cannot be lost")
    app.dispose()
}
