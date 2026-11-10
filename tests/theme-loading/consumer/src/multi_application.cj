package theme_loading_contract
import cjtui.*
func applicationsHaveIndependentLoaders(env:TestEnvironment):Unit {
    let shared=prepared("Shared","red")
    let first=Application(Text("a"),theme:shared)
    let second=Application(Text("b"),theme:shared)
    first.startHeadless();second.startHeadless()
    try {
        let a=first.loadTheme(ThemeSource.File(env.path("gate-app-a.toml")))
        env.entered("gate-app-a.toml")
        let b=second.loadTheme(ThemeSource.File(env.path("gate-app-b.toml")))
        env.entered("gate-app-b.toml")
        check(a.id==1 && b.id==1,"request ids belong to each Application")
        env.release("gate-app-a.toml")
        env.release("gate-app-b.toml")
        pump(second,b,env);applied(b,1)
        unchanged(second,"AppB",1,b.id);unchanged(first,"Shared",0,0)
        pump(first,a,env);applied(a,1)
        unchanged(first,"AppA",1,a.id);unchanged(second,"AppB",1,b.id)
        check(shared.name=="Shared","shared immutable Theme does not share application mutation")
    } finally {first.dispose();second.dispose()}
}
