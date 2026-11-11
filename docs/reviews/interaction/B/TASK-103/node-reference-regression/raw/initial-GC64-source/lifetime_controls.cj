package node_reference_regression
import cjtui.*
func lifetimeControls():Unit {
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
    }finally{app.dispose()}
}
