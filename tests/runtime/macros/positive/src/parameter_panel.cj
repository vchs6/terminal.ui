package runtime_macro_positive

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class ParameterPanel {
    private let label: String
    private let ordinary: Int64
    @State private var count: Int64 = 0
    var builds: Int64 = 0
    init(label: String, initial: Int64, fail: Bool) {
        if (fail) { throw Exception("CTOR_SENTINEL") }
        this.label = label
        ordinary = initial
        count = initial + 1
    }
    public func build(): Unit { builds++; Text(@Bind("${label}:${ordinary}:${count}")) }
    func increment(): Unit { count++ }
}
