package runtime_macro_positive

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class DefaultPanel {
    @State public var count: Int64 = 2
    var builds: Int64 = 0
    public func build(): Unit { builds++; Text(@Bind("n=${count}")) }
}
