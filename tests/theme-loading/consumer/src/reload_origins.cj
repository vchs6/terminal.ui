package theme_loading_contract
import cjtui.*
func reloadUsesAcceptedFrozenOrigin(env:TestEnvironment):Unit {
    let app=Application(Text("x"),theme:Theme.readFile(env.path("live.toml")));app.startHeadless()
    try {
        unchanged(app,"FileA",0,0)
        env.write("live.toml","FileB")
        for(_ in 0..3){app.snapshot(12,5)}
        unchanged(app,"FileA",0,0)
        let loaded=app.reloadTheme();pump(app,loaded,env);applied(loaded,1)
        unchanged(app,"FileB",1,loaded.id)
        check(fileOrigin(app.themeInfo())==env.path("live.toml"),"Prepared(readFile) retains frozen File origin")
        let bad=app.loadTheme(ThemeSource.File(env.path("missing.toml")))
        pump(app,bad,env);failed(bad,"ReadFailed")
        unchanged(app,"FileB",1,loaded.id)
        env.write("live.toml","FileC")
        let pending=app.loadTheme(ThemeSource.File(env.path("gate-other.toml")))
        env.entered("gate-other.toml")
        let reload=app.reloadTheme()
        superseded(pending,reload.id)
        env.release("gate-other.toml")
        pump(app,reload,env);applied(reload,2)
        unchanged(app,"FileC",2,reload.id)
        check(fileOrigin(app.themeInfo())==env.path("live.toml"),"reload captures accepted source, not in-flight/failed File request")
        let preset=app.loadTheme(ThemeSource.Preset(ThemePreset.Dark))
        pump(app,preset,env);applied(preset,3)
        let noFile=app.reloadTheme();pump(app,noFile,env);failed(noFile,"NoFileSource")
        unchanged(app,"Dark",3,preset.id)
        let memory=app.loadTheme(ThemeSource.Prepared(prepared("Memory","cyan")))
        pump(app,memory,env);applied(memory,4)
        let noMemoryFile=app.reloadTheme();pump(app,noMemoryFile,env);failed(noMemoryFile,"NoFileSource")
        unchanged(app,"Memory",4,memory.id)
        let preparedFile=app.loadTheme(ThemeSource.Prepared(Theme.readFile(env.path("live.toml"))))
        pump(app,preparedFile,env);applied(preparedFile,5)
        env.write("live.toml","FileD")
        let restored=app.reloadTheme();pump(app,restored,env);applied(restored,6)
        unchanged(app,"FileD",6,restored.id)
        failed(bad,"ReadFailed");applied(preset,3)
    } finally {app.dispose()}
}
func relativeOriginFreezesAtRequest(env:TestEnvironment):Unit {
    let app=Application(Text("x"),theme:prepared("A","red"));app.startHeadless()
    try {
        let blocker=app.loadTheme(ThemeSource.File(env.path("gate-old.toml")))
        env.entered("gate-old.toml")
        changeDirectory(env.path("a"))
        let relative=app.loadTheme(ThemeSource.File("theme.toml"))
        superseded(blocker,relative.id)
        changeDirectory(env.path("b"))
        env.release("gate-old.toml")
        pump(app,relative,env);applied(relative,1)
        unchanged(app,"OriginA",1,relative.id)
        check(fileOrigin(app.themeInfo())==env.path("a/theme.toml"),"relative File source freezes accepting cwd before delayed I/O")
        env.write("a/theme.toml","OriginA2")
        let reload=app.reloadTheme();pump(app,reload,env);applied(reload,2)
        unchanged(app,"OriginA2",2,reload.id)
        check(fileOrigin(app.themeInfo())==env.path("a/theme.toml"),"reload ignores later cwd and reopens frozen absolute source")
    } finally {app.dispose();changeDirectory(env.root)}
}
