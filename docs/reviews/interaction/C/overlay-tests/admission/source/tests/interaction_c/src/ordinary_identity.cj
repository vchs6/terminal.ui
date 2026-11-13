package interaction_c
import cjtui.*
import std.collection.*

func mixedOrdinaryIdentity():Unit {
    let show=Observable<Bool>(true);let keys=Observable<Array<String>>(["A","B"]);let entries=ArrayList<Component>()
    let root=Column{
        If({=>show.get()},{=>Text("if")})
        ForEach<String>({=>keys.get()},{s=>s},{item=>entries.add(Text({=>item.value}).key(item.value))})
    }.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();let a=node(entries[0]);let b=node(entries[1]);let manual=Text("M")
    app.batch({=>node(root).insertBefore(b,manual)})
    let before=node(root).children();let layer=Text("layer");let h=Box<?OverlayHandle>(None)
    app.batch({=>h.value=Some(node(root).openOverlay(layer,options:OverlayOptions(takeFocus:false)))})
    let after=node(root).children()
    check(after.size==before.size,"N04 layer not an ordinary marker or child")
    for(i in 0..before.size){check(before[i].sameNode(after[i]),"N04 ordinary identity unchanged ${i}")}
    app.batch({=>keys.set(["B","A"]);show.set(false)})
    let moved=node(root).children()
    check(moved.size==3 && moved[0].sameNode(b) && moved[1].sameNode(node(manual)) && moved[2].sameNode(a),"N04 physical keyed/manual order B M A")
    check(h.value.getOrThrow().content().getOrThrow().sameNode(node(layer)),"N04 keyed change preserves layer generation")
    app.dispose()
}

func ownerMoveAndPaintLifetime():Unit {
    let owner=Box<?Component>(None);let root=Column{owner.value=Some(Text("O").height(1));Text("S").height(1)}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();app.snapshot(6,6)
    let paint=Box<?PaintContext>(None)
    let popup=Canvas({_=>Size(3,8)},{p=>paint.value=Some(p);p.put(0,3,"P")}).viewport(ScrollAxes.Vertical).width(3).height(2)
    let h=Box<?OverlayHandle>(None)
    app.batch({=>h.value=Some(node(owner.value.getOrThrow()).openOverlay(popup,options:OverlayOptions(anchor:node(owner.value.getOrThrow()),placement:OverlayPlacement.BelowStart,takeFocus:false)))})
    app.snapshot(6,6);let old=node(popup);let ownerRef=node(owner.value.getOrThrow())
    app.batch({=>old.scrollTo(0,3);node(root).moveToEnd(ownerRef)})
    picture(app.snapshot(6,6),"S     \nO     \nP     \n      \n      \n      ","N05 moved anchor geometry and retained scrolled paint")
    check(old.sameNode(node(popup)) && ownerRef.sameNode(node(owner.value.getOrThrow())) && old.viewportSnapshot().offsetY==3,"N05 owner move retains owner/layer/local offset")
    code("ExpiredPaintContext",{=>paint.value.getOrThrow().size;()},"N06 paint context expires after layer draw")
    check(old.isValid(),"N06 expiry does not revoke actual layer node")
    app.batch({=>h.value.getOrThrow().close()})
    code("StaleReference",{=>old.isVisible();()},"N06 close revokes layer generation")
    app.dispose()
}
