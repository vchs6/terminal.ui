package runtime_macro_state_private

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Bad {
    @State private var hidden: Int64 = 1
    public func build(): Unit { Text(@Bind("${hidden}")) }
}
