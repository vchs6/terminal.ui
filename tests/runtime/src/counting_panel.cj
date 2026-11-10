package runtime_contract

import cjtui.*

class CountingPanel <: Component {
    let value: Observable<String>
    var builds: Int64 = 0
    init(value: Observable<String>) {
        this.value = value
        finishConstruction()
    }
    public override func build(): Unit {
        builds++
        Text({ => value.get() })
        Text("tail")
    }
}
