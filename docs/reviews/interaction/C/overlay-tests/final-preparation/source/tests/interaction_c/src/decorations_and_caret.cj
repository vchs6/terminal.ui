package interaction_c
import cjtui.*

func decoratedLayerTargets():Unit {
    let root=Canvas({_=>Size(8,5)},{p=>for(y in 0..5){p.put(0,y,"abcdefgh")}}).viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();let h=Box<?OverlayHandle>(None)
    let popup=Canvas({_=>Size(2,1)},{p=>p.put(0,0,"界")}).width(4).height(3).surface(SurfaceMode.Opaque).border(BorderStyle.Rounded).shadow(style:Style(dim:true))
    app.batch({=>h.value=Some(node(root).openOverlay(popup,options:OverlayOptions(takeFocus:false)))})
    let first=app.snapshot(8,5)
    picture(first,"abcdefgh\nab╭──╮gh\nab│界│░h\nab╰──╯░h\nabc░░░░h","G15 rounded border/wide cell/shadow hand grid")
    check(first.cellAt(4,2).continuation && first.cellAt(6,2).style.dim,"G15 actual continuation and explicit shadow style")
    picture(app.snapshot(10,5),"abcdefgh  \nabc╭──╮h  \nabc│界│░  \nabc╰──╯░  \nabcd░░░░  ","G15 moved old/new/shadow ranges")
    app.batch({=>popup.width(3)})
    let small=app.snapshot(8,5)
    picture(small,"abcdefgh\nab╭─╮fgh\nab│ │░gh\nab╰─╯░gh\nabc░░░gh","G15 shrink discards clipped wide cluster")
    check(small.cellAt(3,2).grapheme==" " && !small.cellAt(3,2).continuation,"G15 no orphan half cluster")
    app.batch({=>h.value.getOrThrow().close()})
    picture(app.snapshot(8,5),"abcdefgh\nabcdefgh\nabcdefgh\nabcdefgh\nabcdefgh","G15 close restores all current base cells")
    app.dispose()
}
func hiddenCaret(app:Application,name:String):Unit {
    let c=app.caretSnapshot();check(!c.visible && c.owner.isNone() && c.x==0 && c.y==0,name)
}
func caretSpacesShadowAndClip():Unit {
    let root=Canvas({_=>Size(8,5)},{p=>p.put(2,1,"界");p.caret(6,2)}).focusable(true).viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();app.snapshot(8,5)
    check(app.caretSnapshot().visible,"G16 initial caret visible")
    let h=Box<?OverlayHandle>(None)
    let shadow=Text("").width(4).height(3).shadow()
    app.batch({=>h.value=Some(node(root).openOverlay(shadow,options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false)))})
    app.snapshot(8,5);hiddenCaret(app,"G16 shadow contribution occludes caret")
    app.batch({=>h.value.getOrThrow().close()});app.snapshot(8,5);check(app.caretSnapshot().visible,"G16 close reveals base caret")
    app.snapshot(0,5);hiddenCaret(app,"G16 zero axis hides without clamp")
    app.snapshot(4,2);hiddenCaret(app,"G16 actual clip hides without clamp")
    app.dispose()
    let blank=Canvas({_=>Size(8,3)},{p=>p.caret(3,1)}).focusable(true).viewport(ScrollAxes.Off)
    let b=Application(blank);b.startHeadless();b.snapshot(8,3)
    b.batch({=>node(blank).openOverlay(Canvas({_=>Size(3,1)},{p=>p.put(1,0," ",patch:TextStylePatch(background:Color.Default))}),options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false));()})
    b.snapshot(8,3);hiddenCaret(b,"G16 styled opaque space occludes matching background");b.dispose()
    let wide=Canvas({_=>Size(8,3)},{p=>p.put(2,1,"界");p.caret(3,1)}).focusable(true).viewport(ScrollAxes.Off)
    let w=Application(wide);w.startHeadless();w.snapshot(8,3);hiddenCaret(w,"G16 continuation caret hidden normal form");w.dispose()
}
