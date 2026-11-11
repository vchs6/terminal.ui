package interaction_b
import cjtui.*
import std.env.*
import std.fs.*

// No focusable children: actual arrows must use A activeTarget without fake focus.
func ptyFixture():Int64 {
    let root=Column({=>hundredRows()});let app=Application(root);let query=Box<Int64>(0)
    app.onKeyEvent({e=>
        if(e.key.text=="q"){app.stop();e.preventDefault()}
        if(e.key.text=="s"){
            query.value++;let v=ref(root).viewportSnapshot()
            let active=app.activeTarget().getOrThrow().sameNode(ref(root))
            File.writeTo(getVariable("CJTUI_VIEWPORT_OUTPUT").getOrThrow()+"/state-${query.value}",
                "${v.width}/${v.height}/${v.contentHeight}/${v.offsetY}/${app.focusedNode().isNone()}/${active}".toArray())
        }
    })
    app.run();return 0
}
