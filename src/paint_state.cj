package cjtui

// Immutable facts from a successful logical composition, retained even when a
// component is subsequently removed or its layout object is replaced.
class PaintState {
    let id: Int64
    let left: Int64
    let top: Int64
    let right: Int64
    let bottom: Int64
    let contentX: Int64
    let contentY: Int64
    let contentWidth: Int64
    let contentHeight: Int64
    let x: Int64
    let y: Int64
    let width: Int64
    let height: Int64
    let clipLeft: Int64
    let clipTop: Int64
    let clipRight: Int64
    let clipBottom: Int64
    let changed: Bool
    let focused: Bool
    let enabled: Bool
    let resolved: ResolvedStyle
    let selected: ResolvedStyle
    init(n: LayoutNode) {
        id = n.component.readMount().getOrThrow().id
        let runtime = n.component.readMount().getOrThrow()
        focused = if (let Some(node) <- n.session.focusManager.focused) { n.component.kind == 3 && node.id == id } else { false }
        enabled = if (n.component.kind == 3) { n.session.focusManager.effective(runtime, true) } else { true }
        resolved = n.resolved
        selected = if (n.component.kind == 3) {
            resolveStyle(n.component,n.session.theme,n.inheritedStyle,n.rootNode,selected:true)
        } else { n.resolved }
        changed = runtime.contentDirty || (runtime.styleDirty && (n.component.kind == 0 || n.component.kind == 3))
        x = n.screenX; y = n.screenY; width = n.boxWidth; height = n.boxHeight
        clipLeft = n.paintLeft; clipTop = n.paintTop; clipRight = n.paintRight; clipBottom = n.paintBottom
        let shadowTop = if (n.resolved.shadowEnabled) { signedAdd(n.screenY, n.resolved.shadowY) } else { n.screenY }
        let shadowLeft = if (n.resolved.shadowEnabled) { signedAdd(n.screenX, n.resolved.shadowX) } else { n.screenX }
        left = greater(n.paintLeft, lesser(n.screenX, shadowLeft))
        top = greater(n.paintTop, lesser(n.screenY, shadowTop))
        right = lesser(n.paintRight, greater(signedAdd(n.screenX, n.boxWidth), signedAdd(shadowLeft, n.boxWidth)))
        bottom = lesser(n.paintBottom, greater(signedAdd(n.screenY, n.boxHeight), signedAdd(shadowTop, n.boxHeight)))
        contentX = n.paintContentX; contentY = n.paintContentY
        contentWidth = n.paintContentWidth; contentHeight = n.paintContentHeight
    }
    func sameGeometry(other: PaintState): Bool {
        let sameNormal = samePaintStyle(resolved, other.resolved)
        let sameSelected = samePaintStyle(selected, other.selected)
        focused == other.focused && enabled == other.enabled && sameNormal &&
            sameSelected && left == other.left && top == other.top && right == other.right && bottom == other.bottom &&
            x == other.x && y == other.y && width == other.width && height == other.height &&
            clipLeft == other.clipLeft && clipTop == other.clipTop && clipRight == other.clipRight && clipBottom == other.clipBottom &&
            contentX == other.contentX && contentY == other.contentY &&
            contentWidth == other.contentWidth && contentHeight == other.contentHeight
    }
}

func samePaintStyle(a: ResolvedStyle, b: ResolvedStyle): Bool {
    !layoutStyleDiff(a, b) && a.style == b.style && a.explicit == b.explicit &&
        a.fill == b.fill && a.fillStyle == b.fillStyle && a.textAlignment == b.textAlignment &&
        a.overflow == b.overflow && a.borderStyle == b.borderStyle && a.borderFg == b.borderFg &&
        a.shadowEnabled == b.shadowEnabled && a.shadowX == b.shadowX && a.shadowY == b.shadowY &&
        a.shadowStyle == b.shadowStyle
}
