package incremental_invalidation_cache

import cjtui.*

// Breaks: viewport constraint/clip changes fail to propagate wrap height and clamp offsets.
func viewportWrap(): Unit {
    let epoch = [Int64(0)]
    let text = Observable<String>("abcdefghij")
    let root = ScrollView { Text({ => text.get() }).wrap(TextWrap.Grapheme); Text("Z") }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 4, 2, "abcd\nefgh", "viewport wrap initial")
        let ref = root.reference().getOrThrow()
        check(ref.viewportSnapshot().contentHeight == 4, "viewport initial wrap extent four")
        advance(app, epoch, { => check(ref.scrollTo(0, 2), "viewport scroll to bottom") })
        paired(app, root, epoch, 4, 2, "ij  \nZ   ", "viewport scroll reuses text measurement").reducedMeasure()
        paired(app, root, epoch, 5, 2, "fghij\nZ    ", "viewport wider wraps to two then clamps")
        check(ref.viewportSnapshot().offsetY == 1 && ref.viewportSnapshot().contentHeight == 3, "width clamp and new extent")
        advance(app, epoch, { => text.set("q") })
        paired(app, root, epoch, 5, 2, "q    \nZ    ", "viewport content shrink clamp")
        check(ref.viewportSnapshot().offsetY == 0 && ref.viewportSnapshot().contentHeight == 2, "content shrink clamps to zero")
        paired(app, root, epoch, 5, 3, "q    \nZ    \n     ", "viewport height changes clip")
        paired(app, root, epoch, 1, 2, "q\nZ", "viewport narrow constraint")
    } finally { app.dispose() }
}
