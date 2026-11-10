package reactive_example

import cjtui
import cjtui.*
import cjtui.macros.*

@Component
class Counter {
    @State var count: Int64 = 0
    public func build(): Unit {
        Column {
            Text(@Bind("Count: ${count}"))
            Text("Press any key to increment; Ctrl-C exits.")
        }
    }
}

main(): Int64 {
    let counter = Counter()
    Application(counter).onKey({ _ => counter.count++ }).run()
    0
}
