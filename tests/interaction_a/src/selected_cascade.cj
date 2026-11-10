package interaction_a_contract
import cjtui.*
func selectedCascade(): Unit {
    let t = Theme.parse("schema_version=1\nname=\"selected\"\n[text]\nforeground=\"green\"\n[styles.state.states.selected.text]\nbackground=\"blue\"\n[styles.state.states.disabled.text]\ndim=true\n[styles.state.states.focused.text]\nunderline=true\n")
    let inline = StyleRule().withValue(StyleKeys.bold,StyleValue<Bool>.Value(true))
    let c = Canvas({ _ => Size(2,1) },{ p =>
        check(p.defaultStyle == Style(foreground:Color.Red,bold:true,underline:true),"default same-source state resolution")
        check(p.selectedStyle == Style(foreground:Color.Red,background:Color.Blue,bold:true,underline:true),"selected uses same resolver")
        p.put(0,0,RichText([TextSpan("x",style:TextStylePatch(foreground:Some(Color.Yellow),bold:Some(true),italic:Some(true)))]),
            patch:TextStylePatch(foreground:Some(Color.Default),bold:Some(false)),selected:true)
        p.fill(Rect(1,0,1,1),patch:TextStylePatch(bold:Some(false)),selected:true)
    }).styles([StyleUse.Named("state"),StyleUse.Inline(inline)]).foreground(Color.Red).focusable(true)
    let app = Application(c,theme:t); app.startHeadless(); let f=app.snapshot(2,1)
    cell(f,0,0,"x",1,false,Style(foreground:Color.Red,background:Color.Blue,bold:false,italic:true,underline:true))
    cell(f,1,0," ",1,false,Style(foreground:Color.Red,background:Color.Blue,bold:false,underline:true))
    app.dispose()
    let declared = Canvas({ _ => Size(1,1) },{ p => p.put(0,0,"x",selected:false) }).styles([StyleUse.Named("state")]).visualStates(VisualStates(selected:true))
    let d=Application(declared,theme:t); d.startHeadless(); cell(d.snapshot(1,1),0,0,"x",1,false,Style(foreground:Color.Green,background:Color.Blue)); d.dispose()
    // I012: detached, ordinary ancestor disabled, last setter, visual OR, real focus.
    let leaf=Text("x").foreground(Color.Red)
        .setStyle(StyleKeys.dim,StyleValue<Bool>.Value(true),state:VisualState.Disabled)
        .setStyle(StyleKeys.underline,StyleValue<Bool>.Value(true),state:VisualState.Focused)
        .visualStates(VisualStates(disabled:false,focused:true,selected:true)).enabled(true).enabled(false)
    let detached=render(leaf,1,1)
    cell(detached,0,0,"x",1,false,Style(foreground:Color.Red,dim:true,underline:true))
    check(leaf.reference().isNone(),"detached render publishes no reference")
    let (parent,nodes)=group([{=>Text("x").focusable(true).styles([StyleUse.Named("state")]).visualStates(VisualStates(disabled:false,selected:true))}])
    let inherited=nodes[0];parent.enabled(false)
    let a=Application(parent,theme:t); a.startHeadless(); let ff=a.snapshot(1,1)
    check(!ref(inherited).isEnabled() && !ref(inherited).isFocused() && a.focusedNode().isNone(),"ancestor behavior disables without fake visual focus")
    cell(ff,0,0,"x",1,false,Style(foreground:Color.Green,background:Color.Blue,dim:true))
    parent.enabled(true); a.snapshot(1,1); focus(a,inherited)
    check(ref(inherited).isEnabled(),"last enabled source and real focus")
    a.dispose()
}
