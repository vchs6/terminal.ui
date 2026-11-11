package interaction_a_contract
import cjtui.*
import std.fs.File
// Public-only failure observations, also compiled against current real upstream
// by the prerequisite consumer. No Canvas/focus declarations or substitute API.
func deviceRecordFailure(app:Application,directory:String,error:Exception):Unit {
    File.writeTo(directory+"/error",error.message.toArray())
    var primary=error.message
    var extras=""
    if(let Some(aggregate)<-(error as UICleanupException)) {
        primary=aggregate.primary.message
        for(item in aggregate.cleanupFailures){extras+=item.message+"\n"}
    }
    File.writeTo(directory+"/primary",primary.toArray())
    File.writeTo(directory+"/extras",extras.toArray())
    let s=app.stats()
    File.writeTo(directory+"/failure-resources","${s.mountedNodes}/${s.activeBindings}/${s.subscriptions}/${s.pendingPosts}".toArray())
}
func deviceUnsafeReopen(directory:String):Unit {
    let node=Text("UNEXPECTED_REOPEN")
    let next=Application(node)
    node.onMount({_=>next.post({=>next.stop()});{=>}})
    var refused=false
    var message=""
    try{next.run()}catch(error:Exception){refused=true;message=error.message}
    File.writeTo(directory+"/reopen","${refused}\n${message}".toArray())
    next.dispose()
}
