package dynamic_contract

import cjtui.*
import std.collection.ArrayList

// Observe cleanup without querying children after the session token is revoked.
func nestedCleanupTrace(trace: ArrayList<String>, name: String, parent: NodeRef): Unit {
    if (parent.isValid()) {
        trace.add("${name}:active-parent:children=${parent.children().size}")
    } else {
        trace.add("${name}:stopped")
    }
}

func nestedTrace(trace: ArrayList<String>): String {
    var result = ""
    for (entry in trace) { result += entry + "," }
    result
}

// Accumulate observations so an early lifecycle failure cannot hide release checks.
func nestedCheck(failures: ArrayList<String>, value: Bool, name: String): Unit {
    if (!value) { failures.add(name) }
}

func nestedReleased(failures: ArrayList<String>, app: Application, refs: Array<NodeRef>): Unit {
    for (node in refs) { nestedCheck(failures, !node.isValid(), "old reference invalidated") }
    let stats = app.stats()
    nestedCheck(failures, stats.mountedNodes == 0 && stats.activeBindings == 0 &&
        stats.subscriptions == 0 && stats.pendingPosts == 0, "session resources zero")
}

func finishNestedChecks(failures: ArrayList<String>, trace: ArrayList<String>): Unit {
    println("OBSERVED cleanup: ${nestedTrace(trace)}")
    for (failure in failures) { println("ASSERT FAIL: ${failure}") }
    println("OBSERVED failed assertions: ${failures.size}")
    check(failures.isEmpty(), "deep construction validation before structural commit")
}

func manualNestedDuplicateBeforeCommit(): Unit {
    let trace = ArrayList<String>()
    let failures = ArrayList<String>()
    let parent = MutableBox<?NodeRef>(Option<NodeRef>.None)
    let business = Observable<Int64>(0)
    let newMounts = MutableBox<Int64>(0)
    let innerBodies = MutableBox<Int64>(0)
    let root = Column({ =>
        Text("old").onMount({ _ => { =>
            nestedCleanupTrace(trace, "old", parent.value.getOrThrow())
        } })
    }).onMount({ _ => { => nestedCleanupTrace(trace, "root", parent.value.getOrThrow()) } })
    let app = Application(root)
    app.startHeadless()
    let rr = ref(root)
    parent.value = Some(rr)
    let old = rr.children()[0]
    let invalid = Column({ =>
        ForEach<String>({ => ["dup", "dup"] }, { value => value }, { item =>
            innerBodies.value++
            Text(item.value).onMount({ _ => newMounts.value++; { => } })
        })
    }).onMount({ _ => newMounts.value++; { => } })
    var errorCode = "none"
    try {
        app.batch({ =>
            business.set(7)
            rr.append(invalid)
            rr.remove(old)
        })
    } catch (error: UIException) { errorCode = error.code }
    nestedCheck(failures, errorCode == "DuplicateKey", "manual: DuplicateKey preserved")
    nestedCheck(failures, nestedTrace(trace) == "old:stopped,root:stopped,",
        "manual: old cleanup follows whole-session token revocation")
    nestedCheck(failures, newMounts.value == 0 && innerBodies.value == 0,
        "manual: invalid subtree has no mount or duplicate-key body effects")
    nestedCheck(failures, invalid.reference().isNone(), "manual: invalid description has no live reference")
    nestedCheck(failures, business.get() == 7, "manual: batch business side effect is not rolled back")
    nestedReleased(failures, app, [rr, old])
    app.dispose()
    nestedCheck(failures, trace.size == 2, "manual: dispose never repeats cleanup")
    nestedReleased(failures, app, [rr, old])
    finishNestedChecks(failures, trace)
}

func replacementNestedDuplicateBeforeCommit(): Unit {
    let trace = ArrayList<String>()
    let failures = ArrayList<String>()
    let parent = MutableBox<?NodeRef>(Option<NodeRef>.None)
    let data = Observable<Array<String>>(["old"])
    let newMounts = MutableBox<Int64>(0)
    let innerBodies = MutableBox<Int64>(0)
    let descriptions = ArrayList<Component>()
    let root = Column({ =>
        ForEach<String>({ => data.get() }, { value => value }, { item =>
            let row = Column({ =>
                if (item.key == "new") {
                    ForEach<String>({ => ["dup", "dup"] }, { value => value }, { inner =>
                        innerBodies.value++
                        Text(inner.value).onMount({ _ => newMounts.value++; { => } })
                    })
                } else {
                    Text("old").onMount({ _ => { =>
                        nestedCleanupTrace(trace, "old-text", parent.value.getOrThrow())
                    } })
                }
            }).onMount({ _ =>
                if (item.key == "new") { newMounts.value++ }
                { => nestedCleanupTrace(trace, item.key + "-row", parent.value.getOrThrow()) }
            })
            descriptions.add(row)
        })
    }).onMount({ _ => { => nestedCleanupTrace(trace, "root", parent.value.getOrThrow()) } })
    let app = Application(root)
    app.startHeadless()
    let rr = ref(root)
    parent.value = Some(rr)
    let old = rr.children()[0]
    let oldText = old.children()[0]
    data.set(["new"])
    var errorCode = "none"
    try { app.snapshot(10, 4) } catch (error: UIException) { errorCode = error.code }
    nestedCheck(failures, errorCode == "DuplicateKey", "replacement: DuplicateKey preserved")
    nestedCheck(failures, nestedTrace(trace) == "old-text:stopped,old-row:stopped,root:stopped,",
        "replacement: old subtree cleanup follows whole-session token revocation")
    nestedCheck(failures, newMounts.value == 0 && innerBodies.value == 0,
        "replacement: invalid subtree has no mount or duplicate-key body effects")
    for (i in 1..descriptions.size) {
        nestedCheck(failures, descriptions[i].reference().isNone(),
            "replacement: new description has no live reference")
    }
    let current = data.get()
    nestedCheck(failures, current.size == 1 && current[0] == "new",
        "replacement: business data is not rolled back")
    nestedReleased(failures, app, [rr, old, oldText])
    app.dispose()
    nestedCheck(failures, trace.size == 3, "replacement: dispose never repeats cleanup")
    nestedReleased(failures, app, [rr, old, oldText])
    finishNestedChecks(failures, trace)
}

// Both independent reproductions must run even when the first one is RED.
func runNestedCase(name: String, test: () -> Unit): Bool {
    try {
        runCase(name, test)
        true
    } catch (error: Exception) {
        println("FAIL: ${name}: ${error.message}")
        false
    }
}
