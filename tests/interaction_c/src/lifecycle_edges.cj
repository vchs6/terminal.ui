package interaction_c
import cjtui.*

func ordinaryOwnedClosure():Unit {
    let branch=Box<?Component>(None);let owner=Box<?Component>(None)
    let root=Column{branch.value=Some(Column{owner.value=Some(Text("owner"))})}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();let trace=Box<String>("")
    let first=Text("first").onMount({_=>{=>trace.value+="P;"}})
    let child=Text("child").onMount({_=>{=>trace.value+="C;"}})
    let h=Box<?OverlayHandle>(None);let c=Box<?OverlayHandle>(None);let sibling=Box<?OverlayHandle>(None)
    app.batch({=>h.value=Some(node(owner.value.getOrThrow()).openOverlay(first))})
    app.batch({=>c.value=Some(node(first).openOverlay(child))})
    app.batch({=>sibling.value=Some(node(root).openOverlay(Text("sibling"),options:OverlayOptions(takeFocus:false)))})
    app.batch({=>node(root).remove(node(branch.value.getOrThrow()))})
    check(reason(h.value.getOrThrow())=="OwnerGone" && !c.value.getOrThrow().isOpen() && trace.value=="C;P;","L06 ordinary ancestor removal closes overlay full closure")
    check(sibling.value.getOrThrow().isOpen(),"L06 unrelated sibling survives")
    app.dispose()
}

func offscreenOwnerAndReason():Unit {
    let owner=Box<?Component>(None);let root=ScrollView({=>owner.value=Some(Text("O").height(1));Text("tail").height(10)})
    let app=Application(root);app.startHeadless();app.snapshot(4,2)
    let h=Box<?OverlayHandle>(None)
    app.batch({=>h.value=Some(node(owner.value.getOrThrow()).openOverlay(Text("P"),options:OverlayOptions(takeFocus:false)))})
    app.batch({=>node(root).scrollTo(0,5);()});app.snapshot(4,2)
    check(h.value.getOrThrow().isOpen(),"L07 offscreen owner is not hidden")
    app.snapshot(0,0);check(h.value.getOrThrow().isOpen(),"L07 zero clip does not close unanchored layer")
    app.batch({=>owner.value.getOrThrow().visible(false)})
    check(reason(h.value.getOrThrow())=="OwnerHidden","L07 explicit hidden closes")
    app.batch({=>owner.value.getOrThrow().visible(true)});app.snapshot(4,2)
    let anchored=Box<?OverlayHandle>(None)
    app.batch({=>node(root).scrollTo(0,0);()});app.snapshot(4,2)
    app.batch({=>anchored.value=Some(node(owner.value.getOrThrow()).openOverlay(Text("A"),options:OverlayOptions(anchor:node(owner.value.getOrThrow()),placement:OverlayPlacement.BelowStart,takeFocus:false)))})
    app.batch({=>node(root).remove(node(owner.value.getOrThrow()))})
    check(reason(anchored.value.getOrThrow())=="OwnerGone","L07 owner removal wins simultaneous anchor loss")
    app.dispose()
}

func primaryAndCleanup(draw:Bool):Unit {
    let root=Column{}.viewport(ScrollAxes.Off);let app=Application(root);app.startHeadless()
    let original=Exception("L08 ORIGINAL");let parentError=Exception("L08 PARENT");let childError=Exception("L08 CHILD");let trace=Box<String>("")
    let parent=Text("P").onMount({_=>{=>trace.value+="P;";throw parentError}})
    app.batch({=>node(root).openOverlay(parent);()})
    let child=Canvas({_=>Size(1,1)},{_=>if(draw){throw original}}).focusable(true).onKey({_=>throw original}).onMount({_=>{=>trace.value+="C;";throw childError}})
    app.batch({=>node(parent).openOverlay(child);()})
    var caught=false
    try{if(draw){app.snapshot(4,2)}else{app.dispatch(node(child),KeyEvent("text",text:"x"))}}
    catch(e:UICleanupException){caught=refEq(e.primary,original) && e.cleanupFailures.size==2 && refEq(e.cleanupFailures[0],childError) && refEq(e.cleanupFailures[1],parentError)}
    check(caught && trace.value=="C;P;","L08 original callback/draw identity and cleanup order")
    released(app,"L08 failure releases complete session");app.dispose();check(trace.value=="C;P;","L08 no repeated cleanup")
}
