package node_reference_regression
import cjtui.*
import std.runtime.{gc,getGCCount}

func getterGuardAcrossCollection():Unit {
    for(i in 0..64){
        let saved=Box<?Component>(Option<Component>.None);let attempted=Box<Bool>(false)
        let root=Text({=>
            let component=saved.value.getOrThrow()
            let node=component.reference().getOrThrow()
            attempted.value=true
            let before=getGCCount();gc(heavy:true);let after=getGCCount()
            var actual="NO_EXCEPTION"
            try{node.requestFocus()}catch(error:UIException){actual=error.code}
            println("GETTER iteration=${i} gcBefore=${before} gcAfter=${after} valid=${node.isValid()} focusCode=${actual}")
            check(actual=="ReentrantEvaluation","active getter guard iteration=${i}: expected=ReentrantEvaluation, actual=${actual}")
            "X"
        }).focusable(true)
        saved.value=Some(root);let app=Application(root)
        try {
            app.startHeadless();let frame=app.snapshot(1,1)
            check(attempted.value && frame.toPlainText()=="X","active getter was actually evaluated")
            let node=root.reference().getOrThrow()
            check(node.isValid() && node.isEnabled() && node.isVisible(),"active node remains queryable after collection")
        }finally{app.dispose()}
    }
    println("PASS bounded64 active getter/public GC cycles")
}
