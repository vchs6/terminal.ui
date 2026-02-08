package acnl.terminal.core

public enum TAlign <: Equal<TAlign> & Hashable & ToString {
    | LEFT
    | CENTER
    | RIGHT

    public func toString(): String {
        match(this) {
            case CENTER => "center"
            case LEFT   => "left"
            case RIGHT  => "right"
        }
    }

    public func hashCode(): Int64 {
        toString().hashCode()
    }

    public operator func ==(other: TAlign): Bool {
        toString() == other.toString()
    }
}