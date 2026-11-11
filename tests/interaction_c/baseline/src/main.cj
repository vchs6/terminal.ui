package overlay_baseline
import cjtui.*
import std.ref.*
import std.runtime.*
import std.sync.*
func check(ok:Bool,name:String):Unit {if(!ok){throw Exception(name)}}
main():Int64 {
    let value=Observable<String>("base")
    let root=Column{Text({=>value.get()})}.viewport(ScrollAxes.Off)
    let app=Application(root,theme:Theme.parse("schema_version=1\nname='C prerequisite'\n"))
    app.startHeadless()
    check(app.snapshot(6,1).toPlainText()=="base  ","binding first")
    value.set("new");check(app.snapshot(6,1).toPlainText()=="new   ","binding latest")
    let saved=root.reference().getOrThrow()
    check(saved.children().size==1 && saved.application().stats().mountedNodes==2,"actual NodeRef/owner/children")
    let worker=spawn{saved.isValid() && saved.sameNode(saved)}
    check(worker.get(Duration.second*5),"public SDK escaping holder/thread")
    let weak=WeakRef<Application>(app,CleanupPolicy.EAGER)
    check(weak.value.isSome(),"public SDK WeakRef shape")
    let count=getGCCount();check(count>=0,"public GC count shape")
    app.dispose();check(app.stats().mountedNodes==0 && !saved.isValid(),"cleanup generation")
    let canvas=Canvas({_=>Size(13,1)},{p=>p.put(0,0,"abcdefghijklm");p.caret(12,0)}).focusable(true).viewport(ScrollAxes.Horizontal)
    let b=Application(canvas);b.startHeadless();check(b.snapshot(4,1).toPlainText()=="abcd","actual A Canvas/B viewport")
    b.batch({=>canvas.reference().getOrThrow().ensureVisible(rect:Rect(12,0,1,1))})
    check(b.snapshot(4,1).toPlainText()=="jklm" && canvas.reference().getOrThrow().viewportSnapshot().offsetX==9,"actual B ensure/transform")
    check(b.caretSnapshot().visible && b.caretSnapshot().x==3,"actual A caret/B transform")
    b.dispose()
    let scroll=ScrollView({=>Text("one");Text("two")})
    let s=Application(scroll);s.startHeadless();s.snapshot(3,1)
    check(scroll.reference().getOrThrow().viewportSnapshot().contentHeight==2,"actual ScrollView")
    s.dispose()
    let f=Frame(2,1,transparent:true);f.put(0,0,"x");check(f.cellAt(1,0).isTransparent,"actual Frame holes")
    println("POSITIVE_ONLY actual A/B/Theme/Frame/SDK public APIs; no C behavior")
    return 0
}
