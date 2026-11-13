package keyboard_upstream
import cjtui.*
func check(value:Bool,name:String):Unit {if(!value){throw Exception("FAIL upstream ${name}")}}
main():Int64 {
    let body=Canvas({_=>Size(8,1)},{p=>p.put(0,0,"abcdefgh");p.caret(0,0)}).viewport(ScrollAxes.Horizontal).focusable(true)
    let app=Application(body);app.startHeadless()
    try {
        check(app.snapshot(4,1).toPlainText()=="abcd","Canvas/viewport original target")
        let owner=body.reference().getOrThrow()
        check(app.focusedNode().getOrThrow().sameNode(owner) && app.activeTarget().getOrThrow().sameNode(owner),"actual focus/activeTarget")
        app.batch({=>owner.scrollTo(2,0);()})
        check(app.snapshot(4,1).toPlainText()=="cdef" && owner.viewportSnapshot().offsetX==2,"actual committed scroll")
        let saved=Box<?OverlayHandle>(Option<OverlayHandle>.None)
        let modal=Text("M").focusable(true)
        app.batch({=>saved.value=Some(owner.openOverlay(modal,options:OverlayOptions(mode:OverlayMode.Modal)))})
        check(saved.value.getOrThrow().isOpen() && app.activeTarget().getOrThrow().sameNode(modal.reference().getOrThrow()),"actual C modal domain")
        app.batch({=>saved.value.getOrThrow().close()})
        check(app.focusedNode().getOrThrow().sameNode(owner) && saved.value.getOrThrow().content().isNone(),"actual overlay close and focus restore")
        let copied=app.copyLocalText("accepted API baseline")
        check(copied.status==SessionStatus.Unsupported && copied.issue==SessionIssue.NoDevice && copied.emittedBytes==0,"actual Session152 headless honest result")
    }finally{app.dispose()}
    let stats=app.stats();check(stats.mountedNodes==0 && stats.activeBindings==0 && stats.subscriptions==0 && stats.pendingPosts==0,"actual release")
    println("PASS accepted Canvas/focus/activeTarget/viewport/modal/Session baseline; no Keyboard API used")
    0
}
