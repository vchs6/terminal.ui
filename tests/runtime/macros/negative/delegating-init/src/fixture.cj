package runtime_macro_delegating_init

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Bad {
    let value: Int64
    init() { this(1) }
    init(value: Int64) { this.value = value }
    public func build(): Unit { Text("bad") }
}
