package runtime_macro_state_duplicate

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Bad {
    @State @State var value: Int64 = 1
    public func build(): Unit { Text("bad") }
}
