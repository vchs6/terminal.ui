package runtime_contract

import cjtui.*

func failureCleanup(): Unit {
    let trace = Box<String>("")
    let first = Box<?NodeRef>(Option<NodeRef>.None)
    let second = Box<?NodeRef>(Option<NodeRef>.None)
    let application = Box<?Application>(Option<Application>.None)
    let root = Column {
        Text("one").onMount({ owner =>
            first.value = Some(owner)
            { =>
                check(!first.value.getOrThrow().isValid() && !second.value.getOrThrow().isValid(), "all tokens invalid before first cleanup")
                check(application.value.getOrThrow().stats().subscriptions == 0 &&
                    application.value.getOrThrow().stats().pendingPosts == 0, "subscriptions and queue removed before cleanup")
                trace.value += "1"
                throw Exception("CLEANUP_ONE")
            }
        })
        Text("two").onMount({ owner => second.value = Some(owner); { => trace.value += "2"; throw Exception("CLEANUP_TWO") } })
    }.onMount({ _ => { => trace.value += "P" } })
    application.value = Some(Application(root))
    let app = application.value.getOrThrow()
    app.startHeadless()
    check(app.post(first.value.getOrThrow(), { => trace.value += "BAD" }), "owner work queued before cleanup")
    var failure = ""
    try { app.dispose() } catch (error: Exception) { failure = error.message }
    check(trace.value == "12P" || trace.value == "21P", "cleanup attempts every child before parent despite errors")
    check(failure.contains(if (trace.value == "12P") { "CLEANUP_ONE" } else { "CLEANUP_TWO" }),
        "cleanup retains first actual failure")
    emptyStats(app, "throwing cleanup still releases everything")
    let completedTrace = trace.value
    app.dispose()
    check(trace.value == completedTrace, "failed cleanup is never called twice")
    let completed = Box<Int64>(0)
    let failedMount = Application(Column {
        Text("ok").onMount({ _ => { => completed.value++ } })
        Text("fail").onMount({ _ => throw Exception("MOUNT_SENTINEL") })
    })
    failsWith("MOUNT_SENTINEL", { => failedMount.startHeadless() }, "mount effect failure reaches consumer")
    check(completed.value == 1, "mount failure cleans already registered effects")
    emptyStats(failedMount, "mount failure releases all resources")
}
