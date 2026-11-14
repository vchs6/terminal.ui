package cjtui

// A shared row is frozen permanently; writers replace it with a private copy.
class FrameRow {
    let cells: Array<Cell>
    var frozen: Bool = false

    init(width: Int64, transparent: Bool, owner: ?RuntimeSession) {
        cells = Array<Cell>(width, {_ => blankCell(transparent)})
        if (let Some(session) <- owner) { session.recordCells(width, width) }
    }
    init(source: FrameRow) {
        cells = Array<Cell>(source.cells.size, {i => source.cells[i]})
    }
}
