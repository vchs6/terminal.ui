package acnl.terminal.core

public interface Focusable <: EventProcessor {
    func setFocused(value: Bool): Unit
    func isFocused(): Bool
    mut prop tabIndex: Int64
}