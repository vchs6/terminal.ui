package runtime_contract

import cjtui.*

class BrokenPanel <: Component {
    var attempts: Int64 = 0
    init() { finishConstruction() }
    public override func build(): Unit {
        attempts++
        Column { Text("discard"); throw Exception("BUILD_SENTINEL") }
    }
}
