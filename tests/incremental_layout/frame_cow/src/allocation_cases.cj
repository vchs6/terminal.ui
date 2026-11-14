package incremental_frame_cow

import cjtui.*

// Catches copy capacity charged outside ownership and stale aliases after later app generations.
// Numbers printed are measurements, never expected visual fixtures or synthetic allocation counts.
func allocationObservation(requireCow: Bool): Unit {
    let state = Observable<String>("A")
    let root = Text({ => state.get() })
    let app = Application(root)
    app.startHeadless()
    try {
        let first = app.snapshot(8, 3, glyphMode: GlyphMode.Unicode)
        plain(first, "A       \n        \n        ", "first app snapshot")
        let before = app.stats()
        let second = app.snapshot(8, 3, glyphMode: GlyphMode.Unicode)
        let afterSecond = app.stats()
        let third = app.snapshot(8, 3, glyphMode: GlyphMode.Unicode)
        let afterThird = app.stats()
        check(afterSecond.frames == before.frames && afterThird.frames == before.frames,
            "same epoch cached snapshot must not generate frames")
        same(second, first, "same epoch second snapshot")
        same(third, first, "same epoch third snapshot")
        let secondSlots = afterSecond.frameAllocatedCells - before.frameAllocatedCells
        let thirdSlots = afterThird.frameAllocatedCells - afterSecond.frameAllocatedCells
        println("MEASURE cached_snapshot second_slots=${secondSlots} third_slots=${thirdSlots} area=24")
        check(secondSlots >= 0 && thirdSlots >= 0, "allocation counts cumulative")
        second.put(0, 0, "S")
        second.put(1, 0, "T") // repeated same-row caller write
        second.put(0, 2, "U") // different-row caller write
        let callerCopy = third.copy(Rect(0, 0, 8, 3))
        callerCopy.clear(Rect(0, 0, 8, 3), transparent: true)
        let callerResize = first.resized(9, 3)
        callerResize.put(0, 0, "R")
        unchanged(afterThird, app.stats(), "caller first/repeated/other-row writes and copy/resize unowned")
        plain(first, "A       \n        \n        ", "earliest snapshot survives caller writes")
        plain(third, "A       \n        \n        ", "third snapshot survives caller writes")
        app.batch({ => state.set("B") })
        let updated = app.snapshot(8, 3, glyphMode: GlyphMode.Unicode)
        let afterUpdate = app.stats()
        plain(updated, "B       \n        \n        ", "updated app snapshot")
        plain(first, "A       \n        \n        ", "old snapshot survives new app generation")
        plain(second, "ST      \n        \nU       ", "caller edits survive new app generation")
        println("MEASURE changed_generation slots=${afterUpdate.frameAllocatedCells - afterThird.frameAllocatedCells}")
        let reference = render(root, 8, 3, glyphMode: GlyphMode.Unicode)
        let afterReference = app.stats()
        same(updated, reference, "matching-width/profile/epoch full reference")
        check(afterReference.frameAllocatedCells >= afterUpdate.frameAllocatedCells + 24,
            "full reference allocates its actual 24 target slots")
        println("MEASURE full_reference slots=${afterReference.frameAllocatedCells - afterUpdate.frameAllocatedCells}")
        reference.put(0, 0, "E")
        reference.put(1, 0, "F")
        reference.fillRect(Rect(0, 2, 8, 1), style: Style(background: Color.Blue))
        unchanged(afterReference, app.stats(), "returned public render first/repeated writes unowned")
        updated.clear(Rect(0, 0, 1, 1))
        unchanged(afterReference, app.stats(), "returned snapshot write unowned")
        let restored = app.snapshot(8, 3, glyphMode: GlyphMode.Unicode)
        plain(restored, "B       \n        \n        ", "external edits never poison app target")
        if (requireCow) {
            check(secondSlots == 0 && thirdSlots == 0,
                "COW RED: unchanged complete snapshots must share existing Cell storage; got ${secondSlots}, ${thirdSlots} newly allocated slots")
        }
    } finally { app.dispose() }
}
