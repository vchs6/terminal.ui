import audit_macros.*

@Component
class Counter {
    public var reads: Int64 = 0
    public var writes: Int64 = 0
    @State var count: Int64 = 1
    public func build(): String { "value=${count}" }
}

main(): Int64 {
    let counter = Counter()
    let first = counter.build()
    let binding = @Bind(counter.build())
    counter.count = 9
    if (first != "value=1" || binding() != "value=9" || counter.reads != 2 || counter.writes != 1 ||
        counter.generatedMarker() != "macro-component") { return 1 }
    println("PASS SDK1.2 nested class/member macros, generated getter/setter observation hooks, expression closure binding")
    println("LIMIT hooks are counters only; no dependency graph, scheduler, node identity or product syntax contract")
    return 0
}
