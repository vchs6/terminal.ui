import audit_component_macros.*
import auditsupplement.*

@Component
class Configured {
    let label: String
    var ordinary: Int64
    @State var count: Int64 = 1
    public var builds: Int64 = 0
    public init(label: String, initial: Int64, fail: Bool) {
        if (fail) { throw Exception("requested failure") }
        this.label = label
        ordinary = initial
        count = initial + 1
    }
    public func build(): Unit { builds++ }
    public func description(): String { "${label}:${ordinary}:${count}" }
}

@Component
class GenericCounter<T> <: Named & ValueProvider<T> {
    let label: String
    @State var selected: ?T = None
    public var builds: Int64 = 0
    public init(label: String) { this.label = label }
    public func build(): Unit { builds++ }
    public func name(): String { label }
    public func current(): ?T { selected }
}

main(): Int64 {
    let configured = Configured("first", 4, false)
    if (attachedCount() != 1 || configured.builds != 0 || configured.description() != "first:4:5") { return 1 }
    var failed = false
    try { Configured("fail", 8, true) } catch (_: Exception) { failed = true }
    if (!failed || attachedCount() != 1) { return 2 }
    invokeBuild(0)
    if (configured.builds != 1) { return 3 }

    let generic = GenericCounter<Int64>("generic")
    if (attachedCount() != 2 || generic.builds != 0 || generic.name() != "generic") { return 4 }
    generic.selected = Some(42)
    let binding = @Bind(generic.selected)
    if (binding() != Some(42)) { return 5 }
    let named: Named = generic
    let provider: ValueProvider<Int64> = generic
    if (named.name() != "generic" || provider.current() != Some(42)) { return 6 }
    invokeBuild(1)
    if (generic.builds != 1 || attachedCount() != 2) { return 7 }
    println("PASS explicit parameter init preserves ordinary assignments and State setter; success attaches once, throw attaches zero, build deferred")
    println("PASS generic @Component class<T> preserves two interface declarations; generic State<Option<T>> getter/setter and Bind closure")
    return 0
}
