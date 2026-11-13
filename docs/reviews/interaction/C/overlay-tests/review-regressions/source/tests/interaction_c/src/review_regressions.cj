package interaction_c
import cjtui.*

// C-I01: ordinary removal must revoke every owned generation before cleanup.
func reviewOwnerRevocation():Unit {
    let owner=Box<?Component>(Option<Component>.None)
    let root=Column{owner.value=Some(Text("O"))}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();let ownerRef=node(owner.value.getOrThrow())
    let allRevoked=Box<Bool>(true);let postRejected=Box<Bool>(true);let trace=Box<String>("")
    let outer=Box<?NodeRef>(Option<NodeRef>.None);let inner=Box<?NodeRef>(Option<NodeRef>.None)
    let observe={=>allRevoked.value=allRevoked.value && !ownerRef.isValid() && !outer.value.getOrThrow().isValid() && !inner.value.getOrThrow().isValid();postRejected.value=postRejected.value && !app.post(ownerRef,{=>})}
    let layer=Column{Text("L")}.onMount({_=>{=>observe();trace.value+="L;"}})
    let nested=Text("N").onMount({_=>{=>observe();trace.value+="N;"}})
    let first=Box<?OverlayHandle>(Option<OverlayHandle>.None);let second=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    try {
        app.batch({=>first.value=Some(ownerRef.openOverlay(layer,options:OverlayOptions(takeFocus:false)))})
        outer.value=Some(node(layer))
        app.batch({=>second.value=Some(node(layer).openOverlay(nested,options:OverlayOptions(takeFocus:false)))})
        inner.value=Some(node(nested))
        check(first.value.getOrThrow().isOpen() && second.value.getOrThrow().isOpen(),"C-I01 nested owned layers mounted control")
        app.batch({=>node(root).remove(ownerRef)})
        println("C-I01 allRevokedAtCleanup=${allRevoked.value} ownerPostRejected=${postRejected.value} trace=${trace.value} mounted=${app.stats().mountedNodes}")
        check(allRevoked.value && postRejected.value,"C-I01 revoke ordinary owner and whole overlay closure before any cleanup")
        check(trace.value=="N;L;" && app.stats().mountedNodes==1,"C-I01 deepest-first exactly-once cleanup leaves root only")
        check(!first.value.getOrThrow().isOpen() && !second.value.getOrThrow().isOpen() && reason(first.value.getOrThrow())=="OwnerGone" && reason(second.value.getOrThrow())=="OwnerGone","C-I01 owned handles terminate OwnerGone")
    }finally{app.dispose()}
}

// Both ordinary declarative retirement mechanisms must close the modal domain.
func reviewRetirement(useEach:Bool):Bool {
    let show=Observable<Bool>(true);let keys=Observable<Array<String>>(["owner"])
    let owner=Box<?Component>(Option<Component>.None)
    let root=if(useEach){Column{ForEach<String>({=>keys.get()},{s=>s},{_=>owner.value=Some(Text("O"))})}}else{Column{If({=>show.get()},{=>owner.value=Some(Text("O"))})}}
    root.viewport(ScrollAxes.Off)
    let cleanups=Box<Int64>(0);let modal=Text("P").onMount({_=>{=>cleanups.value++}})
    let app=Application(root);app.startHeadless();let savedOwner=node(owner.value.getOrThrow())
    let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None);var correct=false
    try {
        app.batch({=>handle.value=Some(savedOwner.openOverlay(modal,options:OverlayOptions(mode:OverlayMode.Modal)))})
        let savedLayer=node(modal);check(handle.value.getOrThrow().isOpen() && savedLayer.isValid(),"C-I02 modal mounted before retirement each=${useEach}")
        app.batch({=>if(useEach){keys.set([])}else{show.set(false)}})
        let h=handle.value.getOrThrow();let active=app.activeTarget()
        correct= !savedOwner.isValid() && !savedLayer.isValid() && !h.isOpen() && reason(h)=="OwnerGone" && cleanups.value==1 && active.isSome() && active.getOrThrow().sameNode(node(root))
        println("C-I02 each=${useEach} ownerValid=${savedOwner.isValid()} layerValid=${savedLayer.isValid()} open=${h.isOpen()} reason=${reason(h)} cleanup=${cleanups.value} activeIsRoot=${active.isSome() && active.getOrThrow().sameNode(node(root))}")
    }finally{app.dispose()}
    return correct
}
func reviewDeclarativeOwner():Unit {
    let ifCorrect=reviewRetirement(false);let eachCorrect=reviewRetirement(true)
    check(ifCorrect && eachCorrect,"C-I02 If and ForEach retirement close owned modal once and restore base root")
}

func reviewHiddenAndDisabledLayer():Unit {
    let root=Text("BBB").viewport(ScrollAxes.Off);let layer=Text("P")
    let app=Application(root);app.startHeadless()
    try {
        app.batch({=>node(root).openOverlay(layer,options:OverlayOptions(takeFocus:true));()})
        picture(app.snapshot(3,1),"BPB","C-I03 visible centered layer control")
        target(app,node(layer),"C-I03 takeFocus layer root control")
        app.batch({=>layer.visible(false)})
        let hidden=app.snapshot(3,1);let hiddenTarget=app.activeTarget()
        let hiddenEligible=hiddenTarget.isNone() || (hiddenTarget.getOrThrow().isVisible() && hiddenTarget.getOrThrow().isEnabled())
        let hiddenRefVisible=node(layer).isVisible()
        app.batch({=>layer.visible(true);layer.enabled(false)})
        let disabled=app.snapshot(3,1);let disabledTarget=app.activeTarget()
        let disabledEligible=disabledTarget.isNone() || (disabledTarget.getOrThrow().isVisible() && disabledTarget.getOrThrow().isEnabled())
        println("C-I03 hidden=[${hidden.toPlainText()}] refVisible=${hiddenRefVisible} hiddenTargetEligible=${hiddenEligible} disabled=[${disabled.toPlainText()}] disabledTargetEligible=${disabledEligible}")
        picture(hidden,"BBB","C-I03 hidden content root contributes no cells")
        check(!hiddenRefVisible && hiddenEligible && disabledEligible,"C-I03 hidden and disabled roots cannot remain active targets")
        picture(disabled,"BPB","C-I03 disabled content remains visible")
    }finally{app.dispose()}
}

func reviewEnsureAnchor():Unit {
    let anchor=Box<?Component>(Option<Component>.None)
    let root=ScrollView{anchor.value=Some(Text("A"));Text("1\n2\n3\n4")}
    let app=Application(root);app.startHeadless();let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    try {
        picture(app.snapshot(3,2),"A  \n1  ","C-I04 initial scroll content control")
        app.batch({=>handle.value=Some(node(root).openOverlay(Text("P"),options:OverlayOptions(anchor:node(anchor.value.getOrThrow()),placement:OverlayPlacement.BelowStart,takeFocus:false)))})
        picture(app.snapshot(3,2),"A  \nP  ","C-I04 visible anchored overlay control")
        app.batch({=>node(root).ensureVisible(rect:Rect(0,4,1,1))})
        let frame=app.snapshot(3,2);let h=handle.value.getOrThrow();let offset=node(root).viewportSnapshot().offsetY
        println("C-I04 offset=${offset} open=${h.isOpen()} reason=${reason(h)} frame=[${frame.toPlainText()}]")
        check(offset==3,"C-I04 ensure target row4 in two rows commits offset3")
        check(!h.isOpen() && reason(h)=="AnchorGone","C-I04 same frame uses post-ensure anchor intersection")
        picture(frame,"3  \n4  ","C-I04 no floating layer after anchor scrolls out of host")
    }finally{app.dispose()}
}

func reviewThemeResult(request:ThemeRequest):String {
    match(request.result()){
        case Some(ThemeResult.Applied(_))=>"Applied"
        case Some(ThemeResult.Failed(_))=>"Failed"
        case Some(ThemeResult.Superseded(_))=>"Superseded"
        case Some(ThemeResult.SessionClosed)=>"SessionClosed"
        case None=>"Pending"
    }
}
func reviewOverlayCandidate():Unit {
    let old=Theme.parse("schema_version=1\nname='Old'\n[styles.grow.spacing]\nweight=0\nmin_width=0\n")
    let next=Theme.parse("schema_version=1\nname='Next'\n[styles.grow.spacing]\nweight=1\nmin_width=9223372036854775807\n")
    let mounts=Box<Int64>(0);let cleanups=Box<Int64>(0)
    let root=Column{}.viewport(ScrollAxes.Off)
    let layer=Row{Text("a").styles([StyleUse.Named("grow")]);Text("b").styles([StyleUse.Named("grow")])}.onMount({_=>mounts.value++;{=>cleanups.value++}})
    let app=Application(root,theme:old);app.startHeadless()
    try {
        app.batch({=>node(root).openOverlay(layer,options:OverlayOptions(takeFocus:false));()})
        let owner=node(root);let saved=node(layer)
        let baseline=app.snapshot(Int64.Max,0);let info=app.themeInfo()
        check(baseline.width==Int64.Max && baseline.height==0 && info.name=="Old" && mounts.value==1,"C-I05 legal old zero-area huge-width layout control")
        let request=app.loadTheme(ThemeSource.Prepared(next));var error=""
        try{app.snapshot(Int64.Max,0)}catch(e:Exception){error=e.message}
        let active=app.post({=>});let current=app.themeInfo()
        println("C-I05 result=${reviewThemeResult(request)} error=[${error}] theme=${current.name} revision=${current.revision} active=${active} rootValid=${owner.isValid()} layerValid=${saved.isValid()} mounts=${mounts.value} cleanups=${cleanups.value}")
        check(error.isEmpty() && reviewThemeResult(request)=="Failed","C-I05 predictable overlay minimum sum overflow rejected before publication")
        check(current.name=="Old" && current.revision==info.revision && current.requestId==info.requestId,"C-I05 failed candidate retains accepted theme identity")
        check(active && owner.isValid() && saved.isValid() && mounts.value==1 && cleanups.value==0,"C-I05 rejection preserves active original mounted session")
        let after=app.snapshot(Int64.Max,0)
        check(after.width==Int64.Max && after.height==0 && after.toPlainText()==baseline.toPlainText(),"C-I05 original zero-area picture remains usable")
        // Public snapshot includes legitimate layout. No cross-snapshot zero-call
        // oracle is used for measure/draw; forbidden preflight is source-audited.
    }finally{app.dispose()}
}

func reviewOverlayWeight():Unit {
    let old=Theme.parse("schema_version=1\nname='Old'\n");let next=Theme.parse("schema_version=1\nname='Next'\n")
    let root=Row{Text("B").layoutWeight(Int64.Max)}.viewport(ScrollAxes.Off)
    let app=Application(root,theme:old);app.startHeadless()
    try {
        app.batch({=>node(root).openOverlay(Text("P").layoutWeight(1),options:OverlayOptions(takeFocus:false));()})
        picture(app.snapshot(3,1),"BP ","C-I06 valid ordinary max weight plus independent layer control")
        check(node(root).children().size==1,"C-I06 overlay excluded from public ordinary children")
        let request=app.loadTheme(ThemeSource.Prepared(next));let frame=app.snapshot(3,1)
        println("C-I06 result=${reviewThemeResult(request)} theme=${app.themeInfo().name} frame=[${frame.toPlainText()}]")
        check(reviewThemeResult(request)=="Applied" && app.themeInfo().name=="Next","C-I06 overlay ownership weight never sums into ordinary flow")
        picture(frame,"BP ","C-I06 unchanged legal theme preserves composed picture")
    }finally{app.dispose()}
}

func reviewExplicitRootHost():Unit {
    let root=Text("B").viewport(ScrollAxes.Off);let app=Application(root);app.startHeadless()
    let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None);let observed=Box<String>("None")
    try {
        app.batch({=>try{handle.value=Some(node(root).openOverlay(Text("P"),options:OverlayOptions(host:node(root),takeFocus:false)))}catch(e:UIException){observed.value=e.code}})
        println("C-I07 explicitRootHost code=${observed.value} returned=${handle.value.isSome()}")
        check(observed.value=="None" && handle.value.isSome(),"C-I07 explicit application root has built-in host capability")
        check(handle.value.getOrThrow().isOpen() && handle.value.getOrThrow().content().isSome(),"C-I07 explicit root host commits real content")
        picture(app.snapshot(3,1),"BP ","C-I07 explicit root host centered geometry")
    }finally{app.dispose()}
}

func reviewRevokedPendingHost():Unit {
    let host=Box<?Component>(Option<Component>.None);let owner=Box<?Component>(Option<Component>.None)
    let root=Column{host.value=Some(Column{owner.value=Some(Text("O"))}.overlayHost(true))}.viewport(ScrollAxes.Off)
    let mounts=Box<Int64>(0);let cleanups=Box<Int64>(0)
    let content=Text("P").onMount({_=>mounts.value++;{=>cleanups.value++}})
    let app=Application(root);app.startHeadless();let rootRef=node(root)
    let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None);var observed="None"
    try {
        try{app.batch({=>handle.value=Some(node(owner.value.getOrThrow()).openOverlay(content,options:OverlayOptions(host:node(host.value.getOrThrow()),takeFocus:false)));host.value.getOrThrow().overlayHost(false);()})}catch(e:UIException){observed=e.code}
        println("C-I08 code=${observed} open=${handle.value.getOrThrow().isOpen()} mounts=${mounts.value} cleanups=${cleanups.value} rootValid=${rootRef.isValid()} mounted=${app.stats().mountedNodes}")
        check(observed=="InvalidOverlayHost","C-I08 pending commit revalidates revoked host capability")
        check(!handle.value.getOrThrow().isOpen() && handle.value.getOrThrow().content().isNone() && mounts.value==0 && cleanups.value==0 && content.reference().isNone(),"C-I08 illegal pending content never mounts or publishes")
        check(!rootRef.isValid(),"C-I08 structural failure revokes original session")
        released(app,"C-I08 unified failure cleanup releases all resources")
    }finally{app.dispose()}
}

func reviewPassiveDispatch():Unit {
    let calls=Box<Int64>(0);let root=Text("B").viewport(ScrollAxes.Off).onKey({_=>calls.value++})
    let app=Application(root);app.startHeadless();let normal=Text("N");let passive=Text("P")
    let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    try {
        app.batch({=>handle.value=Some(node(root).openOverlay(normal,options:OverlayOptions(takeFocus:false)))})
        app.dispatch(node(normal),KeyEvent("text",text:"x"))
        check(calls.value==1,"C-I09 normal NonModal dispatch reaches owner control")
        app.batch({=>handle.value.getOrThrow().close();()});calls.value=0
        app.batch({=>node(root).openOverlay(passive,options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false));()})
        var observed="None"
        try{app.dispatch(node(passive),KeyEvent("text",text:"x"))}catch(e:UIException){observed=e.code}
        println("C-I09 passiveDispatch code=${observed} ownerCalls=${calls.value}")
        check(observed=="InvalidProperty" && calls.value==0,"C-I09 Passive explicit keyboard target rejected before business route")
    }finally{app.dispose()}
}

func reviewSameViewport(a:ViewportSnapshot,b:ViewportSnapshot):Bool {
    return a.width==b.width && a.height==b.height && a.contentWidth==b.contentWidth && a.contentHeight==b.contentHeight && a.offsetX==b.offsetX && a.offsetY==b.offsetY && a.axes==b.axes
}
func reviewPureExportGeometry():Unit {
    let root=Text("A").viewport(ScrollAxes.Off);let layer=Text("P").viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();let rootRef=node(root)
    let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    try {
        app.batch({=>handle.value=Some(rootRef.openOverlay(layer,options:OverlayOptions(anchor:rootRef,placement:OverlayPlacement.BelowStart,takeFocus:false)))})
        let h=handle.value.getOrThrow();let saved=node(layer);let rootBefore=rootRef.viewportSnapshot();let layerBefore=saved.viewportSnapshot()
        check(rootBefore.width==0 && rootBefore.height==0 && h.isOpen(),"C-I10 first export has no preceding application snapshot")
        let first=render(root,3,2);let second=render(root,5,3)
        let freshPreserved=h.isOpen() && saved.isValid() && reviewSameViewport(rootBefore,rootRef.viewportSnapshot()) && reviewSameViewport(layerBefore,saved.viewportSnapshot())
        let committed=app.snapshot(3,2);let rootCommitted=rootRef.viewportSnapshot();let layerCommitted=saved.viewportSnapshot()
        let larger=render(root,5,3);let smaller=render(root,1,1)
        let committedPreserved=h.isOpen() && reason(h)=="None" && node(root).sameNode(rootRef) && h.content().getOrThrow().sameNode(saved) && reviewSameViewport(rootCommitted,rootRef.viewportSnapshot()) && reviewSameViewport(layerCommitted,saved.viewportSnapshot())
        println("C-I10 first3x2=[${first.toPlainText()}] fresh5x3=[${second.toPlainText()}] committed3x2=[${committed.toPlainText()}] larger5x3=[${larger.toPlainText()}] smaller1x1=[${smaller.toPlainText()}] freshPreserved=${freshPreserved} committedPreserved=${committedPreserved}")
        picture(first,"A  \nP  ","C-I10 first pure export includes current anchored layer")
        picture(second,"A    \n     \nP    ","C-I10 fresh export uses its own5x3 geometry")
        check(freshPreserved,"C-I10 fresh exports leave application committed viewports untouched")
        picture(committed,"A  \nP  ","C-I10 first real application snapshot remains usable")
        picture(larger,"A    \n     \nP    ","C-I10 resized export uses current temporary host geometry")
        picture(smaller,"P","C-I10 one-cell export composes anchored layer at clamped origin")
        check(committedPreserved,"C-I10 different export sizes preserve live handle refs and application3x2 committed geometry")
    }finally{app.dispose()}
}

func reviewRegression(name:String):Int64 {
    match(name){
        case "C-I01"=>reviewOwnerRevocation()
        case "C-I02"=>reviewDeclarativeOwner()
        case "C-I03"=>reviewHiddenAndDisabledLayer()
        case "C-I04"=>reviewEnsureAnchor()
        case "C-I05"=>reviewOverlayCandidate()
        case "C-I06"=>reviewOverlayWeight()
        case "C-I07"=>reviewExplicitRootHost()
        case "C-I08"=>reviewRevokedPendingHost()
        case "C-I09"=>reviewPassiveDispatch()
        case "C-I10"=>reviewPureExportGeometry()
        case _=>throw Exception("unknown formal review regression ${name}")
    }
    return 0
}
