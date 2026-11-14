package rendering_workloads

import cjtui.*

public class GlyphScene {
    public let root: Component
    public let app: Application
    public let name: String
    private let text: Observable<String>

    public init(name: String, width: Int64, height: Int64) {
        this.name = name
        let text = Observable<String>(if (name == "ellipsis_policy") { "abcdef" } else { "中" })
        this.text = text
        let root = if (name == "ellipsis_policy") {
            Column { Text({=> text.get()}).width(5).height(1).overflow(TextOverflow.Ellipsis) }
                .width(width).height(height)
        } else {
            Column { Text({=> text.get()}).width(width).height(1) }.width(width).height(height)
        }
        this.root = root
        this.app = Application(root, glyphMode: GlyphMode.Unicode,
            theme: Theme.parse("schema_version = 1\nname = \"benchmark\"\n"))
    }

    public func glyphMode(epoch: Int64): GlyphMode {
        if (name == "glyph_projection") { return GlyphMode.Ascii }
        if (epoch % 2 == 1) { GlyphMode.Ascii } else { GlyphMode.Unicode }
    }

    public func action(epoch: Int64): Unit {
        if (name == "glyph_projection") {
            let step = epoch % 3
            text.set(if (step == 1) { "文" } else if (step == 2) { "??" } else { "中" })
        }
    }
}
