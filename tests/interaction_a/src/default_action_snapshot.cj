package interaction_a_contract
import cjtui.*
func defaultActionSnapshot(): Unit {
    let current=Box<?Component>(Option<Component>.None);let trace=Box<String>("");let replace=Box<Bool>(true)
    let (root,nodes)=group([{=>
        let c=Text("A").focusable(true).onKey({ _=>
            trace.value+="bubble "
            if(replace.value){current.value.getOrThrow().defaultAction({_=>trace.value+="new "});replace.value=false}
        }).defaultAction({_=>trace.value+="old "})
        current.value=Some(c);c
    },{=>Text("B").focusable(true)}])
    root.defaultAction({_=>trace.value+="ancestor "},phase:DefaultActionPhase.Ancestor)
    let app=Application(root,theme:plainTheme());app.startHeadless();let target=nodes[0]
    app.dispatch(ref(target),KeyEvent("text",text:"x"))
    check(trace.value=="bubble old ancestor ","handler snapshot fixed before callback replacement")
    trace.value="";app.dispatch(ref(target),KeyEvent("text",text:"x"))
    check(trace.value=="bubble new ancestor ","replacement applies to following event only")
    trace.value=""
    target.defaultAction({_=>trace.value+="disable ";target.enabled(false);()})
    app.dispatch(ref(target),KeyEvent("text",text:"x"))
    check(trace.value=="bubble disable ancestor ","side effects do not truncate fixed default route")
    focus(app,nodes[1]);app.dispose()
}
