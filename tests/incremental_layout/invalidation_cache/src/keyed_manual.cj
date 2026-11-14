package incremental_invalidation_cache

import cjtui.*

// Breaks: moved keys lose identity/cache; manual slot or Structure notification is dropped.
func keyedManual(): Unit {
    let epoch = [Int64(0)]
    let items = Observable<Array<String>>(["A", "B", "C"])
    let root = Column { ForEach({ => items.get() }, { item => item }, { item => Text({ => item.value }) }) }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 1, 4, "A\nB\nC\n ", "keyed initial")
        let parent = root.reference().getOrThrow()
        let a = parent.children()[0]
        let b = parent.children()[1]
        let c = parent.children()[2]
        advance(app, epoch, { => parent.insertBefore(b, Text("X")) })
        paired(app, root, epoch, 1, 4, "A\nX\nB\nC", "manual inserted physical slot")
        let x = parent.children()[1]
        advance(app, epoch, { => items.set(["C", "B", "A"]) })
        paired(app, root, epoch, 1, 4, "C\nX\nB\nA", "keys reverse around manual slot").reducedMeasure()
        check(parent.children()[0].sameNode(c) && parent.children()[2].sameNode(b) && parent.children()[3].sameNode(a), "keys retain nodes")
        advance(app, epoch, { => parent.moveToEnd(x) })
        paired(app, root, epoch, 1, 4, "C\nB\nA\nX", "manual position changes only").reducedMeasure()
        advance(app, epoch, { => parent.remove(b) })
        paired(app, root, epoch, 1, 4, "C\nA\nX\n ", "manual removal of declarative B")
        check(!b.isValid(), "removed keyed node invalid")
        advance(app, epoch, { => parent.notify(ChangeKind.Structure) })
        paired(app, root, epoch, 1, 4, "C\nB\nA\nX", "Structure restores latest declarative data")
        check(parent.children()[0].sameNode(c) && parent.children()[2].sameNode(a), "unremoved keys retain identities")
        advance(app, epoch, { => items.set([]) })
        paired(app, root, epoch, 1, 4, "X\n \n \n ", "manual survives empty declaration")
    } finally { app.dispose() }
}
