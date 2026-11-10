package theme_integration_contract
import cjtui.*
func richTextMasks(): Unit {
    let rich=RichText([TextSpan("x",style:TextStylePatch(foreground:Some(Color.Blue),background:Some(Color.Yellow),bold:Some(true)))])
    let lower=StyleRule().withValue(StyleKeys.foreground,StyleValue<Color>.Value(Color.Red))
    styleAt(classic(Text(rich).styles([StyleUse.Inline(lower)]),1,1),0,0,Style(foreground:Color.Blue,background:Color.Yellow,bold:true),"span overrides reusable style without explicit mask")
    let control=Observable<StyleValue<Color>>(StyleValue<Color>.Unset)
    let node=Text(rich).styles([StyleUse.Inline(lower)]).setStyle(StyleKeys.foreground,{=>control.get()})
    let app=Application(node,theme:Theme.preset(ThemePreset.Classic));app.startHeadless()
    try {
        styleAt(app.snapshot(1,1),0,0,Style(foreground:Color.Blue,background:Color.Yellow,bold:true),"initial span sees no explicit foreground")
        app.batch({=>control.set(StyleValue<Color>.Value(Color.Red))})
        styleAt(app.snapshot(1,1),0,0,Style(foreground:Color.Red,background:Color.Yellow,bold:true),"equal resolved base Red still changes explicit mask and span result")
        app.batch({=>control.set(StyleValue<Color>.Reset)})
        styleAt(app.snapshot(1,1),0,0,Style(background:Color.Yellow,bold:true),"explicit Reset masks span with framework default")
        app.batch({=>control.set(StyleValue<Color>.Unset)})
        styleAt(app.snapshot(1,1),0,0,Style(foreground:Color.Blue,background:Color.Yellow,bold:true),"Unset restores span precedence")
    } finally {app.dispose()}
    let defaultBool=Text(rich).setStyle(StyleKeys.bold,StyleValue<Bool>.Value(false))
    check(!classic(defaultBool,1,1).cellAt(0,0).style.bold,"Value(false) masks true span flag")
    let all=RichText([TextSpan("x",style:TextStylePatch(foreground:Some(Color.Blue),background:Some(Color.Yellow),bold:Some(true),dim:Some(true),italic:Some(true),underline:Some(true),inverse:Some(true),strikethrough:Some(true)))])
    let bools=Observable<StyleValue<Bool>>(StyleValue<Bool>.Unset)
    let bg=Observable<StyleValue<Color>>(StyleValue<Color>.Unset)
    let allBase=StyleRule().withValue(StyleKeys.background,StyleValue<Color>.Value(Color.Black))
    let masks=Text(all).styles([StyleUse.Inline(allBase)])
        .setStyle(StyleKeys.bold,{=>bools.get()}).setStyle(StyleKeys.dim,{=>bools.get()})
        .setStyle(StyleKeys.italic,{=>bools.get()}).setStyle(StyleKeys.underline,{=>bools.get()})
        .setStyle(StyleKeys.inverse,{=>bools.get()}).setStyle(StyleKeys.strikethrough,{=>bools.get()})
        .setStyle(StyleKeys.background,{=>bg.get()})
    let every=Application(masks);every.startHeadless()
    try {
        styleAt(every.snapshot(1,1),0,0,Style(foreground:Color.Blue,background:Color.Yellow,bold:true,dim:true,italic:true,underline:true,inverse:true,strikethrough:true),"all unmasked span fields are preserved")
        every.batch({=>bools.set(StyleValue<Bool>.Value(false));bg.set(StyleValue<Color>.Value(Color.Black))})
        styleAt(every.snapshot(1,1),0,0,Style(foreground:Color.Blue,background:Color.Black),"each of six Bool and background mask bits changes despite equal base values")
        every.batch({=>bools.set(StyleValue<Bool>.Unset);bg.set(StyleValue<Color>.Unset)})
        styleAt(every.snapshot(1,1),0,0,Style(foreground:Color.Blue,background:Color.Yellow,bold:true,dim:true,italic:true,underline:true,inverse:true,strikethrough:true),"clearing every mask restores all span fields")
    } finally {every.dispose()}
}
