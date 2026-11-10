package dynamic_contract

import cjtui.*
import std.collection.*

func invalidKeysBeforeBodies(): Unit {
    for (empty in [false, true]) {
        let log = FixtureLog()
        let root = Column({ =>
            ForEach<String>({ => if (empty) { [""] } else { ["A", "A"] } }, { value => value }, { item =>
                log.bodies.add(item.key)
                Text(item.value)
            })
        })
        let app = Application(root)
        expectUI(if (empty) { "InvalidKey" } else { "DuplicateKey" }, { => app.startHeadless() })
        check(log.bodies.isEmpty(), "all keys validated before any body")
        dead(app, [], "invalid initial keys")
        app.dispose()
    }
}

func invalidUpdateHasNoPartialBodies(): Unit {
    let data = Observable<Array<String>>(["A"])
    let log = FixtureLog()
    let rows = ArrayList<Component>()
    let root = Column({ =>
        ForEach<String>({ => data.get() }, { value => value }, { item =>
            log.bodies.add(item.key)
            rows.add(Text(item.value).onMount({ _ =>
                log.mounts.add(item.key)
                { => log.cleanups.add(item.key) }
            }))
        })
    })
    let app = Application(root)
    app.startHeadless()
    let a = ref(rows[0])
    let rr = ref(root)
    data.set(["B", "B", "A"])
    expectUI("DuplicateKey", { => app.snapshot(1, 4) })
    check(log.bodies.size == 1 && log.mounts.size == 1, "duplicate update cannot partially construct B")
    check(log.trace() == "A,", "duplicate failure cleans existing mount once")
    dead(app, [a, rr], "invalid update terminates session")
    app.dispose()
    check(log.trace() == "A,", "dispose after failure does not repeat cleanup")
}

func dynamicRootCounts(): Unit {
    for (count in [0, 2]) {
        let root = Column({ =>
            ForEach<String>({ => ["A"] }, { value => value }, { _ =>
                for (_ in 0..count) { Text("A") }
            })
        })
        let app = Application(root)
        expectUI("ConstructionRootCount", { => app.startHeadless() })
        dead(app, [], "ForEach requires one root per key")
        app.dispose()
    }
    let root = Column({ => If({ => true }, { => Text("A"); Text("B") }) })
    let app = Application(root)
    expectUI("ConstructionRootCount", { => app.startHeadless() })
    dead(app, [], "If rejects multiple roots")
    app.dispose()
}

func staleAnchorAfterRemove(): Unit {
    let f = SlotFixture()
    let a = ref(f.rows[0])
    let rr = ref(f.root)
    let mounts = MutableBox<Int64>(0)
    let x = Text("X").onMount({ _ => mounts.value++; { => } })
    expectUI("StaleAnchor", { =>
        f.app.batch({ =>
            rr.remove(a)
            rr.insertBefore(a, x)
        })
    })
    check(mounts.value == 0 && x.reference().isNone(), "stale anchor does not degrade to append")
    dead(f.app, [rr, a], "stale anchor failure")
    f.app.dispose()
}

func crossParentAndForeignAnchor(): Unit {
    for (moving in [true, false]) {
        let left = Column({ => Text("L") })
        let right = Column({ => Text("R") })
        let root = Column({ => })
        let app = Application(root)
        app.startHeadless()
        app.batch({ => ref(root).append(left); ref(root).append(right) })
        let lr = ref(left)
        let rr = ref(right)
        let l = lr.children()[0]
        let r = rr.children()[0]
        let x = Text("X")
        if (moving) {
            expectUI("CrossParentMove", { => app.batch({ => rr.moveBefore(l, r) }) })
        } else {
            expectUI("StaleAnchor", { => app.batch({ => rr.insertBefore(l, x) }) })
        }
        check(x.reference().isNone(), "foreign anchor has no new mount")
        dead(app, [lr, rr, l, r], "cross parent failure")
        app.dispose()
    }
}

func duplicateInsertionAndCycles(): Unit {
    for (pending in [true, false]) {
        let f = SlotFixture()
        let rr = ref(f.root)
        let mounts = MutableBox<Int64>(0)
        let cleanups = MutableBox<Int64>(0)
        let x = Text("X").onMount({ _ => mounts.value++; { => cleanups.value++ } })
        if (!pending) { f.app.batch({ => rr.append(x) }) }
        expectUI("AlreadyMounted", { => f.app.batch({ => rr.append(x); rr.append(x) }) })
        check(mounts.value <= 1 && mounts.value == cleanups.value, "duplicate reservation never mounts same description twice")
        dead(f.app, [rr], "duplicate insert cleanup")
        f.app.dispose()
    }
    let child = Column({ => Text("A") })
    let root = Column({ => })
    let app = Application(root)
    app.startHeadless()
    app.batch({ => ref(root).append(child) })
    let rr = ref(root)
    let cr = ref(child)
    // Validation priority between already mounted and cycle is deliberately unspecified.
    expectSomeUI({ => app.batch({ => cr.append(root) }) })
    dead(app, [rr, cr], "ancestor cycle rejected")
    app.dispose()
}

func leafParentAndRemovedMove(): Unit {
    let f = SlotFixture()
    let a = ref(f.rows[0])
    expectUI("InvalidParent", { => f.app.batch({ => a.append(Text("X")) }) })
    dead(f.app, [a], "Text cannot own children")
    f.app.dispose()

    let g = SlotFixture()
    let rr = ref(g.root)
    let old = ref(g.rows[0])
    expectUI("StaleReference", { => g.app.batch({ => rr.remove(old); rr.moveToEnd(old) }) })
    dead(g.app, [rr, old], "move after earlier remove")
    g.app.dispose()
}

func structureLimits(): Unit {
    let root = Column({ => })
    let app = Application(root, limits: RuntimeLimits(structuralOpsPerBatch: 1))
    app.startHeadless()
    let rr = ref(root)
    expectUI("CapacityExceeded", { => app.batch({ => rr.append(Text("A")); rr.append(Text("B")) }) })
    dead(app, [rr], "structural command budget")
    app.dispose()

    let data = Observable<Array<String>>(["A"])
    let log = FixtureLog()
    let tree = Column({ =>
        ForEach<String>({ => data.get() }, { value => value }, { item =>
            Text(item.value).onMount({ _ => log.mounts.add(item.key); { => log.cleanups.add(item.key) } })
        })
    })
    let limited = Application(tree, limits: RuntimeLimits(mountedNodes: 2))
    limited.startHeadless()
    let tr = ref(tree)
    let a = tr.children()[0]
    data.set(["A", "B"])
    expectUI("CapacityExceeded", { => limited.snapshot(1, 4) })
    check(log.mounts.size == 1 && log.trace() == "A,", "node limit does not half mount added key")
    dead(limited, [tr, a], "dynamic node limit")
    limited.dispose()
}
