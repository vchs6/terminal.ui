package runtime_macro_finish_call

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Bad {
    init() { finishConstruction() }
    public func build(): Unit { Text("bad") }
}
