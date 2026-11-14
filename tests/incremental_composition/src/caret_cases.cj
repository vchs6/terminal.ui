package incremental_composition

import cjtui.*

func cachedCaretAndOwnership(): Unit {
    let epoch = [Int64(0)]; let position = Observable<Int64>(1); let text = Observable<String>("AAAAAA")
    let written = Observable<Bool>(false)
    let first = DrawProbe("cached-caret-owner",6,1); let second = DrawProbe("other-row",6,1)
    let top = DrawProbe("opaque-identical-space",6,1)
    let holder = [Option<Component>.None]; let peer = [Option<Component>.None]
    let root = Column {
        holder[0] = Some(Canvas({_ => Size(6,1)},{p => first.record(p); p.caret(position.get(),0) })
            .height(1).focusable(true).overlayHost(true))
        Canvas({_ => Size(6,1)},{p => second.record(p); p.put(0,0,text.get()) }).height(1)
        peer[0] = Some(Text("P").height(1).focusable(true))
    }.viewport(ScrollAxes.Off)
    let owner = holder[0].getOrThrow()
    let overlay = Canvas({_ => Size(6,1)},{p => top.record(p); if (written.get()) { p.put(2,0," ") } })
    let handle = [Option<OverlayHandle>.None]
    let probes = [first,second,top]
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    try {
        let initial = [row([" "," "," "," "," "," "]),row(["A","A","A","A","A","A"]),row(["P"," "," "," "," "," "])]
        paired(app,root,epoch,6,3,initial,probes,[1,1,0],"caret initial blank owner")
        caret(app,owner,1,0,"initial logical caret")
        advance(app,epoch,{ => text.set("BBBBBB") })
        let stableGrid = [row([" "," "," "," "," "," "]),row(["B","B","B","B","B","B"]),row(["P"," "," "," "," "," "])]
        paired(app,root,epoch,6,3,stableGrid,probes,[0,1,0],"other-row repaint preserves skipped Canvas caret")
        caret(app,owner,1,0,"cached undrawn owner request")
        advance(app,epoch,{ => position.set(2) })
        let before = paired(app,root,epoch,6,3,stableGrid,probes,[1,0,0],"caret-only movement equal grid")
        caret(app,owner,2,0,"caret moves independently of frame equality")
        advance(app,epoch,{ => handle[0] = Some(node(owner).openOverlay(overlay,options:OverlayOptions(mode:OverlayMode.Passive,host:Some(node(owner)),takeFocus:false))) })
        let hole = paired(app,root,epoch,6,3,stableGrid,probes,[1,0,1],"transparent overlay keeps caret")
        sameCells(before,hole,"transparent cover unchanged raw grid")
        caret(app,owner,2,0,"hole preserves owner")
        advance(app,epoch,{ => written.set(true) })
        let covered = paired(app,root,epoch,6,3,stableGrid,probes,[1,0,1],"opaque default space same cells hides caret")
        sameCells(hole,covered,"source ownership changes despite identical Cell values")
        noCaret(app,"opaque StyledSpace covers matching default blank")
        Checks.equal(app.focusedNode().getOrThrow().sameNode(node(owner)),"passive layer preserves underlying logical focus")
        advance(app,epoch,{ => handle[0].getOrThrow().close() })
        paired(app,root,epoch,6,3,stableGrid,probes,[1,0,0],"close cover recalculates cached owner caret")
        caret(app,owner,2,0,"cover close restores live owner")
        advance(app,epoch,{ => owner.visible(false) })
        let hidden = [row(["B","B","B","B","B","B"]),row(["P"," "," "," "," "," "]),row([" "," "," "," "," "," "])]
        paired(app,root,epoch,6,3,hidden,probes,[0,1,0],"hidden caret owner clears prior row")
        noCaret(app,"hidden owner cannot resurrect cached request")
        advance(app,epoch,{ => owner.visible(true); node(peer[0].getOrThrow()).requestFocus() })
        paired(app,root,epoch,6,3,stableGrid,probes,[-1,-1,0],"shown owner remains unfocused")
        noCaret(app,"unfocused shown Canvas cannot resurrect request")
        advance(app,epoch,{ => node(owner).requestFocus() })
        paired(app,root,epoch,6,3,stableGrid,probes,[1,0,0],"explicit focus restores caret")
        caret(app,owner,2,0,"refocused owner")
        let stale = node(owner)
        advance(app,epoch,{ => node(root).remove(stale) })
        paired(app,root,epoch,6,3,hidden,probes,[0,1,0],"unmounted owner old paint cleared")
        Checks.equal(!stale.isValid(),"removed caret owner reference stale")
        noCaret(app,"unmounted owner cannot resurrect cached request")
    } finally { app.dispose() }
    noCaret(app,"disposed application clears caret")
}

func invalidCaretRequests(): Unit {
    let epoch = [Int64(0)]; let x = Observable<Int64>(0); let visible = Observable<Bool>(true)
    let probe = DrawProbe("wide-caret",4,1)
    let root = Canvas({_ => Size(4,1)},{p => probe.record(p); p.put(0,0,"界  "); p.caret(x.get(),0,visible:visible.get()) }).focusable(true)
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    let grid = [[ExpectedCell("界",width:2),ExpectedCell("",width:0,continuation:true),ExpectedCell(" "),ExpectedCell(" ")]]
    try {
        paired(app,root,epoch,4,1,grid,[probe],[1],"wide anchor caret control")
        caret(app,root,0,0,"wide anchor is valid caret cell")
        for (invalid in [Int64(1),4,-1]) {
            advance(app,epoch,{ => x.set(invalid) })
            paired(app,root,epoch,4,1,grid,[probe],[1],"invalid caret coordinate ${invalid}")
            noCaret(app,"continuation or out-of-range request ${invalid}")
        }
        advance(app,epoch,{ => x.set(0); visible.set(false) })
        paired(app,root,epoch,4,1,grid,[probe],[1],"explicit invisible caret")
        noCaret(app,"explicit invisible request wins")
    } finally { app.dispose() }
}
