package rendering_workloads

import cjtui.*

public class KeyedScene {
    public let root: Component
    public let app: Application
    private let entries: Observable<Array<String>>

    public init(width: Int64, height: Int64) {
        let entries = Observable<Array<String>>(["A", "B", "C"])
        this.entries = entries
        let root = Row {
            ForEach<String>({=> entries.get()}, {value => value}, {item => Text({=> item.value}).width(1).height(1)})
        }.width(width).height(height)
        this.root = root
        this.app = Application(root, glyphMode: GlyphMode.Unicode,
            theme: Theme.parse("schema_version = 1\nname = \"benchmark\"\n"))
    }

    // Mounted children are available after start; separators are ordinary
    // manually inserted children, not keys or dynamic declarations.
    public func insertSeparators(): Unit {
        let parent = root.reference().getOrThrow()
        let children = parent.children()
        if (children.size != 3) { throw Exception("keyed children missing at mount") }
        parent.insertBefore(children[1], Text("|").width(1).height(1))
        parent.insertBefore(children[2], Text("|").width(1).height(1))
    }

    public func action(epoch: Int64): Unit {
        let step = epoch % 3
        entries.set(if (step == 1) { ["C", "A", "B"] } else if (step == 2) { ["B", "C", "A"] } else { ["A", "B", "C"] })
    }
}
