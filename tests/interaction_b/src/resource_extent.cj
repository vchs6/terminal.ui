package interaction_b
import cjtui.*

// Public finite result checks only. Root-pass count and allocation strategy need
// the independent sole-layout source audit; Canvas measure calls are not passes.
func finiteExtentResource():Unit {
    let root=Canvas({_=>Size(1,65536)},{p=>p.put(0,0,"A");p.put(0,65535,"Z")}).viewport(ScrollAxes.Vertical)
    let app=Application(root);app.startHeadless()
    try {
        let first=app.snapshot(1,2)
        check(first.width==1 && first.height==2,"B02 actual Frame remains1x2")
        picture(first,"A\n ","B02 finite large logical initial")
        check(ref(root).viewportSnapshot().contentHeight==65536,"B02 finite logical extent65536")
        app.batch({=>ref(root).scrollTo(0,65534)})
        picture(app.snapshot(1,2)," \nZ","B02 finite logical tail without extent-sized oracle")
    } finally {app.dispose()}
}
