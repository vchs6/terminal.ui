package cjtui
import std.collection.ArrayList
import std.sync.Mutex

let constructionLock = Mutex()
let parents = ArrayList<Component>()
public class Component {
    let kind: Int64
    let value: String
    let children = ArrayList<Component>()
    var fg: ?Color = None
    var bg: ?Color = None
    var isBold: ?Bool = None
    var fixedW: ?Int64 = None
    var fixedH: ?Int64 = None
    var minW: Int64 = 0
    var minH: Int64 = 0
    var weight: Int64 = 0
    var pad: Int64 = 0
    var spacing: Int64 = 0
    var align: Alignment = Alignment.Start
    var justify: Alignment = Alignment.Start
    var textAlignment: Alignment = Alignment.Start
    func nonnegative(v: Int64): Unit { if (v < 0) { throw IllegalArgumentException("negative layout value") } }
    public func width(v: Int64): Component { nonnegative(v); fixedW = v; this }
    public func height(v: Int64): Component { nonnegative(v); fixedH = v; this }
    public func widthAuto(): Component { fixedW = None; this }
    public func heightAuto(): Component { fixedH = None; this }
    public func minWidth(v: Int64): Component { nonnegative(v); minW = v; this }
    public func minHeight(v: Int64): Component { nonnegative(v); minH = v; this }
    public func layoutWeight(v: Int64): Component { nonnegative(v); weight = v; this }
    public func padding(v: Int64): Component { nonnegative(v); pad = v; this }
    public func gap(v: Int64): Component { nonnegative(v); if (kind == 0) { throw IllegalArgumentException("gap on text") }; spacing = v; this }
    public func alignItems(v: Alignment): Component { if (kind == 0) { throw IllegalArgumentException("alignment on text") }; align = v; this }
    public func justifyContent(v: Alignment): Component { if (kind == 0 || v == Alignment.Stretch) { throw IllegalArgumentException("invalid justification") }; justify = v; this }
    public func textAlign(v: Alignment): Component { if (kind != 0 || v == Alignment.Stretch) { throw IllegalArgumentException("invalid text alignment") }; textAlignment = v; this }
    init(kind: Int64, value: String) { this.kind = kind; this.value = value }
    public func foreground(value: Color): Component { fg = value; this }
    public func background(value: Color): Component { bg = value; this }
    public func bold(): Component { isBold = true; this }
}
func attach(c: Component): Component {
    constructionLock.lock()
    try { if (parents.size > 0) { parents[parents.size - 1].children.add(c) }; c }
    finally { constructionLock.unlock() }
}
public func Text(value: String): Component { attach(Component(0, value)) }
func container(kind: Int64, body: () -> Unit): Component {
    constructionLock.lock()
    try {
        let node = attach(Component(kind, ""))
        parents.add(node)
        try { body() } finally { parents.remove(at: parents.size - 1) }
        node
    } finally { constructionLock.unlock() }
}
public func Column(body: () -> Unit): Component { container(1, body) }
public func Row(body: () -> Unit): Component { container(2, body) }
