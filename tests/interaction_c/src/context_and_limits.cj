package interaction_c
import cjtui.*

func threadAndAnchorValidation():Unit {
    let owner=Box<?Component>(Option<Component>.None);let host=Box<?Component>(Option<Component>.None);let anchor=Box<?Component>(Option<Component>.None)
    let root=Column{host.value=Some(Column{owner.value=Some(Column{anchor.value=Some(Text("a"))})}.overlayHost(true))}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();let r=node(owner.value.getOrThrow());let h=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({=>h.value=Some(r.openOverlay(Text("layer"),options:OverlayOptions(takeFocus:false)))})
    let old=h.value.getOrThrow()
    let worker=spawn{
        code("WrongUIContext",{=>old.isOpen();()},"E13 worker handle query")
        code("WrongUIContext",{=>old.content();()},"E13 worker content")
        code("WrongUIContext",{=>old.closeReason();()},"E13 worker reason")
        code("WrongUIContext",{=>old.close()},"E13 worker close")
        code("WrongUIContext",{=>r.openOverlay(Text("bad"));()},"E13 worker open")
        true
    };check(worker.get(Duration.second*5),"E13 worker joined")
    app.batch({=>old.close()})
    let closed=spawn{code("WrongUIContext",{=>old.close()},"E13 closed no-op still guarded");true};check(closed.get(Duration.second*5),"E13 closed worker joined")
    app.batch({=>host.value.getOrThrow().visible(false)})
    // Capability and owner/host ancestry are valid; visibility is the rejected property.
    app.batch({=>code("InvalidOverlayHost",{=>node(host.value.getOrThrow()).openOverlay(Text("bad"),options:OverlayOptions(host:node(host.value.getOrThrow())));()},"E14 invisible host rejected")})
    app.batch({=>host.value.getOrThrow().visible(true)})
    let stale=node(anchor.value.getOrThrow());app.batch({=>r.remove(stale)})
    app.batch({=>code("StaleReference",{=>r.openOverlay(Text("bad"),options:OverlayOptions(anchor:stale,placement:OverlayPlacement.BelowStart));()},"E14 stale anchor")})
    let otherRoot=Text("foreign");let other=Application(otherRoot);other.startHeadless();let foreignAnchor=node(otherRoot)
    app.batch({=>code("WrongUIContext",{=>r.openOverlay(Text("bad"),options:OverlayOptions(anchor:foreignAnchor,placement:OverlayPlacement.BelowStart));()},"E14 foreign anchor")})
    other.dispose();app.dispose()
}

func evaluationAndLifecycleGuards(phase:Int64):Unit {
    let owner=Box<?Component>(Option<Component>.None);let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None);let armed=Observable<Bool>(false)
    let guarded={=>if(armed.get()){
        code("ReentrantStructure",{=>node(owner.value.getOrThrow()).openOverlay(Text("bad"));()},"E15 evaluation open structure guard")
        code("ReentrantStructure",{=>handle.value.getOrThrow().close()},"E15 evaluation close structure guard")
    }}
    let root=Column{
        owner.value=Some(Text("owner"))
        if(phase==0){Text({=>guarded();"getter"})}
        else {Canvas({_=>if(phase==1){guarded()};Size(1,1)},{_=>if(phase==2){guarded()}})}
    }.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    app.batch({=>handle.value=Some(node(owner.value.getOrThrow()).openOverlay(Text("live"),options:OverlayOptions(takeFocus:false)))})
    armed.set(true);app.snapshot(6,2);check(handle.value.getOrThrow().isOpen(),"E15 rejected evaluation commands preserve live layer")
    app.dispose()
}
func lifecycleLayerCommands():Unit {
    let root=Column{}.viewport(ScrollAxes.Off);let app=Application(root);app.startHeadless();let h=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    let content=Text("layer").onMount({r=>
        code("LifecycleReentry",{=>r.openOverlay(Text("bad"));()},"E15 lifecycle direct open")
        code("LifecycleReentry",{=>h.value.getOrThrow().close()},"E15 lifecycle direct close")
        check(app.post(r,{=>h.value.getOrThrow().close()}),"E15 lifecycle post accepted")
        {=>}
    })
    app.batch({=>h.value=Some(node(root).openOverlay(content))});app.snapshot(4,1)
    check(!h.value.getOrThrow().isOpen(),"E15 next-turn post closes successfully");app.dispose()
}

func layerCapacity(which:Int64):Unit {
    let owner=Box<?Component>(Option<Component>.None)
    // Shared runtime starts at root0: only the depth case adds ordinary owner1.
    let root=Column{if(which==2){owner.value=Some(Text("owner"))}}.viewport(ScrollAxes.Off)
    let limits=if(which==0){RuntimeLimits(mountedNodes:1)}else if(which==1){RuntimeLimits(structuralOpsPerBatch:1)}else{RuntimeLimits(treeDepth:1)}
    let app=Application(root,limits:limits);app.startHeadless()
    code("CapacityExceeded",{=>app.batch({=>
        if(which==2){node(owner.value.getOrThrow()).openOverlay(Text("one"))}else{node(root).openOverlay(Text("one"))}
        if(which==1){node(root).openOverlay(Text("two"))};()
    })},"E16 shared node/command/depth budget")
    app.dispose();released(app,"E16 no retained layer queue")
}

func layerDepthBoundary():Unit {
    let root=Column{}.viewport(ScrollAxes.Off)
    let app=Application(root,limits:RuntimeLimits(treeDepth:1));app.startHeadless()
    let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({=>handle.value=Some(node(root).openOverlay(Text("one")))})
    check(handle.value.getOrThrow().isOpen() && handle.value.getOrThrow().content().getOrThrow().isValid() && app.stats().mountedNodes==2,
        "E16 root0 to Text layer1 is legal at treeDepth1 and has exactly two real nodes")
    app.dispose();released(app,"E16 legal depth boundary releases complete session")
}
func layerDependencyBudget(exceed:Bool):Unit {
    let root=Column{}.viewport(ScrollAxes.Off);let app=Application(root,limits:RuntimeLimits(dependenciesPerBinding:1));app.startHeadless()
    let a=Observable<Int64>(1);let b=Observable<Int64>(2)
    let c=Canvas({_=>Size(a.get(),1)},{p=>p.put(0,0,"${if(exceed){a.get()+b.get()}else{b.get()}}")})
    let action={=>app.batch({=>node(root).openOverlay(c,options:OverlayOptions(takeFocus:false));()});app.snapshot(3,1);()}
    if(exceed){code("CapacityExceeded",action,"E17 draw two dependencies exceed1")}
    else {action();check(app.stats().subscriptions==2,"E17 measure and draw separate single-source subscriptions")}
    app.dispose();released(app,"E17 both computation records released")
}
func interactivePassiveRejection():Unit {
    let root=Column{}.viewport(ScrollAxes.Off);let app=Application(root);app.startHeadless()
    illegal({=>app.batch({=>node(root).openOverlay(Column{Text("interactive").focusable(true)},options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false));()})},"E18 passive interactive descendants rejected")
    app.dispose();released(app,"E18 rejected content leaves no resources")
}
