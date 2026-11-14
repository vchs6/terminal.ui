package incremental_composition

import cjtui.*

func descendantShadows(): Unit {
    let epoch = [Int64(0)]; let lower = Observable<String>("ABCDEFGH")
    let base = DrawProbe("base",8,5); let child = DrawProbe("descendant-shadow",2,1)
    let root = Canvas({_ => Size(8,5)},{p =>
        base.record(p)
        p.put(0,0,"ABCDEFGH"); p.put(0,1,"ABCDEFGH"); p.put(0,2,lower.get())
        p.put(0,3,"ABCDEFGH"); p.put(0,4,"ABCDEFGH")
    }).viewport(ScrollAxes.Off)
    let descendant = [Option<Component>.None]
    let layer = Column {
        descendant[0] = Some(Canvas({_ => Size(2,1)},{p => child.record(p); p.put(0,0,"XY")})
            .width(2).height(1).shadow(style:Style(dim:true)))
    }.width(4).height(3).surface(SurfaceMode.Transparent)
    let handle = [Option<OverlayHandle>.None]
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    try {
        paired(app,root,epoch,8,5,baseShadowGrid(false,false),[base,child],[1,0],"shadow initial")
        advance(app,epoch,{ => handle[0] = Some(node(root).openOverlay(layer,options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false))) })
        paired(app,root,epoch,8,5,baseShadowGrid(true,false),[base,child],[1,1],"descendant extends parent own empty paint")
        advance(app,epoch,{ => lower.set("abcdefgh") })
        paired(app,root,epoch,8,5,baseShadowGrid(true,true),[base,child],[1,1],"clean descendant shadow replays over changed lower row")
        advance(app,epoch,{ => descendant[0].getOrThrow().shadow(offsetX:2,offsetY:1,style:Style(dim:true)) })
        let shifted = baseShadowGrid(false,true)
        shifted[1] = row(["A","B","X","Y","E","F","G","H"])
        shifted[2][4] = ExpectedCell("░",style:Style(dim:true)); shifted[2][5] = ExpectedCell("░",style:Style(dim:true))
        paired(app,root,epoch,8,5,shifted,[base,child],[1,1],"shadow offset clears old extent")
        advance(app,epoch,{ => descendant[0].getOrThrow().shadow(enabled:false) })
        let removed = baseShadowGrid(false,true); removed[1] = row(["A","B","X","Y","E","F","G","H"])
        paired(app,root,epoch,8,5,removed,[base,child],[1,1],"shadow disabled removes old extent")
        advance(app,epoch,{ => handle[0].getOrThrow().close() })
        paired(app,root,epoch,8,5,baseShadowGrid(false,true),[base,child],[1,0],"shadow layer close restores latest background")
    } finally { app.dispose() }
}

func baseShadowGrid(shadow: Bool, lower: Bool): Array<Array<ExpectedCell>> {
    let result = [row(["A","B","C","D","E","F","G","H"]),row(["A","B","C","D","E","F","G","H"]),
        if (lower) { row(["a","b","c","d","e","f","g","h"]) } else { row(["A","B","C","D","E","F","G","H"]) },
        row(["A","B","C","D","E","F","G","H"]),row(["A","B","C","D","E","F","G","H"])]
    if (shadow) {
        result[1] = row(["A","B","X","Y","E","F","G","H"])
        result[2][3] = ExpectedCell("░",style:Style(dim:true)); result[2][4] = ExpectedCell("░",style:Style(dim:true))
    }
    result
}

func movedShadowLayer(): Unit {
    let epoch = [Int64(0)]; let base = DrawProbe("resized-base",8,5); let upper = DrawProbe("resized-layer",2,1)
    let root = Canvas({_ => Size(8,5)},{p => base.record(p); for (y in 0..5) { p.put(0,y,"abcdefgh") } }).viewport(ScrollAxes.Off)
    let cover = Canvas({_ => Size(2,1)},{p => upper.record(p); p.put(0,0,"XY")}).shadow(style:Style(dim:true))
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    try {
        advance(app,epoch,{ => node(root).openOverlay(cover,options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false)); () })
        let small = [row(["a","b","c","d","e","f","g","h"]),row(["a","b","c","d","e","f","g","h"]),
            row(["a","b","c","X","Y","f","g","h"]),row(["a","b","c","d","░","░","g","h"]),row(["a","b","c","d","e","f","g","h"])]
        small[3][4] = ExpectedCell("░",style:Style(dim:true)); small[3][5] = ExpectedCell("░",style:Style(dim:true))
        paired(app,root,epoch,8,5,small,[base,upper],[1,1],"centered shadow initial")
        base.expected = DrawObservation(10,5,Rect(0,0,10,5))
        let large = [row(["a","b","c","d","e","f","g","h"," "," "]),row(["a","b","c","d","e","f","g","h"," "," "]),
            row(["a","b","c","d","X","Y","g","h"," "," "]),row(["a","b","c","d","e","░","░","h"," "," "]),row(["a","b","c","d","e","f","g","h"," "," "])]
        large[3][5] = ExpectedCell("░",style:Style(dim:true)); large[3][6] = ExpectedCell("░",style:Style(dim:true))
        paired(app,root,epoch,10,5,large,[base,upper],[1,1],"resize moves layer and shadow old-new bounds")
    } finally { app.dispose() }
}

func shadowCaretOcclusion(): Unit {
    let epoch = [Int64(0)]; let probe = DrawProbe("shadow-caret-owner",8,5)
    let root = Canvas({_ => Size(8,5)},{p => probe.record(p); p.caret(6,2) }).focusable(true).viewport(ScrollAxes.Off)
    let layer = Text("").width(4).height(3).surface(SurfaceMode.Transparent).shadow(style:Style(dim:true))
    let handle = [Option<OverlayHandle>.None]
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    let blank = [row([" "," "," "," "," "," "," "," "]),row([" "," "," "," "," "," "," "," "]),
        row([" "," "," "," "," "," "," "," "]),row([" "," "," "," "," "," "," "," "]),row([" "," "," "," "," "," "," "," "])]
    try {
        paired(app,root,epoch,8,5,blank,[probe],[1],"shadow caret initial")
        caret(app,root,6,2,"uncovered caret")
        advance(app,epoch,{ => handle[0] = Some(node(root).openOverlay(layer,options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false))) })
        let shadow = [row([" "," "," "," "," "," "," "," "]),row([" "," "," "," "," "," "," "," "]),
            row([" "," "," "," "," "," "," "," "]),row([" "," "," "," "," "," "," "," "]),row([" "," "," "," "," "," "," "," "])]
        shadow[2][6] = ExpectedCell("░",style:Style(dim:true)); shadow[3][6] = ExpectedCell("░",style:Style(dim:true))
        for (x in 3..7) { shadow[4][x] = ExpectedCell("░",style:Style(dim:true)) }
        paired(app,root,epoch,8,5,shadow,[probe],[1],"opaque shadow covers caret")
        noCaret(app,"shadow is an opaque contribution")
        advance(app,epoch,{ => handle[0].getOrThrow().close() })
        paired(app,root,epoch,8,5,blank,[probe],[1],"shadow close restores empty grid")
        caret(app,root,6,2,"shadow close restores live cached caret")
    } finally { app.dispose() }
}
