package theme_loading_contract
import cjtui.*
func oldSessionCannotCommitAfterRestart(env:TestEnvironment):Unit {
    let node=Text("x")
    let app=Application(node,theme:prepared("A","red"));app.startHeadless()
    let accepted=app.loadTheme(ThemeSource.Prepared(prepared("Accepted","blue")))
    pump(app,accepted,env);applied(accepted,1)
    let oldRef=reference(node)
    let old=app.loadTheme(ThemeSource.File(env.path("gate-old.toml")))
    env.entered("gate-old.toml")
    app.dispose()
    check(resultTag(old)=="closed","dispose closes an executing request before its real I/O returns")
    unchanged(app,"Accepted",1,accepted.id);applied(accepted,1)
    app.startHeadless()
    try {
        check(!oldRef.sameNode(reference(node)),"restarted session has a fresh node generation")
        unchanged(app,"Accepted",1,accepted.id)
        let fresh=app.loadTheme(ThemeSource.Prepared(prepared("Fresh","green")))
        check(fresh.id>old.id,"restart never reuses an application request id")
        env.release("gate-old.toml")
        let frame=pump(app,fresh,env);applied(fresh,2)
        unchanged(app,"Fresh",2,fresh.id)
        check(frame.cellAt(0,0).style.foreground==Color.Green,"old-session completion cannot paint over the new session")
        check(resultTag(old)=="closed","new-session request and old I/O cannot rewrite SessionClosed")
        applied(accepted,1)
    } finally {app.dispose()}
}
func uncommittedIntentClosesBeforeRestart(env:TestEnvironment):Unit {
    let app=Application(Text("x"),theme:prepared("A","red"));app.startHeadless()
    let queued=app.loadTheme(ThemeSource.Prepared(prepared("NeverAccepted","blue")))
    check(resultTag(queued)=="pending","prepared intent remains uncommitted outside a UI boundary")
    app.dispose()
    check(resultTag(queued)=="closed","dispose closes uncommitted intent")
    unchanged(app,"A",0,0)
    app.startHeadless()
    try {
        check(app.snapshot(1,1).cellAt(0,0).style.foreground==Color.Red,"old queued candidate cannot leak into restart")
        unchanged(app,"A",0,0)
        let next=app.loadTheme(ThemeSource.Preset(ThemePreset.Dark))
        check(next.id>queued.id,"queued intent id is not reused")
        pump(app,next,env);applied(next,1)
        check(resultTag(queued)=="closed","new commit preserves old queued terminal")
    } finally {app.dispose()}
}
