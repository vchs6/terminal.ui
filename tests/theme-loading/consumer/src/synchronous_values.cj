package theme_loading_contract
import cjtui.*
func synchronousValuesDoNotMutateApplication(env:TestEnvironment):Unit {
    let app=Application(Text("x"),theme:prepared("A","red"));app.startHeadless()
    try {
        let memory=Theme.parse("schema_version=1\nname=\"Memory\"\n",sourceName:env.path("live.toml"))
        let file=Theme.readFile(env.path("live.toml"))
        check(memory.sourcePath.isNone() && file.sourcePath==Some(env.path("live.toml")),"parse display source does not become a File origin")
        unchanged(app,"A",0,0)
        check(app.snapshot(1,1).cellAt(0,0).style.foreground==Color.Red,"synchronous parse/readFile do not affect active pixels")
        let request=app.loadTheme(ThemeSource.Prepared(memory))
        pump(app,request,env);applied(request,1)
        let reload=app.reloadTheme();pump(app,reload,env);failed(reload,"NoFileSource")
        unchanged(app,"Memory",1,request.id)
    } finally {app.dispose()}
}
