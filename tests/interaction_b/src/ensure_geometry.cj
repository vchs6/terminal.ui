package interaction_b
import cjtui.*

func ensureTwoAxesAndNone():Unit {
    let saved=Box<?Component>(Option<Component>.None)
    let root=Column({=>
        Text("s\ns\ns").height(3)
        Row({=>
            Text("sss").width(3)
            saved.value=Canvas({_=>Size(10,10)},{p=>p.put(9,9,"T")}).width(3).height(3).viewport(ScrollAxes.Both)
            Text("ttt").width(3)
        }).height(3)
        Text("t\nt\nt").height(3)
    }).viewport(ScrollAxes.Both)
    let app=Application(root);app.startHeadless()
    try {
        app.snapshot(4,4)
        app.batch({=>ref(saved.value).ensureVisible(rect:Rect(9,9,1,1))})
        let frame=app.snapshot(4,4)
        offset(saved.value,7,7,"B03 Some first handles own two-axis viewport")
        offset(root,2,2,"B03 outer uses inner visible fragment on both axes")
        check(frame.cellAt(3,3).grapheme=="T","B03 nested target actual screen coordinate")
        app.batch({=>ref(saved.value).scrollTo(0,0);ref(root).scrollTo(0,0);ref(saved.value).ensureVisible()})
        app.snapshot(4,4)
        offset(saved.value,0,0,"B03 None does not scroll own content")
        offset(root,2,2,"B03 None brings whole inner layout box into parent")
    } finally {app.dispose()}
    let canvas=Canvas({_=>Size(40,40)},{_=>}).viewport(ScrollAxes.Both)
    let other=Application(canvas);other.startHeadless()
    try {
        other.snapshot(6,6)
        for(mode in [ScrollAlign.Start,ScrollAlign.End,ScrollAlign.Center,ScrollAlign.Nearest]) {
            other.batch({=>ref(canvas).scrollTo(0,0);ref(canvas).ensureVisible(rect:Rect(20,20,1,1),horizontal:mode,vertical:mode)})
            other.snapshot(6,6)
            let value=match(mode){case ScrollAlign.Start=>20;case ScrollAlign.Center=>18;case _=>15}
            offset(canvas,value,value,"B03 manual two-axis alignment")
        }
        other.batch({=>ref(canvas).scrollTo(18,18);ref(canvas).ensureVisible(rect:Rect(20,20,1,1))})
        other.snapshot(6,6);offset(canvas,18,18,"B03 already visible Nearest unchanged")
        other.batch({=>ref(canvas).scrollTo(0,0);ref(canvas).ensureVisible(rect:Rect(10,10,30,30))})
        other.snapshot(6,6);offset(canvas,10,10,"B03 oversized target approached from before")
        other.batch({=>ref(canvas).scrollTo(34,34);ref(canvas).ensureVisible(rect:Rect(10,10,20,20))})
        other.snapshot(6,6);offset(canvas,24,24,"B03 oversized target approached from after")
        other.batch({=>ref(canvas).scrollTo(15,15);ref(canvas).ensureVisible(rect:Rect(10,10,30,30))})
        other.snapshot(6,6);offset(canvas,15,15,"B03 window inside oversized target retained")
        other.batch({=>ref(canvas).ensureVisible()});other.snapshot(6,6)
        offset(canvas,15,15,"B03 root None starts above own viewport")
    } finally {other.dispose()}
}

func explicitIntentOrdering():Unit {
    let root=Canvas({_=>Size(20,1)},{p=>p.put(0,0,"abcdefghijklmnopqrst")}).viewport(ScrollAxes.Horizontal)
    let app=Application(root);app.startHeadless()
    try {
        app.snapshot(4,1)
        app.batch({=>ref(root).scrollTo(16,0);ref(root).ensureVisible(rect:Rect(2,0,1,1),horizontal:ScrollAlign.End)})
        picture(app.snapshot(4,1),"abcd","B03 ensure after explicit scroll wins")
        app.batch({=>ref(root).ensureVisible(rect:Rect(19,0,1,1));ref(root).ensureVisible(rect:Rect(6,0,1,1),horizontal:ScrollAlign.Start)})
        picture(app.snapshot(4,1),"ghij","B03 last ensure wins")
        picture(app.snapshot(4,1),"ghij","B03 repaint does not re-ensure old intent")
    } finally {app.dispose()}
}
