package theme_loading_contract
import cjtui.*
func check(value:Bool,name:String):Unit {if(!value){throw Exception("FAIL: "+name)};println("PASS: "+name)}
func prepared(name:String,color:String):Theme {
    Theme.parse("schema_version=1\nname=\""+name+"\"\n[text]\nforeground=\""+color+"\"\nbackground=\"default\"\n")
}
func resultTag(request:ThemeRequest):String {
    match(request.result()) {
        case None => "pending"
        case Some(value) => match(value) {
            case ThemeResult.Applied(revision) => "applied:${revision}"
            case ThemeResult.Failed(diagnostic) => "failed:"+diagnostic.code
            case ThemeResult.Superseded(id) => "superseded:${id}"
            case ThemeResult.SessionClosed => "closed"
        }
    }
}
func applied(request:ThemeRequest,revision:UInt64):Unit {check(resultTag(request)=="applied:${revision}","Applied has exact committed revision")}
func superseded(request:ThemeRequest,replacement:UInt64):Unit {check(resultTag(request)=="superseded:${replacement}","Superseded records first replacing request id")}
func failed(request:ThemeRequest,code:String):Unit {check(resultTag(request)=="failed:"+code,"Failed diagnostic ${code}")}
func candidateFailure(request:ThemeRequest,alternative:String):Unit {
    let tag=resultTag(request)
    check(tag=="failed:InvalidCandidate" || tag=="failed:"+alternative, "candidate validation has contract-permitted diagnostic")
}
func pump(app:Application,request:ThemeRequest,env:TestEnvironment):Frame {
    for(_ in 0..20000) {
        let frame=app.snapshot(12,5)
        if(request.result().isSome()){return frame}
        // This I/O rendezvous yields control; completion is determined only by
        // the public terminal result, never by sleeping a chosen duration.
        env.sync("tick")
    }
    throw Exception("theme request made no progress; see parent-process deadline and raw trace")
}
func unchanged(app:Application,name:String,revision:UInt64,id:UInt64):Unit {
    let info=app.themeInfo()
    check(info.name==name && info.revision==revision && info.requestId==id,"accepted ThemeInfo remains ${name}/${revision}/${id}")
}
func fileOrigin(info:ThemeInfo):String {
    match(info.source) {
        case ThemeSource.File(path) => path
        case ThemeSource.Prepared(value) => value.sourcePath.getOrThrow()
        case _ => throw Exception("accepted source has no File origin")
    }
}
func reference(node:Component):NodeRef {node.reference().getOrThrow()}
