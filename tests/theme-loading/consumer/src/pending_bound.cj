package theme_loading_contract
import cjtui.*
import std.collection.ArrayList
func onlyLatestPendingFileIsRead(env:TestEnvironment):Unit {
    let app=Application(Text("x"),theme:prepared("A","red"));app.startHeadless()
    try {
        let old=app.loadTheme(ThemeSource.File(env.path("gate-old.toml")))
        env.entered("gate-old.toml")
        let requests=ArrayList<ThemeRequest>()
        for(i in 0..32){requests.add(app.loadTheme(ThemeSource.File(env.path("gate-pending-${i}.toml"))))}
        superseded(old,requests[0].id)
        for(i in 0..31){superseded(requests[i],requests[i+1].id)}
        unchanged(app,"A",0,0)
        env.release("gate-old.toml")
        env.entered("gate-pending-31.toml")
        // The test process rejects every actual intermediate read and records
        // overlapping gate entries; structural capacity still belongs to review.
        env.release("gate-pending-31.toml")
        pump(app,requests[31],env);applied(requests[31],1)
        unchanged(app,"P31",1,requests[31].id)
        for(i in 0..31){superseded(requests[i],requests[i+1].id)}
    } finally {app.dispose()}
}
func commitMailboxSurvivesFullPostQueue(env:TestEnvironment):Unit {
    let effects=Box<Int64>(0)
    let app=Application(Text("x"),theme:prepared("A","red"),limits:RuntimeLimits(pendingPosts:1));app.startHeadless()
    try {
        check(app.post({=>effects.value++}),"ordinary post queue is filled")
        check(!app.post({=>throw Exception("overflow post ran")}),"second ordinary post is rejected at capacity")
        let request=app.loadTheme(ThemeSource.Prepared(prepared("B","blue")))
        pump(app,request,env);applied(request,1)
        check(effects.value==1,"accepted ordinary post executes once")
        unchanged(app,"B",1,request.id)
    } finally {app.dispose()}
}
