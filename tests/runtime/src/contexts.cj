package runtime_contract

import cjtui.*

func contextsAndLimits(): Unit {
    let root = Text("x")
    let app = Application(root)
    code("SessionInactive", { => app.snapshot(1, 1); () }, "snapshot rejects inactive session")
    app.startHeadless()
    let owner = ref(root)
    let worker = spawn {
        code("WrongUIContext", { => app.snapshot(1, 1); () }, "snapshot rejects another thread")
        owner.isValid()
    }
    check(worker.get(Duration.second * 5), "isValid remains safe on another thread")
    let second = Application(Text("second"))
    second.startHeadless()
    code("WrongUIContext", { => app.batch({ => second.batch({ => }) }) }, "active callback cannot enter another session")
    second.dispose()
    app.dispose()
    for (make in [
        { => RuntimeLimits(pendingPosts: 0) },
        { => RuntimeLimits(mountedNodes: 0) },
        { => RuntimeLimits(bindingsPerNode: 0) },
        { => RuntimeLimits(dependenciesPerBinding: 0) },
        { => RuntimeLimits(structuralOpsPerBatch: 0) },
        { => RuntimeLimits(stabilizationPasses: 0) },
        { => RuntimeLimits(treeDepth: 0) }
    ]) { illegal({ => make(); () }, "each runtime budget must be positive") }
    let allNamed = RuntimeLimits(pendingPosts: 2, mountedNodes: 10, bindingsPerNode: 4,
        dependenciesPerBinding: 3, structuralOpsPerBatch: 2, stabilizationPasses: 4, treeDepth: 4)
    let explicitMode = Application(Text("ok"), colorMode: ColorMode.TrueColor, limits: allNamed)
    explicitMode.startHeadless()
    explicitMode.dispose()
    code("CapacityExceeded", { =>
        Application(Column { Text("x") }, limits: RuntimeLimits(mountedNodes: 1)).startHeadless()
    }, "node capacity rejects before exposing oversized tree")
    code("CapacityExceeded", { =>
        Application(Column { Column { Text("x") } }, limits: RuntimeLimits(treeDepth: 1)).startHeadless()
    }, "tree depth budget enforced")
    let a = Observable<String>("a")
    let b = Observable<String>("b")
    code("CapacityExceeded", { =>
        Application(Text({ => a.get() + b.get() }), limits: RuntimeLimits(dependenciesPerBinding: 1)).startHeadless()
    }, "dependency budget enforced")
    code("CapacityExceeded", { =>
        Application(Text({ => a.get() }).foreground({ => Color.Red }),
            limits: RuntimeLimits(bindingsPerNode: 1)).startHeadless()
    }, "binding budget enforced")
    code("ReentrantEvaluation", { =>
        Application(Text({ => a.set("illegal"); a.get() })).startHeadless()
    }, "getter cannot mutate observable")
    let recursive = Box<?Application>(Option<Application>.None)
    let recursiveRoot = Text({ => recursive.value.getOrThrow().snapshot(1, 1); "x" })
    recursive.value = Some(Application(recursiveRoot))
    code("ReentrantEvaluation", { => recursive.value.getOrThrow().startHeadless() }, "getter cannot recursively snapshot")
    code("DuplicateKey", { =>
        Application(Column { Text("A").key("same"); Text("B").key("same") }).startHeadless()
    }, "static sibling keys are unique")
    code("InvalidKey", { => Text("A").key(""); () }, "empty explicit key rejected")
    backgroundReadIsolation()
}

func backgroundReadIsolation(): Unit {
    let uiValue = Observable<String>("U")
    let workerValue = Observable<String>("W")
    let calls = Box<Int64>(0)
    let app = Application(Text({ =>
        calls.value++
        let background = spawn { workerValue.get() }
        background.get(Duration.second * 5)
        uiValue.get()
    }))
    app.startHeadless()
    app.snapshot(1, 1)
    check(app.stats().subscriptions == 1, "background get does not enter UI dependency collector")
    let initial = calls.value
    workerValue.set("changed")
    app.snapshot(1, 1)
    check(calls.value == initial, "background-only state does not invalidate UI getter")
    app.dispose()
}
