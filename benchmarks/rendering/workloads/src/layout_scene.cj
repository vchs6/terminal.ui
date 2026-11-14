package rendering_workloads

import cjtui.*

public class LayoutScene {
    public let root: Component
    public let app: Application
    public let name: String
    private let text: Observable<String>
    private let color: Observable<Color>
    private let shown: Observable<Bool>
    private let firstWidth: Observable<Int64>
    private let baseWidth: Int64

    public init(name: String, width: Int64, height: Int64) {
        this.name = name
        let text = Observable<String>("A中é👩‍💻🇨🇳")
        let color = Observable<Color>(Color.Default)
        let shown = Observable<Bool>(true)
        let baseWidth = width / 8
        let firstWidth = Observable<Int64>(baseWidth)
        this.text = text; this.color = color; this.shown = shown
        this.firstWidth = firstWidth; this.baseWidth = baseWidth
        let root = if (name == "same_row_columns" || name == "row_flex_width") {
            Column {
                Row {
                    Text({=> text.get()}).width({=> firstWidth.get()}).height(1).foreground({=> color.get()})
                    for (i in 0..7) {
                        let index = i
                        Text("A中é👩‍💻🇨🇳").width({=>
                            let remainder = width - firstWidth.get()
                            remainder / 7 + if (index < remainder % 7) { 1 } else { 0 }
                        }).height(1)
                    }
                }.width(width).height(1)
                for (_ in 1..height) { Text("A中é👩‍💻🇨🇳").width(width).height(1) }
            }.width(width).height(height)
        } else if (name == "column_wrap_height") {
            Column {
                Text({=> text.get()}).width(if (width < 10) { width } else { 10 }).wrap(TextWrap.Grapheme)
                Text("lower panel").width(width).height(1)
            }.width(width).height(height)
        } else {
            Column {
                for (i in 0..height) {
                    if (i == height - 1) {
                        Text({=> text.get()}).foreground({=> color.get()}).visible({=> shown.get()}).width(width).height(1)
                    } else { Text("A中é👩‍💻🇨🇳").width(width).height(1) }
                }
            }.width(width).height(height)
        }
        this.root = root
        this.app = Application(root, glyphMode: GlyphMode.Unicode,
            theme: Theme.parse("schema_version = 1\nname = \"benchmark\"\n"))
    }

    public func action(epoch: Int64): Unit {
        let changed = epoch % 2 == 1
        if (name == "same_row_columns") { color.set(if (changed) { Color.Red } else { Color.Default }) }
        else if (name == "row_flex_width") { firstWidth.set(if (changed) { baseWidth * 2 } else { baseWidth }) }
        else if (name == "column_wrap_height") {
            text.set(if (changed) { "A中é👩‍💻🇨🇳A中é👩‍💻🇨🇳" } else { "A中é👩‍💻🇨🇳" })
        } else if (name == "batch_properties") {
            text.set(if (changed) { "A文é👩‍💻🇨🇳" } else { "A中é👩‍💻🇨🇳" })
            color.set(if (changed) { Color.Red } else { Color.Default })
            shown.set(!changed)
        } else { throw Exception("unknown layout scene ${name}") }
    }
}
