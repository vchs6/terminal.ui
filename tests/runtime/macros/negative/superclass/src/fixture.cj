package runtime_macro_superclass

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Bad <: Base { public func build(): Unit { Text("bad") } }
