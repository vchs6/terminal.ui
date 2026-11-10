package interaction_a_contract
import cjtui.*
func caretFrames(): Unit {
    let position=Observable<Int64>(0); let drawCaret=Observable<Bool>(true)
    let c=Canvas({_=>Size(4,1)},{p=>p.put(0,0,"界  "); p.caret(3,0); if(drawCaret.get()){p.caret(position.get(),0)}else{p.caret(0,0,visible:false)}}).focusable(true)
    let a=Application(c,theme:plainTheme()); a.startHeadless(); a.snapshot(4,1)
    let s=a.caretSnapshot(); check(s.visible && s.x==0 && s.y==0 && s.owner.getOrThrow().sameNode(ref(c)),"last caret wins")
    let before=a.snapshot(4,1); position.set(2); let after=a.snapshot(4,1); sameFrame(before,after,4,1)
    check(a.caretSnapshot().x==2 && a.caretSnapshot().visible,"caret-only update without changed grid")
    position.set(1); a.snapshot(4,1); hiddenCaret(a) // continuation
    position.set(4); a.snapshot(4,1); hiddenCaret(a) // right edge, no reserved insertion cell
    position.set(-1); a.snapshot(4,1); hiddenCaret(a)
    position.set(0); drawCaret.set(false); a.snapshot(4,1); hiddenCaret(a)
    drawCaret.set(true); a.snapshot(0,1); focus(a,c); hiddenCaret(a)
    a.snapshot(4,0); focus(a,c); hiddenCaret(a)
    a.dispose(); hiddenCaret(a)
    let (pair,_)=group([{=>Text("x").focusable(true)},{=>Canvas({_=>Size(1,1)},{p=>p.caret(0,0)}).focusable(true)}])
    let b=Application(pair,theme:plainTheme()); b.startHeadless(); b.snapshot(1,2); hiddenCaret(b); b.dispose()
    let noRequest=Canvas({_=>Size(1,1)},{p=>p.put(0,0,"x")}).focusable(true)
    let d=Application(noRequest,theme:plainTheme()); d.startHeadless(); d.snapshot(1,1); hiddenCaret(d); d.dispose()
}
