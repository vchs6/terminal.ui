package runtime_contract

import cjtui.*

// R005/R012: cleanup is active application code even when dispose was invoked
// from an otherwise idle boundary. A must own TLS until every cleanup returns.
func cleanupCannotEnterAnotherSession(): Unit {
    let value = Observable<String>("B")
    let otherRoot = Text({ => value.get() })
    let other = Application(otherRoot)
    other.startHeadless()
    picture(other.snapshot(2, 1), "B ", "other session is initially usable")
    let otherRef = ref(otherRoot)
    let observed = Box<String>("accepted")
    let cleanups = Box<Int64>(0)
    let root = Column {
        Text("A").onMount({ _ => { =>
            cleanups.value++
            try { other.snapshot(2, 1) } catch (error: UIException) { observed.value = error.code }
        } })
    }.onMount({ _ => { => cleanups.value++ } })
    let app = Application(root)
    app.startHeadless()
    let old = ref(root)
    app.dispose()
    println("cleanup-context observed=${observed.value} cleanups=${cleanups.value} A-valid=${old.isValid()} B-valid=${otherRef.isValid()}")
    check(cleanups.value == 2 && !old.isValid(), "cross-session attempt does not abort complete A cleanup")
    emptyStats(app, "A cleanup releases every resource")
    check(otherRef.isValid(), "rejected callback entry preserves B session")
    value.set("C")
    picture(other.snapshot(2, 1), "C ", "B remains usable after A cleanup and TLS restoration")
    other.batch({ => value.set("D") })
    picture(other.snapshot(2, 1), "D ", "next B active boundary has restored ownership")
    other.dispose()
    check(observed.value == "WrongUIContext", "cleanup cannot synchronously enter a different idle session")
}

// R004/R012: owner render is a runtime failure boundary, including the same
// teardown/primary-error rules as snapshot. Detached export is tested elsewhere.
func ownerRenderFailureDisposes(extraCleanupFailure: Bool): Unit {
    let fail = Observable<Bool>(false)
    let getterFailure = MarkedFailure("OWNER_GETTER_SENTINEL")
    let cleanupFailure = MarkedFailure("OWNER_CLEANUP_SENTINEL")
    let cleanups = Box<Int64>(0)
    let root = Text({ =>
        if (fail.get()) { throw getterFailure }
        "ok"
    }).onMount({ _ => { =>
        cleanups.value++
        if (extraCleanupFailure) { throw cleanupFailure }
    } })
    let app = Application(root)
    app.startHeadless()
    picture(app.snapshot(3, 1), "ok ", "owner render starts with a mounted getter")
    let old = ref(root)
    check(app.post(old, { => }), "owner work accepted before render failure")
    fail.set(true)
    let caught = Box<?Exception>(Option<Exception>.None)
    try { render(root, 3, 1) } catch (error: Exception) { caught.value = Some(error) }
    let error = caught.value.getOrThrow()
    let stats = app.stats()
    println("owner-render aggregate=${extraCleanupFailure} error=${error.message} valid=${old.isValid()} cleanup=${cleanups.value} mounted=${stats.mountedNodes} bindings=${stats.activeBindings} subscriptions=${stats.subscriptions} posts=${stats.pendingPosts}")
    check(!old.isValid() && cleanups.value == 1, "owner render getter failure disposes generation and cleanup")
    emptyStats(app, "owner render failure releases nodes, bindings, subscriptions and posts")
    if (extraCleanupFailure) {
        let aggregate = (error as UICleanupException).getOrThrow()
        let primary = (aggregate.primary as MarkedFailure).getOrThrow()
        primary.marker = 51
        check(getterFailure.marker == 51 && aggregate.cleanupFailures.size == 1,
            "owner render aggregation preserves original getter primary")
        let additional = (aggregate.cleanupFailures[0] as MarkedFailure).getOrThrow()
        additional.marker = 52
        check(cleanupFailure.marker == 52 && aggregate.message.contains("OWNER_GETTER_SENTINEL") &&
            aggregate.message.contains("OWNER_CLEANUP_SENTINEL"), "owner render reports original cleanup failure")
    } else {
        let original = (error as MarkedFailure).getOrThrow()
        original.marker = 53
        check(getterFailure.marker == 53, "owner render without cleanup failure preserves original exception object/type")
    }
    app.dispose()
    check(cleanups.value == 1, "owner render failure cleanup is not replayed by dispose")
}

func cleanupBoundaryCode(action: () -> Unit): String {
    var result = "accepted"
    try { action() } catch (error: UIException) { result = error.code }
    result
}

// R018: closing-session callbacks still own an active lifecycle boundary even
// after references and queue tokens have been revoked. Reentry wins over stale
// target/session-inactive checks; post remains a non-throwing false rejection.
func cleanupSameSessionReentry(): Unit {
    let holder = Box<?Application>(Option<Application>.None)
    let target = Box<?NodeRef>(Option<NodeRef>.None)
    let snapshotCode = Box<String>("not called")
    let dispatchCode = Box<String>("not called")
    let disposeCode = Box<String>("not called")
    let postAccepted = Box<Bool>(true)
    let postedRuns = Box<Int64>(0)
    let cleanups = Box<Int64>(0)
    let probeEnabled = Box<Bool>(true)
    let other = Application(Text("B"))
    other.startHeadless()
    let root = Column {
        Text("A").onMount({ owner =>
            target.value = Some(owner)
            { =>
                cleanups.value++
                if (probeEnabled.value) {
                    let session = holder.value.getOrThrow()
                    snapshotCode.value = cleanupBoundaryCode({ => session.snapshot(2, 1); () })
                    dispatchCode.value = cleanupBoundaryCode({ => session.dispatch(target.value.getOrThrow(), KeyEvent("text")) })
                    disposeCode.value = cleanupBoundaryCode({ => session.dispose() })
                    postAccepted.value = session.post({ => postedRuns.value++ })
                }
            }
        })
    }.onMount({ _ => { => cleanups.value++ } })
    let app = Application(root)
    holder.value = Some(app)
    app.startHeadless()
    let old = ref(root)
    app.dispose()
    println("cleanup-same snapshot=${snapshotCode.value} dispatch=${dispatchCode.value} dispose=${disposeCode.value} post=${postAccepted.value} posted-runs=${postedRuns.value} cleanups=${cleanups.value} valid=${old.isValid()}")
    check(cleanups.value == 2 && !old.isValid(), "same-session reentry attempts do not interrupt remaining cleanup")
    emptyStats(app, "same-session cleanup boundary releases all current resources")
    check(!postAccepted.value && postedRuns.value == 0, "post during entire-session cleanup returns false and does not execute")
    picture(other.snapshot(2, 1), "B ", "cleanup restores TLS for a later unrelated legal boundary")
    probeEnabled.value = false
    app.startHeadless()
    picture(app.snapshot(2, 1), "A ", "cleaned application can establish a later session after lifecycle boundary")
    app.dispose()
    other.dispose()
    check(postedRuns.value == 0 && cleanups.value == 4, "rejected cleanup post cannot leak into remount")
    check(snapshotCode.value == "LifecycleReentry", "snapshot in same-session cleanup reports LifecycleReentry before inactive checks")
    check(dispatchCode.value == "LifecycleReentry", "dispatch in cleanup reports LifecycleReentry before revoked target checks")
    check(disposeCode.value == "LifecycleReentry", "dispose in cleanup reports LifecycleReentry instead of silently succeeding")
}
