package theme_loading_contract
import cjtui.*
func latestSuccessfulRequest(env:TestEnvironment):Unit {
    let app=Application(Text("x"),theme:prepared("A","red"));app.startHeadless()
    try {
        let slow=app.loadTheme(ThemeSource.File(env.path("gate-old.toml")))
        env.entered("gate-old.toml")
        let second=app.loadTheme(ThemeSource.Prepared(prepared("B","blue")))
        superseded(slow,second.id)
        let last=app.loadTheme(ThemeSource.Prepared(prepared("C","green")))
        superseded(second,last.id);superseded(slow,second.id)
        unchanged(app,"A",0,0)
        env.release("gate-old.toml")
        let frame=pump(app,last,env);applied(last,1)
        unchanged(app,"C",1,last.id)
        check(frame.cellAt(0,0).style.foreground==Color.Green,"latest prepared request owns final pixels")
        let fence=app.loadTheme(ThemeSource.File(env.path("gate-fence.toml")))
        env.entered("gate-fence.toml")
        unchanged(app,"C",1,last.id)
        check(app.snapshot(1,1).cellAt(0,0).style.foreground==Color.Green,"old read cannot commit while newer file intent is pending")
        env.release("gate-fence.toml")
        pump(app,fence,env);applied(fence,2)
        superseded(slow,second.id);superseded(second,last.id);applied(last,1)
    } finally {app.dispose()}
}
func latestFailureDoesNotReviveOld(env:TestEnvironment):Unit {
    let app=Application(Text("x"),theme:prepared("A","red"));app.startHeadless()
    try {
        let old=app.loadTheme(ThemeSource.File(env.path("gate-old.toml")))
        env.entered("gate-old.toml")
        let latest=app.loadTheme(ThemeSource.File(env.path("invalid.toml")))
        superseded(old,latest.id)
        env.release("gate-old.toml")
        let frame=pump(app,latest,env)
        failed(latest,"InvalidType");superseded(old,latest.id)
        unchanged(app,"A",0,0)
        check(frame.cellAt(0,0).style.foreground==Color.Red,"latest failure retains accepted theme; old legal intent never revives")
        let good=app.loadTheme(ThemeSource.Prepared(prepared("Recovery","blue")))
        pump(app,good,env);applied(good,1)
        check(sessionStillRenders(app),"recoverable failure leaves session active")
        let pending=app.loadTheme(ThemeSource.File(env.path("gate-fence.toml")))
        env.entered("gate-fence.toml")
        let noFile=app.reloadTheme()
        superseded(pending,noFile.id)
        env.release("gate-fence.toml")
        pump(app,noFile,env);failed(noFile,"NoFileSource")
        unchanged(app,"Recovery",1,good.id)
        superseded(pending,noFile.id);applied(good,1)
    } finally {app.dispose()}
}
func sessionStillRenders(app:Application):Bool {app.snapshot(1,1).cellAt(0,0).grapheme=="x"}

func newestIntentWinsBeforeAnyUiTurn(env:TestEnvironment):Unit {
    let app=Application(Text("x"),theme:prepared("A","red"));app.startHeadless()
    try {
        let first=app.loadTheme(ThemeSource.Prepared(prepared("B","blue")))
        for(_ in 0..32){check(resultTag(first)=="pending","query alone does not commit a prepared intent");unchanged(app,"A",0,0)}
        let second=app.loadTheme(ThemeSource.Prepared(prepared("C","green")))
        let last=app.loadTheme(ThemeSource.Prepared(prepared("D","cyan")))
        superseded(first,second.id);superseded(second,last.id)
        unchanged(app,"A",0,0)
        let frame=pump(app,last,env);applied(last,1)
        unchanged(app,"D",1,last.id)
        check(frame.cellAt(0,0).style.foreground==Color.Cyan,"one UI turn can only commit current requested intent")
        superseded(first,second.id);superseded(second,last.id)
    } finally {app.dispose()}
}
