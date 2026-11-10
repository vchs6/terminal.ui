package theme_loading_contract
import cjtui.*
func eventAndPostMayLoadTheme(env:TestEnvironment):Unit {
    let holder=Box<?Application>(Option<Application>.None)
    let current=Box<?ThemeRequest>(Option<ThemeRequest>.None)
    let node=Text("x").onKey({_=>current.value=Some(holder.value.getOrThrow().loadTheme(ThemeSource.Prepared(prepared("Event","blue"))))})
    let app=Application(node,theme:prepared("A","red"));holder.value=Some(app);app.startHeadless()
    try {
        let initial=app.themeInfo()
        app.dispatch(reference(node),KeyEvent("text",text:"x"))
        let event=current.value.getOrThrow();pump(app,event,env);applied(event,1)
        unchanged(app,"Event",1,event.id)
        check(initial.name=="A" && initial.revision==0 && initial.requestId==0,"earlier ThemeInfo is an immutable independent snapshot")
        check(app.post({=>current.value=Some(app.loadTheme(ThemeSource.Prepared(prepared("Post","green"))))}),"ordinary task callback can request load")
        app.snapshot(12,5)
        let task=current.value.getOrThrow();check(task.id>event.id,"post issued a separate request")
        pump(app,task,env);applied(task,2)
        unchanged(app,"Post",2,task.id);applied(event,1)
    } finally {app.dispose()}
}
