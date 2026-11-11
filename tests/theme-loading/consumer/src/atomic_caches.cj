package theme_loading_contract
import cjtui.*
import std.collection.ArrayList
func kept(name:String,color:String,spacing!:String=""):Theme {
    Theme.parse("schema_version=1\nname=\""+name+"\"\n[styles.keep.text]\nforeground=\""+color+"\"\n"+spacing)
}
func candidateValidatesLatestDeclarationCache(env:TestEnvironment):Unit {
    let initial=Theme.parse("schema_version=1\nname=\"A\"\n[text]\nforeground=\"red\"\n[styles.later.text]\nforeground=\"red\"\n")
    let node=Text("x")
    let app=Application(node,theme:initial);app.startHeadless()
    try {
        let oldRef=reference(node)
        let request=app.loadTheme(ThemeSource.File(env.path("gate-old.toml")))
        env.entered("gate-old.toml")
        node.styles([StyleUse.Named("later")])
        check(app.snapshot(1,1).cellAt(0,0).style.foreground==Color.Red,"tree cache can change while actual loader I/O is blocked")
        env.release("gate-old.toml")
        pump(app,request,env);candidateFailure(request,"MissingStyle")
        unchanged(app,"A",0,0)
        check(oldRef.sameNode(reference(node)),"commit validates current declarations and preserves current node")
    } finally {app.dispose()}
}
func atomicCandidateValidationUsesCaches(env:TestEnvironment):Unit {
    candidateMinimumSumRejectsBeforeCommit(env)
    subtreeCandidateMinimumSumRejectsBeforeCommit(env)
    let state=Observable<String>("edit")
    let root=TrackedPanel(state)
    root.onMount({_=>root.mounts++;{=>root.cleanups++}})
    let app=Application(root,theme:kept("A","red"));app.startHeadless()
    try {
        let parent=reference(root);let child=reference(root.body.getOrThrow())
        let before=app.snapshot(12,5)
        let gets=root.getters;let widths=root.widths;let builds=root.builds
        let missing=app.loadTheme(ThemeSource.Prepared(prepared("Missing","blue")))
        pump(app,missing,env);candidateFailure(missing,"MissingStyle")
        unchanged(app,"A",0,0)
        let target=app.loadTheme(ThemeSource.Prepared(kept("BadTarget","blue",spacing:"[styles.keep.spacing]\ngap=1\n")))
        pump(app,target,env);candidateFailure(target,"UnsupportedProperty")
        let overflow=app.loadTheme(ThemeSource.Prepared(kept("Overflow","blue",spacing:"[styles.keep.spacing]\nweight=9223372036854775807\n")))
        pump(app,overflow,env);candidateFailure(overflow,"OutOfRange")
        unchanged(app,"A",0,0)
        check(root.getters==gets && root.widths==widths && root.builds==builds && root.mounts==1,"failed candidates validate cached values without user getter/build/mount")
        check(parent.sameNode(reference(root)) && child.sameNode(reference(root.body.getOrThrow())),"failed candidates retain node identities")
        let accepted=app.loadTheme(ThemeSource.Prepared(kept("B","blue",spacing:"[spacing]\ngap=1\n")))
        let after=pump(app,accepted,env);applied(accepted,1)
        unchanged(app,"B",1,accepted.id)
        check(root.getters==gets && root.widths==widths && root.builds==builds && root.mounts==1,"successful commit does not execute unrelated getters/build/mount")
        check(child.sameNode(reference(root.body.getOrThrow())) && state.get()=="edit","successful theme retains business state and ref")
        check(after.cellAt(0,0).style.foreground==Color.Blue && after.cellAt(0,2).style.foreground==Color.Blue,"layout and all sibling pixels use one accepted revision")
        sameFrame(after,render(root,12,5),12,5)
        check(before.cellAt(0,0).style.foreground==Color.Red && before.cellAt(0,1).grapheme=="Q","earlier snapshot is independent")
        state.set("done")
        check(app.snapshot(12,5).cellAt(0,0).grapheme=="d","business binding continues after failure and success")
    } finally {app.dispose()}
    check(root.cleanups==1,"retained component cleans up exactly once")
}
func sameFrame(first:Frame,second:Frame,width:Int64,height:Int64):Unit {
    for(y in 0..height){for(x in 0..width){
        let a=first.cellAt(x,y);let b=second.cellAt(x,y)
        check(a.grapheme==b.grapheme && a.width==b.width && a.continuation==b.continuation && a.isTransparent==b.isTransparent && a.style==b.style,"Application snapshot equals active-root M1 render at ${x},${y}")
    }}
}

// The same individually legal Max minimum must still be accepted when clipped
// by a finite viewport. Only the actual allocated minimum sum may overflow.
func candidateMinimumSumRejectsBeforeCommit(env:TestEnvironment):Unit {
    let candidate=Theme.parse("schema_version=1\nname=\"CandidateMin\"\n[text]\nforeground=\"blue\"\n[components.text.spacing]\nweight=1\nmin_width=9223372036854775807\n")
    let finite=Application(Row { Text("a");Text("b") },theme:prepared("FiniteBase","red"))
    finite.startHeadless()
    try {
        finite.snapshot(4,1)
        let valid=finite.loadTheme(ThemeSource.Prepared(candidate))
        pump(finite,valid,env);applied(valid,1)
        unchanged(finite,"CandidateMin",1,valid.id)
        let clipped=finite.snapshot(4,1)
        check(clipped.width==4 && clipped.height==1 && clipped.cellAt(0,0).grapheme=="a","finite viewport clips legal Max minima without rejecting the candidate")
        check(clipped.cellAt(0,0).style.foreground==Color.Blue && finite.post({=>}),"finite legal candidate is visible and session stays active")
    } finally {finite.dispose()}
    let state=Observable<String>("a")
    let getters=Box<Int64>(0);let mounts=Box<Int64>(0)
    let root=Row { Text({=>getters.value++;state.get()});Text("b") }
        .onMount({_=>mounts.value++;{=>}})
    let app=Application(root,theme:prepared("MinimumBase","red"));app.startHeadless()
    try {
        let old=reference(root)
        let pixels=app.snapshot(4,1)
        let empty=app.snapshot(Int64.Max,0)
        check(empty.width==Int64.Max && empty.height==0,"baseline Max by zero snapshot succeeds without giant allocation")
        let beforeGetters=getters.value
        let request=app.loadTheme(ThemeSource.Prepared(candidate))
        var layoutError=""
        try {
            for(_ in 0..20000) {
                app.snapshot(Int64.Max,0)
                if(request.result().isSome()){break}
                env.sync("tick")
            }
        } catch(error:Exception){layoutError=error.message}
        let info=app.themeInfo();let active=app.post({=>})
        println("OBSERVED candidate minima: error=[${layoutError}], result=${resultTag(request)}, info=${info.name}/${info.revision}/${info.requestId}, post=${active}, ref=${old.isValid()}")
        check(layoutError.isEmpty(),"T008 rejects predictable candidate minimum-sum overflow before layout throws")
        candidateFailure(request,"OutOfRange")
        unchanged(app,"MinimumBase",0,0)
        check(active && old.isValid() && old.sameNode(reference(root)),"failed layout candidate preserves active session and node generation")
        check(state.get()=="a" && getters.value==beforeGetters && mounts.value==1,"validation preserves business state without getter or mount replay")
        check(empty.width==Int64.Max && empty.height==0,"previous zero-area frame stays independent")
        sameFrame(pixels,app.snapshot(4,1),4,1)
        check(pixels.cellAt(0,0).style.foreground==Color.Red,"previous accepted pixels remain unchanged")
    } finally {app.dispose()}
}

// A mounted-subtree render is also a UI commit boundary; its 1x1 export size
// must not replace the active root viewport used for candidate validation.
func subtreeCandidateMinimumSumRejectsBeforeCommit(env:TestEnvironment):Unit {
    let state=Observable<String>("a")
    let getters=Box<Int64>(0);let mounts=Box<Int64>(0)
    let children=ArrayList<Component>()
    let root=Row { children.add(Text({=>getters.value++;state.get()}));Text("b") }
        .onMount({_=>mounts.value++;{=>}})
    let app=Application(root,theme:prepared("SubtreeBase","red"));app.startHeadless()
    try {
        let old=reference(root);let child=reference(children[0])
        let pixels=app.snapshot(4,1)
        let empty=app.snapshot(Int64.Max,0)
        check(empty.width==Int64.Max && empty.height==0,"subtree regression has valid Max by zero root baseline")
        let beforeGetters=getters.value
        let candidate=Theme.parse("schema_version=1\nname=\"SubtreeCandidate\"\n[text]\nforeground=\"blue\"\n[components.text.spacing]\nweight=1\nmin_width=9223372036854775807\n")
        let request=app.loadTheme(ThemeSource.Prepared(candidate))
        var layoutError=""
        try {
            for(_ in 0..20000) {
                let frame=render(children[0],1,1)
                check(frame.width==1 && frame.height==1,"mounted subtree export stays 1x1")
                if(request.result().isSome()){break}
                env.sync("tick")
            }
            println("OBSERVED after mounted subtree: ${resultTag(request)} info=${app.themeInfo().name}")
            app.snapshot(Int64.Max,0)
        } catch(error:Exception){layoutError=error.message}
        let info=app.themeInfo();let active=app.post({=>})
        println("OBSERVED subtree candidate minima: error=[${layoutError}], result=${resultTag(request)}, info=${info.name}/${info.revision}/${info.requestId}, post=${active}, ref=${old.isValid()}")
        check(layoutError.isEmpty(),"T008 subtree commit validates root constraints before publication or layout failure")
        candidateFailure(request,"OutOfRange")
        unchanged(app,"SubtreeBase",0,0)
        check(active && old.isValid() && child.isValid() && old.sameNode(reference(root)) && child.sameNode(reference(children[0])),"failed subtree candidate preserves session and both refs")
        check(state.get()=="a" && getters.value==beforeGetters && mounts.value==1,"subtree validation preserves business state and cached getters/mount")
        check(empty.width==Int64.Max && empty.height==0,"old zero-area frame stays independent after subtree commit boundary")
        sameFrame(pixels,app.snapshot(4,1),4,1)
    } finally {app.dispose()}
}
