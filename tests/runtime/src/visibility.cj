package runtime_contract

import cjtui.*

func retainedVisibility(): Unit {
    let shown = Observable<Bool>(true)
    let value = Observable<String>("A")
    let mounted = Box<Int64>(0)
    let cleaned = Box<Int64>(0)
    let leaf = Box<?Component>(Option<Component>.None)
    let root = Column {
        leaf.value = Some(Text({ => value.get() }).visible({ => shown.get() })
            .onMount({ _ => mounted.value++; { => cleaned.value++ } }))
        Text("tail")
    }
    let app = Application(root)
    app.startHeadless()
    let original = ref(leaf.value.getOrThrow())
    picture(app.snapshot(4, 2), "A   \ntail", "visible child participates in Column layout")
    let counts = app.stats()
    shown.set(false)
    picture(app.snapshot(4, 2), "tail\n    ", "hidden child occupies no layout space")
    value.set("B")
    app.snapshot(4, 2)
    check(original.isValid() && mounted.value == 1 && cleaned.value == 0 &&
        app.stats().mountedNodes == counts.mountedNodes && app.stats().subscriptions == counts.subscriptions,
        "hidden child keeps mount, state, and subscriptions")
    shown.set(true)
    picture(app.snapshot(4, 2), "B   \ntail", "revealed child displays latest hidden update")
    check(original.sameNode(ref(leaf.value.getOrThrow())), "visibility does not change generation")
    app.dispose()
    check(cleaned.value == 1, "retained hidden lifecycle cleans only on disposal")
}
