package interaction_b_positive
import cjtui.*
import std.fs.*
func check(value:Bool,message:String):Unit {if(!value){throw Exception(message)}}
main():Int64 {
    let ioPath="tests/interaction_b/prerequisites/target/positive-handshake"
    File.writeTo(ioPath,"ok".toArray());check(exists(ioPath),"real SDK file rendezvous APIs");sleep(Duration.millisecond)
    let saved=Box<?Component>(Option<Component>.None);let trace=Box<String>("");let cleaned=Box<Int64>(0)
    let text=Observable<String>("e\u{301}X")
    let root=Column({=>
        saved.value=Canvas({b=>b.constrain(Size(4,1))},{p=>p.put(0,0,text.get());p.caret(0,0)}).focusable(true)
            .defaultAction({e=>trace.value+="${e.key.code}:${e.key.text}|"})
        Text({=>if(let Some(c)<-saved.value){if(let Some(r)<-c.reference()){return if(r.isFocused()){"F"}else{"N"}}};"N"})
    }).onMount({_=>{=>cleaned.value++}})
    let app=Application(root);app.startHeadless()
    try {
        let f=app.snapshot(4,2)
        check(f.cellAt(0,0).grapheme=="e\u{301}" && f.cellAt(0,1).grapheme=="F","real A Canvas/readonly getter positive")
        let node=saved.value.getOrThrow().reference().getOrThrow()
        check(node.isFocused() && app.caretSnapshot().visible,"real focus/caret positive")
        text.set("QR");check(app.snapshot(4,2).cellAt(0,0).grapheme=="Q","Observable.get/set real API")
        app.dispatch(node,KeyEvent("text",text:"v"));check(trace.value=="text:v|","named KeyEvent and real default callback")
        check(root.reference().getOrThrow().children().size==2,"one real child construction path")
    } finally {app.dispose()}
    check(cleaned.value==1 && app.stats().mountedNodes==0,"escaping holder cleanup positive")
    println("PASS preparation-only real f8 public A/language mapping; no B API or B behavior executed");0
}
