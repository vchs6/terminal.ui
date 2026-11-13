package interaction_c
import cjtui.*

func escapeAndLogicalRouting():Unit {
    let mode=Observable<Int64>(0);let root=Column{Text("base").focusable(true)}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    let modal=Text("M").focusable(true).onKey({e=>if(mode.get()==0){e.preventDefault()}else{e.stopPropagation()}})
    let h=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({=>h.value=Some(node(root).openOverlay(modal,options:OverlayOptions(mode:OverlayMode.Modal)))})
    app.batch({=>node(modal).openOverlay(Text("passive"),options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false));()})
    app.dispatch(node(modal),KeyEvent("escape"))
    check(h.value.getOrThrow().isOpen(),"D07 Target preventDefault keeps modal and passive open")
    mode.set(1);app.dispatch(node(modal),KeyEvent("escape"))
    check(reason(h.value.getOrThrow())=="Escape","D07 stopPropagation permits Escape and passive is skipped")
    app.dispose()

    let trace=Box<String>("");let owner=Box<?Component>(Option<Component>.None)
    let host=Box<?Component>(Option<Component>.None)
    let outer=Column{host.value=Some(Column{owner.value=Some(Text("O").onKey({_=>trace.value+="O;"}))}.overlayHost(true).onKey({_=>trace.value+="H;"}))}.viewport(ScrollAxes.Off).onKey({_=>trace.value+="R;"})
    let b=Application(outer).onKeyEvent({_=>trace.value+="APP;"}).onKey({_=>trace.value+="LEGACY;"});b.startHeadless()
    let leaf=Text("L").focusable(true).onKey({_=>trace.value+="L;"})
    b.batch({=>node(owner.value.getOrThrow()).openOverlay(leaf,options:OverlayOptions(host:node(host.value.getOrThrow())));()})
    trace.value="";b.dispatch(node(leaf),KeyEvent("text",text:"x"))
    // Host is already an ordinary ancestor here. It appears ONCE in owner order,
    // never as an extra geometry-parent edge ahead of O.
    check(trace.value=="L;O;H;R;APP;LEGACY;","D08 owner chain and base handlers; host adds no event-parent edge")
    b.dispose()
}

func modalTraversalAndDomainOpen():Unit {
    let base=Box<?Component>(Option<Component>.None);let root=Column{base.value=Some(Text("base").focusable(true))}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();let a=Box<?Component>(Option<Component>.None);let b=Box<?Component>(Option<Component>.None)
    let modal=Column{a.value=Some(Text("A").focusable(true));b.value=Some(Text("B").focusable(true))}
    app.batch({=>node(root).openOverlay(modal,options:OverlayOptions(mode:OverlayMode.Modal));()})
    app.batch({=>
        code("FocusOutsideDomain",{=>node(base.value.getOrThrow()).openOverlay(Text("bad"));()},"D09 lower owner open rejected")
        code("FocusOutsideDomain",{=>node(base.value.getOrThrow()).requestFocus()},"D09 lower domain focus rejected")
    })
    let p=Text("P").focusable(true);let q=Text("Q").focusable(true)
    app.batch({=>node(modal).openOverlay(p,options:OverlayOptions(takeFocus:false));node(modal).openOverlay(q,options:OverlayOptions(takeFocus:false));()})
    focused(app,node(a.value.getOrThrow()),"D10 modal ordinary first")
    for(c in [b.value.getOrThrow(),p,q,a.value.getOrThrow()]){app.dispatch(app.focusedNode().getOrThrow(),KeyEvent("tab"));focused(app,node(c),"D10 forward ordinary and layer commit order")}
    for(c in [q,p,b.value.getOrThrow(),a.value.getOrThrow()]){app.dispatch(app.focusedNode().getOrThrow(),KeyEvent("backtab"));focused(app,node(c),"D10 exact reverse, no base")}
    app.dispose()
}
