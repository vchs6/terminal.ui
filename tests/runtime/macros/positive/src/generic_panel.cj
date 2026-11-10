package runtime_macro_positive

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class GenericPanel<T> <: Named & Provider<T> {
    private let label: String
    @State private var selected: ?T = Option<T>.None
    @State public var count: Int64 = 1
    var builds: Int64 = 0
    init(label: String, initial: T) {
        this.label = label
        selected = Some(initial)
        count = 4
    }
    public func build(): Unit { builds++; Text(@Bind("${label}:${count}")) }
    public func name(): String { label }
    public func current(): ?T { selected }
    public func select(value: T): Unit { selected = Some(value) }
}
