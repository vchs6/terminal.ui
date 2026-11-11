package cjtui

// Scoped access to the existing Frame; no mutable frame escapes this object.
public class PaintContext {
    private let session: RuntimeSession
    private let node: RuntimeNode
    private let frame: Frame
    private let originX: Int64
    private let originY: Int64
    private let area: Size
    private let clipping: Rect
    private let normal: ResolvedStyle
    private let selected: ResolvedStyle
    private let focusedValue: Bool
    private let enabledValue: Bool
    private var active = true
    init(session: RuntimeSession, node: RuntimeNode, frame: Frame, originX: Int64, originY: Int64,
        area: Size, clipping: Rect, normal: ResolvedStyle, selected: ResolvedStyle) {
        this.session = session; this.node = node; this.frame = frame
        this.originX = originX; this.originY = originY; this.area = area; this.clipping = clipping
        this.normal = normal; this.selected = selected
        this.enabledValue = session.focusManager.effective(node,true)
        this.focusedValue = if (let Some(focused) <- session.focusManager.focused) { focused.id == node.id } else { false }
    }
    private func check(): Unit {
        session.requireOwner()
        if (!active) { throw UIException("ExpiredPaintContext","paint context has expired") }
    }
    func expire(): Unit { active = false }
    public prop size: Size { get() { check(); area } }
    public prop clip: Rect { get() { check(); clipping } }
    public prop defaultStyle: Style { get() { check(); normal.style } }
    public prop selectedStyle: Style { get() { check(); selected.style } }
    public prop focused: Bool { get() { check(); focusedValue } }
    public prop enabled: Bool { get() { check(); enabledValue } }
    public func textWidth(text: String): Int64 { check(); displayWidth(text) }
    public func put(x: Int64, y: Int64, text: String, patch!: TextStylePatch = TextStylePatch(), selected!: Bool = false): Unit {
        check(); put(x,y,RichText(text),patch:patch,selected:selected)
    }
    public func put(x: Int64, y: Int64, text: RichText, patch!: TextStylePatch = TextStylePatch(), selected!: Bool = false): Unit {
        check()
        let style = if (selected) { this.selected } else { normal }
        var cx = x; var cy = y
        let right = signedAdd(clipping.x,clipping.width); let bottom = signedAdd(clipping.y,clipping.height)
        for (span in richTextClusters(text)) {
            if (span.text == "\n" || span.text == "\r\n") { cx = x; cy = signedAdd(cy,1); continue }
            let width = displayWidth(span.text)
            if (width > 0 && cy >= clipping.y && cy < bottom && cx >= clipping.x && cx < right && width <= right - cx) {
                let resolved = style.explicit.resolve(patch.resolve(span.style.resolve(style.style)))
                frame.put(signedAdd(originX,cx),signedAdd(originY,cy),span.text,style:resolved)
            }
            if (width > 0) { cx = signedAdd(cx,width) }
        }
    }
    public func fill(rect: Rect, patch!: TextStylePatch = TextStylePatch(), selected!: Bool = false): Unit {
        check()
        let style = if (selected) { this.selected } else { normal }
        let fillStyle = style.explicit.resolve(patch.resolve(style.style))
        frame.fillClipped(Rect(signedAdd(originX,rect.x),signedAdd(originY,rect.y),rect.width,rect.height),fillStyle,
            signedAdd(originX,clipping.x),signedAdd(originY,clipping.y),
            signedAdd(originX,signedAdd(clipping.x,clipping.width)),signedAdd(originY,signedAdd(clipping.y,clipping.height)))
    }
    public func caret(x: Int64, y: Int64, visible!: Bool = true): Unit {
        check()
        if (!session.trackCaret || !focusedValue) { return }
        session.pendingCaret = None
        let right = signedAdd(clipping.x,clipping.width); let bottom = signedAdd(clipping.y,clipping.height)
        if (visible && x >= clipping.x && x < right && y >= clipping.y && y < bottom) {
            session.pendingCaret = Some(CaretRequest(node.reference(),signedAdd(originX,x),signedAdd(originY,y)))
        }
    }
}
