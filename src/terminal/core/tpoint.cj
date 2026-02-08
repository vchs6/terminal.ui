package acnl.terminal.core

public struct TPoint <: Equatable<TPoint> {
    public var col: Int64 = 0        //xpos
    public var row: Int64 = 0        //ypos

    public init(col: Int64, row: Int64) {
        this.col = col
        this.row = row
    }

    public mut func moveto(col: Int64, row: Int64): Unit {
        this.col = col
        this.row = row
    }

    public operator func ==(rhs: TPoint): Bool {
        (col, row) == (rhs.col, rhs.row)
    }
}
