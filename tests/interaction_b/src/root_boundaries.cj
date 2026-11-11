package interaction_b
import cjtui.*

func zeroHundredRoot():Unit {
    let root=Column({=>hundredRows()});let app=Application(root);app.startHeadless()
    try {
        let retained=ref(root);let frame=app.snapshot(80,0)
        check(frame.width==80 && frame.height==0,"B02 zero100 actual Frame")
        let s=retained.viewportSnapshot();check(s.height==0 && s.contentHeight==100 && s.offsetY==0,"B02 zero100 extent")
        app.batch({=>check(retained.scrollTo(0,100),"B02 zero axis legal offset endpoint100")})
        app.batch({=>retained.ensureVisible(rect:Rect(0,0,1,1))})
        offset(root,0,100,"B03 zero axis ensure does not locate")
        app.snapshot(80,24);offset(root,0,76,"B02 restore clamps zero100 offset")
        check(retained.sameNode(ref(root)) && app.focusedNode().isNone(),"B02 zero hundred identity/focus preserved")
    } finally {app.dispose()}
}

func rootOverflowBoundaries():Unit {
    for(mode in ["ordinary","horizontal","vertical","both"]) {
        let saved=Box<?Component>(Option<Component>.None)
        let root=Column({=>
            let inner=Column({=>hundredRows()}).layoutWeight(1)
            if(mode=="horizontal"){inner.viewport(ScrollAxes.Horizontal)}
            if(mode=="vertical"){inner.viewport(ScrollAxes.Vertical)}
            if(mode=="both"){inner.viewport(ScrollAxes.Both)}
            saved.value=Some(inner)
        })
        let app=Application(root);app.startHeadless()
        try {
            app.snapshot(3,10)
            let barrier=mode=="vertical" || mode=="both"
            check(ref(root).viewportSnapshot().contentHeight==if(barrier){10}else{100},"B02 overflow boundary ${mode}")
            if(barrier){
                let state=ref(saved.value).viewportSnapshot();check(state.height==10 && state.contentHeight==100,"B02 independent viewport keeps own extent")
                app.batch({=>check(!ref(root).scrollBy(0,1),"B02 independent viewport root remains fixed")})
            }else{
                app.batch({=>check(ref(root).scrollTo(0,90),"B02 ordinary/Horizontal overflow remains root-accessible")})
                picture(app.snapshot(3,10),"r90\nr91\nr92\nr93\nr94\nr95\nr96\nr97\nr98\nr99","B02 propagated tail ${mode}")
            }
        } finally {app.dispose()}
    }
    for(explicit in [false,true]) {
        let root=Column({=>hundredRows()}).height(3)
        if(explicit){root.viewport(ScrollAxes.Vertical)}
        let app=Application(root);app.startHeadless()
        try {
            app.snapshot(3,10);let s=ref(root).viewportSnapshot()
            check(s.height==3 && s.contentHeight==if(explicit){100}else{3},"B02 root fixed height vs explicit viewport")
            app.batch({=>check(ref(root).scrollTo(0,97)==explicit,"B02 fixed root explicit scrolling intent")})
        } finally {app.dispose()}
    }
    let root=Column({=>Column({=>hundredRows()}).visible(false);Text("V")})
    let app=Application(root);app.startHeadless()
    try {
        picture(app.snapshot(1,3),"V\n \n ","B02 hidden overflow ignored")
        check(ref(root).viewportSnapshot().contentHeight==3,"B02 hidden subtree cannot trigger fallback")
    } finally {app.dispose()}
}
