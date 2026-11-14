package rendering_workloads

import cjtui.*

// Focus and viewport ownership are business references, not runtime node IDs.
public class CaretScene {
    public let name: String
    public let root: Component
    public let app: Application
    public let first: Component
    public let second: Component
    public let viewport: Component
    private let width: Int64
    private let caretX: Observable<Int64>
    private let caretVisible: Observable<Bool>

    public init(name: String, width: Int64, height: Int64) {
        this.name = name; this.width = width
        let x = Observable<Int64>(1)
        let visible = Observable<Bool>(true)
        this.caretX = x; this.caretVisible = visible
        let firstRef: Array<?Component> = [None]
        let secondRef: Array<?Component> = [None]
        let viewportRef: Array<?Component> = [None]
        let root = if (name == "viewport_caret") {
            Column {
                Text("H").width(width).height(1)
                let view = ScrollView {
                    let content = Canvas({constraints => constraints.constrain(Size(width, 4))}, {context =>
                        context.put(0, 0, "A中é👩‍💻🇨🇳")
                        context.put(0, 1, "B中é👩‍💻🇨🇳")
                        context.put(0, 2, "C中é👩‍💻🇨🇳")
                        context.put(0, 3, "D中é👩‍💻🇨🇳")
                        if (firstRef[0].getOrThrow().reference().getOrThrow().isFocused()) { context.caret(1, 2) }
                    }).width(width).height(4).focusable(true)
                    firstRef[0] = Some(content)
                }.width(width).height(2).focusable(false)
                viewportRef[0] = Some(view)
                Text("F").width(width).height(1)
            }.width(width).height(height)
        } else {
            Column {
                let first = Canvas({constraints => constraints.constrain(Size(width, 1))}, {context =>
                    if (firstRef[0].getOrThrow().reference().getOrThrow().isFocused()) {
                        context.caret(x.get(), 0, visible: visible.get())
                    }
                }).width(width).height(1).focusable(true)
                firstRef[0] = Some(first)
                if (name == "readonly_focus_caret") {
                    let second = Canvas({constraints => constraints.constrain(Size(width, 1))}, {context =>
                        if (secondRef[0].getOrThrow().reference().getOrThrow().isFocused()) { context.caret(2, 0) }
                    }).width(width).height(1).focusable(true)
                    secondRef[0] = Some(second)
                    Text("A中é👩‍💻🇨🇳").width(width).height(1)
                }
            }.width(width).height(height)
        }
        this.root = root
        this.first = firstRef[0].getOrThrow()
        this.second = match (secondRef[0]) { case Some(value) => value; case None => firstRef[0].getOrThrow() }
        this.viewport = match (viewportRef[0]) { case Some(value) => value; case None => root }
        this.app = Application(root, glyphMode: GlyphMode.Unicode,
            theme: Theme.parse("schema_version = 1\nname = \"benchmark\"\n"))
    }

    public func focusInitial(): Unit { first.reference().getOrThrow().requestFocus() }

    public func action(epoch: Int64): Unit {
        if (name == "caret_only") {
            let step = epoch % 4
            caretX.set(if (step == 1) { 2 } else if (step == 2) { width } else { 1 })
            caretVisible.set(step != 3)
        } else if (name == "readonly_focus_caret") {
            if (epoch % 3 == 1) { second.reference().getOrThrow().requestFocus() }
            else { first.reference().getOrThrow().requestFocus() }
        } else if (name == "viewport_caret") {
            if (epoch % 3 == 1) { viewport.reference().getOrThrow().scrollTo(0, 1) }
            else if (epoch % 3 == 0) { viewport.reference().getOrThrow().scrollTo(0, 0) }
        } else { throw Exception("unknown caret scene ${name}") }
    }
}
