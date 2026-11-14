package rendering_workloads

import cjtui.*

public class ViewportScene {
    public let root: Component
    public let app: Application
    public let viewport: Component
    public let name: String
    private let width: Int64
    private let height: Int64
    private let rows: Observable<Array<String>>

    public init(name: String, width: Int64, height: Int64) {
        this.name = name; this.width = width; this.height = height
        let rows = Observable<Array<String>>(["A", "B"])
        this.rows = rows
        let count = if (name == "large_mounted_viewport") { height * 8 } else { height * 2 }
        let viewportRef: Array<?Component> = [None]
        let root = if (name == "root_fallback") {
            Column {
                ForEach<String>({=> rows.get()}, {value => value}, {item =>
                    Text({=> if (item.value.startsWith("C")) { "C中é👩‍💻🇨🇳" } else { item.value + "中é👩‍💻🇨🇳" }}).width(width).height(1)
                })
            }.width(width)
        } else {
            Column {
                let viewport = ScrollView {
                    for (i in 0..count) { Text("${i} A中é👩‍💻🇨🇳").width(width).height(1) }
                }.width(width).height(4)
                viewportRef[0] = Some(viewport)
                Text("footer").width(width).height(1)
            }.width(width).height(height)
        }
        this.viewport = if (name == "root_fallback") { root } else { viewportRef[0].getOrThrow() }
        this.root = root
        this.app = Application(root, glyphMode: GlyphMode.Unicode,
            theme: Theme.parse("schema_version = 1\nname = \"benchmark\"\n"))
    }

    public func assertCommitted(epoch: Int64): Unit {
        let state = viewport.reference().getOrThrow().viewportSnapshot()
        if (name == "root_fallback") {
            let step = epoch % 3
            let expectedContent = if (step == 0) { height } else { height + 2 }
            let expectedOffset = if (step == 2) { 2 } else { 0 }
            if (state.width != width || state.height != height || state.contentHeight != expectedContent || state.offsetY != expectedOffset) {
                throw Exception("root fallback geometry mismatch at epoch ${epoch}")
            }
        } else {
            let expectedContent = if (name == "large_mounted_viewport") { height * 8 } else { height * 2 }
            let step = epoch % (if (name == "scroll_step") { 4 } else if (name == "scroll_multistep") { 3 } else { 2 })
            let expectedOffset = if (name == "scroll_step") { if (step == 1) { 1 } else if (step == 2) { 2 } else { 0 } }
                else { if (step == 1) { 4 } else { 0 } }
            if (state.width != width || state.height != 4 || state.contentHeight != expectedContent || state.offsetY != expectedOffset) {
                throw Exception("viewport geometry mismatch at epoch ${epoch}")
            }
        }
    }

    public func action(epoch: Int64): Unit {
        if (name == "root_fallback") {
            let step = epoch % 3
            if (step == 1) {
                // Keys must be distinct even when the visual payload is the same.
                let expanded = Array<String>(height + 2, {i =>
                    if (i == 0) { "A" } else if (i == 1) { "B" } else { "C${i}" }
                })
                rows.set(expanded)
            } else if (step == 2) { viewport.reference().getOrThrow().scrollTo(0, 2) }
            else { rows.set(["A", "B"]) }
        } else if (name == "scroll_step") {
            let step = epoch % 4
            viewport.reference().getOrThrow().scrollTo(0, if (step == 1) { 1 } else if (step == 2) { 2 } else { 0 })
        } else {
            let step = epoch % (if (name == "scroll_multistep") { 3 } else { 2 })
            viewport.reference().getOrThrow().scrollTo(0, if (step == 1) { 4 } else { 0 })
        }
    }
}
