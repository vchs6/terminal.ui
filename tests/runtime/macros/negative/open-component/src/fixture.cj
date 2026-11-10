package runtime_macro_open_component

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
open class Bad { public func build(): Unit { Text("bad") } }
