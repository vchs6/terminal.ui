package node_reference_regression
import cjtui.*
func getterGuardAcrossCollection():Unit {
    for(i in 0..500){
        let saved=Box<?Component>(Option<Component>.None);let attempted=Box<Bool>(false)
        let root=Text({=>
            if(let Some(c)<-saved.value){if(let Some(r)<-c.reference()){
                attempted.value=true
                try{r.requestFocus();throw Exception("FAIL: missing getter mutation guard")}
                catch(e:UIException){if(e.code!="ReentrantEvaluation"){throw Exception("FAIL: active getter iteration=${i}, expected=ReentrantEvaluation, actual=${e.code}")}}
            }}
            "X"
        }).focusable(true)
        saved.value=Some(root);let app=Application(root)
        try{
            app.startHeadless();app.snapshot(1,1)
            check(attempted.value,"active getter obtained public Component.reference")
        }finally{app.dispose()}
    }
    println("PASS bounded500 natural getter guard mount cycles")
}
