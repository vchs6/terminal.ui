package runtime_macro_positive

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class NestedReturnPanel {
    private let label: String
    init() {
        let calculate = { => return "nested" }
        label = calculate()
    }
    public func build(): Unit {
        let read = { => return label }
        Text(read())
    }
}
