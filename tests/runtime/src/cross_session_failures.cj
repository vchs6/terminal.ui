package runtime_contract

import cjtui.*

// A callback/getter's uncaught WrongUIContext belongs to owner A's failure
// boundary. The B operation must reject before changing B; the same exception
// must then tear down A, independently of its error-code spelling.
func crossSessionOwnerFailure(kind: String, cleanupThrows: Bool): Unit {
    let bValue = Observable<String>("B")
    let bRoot = Text({ => bValue.get() })
    let b = Application(bRoot)
    b.startHeadless()
    picture(b.snapshot(3, 1), "B  ", "unrelated B starts normally")
    let bRef = ref(bRoot)
    let bStats = b.stats()
    let original = Box<?UIException>(Option<UIException>.None)
    let trigger = Box<Bool>(false)
    let aValue = Observable<String>("A")
    let cleanupFailure = MarkedFailure("CROSS_SESSION_CLEANUP")
    let cleanups = Box<Int64>(0)
    let queuedRuns = Box<Int64>(0)
    let aRoot = Text({ =>
        let current = aValue.get()
        if (kind == "getter" && trigger.value) {
            try { b.snapshot(3, 1); () }
            catch (error: UIException) { original.value = Some(error); throw error }
        }
        current
    }).onMount({ _ => { =>
        cleanups.value++
        if (cleanupThrows) { throw cleanupFailure }
    } })
    let a = Application(aRoot)
    a.startHeadless()
    picture(a.snapshot(3, 1), "A  ", "owner A starts with an active Observable binding")
    let aRef = ref(aRoot)
    if (kind == "post") {
        check(a.post({ =>
            try { b.snapshot(3, 1); () }
            catch (error: UIException) { original.value = Some(error); throw error }
        }), "cross-session post is accepted before its callback runs")
        check(a.post(aRef, { => queuedRuns.value++ }), "later owner work is queued before callback failure")
    } else {
        trigger.value = true
        aRef.notify(ChangeKind.Content)
    }
    let caught = Box<?Exception>(Option<Exception>.None)
    try { a.snapshot(3, 1); () } catch (error: Exception) { caught.value = Some(error) }
    let failure = caught.value.getOrThrow()
    let witness = original.value.getOrThrow()
    check(witness.code == "WrongUIContext", "B rejects the callback/getter's cross-session entry")
    check(bRef.isValid() && b.stats().mountedNodes == bStats.mountedNodes &&
        b.stats().subscriptions == bStats.subscriptions, "B precondition rejection does not dispose its resources")
    bValue.set("B2")
    picture(b.snapshot(3, 1), "B2 ", "unrelated B remains usable after A's failed callback/getter")
    let stats = a.stats()
    println("cross-owner kind=${kind} extra=${cleanupThrows} error=${failure.message} A-valid=${aRef.isValid()} cleanup=${cleanups.value} mounted=${stats.mountedNodes} bindings=${stats.activeBindings} subscriptions=${stats.subscriptions} posts=${stats.pendingPosts} queued-runs=${queuedRuns.value} B-valid=${bRef.isValid()}")
    check(!aRef.isValid() && cleanups.value == 1, "uncaught WrongUIContext from owner callback/getter disposes A")
    emptyStats(a, "owner failure releases A nodes, bindings, subscriptions and queued work")
    check(queuedRuns.value == 0 && !a.post({ => queuedRuns.value++ }), "owner failure cancels later work and rejects new posts")
    if (cleanupThrows) {
        let aggregate = (failure as UICleanupException).getOrThrow()
        check(refEq(aggregate.primary, witness) &&
            (aggregate.primary as UIException).getOrThrow().code == "WrongUIContext",
            "cleanup aggregate preserves the exact original WrongUIContext object and type")
        check(aggregate.cleanupFailures.size == 1 && refEq(aggregate.cleanupFailures[0], cleanupFailure) &&
            aggregate.message.contains(witness.message) && aggregate.message.contains(cleanupFailure.message),
            "owner callback failure returns its additional cleanup failure")
    } else {
        check(refEq(failure, witness) && (failure as UIException).getOrThrow().code == "WrongUIContext",
            "without cleanup errors the original WrongUIContext object and type are thrown")
    }
    a.dispose()
    check(cleanups.value == 1, "owner failure cleanup is not replayed")
    b.dispose()
}
