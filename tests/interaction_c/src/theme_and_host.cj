package interaction_c
import cjtui.*

func ownerThemeSurface():Unit {
    let owner=Box<?Component>(Option<Component>.None)
    let root=Column{owner.value=Some(Text("O").styles([StyleUse.Named("owner")]))}.styles([StyleUse.Named("host")]).overlayHost(true).viewport(ScrollAxes.Off)
    let first=Theme.parse("schema_version=1\nname='first'\n[styles.host]\nbackground='#445566'\n[styles.owner]\nbackground='#112233'\n")
    let second=Theme.parse("schema_version=1\nname='second'\n[styles.host]\nbackground='#445566'\n[styles.owner]\nbackground='#778899'\n")
    let app=Application(root,theme:first);app.startHeadless()
    let modal=Text("X").width(3).height(1).underline().inverse()
    app.batch({=>node(owner.value.getOrThrow()).openOverlay(modal,options:OverlayOptions(mode:OverlayMode.Modal,host:node(root)));()})
    let a=app.snapshot(8,3)
    check(a.cellAt(3,1).grapheme==" " && a.cellAt(3,1).style.background==Color.Rgb(0x11,0x22,0x33) && a.cellAt(3,1).style.underline && a.cellAt(3,1).style.inverse,"G11 modal surface spaces use full inherited owner style")
    check(a.cellAt(7,2).style.background==Color.Rgb(0x44,0x55,0x66),"G11 no full-screen modal backdrop")
    app.batch({=>owner.value.getOrThrow().enabled(false)})
    check(node(modal).isEnabled(),"G11 enabled does not inherit over owner edge")
    let request=app.loadTheme(ThemeSource.Prepared(second));let b=app.snapshot(8,3)
    check(match(request.result()){case Some(ThemeResult.Applied(_))=>true;case _=>false},"G11 theme commit control")
    check(b.cellAt(3,1).style.background==Color.Rgb(0x77,0x88,0x99) && b.cellAt(3,1).style.inverse,"G11 theme update changes filled modal spaces without local Default")
    app.dispose()
}

func explicitHostClip():Unit {
    let host=Box<?Component>(Option<Component>.None);let owner=Box<?Component>(Option<Component>.None)
    let root=Column{
        host.value=Some(Column{owner.value=Some(Text("O").width(1).height(1))}.width(6).height(3).overlayHost(true))
        Text("TTTTTTTT").height(1)
    }.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();app.snapshot(8,4)
    let popup=Canvas({_=>Size(9,6)},{p=>for(y in 0..6){p.put(0,y,"PPPPPPPPP")}}).shadow()
    app.batch({=>node(owner.value.getOrThrow()).openOverlay(popup,options:OverlayOptions(host:node(host.value.getOrThrow()),takeFocus:false));()})
    picture(app.snapshot(8,4),"PPPPPP  \nPPPPPP  \nPPPPPP  \nTTTTTTTT","G12 escapes owner1x1; popup/shadow never escape host6x3")
    app.dispose()
}
