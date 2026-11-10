package auditsupplement

import std.collection.ArrayList

let attached = ArrayList<AuditBase>()
public func attachedCount(): Int64 { attached.size }
public func invokeBuild(index: Int64): Unit { attached[index].build() }

public open class AuditBase {
    public init() {}
    protected func finishConstruction(): Unit { attached.add(this) }
    public open func build(): Unit {}
}

public class Observable<T> {
    private var value: T
    public init(initial: T) { value = initial }
    public func get(): T { value }
    public func set(next: T): Unit { value = next }
}

public interface Named { func name(): String }
public interface ValueProvider<T> { func current(): ?T }
