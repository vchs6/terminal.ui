package interaction_a_contract
import cjtui.*
func readonlyQueries(): Unit {
    let rootBox=Box<?Component>(Option<Component>.None); let appBox=Box<?Application>(Option<Application>.None); let reads=Box<Int64>(0)
    let labelFactory={=>Text({=>
        if(let Some(root)<-rootBox.value){ if(let Some(r)<-root.reference()){
            reads.value++; r.isFocused(); r.isEnabled(); r.isVisible(); r.application().focusedNode(); r.application().activeTarget()
        } }
        if(let Some(root)<-rootBox.value){ if(let Some(r)<-root.reference()){
            return if(r.isFocused()) { "F" } else { "N" }
        } }
        "N"
    }) }
    let (root,_)=group([labelFactory]); root.focusable(true); rootBox.value=Some(root)
    let app=Application(root,theme:plainTheme()); appBox.value=Some(app); app.startHeadless(); check(app.snapshot(1,1).toPlainText()=="F","initial focus updates readonly getter before returning")
    check(app.terminalCapabilities().isNone(),"first headless has no device capabilities")
    check(reads.value>0 && ref(root).application().focusedNode().getOrThrow().sameNode(ref(root)),"getter reference and readonly application service")
    let before=app.stats().frames; app.focusedNode(); app.activeTarget(); app.caretSnapshot(); ref(root).isFocused(); ref(root).application()
    check(app.stats().frames==before,"readonly queries do not pump")
    let saved=ref(root)
    let worker=spawn { code("WrongUIContext",{=>root.reference();()}); code("WrongUIContext",{=>saved.isFocused();()}); code("WrongUIContext",{=>app.focusedNode();()}); saved.isValid() && saved.sameNode(saved) }
    check(worker.get(Duration.second*5),"saved NodeRef isValid/sameNode remain thread safe")
    let otherRoot=Text("other").focusable(true); let other=Application(otherRoot,theme:plainTheme()); other.startHeadless()
    app.batch({=>
        code("WrongUIContext",{=>ref(otherRoot).isVisible();()}); code("WrongUIContext",{=>other.focusedNode();()})
        code("WrongUIContext",{=>ref(otherRoot).application();()})
    })
    other.dispose(); app.dispose()
    // A root getter must not bypass the read guard, including Component.reference.
    let secondRoot=Text("other"); let second=Application(secondRoot,theme:plainTheme()); second.startHeadless()
    code("WrongUIContext",{=>Application(Text({=>secondRoot.reference();"x"}),theme:plainTheme()).startHeadless()})
    second.dispose()
    // Acquiring Application never grants write permission from getter.
    let selfBox=Box<?Component>(Option<Component>.None)
    let bad=Text({=> if(let Some(c)<-selfBox.value){ if(let Some(r)<-c.reference()) { r.application().batch({=>}) } }; "x" })
    selfBox.value=Some(bad)
    let badApp=Application(bad,theme:plainTheme());
    code("ReentrantEvaluation",{=>badApp.startHeadless(); badApp.snapshot(1,1);()}); empty(badApp)
}
