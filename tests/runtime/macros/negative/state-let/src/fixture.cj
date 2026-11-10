package runtime_macro_state_let

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Bad {
    @State let value: Int64 = 1
    public func build(): Unit { Text("bad") }
}
