package interaction_b
import cjtui.*

func reviewCandidateInvalidationCase(exported:Bool,invalidate:Bool):Unit {
    let canvas=Box<?Component>(Option<Component>.None);let state=Observable<String>("a")
    let calls=Box<Int64>(0);let getters=Box<Int64>(0);let mounts=Box<Int64>(0)
    let old=Theme.parse("schema_version=1\nname=\"Old\"\n[styles.grow.spacing]\nweight=0\nmin_width=0\n")
    let candidate=Theme.parse("schema_version=1\nname=\"Candidate\"\n[styles.grow.spacing]\nweight=1\nmin_width=9223372036854775807\n")
    let root=Row{
        canvas.value=Canvas({b=>calls.value++;if(b.maxWidth.isNone()){Size(1,0)}else{b.constrain(Size(Int64.Max,0))}},{_=>})
        Row{Text({=>getters.value++;state.get()}).styles([StyleUse.Named("grow")]);Text("b").styles([StyleUse.Named("grow")])}.layoutWeight(1)
    }.onMount({_=>mounts.value++;{=>}})
    let app=Application(root,theme:old);app.startHeadless()
    try {
        let saved=ref(root);let child=ref(canvas.value)
        let frame=app.snapshot(Int64.Max,0);check(frame.width==Int64.Max && frame.height==0,"I07 legal zero-area baseline")
        if(exported){render(canvas.value.getOrThrow(),Int64.Max,0)}
        let beforeCalls=calls.value;let beforeGetters=getters.value;let beforeFrames=app.stats().frames
        // Prepared is already in the UI mailbox on submit; no worker/readiness sleep.
        let request=app.loadTheme(ThemeSource.Prepared(candidate));var error=""
        try {
            if(invalidate){app.batch({=>state.set("c")})}
            for(_ in 0..2000){app.snapshot(Int64.Max,0);if(request.result().isSome()){break};sleep(Duration.millisecond)}
        }catch(e:Exception){error=e.message}
        let info=app.themeInfo();let active=app.post({=>})
        let failed=match(request.result()){case Some(ThemeResult.Failed(_))=>true;case _=>false}
        println("I07 export=${exported} invalidation=${invalidate} failed=${failed} error=[${error}] info=${info.name}/${info.revision} active=${active} rootRef=${saved.isValid()} canvasRef=${child.isValid()} measureDelta=${calls.value-beforeCalls} getterDelta=${getters.value-beforeGetters}")
        check(error.isEmpty(),"I07 invalidated candidate must fail before layout exception")
        check(failed && info.name=="Old" && info.revision==0 && info.requestId==0,"I07 candidate failure retains old theme")
        check(active && saved.isValid() && child.isValid() && saved.sameNode(ref(root)),"I07 candidate failure retains active session/refs")
        check(state.get()==if(invalidate){"c"}else{"a"},"I07 business update retained")
        check(mounts.value==1,"I07 no remount during preview")
        if(!invalidate){
            check(getters.value==beforeGetters,"I07 no business getter replay for rejected clean candidate")
            if(app.stats().frames==beforeFrames){check(calls.value==beforeCalls,"I07 no preview measure when no target frame was produced")}
        }
    } finally {app.dispose()}
}
func reviewCandidateAfterInvalidation():Unit {
    reviewCandidateInvalidationCase(false,true)
    reviewCandidateInvalidationCase(true,false)
    reviewCandidateInvalidationCase(true,true)
}
