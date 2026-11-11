package node_reference_regression
import std.runtime.{gc,getGCCount}
func awaitPublicCollection():Bool {
    let before=getGCCount();gc(heavy:true)
    for(_ in 0..500){
        let after=getGCCount()
        if(after>before){println("GC progress before=${before} after=${after}");return true}
        sleep(Duration.millisecond)
    }
    return false
}
