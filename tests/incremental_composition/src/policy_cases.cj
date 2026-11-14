package incremental_composition

import cjtui.*

func layeredGlyphPolicy(): Unit {
    let epoch = [Int64(0)]; let upper = DrawProbe("policy-clean-overlay",2,1)
    let root = Column { Text("abcdef").overflow(TextOverflow.Ellipsis); Text("Z") }.viewport(ScrollAxes.Off)
    let cover = Canvas({_ => Size(2,1)},{p => upper.record(p); p.put(0,0,"X") })
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    try {
        advance(app,epoch,{ => node(root).openOverlay(cover,options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false)); () })
        paired(app,root,epoch,5,2,[row(["a","X","c","d","…"]),row(["Z"," "," "," "," "])],[upper],[1],"Unicode marker under transparent layer")
        paired(app,root,epoch,5,2,[row(["a","X",".",".","."]),row(["Z"," "," "," "," "])],[upper],[1],"Ascii marker redraws intersecting clean layer",glyphMode:GlyphMode.Ascii)
        paired(app,root,epoch,5,2,[row(["a","X","c","d","…"]),row(["Z"," "," "," "," "])],[upper],[1],"Unicode marker policy restored")
    } finally { app.dispose() }
}

func rootFallbackLayers(): Unit {
    let epoch = [Int64(0)]; let upper = DrawProbe("implicit-root-overlay",2,1)
    let root = Column { Text("AAAA"); Text("BBBB"); Text("CCCC"); Text("DDDD") }
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    try {
        paired(app,root,epoch,4,2,[row(["A","A","A","A"]),row(["B","B","B","B"])],[upper],[0],"implicit root actual overflow")
        Checks.equal(node(root).viewportSnapshot().contentHeight == 4,"implicit root natural overflow extent")
        let layer = Canvas({_ => Size(2,1)},{p => upper.record(p); p.put(0,0,"XY") })
        advance(app,epoch,{ => node(root).openOverlay(layer,options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false)); () })
        paired(app,root,epoch,4,2,[row(["A","X","Y","A"]),row(["B","B","B","B"])],[upper],[1],"implicit root layer before scroll")
        advance(app,epoch,{ => Checks.equal(node(root).scrollTo(0,2),"implicit root scroll accepted") })
        paired(app,root,epoch,4,2,[row(["C","X","Y","C"]),row(["D","D","D","D"])],[upper],[1],"mounted M1 consumes implicit root offset and layers")
        Checks.equal(node(root).viewportSnapshot().offsetY == 2,"reference leaves committed root offset intact")
    } finally { app.dispose() }
}
