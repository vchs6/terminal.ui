package interaction_b

import cjtui.*
import std.collection.*

// Catches key-by-index state transfer and artificial focus tied to visible clip or marker order.
func mixedIdentityRetention(): Unit {
    let data = Observable<Array<String>>(["A", "B"])
    let entries = ArrayList<Component>()
    let root = ScrollView({ =>
        ForEach<String>({ => data.get() }, { value => value }, { item =>
            entries.add(Text({ => item.value }).height(1).focusable(true))
        })
    })
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(1, 2)
        let a = ref(entries[0])
        let b = ref(entries[1])
        let manual = Text("M").height(1).focusable(true)
        app.batch({ =>
            ref(root).insertBefore(b, manual)
            a.requestFocus()
        })
        app.batch({ => data.set(["B", "A"]) })
        app.snapshot(1, 2)
        let children = ref(root).children()
        check(children.size == 3 && children[0].sameNode(b) &&
            children[1].sameNode(ref(manual)) && children[2].sameNode(a), "B02 actual mixed sequence B M A")
        check(app.focusedNode().getOrThrow().sameNode(a), "B02 key reorder retains actual focus")
        app.snapshot(0, 0)
        check(app.focusedNode().getOrThrow().sameNode(a), "B02 zero clip retains same focus")
        app.snapshot(1, 2)
        app.dispatch(a, KeyEvent("tab", ""))
        check(app.focusedNode().getOrThrow().sameNode(ref(root)), "B02 next Tab follows real order, wraps to parent")
        check(a.isValid() && b.isValid(), "B02 clipping never hides or unmounts data")
    } finally { app.dispose() }
}
