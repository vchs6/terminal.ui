package widgets_small_contract

import cjtui.{Application, Button, Checkbox, Column, KeyEvent, Observable, Radio, UIException}

func assertEvent(value: Bool, caseName: String): Unit {
    if (!value) {
        throw IllegalStateException(caseName)
    }
}

func eventCases(): Unit {
    buttonEvents()
    checkboxEvents()
    radioEvents()
    eventBoundaryCases()
    duplicateRadioLabels()
    allControlKeyExclusions()
}

func buttonEvents(): Unit {
    let clicks = [0]
    let button = Button("Go", {=> clicks[0]++})
    let app = Application(button)
    app.startHeadless()
    let target = button.reference().getOrThrow()
    app.dispatch(target, KeyEvent("enter"))
    app.dispatch(target, KeyEvent("text", text: " "))
    assertEvent(clicks[0] == 2, "Enter and single ASCII Space each click once")
    app.dispatch(target, KeyEvent("text", text: "  "))
    app.dispatch(target, KeyEvent("paste", text: " "))
    for (key in [KeyEvent("enter", ctrl: true), KeyEvent("enter", alt: true), KeyEvent("enter", shift: true),
        KeyEvent("text", text: " ", ctrl: true), KeyEvent("text", text: " ", alt: true),
        KeyEvent("text", text: " ", shift: true), KeyEvent("text", text: " ", ctrl: true, alt: true, shift: true)]) {
        app.dispatch(target, key)
    }
    assertEvent(clicks[0] == 2, "multi-space, paste and Alt+Space excluded")
    app.dispose()

    let prevented = [0]
    let blocked = Button("Go", {=> prevented[0]++}).onKeyCapture({event => event.preventDefault()})
    let second = Application(blocked)
    second.startHeadless()
    second.dispatch(blocked.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(prevented[0] == 0, "capture preventDefault suppresses default action")
    second.dispose()

    let stopped = [0]
    let stopOnly = Button("Go", {=> stopped[0]++}).onKeyCapture({event => event.stopPropagation()})
    let third = Application(stopOnly)
    third.startHeadless()
    third.dispatch(stopOnly.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(stopped[0] == 1, "stopPropagation alone preserves target default")
    third.dispose()

    let bubbleCalls = [0]
    let parent = Column {Button("Go", {=> bubbleCalls[0]++})}.onKey({event => event.preventDefault()})
    let fourth = Application(parent)
    fourth.startHeadless()
    fourth.dispatch(parent.reference().getOrThrow().children()[0], KeyEvent("enter"))
    assertEvent(bubbleCalls[0] == 0, "bubble preventDefault suppresses default action")
    fourth.dispose()

    let appCalls = [0]
    let appBlocked = Button("Go", {=> appCalls[0]++})
    let fifth = Application(appBlocked).onKeyEvent({event => event.preventDefault()})
    fifth.startHeadless()
    fifth.dispatch(appBlocked.reference().getOrThrow(), KeyEvent("enter"))
    assertEvent(appCalls[0] == 0, "app preventDefault suppresses default action")
    fifth.dispose()

    let unfocusedCalls = [0]
    let pair = Column {
        Button("first", {=> ()});
    Button("second", {=> unfocusedCalls[0]++})
    }
    let sixth = Application(pair)
    sixth.startHeadless()
    let children = pair.reference().getOrThrow().children()
    assertEvent(sixth.focusedNode().getOrThrow().sameNode(children[0]), "first button receives initial focus")
    sixth.dispatch(children[1], KeyEvent("enter"))
    assertEvent(unfocusedCalls[0] == 0, "legal unfocused target does not activate")
    sixth.dispose()

    let disabledCalls = [0]
    let disabled = Column {Button("child", {=> disabledCalls[0]++})}.enabled(false)
    let seventh = Application(disabled)
    seventh.startHeadless()
    var rejected = false
    try {
        seventh.dispatch(disabled.reference().getOrThrow().children()[0], KeyEvent("enter"))
    } catch (_: UIException) {
        rejected = true
    }
    assertEvent(rejected && disabledCalls[0] == 0, "disabled ancestor blocks dispatch")
    seventh.dispose()
}

func checkboxEvents(): Unit {
    let checked = Observable<Bool>(false)
    let getterCalls = [0]
    let requests = [0]
    let requested = [false]
    let box = Checkbox(
        {
            =>
            getterCalls[0]++;
            checked.get()
        },
        {
            value =>
            requests[0]++;
            requested[0] = value
        }
    )
    let app = Application(box)
    app.startHeadless()
    let target = box.reference().getOrThrow()
    getterCalls[0] = 0
    app.dispatch(target, KeyEvent("enter"))
    assertEvent(getterCalls[0] == 1 && requests[0] == 1 && requested[0], "one latest checked read, one true request")
    assertEvent(app.snapshot(3, 1).toPlainText() == "[ ]", "ignored request leaves business value false")
    checked.set(true)
    assertEvent(app.snapshot(3, 1).toPlainText() == "[x]", "application owns checked value")
    app.dispose()
}

func radioEvents(): Unit {
    let selected = Observable<Bool>(true)
    let requests = [0]
    let radio = Radio({=> selected.get()}, {=> requests[0]++})
    let app = Application(radio)
    app.startHeadless()
    let target = radio.reference().getOrThrow()
    app.dispatch(target, KeyEvent("enter"))
    app.dispatch(target, KeyEvent("text", text: " "))
    assertEvent(requests[0] == 0, "already selected Radio has no request for Enter or Space")
    selected.set(false)
    app.snapshot(3, 1)
    app.dispatch(target, KeyEvent("enter"))
    assertEvent(requests[0] == 1, "unselected Radio requests[0] exactly once")
    app.dispose()
}
