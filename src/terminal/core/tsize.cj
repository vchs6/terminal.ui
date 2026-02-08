package acnl.terminal.core

public struct TSize <: Equatable<TSize> & ToString {
    public var width: Int64
    public var height: Int64

    public init() {
        width = 0
        height = 0
    }
    
    public init(w: Int64, h: Int64) {
        width = w
        height = h
    }

    public func isEmpty(): Bool {
        width + height == 0
    }

    public operator func ==(ot: TSize): Bool {
        (width, height) == (ot.width, ot.height)
    }

    public func toString(): String {
        width.toString() + "," + height.toString()
    }
}