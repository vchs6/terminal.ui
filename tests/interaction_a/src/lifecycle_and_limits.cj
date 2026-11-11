package interaction_a_contract
import cjtui.*
func lifecycleAndLimits(): Unit {
    let cleanup=Box<Int64>(0); let saved=Box<?PaintContext>(Option<PaintContext>.None)
    let node=Canvas({_=>Size(1,1)},{p=>saved.value=Some(p); throw Exception("DRAW_SENTINEL")})
        .onMount({_=>{=>cleanup.value++; throw Exception("CLEANUP_SENTINEL")}})
    let a=Application(node,theme:plainTheme()); a.startHeadless(); let old=ref(node)
    var caught=false
    try { a.snapshot(1,1) } catch(e:UICleanupException){
        caught=e.primary.message=="DRAW_SENTINEL" && e.cleanupFailures.size==1 && e.cleanupFailures[0].message=="CLEANUP_SENTINEL"
    }
    check(caught && cleanup.value==1 && !old.isValid(),"draw primary plus once-only cleanup aggregation")
    code("ExpiredPaintContext",{=>saved.value.getOrThrow().size;()}); a.dispose(); check(cleanup.value==1,"dispose does not repeat cleanup"); empty(a)
    let state=Observable<Int64>(0)
    code("ReentrantEvaluation",{=>let p=Application(Canvas({_=>state.set(1);Size(1,1)},{_=>}),theme:plainTheme());p.startHeadless();p.snapshot(1,1);()})
    code("ReentrantEvaluation",{=>let p=Application(Canvas({_=>Size(1,1)},{_=>state.set(1)}),theme:plainTheme());p.startHeadless();p.snapshot(1,1);()})
    let root=Box<?Component>(Option<Component>.None)
    let c=Canvas({_=>Size(1,1)},{_=>ref(root.value.getOrThrow()).requestFocus()}).focusable(true); root.value=Some(c)
    code("ReentrantEvaluation",{=>let p=Application(c,theme:plainTheme());p.startHeadless();p.snapshot(1,1);()})
    let d=Text("d").focusable(true).onMount({r=>code("LifecycleReentry",{=>r.requestFocus()});{=>}})
    let q=Application(d,theme:plainTheme());q.startHeadless();focus(q,d);q.dispose()
    let one=Observable<Int64>(1);let two=Observable<Int64>(2)
    code("CapacityExceeded",{=>let p=Application(Canvas({_=>Size(one.get()+two.get(),1)},{_=>}),theme:plainTheme(),limits:RuntimeLimits(dependenciesPerBinding:1));p.startHeadless();p.snapshot(3,1);()})
    code("CapacityExceeded",{=>let p=Application(Canvas({_=>Size(1,1)},{p=>p.put(0,0,"${one.get()+two.get()}")}),theme:plainTheme(),limits:RuntimeLimits(dependenciesPerBinding:1));p.startHeadless();p.snapshot(3,1);()})
    code("CapacityExceeded",{=>let p=Application(Canvas({_=>Size(1,1)},{_=>}),theme:plainTheme(),limits:RuntimeLimits(bindingsPerNode:1));p.startHeadless();p.snapshot(1,1);()})
    focusCommandCapacity("focus-focus"); focusCommandCapacity("append-focus"); focusCommandCapacity("focus-append")
}

// Shared command budget includes focus and existing structural operations.
func focusCommandCapacity(mode:String): Unit {
    let (control,good)=group([{=>Text("A").focusable(true)},{=>Text("B").focusable(true)}])
    let accepted=Application(control,theme:plainTheme(),limits:RuntimeLimits(structuralOpsPerBatch:2));accepted.startHeadless()
    try {accepted.batch({=>ref(good[0]).requestFocus();ref(good[1]).requestFocus()});focus(accepted,good[1])} finally {accepted.dispose()}
    let (root,nodes)=group([{=>Text("A").focusable(true)},{=>Text("B").focusable(true)}])
    let app=Application(root,theme:plainTheme(),limits:RuntimeLimits(structuralOpsPerBatch:1));app.startHeadless()
    try {
        app.batch({=>ref(nodes[1]).requestFocus()});focus(app,nodes[1])
        code("CapacityExceeded",{=>app.batch({=>
            if(mode=="append-focus"){ref(root).append(Text("C"))}else{ref(nodes[0]).requestFocus()}
            if(mode=="focus-append"){ref(root).append(Text("C"))}else{ref(nodes[1]).requestFocus()}
        })})
    } finally {app.dispose()}
    empty(app)
}
