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
}
