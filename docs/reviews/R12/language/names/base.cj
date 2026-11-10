package auditnames

public open class Component {
    public init() {}
    public open func build(): String { "library-base" }
}

public class Observable<T> {
    private var value: T
    public init(initial: T) { value = initial }
    public func get(): T { value }
    public func set(next: T): Unit { value = next }
}
