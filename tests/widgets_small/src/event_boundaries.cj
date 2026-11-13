package widgets_small_contract

import cjtui.{Application, Button, Checkbox, Column, DefaultActionPhase, KeyEvent, Observable, Radio, UIKeyEvent}

func eventBoundaryCases(): Unit {
    let trace = [""]
    let clicks = [0]
    let eventBox = Array<?UIKeyEvent>(1, repeat: Option<UIKeyEvent>.None)
    let root = Column { Button("go", { =>
        assertEvent(eventBox[0].getOrThrow().defaultPrevented, "Target prevents before business callback")
        trace[0] += "callback;"; clicks[0]++
    }).onKeyCapture({ event => trace[0] += "target-capture;"; eventBox[0] = Some(event) })
        .onKey({ _ => trace[0] += "target-bubble;" })
    }
        .onKeyCapture({ _ => trace[0] += "root-capture;" })
        .onKey({ _ => trace[0] += "root-bubble;" })
        .defaultAction({ _ => trace[0] += "ancestor-default;" }, phase: DefaultActionPhase.Ancestor)
    let app = Application(root).onKeyEvent({ _ => trace[0] += "app;" })
        .onKey({ _ => trace[0] += "legacy;" })
    app.startHeadless()
    app.dispatch(root.reference().getOrThrow().children()[0], KeyEvent("enter"))
    equal(trace[0], "root-capture;target-capture;target-bubble;root-bubble;app;legacy;callback;", "exact phase trace")
    assertEvent(clicks[0] == 1, "one callback, no ancestor default after consumed activation")
    app.dispose()

    let consumed = [0]
    let consume = Button("go", { => consumed[0]++ }).onKey({ event => event.consume() })
    let consumedApp = Application(consume)
    consumedApp.startHeadless()
    consumedApp.dispatch(consume.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(consumed[0] == 0, "consume prevents Target")
    consumedApp.dispose()

    let enabled = Observable<Bool>(true)
    let current = [0]
    let change = Button("go", { => current[0]++ }).enabled({ => enabled.get() })
        .onKey({ _ => enabled.set(false) })
    let timing = Application(change)
    timing.startHeadless()
    timing.dispatch(change.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(current[0] == 1, "eligibility uses committed snapshot despite onKey business disable")
    timing.dispose()

    let cancelEnabled = Observable<Bool>(true)
    let cancelledCalls = [0]
    let cancelled = Button("go", { => cancelledCalls[0]++ }).enabled({ => cancelEnabled.get() })
        .onKey({ event => cancelEnabled.set(false); event.preventDefault() })
    let cancelledApp = Application(cancelled)
    cancelledApp.startHeadless()
    cancelledApp.dispatch(cancelled.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(cancelledCalls[0] == 0, "onKey business disable plus prevent cancels current event")
    cancelledApp.dispose()

    let checked = Observable<Bool>(false)
    let request = [false]
    let latestRequests = [0]
    let latest = Checkbox({ => checked.get() }, { value => latestRequests[0]++; request[0] = value })
        .onKey({ _ => checked.set(true) })
    let latestApp = Application(latest)
    latestApp.startHeadless()
    latestApp.dispatch(latest.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(latestRequests[0] == 1 && !request[0] && checked.get(), "Checkbox default reads latest true and requests false")
    latestApp.dispose()

    let overrideCalls = [0]
    let builtinCalls = [0]
    let overridden = Button("go", { => builtinCalls[0]++ })
        .defaultAction({ _ => overrideCalls[0]++ })
    let overwrite = Application(overridden)
    overwrite.startHeadless()
    overwrite.dispatch(overridden.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(overrideCalls[0] == 1 && builtinCalls[0] == 0, "same-phase defaultAction later write replaces builtin")
    overwrite.dispose()
}

func duplicateRadioLabels(): Unit {
    let selected = Observable<String>("none")
    let requests = [0, 0]
    let root = Column {
        Radio({ => selected.get() == "a" }, { => requests[0]++; selected.set("a") }, label: "same")
        Radio({ => selected.get() == "b" }, { => requests[1]++; selected.set("b") }, label: "same")
    }
    let app = Application(root)
    app.startHeadless()
    let children = root.reference().getOrThrow().children()
    app.dispatch(children[0], KeyEvent("enter"))
    // Selection writes schedule visual evaluation at the boundary, so exact default
    // getter-read count is measured with a separate non-writing callback below.
    assertEvent(requests[0] == 1 && requests[1] == 0 && selected.get() == "a", "same captions preserve application IDs")
    app.batch({ => children[1].requestFocus() })
    assertEvent(children[1].isFocused(), "second Radio focused before positive activation")
    app.dispatch(children[1], KeyEvent("text", text: " "))
    assertEvent(requests[0] == 1 && requests[1] == 1 && selected.get() == "b", "application alone groups radios")
    equal(app.snapshot(8, 2).toPlainText(), "( ) same\n(*) same", "duplicate label exact controlled frames")
    app.dispose()

    let reads = [0]
    let requested = [0]
    let seen = Array<?UIKeyEvent>(1, repeat: Option<UIKeyEvent>.None)
    let selectedRadio = Radio({ => reads[0]++; true }, { => requested[0]++ })
    let single = Application(selectedRadio).onKeyEvent({ event => seen[0] = Some(event) })
    single.startHeadless()
    reads[0] = 0
    single.dispatch(selectedRadio.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(reads[0] == 1 && requested[0] == 0, "selected Radio exactly one default read and zero request")
    assertEvent(seen[0].getOrThrow().defaultPrevented, "selected Radio still consumes activation")
    single.dispose()
}

func allControlKeyExclusions(): Unit {
    let calls = [0]
    for (control in [Button("B", { => calls[0]++ }),
        Checkbox({ => false }, { _: Bool => calls[0]++ }),
        Radio({ => false }, { => calls[0]++ })]) {
        calls[0] = 0
        let app = Application(control)
        app.startHeadless()
        let target = control.reference().getOrThrow()
        app.dispatch(target, KeyEvent("enter"))
        app.dispatch(target, KeyEvent("text", text: " "))
        assertEvent(calls[0] == 2, "all activatable controls accept unmodified Enter/Space exactly once")
        for (ctrl in [false, true]) {
            for (alt in [false, true]) {
                for (shift in [false, true]) {
                    if (!ctrl && !alt && !shift) { continue }
                    app.dispatch(target, KeyEvent("enter", ctrl: ctrl, alt: alt, shift: shift))
                    app.dispatch(target, KeyEvent("text", text: " ", ctrl: ctrl, alt: alt, shift: shift))
                }
            }
        }
        app.dispatch(target, KeyEvent("paste", text: " "))
        app.dispatch(target, KeyEvent("text", text: "  "))
        assertEvent(calls[0] == 2, "all seven modifier combinations, paste, multiple spaces excluded for all controls")
        app.dispose()
    }
}
