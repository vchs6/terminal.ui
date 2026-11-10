package theme_loading_contract
import cjtui.*
class TrackedPanel <: Component {
    let textState:Observable<String>
    var builds:Int64=0
    var getters:Int64=0
    var widths:Int64=0
    var mounts:Int64=0
    var cleanups:Int64=0
    var body:?Component=None
    init(state:Observable<String>){textState=state;finishConstruction()}
    public override func build():Unit {
        builds++
        body=Some(Text({=>getters++;textState.get()}).width({=>widths++;5}).styles([StyleUse.Named("keep")]))
        Text("Q").styles([StyleUse.Named("keep")])
    }
}
