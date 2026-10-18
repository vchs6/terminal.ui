package acnl.terminal.core


public struct TRect <: Equatable<TRect> {
    private var pos: TPoint
    private var size: TSize

    public init() {
        pos = TPoint(0 , 0)
        size = TSize(0, 0)
    }

    public init(pos: (col: Int64, row: Int64), size: (width: Int64, height: Int64)) {
        this.pos = TPoint(pos[0], pos[1])
        this.size = TSize(size[0], size[1])
    }

    public init(pos: TPoint, size: TSize) {
        this.pos = TPoint(pos.col, pos.row)
        this.size = TSize(size.width, size.height)
    }

    public init(lt: TPoint, br: TPoint) {
        let (r1, c1) = (min(lt.row, br.row), min(lt.col, br.col))
        let (r2, c2) = (max(lt.row, br.row), max(lt.col, br.col))
        pos = TPoint(c1, r1)
        size = TSize(c2 - c1 + 1, r2 - r1 + 1)
    }

    public init(lt: TPoint, width: Int64, height: Int64) {
        pos = TPoint(lt.col, lt.row)
        size = TSize(width, height)
    }

    public func isEmpty(): Bool {
        size.isEmpty()
    }

    public operator func ==(rhs: TRect): Bool {
        (pos, size) == (rhs.pos, rhs.size)
    }

    public func getOverlapRect(rect: TRect): TRect {
        let LT = TPoint(max(left, rect.left), max(top, rect.top))
        let RB = TPoint(min(right, rect.right), min(bottom, rect.bottom))
        if (LT.col < RB.col && LT.row < RB.row ) {
            TRect(LT, RB)
        } else {
            TRect()
        }
    }

    public mut prop left: Int64 {
        get() { pos.col }
        set(v) { pos.col = v }
    }

    public mut prop top: Int64 {
        get() { pos.row }
        set(v) { pos.row = v}
    }

    public mut prop width: Int64 {
        get() { size.width }
        set(v) { size.width = v }
    }

    public mut prop height: Int64 {
        get() { size.height }
        set(v) { size.height = v }
    }

    public mut prop right: Int64 {
        get() { pos.col + size.width - 1}
        set(v) {
            size.width += pos.col - v
            pos.col = v
        }
    }

    public mut prop bottom: Int64 {
        get() { pos.row + size.height - 1}
        set(v) {
            size.height += pos.row - v
            pos.row = v 
        }
    }
}