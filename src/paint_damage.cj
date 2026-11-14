package cjtui

import std.collection.ArrayList
import std.collection.HashMap

func collectPaintStates(node: LayoutNode, result: ArrayList<PaintState>): Unit {
    let state = PaintState(node)
    result.add(state)
    if (node.component.kind != 0 && node.component.kind != 3) {
        for (child in node.children()) { collectPaintStates(child, result) }
    }
}

func compositionDamage(old: ArrayList<PaintState>, current: ArrayList<PaintState>, height: Int64): DamageRows {
    let damage = DamageRows(height)
    let before = HashMap<Int64, PaintState>()
    let after = HashMap<Int64, PaintState>()
    for (state in old) { before[state.id] = state }
    for (state in current) { after[state.id] = state }
    for (state in old) {
        if (let Some(next) <- after.get(state.id)) {
            let same = state.sameGeometry(next)
            if (next.changed || !same) {
                if (state.left < state.right) { damage.include(state.top, state.bottom) }
                if (next.left < next.right) { damage.include(next.top, next.bottom) }
            }
        } else if (state.left < state.right) { damage.include(state.top, state.bottom) }
    }
    for (state in current) {
        if (before.get(state.id).isNone() && state.left < state.right) { damage.include(state.top, state.bottom) }
    }
    // A retained node is involved in a reorder when an earlier node now
    // follows it, or a later node now precedes it. Detect both in linear time.
    let positions = HashMap<Int64, Int64>()
    for (i in 0..current.size) { positions[current[i].id] = i }
    let inverted = Array<Bool>(old.size, {_ => false})
    var maximum: Int64 = -1
    for (i in 0..old.size) {
        if (let Some(pos) <- positions.get(old[i].id)) {
            if (pos < maximum) { inverted[i] = true }
            maximum = greater(maximum, pos)
        }
    }
    var minimum = current.size
    var i = old.size
    while (i > 0) {
        i--
        if (let Some(pos) <- positions.get(old[i].id)) {
            if (pos > minimum) { inverted[i] = true }
            minimum = lesser(minimum, pos)
        }
    }
    for (i in 0..old.size) {
        if (inverted[i]) {
            let state = old[i]
            let next = after.get(state.id).getOrThrow()
            if (state.left < state.right) { damage.include(state.top, state.bottom) }
            if (next.left < next.right) { damage.include(next.top, next.bottom) }
        }
    }
    damage
}

// Resolve visibility from the source that actually owns the final cell, not
// from its glyph or the writes that happened in this particular target pass.
func resolvePaintedCaret(session: RuntimeSession, frame: Frame, states: ArrayList<PaintState>): Unit {
    if (let Some(request) <- session.pendingCaret) {
        if (!request.owner.isValid()) { session.pendingCaret = None; return }
        if (request.x < 0 || request.y < 0 || request.x >= frame.width || request.y >= frame.height) { return }
        let writer = frame.getPaintOwners().at(request.x, request.y)
        if (writer < 0) { return }
        let owner = request.owner.resolve().id
        var ownerOrder: Int64 = -1
        var writerOrder: Int64 = -1
        for (i in 0..states.size) {
            if (states[i].id == owner) { ownerOrder = i }
            if (states[i].id == writer) { writerOrder = i }
        }
        if (ownerOrder < 0 || writerOrder < 0) {
            throw UIException("InvalidPaintOwner", "caret source is outside the composed scene")
        }
        if (writerOrder > ownerOrder) { session.pendingCaret = None }
    }
}
