package theme_loading_contract
import cjtui.*
func applicationExceptionDoesNotRollbackAcceptedTheme(env:TestEnvironment):Unit {
    let node=Text("x").onKey({_=>throw Exception("USER_CALLBACK_AFTER_THEME")})
    let app=Application(node,theme:prepared("A","red"));app.startHeadless()
    let accepted=app.loadTheme(ThemeSource.Prepared(prepared("B","blue")))
    pump(app,accepted,env);applied(accepted,1)
    let oldRef=reference(node)
    var caught=false
    try{app.dispatch(oldRef,KeyEvent("text",text:"x"))}catch(error:Exception){caught=error.message=="USER_CALLBACK_AFTER_THEME"}
    check(caught && !oldRef.isValid(),"ordinary user callback error retains normal runtime failure cleanup")
    unchanged(app,"B",1,accepted.id);applied(accepted,1)
    check(!app.post({=>throw Exception("failed session post ran")}),"callback failure closes session")
    app.dispose()
}
