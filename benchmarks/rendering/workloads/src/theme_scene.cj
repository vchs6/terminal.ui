package rendering_workloads

import cjtui.*

public class ThemeScene {
    public let root: Component
    public let app: Application
    public let name: String
    private let base: Theme
    private let changed: Theme

    public init(name: String, width: Int64, height: Int64) {
        this.name = name
        let base = Theme.parse("schema_version = 1\nname = \"base\"\n")
        let detail = if (name == "theme_color") { "[text]\nforeground = \"red\"\n" }
            else if (name == "theme_spacing") { "[spacing]\ngap = 1\n" }
            else if (name == "theme_four_sides") {
                "[spacing]\npadding_top = 1\npadding_right = 2\npadding_bottom = 3\npadding_left = 4\n"
            } else { "[text]\nwrap = \"grapheme\"\n" }
        let changed = Theme.parse("schema_version = 1\nname = \"changed\"\n" + detail)
        this.base = base; this.changed = changed
        let root = Column {
            for (_ in 0..height) { Text("A中é👩‍💻🇨🇳 A中é👩‍💻🇨🇳").width(width) }
        }.width(width).height(height)
        this.root = root
        this.app = Application(root, glyphMode: GlyphMode.Unicode, theme: base)
    }

    // Prepared theme submission is synchronous; the next public snapshot commits
    // its mailbox. The caller must check this result after that snapshot.
    public func action(epoch: Int64): ThemeRequest {
        app.loadTheme(ThemeSource.Prepared(if (epoch % 2 == 1) { changed } else { base }))
    }

    public func assertApplied(request: ThemeRequest): Unit {
        match (request.result()) {
            case Some(ThemeResult.Applied(_)) => ()
            case _ => throw Exception("theme request was not applied at the business barrier")
        }
    }
}
