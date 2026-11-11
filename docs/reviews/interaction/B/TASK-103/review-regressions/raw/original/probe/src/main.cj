package viewport_review_probe
import cjtui.*
func theme():Theme{Theme.parse("schema_version=1\nname=\"probe\"\n")}
func ref(c:Component):NodeRef{c.reference().getOrThrow()}
func describe(c:Component):String{let v=ref(c).viewportSnapshot();"view=${v.width}x${v.height} content=${v.contentWidth}x${v.contentHeight} offset=${v.offsetX},${v.offsetY}"}
func horizontalWeights():Unit {
    let root=Row{Text("ABCD").wrap(TextWrap.Grapheme).layoutWeight(1);Text("EFGH").wrap(TextWrap.Grapheme).layoutWeight(1)}.viewport(ScrollAxes.Horizontal)
    let app=Application(root,theme:theme());app.startHeadless()
    println("HORIZONTAL initial=[${app.snapshot(4,1).toPlainText()}] ${describe(root)}")
    app.batch({=>ref(root).scrollTo(4,0)})
    println("HORIZONTAL tail=[${app.snapshot(4,1).toPlainText()}] ${describe(root)}");app.dispose()
}
func mixedBarrier():Unit {
    let inner=Box<?Component>(Option<Component>.None)
    let root=Column{
        inner.value=ScrollView{Text("i\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni\ni")}.layoutWeight(1)
        Text("A\nA\nA\nA\nA\nA\nA\nA").layoutWeight(1)
    }
    let app=Application(root,theme:theme());app.startHeadless()
    println("MIXED initial\n"+app.snapshot(1,10).toPlainText())
    println("MIXED ${describe(root)} inner ${describe(inner.value.getOrThrow())}")
    app.batch({=>ref(root).scrollTo(0,Int64.Max)})
    println("MIXED tail\n"+app.snapshot(1,10).toPlainText());app.dispose()
}
func localResize():Unit {
    let width=Observable<Int64>(4);let saved=Box<?Component>(Option<Component>.None)
    let root=Column{saved.value=Canvas({_=>Size(13,1)},{p=>p.put(0,0,"abcdefghijkl");p.caret(12,0)}).width({=>width.get()}).viewport(ScrollAxes.Horizontal).focusable(true)}.viewport(ScrollAxes.Off)
    let app=Application(root,theme:theme());app.startHeadless();app.snapshot(4,1)
    app.batch({=>ref(saved.value.getOrThrow()).ensureVisible(rect:Rect(12,0,1,1),horizontal:ScrollAlign.End)})
    app.snapshot(4,1);println("RESIZE before ${describe(saved.value.getOrThrow())} caret=${app.caretSnapshot().visible}")
    width.set(2);println("RESIZE after=[${app.snapshot(4,1).toPlainText()}] ${describe(saved.value.getOrThrow())} caret=${app.caretSnapshot().visible}");app.dispose()
}
func subtreeRender():Unit {
    let saved=Box<?Component>(Option<Component>.None)
    let root=Column{saved.value=Canvas({_=>Size(13,1)},{p=>p.put(0,0,"abcdefghijkl")}).viewport(ScrollAxes.Horizontal)}.viewport(ScrollAxes.Off)
    let app=Application(root,theme:theme());app.startHeadless();app.snapshot(4,1)
    app.batch({=>ref(saved.value.getOrThrow()).scrollTo(9,0)})
    println("EXPORT before=[${app.snapshot(4,1).toPlainText()}] ${describe(saved.value.getOrThrow())}")
    render(saved.value.getOrThrow(),13,1)
    println("EXPORT after-export ${describe(saved.value.getOrThrow())}")
    let actual=app.snapshot(4,1).toPlainText();let full=render(root,4,1).toPlainText()
    println("EXPORT app=[${actual}] M1=[${full}] ${describe(saved.value.getOrThrow())}");app.dispose()
}
func grownEnsure():Unit {
    let extent=Observable<Int64>(4)
    let root=Canvas({_=>Size(extent.get(),1)},{p=>}).viewport(ScrollAxes.Horizontal)
    let app=Application(root,theme:theme());app.startHeadless();app.snapshot(4,1)
    try {app.batch({=>extent.set(13);ref(root).ensureVisible(rect:Rect(12,0,1,1))});app.snapshot(4,1);println("GROW ${describe(root)}")}
    catch(e:UIException){println("GROW error=${e.code}")}
    app.dispose()
}
func finiteNonScrollAxis():Unit {
    let last=Box<String>("")
    let root=Canvas({b=>last.value="maxWidth=${b.maxWidth} maxHeight=${b.maxHeight}";Size(8,4)},{_=>}).viewport(ScrollAxes.Horizontal)
    let app=Application(root,theme:theme());app.startHeadless();app.snapshot(4,2)
    println("CONSTRAINT last ${last.value} ${describe(root)}");app.dispose()
}
func candidateAfterInvalidation():Unit {
    let exported=Box<?Component>(Option<Component>.None)
    let state=Observable<String>("a")
    let old=Theme.parse("schema_version=1\nname=\"Old\"\n[styles.grow.spacing]\nweight=0\nmin_width=0\n")
    let candidate=Theme.parse("schema_version=1\nname=\"Candidate\"\n[styles.grow.spacing]\nweight=1\nmin_width=9223372036854775807\n")
    let root=Row {
        exported.value=Canvas({b=>if(b.maxWidth.isNone()){Size(1,0)}else{b.constrain(Size(Int64.Max,0))}},{_=>})
        Row {Text({=>state.get()}).styles([StyleUse.Named("grow")]);Text("b").styles([StyleUse.Named("grow")])}.layoutWeight(1)
    }
    let app=Application(root,theme:old);app.startHeadless();app.snapshot(Int64.Max,0)
    render(exported.value.getOrThrow(),Int64.Max,0)
    let request=app.loadTheme(ThemeSource.Prepared(candidate));sleep(Duration.millisecond*30)
    var error=""
    try {app.batch({=>state.set("c")});app.snapshot(Int64.Max,0)}catch(e:Exception){error=e.message}
    let tag=match(request.result()){case Some(ThemeResult.Applied(_))=>"Applied";case Some(ThemeResult.Failed(_))=>"Failed";case Some(ThemeResult.SessionClosed)=>"Closed";case _=>"PendingOrSuperseded"}
    println("CANDIDATE result=${tag} error=[${error}] info=${app.themeInfo().name} active=${app.post({=>})} ref=${root.reference().isSome()}");app.dispose()
}
func prelayoutGetterAxes():Unit {
    let seen=Box<Bool>(false)
    let root=Canvas({_=>Size(1,1)},{_=>}).viewport({=>ScrollAxes.Both}).onMount({r=>seen.value=r.viewportSnapshot().axes==ScrollAxes.Both;{=>}})
    let app=Application(root,theme:theme());app.startHeadless()
    println("PRELAYOUT mountBoth=${seen.value} afterStartBoth=${ref(root).viewportSnapshot().axes==ScrollAxes.Both}");app.dispose()
}
main():Int64{prelayoutGetterAxes();horizontalWeights();mixedBarrier();localResize();subtreeRender();grownEnsure();finiteNonScrollAxis();candidateAfterInvalidation();0}
