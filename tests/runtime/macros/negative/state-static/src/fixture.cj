package runtime_macro_state_static

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Bad {
    @State static var value: Int64 = 1
    public func build(): Unit { Text("bad") }
}
