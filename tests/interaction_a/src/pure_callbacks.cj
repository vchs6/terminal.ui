package interaction_a_contract
import cjtui.*
// Production changes that grant write privilege through a readonly ref/application
// or fail to revoke a paint scope must make these assertions fail.
func pureCallbacks(): Unit {
    for (phase in ["measure","draw"]) {
        for (operation in ["component","notify","focus","batch","snapshot","dispatch","dispose","structure"]) {
            let owner=Box<?Component>(Option<Component>.None)
            let action={=>
                let c=owner.value.getOrThrow();let r=ref(c);let app=r.application()
                match(operation){
                    case "component"=>c.width(1);()
                    case "notify"=>r.notify(ChangeKind.Layout)
                    case "focus"=>r.requestFocus()
                    case "batch"=>app.batch({=>})
                    case "snapshot"=>app.snapshot(1,1);()
                    case "dispatch"=>app.dispatch(r,KeyEvent("text",text:"x"))
                    case "dispose"=>app.dispose()
                    case _=>r.append(Text("illegal"))
                }
            }
            let c=Canvas({bounds=>
                if(phase=="measure"){action()};bounds.constrain(Size(1,1))
            },{p=>if(phase=="draw"){action()};p.put(0,0,"x")}).focusable(true)
            owner.value=Some(c)
            let app=Application(c,theme:plainTheme())
            code(if(operation=="structure"){"ReentrantStructure"}else{"ReentrantEvaluation"},{=>
                app.startHeadless();app.snapshot(1,1);()
            })
            empty(app)
        }
    }
    let owner=Box<?Component>(Option<Component>.None)
    let c=Canvas({bounds=>
        let r=ref(owner.value.getOrThrow());r.isEnabled();r.isVisible();r.isFocused();r.application().focusedNode()
        bounds.constrain(Size(1,1))
    },{p=>
        let r=ref(owner.value.getOrThrow());r.application().caretSnapshot();r.isFocused();r.isEnabled();r.isVisible()
        // Whole-value validation must not leave the initial 'A' written after rejection.
        illegal({=>p.put(0,0,"A\u{0}")})
    }).focusable(true)
    owner.value=Some(c)
    let app=Application(c,theme:plainTheme());app.startHeadless();cell(app.snapshot(1,1),0,0," ",1,false,Style());app.dispose()
    canvasLeafStructure(false); canvasLeafStructure(true)
}

func canvasLeafStructure(nested:Bool): Unit {
    // Existing containers still mount, order and focus ordinary children.
    let control=Column {};let visible=Text("V").focusable(true)
    let good=Application(control,theme:plainTheme());good.startHeadless()
    try {
        good.batch({=>ref(control).append(visible)})
        let before=Text("B");good.batch({=>ref(control).insertBefore(ref(visible),before)})
        check(ref(control).children().size==2 && good.snapshot(1,2).toPlainText()=="B\nV","I07 normal container append/insert control")
        focus(good,visible)
    } finally {good.dispose()}
    let mounts=Box<Int64>(0)
    let saved=Box<?Component>(Option<Component>.None)
    let makeLeaf={=>let value=Canvas({_=>Size(1,1)},{p=>p.put(0,0,"C")});saved.value=Some(value);value}
    let root:Component=if(nested){Column {makeLeaf()}}else{makeLeaf()}
    let leaf=saved.value.getOrThrow()
    let hidden=Text("hidden").focusable(true).onMount({_=>mounts.value++;{=>}})
    let app=Application(root,theme:plainTheme());app.startHeadless()
    try {
        check(ref(leaf).children().isEmpty() && app.focusedNode().isNone(),"I07 leaf starts without hidden focus")
        code("InvalidParent",{=>app.batch({=>ref(leaf).append(hidden)})})
        check(mounts.value==0 && hidden.reference().isNone(),"I07 rejected leaf insertion never mounts hidden focus target")
    } finally {app.dispose()}
    empty(app)
}
