import std.collection.ArrayList

let attached = ArrayList<AuditBase>()
func attach(component: AuditBase): Unit { attached.add(component) }

public open class AuditBase {
    public init() { attach(this) }
    public open func build(): String { "base" }
}

main(): Unit {}
