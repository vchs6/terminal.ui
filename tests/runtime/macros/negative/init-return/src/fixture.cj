package runtime_macro_init_return

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Bad {
    init(early: Bool) { if (early) { return } }
    public func build(): Unit { Text("bad") }
}
