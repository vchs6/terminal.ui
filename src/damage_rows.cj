package cjtui

// A damage set represents entire terminal rows, including wide-cell partners.
class DamageRows {
    private let rows: Array<Bool>
    init(height: Int64) { rows = Array<Bool>(height, {_ => false}) }
    func include(top: Int64, bottom: Int64): Unit {
        let first = greater(0, top)
        let end = lesser(rows.size, bottom)
        for (y in first..greater(first, end)) { rows[y] = true }
    }
    func contains(y: Int64): Bool { y >= 0 && y < rows.size && rows[y] }
    func intersects(top: Int64, bottom: Int64): Bool {
        let first = greater(0, top)
        let end = lesser(rows.size, bottom)
        for (y in first..greater(first, end)) { if (rows[y]) { return true } }
        false
    }
}
