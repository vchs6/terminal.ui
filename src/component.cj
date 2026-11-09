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
func measure(c: Component): (Int64, Int64) {
    if (c.kind == 0) {
        var w: Int64 = 0
        var maxWidth: Int64 = 0
        var h: Int64 = 1
        for (g in graphemeClusters(c.value)) {
            if (g == "\n" || g == "\r\n") { if (w > maxWidth) { maxWidth = w }; w = 0; h++ }
            else { w += displayWidth(g) }
        }
        if (w > maxWidth) { maxWidth = w }
        return (maxWidth, h)
    }
    var w: Int64 = 0
    var h: Int64 = 0
    for (child in c.children) {
        let (cw, ch) = measure(child)
        if (c.kind == 1) { if (cw > w) { w = cw }; h += ch }
        else { w += cw; if (ch > h) { h = ch } }
    }
    (w, h)
}
func draw(c: Component, frame: Frame, x: Int64, y: Int64, right: Int64, bottom: Int64, inherited: Style): Unit {
    let style = Style(foreground: c.fg ?? inherited.foreground, background: c.bg ?? inherited.background, bold: c.isBold ?? inherited.bold)
    if (c.kind == 0) {
        // Validate the complete string, including clipped text.
        validateText(c.value)
        var cx = x
        var cy = y
        for (g in graphemeClusters(c.value)) {
            if (g == "\n" || g == "\r\n") { cx = x; cy++; continue }
            let w = displayWidth(g)
            if (cx >= x && cy >= y && cy < bottom && cx < right && w <= right - cx) { frame.put(cx, cy, g, style: style) }
            cx += w
        }
        return
    }
    var cx = x
    var cy = y
    for (child in c.children) {
        let (w, h) = measure(child)
        let cr = if (cx + w < right) { cx + w } else { right }
        let cb = if (cy + h < bottom) { cy + h } else { bottom }
        draw(child, frame, cx, cy, cr, cb, style)
        if (c.kind == 1) { cy += h } else { cx += w }
    }
}
public func render(root: Component, width: Int64, height: Int64): Frame {
    let result = Frame(width, height)
    draw(root, result, 0, 0, width, height, Style())
    result
}
