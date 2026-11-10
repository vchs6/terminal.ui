package runtime_contract

import cjtui.*

class DoubleFinish <: Component {
    init() { finishConstruction(); finishConstruction() }
}
