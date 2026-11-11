package theme_canvas_integration
import cjtui.*
import std.env.getCommandLine
func resultTag(request:ThemeRequest):String {
    match(request.result()){
        case None=>"pending"
        case Some(value)=>match(value){
            case ThemeResult.Applied(revision)=>"applied:${revision}"
            case ThemeResult.Failed(diagnostic)=>"failed:${diagnostic.code}"
            case ThemeResult.Superseded(id)=>"superseded:${id}"
            case ThemeResult.SessionClosed=>"closed"
        }
    }
}
func check(value:Bool,message:String):Unit {if(!value){throw Exception(message)}}
main():Int64 {
    let args=getCommandLine();let mode=if(args.contains("finite")){"finite"}else if(args.contains("control")){"control"}else{"subtree"}
    let width:Int64=if(mode=="finite"){4}else{Int64.Max}
    let exported=Box<?Component>(Option<Component>.None);let inner=Box<?Component>(Option<Component>.None)
    let state=Observable<String>("a");let mounts=Box<Int64>(0)
    let theme=Theme.parse("schema_version=1\nname=\"Old\"\n[styles.grow.spacing]\nweight=0\nmin_width=0\n")
    let candidate=Theme.parse("schema_version=1\nname=\"Candidate\"\n[styles.grow.spacing]\nweight=1\nmin_width=9223372036854775807\n")
    let root=Row {
        exported.value=Canvas({b=>if(b.maxWidth.isNone()){Size(1,0)}else{b.constrain(Size(Int64.Max,0))}},{_=>})
        inner.value=Row { Text({=>state.get()}).styles([StyleUse.Named("grow")]);Text("b").styles([StyleUse.Named("grow")]) }.layoutWeight(1)
    }
    root.onMount({_=>mounts.value++;{=>}})
    let app=Application(root,theme:theme);app.startHeadless()
    try {
        let owner=root.reference().getOrThrow();let canvas=exported.value.getOrThrow().reference().getOrThrow()
        let baseline=app.snapshot(width,0)
        check(baseline.width==width && baseline.height==0,"initial public zero-area snapshot failed")
        println("BASE mode=${mode} viewport=${width}x0 info=${app.themeInfo().name}/${app.themeInfo().revision} active=${app.post({=>})} ref=${owner.isValid()}")
        if(mode=="subtree"){
            let altered=render(exported.value.getOrThrow(),Int64.Max,0)
            check(altered.width==Int64.Max && altered.height==0,"mounted Canvas export size failed")
            println("EXPORT Canvas=${altered.width}x${altered.height}")
        }
        let request=app.loadTheme(ThemeSource.Prepared(candidate));var layoutError="";var errorCode=""
        try {
            for(_ in 0..2000){
                app.snapshot(width,0)
                if(request.result().isSome()){break}
                sleep(Duration.millisecond)
            }
        }catch(error:Exception){layoutError=error.message;if(let Some(ui)<-(error as UIException)){errorCode=ui.code}}
        let info=app.themeInfo();let active=app.post({=>})
        println("RESULT mode=${mode} result=${resultTag(request)} error=[${layoutError}] errorCode=${errorCode} info=${info.name}/${info.revision}/${info.requestId} active=${active} rootRef=${owner.isValid()} canvasRef=${canvas.isValid()} state=${state.get()} mounts=${mounts.value}")
        // T008: a predictable candidate layout failure is rejected before publication.
        check(layoutError.isEmpty(),"T008 must reject before root layout throws; mode=${mode}, result=${resultTag(request)}, error=${layoutError}")
        if(mode=="finite"){
            check(resultTag(request)=="applied:1","finite Max minima must remain a valid clipped candidate")
            check(info.name=="Candidate" && info.revision==1 && info.requestId==request.id,"finite candidate commits exactly once")
        }else{
            let rejected=match(request.result()){case Some(ThemeResult.Failed(_))=>true;case _=>false}
            check(rejected,"T008 Max candidate must be Failed; mode=${mode}, actual=${resultTag(request)}")
            check(info.name=="Old" && info.revision==0 && info.requestId==0,"failed candidate preserves accepted ThemeInfo")
        }
        check(active && owner.isValid() && canvas.isValid(),"candidate outcome preserves active session and node refs")
        check(owner.sameNode(root.reference().getOrThrow()) && canvas.sameNode(exported.value.getOrThrow().reference().getOrThrow()),"candidate outcome preserves node generation")
        check(state.get()=="a" && mounts.value==1,"candidate outcome retains business state and mount identity")
        if(active){
            var recovery="ok"
            try{app.snapshot(width,0)}catch(error:Exception){recovery=error.message}
            println("RECOVERY mode=${mode} snapshot=[${recovery}] active=${app.post({=>})}")
            check(recovery=="ok" && app.post({=>}),"session remains usable for the next root snapshot")
        }
        println("PASS theme_canvas_integration ${mode}")
    }finally{app.dispose()}
    0
}
