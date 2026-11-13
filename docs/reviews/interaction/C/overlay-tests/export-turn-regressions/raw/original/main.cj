package overlay_export_probe
import cjtui.*
class Box { var value: ?OverlayHandle = Option<OverlayHandle>.None; init() {} }
main():Int64 {
    let root=Text("A").viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    try {
        app.snapshot(4,2);let box=Box()
        app.batch({=> box.value=Some(root.reference().getOrThrow().openOverlay(Text("P"),
            options:OverlayOptions(anchor:root.reference().getOrThrow(),placement:OverlayPlacement.BelowStart,takeFocus:false))) })
        app.snapshot(4,2);let h=box.value.getOrThrow()
        if (!h.isOpen()) { throw Exception("baseline overlay closed") }
        render(root,0,0)
        if (!h.isOpen()) { throw Exception("mounted export changed application overlay") }
        println("PASS mounted export preserves application overlay")
    } finally { app.dispose() }
    0
}
