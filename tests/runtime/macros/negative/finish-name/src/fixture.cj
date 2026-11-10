package runtime_macro_finish_name

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Bad {
    func finishConstruction(): Unit {}
    public func build(): Unit { Text("bad") }
}
