package widgets_small_contract

import cjtui.{Application, Button, KeyEvent, Label, Observable}

func assertLifetime(value: Bool, caseName: String): Unit {
    if (!value) {
        throw IllegalStateException(caseName)
    }
}

func lifecycleCases(): Unit {
    remountAndWorkerPosts()
    let cleanups = [0]
    let failing = Button("raise", {=> throw Exception("WIDGET_CALLBACK_SENTINEL")}).onMount({_ => {=> cleanups[0]++}})
    let app = Application(failing)
    app.startHeadless()
    let stale = failing.reference().getOrThrow()
    var caught = false
    try {
        app.dispatch(stale, KeyEvent("enter"))
    } catch (error: Exception) {
        caught = error.message.contains("WIDGET_CALLBACK_SENTINEL")
    }
    assertLifetime(caught, "callback first error survives cleanup")
    assertLifetime(cleanups[0] == 1 && !stale.isValid(), "failed session cleans once and invalidates old ref")

    let model = Observable<String>("A")
    let first = Application(Label({=> model.get()}))
    let second = Application(Label({=> model.get()}))
    first.startHeadless();
    second.startHeadless()
    assertLifetime(first.snapshot(2, 1).toPlainText() == "A " && second.snapshot(2, 1).toPlainText() == "A ",
        "two views share business model")
    model.set("B")
    assertLifetime(first.snapshot(2, 1).toPlainText() == "B " && second.snapshot(2, 1).toPlainText() == "B ",
        "both views observe latest model")
    first.dispose();
    second.dispose()
    assertLifetime(model.get() == "B", "business model survives view disposal")

    let latest = Observable<String>("ok")
    let getter = Application(
        Label(
            {
                =>
                    if (latest.get() == "bad") {
                        throw Exception("WIDGET_GETTER_SENTINEL")
                    }
                    latest.get()
            }
        )
    )
    getter.startHeadless()
    latest.set("bad")
    caught = false
    try {
        getter.snapshot(3, 1)
    } catch (error: Exception) {
        caught = error.message.contains("WIDGET_GETTER_SENTINEL")
    }
    assertLifetime(caught && latest.get() == "bad", "getter failure preserves error and business state")
}
