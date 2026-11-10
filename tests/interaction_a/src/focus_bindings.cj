package interaction_a_contract
import cjtui.*
func focusBindings(): Unit {
    let enabled=Observable<Bool>(true);let visible=Observable<Bool>(true);let eligible=Observable<Bool>(false)
    let mounts=Box<Int64>(0)
    let (parent,nodes)=group([
        {=>Text("A").enabled(false).enabled({=>enabled.get()}).focusable({=>eligible.get()})
            .visualStates(VisualStates(disabled:true,focused:true,selected:true))
            .onMount({_=>mounts.value++;{=>}})},
        {=>Text("B").focusable(true)}])
    parent.visible({=>visible.get()})
    let app=Application(parent,theme:plainTheme());app.startHeadless();let first=nodes[0];let second=nodes[1]
    focus(app,second)
    check(ref(first).isEnabled() && !ref(first).isFocused(),"declared visual disabled/focused never changes behavior")
    eligible.set(true);app.snapshot(1,2);focus(app,second)
    app.batch({=>ref(first).requestFocus()});focus(app,first)
    enabled.set(false);app.snapshot(1,2);focus(app,second)
    first.enabled(true);enabled.set(true);enabled.set(false);app.snapshot(1,2)
    check(ref(first).isEnabled(),"later constant replaces enabled getter and removes dependency")
    visible.set(false);app.snapshot(1,2)
    check(!ref(first).isVisible() && !ref(second).isVisible() && app.focusedNode().isNone() && app.activeTarget().isNone(),"effective ancestor visibility and empty target")
    visible.set(true);app.snapshot(1,2);focus(app,first)
    check(mounts.value==1,"focus/visibility/enable changes do not remount effects")
    app.dispose()
}
