package widgets_small_contract

import cjtui.{Application, Button, Checkbox, Column, KeyEvent, Observable, Radio, UIException}

func assertEvent(value: Bool, caseName: String): Unit {
    if (!value) { throw IllegalStateException(caseName) }
}

func eventCases(): Unit {
    buttonEvents()
    checkboxEvents()
    radioEvents()
}

func buttonEvents(): Unit {
    var clicks = 0
    let button = Button("Go", { => clicks++ })
    let app = Application(button)
    app.startHeadless()
    let target = button.reference().getOrThrow()
    app.dispatch(target, KeyEvent("enter"))
    app.dispatch(target, KeyEvent("text", text: " "))
    assertEvent(clicks == 2, "Enter and single ASCII Space each click once")
    app.dispatch(target, KeyEvent("text", text: "  "))
    app.dispatch(target, KeyEvent("paste", text: " "))
    app.dispatch(target, KeyEvent("text", text: " ", alt: true))
    assertEvent(clicks == 2, "multi-space, paste and Alt+Space excluded")
    app.dispose()

    var prevented = 0
    let blocked = Button("Go", { => prevented++ }).onKeyCapture({ event => event.preventDefault() })
    let second = Application(blocked)
    second.startHeadless()
    second.dispatch(blocked.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(prevented == 0, "capture preventDefault suppresses default action")
    second.dispose()

    var stopped = 0
    let stopOnly = Button("Go", { => stopped++ }).onKeyCapture({ event => event.stopPropagation() })
    let third = Application(stopOnly)
    third.startHeadless()
    third.dispatch(stopOnly.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(stopped == 1, "stopPropagation alone preserves target default")
    third.dispose()

    var bubbleCalls = 0
    let parent = Column { Button("Go", { => bubbleCalls++ }) }
        .onKey({ event => event.preventDefault() })
    let fourth = Application(parent)
    fourth.startHeadless()
    fourth.dispatch(parent.reference().getOrThrow().children()[0], KeyEvent("enter"))
    assertEvent(bubbleCalls == 0, "bubble preventDefault suppresses default action")
    fourth.dispose()

    var appCalls = 0
    let appBlocked = Button("Go", { => appCalls++ })
    let fifth = Application(appBlocked).onKeyEvent({ event => event.preventDefault() })
    fifth.startHeadless()
    fifth.dispatch(appBlocked.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(appCalls == 0, "app preventDefault suppresses default action")
    fifth.dispose()

    var unfocusedCalls = 0
    let pair = Column { Button("first", { => () }); Button("second", { => unfocusedCalls++ }) }
    let sixth = Application(pair)
    sixth.startHeadless()
    let children = pair.reference().getOrThrow().children()
    assertEvent(sixth.focusedNode().getOrThrow().sameNode(children[0]), "first button receives initial focus")
    sixth.dispatch(children[1], KeyEvent("enter"))
    assertEvent(unfocusedCalls == 0, "legal unfocused target does not activate")
    sixth.dispose()

    var disabledCalls = 0
    let disabled = Column { Button("child", { => disabledCalls++ }) }.enabled(false)
    let seventh = Application(disabled)
    seventh.startHeadless()
    var rejected = false
    try { seventh.dispatch(disabled.reference().getOrThrow().children()[0], KeyEvent("enter")) }
    catch (_: UIException) { rejected = true }
    assertEvent(rejected && disabledCalls == 0, "disabled ancestor blocks dispatch")
    seventh.dispose()
}

func checkboxEvents(): Unit {
    let checked = Observable<Bool>(false)
    var getterCalls = 0
    var requests = 0
    var requested = false
    let box = Checkbox({ => getterCalls++; checked.get() }, { value => requests++; requested = value })
    let app = Application(box)
    app.startHeadless()
    let target = box.reference().getOrThrow()
    getterCalls = 0
    app.dispatch(target, KeyEvent("enter"))
    assertEvent(getterCalls == 1 && requests == 1 && requested, "one latest checked read, one true request")
    assertEvent(app.snapshot(3, 1).toPlainText() == "[ ]", "ignored request leaves business value false")
    checked.set(true)
    assertEvent(app.snapshot(3, 1).toPlainText() == "[x]", "application owns checked value")
    app.dispose()
}

func radioEvents(): Unit {
    let selected = Observable<Bool>(true)
    var requests = 0
    let radio = Radio({ => selected.get() }, { => requests++ })
    let app = Application(radio)
    app.startHeadless()
    let target = radio.reference().getOrThrow()
    app.dispatch(target, KeyEvent("enter"))
    assertEvent(requests == 0, "already selected Radio has no request")
    selected.set(false)
    app.snapshot(3, 1)
    app.dispatch(target, KeyEvent("enter"))
    assertEvent(requests == 1, "unselected Radio requests exactly once")
    app.dispose()
}
