package runtime_macro_state_no_initial

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Bad {
    @State var value: Int64
    init() { value = 1 }
    public func build(): Unit { Text("bad") }
}
