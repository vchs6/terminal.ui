package interaction_b
import cjtui.*

// B1 applies to Canvas too: logical scrolling extent is distinct from clip/Frame.
func bareCanvasImplicitViewport():Unit {
    let drawn=Box<Bool>(false)
    let root=Canvas({_=>Size(999,999)},{p=>
        drawn.value=true
        check(p.size.width==1 && p.size.height==999,"B02 bare Canvas implicit root logical extent1x999")
        check(p.clip.x==0 && p.clip.y==0 && p.clip.width==1 && p.clip.height==1,"B02 implicit Canvas visible clip remains1x1")
        p.put(0,0,"X")
    }).minWidth(10).minHeight(10)
    let app=Application(root);app.startHeadless()
    try {
        let frame=app.snapshot(1,1)
        check(drawn.value && frame.width==1 && frame.height==1 && frame.toPlainText()=="X","B02 implicit Canvas minimum cannot enlarge terminal Frame")
        let v=ref(root).viewportSnapshot()
        check(v.axes==ScrollAxes.Vertical && v.width==1 && v.height==1 && v.contentHeight==999 && v.offsetY==0,"B02 all undeclared Application roots default Vertical")
    } finally {app.dispose()}
}
