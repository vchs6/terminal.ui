package dynamic_contract

import cjtui.*
import std.collection.*

// Detects retaining the initial T, rebuilding surviving keys, or transferring local state by index.
func retainedKeyGetsNewValue(): Unit {
    let data = Observable<Array<RowData>>([RowData("a", "A"), RowData("b", "B")])
    let rows = ArrayList<StatefulRow>()
    let log = FixtureLog()
    let root = Column({ =>
        ForEach<RowData>({ => data.get() }, { value => value.id }, { item =>
            log.bodies.add(item.key)
            let row = StatefulRow(item, log)
            rows.add(row)
        })
    })
    let app = Application(root)
    app.startHeadless()
    let a = ref(rows[0])
    let b = ref(rows[1])
    rows[0].local.set(7)
    picture(app, 5, 3, "A:7  \nB:0  \n     ", "local state before new T")
    data.set([RowData("b", "Bee"), RowData("a", "Ay")])
    picture(app, 5, 3, "Bee:0\nAy:7 \n     ", "new object updates ListItem.value and retains local state")
    sequence(ref(root), [b, a], "new T preserves keyed identity")
    check(log.bodies.size == 2 && log.builds == 2, "surviving key body and build each once")
    check(rows[0].item.key == "a" && rows[0].item.value.label == "Ay", "retained ListItem key/value")
    data.set([RowData("b", "Bee")])
    picture(app, 5, 3, "Bee:0\n     \n     ", "delete stateful row")
    check(!a.isValid(), "stateful removal invalidates old ref")
    data.set([RowData("a", "New"), RowData("b", "Bee")])
    picture(app, 5, 3, "New:0\nBee:0\n     ", "same deleted key creates fresh local state")
    check(rows.size == 3 && !ref(rows[2]).sameNode(a) && !a.isValid(), "deleted key ref never revives")
    app.dispose()
}

// Detects globally keyed groups, or group rebuilding that deletes/moves manual and other-group nodes.
func multipleGroupsAndManualOrder(): Unit {
    let left = Observable<Array<String>>(["A", "B"])
    let right = Observable<Array<String>>(["A", "B"])
    let l = ArrayList<Component>()
    let r = ArrayList<Component>()
    let root = Column({ =>
        ForEach<String>({ => left.get() }, { value => value }, { item =>
            l.add(Text({ => if (item.value == "A") { "a" } else if (item.value == "B") { "b" } else { "c" } }))
        })
        Text("S")
        ForEach<String>({ => right.get() }, { value => value }, { item => r.add(Text({ => item.value })) })
    })
    let app = Application(root)
    app.startHeadless()
    let lrA = ref(l[0])
    let lrB = ref(l[1])
    let rrA = ref(r[0])
    let rrB = ref(r[1])
    let separator = ref(root).children()[2]
    check(!lrA.sameNode(rrA), "same string key is scoped by group")
    let x = Text("X")
    let y = Text("Y")
    app.batch({ =>
        ref(root).insertBefore(lrB, x)
        ref(root).insertBefore(rrB, y)
        ref(root).moveBefore(rrA, lrA)
    })
    picture(app, 1, 9, "A\na\nX\nb\nS\nY\nB\n \n ", "interleaved groups before updates")
    app.batch({ =>
        left.set(["B", "A", "C"])
        right.set(["B", "A"])
    })
    picture(app, 1, 9, "B\nb\nX\na\nc\nS\nY\nA\n ", "each group replaces only its own slots")
    sequence(ref(root), [rrB, lrB, ref(x), lrA, ref(l[2]), separator, ref(y), rrA], "multiple group identities")
    left.set([])
    picture(app, 1, 9, "B\nX\nS\nY\nA\n \n \n \n ", "remove one group preserves manual order and other group")
    check(rrA.isValid() && rrB.isValid(), "other group retains same-key refs")
    app.dispose()
}
