package interaction_c
import cjtui.*

func hiddenOrUnmountedSaved(remove:Bool):Unit {
    let saved=Box<?Component>(Option<Component>.None);let previous=Box<?Component>(Option<Component>.None)
    let root=Column{previous.value=Some(Text("P").focusable(true));saved.value=Some(Text("S").focusable(true));Text("N").focusable(true)}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();let old=node(saved.value.getOrThrow());app.batch({=>old.requestFocus()})
    let h=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({=>h.value=Some(node(root).openOverlay(Text("M").focusable(true),options:OverlayOptions(mode:OverlayMode.Modal)))})
    app.batch({=>if(remove){node(root).remove(old)}else{saved.value.getOrThrow().visible(false)}})
    app.batch({=>h.value.getOrThrow().close()})
    check(old.isValid()!=remove,"F10/F11 hidden retains generation; remove revokes")
    focused(app,node(previous.value.getOrThrow()),"F10/F11 nearest surviving owner ancestor first eligible")
    app.dispose()
}

func physicalRestorationFallback(branch:Int64):Unit {
    let root=Column{}.viewport(ScrollAxes.Off);let app=Application(root);app.startHeadless()
    let previous=Box<?Component>(Option<Component>.None);let saved=Box<?Component>(Option<Component>.None);let next=Box<?Component>(Option<Component>.None)
    let lower=Column{previous.value=Some(Text("P").focusable(true));saved.value=Some(Text("S").focusable(true));next.value=Some(Text("N").focusable(true))}
    app.batch({=>node(root).openOverlay(lower);()});app.batch({=>node(saved.value.getOrThrow()).requestFocus()})
    let h=Box<?OverlayHandle>(Option<OverlayHandle>.None);app.batch({=>h.value=Some(node(root).openOverlay(Text("M").focusable(true),options:OverlayOptions(mode:OverlayMode.Modal)))})
    app.batch({=>saved.value.getOrThrow().visible(false);if(branch>=1){next.value.getOrThrow().enabled(false)};if(branch>=2){previous.value.getOrThrow().enabled(false)}})
    let fresh=Text("F").focusable(true)
    if(branch==2){app.batch({=>node(lower).append(fresh)})}
    app.batch({=>h.value.getOrThrow().close()})
    if(branch==0){focused(app,node(next.value.getOrThrow()),"F12 physical successor outside empty owner subtree")}
    else if(branch==1){focused(app,node(previous.value.getOrThrow()),"F12 old predecessor when successor ineligible")}
    else if(branch==2){focused(app,node(fresh),"F12 new domain first when old candidates absent")}
    else {check(app.focusedNode().isNone(),"F12 all empty keeps None");target(app,node(root),"F12 empty base domain target")}
    app.dispose()
}

func stackedRestoration():Unit {
    let root=Column{Text("base").focusable(true)}.viewport(ScrollAxes.Off);let app=Application(root);app.startHeadless()
    let lower=Text("M").focusable(true);let popup=Text("P").focusable(true);let confirm=Text("C").focusable(true)
    let m=Box<?OverlayHandle>(Option<OverlayHandle>.None);let p=Box<?OverlayHandle>(Option<OverlayHandle>.None);let c=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({=>m.value=Some(node(root).openOverlay(lower,options:OverlayOptions(mode:OverlayMode.Modal)))})
    app.batch({=>p.value=Some(node(lower).openOverlay(popup))})
    app.batch({=>c.value=Some(node(popup).openOverlay(confirm,options:OverlayOptions(mode:OverlayMode.Modal)))})
    app.batch({=>c.value.getOrThrow().close()});focused(app,node(popup),"F13 top modal restores lower dependent focus")
    app.batch({=>p.value.getOrThrow().close()});focused(app,node(lower),"F13 lower modal original focus restored")
    app.batch({=>node(lower).openOverlay(Text("P2").focusable(true));()})
    app.batch({=>m.value.getOrThrow().close()});check(!p.value.getOrThrow().isOpen() && !c.value.getOrThrow().isOpen(),"F13 closed dependents remain terminal")
    focused(app,node(root).children()[0],"F13 cascade restores base focus once at final boundary")
    app.dispose()
}
