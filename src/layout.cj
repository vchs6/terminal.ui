package cjtui

import std.collection.ArrayList
import std.collection.HashMap

func sat(a: Int64, b: Int64): Int64 {
    if (a > Int64.Max - b) {
        Int64.Max
    } else {
        a + b
    }
}

func lesser(a: Int64, b: Int64): Int64 {
    if (a < b) {
        a
    } else {
        b
    }
}

func greater(a: Int64, b: Int64): Int64 {
    if (a > b) {
        a
    } else {
        b
    }
}

func offset(a: Alignment, free: Int64): Int64 {
    if (a == Alignment.End) {
        free
    } else if (a == Alignment.Center) {
        free / 2
    } else {
        0
    }
}

// Exact quotient and remainder for a*b/d, where 0 <= a <= d and b >= 0.
func mulDiv(a: Int64, b: Int64, d: Int64): (Int64, Int64) {
    if (a == d) {
        return (b, 0)
    }
    var q: Int64 = 0
    var r: Int64 = 0
    var bit: Int64 = 4611686018427387904
    while (bit > 0) {
        q *= 2
        if (r >= d - r) {
            r -= d - r
            q++
        } else {
            r += r
        }
        if ((b / bit) % 2 == 1) {
            if (r >= d - a) {
                r -= d - a
                q++
            } else {
                r += a
            }
        }
        bit /= 2
    }
    (q, r)
}

func paint(n: LayoutNode, frame: Frame): Unit {
    n.session.recordPaint()
    let c = n.component
    let r = n.resolved
    let style = r.style
    let x = n.screenX; let y = n.screenY; let w = n.boxWidth; let h = n.boxHeight
    let clipL = n.paintLeft; let clipT = n.paintTop; let clipR = n.paintRight; let clipB = n.paintBottom
    let ix = n.paintContentX; let iy = n.paintContentY
    let contentW = n.paintContentWidth; let contentH = n.paintContentHeight
    let boxX = n.paintBoxX; let boxY = n.paintBoxY
    let ir = n.paintInnerRight; let ib = n.paintInnerBottom
    let rect = Rect(x, y, w, h)
    if (r.shadowEnabled) {
        frame.shadowClipped(rect, r.shadowX, r.shadowY, r.shadowStyle, clipL, clipT, clipR, clipB)
    }
    if (r.fill != 0) {
        frame.fillClipped(rect, r.fillStyle, clipL, clipT, clipR, clipB)
    }
    let borderStyle = Style(foreground: r.borderFg, background: style.background, bold: style.bold,
        dim: style.dim, italic: style.italic, underline: style.underline, inverse: style.inverse,
        strikethrough: style.strikethrough)
    frame.borderClipped(rect, r.borderStyle, borderStyle, clipL, clipT, clipR, clipB)
    if (c.kind == 3) {
        let left = greater(0,signedSubtract(greater(clipL,boxX),ix))
        let top = greater(0,signedSubtract(greater(clipT,boxY),iy))
        let endX = greater(left,lesser(contentW,signedSubtract(ir,ix))); let endY = greater(top,lesser(contentH,signedSubtract(ib,iy)))
        let selected = resolveStyle(c,n.session.theme,n.inheritedStyle,n.rootNode,selected:true)
        let context = PaintContext(n.session,c.readMount().getOrThrow(),frame,ix,iy,Size(contentW,contentH),
            Rect(left,top,endX-left,endY-top),r,selected)
        try { c.canvasBinding("canvas-draw").track({=> c.canvas.getOrThrow().draw(context) }) }
        finally { context.expire() }
        return
    }
    if (c.kind == 0) {
        let clusters = richTextClusters(c.value)
        for (i in 0..n.lines.size) {
            let cy = sat(iy,i)
            let clipped = r.overflow == TextOverflow.Ellipsis && n.widths[i] > contentW && contentW > 0
            let marker = if (clipped) { generatedEllipsis(n.session.layoutGlyphPolicy,contentW,ambiguousWide:false) } else { "" }
            let markerWidth = displayWidth(marker)
            let budget = contentW - markerWidth
            let free = if (n.widths[i] < contentW) { contentW - n.widths[i] } else { 0 }
            var cx = sat(ix,offset(r.textAlignment,free))
            var used: Int64 = 0
            var markerStyle = style
            for (index in n.lines[i]) {
                let span = clusters[index]
                let gw = displayWidth(span.text)
                let textStyle = r.explicit.resolve(span.style.resolve(style))
                if (clipped && gw > 0 && (used > budget || gw > budget - used)) {
                    markerStyle = textStyle
                    break
                }
                if (cy >= greater(clipT,boxY) && cy < ib && cx >= greater(clipL,boxX) && cx < ir && gw <= ir - cx) {
                    frame.put(cx,cy,span.text,style:textStyle)
                }
                cx = sat(cx,gw); used = sat(used,gw)
            }
            if (clipped && cy >= greater(clipT,boxY) && cy < ib) {
                var mx = sat(ix,contentW - markerWidth)
                for (g in graphemeClusters(marker)) {
                    let mw = displayWidth(g)
                    if (mx >= greater(clipL,boxX) && mx < ir && mw <= ir - mx) { frame.put(mx,cy,g,style:markerStyle) }
                    mx = sat(mx,mw)
                }
            }
        }
        return
    }
    for (child in n.children()) { paint(child, frame) }
}

// Arrange geometry once for paint and side-effect-free preflight.
func arrange(n: LayoutNode, x: Int64, y: Int64, w: Int64, h: Int64, clipL: Int64, clipT: Int64,
    clipR: Int64, clipB: Int64, geometry!: ?HashMap<Int64, LayoutNode> = None): Unit {
    let c = n.component
    let r = n.resolved
    let right = lesser(clipR, sat(x, w));
    let bottom = lesser(clipB, sat(y, h))
    let borderInset: Int64 = if (r.borderStyle == BorderStyle.None) { 0 } else { 1 }
    let leftPad = lesser(sat(r.padLeft,borderInset), w)
    let topPad = lesser(sat(r.padTop,borderInset), h)
    let innerW = w - leftPad - lesser(sat(r.padRight,borderInset), w - leftPad)
    let innerH = h - topPad - lesser(sat(r.padBottom,borderInset), h - topPad)
    let boxX = sat(x, leftPad); let boxY = sat(y, topPad)
    let ir = lesser(right, sat(boxX, innerW)); let ib = lesser(bottom, sat(boxY, innerH))
    let runtimeNode = c.readMount().getOrThrow()
    let viewport = n.session.viewportAxes(runtimeNode)
    let axes = viewport ?? ScrollAxes.Off
    let implicitRoot = runtimeNode.parent.isNone() && !n.session.temporary && !c.viewportDeclared
    let virtualY = axes.vertical() && (!implicitRoot || n.rootFallback)
    n.constrainCanvasFinal(innerW,innerH,axes)
    let naturalContentW = greater(0,n.naturalW - lesser(n.naturalW,n.horizontalInsets()))
    let neededH = n.scrollingHeight()
    let naturalContentH = greater(0,neededH - lesser(neededH,n.verticalInsets()))
    // A zero-width viewport cannot constrain away the logical content used by
    // pending visibility requests; it still clips all painting at the box.
    let zeroViewportWidth = if (innerW == 0) { viewport.isSome() } else { false }
    let contentW = if (axes.horizontal() || zeroViewportWidth) { greater(innerW,naturalContentW) } else { innerW }
    let contentH = if (virtualY) { greater(innerH,naturalContentH) } else { innerH }
    let state = runtimeNode.viewportState
    if (n.previewTheme.isNone() && n.commitGeometry && viewport.isSome()) {
        if (state.width != innerW || state.height != innerH) {
            if (let Some(caret) <- n.session.lastCaret) {
                if (n.session.viewportContains(runtimeNode,caret.owner)) { n.session.focusedViewportResized = true }
            }
        }
        state.update(innerW,innerH,contentW,contentH,axes)
    }
    let scrollX = if (axes.horizontal()) { state.offsetX } else { 0 }
    let scrollY = if (axes.vertical()) { state.offsetY } else { 0 }
    let ix = signedAdd(boxX,-scrollX); let iy = signedAdd(boxY,-scrollY)
    n.screenX = x; n.screenY = y
    n.clipLeft = greater(clipL,x); n.clipTop = greater(clipT,y)
    n.clipRight = right; n.clipBottom = bottom
    n.boxWidth = w; n.boxHeight = h; n.contentX = leftPad; n.contentY = topPad
    n.contentWidth = if (viewport.isSome()) { innerW } else { contentW }
    n.contentHeight = if (viewport.isSome()) { innerH } else { contentH }
    if (let Some(map) <- geometry) { map[runtimeNode.id] = n }
    if (n.previewTheme.isNone() && n.commitGeometry) {
        runtimeNode.screenX = x; runtimeNode.screenY = y
        runtimeNode.clipLeft = greater(clipL,x); runtimeNode.clipTop = greater(clipT,y)
        runtimeNode.clipRight = right; runtimeNode.clipBottom = bottom
        runtimeNode.layoutWidth = w; runtimeNode.layoutHeight = h
        runtimeNode.contentX = leftPad; runtimeNode.contentY = topPad
        runtimeNode.logicalWidth = contentW; runtimeNode.logicalHeight = contentH
    }
    n.paintLeft = clipL; n.paintTop = clipT; n.paintRight = clipR; n.paintBottom = clipB
    n.paintContentX = ix; n.paintContentY = iy; n.paintContentWidth = contentW; n.paintContentHeight = contentH
    n.paintBoxX = boxX; n.paintBoxY = boxY; n.paintInnerRight = ir; n.paintInnerBottom = ib
    if (c.kind == 0 || c.kind == 3) { return }
    let mainSize = if (c.kind == 2) { contentW } else { contentH }
    let cross = if (c.kind == 2) { contentH } else { contentW }
    let children = n.children()
    let count = children.size
    let naturalBasis = if (c.kind == 2) { axes.horizontal() } else { virtualY }
    let (sizes,free) = n.mainAllocation(mainSize,naturalBasis)
    var cursor = offset(r.justify, free)
    for (i in 0..count) {
        let child = children[i];
        let cc = child.resolved
        let fixed = if (c.kind == 2) {
            cc.fixedH
        } else {
            cc.fixedW
        }
        let minimum = if (c.kind == 2) {
            cc.minH
        } else {
            cc.minW
        }
        let natural = if (c.kind == 2) {
            child.naturalH
        } else {
            child.naturalW
        }
        var crossSize = lesser(cross, greater(fixed ?? natural, minimum))
        if (r.align == Alignment.Stretch && fixed == Option<Int64>.None) {
            crossSize = cross
        }
        let crossOffset = offset(r.align, cross - crossSize)
        let cx = if (c.kind == 2) {
            sat(ix, cursor)
        } else {
            sat(ix, crossOffset)
        }
        let cy = if (c.kind == 2) {
            sat(iy, crossOffset)
        } else {
            sat(iy, cursor)
        }
        let cw = if (c.kind == 2) {
            sizes[i]
        } else {
            crossSize
        }
        let ch = if (c.kind == 2) {
            crossSize
        } else {
            sizes[i]
        }
        if (n.previewTheme.isNone() && n.commitGeometry) {
            let childNode = child.component.readMount().getOrThrow()
            childNode.layoutX = if (c.kind == 2) { cursor } else { crossOffset }
            childNode.layoutY = if (c.kind == 2) { crossOffset } else { cursor }
        }
        arrange(child, cx, cy, cw, ch, greater(clipL, boxX), greater(clipT, boxY), ir, ib, geometry:geometry)
        cursor = sat(cursor, sizes[i])
        if (i + 1 < count) {
            cursor = sat(cursor, r.spacing)
        }
    }
}

// First finite pass summary, following the existing allocator and same node tree.
func summarizeVerticalOverflow(n: LayoutNode, width: Int64, height: Int64, result: VerticalOverflowSummary): Unit {
    n.assignedWidth = width; n.assignedHeight = height
    if (n.component.kind == 0 || n.component.kind == 3) {
        if (n.naturalH > height) {
            result.record(n.component.readMount().getOrThrow(),if (n.component.kind == 0) { "content-or-wrap" } else { "content" })
        }
        return
    }
    let b: Int64 = if (n.resolved.borderStyle == BorderStyle.None) { 0 } else { 1 }
    let left = lesser(width,sat(n.resolved.padLeft,b)); let top = lesser(height,sat(n.resolved.padTop,b))
    let iw = width-left-lesser(width-left,sat(n.resolved.padRight,b))
    let ih = height-top-lesser(height-top,sat(n.resolved.padBottom,b))
    let mainSize = if (n.component.kind == 2) { iw } else { ih }
    let cross = if (n.component.kind == 2) { ih } else { iw }
    let (sizes,_) = n.mainAllocation(mainSize,false)
    var cursor: Int64 = 0
    let children = n.children()
    for (i in 0..children.size) {
        let child = children[i]; let cr = child.resolved
        let fixed = if (n.component.kind == 2) { cr.fixedH } else { cr.fixedW }
        let minimum = if (n.component.kind == 2) { cr.minH } else { cr.minW }
        let natural = if (n.component.kind == 2) { child.naturalH } else { child.naturalW }
        var crossSize = lesser(cross,greater(fixed ?? natural,minimum))
        if (n.resolved.align == Alignment.Stretch && fixed.isNone()) { crossSize = cross }
        let cw = if (n.component.kind == 2) { sizes[i] } else { crossSize }
        let ch = if (n.component.kind == 2) { crossSize } else { sizes[i] }
        child.assignedWidth = cw; child.assignedHeight = ch
        let declaredHeight = match (cr.fixedH) { case Some(fixedHeight) => greater(fixedHeight,cr.minH); case None => ch }
        if (n.component.kind == 1 && (cursor > ih || declaredHeight > ih - cursor)) {
            result.record(child.component.readMount().getOrThrow(),"descendant")
        }
        let barrier = cr.fixedH.isSome() || (child.component.viewportDeclared && child.component.viewportAxes.vertical())
        if (!barrier) { summarizeVerticalOverflow(child,cw,ch,result) }
        cursor = sat(cursor,sizes[i])
        if (i + 1 < children.size) { cursor = sat(cursor,n.resolved.spacing) }
    }
}

// Uses the same measurement, constrained-width and recursive allocation path
// as painting, with candidate-resolved cached declarations and no frame writes.
func validateCandidateLayout(session: RuntimeSession, theme: Theme): Unit {
    let width = session.validationWidth
    let height = session.validationHeight
    if (width < 0 || height < 0 || !session.root.isVisible) { return }
    let node = LayoutNode(session.root,session,themeSeed(theme),isRoot:true,previewTheme:Some(theme),
        previousMeasurement: session.measuredLayout)
    node.measure()
    let w = lesser(width,greater(node.resolved.fixedW ?? width,node.resolved.minW))
    let h = lesser(height,greater(node.resolved.fixedH ?? height,node.resolved.minH))
    node.constrain(w)
    if (!session.root.viewportDeclared && node.resolved.fixedH.isNone()) {
        let summary = VerticalOverflowSummary()
        summarizeVerticalOverflow(node,w,h,summary)
        node.rootFallback = summary.present
    }
    let geometry = HashMap<Int64, LayoutNode>()
    arrange(node,0,0,w,h,0,0,width,height,geometry:Some(geometry))
    for (record in session.overlayRecords) {
        if (let Some(layer) <- overlayGeometry(session,record,width,height,false,geometry,preview:Some(theme))) {
            arrange(layer.node,layer.x,layer.y,layer.width,layer.height,
                layer.left,layer.top,layer.right,layer.bottom,geometry:Some(geometry))
        }
    }
}

func overlayInherited(owner: RuntimeNode, theme: Theme): Style {
    let chain = ArrayList<RuntimeNode>()
    var cursor: ?RuntimeNode = Some(owner)
    while (let Some(node) <- cursor) { chain.add(node); cursor = node.parent }
    var style = themeSeed(theme); var i = chain.size
    while (i > 0) {
        i--; let node = chain[i]
        style = resolveStyle(node.component,theme,style,node.parent.isNone()).style
    }
    style
}

func overlayGeometry(session: RuntimeSession, record: OverlayRecord, width: Int64, height: Int64, commit: Bool,
    geometry: HashMap<Int64, LayoutNode>, preview!: ?Theme = None, deferClose!: Bool = false): ?OverlayLayout {
    if (record.terminal.isSome() || !record.owner.isValid()) { return None }
    let rootRef = record.root
    if (rootRef.isNone() || !rootRef.getOrThrow().isValid()) { return None }
    let owner = record.owner.resolve()
    if (!session.focusManager.effective(rootRef.getOrThrow().resolve(),false)) { return None }
    var left: Int64 = 0; var top: Int64 = 0; var right = width; var bottom = height
    if (let Some(hostRef) <- record.options.host) {
        if (!hostRef.isValid()) { return None }
        let host = hostRef.resolve()
        // The application root is the built-in host over the actual frame,
        // regardless of its own ordinary layout box.
        if (host.parent.isSome()) {
            let hostGeometry = geometry.get(host.id)
            if (hostGeometry.isNone()) { return None }
            let g = hostGeometry.getOrThrow()
            let hx = signedAdd(g.screenX,g.contentX); let hy = signedAdd(g.screenY,g.contentY)
            left = greater(g.clipLeft,hx); top = greater(g.clipTop,hy)
            right = lesser(g.clipRight,signedAdd(hx,g.contentWidth)); bottom = lesser(g.clipBottom,signedAdd(hy,g.contentHeight))
        }
    }
    right = greater(left,right); bottom = greater(top,bottom)
    let node = LayoutNode(rootRef.getOrThrow().resolve().component,session,overlayInherited(owner,preview ?? session.theme),
        previewTheme:preview,commitGeometry:commit)
    node.measure()
    let w = lesser(right-left,greater(node.resolved.fixedW ?? node.naturalW,node.resolved.minW))
    node.constrain(w)
    let h = lesser(bottom-top,greater(node.resolved.fixedH ?? node.naturalH,node.resolved.minH))
    var x = signedAdd(left,(right-left-w)/2); var y = signedAdd(top,(bottom-top-h)/2)
    if (let Some(anchorRef) <- record.options.anchor) {
        if (!anchorRef.isValid()) {
            if (commit && !deferClose) { session.closeOverlayTree(record,OverlayCloseReason.AnchorGone,true) }
            return None
        }
        let anchor = anchorRef.resolve()
        let anchorGeometry = geometry.get(anchor.id)
        if (anchorGeometry.isNone()) { return None }
        let g = anchorGeometry.getOrThrow()
        let ax = greater(left,greater(g.screenX,g.clipLeft))
        let ay = greater(top,greater(g.screenY,g.clipTop))
        let ar = lesser(right,lesser(signedAdd(g.screenX,g.boxWidth),g.clipRight))
        let ab = lesser(bottom,lesser(signedAdd(g.screenY,g.boxHeight),g.clipBottom))
        var anchorGone = ar <= ax || ab <= ay
        if (!anchorGone) { anchorGone = !session.focusManager.effective(anchor,false) }
        if (anchorGone) {
            if (commit && !deferClose) { session.closeOverlayTree(record,OverlayCloseReason.AnchorGone,true) }
            return None
        }
        match (record.options.placement) {
            case OverlayPlacement.BelowStart =>
                x = ax; let below = bottom-ab; let above = ay-top
                y = if (below >= h || below >= above) { ab } else { ay-h }
            case OverlayPlacement.AboveStart =>
                x = ax; let above = ay-top; let below = bottom-ab
                y = if (above >= h || above >= below) { ay-h } else { ab }
            case OverlayPlacement.RightStart =>
                y = ay; let rightSpace = right-ar; let leftSpace = ax-left
                x = if (rightSpace >= w || rightSpace >= leftSpace) { ar } else { ax-w }
            case OverlayPlacement.LeftStart =>
                y = ay; let leftSpace = ax-left; let rightSpace = right-ar
                x = if (leftSpace >= w || leftSpace >= rightSpace) { ax-w } else { ar }
            case OverlayPlacement.Center => ()
        }
    }
    x = lesser(greater(left,x),greater(left,right-w)); y = lesser(greater(top,y),greater(top,bottom-h))
    Some(OverlayLayout(node,x,y,w,h,left,top,right,bottom))
}

func renderLayout(root: Component, width: Int64, height: Int64, session: RuntimeSession, reuse!: Bool = true): Frame {
    let frame = Frame(width, height)
    if (!root.isVisible) { return frame }
    // Public render may target a mounted subtree in the same session.
    // Only the application root owns this reusable measurement.
    let sessionRoot = reuse && root.descriptionId == session.root.descriptionId
    let node = if (sessionRoot && session.measuredLayout.isSome()) {
        session.measuredLayout.getOrThrow()
    } else {
        let measured = LayoutNode(root, session, themeSeed(session.theme), isRoot: true, commitGeometry: reuse)
        measured.measure()
        if (sessionRoot) { session.measuredLayout = Some(measured) }
        measured
    }

    node.refresh(themeSeed(session.theme), true)
    let w = lesser(width, greater(node.resolved.fixedW ?? width, node.resolved.minW))
    let h = lesser(height, greater(node.resolved.fixedH ?? height, node.resolved.minH))
    node.constrain(w)
    let implicitRoot = sessionRoot && !session.temporary && !root.viewportDeclared
    // Mounted M1 render is also a root consumer even when caching is disabled.
    let mountedRoot = !session.temporary && root.descriptionId == session.root.descriptionId
    if ((implicitRoot || mountedRoot) && !root.viewportDeclared && node.resolved.fixedH.isNone()) {
        let summary = VerticalOverflowSummary()
        summarizeVerticalOverflow(node,w,h,summary)
        node.rootFallback = summary.present
    } else { node.rootFallback = false }
    // Resolve current finite geometry before consuming deferred ensure intents.
    if (reuse) { session.focusedViewportResized = false }
    let geometry = HashMap<Int64, LayoutNode>()
    arrange(node,0,0,w,h,0,0,width,height,geometry:Some(geometry))
    let layers = ArrayList<OverlayLayout>()
    if (mountedRoot) {
        for (record in session.overlayRecords) {
            if (let Some(layer) <- overlayGeometry(session,record,width,height,reuse,geometry,deferClose:reuse)) {
                arrange(layer.node,layer.x,layer.y,layer.width,layer.height,
                    layer.left,layer.top,layer.right,layer.bottom,geometry:Some(geometry))
                layers.add(layer)
            }
        }
    }
    if (reuse) {
        if (session.focusedViewportResized) {
            if (let Some(previousCaret) <- session.lastCaret) {
                var hasExplicit = false
                for (command in session.pendingEnsures) {
                    if (command.target.sameNode(previousCaret.owner)) { hasExplicit = true }
                }
                if (!hasExplicit && previousCaret.owner.isValid()) {
                    let ensure = ScrollCommand(previousCaret.owner,1,0,0,
                        Some(Rect(previousCaret.localX,previousCaret.localY,1,1)),ScrollAlign.Nearest,ScrollAlign.Nearest)
                    ensure.order = session.nextViewportIntent(); session.pendingEnsures.add(ensure)
                }
            }
        }
        applyPendingViewportEnsures(session)
        // Ensures can scroll the anchor or host; derive the painted layers
        // from the resulting geometry in the same frame.
        geometry.clear(); layers.clear()
        arrange(node,0,0,w,h,0,0,width,height,geometry:Some(geometry))
        if (mountedRoot) {
            for (record in session.overlayRecords) {
                if (let Some(layer) <- overlayGeometry(session,record,width,height,true,geometry)) {
                    arrange(layer.node,layer.x,layer.y,layer.width,layer.height,
                        layer.left,layer.top,layer.right,layer.bottom,geometry:Some(geometry))
                    layers.add(layer)
                }
            }
        }
    }
    paint(node, frame)
    for (layer in layers) {
        let overlay = Frame(width,height,transparent:true)
        let previousCaret = session.pendingCaret
        paint(layer.node,overlay)
        if (let Some(previous) <- previousCaret) {
            if (let Some(current) <- session.pendingCaret) {
                if (refEq(previous,current) && previous.x >= 0 && previous.y >= 0 && previous.x < width && previous.y < height) {
                    if (!overlay.cellAt(previous.x,previous.y).isTransparent) { session.pendingCaret = None }
                }
            }
        }
        frame.composite(overlay)
    }
    frame
}

public func render(root: Component, width: Int64, height: Int64, glyphMode!: GlyphMode = GlyphMode.Unicode): Frame {
    if (let Some(node) <- root.readMount()) {
        let session = node.session
        session.requireBoundary()
        if (session.isStopping()) {
            session.closeStopped()
            throw UIException("SessionInactive", "session stopped")
        }
        let turnCutoff = session.cutoff()
        try {
            let frame = session.enter({ =>
                session.stabilize(turnCutoff)
                // Only an application-root render updates the viewport used
                // to validate a global theme candidate. Subtree export sizes
                // belong to that export, not to the application root.
                if (root.descriptionId == session.root.descriptionId) {
                    session.validationWidth = width; session.validationHeight = height
                }
                session.applyPendingTheme()
                session.selectLayoutGlyphPolicy(offlineGlyphPolicy(glyphMode))
                let result = renderLayout(root, width, height, session, reuse:false)
                session.recordFrame()
                result
            })
            if (session.isStopping()) { session.closeStopped() }
            return frame
        } catch (error: Exception) { throw session.closeFailure(error) }
    }
    let session = RuntimeSession(root, RuntimeLimits(), temporary: true)
    try {
        session.start()
        return session.produce(width, height, true, glyphPolicy: offlineGlyphPolicy(glyphMode))
    } finally { session.close() }
}
