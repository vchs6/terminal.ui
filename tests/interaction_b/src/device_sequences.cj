package interaction_b
import cjtui.*
import std.env.*
import std.fs.*

// Public user callbacks and a test-driver file rendezvous; no product hook.
func viewportDeviceSequence(mode:String):Int64 {
    let directory=getVariable("CJTUI_VIEWPORT_OUTPUT").getOrThrow()
    let body=Box<?Component>(Option<Component>.None)
    let caret=Observable<Int64>(0);let text=Observable<String>(if(mode=="unicode"){"A界B"}else{"abcdefghijkl"})
    let query=Box<Int64>(0)
    let root:Component=if(mode=="unicode"){
        Row({=>Text("#").width(1);body.value=Canvas({b=>Size(b.textWidth(text.get()),1)},{p=>p.put(0,0,text.get())}).width(2).viewport(ScrollAxes.Horizontal);Text("!").width(1)}).viewport(ScrollAxes.Off)
    }else{
        let value=Canvas({_=>Size(13,1)},{p=>p.put(0,0,text.get());p.caret(caret.get(),0)}).viewport(ScrollAxes.Horizontal).focusable(true)
        body.value=Some(value);value
    }
    let app=Application(root,glyphMode:GlyphMode.Unicode,theme:Theme.parse("schema_version=1\nname=\"device sequence\"\n"))
    app.onKeyEvent({e=>
        match(e.key.text){
            case "q"=>app.stop();e.preventDefault()
            case "o"=>caret.set(12);ref(body.value).ensureVisible(rect:Rect(12,0,1,1),horizontal:ScrollAlign.End)
            case "n"=>
                let before=ref(body.value).viewportSnapshot()
                File.writeTo(directory+"/callback-enter","${before.width}/${before.offsetX}".toArray())
                var attempts:Int64=0
                while(!exists(directory+"/resize-ready") && attempts<3000){sleep(Duration.millisecond);attempts++}
                check(exists(directory+"/resize-ready"),"B03 driver actual resize handshake completed")
                caret.set(2);ref(body.value).ensureVisible(rect:Rect(2,0,1,1),horizontal:ScrollAlign.End)
                File.writeTo(directory+"/callback-explicit","caret2/end".toArray())
            case "0"=>ref(body.value).scrollTo(0,0);()
            case "1"=>ref(body.value).scrollTo(1,0);()
            case "2"=>ref(body.value).scrollTo(2,0);()
            case "b"=>text.set("B")
            case "s"=>
                query.value++;let v=ref(body.value).viewportSnapshot();let c=app.caretSnapshot()
                File.writeTo(directory+"/state-${query.value}","${v.width}/${v.height}/${v.contentWidth}/${v.contentHeight}/${v.offsetX}/${v.offsetY}/${c.x}/${c.visible}".toArray())
            case _=>()
        }
    })
    app.run();return 0
}
