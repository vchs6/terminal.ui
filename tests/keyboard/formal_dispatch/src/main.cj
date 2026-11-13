package keyboard_formal_dispatch
import cjtui.*
func check(ok:Bool,name:String):Unit{if(!ok){throw Exception("FAIL dispatch ${name}")}}
func ref(c:Component):NodeRef{c.reference().getOrThrow()}
main():Int64 {
    let a=Box<?Component>(Option<Component>.None);let b=Box<?Component>(Option<Component>.None)
    let calls=Box<Int64>(0);let prevent=Box<Bool>(true)
    let root=Column{a.value=Some(Text("A").focusable(true));b.value=Some(Text("B").focusable(true))}.viewport(ScrollAxes.Off)
    let app=Application(root).onKeyEvent({e=>calls.value++;if(e.key.code=="interrupt" && prevent.value){e.preventDefault()}})
    app.startHeadless()
    try{
        let first=ref(a.value.getOrThrow());let second=ref(b.value.getOrThrow())
        for(key in [KeyEvent("left",text:"bad"),KeyEvent("paste",text:"x",ctrl:true),KeyEvent("paste",text:"x",alt:true),KeyEvent("paste",text:"x",shift:true)]){
            let before=calls.value;var caught=false
            try{app.dispatch(first,key)}catch(_:IllegalArgumentException){caught=true}
            check(caught && calls.value==before && first.isValid(),"invalid reserved combination before callback; healthy session")
        }
        app.batch({=>second.requestFocus()});app.dispatch(second,KeyEvent("backtab"))
        check(app.focusedNode().getOrThrow().sameNode(first),"legacy backtab exactly one backwards traversal")
        app.batch({=>second.requestFocus()});app.dispatch(second,KeyEvent("tab",shift:true))
        check(app.focusedNode().getOrThrow().sameNode(first),"tab+shift aliases backwards traversal once")
        let before=calls.value;app.dispatch(first,KeyEvent("custom"));check(calls.value==before+1 && first.isValid(),"custom unknown code still dispatches")
        app.dispatch(first,KeyEvent("interrupt"));check(first.isValid(),"legacy interrupt without ctrl can be prevented")
        prevent.value=false;app.dispatch(first,KeyEvent("interrupt"));check(!first.isValid(),"legacy interrupt keeps framework stop")
    }finally{app.dispose()}
    0
}
