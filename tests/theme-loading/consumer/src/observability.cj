package theme_loading_contract
import cjtui.*
func resultAndInfoAreObservable(env:TestEnvironment):Unit {
    let appBox=Box<?Application>(Option<Application>.None)
    let current=Box<?ThemeRequest>(Option<ThemeRequest>.None)
    let calls=Box<Int64>(0)
    let owner=Thread.currentThread.id
    let node=Text({=>
        check(Thread.currentThread.id==owner,"observable theme query reevaluates only on UI owner")
        calls.value++
        let revision=appBox.value.getOrThrow().themeInfo().revision
        let result=match(current.value){case Some(request)=>resultTag(request);case None=>"none"}
        "${revision}|"+result
    })
    let app=Application(node,theme:prepared("A","red"));appBox.value=Some(app);app.startHeadless()
    try {
        let request=app.loadTheme(ThemeSource.File(env.path("gate-observe.toml")))
        env.entered("gate-observe.toml")
        current.value=Some(request);reference(node).notify(ChangeKind.Content)
        check(app.snapshot(40,1).toPlainText().startsWith("0|pending"),"binding observes pending result without driving it")
        let before=calls.value
        let background=spawn{resultTag(request)+"/"+app.themeInfo().name}
        check(background.get(Duration.second*5)=="pending/A","background queries return before UI commit or file completion")
        check(calls.value==before,"background queries execute no UI getter")
        env.release("gate-observe.toml")
        pump(app,request,env);applied(request,1)
        let observed=app.snapshot(40,1).toPlainText()
        check(observed.startsWith("1|applied:1") && calls.value>before,"result and ThemeInfo notify existing typed binding automatically")
    } finally {app.dispose()}
    backgroundQueriesDoNotSubscribe(env)
}
func backgroundQueriesDoNotSubscribe(env:TestEnvironment):Unit {
    let other=Application(Text("x"),theme:prepared("A","red"));other.startHeadless()
    let request=other.loadTheme(ThemeSource.File(env.path("gate-background.toml")))
    env.entered("gate-background.toml")
    let calls=Box<Int64>(0)
    let watcher=Application(Text({=>calls.value++;let work=spawn{other.themeInfo().name+"/"+resultTag(request)};work.get(Duration.second*5)}))
    watcher.startHeadless()
    try {
        check(watcher.snapshot(20,1).toPlainText().startsWith("A/pending"),"background values may be consumed as ordinary snapshots")
        let before=calls.value
        check(watcher.stats().subscriptions==0,"background read does not join UI binding dependency collection")
        env.release("gate-background.toml")
        pump(other,request,env);applied(request,1)
        check(watcher.snapshot(20,1).toPlainText().startsWith("A/pending") && calls.value==before,"later background-source changes do not invalidate unrelated UI binding")
    } finally {watcher.dispose();other.dispose()}
}
