package incremental_composition

import cjtui.*

func coveredCaretAcrossDamageRows(): Unit {
    let epoch = [Int64(0)]; let lowerValue = Observable<String>("X")
    let ownerProbe = DrawProbe("three-row-caret-owner",6,3)
    let coverProbe = DrawProbe("clean-opaque-caret-cover",2,1)
    let lowerProbe = DrawProbe("other-row-overlay",2,1)
    let anchors = [Option<Component>.None,Option<Component>.None]
    let ownerHolder = [Option<Component>.None]
    let root = Column {
        anchors[0] = Some(Text("aaaaaa").height(1))
        ownerHolder[0] = Some(Canvas({_ => Size(6,3)},{p =>
            ownerProbe.record(p)
            p.put(0,0,"bbbbbb"); p.put(0,1,"cccccc"); p.put(0,2,"dddddd"); p.caret(1,0)
        }).width(6).height(3).focusable(true))
        anchors[1] = Some(Text("eeeeee").height(1))
    }.viewport(ScrollAxes.Off)
    let owner = ownerHolder[0].getOrThrow()
    // The top layer writes the same glyph and Style as the owner's caret cell.
    // It remains an opaque source even though those Cell values are identical.
    let cover = Canvas({_ => Size(2,1)},{p => coverProbe.record(p); p.put(1,0,"b") })
    let lower = Canvas({_ => Size(2,1)},{p => lowerProbe.record(p); p.put(0,0,lowerValue.get()) })
    let probes = [ownerProbe,coverProbe,lowerProbe]
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    let first = row(["a","a","a","a","a","a"])
    let caretRow = row(["b","b","b","b","b","b"])
    let middle = row(["c","c","c","c","c","c"])
    let last = row(["e","e","e","e","e","e"])
    try {
        paired(app,root,epoch,6,5,[first,caretRow,middle,row(["d","d","d","d","d","d"]),last],probes,[1,0,0],"multi-row owner initial caret")
        caret(app,owner,1,1,"multi-row owner initial visible caret")
        advance(app,epoch,{ =>
            node(root).openOverlay(cover,options:OverlayOptions(mode:OverlayMode.Passive,
                anchor:Some(node(anchors[0].getOrThrow())),placement:OverlayPlacement.BelowStart,takeFocus:false))
            node(root).openOverlay(lower,options:OverlayOptions(mode:OverlayMode.Passive,
                anchor:Some(node(anchors[1].getOrThrow())),placement:OverlayPlacement.AboveStart,takeFocus:false))
            ()
        })
        paired(app,root,epoch,6,5,[first,caretRow,middle,row(["X","d","d","d","d","d"]),last],probes,[1,1,1],"caret covered on owner local row zero")
        noCaret(app,"opaque source on screen row one hides owner caret")
        Checks.equal(app.focusedNode().getOrThrow().sameNode(node(owner)),"passive layers preserve owner focus")
        advance(app,epoch,{ => lowerValue.set("Y") })
        paired(app,root,epoch,6,5,[first,caretRow,middle,row(["Y","d","d","d","d","d"]),last],probes,[1,0,1],"owner local row two changes while caret cover stays clean")
        let observed = app.caretSnapshot()
        println("CARET covered-other-row visible=${observed.visible} x=${observed.x} y=${observed.y} owner_present=${observed.owner.isSome()}")
        noCaret(app,"clean opaque row-one cover still hides caret after owner redraw for row three")
        Checks.equal(app.focusedNode().getOrThrow().sameNode(node(owner)),"other-row update preserves owner focus")
    } finally { app.dispose() }
}
