package acnl.terminal.core

public interface EventProcessor {
    func notify(event: TEvent): Unit
    func addEventProcessor(event: TEvent, callback: (TEvent)->Unit): Unit
    func removeEventProcessor(event: TEvent): Unit
}