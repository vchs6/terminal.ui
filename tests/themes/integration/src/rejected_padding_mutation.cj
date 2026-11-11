package theme_integration_contract
import cjtui.*

func rejectedPaddingMutationCase(useGetter: Bool): Unit {
    let padding=Observable<Int64>(1)
    let trigger=Observable<Bool>(false)
    let rejected=Array<Bool>(1,repeat:false)
    let node=Text("X").padding({=>padding.get()})
    node.foreground({=>
        if(trigger.get()) {
            try {
                if(useGetter) { node.setStyle(StyleKeys.paddingLeft,{=>StyleValue<Int64>.Value(9)}) }
                else { node.setStyle(StyleKeys.paddingLeft,StyleValue<Int64>.Value(9)) }
            } catch(e:UIException) {
                if(e.code!="ReentrantEvaluation") { throw e }
                rejected[0]=true
            }
        }
        Color.Red
    })
    let app=Application(node)
    app.startHeadless()
    try {
        let initial=app.snapshot(7,7)
        check(initial.cellAt(1,1).grapheme=="X","uniform padding getter initially binds all sides")
        let mounted=app.stats().mountedNodes
        app.batch({=>trigger.set(true)})
        check(rejected[0],"getter setStyle overload ${useGetter} rejected with ReentrantEvaluation")
        app.batch({=>trigger.set(false)})
        app.batch({=>padding.set(2)})
        let frame=app.snapshot(7,7)
        println("OBSERVED padding getter-overload=${useGetter}: rejected=${rejected[0]}, X@2,2=[${frame.cellAt(2,2).grapheme}], X@1,2=[${frame.cellAt(1,2).grapheme}]")
        check(padding.get()==2,"original Observable retains the requested value")
        check(app.stats().mountedNodes==mounted,"rejected mutation preserves mounted nodes")
        check(frame.cellAt(2,2).grapheme=="X","both left and top uniform padding bindings survive rejected mutation")
        check(frame.cellAt(1,2).grapheme==" " && frame.cellAt(1,1).grapheme==" ","old positions are cleared")
    } finally { app.dispose() }
}
func rejectedPaddingMutations(): Unit {
    var failed: Int64=0
    for (useGetter in [false,true]) {
        try { rejectedPaddingMutationCase(useGetter);println("CASE PASS rejected padding overload ${useGetter}") }
        catch(e:Exception) { failed++;println("CASE FAIL rejected padding overload ${useGetter}: ${e.message}") }
    }
    check(failed==0,"rejected padding mutation regressions: ${failed} failed")
}
