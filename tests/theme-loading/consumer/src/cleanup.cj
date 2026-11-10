package theme_loading_contract
import cjtui.*
func cleanupFailureStillClosesPendingRequests(env:TestEnvironment):Unit {
    let armed=Box<Bool>(true)
    let cleaned=Box<Int64>(0)
    let root=Column {Text("x").onMount({_=>{=>cleaned.value++;if(armed.value){throw Exception("CHILD_CLEANUP")}}})}
        .onMount({_=>{=>cleaned.value++;if(armed.value){throw Exception("PARENT_CLEANUP")}}})
    let app=Application(root,theme:prepared("A","red"));app.startHeadless()
    let oldRef=reference(root)
    let old=app.loadTheme(ThemeSource.File(env.path("gate-old.toml")))
    env.entered("gate-old.toml")
    let pending=app.loadTheme(ThemeSource.Prepared(prepared("Cancelled","blue")))
    superseded(old,pending.id)
    var aggregated=false
    try{app.dispose()}catch(error:UICleanupException){
        aggregated=error.primary.message=="CHILD_CLEANUP" && error.cleanupFailures.size==1 && error.cleanupFailures[0].message=="PARENT_CLEANUP"
    }
    check(aggregated && cleaned.value==2,"R017 aggregates every cleanup while loader closes")
    check(resultTag(pending)=="closed","dispose terminates newest pending request despite cleanup exceptions")
    superseded(old,pending.id);unchanged(app,"A",0,0)
    check(!oldRef.isValid() && !app.post({=>throw Exception("disposed post ran")}),"cleanup failure still revokes session capabilities")
    let released=app.stats()
    check(released.mountedNodes==0 && released.activeBindings==0 && released.subscriptions==0 && released.pendingPosts==0,"dispose releases existing runtime resources")
    armed.value=false
    app.startHeadless()
    try {
        check(!oldRef.sameNode(reference(root)),"new session generation differs after failed cleanup")
        let next=app.loadTheme(ThemeSource.Prepared(prepared("NewSession","green")))
        check(next.id>pending.id,"request ids survive cleanup failure and restart")
        env.release("gate-old.toml")
        pump(app,next,env);applied(next,1)
        unchanged(app,"NewSession",1,next.id)
        superseded(old,pending.id);check(resultTag(pending)=="closed","old worker completion cannot alter historical terminals")
    } finally {app.dispose()}
    check(cleaned.value==4,"each generation cleans exactly once")
}
