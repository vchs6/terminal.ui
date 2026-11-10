package runtime_macro_abstract_component

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
abstract class Bad { public func build(): Unit { Text("bad") } }
