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
    behaviorStateGeometry("focus"); behaviorStateGeometry("constant"); behaviorStateGeometry("getter"); enabledVisibilityIndependence()
}

// I012/A.2: automatic behavioral states can select layout-affecting styles.
func behaviorStateGeometry(mode:String): Unit {
    let enabled=Observable<Bool>(true)
    let saved=Box<?Component>(Option<Component>.None)
    let root=Column {
        Text("A").focusable(true)
        let target=Text("abcd").width(4).wrap(TextWrap.Grapheme).focusable(true)
        if(mode=="focus"){
            target.setStyle(StyleKeys.width,StyleValue<Dimension>.Value(Dimension.Cells(1)),state:VisualState.Focused)
        } else {
            target.setStyle(StyleKeys.width,StyleValue<Dimension>.Value(Dimension.Cells(1)),state:VisualState.Disabled)
            if(mode=="getter"){target.enabled({=>enabled.get()})}
        }
        saved.value=Some(target)
        Text("Z")
    }
    let target=saved.value.getOrThrow()
    let app=Application(root,theme:plainTheme());app.startHeadless()
    try {
        check(app.snapshot(4,6).toPlainText()=="A   \nabcd\nZ   \n    \n    \n    ","I02 initial width4 geometry")
        if(mode=="focus"){app.batch({=>ref(target).requestFocus()})}
        else if(mode=="constant"){target.enabled(false)}else{enabled.set(false)}
        let actual=app.snapshot(4,6);let full=render(root,4,6)
        let expected="A   \na   \nb   \nc   \nd   \nZ   "
        check(full.toPlainText()==expected,"I02 manual M1 state geometry control ${mode}")
        check(actual.toPlainText()==expected,"I02 behavioral state invalidates measurement ${mode}")
        sameFrame(actual,full,4,6)
    } finally {app.dispose()}
}
func enabledVisibilityIndependence(): Unit {
    let (root,nodes)=group([{=>Text("x").enabled(true).focusable(true)}]);let child=nodes[0]
    let app=Application(root,theme:plainTheme());app.startHeadless()
    try {
        app.snapshot(1,1);check(ref(child).isEnabled() && ref(child).isVisible(),"I04 initial enabled/visible control")
        root.visible(false);app.snapshot(1,1)
        check(!ref(child).isVisible() && app.focusedNode().isNone(),"I04 hidden ancestor excludes focus")
        check(ref(child).isEnabled(),"I04 hidden ancestor does not disable descendant")
        root.visible(true);root.enabled(false);app.snapshot(1,1)
        check(ref(child).isVisible() && !ref(child).isEnabled(),"I04 disabled ancestor does not hide descendant")
        root.enabled(true);child.visible(false);app.snapshot(1,1)
        check(!ref(child).isVisible() && ref(child).isEnabled(),"I04 own visibility independent from enabled")
    } finally {app.dispose()}
}
