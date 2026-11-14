package rendering_workloads

import cjtui.*

public class OverlayScene {
    public let name: String
    public let root: Component
    public let app: Application
    private let base: Observable<String>
    private let anchor: Component
    private let layerWidth: Observable<Int64>
    private let anchorWidth: Observable<Int64>
    private let width: Int64
    private let height: Int64
    private var parent: ?OverlayHandle = None
    private var child: ?OverlayHandle = None

    public init(name: String, width: Int64, height: Int64) {
        this.name = name; this.width = width; this.height = height
        let base = Observable<String>("A中é👩‍💻🇨🇳")
        let layerWidth = Observable<Int64>(width / 2)
        let anchorWidth = Observable<Int64>(1)
        this.base = base; this.layerWidth = layerWidth; this.anchorWidth = anchorWidth
        let anchorRef: Array<?Component> = [None]
        let root = Column {
            Row {
                Text(" ").width({=> anchorWidth.get()}).height(1)
                let anchor = Text("anchor").width(6).height(1)
                anchorRef[0] = Some(anchor)
            }.width(width).height(1)
            for (_ in 1..height) { Text({=> base.get()}).width(width).height(1) }
        }.width(width).height(height)
        this.root = root; this.anchor = anchorRef[0].getOrThrow()
        this.app = Application(root, glyphMode: GlyphMode.Unicode,
            theme: Theme.parse("schema_version = 1\nname = \"benchmark\"\n"))
    }

    public func open(): Unit {
        let layerWidth = this.layerWidth
        let layerHeight = if (name == "large_fill_shadows") { height / 2 + 1 } else { 4 }
        let layer = Canvas({constraints => constraints.constrain(Size(layerWidth.get(), layerHeight))}, {context =>
            if (name == "overlay_holes") {
                context.put(0, 0, "opaque ")
                context.put(2, 1, " ")
            } else { context.fill(Rect(0, 0, layerWidth.get(), layerHeight)); context.put(0, 0, "overlay") }
        }).width({=> layerWidth.get()}).height(layerHeight).shadow()
        let options = OverlayOptions(anchor: Some(anchor.reference().getOrThrow()), placement: OverlayPlacement.BelowStart,
            mode: OverlayMode.NonModal, takeFocus: false)
        parent = Some(root.reference().getOrThrow().openOverlay(layer, options: options))
        if (name == "overlay_nested_close") {
            let host = parent.getOrThrow().content().getOrThrow()
            child = Some(host.openOverlay(Text("child").width(width / 3).height(2),
                options: OverlayOptions(mode: OverlayMode.NonModal, takeFocus: false)))
        }
    }

    public func action(epoch: Int64): Unit {
        let changed = epoch % 2 == 1
        if (name == "overlay_holes") {
            if (changed) { if (parent.isNone()) { open() }; base.set("B中é👩‍💻🇨🇳") } else { parent.getOrThrow().close(); parent = None; base.set("A中é👩‍💻🇨🇳") }
        } else if (name == "overlay_move") { anchorWidth.set(if (changed) { width / 4 } else { 1 }) }
        else if (name == "overlay_shrink") { layerWidth.set(if (changed) { width / 4 } else { width / 2 }) }
        else if (name == "overlay_nested_close") {
            if (epoch % 3 == 1) { base.set("B中é👩‍💻🇨🇳") }
            else if (epoch % 3 == 2) {
                let attached = child.getOrThrow()
                parent.getOrThrow().close()
                if (attached.isOpen()) { throw Exception("child overlay stayed open after parent close") }
                parent = None; child = None
            }
            else { open() }
        } else if (name == "large_fill_shadows") { anchorWidth.set(if (changed) { width / 4 } else { 1 }) }
        else { throw Exception("unknown overlay scene ${name}") }
    }
}
