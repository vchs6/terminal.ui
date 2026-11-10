package interaction_a_contract
import cjtui.*
func defaultActionTrace(): Unit {
    let refTarget=Box<?NodeRef>(Option<NodeRef>.None)
    let parentForTrace=Box<?Component>(Option<Component>.None)
    let trace=Box<String>(""); let mode=Box<String>("normal"); let saved=Box<?UIKeyEvent>(Option<UIKeyEvent>.None)
    let targetBox=Box<?Component>(Option<Component>.None)
    let parentBox=Box<?Component>(Option<Component>.None)
    let targetFactory={=>Text("x").focusable(true).onKeyCapture({ _ => trace.value+="Tc " }).onKey({ e =>
        trace.value+="Tb "; saved.value=Some(e)
        if(mode.value=="stop"){e.stopPropagation()}; if(mode.value=="prevent"){e.preventDefault()}; if(mode.value=="consume"){e.consume()}
    }).defaultAction({ _ => trace.value+="OLD " }).defaultAction({ e =>
        check(e.target.sameNode(refTarget.value.getOrThrow()) && e.currentTarget.sameNode(e.target),"Target identity")
        trace.value+="T "; if(mode.value=="target-prevent"){e.preventDefault()}; if(mode.value=="target-stop"){e.stopPropagation()}
    }).defaultAction({ _ => trace.value+="TA " },phase:DefaultActionPhase.Ancestor) }
    refTarget.value=Option<NodeRef>.None
    let parentFactory={=>Row { targetBox.value=Some(targetFactory()) }.onKeyCapture({ _ => trace.value+="Pc " }).onKey({ _ => trace.value+="Pb " })
        .defaultAction({ e => trace.value+="PA "; check(e.currentTarget.sameNode(ref(parentForTrace.value.getOrThrow())),"ancestor currentTarget"); if(mode.value=="ancestor-prevent"){e.preventDefault()} },phase:DefaultActionPhase.Ancestor) }
    let root=Column { parentBox.value=Some(parentFactory()) }.onKeyCapture({ _ => trace.value+="Rc " }).onKey({ _ => trace.value+="Rb " })
        .defaultAction({ _ => trace.value+="RA " },phase:DefaultActionPhase.Ancestor)
    let target=targetBox.value.getOrThrow();let parent=parentBox.value.getOrThrow();parentForTrace.value=Some(parent)
    let app=Application(root,theme:plainTheme()).onKeyEvent({ _ => trace.value+="N " }).onKey({ _ => trace.value+="L " })
    app.startHeadless(); refTarget.value=Some(ref(target))
    for(pair in [("normal","Rc Pc Tc Tb Pb Rb N L T TA PA RA "),("stop","Rc Pc Tc Tb T TA PA RA "),
        ("prevent","Rc Pc Tc Tb Pb Rb N L "),("consume","Rc Pc Tc Tb "),
        ("target-prevent","Rc Pc Tc Tb Pb Rb N L T "),("target-stop","Rc Pc Tc Tb Pb Rb N L T TA PA RA "),
        ("ancestor-prevent","Rc Pc Tc Tb Pb Rb N L T TA PA ")]) {
        mode.value=pair[0]; trace.value=""; app.dispatch(ref(target),KeyEvent("text",text:"x")); check(trace.value==pair[1],"literal default trace ${pair[0]}")
        let event=saved.value.getOrThrow(); code("ExpiredEvent",{=>event.preventDefault()}); code("ExpiredEvent",{=>event.stopPropagation()}); code("ExpiredEvent",{=>event.consume()})
    }
    mode.value="normal"; trace.value=""; app.dispatch(ref(target),KeyEvent("tab"))
    check(trace.value=="Rc Pc Tc Tb Pb Rb N L T ","framework Tab handles before Ancestor even same single focus")
    app.dispose()
}
