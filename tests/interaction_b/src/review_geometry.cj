package interaction_b
import cjtui.*

func reviewHorizontalWeights():Unit {
    let root=Row{Text("ABCD").wrap(TextWrap.Grapheme).layoutWeight(1);Text("EFGH").wrap(TextWrap.Grapheme).layoutWeight(1)}.viewport(ScrollAxes.Horizontal)
    let app=Application(root);app.startHeadless()
    try {
        let first=app.snapshot(4,1);check(first.width==4 && first.height==1,"I01 physical Frame control")
        check(ref(root).viewportSnapshot().contentWidth==8,"I01 logical width8 control")
        app.batch({=>check(ref(root).scrollTo(4,0),"I01 accepts tail4")})
        let tail=app.snapshot(4,1);println("I01 first=[${first.toPlainText()}] tail=[${tail.toPlainText()}]")
        picture(first,"ABCD","I01 horizontal weighted natural widths")
        picture(tail,"EFGH","I01 horizontal weighted tail remains accessible")
    } finally {app.dispose()}
}

func reviewMixedBarrier():Unit {
    let inner=Box<?Component>(Option<Component>.None)
    let root=Column{
        inner.value=ScrollView{Text("i\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni")}.layoutWeight(1)
        Text("A\nA\nA\nA\nA\nA\nA\nA").layoutWeight(1)
    }
    let app=Application(root);app.startHeadless()
    try {
        let first=app.snapshot(1,10);let view=ref(inner.value).viewportSnapshot()
        check(ref(root).viewportSnapshot().contentHeight==13,"I02 root extent13 control")
        app.batch({=>ref(root).scrollTo(0,Int64.Max);()})
        let tail=app.snapshot(1,10);println("I02 innerHeight=${view.height} first=[${first.toPlainText()}] tail=[${tail.toPlainText()}]")
        check(view.height==5,"I02 independent viewport keeps first-pass outer allocation5")
        picture(first,"i\ni\ni\ni\ni\nA\nA\nA\nA\nA","I02 mixed baseline5/8 initial")
        picture(tail,"i\ni\nA\nA\nA\nA\nA\nA\nA\nA","I02 all eight ordinary rows accessible")
    } finally {app.dispose()}
}

func reviewLocalViewportResize():Unit {
    let width=Observable<Int64>(4);let saved=Box<?Component>(Option<Component>.None)
    let root=Column{saved.value=Canvas({_=>Size(13,1)},{p=>p.put(0,0,"abcdefghijkl");p.caret(12,0)}).width({=>width.get()}).viewport(ScrollAxes.Horizontal).focusable(true)}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    try {
        app.snapshot(4,1);app.batch({=>ref(saved.value).ensureVisible(rect:Rect(12,0,1,1),horizontal:ScrollAlign.End)})
        picture(app.snapshot(4,1),"jkl ","I03 completed caret12 control");offset(saved.value,9,0,"I03 initial offset9")
        check(app.caretSnapshot().visible,"I03 old caret visible control")
        width.set(2);let frame=app.snapshot(4,1);let v=ref(saved.value).viewportSnapshot()
        println("I03 frame=[${frame.toPlainText()}] view=${v.width} offset=${v.offsetX} caret=${app.caretSnapshot().visible}")
        check(v.width==2 && v.height==1,"I03 local viewport changed while App stays4x1")
        offset(saved.value,11,0,"I03 local resize ensures old caret")
        picture(frame,"l   ","I03 new local clip plus unused App columns")
        check(app.caretSnapshot().visible && app.caretSnapshot().x==1,"I03 local resize caret remains visible")
    } finally {app.dispose()}
}

func reviewMountedViewportExport():Unit {
    let saved=Box<?Component>(Option<Component>.None)
    let root=Column{saved.value=Canvas({_=>Size(13,1)},{p=>p.put(0,0,"abcdefghijkl")}).viewport(ScrollAxes.Horizontal)}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    try {
        app.snapshot(4,1);app.batch({=>ref(saved.value).scrollTo(9,0);()})
        picture(app.snapshot(4,1),"jkl ","I04 committed offset9 control")
        let exported=render(saved.value.getOrThrow(),13,1)
        check(exported.width==13 && exported.height==1,"I04 independent export dimensions")
        let after=ref(saved.value).viewportSnapshot();let frame=app.snapshot(4,1);let full=render(root,4,1)
        println("I04 afterExportView=${after.width} offset=${after.offsetX} app=[${frame.toPlainText()}] M1=[${full.toPlainText()}]")
        check(after.width==4 && after.offsetX==9,"I04 subtree export cannot overwrite committed application viewport")
        picture(frame,"jkl ","I04 Application keeps committed offset")
        picture(full,"jkl ","I04 mounted M1 equals same-input Application")
    } finally {app.dispose()}
}

func reviewGrowingExtentEnsure():Unit {
    let stable=Canvas({_=>Size(4,1)},{_=>}).viewport(ScrollAxes.Horizontal)
    let control=Application(stable);control.startHeadless()
    try {
        control.snapshot(4,1)
        control.batch({=>code("InvalidProperty",{=>ref(stable).ensureVisible(rect:Rect(12,0,1,1))},"I05 truly beyond final extent4 still rejected")})
        offset(stable,0,0,"I05 invalid target control preserves offset")
    } finally {control.dispose()}
    let extent=Observable<Int64>(4);let caret=Observable<Int64>(0)
    let root=Canvas({_=>Size(extent.get(),1)},{p=>p.put(0,0,"abcdefghijkl");p.caret(caret.get(),0)}).viewport(ScrollAxes.Horizontal).focusable(true)
    let app=Application(root);app.startHeadless()
    try {
        picture(app.snapshot(4,1),"abcd","I05 old extent4 control")
        var error=""
        try{app.batch({=>extent.set(13);caret.set(12);ref(root).ensureVisible(rect:Rect(12,0,1,1))})}catch(e:UIException){error=e.code}
        println("I05 growing same-batch ensure error=[${error}]")
        check(error.isEmpty(),"I05 new caret is validated against final grown extent")
        picture(app.snapshot(4,1),"jkl ","I05 growing extent13/new caret12 succeeds")
        offset(root,9,0,"I05 grown target offset9")
        check(app.caretSnapshot().visible && app.caretSnapshot().x==3,"I05 grown caret visible")
    } finally {app.dispose()}
}

func reviewFiniteNonScrollConstraint():Unit {
    let last=Box<?Constraints>(Option<Constraints>.None)
    let root=Canvas({b=>last.value=Some(b);Size(8,4)},{_=>}).viewport(ScrollAxes.Horizontal)
    let app=Application(root);app.startHeadless()
    try {
        let frame=app.snapshot(4,2);let v=ref(root).viewportSnapshot();let b=last.value.getOrThrow()
        check(frame.width==4 && frame.height==2 && v.width==4 && v.height==2,"I06 actual4x2 control")
        println("I06 last maxWidth=${b.maxWidth} maxHeight=${b.maxHeight}")
        check(b.maxWidth.isNone() && b.maxHeight==Some(2),"I06 only scrolling X is unbounded; final Y bound2")
    } finally {app.dispose()}
}
