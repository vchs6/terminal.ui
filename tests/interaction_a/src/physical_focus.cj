package interaction_a_contract
import cjtui.*
import std.collection.ArrayList
func physicalFocus(): Unit {
    let items=Observable<Array<String>>(["A","B","C"]); let built=ArrayList<Component>()
    let root=Column {
        ForEach<String>({=>items.get()},{s=>s},{item=> built.add(Text({=>item.value}).focusable(true))})
    }
    let app=Application(root,theme:plainTheme()); check(app.focusedNode().isNone(),"not-started focus None")
    app.startHeadless(); let a=built[0]; let b=built[1]; let c=built[2]; focus(app,a)
    let x=Text("X").focusable(true)
    app.batch({=>ref(root).insertBefore(ref(b),x)})
    app.batch({=>ref(b).requestFocus()}); items.set(["C","B","A"]); app.snapshot(1,4); focus(app,b)
    let children=ref(root).children()
    check(children.size==4 && children[0].sameNode(ref(c)) && children[1].sameNode(ref(x)) && children[2].sameNode(ref(b)) && children[3].sameNode(ref(a)),"C X B A mixed physical order")
    app.dispatch(ref(b),KeyEvent("tab")); focus(app,a)
    app.dispatch(ref(a),KeyEvent("tab")); focus(app,c)
    app.dispatch(ref(c),KeyEvent("backtab")); focus(app,a)
    app.batch({=>ref(root).moveBefore(ref(a),ref(c))}); focus(app,a)
    app.dispatch(ref(a),KeyEvent("tab")); focus(app,c)
    app.dispose(); check(app.focusedNode().isNone() && app.activeTarget().isNone(),"disposed queries None")
    // Parent preorder, hidden/disabled leaves and later eligibility are not key-sorted.
    let secondBox=Box<?Component>(Option<Component>.None)
    let (r,nodes)=group([{=>Text("z").focusable(true).enabled(false)},
        {=>Column { secondBox.value=Some(Text("a").focusable(true)) }.focusable(true)}])
    let first=nodes[0];let nested=nodes[1];let second=secondBox.value.getOrThrow()
    let p=Application(r,theme:plainTheme()); p.startHeadless(); focus(p,nested)
    p.dispatch(ref(nested),KeyEvent("tab")); focus(p,second)
    first.enabled(true); p.snapshot(1,2); focus(p,second)
    p.dispose()
    let later=Text("later").focusable(false); let e=Application(later,theme:plainTheme()); e.startHeadless()
    check(e.focusedNode().isNone() && e.activeTarget().getOrThrow().sameNode(ref(later)),"empty base activeTarget is root")
    later.focusable(true); e.snapshot(5,1); focus(e,later); e.dispose()
}
