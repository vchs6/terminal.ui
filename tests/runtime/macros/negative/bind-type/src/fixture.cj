package runtime_macro_bind_type

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Bad { public func build(): Unit { Text(@Bind(1)) } }
