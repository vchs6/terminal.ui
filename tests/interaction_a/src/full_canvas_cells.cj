package interaction_a_contract
import cjtui.*
func fullCanvasCells(): Unit {
    let canvas = Canvas({ _ => Size(5,2) }, { p =>
        check(p.size.width == 5 && p.size.height == 2,"local content size")
        check(p.clip.x == 0 && p.clip.y == 0 && p.clip.width == 5 && p.clip.height == 2,"effective local clip")
        check(!p.focused && p.enabled && p.textWidth("界é") == 3,"paint readonly context")
        p.put(-1,0,"界A") // first cluster cut on left; A at column1.
        p.put(4,0,"界") // right continuation outside -> entire cluster omitted.
        p.put(0,1,RichText([TextSpan("e"),TextSpan("́",style:TextStylePatch(bold:Some(true))),TextSpan("界")]))
        p.put(2,1,"z") // overwrites wide head; clears its whole footprint.
        p.fill(Rect(4,1,99,1),patch:TextStylePatch(background:Some(Color.Blue)))
    })
    let app = Application(canvas, theme: plainTheme()); app.startHeadless(); let f = app.snapshot(5,2)
    cell(f,0,0," ",1,false,Style()); cell(f,1,0,"A",1,false,Style())
    cell(f,2,0," ",1,false,Style()); cell(f,3,0," ",1,false,Style()); cell(f,4,0," ",1,false,Style())
    cell(f,0,1,"é",1,false,Style()); cell(f,1,1," ",1,false,Style()); cell(f,2,1,"z",1,false,Style())
    cell(f,3,1," ",1,false,Style()); cell(f,4,1," ",1,false,Style(background:Color.Blue))
    // Mounted render of a subtree must use the existing session; independent Frame lifetime.
    let reference = render(canvas,5,2); sameFrame(f,reference,5,2)
    reference.put(0,0,"X"); cell(f,0,0," ",1,false,Style())
    app.dispose()
    let (parent,nodes)=group([{=>Canvas({_=>Size(2,1)},{p=>p.put(0,0,"xy")})},{=>Text("sibling")}])
    let mounted=Application(parent,theme:plainTheme());mounted.startHeadless();mounted.snapshot(7,2)
    let sub=render(nodes[0],2,1);cell(sub,0,0,"x",1,false,Style());cell(sub,1,0,"y",1,false,Style())
    check(ref(nodes[0]).isValid() && ref(parent).children().size==2,"ordinary mounted-subtree render preserves session identities")
    mounted.dispose()
    let small = Canvas({ _ => Size(999,999) },{ p =>
        check(p.size.width == 1 && p.size.height == 1,"min cannot exceed actual allocation")
        p.put(0,0,"界"); p.put(Int64.Max,Int64.Max,"A"); p.fill(Rect(Int64.Max,0,2,1))
    }).minWidth(10).minHeight(10)
    let tiny = Application(small, theme:plainTheme()); tiny.startHeadless(); cell(tiny.snapshot(1,1),0,0," ",1,false,Style()); tiny.dispose()
}

func frameAndAncestorClip(): Unit {
    let value=RichText([TextSpan("e"),TextSpan("́",style:TextStylePatch(bold:Some(true))),TextSpan("界")])
    let primitive=Frame(4,1);primitive.put(0,0,value)
    cell(primitive,0,0,"é",1,false,Style());cell(primitive,1,0,"界",2,false,Style())
    cell(primitive,2,0,"",0,true,Style());cell(primitive,3,0," ",1,false,Style())
    let c=Canvas({_=>Size(4,1)},{p=>p.put(0,0,value)})
    let app=Application(c,theme:plainTheme());app.startHeadless();let f=app.snapshot(4,1)
    cell(f,0,0,"é",1,false,Style());cell(f,1,0,"界",2,false,Style())
    cell(f,2,0,"",0,true,Style());cell(f,3,0," ",1,false,Style());app.dispose()
    let root=Column {
        Canvas({_=>Size(20,20)},{p=>
            check(p.size.width==1 && p.size.height==1,"ancestor padding leaves actual content 1x1")
            p.put(-1,0,"AB");p.put(1,0,"LEAK");p.put(0,1,"LEAK")
        })
    }.width(3).height(3).padding(1)
    let clipped=Application(root,theme:plainTheme());clipped.startHeadless();let g=clipped.snapshot(3,3)
    for(y in 0..3){for(x in 0..3){cell(g,x,y,if(x==1&&y==1){"B"}else{" "},1,false,Style())}}
    clipped.dispose()
}
