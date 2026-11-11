package interaction_b
import cjtui.*

func viewportCell(frame:Frame,x:Int64,glyph:String,width:Int64,continuation:Bool):Unit {
    let c=frame.cellAt(x,0)
    check(c.grapheme==glyph && c.width==width && c.continuation==continuation && c.style==Style() && !c.isTransparent,"B01 complete Unicode cell ${x}")
}

func unicodeViewportClipping():Unit {
    let text=Observable<String>("A界B");let saved=Box<?Component>(Option<Component>.None)
    let root=Row({=>
        Text("#").width(1)
        saved.value=Canvas({b=>check(!b.ambiguousWide,"B01 fixed narrow ambiguous profile");Size(b.textWidth(text.get()),1)},
            {p=>p.put(0,0,text.get())}).width(2).viewport(ScrollAxes.Horizontal)
        Text("!").width(1)
    }).viewport(ScrollAxes.Off)
    let app=Application(root,glyphMode:GlyphMode.Unicode,theme:Theme.parse("schema_version=1\nname=\"Unicode viewport\"\n"));app.startHeadless()
    try {
        let initial=app.snapshot(4,1);picture(initial,"#A !","B01 cluster cannot cross viewport right clip")
        viewportCell(initial,0,"#",1,false);viewportCell(initial,1,"A",1,false);viewportCell(initial,2," ",1,false);viewportCell(initial,3,"!",1,false)
        app.batch({=>ref(saved.value).scrollTo(1,0)})
        let whole=app.snapshot(4,1);picture(whole,"#界!","B01 whole wide cluster in viewport")
        viewportCell(whole,0,"#",1,false);viewportCell(whole,1,"界",2,false);viewportCell(whole,2,"",0,true);viewportCell(whole,3,"!",1,false)
        app.batch({=>ref(saved.value).scrollTo(2,0)})
        let clipped=app.snapshot(4,1);picture(clipped,"# B!","B01 clipped left wide lead leaves no orphan")
        viewportCell(clipped,0,"#",1,false);viewportCell(clipped,1," ",1,false);viewportCell(clipped,2,"B",1,false);viewportCell(clipped,3,"!",1,false)
        text.set("B")
        let short=app.snapshot(4,1);picture(short,"#B !","B01 shrink clears old full cluster and preserves chrome")
        viewportCell(short,0,"#",1,false);viewportCell(short,1,"B",1,false);viewportCell(short,2," ",1,false);viewportCell(short,3,"!",1,false)
        offset(saved.value,0,0,"B02 Unicode shrink clamps offset")
    } finally {app.dispose()}
    for(emoji in [false,true]) {
        let value=if(emoji){"👩‍💻X"}else{"e\u{301}X"}
        let node=Canvas({b=>Size(b.textWidth(value),1)},{p=>p.put(0,0,value)}).viewport(ScrollAxes.Horizontal)
        let other=Application(node,glyphMode:GlyphMode.Unicode,theme:Theme.parse("schema_version=1\nname=\"cluster\"\n"));other.startHeadless()
        try {
            let first=other.snapshot(1,1)
            viewportCell(first,0,if(emoji){" "}else{"e\u{301}"},1,false)
            if(emoji){other.batch({=>ref(node).scrollTo(1,0)});viewportCell(other.snapshot(1,1),0," ",1,false)}
            other.batch({=>ref(node).scrollTo(if(emoji){2}else{1},0)})
            viewportCell(other.snapshot(1,1),0,"X",1,false)
        } finally {other.dispose()}
    }
}
