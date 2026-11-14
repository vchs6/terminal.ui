package session_lifecycle

import cjtui.*

// Fail before the first device transaction, then restart the same Application.
// No private runtime entry or manual flush is used.
func initialLifecycle(scenario: String): Unit {
    let armed = Observable<Bool>(true)
    let registrations = Box<Int64>(0)
    let cleanups = Box<Int64>(0)
    let saved = Box<?NodeRef>(Option<NodeRef>.None)
    let root = Column {
        Text({ =>
            if (armed.get() && scenario == "initial-getter") { throw Exception("L020_INITIAL_GETTER") }
            "INITIAL"
        }).onMount({ ref =>
            registrations.value++; saved.value = Some(ref)
            { => cleanups.value++; check(!ref.isValid(), "initial child token revoked") }
        })
        Canvas({ _ =>
            if (armed.get() && scenario == "initial-measure") { throw Exception("L020_INITIAL_MEASURE") }
            Size(1,1)
        }, { p =>
            if (armed.get() && scenario == "initial-draw") { throw Exception("L020_INITIAL_DRAW") }
            p.put(0,0,"C")
        })
    }.onMount({ _ =>
        if (armed.get() && scenario == "initial-mount") { throw Exception("L020_INITIAL_MOUNT") }
        registrations.value++
        { => cleanups.value++ }
    })
    let app = Application(root)
    app.onKeyEvent({ event =>
        if (event.key.text == "r") { record("probe-2", app.terminalCapabilities().getOrThrow().cursorVisibilityStatus) }
        if (event.key.text == "q") { app.stop() }
    })
    var first: ?Exception = None
    try { app.run() } catch (error: Exception) { first = Some(error); record("error-1", error.message) }
    check(first.isSome(), "initial failure propagates")
    empty(app)
    check(cleanups.value == registrations.value, "every registered initial cleanup ran once")
    if (let Some(ref) <- saved.value) { check(!ref.isValid(), "initial saved ref invalid") }
    record("closed-1", "0/0/0/0")
    armed.set(false)
    app.run(); empty(app)
    check(cleanups.value == registrations.value, "restart every registered cleanup once")
    record("closed-2", "0/0/0/0")
    app.dispose()
}
