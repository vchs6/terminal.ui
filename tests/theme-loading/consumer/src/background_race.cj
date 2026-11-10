package theme_loading_contract
import cjtui.*
func backgroundRequestsHaveOneTotalOrder(env:TestEnvironment):Unit {
    let app=Application(Text("x"),theme:prepared("A","red"));app.startHeadless()
    try {
        let blocked=app.loadTheme(ThemeSource.File(env.path("gate-old.toml")))
        env.entered("gate-old.toml")
        let gate=Gate()
        let themes=Array<Theme>(8,{i=>prepared("Concurrent${i}","blue")})
        let workers=Array<Future<ThemeRequest>>(8,{i=>spawn{gate.awaitOpen();app.loadTheme(ThemeSource.Prepared(themes[i]))}})
        gate.release()
        let requests=Array<ThemeRequest>(8,{i=>workers[i].get(Duration.second*5)})
        var first:UInt64=requests[0].id
        var last:UInt64=requests[0].id
        var winner:Int64=0
        for(i in 0..8){
            if(requests[i].id<first){first=requests[i].id}
            if(requests[i].id>last){last=requests[i].id;winner=i}
            for(j in 0..i){check(requests[i].id!=requests[j].id,"concurrent request ids are unique")}
        }
        superseded(blocked,first)
        for(request in requests){
            if(request.id!=last){
                match(request.result()){
                    case Some(ThemeResult.Superseded(next))=>check(next>request.id && next<=last,"concurrent replacement respects total request order")
                    case _=>throw Exception("non-winning request was not immediately superseded")
                }
            }
        }
        unchanged(app,"A",0,0)
        env.release("gate-old.toml")
        pump(app,requests[winner],env);applied(requests[winner],1)
        unchanged(app,"Concurrent${winner}",1,last)
        superseded(blocked,first)
    } finally {app.dispose()}
}
