package theme_loading_contract
import cjtui.*
class ReentrantPanel <: Component {
    let action:()->Unit
    init(action:()->Unit){this.action=action;finishConstruction()}
    public override func build():Unit {action();Text("not reached")}
}
