package interaction_c
import cjtui.*

func anchorPlacement(placement:OverlayPlacement,top:Int64,left:Int64,expected:String):Unit {
    let anchor=Box<?Component>(Option<Component>.None)
    let root=Column{
        Text("0000000000").height(top)
        Row{Text(if(left==9){"........."}else{"...."}).width(left);anchor.value=Some(Text(if(left==9){"A"}else{"AA"}).width(if(left==9){1}else{2}))}.height(1)
    }.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();app.snapshot(10,6)
    let popup=Canvas({_=>Size(3,2)},{p=>p.put(0,0,"PPP");p.put(0,1,"PPP")})
    let h=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({=>h.value=Some(node(root).openOverlay(popup,options:OverlayOptions(anchor:node(anchor.value.getOrThrow()),placement:placement,takeFocus:false)))})
    let old=node(popup);picture(app.snapshot(10,6),expected,"G13 manual directional/flip/clamp grid")
    // Keep the known anchor intersecting the host; fully clipped is G14.
    app.snapshot(if(left==9){10}else{9},if(top==5){6}else{5})
    check(h.value.getOrThrow().isOpen() && h.value.getOrThrow().content().isSome(),"G13 still-visible anchor keeps published layer open")
    check(old.sameNode(h.value.getOrThrow().content().getOrThrow()),"G13 resize keeps actual layer identity")
    app.dispose()
}
func directionalAnchors():Unit {
    anchorPlacement(OverlayPlacement.BelowStart,2,4,"0000000000\n          \n....AA    \n    PPP   \n    PPP   \n          ")
    anchorPlacement(OverlayPlacement.AboveStart,2,4,"0000PPP000\n    PPP   \n....AA    \n          \n          \n          ")
    anchorPlacement(OverlayPlacement.RightStart,2,4,"0000000000\n          \n....AAPPP \n      PPP \n          \n          ")
    anchorPlacement(OverlayPlacement.LeftStart,2,4,"0000000000\n          \n.PPPAA    \n PPP      \n          \n          ")
    anchorPlacement(OverlayPlacement.BelowStart,5,4,"0000000000\n          \n          \n    PPP   \n    PPP   \n....AA    ")
    anchorPlacement(OverlayPlacement.BelowStart,2,9,"0000000000\n          \n.........A\n       PPP\n       PPP\n          ")
    let a=Box<?Component>(Option<Component>.None);let root=Column{Text("0000000000").height(1);Row{Text("....").width(4);a.value=Some(Text("AA").width(2))}.height(1)}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();app.snapshot(10,3)
    app.batch({=>node(root).openOverlay(Canvas({_=>Size(3,2)},{p=>p.put(0,0,"PPP");p.put(0,1,"PPP")}),options:OverlayOptions(anchor:node(a.value.getOrThrow()),placement:OverlayPlacement.BelowStart,takeFocus:false));()})
    picture(app.snapshot(10,3),"0000000000\n....PPP   \n    PPP   ","G13 equal side space retains Below then clamps to host")
    app.dispose()
}

func clippedAndLostAnchors():Unit {
    let anchor=Box<?Component>(Option<Component>.None);let root=ScrollView({=>anchor.value=Some(Text("AAAA").height(2));Text("tail").height(6)})
    let app=Application(root);app.startHeadless();app.snapshot(4,2)
    app.batch({=>node(root).scrollTo(0,1);()});app.snapshot(4,2)
    let h=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({=>h.value=Some(node(root).openOverlay(Text("PP").width(2).height(1),options:OverlayOptions(anchor:node(anchor.value.getOrThrow()),placement:OverlayPlacement.BelowStart,takeFocus:false)))})
    picture(app.snapshot(4,2),"    \nPPil","G14 partial anchor uses visible intersection")
    app.batch({=>anchor.value.getOrThrow().enabled(false)});app.snapshot(4,2)
    check(h.value.getOrThrow().isOpen(),"G14 disabled anchor keeps geometry/layer")
    app.batch({=>node(root).scrollTo(0,2);()});app.snapshot(4,2)
    check(reason(h.value.getOrThrow())=="AnchorGone" && node(anchor.value.getOrThrow()).isValid(),"G14 fully clipped anchor closes without unmount")
    for(remove in [false,true]){
        app.batch({=>node(root).scrollTo(0,0);()});app.snapshot(4,2)
        let next=Box<?OverlayHandle>(Option<OverlayHandle>.None)
        app.batch({=>next.value=Some(node(root).openOverlay(Text("PP"),options:OverlayOptions(anchor:node(anchor.value.getOrThrow()),placement:OverlayPlacement.BelowStart,takeFocus:false)))})
        app.batch({=>if(remove){node(root).remove(node(anchor.value.getOrThrow()))}else{anchor.value.getOrThrow().visible(false)}})
        check(reason(next.value.getOrThrow())=="AnchorGone","G14 hidden/unmounted anchor closes")
        if(!remove){app.batch({=>anchor.value.getOrThrow().visible(true)})}
    }
    let modal=Box<?OverlayHandle>(Option<OverlayHandle>.None);app.batch({=>modal.value=Some(node(root).openOverlay(Text("M"),options:OverlayOptions(mode:OverlayMode.Modal)))})
    app.snapshot(0,0);check(modal.value.getOrThrow().isOpen(),"G14 unanchored modal survives zero host")
    app.dispose()
}
