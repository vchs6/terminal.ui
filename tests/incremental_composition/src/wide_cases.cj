package incremental_composition

import cjtui.*

func widePartners(): Unit {
    let epoch = [Int64(0)]; let mode = Observable<Int64>(0)
    let base = DrawProbe("wide-base",8,3); let upper = DrawProbe("wide-overlay",3,1)
    let root = Canvas({_ => Size(8,3)},{p => base.record(p); p.put(0,0,"12345678"); p.put(0,1,"ab界efgh"); p.put(0,2,"87654321") }).viewport(ScrollAxes.Off)
    let cover = Canvas({_ => Size(3,1)},{p =>
        upper.record(p)
        match (mode.get()) {
            case 1 => p.put(1,0," ")
            case 2 => p.put(-1,0,"界Q")
            case 3 => p.put(2,0,"界")
            case _ => ()
        }
    })
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    try {
        advance(app,epoch,{ => node(root).openOverlay(cover,options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false)); () })
        let intact = [row(["1","2","3","4","5","6","7","8"]),
            [ExpectedCell("a"),ExpectedCell("b"),ExpectedCell("界",width:2),ExpectedCell("",width:0,continuation:true),ExpectedCell("e"),ExpectedCell("f"),ExpectedCell("g"),ExpectedCell("h")],
            row(["8","7","6","5","4","3","2","1"])]
        paired(app,root,epoch,8,3,intact,[base,upper],[1,1],"wide under transparent layer")
        advance(app,epoch,{ => mode.set(1) })
        paired(app,root,epoch,8,3,[row(["1","2","3","4","5","6","7","8"]),row(["a","b"," "," ","e","f","g","h"]),row(["8","7","6","5","4","3","2","1"])],[base,upper],[1,1],"write on target continuation clears partner outside one-cell write")
        advance(app,epoch,{ => mode.set(2) })
        paired(app,root,epoch,8,3,[row(["1","2","3","4","5","6","7","8"]),row(["a","b"," ","Q","e","f","g","h"]),row(["8","7","6","5","4","3","2","1"])],[base,upper],[1,1],"negative Canvas coordinate skips whole source cluster then advances")
        advance(app,epoch,{ => mode.set(3) })
        paired(app,root,epoch,8,3,intact,[base,upper],[1,1],"right clipped source leaves no half cluster")
    } finally { app.dispose() }
}

func negativeFrameTransfer(): Unit {
    let target = Frame(6,1); target.put(0,0,"ab界ef")
    let layer = Frame(3,1,transparent:true); layer.put(0,0,"界",style:Style(foreground:Color.Red))
    layer.put(2,0,"Q")
    literal(layer,[[ExpectedCell("界",width:2,style:Style(foreground:Color.Red)),
        ExpectedCell("",width:0,continuation:true,style:Style(foreground:Color.Red)),ExpectedCell("Q")]],"literal source before negative transfer")
    target.composite(layer,x:-1)
    literal(target,[[ExpectedCell(" ",style:Style(foreground:Color.Red)),ExpectedCell("Q"),ExpectedCell("界",width:2),
        ExpectedCell("",width:0,continuation:true),ExpectedCell("e"),ExpectedCell("f")]],"negative source half is opaque styled single blank")
    let hole = Frame(1,1,transparent:true)
    literal(hole,[[ExpectedCell(" ",transparent:true)]],"canonical transparent hole")
    target.composite(hole,x:3)
    literal(target,[[ExpectedCell(" ",style:Style(foreground:Color.Red)),ExpectedCell("Q"),ExpectedCell("界",width:2),
        ExpectedCell("",width:0,continuation:true),ExpectedCell("e"),ExpectedCell("f")]],"transparent continuation overlay skips target cluster")
    hole.put(0,0," "); target.composite(hole,x:3)
    literal(target,[[ExpectedCell(" ",style:Style(foreground:Color.Red)),ExpectedCell("Q"),ExpectedCell(" "),ExpectedCell(" "),ExpectedCell("e"),ExpectedCell("f")]],"opaque single blank clears complete target wide partner")
}
