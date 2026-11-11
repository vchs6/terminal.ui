package interaction_a_contract
import cjtui.*
func focusRepair(): Unit {
    let (root,nodes)=group([{=>Text("A").focusable(true)},{=>Text("B").focusable(true)},{=>Text("C").focusable(true)}])
    let a=nodes[0];let b=nodes[1];let c=nodes[2]; let app=Application(root,theme:plainTheme()); app.startHeadless()
    app.batch({=>ref(b).requestFocus()}); b.enabled(false); app.snapshot(1,3); focus(app,c)
    c.visible(false); app.snapshot(1,3); focus(app,a)
    a.focusable(false); app.snapshot(1,3); check(app.focusedNode().isNone(),"no eligible -> None")
    code("InvalidFocusTarget",{=>app.batch({=>ref(b).requestFocus()})})
    app.dispose()
    let (r,pair)=group([{=>Text("1").focusable(true)},{=>Text("2").focusable(true)}])
    let one=pair[0];let two=pair[1]; let p=Application(r,theme:plainTheme()); p.startHeadless()
    let stale=ref(one); p.batch({=>ref(r).remove(stale)}); focus(p,two)
    check(!stale.isValid(),"removed generation invalid")
    code("StaleReference",{=>stale.isFocused();()}); code("StaleReference",{=>stale.isEnabled();()})
    code("StaleReference",{=>stale.isVisible();()}); code("StaleReference",{=>stale.application();()})
    p.batch({=>ref(r).append(one)})
    check(!stale.sameNode(ref(one)) && !stale.isValid(),"remount opens a new generation without reviving old reference")
    focus(p,two)
    p.dispose()
    let (last,lastNodes)=group([{=>Text("f").focusable(true)},{=>Text("g").focusable(true)}])
    let f=lastNodes[0];let g=lastNodes[1];let q=Application(last,theme:plainTheme()); q.startHeadless()
    q.batch({=>ref(g).requestFocus(); ref(f).requestFocus(); ref(g).requestFocus()}); focus(q,g)
    q.dispose()
    cancelUnmountedFocus(false); cancelUnmountedFocus(true)
}

// Unmount cancels queued intent; later direct use is still StaleReference.
func cancelUnmountedFocus(ancestor:Bool): Unit {
    let saved=Box<?Component>(Option<Component>.None)
    let (root,nodes)=group([{=>Text("A").focusable(true)},{=>Column {saved.value=Some(Text("B").focusable(true))}},{=>Text("C").focusable(true)}])
    let branch=nodes[1];let inner=saved.value.getOrThrow()
    let app=Application(root,theme:plainTheme());app.startHeadless()
    try {
        let pending=ref(inner);let parent=ref(branch);focus(app,nodes[0])
        app.batch({=>
            pending.requestFocus();ref(nodes[2]).requestFocus()
            if(ancestor){ref(root).remove(parent)}else{parent.remove(pending)}
        })
        check(!pending.isValid(),"I06 removed target generation revoked")
        focus(app,nodes[2])
        code("StaleReference",{=>pending.requestFocus()})
    } finally {app.dispose()}
}
