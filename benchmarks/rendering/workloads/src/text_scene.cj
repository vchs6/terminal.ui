package rendering_workloads

import cjtui.*

// Text-oriented scenes share a lifecycle but preserve each scenario's own
// business state and mutation sequence. No rendering occurs in action().
public class TextScene {
    public let root: Component
    public let app: Application
    public let name: String
    public let width: Int64
    public let height: Int64
    private let text: Observable<String>
    private let color: Observable<Color>
    private let entries: Array<Observable<String>>

    public init(name: String, width: Int64, height: Int64) {
        this.name = name; this.width = width; this.height = height
        let text = Observable<String>(if (name == "same_width_text") { "中" } else { "A中é👩‍💻🇨🇳" })
        let color = Observable<Color>(Color.Default)
        let entries = Array<Observable<String>>(height, {_ => Observable<String>("A中é👩‍💻🇨🇳")})
        this.text = text; this.color = color; this.entries = entries
        let root = if (name == "unicode_cells") {
            Column {
                Text({=> text.get()}).foreground({=> color.get()}).width(width).height(1)
            }.width(width).height(height)
        } else if (name == "same_width_text" || name == "text_length") {
            Column {
                for (i in 0..height) {
                    if (i == height - 1) {
                        if (name == "text_length") { Text({=> text.get()}).height(1) }
                        else { Text({=> text.get()}).width(width).height(1) }
                    } else { Text("A中é👩‍💻🇨🇳").width(width).height(1) }
                }
            }.width(width).height(height)
        } else if (name == "shared_observable") {
            Column {
                for (i in 0..height) {
                    if (i == 0 || i == height - 1) {
                        Text({=> text.get()}).width(width).height(1)
                    } else { Text("A中é👩‍💻🇨🇳").width(width).height(1) }
                }
            }.width(width).height(height)
        } else {
            Column {
                for (i in 0..height) {
                    let entry = entries[i]
                    if (i == height - 1) {
                        Text({=> entry.get()}).foreground({=> color.get()}).background(Color.Blue)
                            .bold(true).dim(true).italic(true).underline(true).inverse(true).strikethrough(true)
                            .width(width).height(1)
                    } else {
                        Text({=> entry.get()}).foreground(Color.Cyan).background(Color.Blue)
                            .bold(true).dim(true).italic(true).underline(true).inverse(true).strikethrough(true)
                            .width(width).height(1)
                    }
                }
            }.width(width).height(height)
        }
        this.root = root
        let theme = Theme.parse("schema_version = 1\nname = \"benchmark\"\n")
        this.app = Application(root, glyphMode: GlyphMode.Unicode, theme: theme)
    }

    public func dirtyLeaves(): Int64 {
        if (name == "broad_text") { return height }
        if (name == "shared_observable") { return if (height > 1) { 2 } else { 1 } }
        1
    }

    public func textBytes(): Int64 {
        if (name == "unicode_cells") { return text.get().toArray().size }
        let common = Int64("A中é👩‍💻🇨🇳".toArray().size)
        if (name == "same_width_text" || name == "text_length") {
            return (height - 1) * common + text.get().toArray().size
        }
        if (name == "shared_observable") {
            let sharedCount: Int64 = if (height > 1) { 2 } else { 1 }
            return sharedCount * text.get().toArray().size + (height - sharedCount) * common
        }
        var total: Int64 = 0
        for (entry in entries) { total += entry.get().toArray().size }
        total
    }

    public func action(epoch: Int64): Unit {
        if (name == "unicode_cells") {
            let step = epoch % 4
            if (step == 1) { text.set("A文é👩‍💻🇨🇳"); color.set(Color.Default) }
            else if (step == 2) { text.set("A"); color.set(Color.Default) }
            else if (step == 3) { text.set("A"); color.set(Color.Red) }
            else { text.set("A中é👩‍💻🇨🇳"); color.set(Color.Default) }
        } else if (name == "text_length") {
            let step = epoch % 4
            if (step == 1) { text.set("A文é👩‍💻🇨🇳") }
            else if (step == 2) { text.set("A") }
            else if (step == 3) { text.set("") }
            else { text.set("A中é👩‍💻🇨🇳") }
        } else if (name == "same_width_text") {
            text.set(if (epoch % 2 == 1) { "文" } else { "中" })
        } else if (name == "leaf_color" || name == "vertical_panels") {
            color.set(if (epoch % 2 == 1) { Color.Red } else { Color.Default })
        } else if (name == "shared_observable") {
            text.set(if (epoch % 2 == 1) { "A文é👩‍💻🇨🇳" } else { "A中é👩‍💻🇨🇳" })
        } else if (name == "broad_text") {
            let value = if (epoch % 2 == 1) { "A文é👩‍💻🇨🇳" } else { "A中é👩‍💻🇨🇳" }
            for (entry in entries) { entry.set(value) }
        } else { throw Exception("unsupported text scene ${name}") }
    }
}
