package dynamic_contract

import cjtui.*
import std.collection.*

func ownerPostCancelledOnDynamicUnmount(): Unit {
    let f = SlotFixture()
    let a = ref(f.rows[0])
    let rr = ref(f.root)
    let ownerRuns = MutableBox<Int64>(0)
    let sessionRuns = MutableBox<Int64>(0)
    f.app.onKeyEvent({ _ =>
        check(f.app.post(a, { => ownerRuns.value++ }), "owner post accepted while mounted")
        check(f.app.post({ => sessionRuns.value++ }), "session post accepted")
        f.items.set(["B", "C"])
    })
    f.app.dispatch(rr, KeyEvent("test"))
    check(!a.isValid(), "dispatch boundary unmounts removed key")
    check(!f.app.post(a, { => ownerRuns.value++ }), "stale owner post rejected")
    picture(f.app, 1, 4, "B\nC\n \n ", "owner cancellation with remaining list")
    check(ownerRuns.value == 0 && sessionRuns.value == 1, "owner work cancelled, independent session work runs")
    check(f.app.stats().pendingPosts == 0, "cancelled owner does not retain queue entry")
    f.app.dispose()
}

func failedBodyReleasesAndRestoresCollector(): Unit {
    let data = Observable<Array<String>>(["A"])
    let log = FixtureLog()
    let root = Column({ =>
        ForEach<String>({ => data.get() }, { value => value }, { item =>
            if (item.key == "C") { throw FixtureFailure("body-C") }
            Text(item.value).onMount({ _ => log.mounts.add(item.key); { => log.cleanups.add(item.key) } })
        })
    })
    let app = Application(root)
    app.startHeadless()
    let rr = ref(root)
    let a = rr.children()[0]
    data.set(["A", "B", "C"])
    var caught = false
    try { app.snapshot(1, 4) } catch (_: FixtureFailure) { caught = true }
    check(caught, "body failure retains original user exception type")
    check(log.mounts.size == 1 && log.trace() == "A,", "failed group does not half mount B; old A cleans once")
    dead(app, [rr, a], "body failure cleanup")
    app.dispose()
    let fresh = Column({ => Text("Z") })
    let next = Application(fresh)
    next.startHeadless()
    picture(next, 1, 2, "Z\n ", "collector restored after dynamic body failure")
    check(ref(fresh).children().size == 1, "failed collector does not leak children")
    next.dispose()
}

func cleanupContinuesAfterFailure(): Unit {
    let data = Observable<Array<String>>(["A", "B"])
    let log = FixtureLog()
    let root = Column({ =>
        ForEach<String>({ => data.get() }, { value => value }, { item =>
            Column({ => Text(item.value).onMount({ _ => { => log.cleanups.add("child" + item.key) } }) })
                .onMount({ _ => { =>
                    log.cleanups.add("parent" + item.key)
                    if (item.key == "A") { throw FixtureFailure("cleanup-A") }
                } })
        })
    }).onMount({ _ => { => log.cleanups.add("root") } })
    let app = Application(root)
    app.startHeadless()
    let rr = ref(root)
    let children = rr.children()
    data.set([])
    var caught = false
    try { app.snapshot(1, 3) } catch (_: FixtureFailure) { caught = true }
    check(caught, "cleanup failure is reported")
    check(log.cleanups.size == 5, "all child, item, and root cleanups attempted")
    var childA: Int64 = -1
    var parentA: Int64 = -1
    var childB: Int64 = -1
    var parentB: Int64 = -1
    var rootIndex: Int64 = -1
    for (i in 0..log.cleanups.size) {
        match (log.cleanups[i]) {
            case "childA" => childA = i
            case "parentA" => parentA = i
            case "childB" => childB = i
            case "parentB" => parentB = i
            case "root" => rootIndex = i
            case _ => throw Exception("unexpected cleanup entry")
        }
    }
    check(childA >= 0 && childA < parentA && childB >= 0 && childB < parentB &&
        rootIndex > parentA && rootIndex > parentB, "cleanup children before their parents")
    dead(app, [rr, children[0], children[1]], "cleanup exception release")
    app.dispose()
    check(log.cleanups.size == 5, "cleanup exceptions never cause double cleanup")
}

func lifecycleStructureReentry(): Unit {
    for (duringMount in [true, false]) {
        let currentRoot = MutableBox<?Component>(Option<Component>.None)
        let mountedRoot = MutableBox<?NodeRef>(Option<NodeRef>.None)
        let show = Observable<Bool>(true)
        let root = Column({ =>
            If({ => show.get() }, { =>
                Text("A").onMount({ _ =>
                    if (duringMount) { ref(currentRoot.value.getOrThrow()).append(Text("X")) }
                    { =>
                        if (!duringMount) { mountedRoot.value.getOrThrow().append(Text("X")) }
                    }
                })
            })
        })
        currentRoot.value = Some(root)
        let app = Application(root)
        if (duringMount) {
            expectUI("LifecycleReentry", { => app.startHeadless() })
        } else {
            app.startHeadless()
            mountedRoot.value = Some(ref(root))
            show.set(false)
            expectUI("LifecycleReentry", { => app.snapshot(1, 3) })
        }
        dead(app, [], "lifecycle direct structure rejected")
        app.dispose()
    }
}

func evaluationStructureReentry(): Unit {
    for (fromKey in [true, false]) {
        let armed = Observable<Bool>(false)
        let current = MutableBox<?NodeRef>(Option<NodeRef>.None)
        let root = Column({ =>
            ForEach<String>({ =>
                if (!fromKey && armed.get()) { current.value.getOrThrow().append(Text("X")) }
                ["A"]
            }, { value =>
                if (fromKey && armed.get()) { current.value.getOrThrow().append(Text("X")) }
                value
            }, { item => Text(item.value) })
        })
        let app = Application(root)
        app.startHeadless()
        let rr = ref(root)
        current.value = Some(rr)
        armed.set(true)
        rr.notify(ChangeKind.Structure)
        expectUI("ReentrantStructure", { => app.snapshot(1, 3) })
        dead(app, [rr], "structure/key getter reentry")
        app.dispose()
    }
}

func bodyStructureReentry(): Unit {
    let data = Observable<Array<String>>(["A"])
    let current = MutableBox<?NodeRef>(Option<NodeRef>.None)
    let root = Column({ =>
        ForEach<String>({ => data.get() }, { value => value }, { item =>
            if (item.key == "B") { current.value.getOrThrow().append(Text("X")) }
            Text(item.value)
        })
    })
    let app = Application(root)
    app.startHeadless()
    let rr = ref(root)
    current.value = Some(rr)
    data.set(["A", "B"])
    expectUI("ReentrantStructure", { => app.snapshot(1, 3) })
    dead(app, [rr], "new-key body collector cannot mutate mounted tree")
    app.dispose()
}

func lifecycleCanPostNextTurn(): Unit {
    let show = Observable<Bool>(true)
    let currentApp = MutableBox<?Application>(Option<Application>.None)
    let parent = MutableBox<?NodeRef>(Option<NodeRef>.None)
    let accepted = MutableBox<Bool>(false)
    let x = Text("X")
    let root = Column({ =>
        If({ => show.get() }, { =>
            Text("A").onMount({ _ => { =>
                accepted.value = currentApp.value.getOrThrow().post(parent.value.getOrThrow(), { => parent.value.getOrThrow().append(x) })
            } })
        })
    })
    let app = Application(root)
    currentApp.value = Some(app)
    app.startHeadless()
    parent.value = Some(ref(root))
    show.set(false)
    picture(app, 1, 3, " \n \n ", "cleanup post is deferred beyond current turn")
    check(accepted.value && x.reference().isNone(), "cleanup can post without immediate structural recursion")
    picture(app, 1, 3, "X\n \n ", "next turn commits cleanup-posted child")
    sequence(ref(root), [ref(x)], "posted child shares same physical sequence")
    app.dispose()
}

func dynamicMountFailureCleansSession(): Unit {
    let data = Observable<Array<String>>(["A"])
    let log = FixtureLog()
    let root = Column({ =>
        ForEach<String>({ => data.get() }, { value => value }, { item =>
            Text(item.value).onMount({ _ =>
                log.mounts.add(item.key)
                if (item.key == "B") { throw FixtureFailure("mount-B") }
                { => log.cleanups.add(item.key) }
            })
        })
    })
    let app = Application(root)
    app.startHeadless()
    let rr = ref(root)
    let a = rr.children()[0]
    data.set(["A", "B", "C"])
    var caught = false
    try { app.snapshot(1, 4) } catch (_: FixtureFailure) { caught = true }
    check(caught, "dynamic onMount failure preserves original exception")
    check(log.trace() == "A,", "only registered cleanup runs after onMount throws")
    dead(app, [rr, a], "dynamic onMount failure cleanup")
    app.dispose()
    check(log.trace() == "A,", "failed dynamic mount cleanup once")
}

func recursiveStructureBoundaries(): Unit {
    for (entry in ["snapshot", "dispatch"]) {
        for (context in ["condition", "items", "key", "body"]) {
            let armed = Observable<Bool>(false)
            let data = Observable<Array<String>>(["A"])
            let session = MutableBox<?Application>(Option<Application>.None)
            let target = MutableBox<?NodeRef>(Option<NodeRef>.None)
            let reenter: () -> Unit = { =>
                if (entry == "snapshot") {
                    session.value.getOrThrow().snapshot(1, 4)
                } else {
                    session.value.getOrThrow().dispatch(target.value.getOrThrow(), KeyEvent("test"))
                }
            }
            let root = Column({ =>
                If({ =>
                    if (context == "condition" && armed.get()) { reenter() }
                    true
                }, { => Text("I") })
                ForEach<String>({ =>
                    if (context == "items" && armed.get()) { reenter() }
                    data.get()
                }, { value =>
                    if (context == "key" && armed.get()) { reenter() }
                    value
                }, { item =>
                    if (context == "body" && armed.get()) { reenter() }
                    Text(item.value)
                })
            })
            let app = Application(root)
            session.value = Some(app)
            app.startHeadless()
            let rr = ref(root)
            target.value = Some(rr)
            armed.set(true)
            data.set(["B"])
            expectUI("ReentrantStructure", { => app.snapshot(1, 4) })
            dead(app, [rr], "${entry} from ${context} must not recursively enter UI")
            app.dispose()
        }
    }
}

func observableWriteFromKeyRejected(): Unit {
    let armed = Observable<Bool>(false)
    let other = Observable<Int64>(0)
    let root = Column({ =>
        ForEach<String>({ => ["A"] }, { value =>
            if (armed.get()) { other.set(1) }
            value
        }, { item => Text(item.value) })
    })
    let app = Application(root)
    app.startHeadless()
    let rr = ref(root)
    armed.set(true)
    rr.notify(ChangeKind.Structure)
    expectUI("ReentrantEvaluation", { => app.snapshot(1, 3) })
    check(other.get() == 0, "rejected Observable write does not change value")
    dead(app, [rr], "Observable write uses evaluation error even inside key getter")
    app.dispose()
}

func synchronousStructuralLoopIsBounded(): Unit {
    let data = Observable<Array<String>>(["A"])
    let mounts = MutableBox<Int64>(0)
    let cleanups = MutableBox<Int64>(0)
    let root = Column({ =>
        ForEach<String>({ => data.get() }, { value => value }, { item =>
            Text(item.value).onMount({ _ =>
                mounts.value++
                data.set(if (item.key == "A") { ["B"] } else { ["A"] })
                { => cleanups.value++ }
            })
        })
    })
    let app = Application(root, limits: RuntimeLimits(stabilizationPasses: 3))
    expectUI("UnstableUpdate", { => app.startHeadless() })
    check(mounts.value > 1 && mounts.value == cleanups.value, "synchronous mounting loop bounded and all effects released")
    dead(app, [], "unstable structural loop cleanup")
    app.dispose()
}
