package dynamic_contract

import cjtui.*
import std.collection.*

func conditionalLifetimes(): Unit {
    let show = Observable<Bool>(true)
    let label = Observable<String>("A")
    let branches = ArrayList<Component>()
    let log = FixtureLog()
    let root = Column({ =>
        Text("P")
        If({ => show.get() }, { =>
            log.bodies.add("then")
            branches.add(Text({ => label.get() }).onMount({ _ =>
                log.mounts.add("then")
                { => log.cleanups.add("then") }
            }))
        }, elseBody: { =>
            log.bodies.add("else")
            branches.add(Text("N").onMount({ _ =>
                log.mounts.add("else")
                { => log.cleanups.add("else") }
            }))
        })
        Text("Q")
    })
    let app = Application(root)
    app.startHeadless()
    picture(app, 1, 5, "P\nA\nQ\n \n ", "If is a direct sibling without a layout box")
    check(ref(root).children().size == 3, "If marker hidden from public children")
    let a = ref(branches[0])
    show.set(false)
    picture(app, 1, 5, "P\nN\nQ\n \n ", "If switches branch")
    check(!a.isValid() && log.trace() == "then,", "If unmounts old branch exactly once")
    let subscriptions = app.stats().subscriptions
    label.set("B")
    picture(app, 1, 5, "P\nN\nQ\n \n ", "unmounted branch binding detached")
    check(app.stats().subscriptions == subscriptions, "inactive branch has no revived subscription")
    let n = ref(branches[1])
    show.set(true)
    picture(app, 1, 5, "P\nB\nQ\n \n ", "If reconstructs and reads latest value")
    check(!n.isValid() && !ref(branches[2]).sameNode(a), "branch re-entry is a new generation")
    check(log.bodies.size == 3 && log.mounts.size == 3, "one body and mount per branch activation")
    app.dispose()
    check(log.trace() == "then,else,then,", "conditional cleanup once per mounted branch")
}

func emptyConditionalAndPlainControlFlow(): Unit {
    let show = Observable<Bool>(false)
    let plain = MutableBox<Bool>(true)
    let root = Column({ =>
        if (plain.value) { Text("S") }
        for (_ in 0..1) { Text("F") }
        If({ => show.get() }, { => Text("D") })
    })
    let app = Application(root)
    app.startHeadless()
    picture(app, 1, 4, "S\nF\n \n ", "empty If branch legal")
    plain.value = false
    show.set(true)
    picture(app, 1, 4, "S\nF\nD\n ", "plain if/for build once, explicit If reacts")
    check(ref(root).children().size == 3, "plain and dynamic direct children")
    show.set(false)
    picture(app, 1, 4, "S\nF\n \n ", "default else is empty")
    app.dispose()
}

func unmountingGroupParentReleasesDescendants(): Unit {
    let show = Observable<Bool>(true)
    let data = Observable<Array<String>>(["A", "B"])
    let parents = ArrayList<Component>()
    let rows = ArrayList<Component>()
    let log = FixtureLog()
    let root = Column({ =>
        If({ => show.get() }, { =>
            parents.add(Column({ =>
                ForEach<String>({ => data.get() }, { value => value }, { item =>
                    log.bodies.add(item.key)
                    rows.add(Text(item.value).onMount({ _ => { => log.cleanups.add(item.key) } }))
                })
            }))
        })
    })
    let app = Application(root)
    app.startHeadless()
    let rr = ref(root)
    let oldParent = ref(parents[0])
    let a = ref(rows[0])
    let b = ref(rows[1])
    let subscriptions = app.stats().subscriptions
    let ownerRuns = MutableBox<Int64>(0)
    app.onKeyEvent({ _ =>
        check(app.post(a, { => ownerRuns.value++ }), "descendant owner post accepted before parent removal")
        show.set(false)
    })
    app.dispatch(rr, KeyEvent("test"))
    data.set(["C"])
    picture(app, 1, 4, " \n \n \n ", "removing group parent removes all nested list children")
    check(ownerRuns.value == 0 && !oldParent.isValid() && !a.isValid() && !b.isValid(),
        "parent unmount revokes entire descendant subtree and owner queue")
    check(ref(root).children().isEmpty() && app.stats().mountedNodes == 1 &&
        app.stats().subscriptions < subscriptions, "nested dynamic subscriptions released with parent")
    check(log.cleanups.size == 2 && log.bodies.size == 2, "inactive group does no work when data changes")
    show.set(true)
    picture(app, 1, 4, "C\n \n \n ", "re-entered parent constructs latest list data")
    check(parents.size == 2 && !ref(parents[1]).sameNode(oldParent) && log.bodies.size == 3,
        "new parent and descendants receive fresh identity")
    app.dispose()
    check(log.cleanups.size == 3, "nested list cleanup once per mounted key")
}
