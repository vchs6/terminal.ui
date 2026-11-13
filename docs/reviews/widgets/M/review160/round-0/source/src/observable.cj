package cjtui

public class Observable<T> <: ObservableSource {
    private var value: T
    public init(initial: T) {
        value = initial
    }
    public func get(): T {
        lock.lock()
        var result: T = value
        var readVersion: Int64 = 0
        try {
            result = value
            readVersion = version
        } finally {
            lock.unlock()
        }
        if (let Some(binding) <- evaluating.get()) {
            binding.read(this, readVersion)
        }
        result
    }
    // Snapshot and conditional publication share the existing source lock and version.
    func editingSnapshot(): (T, Int64) {
        lock.lock()
        try {
            (value, version)
        } finally {
            lock.unlock()
        }
    }
    func editingCommit(expected: Int64, next: T): ?Int64 {
        if (evaluating.get().isSome() || structureEvaluation.get().isSome()) {
            throw UIException("ReentrantEvaluation", "observable write during evaluation")
        }
        var committed: ?Int64 = None
        lock.lock()
        try {
            if (version == expected) {
                value = next
                version++;
                committed = Some(version)
            }
        } finally {
            lock.unlock()
        }
        if (committed.isSome()) {
            emit()
        }
        committed
    }
    public func set(value: T): Unit {
        if (evaluating.get().isSome() || structureEvaluation.get().isSome()) {
            throw UIException("ReentrantEvaluation", "observable write during evaluation")
        }
        lock.lock()
        try {
            this.value = value
            version++
        } finally {
            lock.unlock()
        }
        emit()
    }
    public func notify(): Unit {
        if (evaluating.get().isSome() || structureEvaluation.get().isSome()) {
            throw UIException("ReentrantEvaluation", "observable write during evaluation")
        }
        lock.lock()
        try {
            version++
        } finally {
            lock.unlock()
        }
        emit()
    }
}
