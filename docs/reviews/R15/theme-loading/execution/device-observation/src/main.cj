package theme_device_observation
import cjtui.*
import std.env.*
import std.fs.File
foreign func cjt_test_arm(mode: Int32, offset: Int64, sequence: Int32): Unit
main(): Int64 {
    let directory=getVariable("TASK091_DEVICE_DIR").getOrThrow()
    let app=Application(Text("TASK091_BASE"),colorMode:ColorMode.Basic16,
        theme:Theme.parse("schema_version=1\nname=\"Before\"\n[text]\nforeground=\"red\"\n"))
    let requests=Array<?ThemeRequest>(1,repeat:Option<ThemeRequest>.None)
    app.onKey { event =>
        if(event.text=="t") {
            // Existing test-process syscall fixture; no product test hook.
            unsafe {cjt_test_arm(1,4,1)}
            let request=app.loadTheme(ThemeSource.Prepared(Theme.parse("schema_version=1\nname=\"Accepted\"\n[text]\nforeground=\"blue\"\n")))
            requests[0]=Some(request)
            File.writeTo(directory+"/requested",request.id.toString().toArray())
        }
    }
    var failure=""
    try {app.run()} catch(error:Exception) {failure=error.message}
    let request=requests[0].getOrThrow()
    let info=app.themeInfo()
    let applied=match(request.result()) {
        case Some(ThemeResult.Applied(value)) => value
        case _ => throw Exception("device failure changed accepted request terminal result")
    }
    let stats=app.stats()
    let report="failure=${failure}\nname=${info.name}\nrevision=${info.revision}\nrequestId=${info.requestId}\nid=${request.id}\napplied=${applied}\nmounted=${stats.mountedNodes}\nbindings=${stats.activeBindings}\nsubscriptions=${stats.subscriptions}\nposts=${stats.pendingPosts}\n"
    File.writeTo(directory+"/after.txt",report.toArray())
    if(failure.isEmpty() || info.name!="Accepted" || info.revision!=1 || info.requestId!=request.id || applied!=1) {throw Exception("T008 accepted history/output failure mismatch")}
    if(stats.mountedNodes!=0 || stats.activeBindings!=0 || stats.subscriptions!=0 || stats.pendingPosts!=0) {throw Exception("device failure leaked runtime resources")}
    0
}
