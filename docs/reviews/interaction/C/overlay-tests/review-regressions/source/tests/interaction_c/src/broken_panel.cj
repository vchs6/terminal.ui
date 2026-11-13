package interaction_c
import cjtui.*
class BrokenPanel <: Component {
    let failure:Exception
    init(failure:Exception){this.failure=failure;finishConstruction()}
    public override func build():Unit {throw failure}
}
