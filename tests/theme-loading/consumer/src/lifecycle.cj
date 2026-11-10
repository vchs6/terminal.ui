package theme_loading_contract
import cjtui.*
func inactiveAndRestart(env:TestEnvironment):Unit {
    let node=Text("x")
    let app=Application(node,theme:prepared("A","red"))
    unchanged(app,"A",0,0)
    let closed=app.loadTheme(ThemeSource.File(env.path("gate-inactive.toml")))
    check(resultTag(closed)=="closed","inactive load returns SessionClosed without file I/O")
    let noReload=app.reloadTheme()
    check(resultTag(noReload)=="closed" && noReload.id>closed.id,"inactive reload has a later application request id")
    app.startHeadless()
    let old=reference(node)
    let first=app.loadTheme(ThemeSource.Prepared(prepared("B","blue")))
    check(first.id>noReload.id,"request ids do not restart at session start")
    pump(app,first,env);applied(first,1)
    unchanged(app,"B",1,first.id)
    let background=spawn {resultTag(first)+"/"+app.themeInfo().name}
    check(background.get(Duration.second*5)=="applied:1/B","background read-only result/info queries need no UI turn")
    app.dispose()
    check(!old.isValid(),"dispose invalidates old node generation")
    unchanged(app,"B",1,first.id);applied(first,1)
    check(resultTag(closed)=="closed","old inactive result is immutable")
    let after=app.loadTheme(ThemeSource.Preset(ThemePreset.Dark))
    check(resultTag(after)=="closed" && after.id>first.id,"closed session rejects load with fresh id")
    app.startHeadless()
    try {
        check(!old.sameNode(reference(node)),"restart creates a different node generation")
        unchanged(app,"B",1,first.id)
        let next=app.loadTheme(ThemeSource.Prepared(prepared("C","green")))
        pump(app,next,env);applied(next,2)
        check(next.id>after.id,"application request sequence survives restart")
    } finally {app.dispose()}
}
