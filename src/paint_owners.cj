package cjtui

// Source ownership follows the same logical target generations as Frame rows.
// A clean row is shared read-only; damaged rows start with no contributing node.
class PaintOwners {
    private let width: Int64
    private let rows: Array<Array<Int64>>
    init(width: Int64, height: Int64, damage!: ?DamageRows = None) {
        this.width = width
        let count = if (width == 0) { 0 } else { height }
        let blank = if (count > 0 && damage.isSome()) { Array<Int64>(width, {_ => -1}) } else { Array<Int64>() }
        rows = Array<Array<Int64>>(count, {y =>
            if (let Some(damaged) <- damage) {
                if (damaged.contains(y)) { Array<Int64>(width, {_ => -1}) } else { blank }
            } else { Array<Int64>(width, {_ => -1}) }
        })
    }
    private init(previous: PaintOwners, damage: DamageRows) {
        width = previous.width
        rows = Array<Array<Int64>>(previous.rows.size, {y =>
            if (damage.contains(y)) { Array<Int64>(previous.width, {_ => -1}) } else { previous.rows[y] }
        })
    }
    func replay(damage: DamageRows): PaintOwners { PaintOwners(this, damage) }
    func at(x: Int64, y: Int64): Int64 { rows[y][x] }
    func set(x: Int64, y: Int64, node: Int64): Unit { rows[y][x] = node }
}
