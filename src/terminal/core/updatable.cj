package acnl.terminal.core

public interface Updatable {
    func updated(): Unit
    func beginChange(): Unit
    func endChange(): Unit
}