package runtime_macro_state_no_type

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Bad {
    @State var value = 1
    public func build(): Unit { Text("bad") }
}
