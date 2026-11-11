package interaction_b
import cjtui.*

func caretHistoryInvalidation():Unit {
    let extent=Observable<Int64>(13);let text=Observable<String>("abcdefghijkl")
    let canvas=Canvas({_=>Size(extent.get(),1)},{p=>p.put(0,0,text.get());p.caret(12,0)}).viewport(ScrollAxes.Horizontal).focusable(true)
    let app=Application(canvas);app.startHeadless()
    try {
        app.snapshot(4,1)
        app.batch({=>ref(canvas).ensureVisible(rect:Rect(12,0,1,1),horizontal:ScrollAlign.End)})
        app.snapshot(4,1);offset(canvas,9,0,"B03 completed old caret12")
        extent.set(3);text.set("ab")
        picture(app.snapshot(2,1),"b ","B03 shortened extent discards old automatic caret rect")
        offset(canvas,1,0,"B03 ordinary shrink clamp remains authoritative")
        check(!app.caretSnapshot().visible,"B03 invalid old caret hidden without business error")
    } finally {app.dispose()}
    let saved=Box<?Component>(Option<Component>.None);let other=Box<?Component>(Option<Component>.None)
    let root=Column({=>
        saved.value=Canvas({_=>Size(13,1)},{p=>p.put(0,0,"abcdefghijkl");p.caret(12,0)}).height(1).viewport(ScrollAxes.Horizontal).focusable(true)
        other.value=Text("T").height(1).focusable(true)
    }).viewport(ScrollAxes.Off)
    let owner=Application(root);owner.startHeadless()
    try {
        owner.snapshot(4,2)
        owner.batch({=>ref(saved.value).ensureVisible(rect:Rect(12,0,1,1),horizontal:ScrollAlign.End)})
        owner.snapshot(4,2);offset(saved.value,9,0,"B03 focus-loss control old offset")
        owner.batch({=>ref(other.value).requestFocus()});owner.snapshot(2,2)
        offset(saved.value,9,0,"B03 unfocused old caret cannot resize-scroll viewport")
        let old=ref(saved.value)
        owner.batch({=>ref(root).remove(old)})
        owner.batch({=>ref(root).append(saved.value.getOrThrow())})
        owner.snapshot(2,2)
        check(!old.isValid() && !old.sameNode(ref(saved.value)),"B03 old caret generation cannot revive")
        offset(saved.value,0,0,"B02 remounted viewport offset starts zero")
    } finally {owner.dispose()}
}
