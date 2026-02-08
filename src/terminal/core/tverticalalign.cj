package acnl.terminal.core

public enum TVerticalAlign <: Equal<TVerticalAlign> & Hashable & ToString {
    | TOP
    | MIDDLE
    | BOTTOM

    public func toString(): String {
        match(this) {
            case BOTTOM => "bottom"
            case TOP    => "top"
            case MIDDLE => "middle"
        }
    }

    public func hashCode(): Int64 {
        toString().hashCode()
    }

    public operator func ==(other: TVerticalAlign): Bool {
        toString() == other.toString()
    }
}