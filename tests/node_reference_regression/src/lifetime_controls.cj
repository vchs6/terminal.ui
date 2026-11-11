package node_reference_regression
import cjtui.*
func lifetimeControls():Bool {
    let child=Box<?Component>(Option<Component>.None)
    let root=Column{child.value=Text("X").focusable(true)}
    let app=Application(root)
    try {
        app.startHeadless();app.snapshot(1,1)
        let parent=root.reference().getOrThrow();let old=child.value.getOrThrow().reference().getOrThrow()
        check(old.isValid() && old.isEnabled() && old.isVisible() && old.isFocused(),"ordinary mounted NodeRef queries")
        check(parent.children().size==1 && parent.children()[0].sameNode(old),"ordinary NodeRef identity/children")
        check(old.application().focusedNode().getOrThrow().sameNode(old),"ordinary public Application lookup")
        app.batch({=>parent.remove(old)})
        check(!old.isValid() && old.sameNode(old),"unmount invalidates handle without changing its identity")
        expectCode("StaleReference",{=>old.isFocused();()},"actually unmounted query remains stale")
        app.batch({=>parent.append(child.value.getOrThrow())});app.snapshot(1,1)
        let next=child.value.getOrThrow().reference().getOrThrow()
        check(next.isValid() && next.isEnabled() && next.isVisible(),"remounted node queries remain live")
        check(!old.isValid() && !old.sameNode(next),"remount opens a new generation")
        println("PASS ordinary queries/unmount/remount generation controls")
        if(!awaitPublicCollection()){println("ENVIRONMENT_INSUFFICIENT: no public GC-count progress");return false}
        let active=child.value.getOrThrow().reference()
        check(active.isSome(),"active Component.reference remains published after observed GC progress")
        let after=active.getOrThrow()
        check(after.isValid() && after.sameNode(next) && next.isValid(),"active Component lookup and saved ref retain same generation after GC")
        check(after.isEnabled() && after.isVisible(),"active post-GC ordinary queries")
        check(after.application().stats().mountedNodes==app.stats().mountedNodes && app.stats().mountedNodes>0,"post-GC NodeRef.application retains active owner")
        println("PASS active Component/reference/owner lookup after observed GC progress")
        return true
    }finally{app.dispose()}
}
