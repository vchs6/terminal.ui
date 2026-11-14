package incremental_composition

import cjtui.*

func surfacesAndLatest(): Unit {
    let epoch = [Int64(0)]; let blank = Observable<Bool>(false); let lower = Observable<String>("ijklmnop")
    let base = DrawProbe("base-full-context",8,3); let upper = DrawProbe("hole-or-space",3,1)
    let root = Canvas({_ => Size(8,3)},{p =>
        base.record(p); p.put(0,0,"abcdefgh"); p.put(0,1,lower.get()); p.put(0,2,"qrstuvwx")
    }).viewport(ScrollAxes.Off)
    let cover = Canvas({_ => Size(3,1)},{p => upper.record(p); p.put(0,0,"X"); if (blank.get()) { p.put(1,0," ") } })
    let handle = [Option<OverlayHandle>.None]
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    try {
        paired(app,root,epoch,8,3,[row(["a","b","c","d","e","f","g","h"]),row(["i","j","k","l","m","n","o","p"]),row(["q","r","s","t","u","v","w","x"])],[base,upper],[1,0],"surface initial")
        advance(app,epoch,{ => handle[0] = Some(node(root).openOverlay(cover,options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false))) })
        paired(app,root,epoch,8,3,[row(["a","b","c","d","e","f","g","h"]),row(["i","j","X","l","m","n","o","p"]),row(["q","r","s","t","u","v","w","x"])],[base,upper],[1,1],"transparent holes pass base")
        advance(app,epoch,{ => blank.set(true) })
        paired(app,root,epoch,8,3,[row(["a","b","c","d","e","f","g","h"]),row(["i","j","X"," ","m","n","o","p"]),row(["q","r","s","t","u","v","w","x"])],[base,upper],[1,1],"default StyledSpace is opaque")
        advance(app,epoch,{ => cover.background(Color.Blue) })
        upper.expected = DrawObservation(3,1,Rect(0,0,3,1),style:Style(background:Color.Blue))
        let colored = row(["i","j","X"," "," ","n","o","p"])
        colored[2] = ExpectedCell("X",style:Style(background:Color.Blue))
        colored[3] = ExpectedCell(" ",style:Style(background:Color.Blue)); colored[4] = ExpectedCell(" ",style:Style(background:Color.Blue))
        paired(app,root,epoch,8,3,[row(["a","b","c","d","e","f","g","h"]),colored,row(["q","r","s","t","u","v","w","x"])],[base,upper],[1,1],"background fills former holes")
        advance(app,epoch,{ => cover.setStyle(StyleKeys.background,StyleValue<Color>.Unset) })
        upper.expected = DrawObservation(3,1,Rect(0,0,3,1))
        paired(app,root,epoch,8,3,[row(["a","b","c","d","e","f","g","h"]),row(["i","j","X"," ","m","n","o","p"]),row(["q","r","s","t","u","v","w","x"])],[base,upper],[1,1],"background removal restores hole")
        advance(app,epoch,{ => lower.set("IJKLMNOP") })
        paired(app,root,epoch,8,3,[row(["a","b","c","d","e","f","g","h"]),row(["I","J","X"," ","M","N","O","P"]),row(["q","r","s","t","u","v","w","x"])],[base,upper],[1,1],"lower dirty replays clean foreground")
        advance(app,epoch,{ => handle[0].getOrThrow().close() })
        paired(app,root,epoch,8,3,[row(["a","b","c","d","e","f","g","h"]),row(["I","J","K","L","M","N","O","P"]),row(["q","r","s","t","u","v","w","x"])],[base,upper],[1,0],"close exposes latest lower values")
    } finally { app.dispose() }
}
