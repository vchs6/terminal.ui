package auditbase

import std.collection.ArrayList

let attached = ArrayList<AuditBase>()
func attach(component: AuditBase): Unit { attached.add(component) }
public func attachedCount(): Int64 { attached.size }
public func buildFirst(): String { attached[0].build() }

public open class AuditBase {
    public init() {}
    protected func finishConstruction(): Unit { attach(this) }
    public open func build(): String { "base" }
}

public class AuditState<T> {
    private var value: T
    public init(initial: T) { value = initial }
    public func get(): T { value }
    public func set(next: T): Unit { value = next }
}
