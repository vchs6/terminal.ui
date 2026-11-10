package theme_loading_contract
import cjtui.*
func loadingDuringGetterIsRejected(env:TestEnvironment):Unit {
    for(reload in [false,true]) {
        let appBox=Box<?Application>(Option<Application>.None)
        let root=Text({=>
            let app=appBox.value.getOrThrow()
            if(reload){app.reloadTheme()}else{app.loadTheme(ThemeSource.Prepared(prepared("Forbidden","blue")))}
            "not reached"
        })
        let app=Application(root,theme:prepared("A","red"));appBox.value=Some(app)
        var rejected=false
        try{app.startHeadless()}catch(error:UIException){rejected=error.code=="ReentrantEvaluation"}
        check(rejected,"typed getter cannot issue load/reload")
        unchanged(app,"A",0,0)
        check(root.reference().isNone() && !app.post({=>throw Exception("closed getter-failure session")}),"normal runtime failure cleanup still occurs")
        app.dispose()
    }
}
func loadingDuringBuildIsRejected(env:TestEnvironment):Unit {
    for(reload in [false,true]) {
        let holder=Box<?Application>(Option<Application>.None)
        let root=ReentrantPanel({=>
            let app=holder.value.getOrThrow()
            if(reload){app.reloadTheme()}else{app.loadTheme(ThemeSource.Prepared(prepared("Forbidden","blue")))}
        })
        let app=Application(root,theme:prepared("A","red"));holder.value=Some(app)
        var rejected=false
        try{app.startHeadless()}catch(error:UIException){rejected=error.code=="ReentrantEvaluation"}
        check(rejected,"structural build cannot issue load/reload")
        unchanged(app,"A",0,0)
        check(root.reference().isNone(),"failed structural evaluation releases nodes")
        app.dispose()
    }
}
