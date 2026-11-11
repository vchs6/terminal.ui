package interaction_b
import cjtui.*

func viewportReadonlyContexts():Unit {
    let saved=Box<?Component>(Option<Component>.None)
    let root=Column({=>
        saved.value=Canvas({_=>if(let Some(c)<-saved.value){if(let Some(r)<-c.reference()){r.viewportSnapshot()}};Size(8,1)},
            {p=>ref(saved.value).viewportSnapshot();p.put(0,0,"abcdefgh")}).height(1).viewport(ScrollAxes.Horizontal)
        Text({=>"${ref(saved.value).viewportSnapshot().offsetX}"})
    }).viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    try {
        picture(app.snapshot(4,2),"abcd\n0   ","B02 readonly getter/measure/draw allowed")
        app.batch({=>ref(saved.value).scrollTo(2,0)})
        picture(app.snapshot(4,2),"cdef\n2   ","B02 viewport query dependency invalidates getter")
        let handle=ref(saved.value)
        let worker=spawn {
            code("WrongUIContext",{=>handle.viewportSnapshot();()},"B02 viewport query thread guard")
            code("WrongUIContext",{=>handle.scrollBy(0,1);()},"B03 scroll thread guard")
            code("WrongUIContext",{=>handle.ensureVisible()},"B03 ensure thread guard");true
        }
        check(worker.get(Duration.second*5),"B02 saved ref thread negative cases complete")
        let otherRoot=Column({=>Text("other")}).viewport(ScrollAxes.Vertical)
        let other=Application(otherRoot);other.startHeadless();let peerRef=ref(otherRoot)
        app.batch({=>
            code("WrongUIContext",{=>peerRef.viewportSnapshot();()},"B02 query active foreign session")
            code("WrongUIContext",{=>peerRef.scrollBy(0,0);()},"B03 scroll active foreign session")
            code("WrongUIContext",{=>peerRef.ensureVisible()},"B03 ensure active foreign session")
        })
        other.dispose()
    } finally {app.dispose()}
}

func viewportPureMutationGuards():Unit {
    for(phase in ["getter","measure","draw"]) {
        for(operation in ["scrollTo","scrollBy","ensure"]) {
            let saved=Box<?Component>(Option<Component>.None);let attempted=Box<Bool>(false)
            let action={=>
                if(let Some(c)<-saved.value){if(let Some(r)<-c.reference()){
                    attempted.value=true
                    code("ReentrantEvaluation",{=>match(operation){case "scrollTo"=>r.scrollTo(0,0);();case "scrollBy"=>r.scrollBy(0,0);();case _=>r.ensureVisible()}},"B03 pure ${phase}/${operation}")
                }}
            }
            let node:Component=if(phase=="getter"){Text({=>action();"X"})}else{
                Canvas({_=>if(phase=="measure"){action()};Size(1,1)},{p=>if(phase=="draw"){action()};p.put(0,0,"X")})
            }
            node.viewport(ScrollAxes.Both);saved.value=Some(node)
            let app=Application(node);app.startHeadless()
            try {picture(app.snapshot(1,1),"X","B03 rejected paint-scroll feedback leaves output");check(attempted.value,"B03 mutation guard actually exercised")} finally {app.dispose()}
        }
    }
}

func viewportValidationAndCapacity():Unit {
    let target=Box<?Component>(Option<Component>.None)
    let root=Column({=>target.value=Text("hidden").visible(false)}).viewport(ScrollAxes.Both)
    let app=Application(root);app.startHeadless()
    try {
        app.snapshot(4,2)
        app.batch({=>
            illegal({=>ref(root).scrollTo(-1,0);()},"B02 negative scroll x")
            illegal({=>ref(root).scrollTo(0,-1);()},"B02 negative scroll y")
            code("InvalidProperty",{=>ref(root).ensureVisible(rect:Rect(-1,0,1,1))},"B03 negative rect x outside content rejected")
            code("InvalidProperty",{=>ref(root).ensureVisible(rect:Rect(0,-1,1,1))},"B03 negative rect y outside content rejected")
            code("InvalidProperty",{=>ref(target.value).ensureVisible()},"B03 hidden target rejected")
        })
        illegal({=>Rect(0,0,-1,1);()},"B03 negative Rect width constructor")
        illegal({=>Rect(0,0,1,-1);()},"B03 negative Rect height constructor")
    } finally {app.dispose()}
    for(mixed in [false,true]) {
        let root=Canvas({_=>Size(1,10)},{_=>}).viewport(ScrollAxes.Vertical).focusable(true)
        let app=Application(root,limits:RuntimeLimits(structuralOpsPerBatch:1));app.startHeadless()
        try {
            app.snapshot(1,2)
            app.batch({=>check(ref(root).scrollTo(0,1),"B03 one viewport command accepted at limit1")})
            code("CapacityExceeded",{=>app.batch({=>
                ref(root).scrollTo(0,2)
                if(mixed){ref(root).ensureVisible(rect:Rect(0,9,1,1))}else{ref(root).scrollTo(0,3);()}
            })},"B03 shared viewport command limit")
        } finally {app.dispose()}
    }
}

func pendingViewportCancellation():Unit {
    for(ancestor in [false,true]) {
        let target=Box<?Component>(Option<Component>.None)
        let branch=Box<?Component>(Option<Component>.None)
        let root=Column({=>
            branch.value=Column({=>target.value=Canvas({_=>Size(1,10)},{_=>}).height(2).viewport(ScrollAxes.Vertical).focusable(true)})
        }).viewport(ScrollAxes.Off)
        let app=Application(root);app.startHeadless()
        try {
            app.snapshot(1,2);let saved=ref(target.value)
            app.batch({=>
                saved.scrollTo(0,8);saved.ensureVisible(rect:Rect(0,9,1,1))
                if(ancestor){ref(root).remove(ref(branch.value))}else{ref(branch.value).remove(saved)}
            })
            check(!saved.isValid(),"B03 removed pending viewport generation revoked")
            code("StaleReference",{=>saved.viewportSnapshot();()},"B02 stale query")
            code("StaleReference",{=>saved.scrollBy(0,1);()},"B03 stale scroll")
            code("StaleReference",{=>saved.ensureVisible()},"B03 stale ensure")
            app.snapshot(1,2)
        } finally {app.dispose()}
    }
}

func viewportLifecyclePost():Unit {
    let observed=Box<Bool>(false);let posted=Box<Bool>(false);let holder=Box<?Application>(Option<Application>.None)
    let root=Canvas({_=>Size(1,10)},{_=>}).viewport(ScrollAxes.Vertical).onMount({r=>
        code("LifecycleReentry",{=>r.ensureVisible()},"B03 lifecycle direct ensure")
        check(holder.value.getOrThrow().post({=>posted.value=true;r.scrollBy(0,0);()}),"B03 lifecycle may post next turn")
        observed.value=true;{=>}
    })
    let app=Application(root);holder.value=Some(app);app.startHeadless()
    try {
        app.snapshot(1,2);check(observed.value && posted.value,"B03 posted command runs outside lifecycle")
        check(app.post({=>ref(root).scrollTo(0,1);()}),"B03 ordinary post accepted")
        app.snapshot(1,2);offset(root,0,1,"B03 posted scroll uses committed geometry")
    } finally {app.dispose()}
}
