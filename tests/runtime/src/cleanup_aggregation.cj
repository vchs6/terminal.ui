package runtime_contract

import cjtui.*

// R017 catches a wrapper losing the primary object/type, retaining mutable
// array aliases, dropping secondary messages/counts, or nesting old aggregates.
func cleanupExceptionPublicContract(): Unit {
    let primary = MarkedFailure("PRIMARY_ONLY")
    let alpha = MarkedFailure("EXTRA_ALPHA")
    let beta = MarkedFailure("EXTRA_BETA")
    let replacement = MarkedFailure("REPLACEMENT")
    let provided: Array<Exception> = [alpha, beta]
    let aggregate = UICleanupException(primary, provided)
    let original = (aggregate.primary as MarkedFailure).getOrThrow()
    original.marker = 11
    check(primary.marker == 11 && original.tag == "PRIMARY_ONLY", "cleanup primary preserves original object and subtype")
    provided[0] = replacement
    check((aggregate.cleanupFailures[0] as MarkedFailure).getOrThrow().tag == "EXTRA_ALPHA",
        "cleanup constructor copies its input array")
    let exposed = aggregate.cleanupFailures
    exposed[1] = replacement
    check(aggregate.cleanupFailures.size == 2 &&
        (aggregate.cleanupFailures[1] as MarkedFailure).getOrThrow().tag == "EXTRA_BETA",
        "cleanupFailures getter returns a fresh array")
    let originalAlpha = (aggregate.cleanupFailures[0] as MarkedFailure).getOrThrow()
    originalAlpha.marker = 12
    check(alpha.marker == 12, "defensive array copies retain original exception objects")
    aggregateMessages(aggregate, "PRIMARY_ONLY", "EXTRA_ALPHA", "EXTRA_BETA", "public aggregate")
    let empty = UICleanupException(primary, Array<Exception>())
    check(empty.cleanupFailures.size == 0 && empty.message.contains("PRIMARY_ONLY") && empty.message.contains("0"),
        "public constructor accepts an empty additional list and reports zero")
    let inner = UICleanupException(primary, [alpha])
    let outer = UICleanupException(inner, [beta])
    check((outer.primary as UICleanupException).isNone() && outer.cleanupFailures.size == 2,
        "nested aggregate flattens to innermost primary")
    check((outer.primary as MarkedFailure).getOrThrow().marker == 11 &&
        (outer.cleanupFailures[0] as MarkedFailure).getOrThrow().tag == "EXTRA_ALPHA" &&
        (outer.cleanupFailures[1] as MarkedFailure).getOrThrow().tag == "EXTRA_BETA",
        "flattening appends old then new failures in order")
    aggregateMessages(outer, "PRIMARY_ONLY", "EXTRA_ALPHA", "EXTRA_BETA", "flattened aggregate")
}

func aggregateMessages(error: UICleanupException, primary: String, first: String, second: String, name: String): Unit {
    let message = error.message
    check(message.contains(primary) && message.contains(first) && message.contains(second) && message.contains("2"),
        "${name}: message retains primary, every additional message and additional count")
    check(message.indexOf(first).getOrThrow() < message.indexOf(second).getOrThrow(),
        "${name}: message preserves additional failure order")
}

func runtimeCleanupAggregation(): Unit {
    let primary = MarkedFailure("MOUNT_PRIMARY")
    let leafFailure = MarkedFailure("LEAF_CLEANUP")
    let parentFailure = MarkedFailure("PARENT_CLEANUP")
    let order = Box<String>("")
    let app = Application(Column {
        Column {
            Text("registered").onMount({ _ => { => order.value += "L"; throw leafFailure } })
        }.onMount({ _ => { => order.value += "P"; throw parentFailure } })
        Text("failing").onMount({ _ => throw primary })
    })
    let caught = Box<?UICleanupException>(Option<UICleanupException>.None)
    try { app.startHeadless() } catch (error: UICleanupException) { caught.value = Some(error) }
    let aggregate = caught.value.getOrThrow()
    check(order.value == "LP" && aggregate.cleanupFailures.size == 2, "mount failure attempts child then parent cleanup and returns both extras")
    let originalPrimary = (aggregate.primary as MarkedFailure).getOrThrow()
    originalPrimary.marker = 21
    check(primary.marker == 21, "mount aggregation preserves original primary object")
    check((aggregate.cleanupFailures[0] as MarkedFailure).getOrThrow().tag == "LEAF_CLEANUP" &&
        (aggregate.cleanupFailures[1] as MarkedFailure).getOrThrow().tag == "PARENT_CLEANUP",
        "mount aggregate exposes exact cleanup order")
    aggregateMessages(aggregate, "MOUNT_PRIMARY", "LEAF_CLEANUP", "PARENT_CLEANUP", "mount aggregate")
    emptyStats(app, "aggregated mount failure releases resources")
    app.dispose()
    check(order.value == "LP", "aggregated failure never replays cleanup")
    cleanupOnlyAggregation()
    extendExistingAggregate()
    originalFailuresWithoutExtras()
}

func extendExistingAggregate(): Unit {
    let primary = MarkedFailure("EXISTING_PRIMARY")
    let alpha = MarkedFailure("OLD_CLEANUP")
    let beta = MarkedFailure("NEW_CLEANUP")
    let existing = UICleanupException(primary, [alpha])
    let root = Text("x").onKey({ _ => throw existing }).onMount({ _ => { => throw beta } })
    let app = Application(root)
    app.startHeadless()
    let caught = Box<?UICleanupException>(Option<UICleanupException>.None)
    try { app.dispatch(ref(root), KeyEvent("text", text: "e")) }
    catch (error: UICleanupException) { caught.value = Some(error) }
    let aggregate = caught.value.getOrThrow()
    let original = (aggregate.primary as MarkedFailure).getOrThrow()
    original.marker = 23
    check(primary.marker == 23 && aggregate.cleanupFailures.size == 2 &&
        (aggregate.cleanupFailures[0] as MarkedFailure).getOrThrow().tag == "OLD_CLEANUP" &&
        (aggregate.cleanupFailures[1] as MarkedFailure).getOrThrow().tag == "NEW_CLEANUP",
        "runtime extends existing aggregate without nesting or reordering")
    aggregateMessages(aggregate, "EXISTING_PRIMARY", "OLD_CLEANUP", "NEW_CLEANUP", "extended runtime aggregate")
    emptyStats(app, "extended aggregate still releases resources")
}

func cleanupOnlyAggregation(): Unit {
    let leafFailure = MarkedFailure("LEAF_FIRST")
    let parentFailure = MarkedFailure("PARENT_NEXT")
    let app = Application(Column {
        Text("leaf").onMount({ _ => { => throw leafFailure } })
    }.onMount({ _ => { => throw parentFailure } }))
    app.startHeadless()
    let caught = Box<?UICleanupException>(Option<UICleanupException>.None)
    try { app.dispose() } catch (error: UICleanupException) { caught.value = Some(error) }
    let aggregate = caught.value.getOrThrow()
    let originalLeaf = (aggregate.primary as MarkedFailure).getOrThrow()
    originalLeaf.marker = 22
    check(leafFailure.marker == 22 && aggregate.cleanupFailures.size == 1 &&
        (aggregate.cleanupFailures[0] as MarkedFailure).getOrThrow().tag == "PARENT_NEXT",
        "cleanup-only failure chooses first cleanup as primary and the remainder as extras")
    check(aggregate.message.contains("LEAF_FIRST") && aggregate.message.contains("PARENT_NEXT") && aggregate.message.contains("1"),
        "cleanup-only aggregate exposes both messages and one additional failure")
    emptyStats(app, "cleanup-only aggregate releases resources")
}

func originalFailuresWithoutExtras(): Unit {
    let callbackFailure = MarkedFailure("CALLBACK_ORIGINAL")
    let root = Text("x").onKey({ _ => throw callbackFailure })
    let app = Application(root)
    app.startHeadless()
    var callbackCaught = false
    try { app.dispatch(ref(root), KeyEvent("text", text: "e")) }
    catch (error: MarkedFailure) { callbackCaught = true; error.marker = 31 }
    check(callbackCaught && callbackFailure.marker == 31, "callback with no cleanup failure throws original object and type")
    emptyStats(app, "unwrapped callback failure still disposes")
    let onlyCleanup = MarkedFailure("CLEANUP_ORIGINAL")
    let cleanupApp = Application(Text("x").onMount({ _ => { => throw onlyCleanup } }))
    cleanupApp.startHeadless()
    var cleanupCaught = false
    try { cleanupApp.dispose() } catch (error: MarkedFailure) { cleanupCaught = true; error.marker = 32 }
    check(cleanupCaught && onlyCleanup.marker == 32, "one cleanup failure throws original object and type without empty wrapper")
    emptyStats(cleanupApp, "unwrapped cleanup failure releases resources")
}
