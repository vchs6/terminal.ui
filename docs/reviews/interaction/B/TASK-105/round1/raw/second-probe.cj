package viewport_round1_probe
import cjtui.*
func dirtyExtent():Unit {
    let extent=Observable<Int64>(4)
    let root=Canvas({_=>Size(extent.get(),1)},{p=>p.put(0,0,"abcdefghijklm")}).viewport(ScrollAxes.Horizontal)
    let app=Application(root);app.startHeadless()
    try {
        app.snapshot(4,1)
        app.batch({=>extent.set(13)})
        var code=""
        app.batch({=>try{root.reference().getOrThrow().ensureVisible(rect:Rect(12,0,1,1))}catch(e:UIException){code=e.code}})
        let frame=app.snapshot(4,1);let v=root.reference().getOrThrow().viewportSnapshot()
        println("DIRTY error=[${code}] content=${v.contentWidth} offset=${v.offsetX} frame=[${frame.toPlainText()}]")
    }finally{app.dispose()}
}
func constrainedDependency():Unit {
    let rows=Observable<Int64>(2)
    let root=Column{
        Canvas({b=>if(b.maxWidth.isSome() && b.maxHeight.isNone()){Size(1,rows.get())}else{Size(1,1)}},{p=>for(i in 0..p.size.height){p.put(0,i,"C")}})
        Text("T")
    }.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    try {
        println("DEPS before=[${app.snapshot(1,5).toPlainText()}]")
        rows.set(3)
        let actual=app.snapshot(1,5).toPlainText();let full=render(root,1,5).toPlainText()
        println("DEPS after=[${actual}] M1=[${full}]")
    }finally{app.dispose()}
}
main():Int64{dirtyExtent();constrainedDependency();0}
