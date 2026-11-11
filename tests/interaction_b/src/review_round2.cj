package interaction_b
import cjtui.*

func reviewStableDirtyExtentEnsure():Unit {
    let extent=Observable<Int64>(4)
    let root=Canvas({_=>Size(extent.get(),1)},{p=>p.put(0,0,"abcdefghijklm")}).viewport(ScrollAxes.Horizontal)
    let app=Application(root);app.startHeadless()
    try {
        picture(app.snapshot(4,1),"abcd","I05-stable initial extent4 control")
        app.batch({=>extent.set(13)})
        let error=Box<String>("")
        app.batch({=>try{ref(root).ensureVisible(rect:Rect(12,0,1,1))}catch(e:UIException){error.value=e.code}})
        let frame=app.snapshot(4,1);let v=ref(root).viewportSnapshot()
        println("I05-stable error=[${error.value}] content=${v.contentWidth} offset=${v.offsetX} frame=[${frame.toPlainText()}]")
        check(frame.width==4 && frame.height==1 && v.contentWidth==13,"I05-stable final measured extent13 control")
        check(error.value.isEmpty(),"I05-stable pending layout is applied before next-batch ensure validation")
        offset(root,9,0,"I05-stable target12 becomes visible")
        picture(frame,"jklm","I05-stable final target window")
    } finally {app.dispose()}
}

func reviewIntermediateMeasureDependency():Unit {
    let rows=Observable<Int64>(2)
    let root=Column{
        Canvas({b=>if(b.maxWidth.isSome() && b.maxHeight.isNone()){Size(1,rows.get())}else{Size(1,1)}},
            {p=>for(i in 0..p.size.height){p.put(0,i,"C")}})
        Text("T")
    }.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    try {
        picture(app.snapshot(1,5),"C\nC\nT\n \n ","I08 initial intermediate constraint result2")
        rows.set(3)
        let actual=app.snapshot(1,5);let full=render(root,1,5)
        println("I08 actual=[${actual.toPlainText()}] M1=[${full.toPlainText()}]")
        picture(full,"C\nC\nC\nT\n ","I08 manual full M1 control")
        picture(actual,"C\nC\nC\nT\n ","I08 every still-used measurement retains its dependencies")
    } finally {app.dispose()}
}
