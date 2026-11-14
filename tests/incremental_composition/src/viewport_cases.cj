package incremental_composition

import cjtui.*

func scrollAndAnchor(): Unit {
    let epoch = [Int64(0)]; let scroll = [Option<Component>.None]; let anchor = [Option<Component>.None]
    let upper = DrawProbe("anchored-layer",2,1)
    let root = Column {
        Text("H").height(1)
        scroll[0] = Some(ScrollView {
            Text("AAAAAA").height(1)
            anchor[0] = Some(Text("BBBBBB").height(1))
            Text("CCCCCC").height(1); Text("DDDDDD").height(1)
        }.width(6).height(2))
        Text("F").height(1)
    }.viewport(ScrollAxes.Off)
    let popup = Canvas({_ => Size(2,1)},{p => upper.record(p); p.put(0,0,"XY")})
    let handle = [Option<OverlayHandle>.None]
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    try {
        paired(app,root,epoch,6,4,[row(["H"," "," "," "," "," "]),row(["A","A","A","A","A","A"]),row(["B","B","B","B","B","B"]),row(["F"," "," "," "," "," "])],[upper],[0],"viewport initial")
        advance(app,epoch,{ => handle[0] = Some(node(root).openOverlay(popup,options:OverlayOptions(anchor:Some(node(anchor[0].getOrThrow())),placement:OverlayPlacement.BelowStart,takeFocus:false))) })
        paired(app,root,epoch,6,4,[row(["H"," "," "," "," "," "]),row(["A","A","A","A","A","A"]),row(["B","B","B","B","B","B"]),row(["X","Y"," "," "," "," "])],[upper],[1],"anchor below crosses viewport into host")
        advance(app,epoch,{ => Checks.equal(node(scroll[0].getOrThrow()).scrollTo(0,1),"scroll action accepted") })
        paired(app,root,epoch,6,4,[row(["H"," "," "," "," "," "]),row(["B","B","B","B","B","B"]),row(["X","Y","C","C","C","C"]),row(["F"," "," "," "," "," "])],[upper],[1],"scroll moves anchor and clears old popup row")
        advance(app,epoch,{ => Checks.equal(node(scroll[0].getOrThrow()).scrollTo(0,2),"second scroll accepted") })
        paired(app,root,epoch,6,4,[row(["H"," "," "," "," "," "]),row(["C","C","C","C","C","C"]),row(["D","D","D","D","D","D"]),row(["F"," "," "," "," "," "])],[upper],[0],"clipped anchor closes and clears layer")
        Checks.equal(!handle[0].getOrThrow().isOpen() && handle[0].getOrThrow().closeReason() == Some(OverlayCloseReason.AnchorGone),"fully clipped anchor closes with AnchorGone")
    } finally { app.dispose() }
}

func viewportCaret(): Unit {
    let epoch = [Int64(0)]; let probe = DrawProbe("scrolling-caret",6,4)
    let content = [Option<Component>.None]
    // ScrollView itself is focusable by default; this fixture needs the Canvas
    // to own focus so its caret request is eligible in the public contract.
    let root = ScrollView {
        content[0] = Some(Canvas({_ => Size(6,4)},{p =>
            probe.record(p); p.put(0,0,"AAAAAA"); p.put(0,1,"BBBBBB"); p.put(0,2,"CCCCCC"); p.put(0,3,"DDDDDD"); p.caret(1,2)
        }).width(6).height(4).focusable(true))
    }.focusable(false)
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    try {
        probe.expected = DrawObservation(6,4,Rect(0,0,6,2))
        paired(app,root,epoch,6,2,[row(["A","A","A","A","A","A"]),row(["B","B","B","B","B","B"])],[probe],[1],"caret outside viewport")
        noCaret(app,"initial clipped caret")
        advance(app,epoch,{ => node(root).scrollTo(0,1); () })
        probe.expected = DrawObservation(6,4,Rect(0,1,6,2))
        paired(app,root,epoch,6,2,[row(["B","B","B","B","B","B"]),row(["C","C","C","C","C","C"])],[probe],[1],"viewport moves caret into visible row")
        caret(app,content[0].getOrThrow(),1,1,"transformed viewport caret")
        probe.expected = DrawObservation(3,4,Rect(0,1,3,2))
        paired(app,root,epoch,3,2,[row(["B","B","B"]),row(["C","C","C"])],[probe],[1],"resize narrows allocation and original viewport clip")
        caret(app,content[0].getOrThrow(),1,1,"resized visible caret")
        advance(app,epoch,{ => node(root).scrollTo(0,2); () })
        probe.expected = DrawObservation(3,4,Rect(0,2,3,2))
        paired(app,root,epoch,3,2,[row(["C","C","C"]),row(["D","D","D"])],[probe],[1],"scroll recomputes caret transformation")
        caret(app,content[0].getOrThrow(),1,0,"top-row caret after scroll")
    } finally { app.dispose() }
    noCaret(app,"disposed viewport cannot retain caret")
}
