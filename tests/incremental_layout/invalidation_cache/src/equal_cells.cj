package incremental_invalidation_cache

import cjtui.*

func equalCells(actual: Frame, reference: Frame, label: String): Unit {
    check(actual.width == reference.width && actual.height == reference.height, "${label}: frame size")
    for (y in 0..actual.height) {
        for (x in 0..actual.width) {
            let a = actual.cellAt(x, y)
            let b = reference.cellAt(x, y)
            if (!(a.grapheme == b.grapheme && a.width == b.width && a.continuation == b.continuation &&
                a.style == b.style && a.isTransparent == b.isTransparent)) {
                throw Exception("${label}: Cell(${x},${y}) actual=${describeCell(a)} reference=${describeCell(b)}")
            }
        }
    }
}
