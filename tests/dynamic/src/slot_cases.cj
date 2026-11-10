package dynamic_contract

import cjtui.*

// Detects keyed movement that drags X with A/B rather than replacing owned slots.
func slotReorder(): Unit {
    let f = SlotFixture()
    let x = f.manualX()
    let a = ref(f.rows[0])
    let b = ref(f.rows[1])
    let c = ref(f.rows[2])
    let xr = ref(x)
    sequence(ref(f.root), [a, xr, b, c], "A X B C initial")
    picture(f.app, 1, 6, "A\nX\nB\nC\n \n ", "manual insertion")
    f.items.set(["C", "B", "A"])
    picture(f.app, 1, 6, "C\nX\nB\nA\n \n ", "C X B A slot reorder")
    sequence(ref(f.root), [c, xr, b, a], "C X B A identities")
    f.app.dispose()
    dead(f.app, [a, b, c, xr], "reorder dispose")
}

func slotDelete(): Unit {
    let f = SlotFixture()
    let x = f.manualX()
    let a = ref(f.rows[0])
    let b = ref(f.rows[1])
    let c = ref(f.rows[2])
    f.items.set(["B", "C"])
    picture(f.app, 1, 6, "B\nX\nC\n \n \n ", "B X C deletion")
    sequence(ref(f.root), [b, ref(x), c], "B X C identities")
    check(!a.isValid(), "deleted A invalid")
    f.app.dispose()
}

func slotEmptyAndRefill(): Unit {
    let f = SlotFixture()
    let x = f.manualX()
    let old = [ref(f.rows[0]), ref(f.rows[1]), ref(f.rows[2])]
    f.items.set([])
    picture(f.app, 1, 6, "X\n \n \n \n \n ", "empty keeps X")
    sequence(ref(f.root), [ref(x)], "empty excludes group marker")
    for (node in old) { check(!node.isValid(), "empty invalidates declared nodes") }
    f.items.set(["D", "E"])
    picture(f.app, 1, 6, "X\nD\nE\n \n \n ", "refill before stable marker")
    sequence(ref(f.root), [ref(x), ref(f.rows[3]), ref(f.rows[4])], "X D E identities")
    f.app.dispose()
}

func slotPrependOverflow(): Unit {
    let f = SlotFixture()
    let x = f.manualX()
    let a = ref(f.rows[0])
    let b = ref(f.rows[1])
    let c = ref(f.rows[2])
    f.items.set(["D", "A", "B", "C"])
    picture(f.app, 1, 6, "D\nX\nA\nB\nC\n ", "D X A B C overflow")
    sequence(ref(f.root), [ref(f.rows[3]), ref(x), a, b, c], "D X A B C identities")
    f.app.dispose()
}

func moveOutsideMarker(): Unit {
    let f = SlotFixture()
    let tail = Text("T")
    f.app.batch({ => ref(f.root).append(tail) })
    let a = ref(f.rows[0])
    let b = ref(f.rows[1])
    let c = ref(f.rows[2])
    let tr = ref(tail)
    f.app.batch({ => ref(f.root).moveToEnd(a) })
    picture(f.app, 1, 7, "B\nC\nT\nA\n \n \n ", "move declared A beyond marker and T")
    f.items.set(["C", "B", "A", "D"])
    picture(f.app, 1, 7, "C\nB\nT\nA\nD\n \n ", "whole parent owned slots include marker exterior")
    sequence(ref(f.root), [c, b, tr, a, ref(f.rows[3])], "exterior overflow identities")
    f.items.set([])
    picture(f.app, 1, 7, "T\n \n \n \n \n \n ", "exterior declared nodes all removed")
    f.items.set(["E"])
    picture(f.app, 1, 7, "E\nT\n \n \n \n \n ", "empty refill returns before marker before T")
    f.app.dispose()
}

func manualRemoveAndRebuild(): Unit {
    let f = SlotFixture()
    let a = ref(f.rows[0])
    let b = ref(f.rows[1])
    let c = ref(f.rows[2])
    f.app.batch({ => ref(f.root).remove(a) })
    picture(f.app, 1, 5, "B\nC\n \n \n ", "manual remove does not immediately re-create")
    check(!a.isValid() && f.rows.size == 3, "manual removal unmounts once")
    check(f.items.get().size == 3 && f.items.get()[0] == "A", "manual remove leaves business data")
    ref(f.root).notify(ChangeKind.Structure)
    picture(f.app, 1, 5, "A\nB\nC\n \n ", "Structure reconstructs still declared key")
    let replacement = ref(f.rows[3])
    check(!replacement.sameNode(a) && !a.isValid(), "re-created A has new identity")
    sequence(ref(f.root), [replacement, b, c], "reconstructed A and surviving B C")
    f.app.dispose()
}

func deferredReadsAndNoops(): Unit {
    let f = SlotFixture()
    let a = ref(f.rows[0])
    let b = ref(f.rows[1])
    let c = ref(f.rows[2])
    let x = Text("X")
    f.app.batch({ =>
        ref(f.root).insertBefore(b, x)
        check(x.reference().isNone(), "pending insertion publishes no provisional ref")
        sequence(ref(f.root), [a, b, c], "children reads committed sequence inside batch")
    })
    let copy = ref(f.root).children()
    copy[0] = c
    sequence(ref(f.root), [a, ref(x), b, c], "returned child array is independent")
    f.app.batch({ =>
        ref(f.root).moveBefore(a, a)
        ref(f.root).moveBefore(b, c)
        ref(f.root).moveToEnd(c)
    })
    sequence(ref(f.root), [a, ref(x), b, c], "validated no-op moves")
    f.app.dispose()
}

func commandsPrecedeReconciliation(): Unit {
    let f = SlotFixture()
    let rr = ref(f.root)
    let a = ref(f.rows[0])
    let b = ref(f.rows[1])
    let c = ref(f.rows[2])
    f.app.batch({ =>
        f.items.set(["C", "B", "A"])
        rr.remove(a)
        sequence(rr, [a, b, c], "pending state and commands leave committed reads unchanged")
    })
    picture(f.app, 1, 4, "C\nB\nA\n ", "explicit remove runs before pending latest structure getter")
    check(!a.isValid() && f.rows.size == 4, "A is removed then reconstructed from still-present key")
    sequence(rr, [c, b, ref(f.rows[3])], "reconciliation after explicit commands")
    f.app.dispose()
}
