package interaction_c
import cjtui.*

func pureExportPreservesCommittedOverlay():Unit {
    let root=Text("A").viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    try {
        app.snapshot(4,2)
        let rootRef=node(root)
        let content=Canvas({_=>Size(8,1)},{p=>p.put(0,0,"abcdefgh")}).viewport(ScrollAxes.Horizontal).width(2).height(1)
        let saved=Box<?OverlayHandle>(Option<OverlayHandle>.None)
        app.batch({=>saved.value=Some(rootRef.openOverlay(content,options:OverlayOptions(anchor:rootRef,placement:OverlayPlacement.BelowStart,takeFocus:false)))})
        let handle=saved.value.getOrThrow();let layer=handle.content().getOrThrow()
        app.snapshot(4,2)
        app.batch({=>layer.scrollTo(3,0);()})
        picture(app.snapshot(4,2),"A   \nde  ","X01 committed application4x2/anchored viewport offset3 control")
        check(handle.isOpen() && layer.isValid() && layer.viewportSnapshot().offsetX==3,"X01 live committed layer control")
        // A legal turn may leave ensure for the next layout or already apply it.
        // Preserve whichever geometry is committed, then prove the hand target.
        app.batch({=>layer.ensureVisible(rect:Rect(6,0,1,1))})
        let committedOffset=layer.viewportSnapshot().offsetX
        let exported=render(root,0,0)
        let actualOffset=if(layer.isValid()){layer.viewportSnapshot().offsetX}else{-1}
        println("X01 pure0x0 open=${handle.isOpen()} reason=${reason(handle)} rootValid=${rootRef.isValid()} layerValid=${layer.isValid()} offset=${actualOffset} previous=${committedOffset}")
        check(exported.width==0 && exported.height==0,"X01 actual pure export has zero dimensions")
        check(handle.isOpen() && layer.isValid() && handle.content().getOrThrow().sameNode(layer),"X01 pure export must preserve committed anchored layer and identity")
        check(reason(handle)=="None" && node(root).sameNode(rootRef),"X01 pure export preserves handle/root generation")
        check(layer.viewportSnapshot().offsetX==committedOffset,"X01 pure export preserves committed viewport offset")
        check(rootRef.application().stats().mountedNodes==2,"X01 original active application still owns both real nodes")
        picture(app.snapshot(4,2),"A   \nfg  ","X01 next application target honors ensure6 and original4x2 geometry")
        check(layer.viewportSnapshot().offsetX==5 && handle.isOpen(),"X01 pending ensure survives pure export")
    } finally {app.dispose()}
}

func overlayOpenRequiresActiveTurn():Unit {
    let root=Column{}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    let mounts=Box<Int64>(0);let cleanups=Box<Int64>(0)
    let content=Text("allowed").onMount({_=>mounts.value++;{=>cleanups.value++}})
    try {
        let owner=node(root);let before=app.stats().mountedNodes
        let unexpected=Box<?OverlayHandle>(Option<OverlayHandle>.None)
        var observed="NO_ERROR"
        try {unexpected.value=Some(owner.openOverlay(content,options:OverlayOptions(takeFocus:false)))}catch(e:UIException){observed=e.code}
        println("X02 top-level open code=${observed} handleReturned=${unexpected.value.isSome()} mounts=${mounts.value} mounted=${app.stats().mountedNodes}")
        check(observed=="WrongUIContext","X02 top-level open outside event/post/batch rejects WrongUIContext")
        check(unexpected.value.isNone() && mounts.value==0 && cleanups.value==0 && content.reference().isNone() && app.stats().mountedNodes==before,"X02 rejection has no reservation/mount side effects")
        let accepted=Box<?OverlayHandle>(Option<OverlayHandle>.None)
        app.batch({=>accepted.value=Some(owner.openOverlay(content,options:OverlayOptions(takeFocus:false)))})
        check(accepted.value.getOrThrow().isOpen() && accepted.value.getOrThrow().content().getOrThrow().sameNode(node(content)),"X02 same content legally opens in batch after rejection")
        check(mounts.value==1 && app.stats().mountedNodes==before+1,"X02 same content reserved/mounted exactly once in legal turn")
    } finally {app.dispose()}
    check(cleanups.value==1,"X02 legal batch content cleanup once")
}

func exportTurnRegression(name:String):Int64 {
    match(name){
        case "pure-export"=>pureExportPreservesCommittedOverlay()
        case "open-turn"=>overlayOpenRequiresActiveTurn()
        case _=>throw Exception("unknown export/turn regression ${name}")
    }
    return 0
}
