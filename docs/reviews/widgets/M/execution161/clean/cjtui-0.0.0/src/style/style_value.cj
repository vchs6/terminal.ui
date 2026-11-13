package cjtui.style
public enum StyleValue<T> { | Unset | Value(T) | Reset }
extend<T> StyleValue<T> <: Equatable<StyleValue<T>> where T <: Equatable<T> {
    public operator func ==(other: StyleValue<T>): Bool {
        match ((this, other)) {
            case (Unset, Unset) | (Reset, Reset) => true
            case (Value(a), Value(b)) => a == b
            case _ => false
        }
    }
}
