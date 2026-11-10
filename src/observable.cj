package cjtui

public class Observable<T> <: ObservableSource {
    private var value: T
    public init(initial: T) { value = initial }
    public func get(): T {
        lock.lock()
        var result: T = value
        var readVersion: Int64 = 0
        try { result = value; readVersion = version } finally { lock.unlock() }
        if (let Some(binding) <- evaluating.get()) { binding.read(this, readVersion) }
        result
    }
    public func set(value: T): Unit {
        if (evaluating.get().isSome()) { throw UIException("ReentrantEvaluation", "observable write during evaluation") }
        lock.lock()
        try { this.value = value; version++ } finally { lock.unlock() }
        emit()
    }
    public func notify(): Unit {
        if (evaluating.get().isSome()) { throw UIException("ReentrantEvaluation", "observable write during evaluation") }
        lock.lock()
        try { version++ } finally { lock.unlock() }
        emit()
    }
}
