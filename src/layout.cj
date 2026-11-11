package cjtui

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

func paint(n: LayoutNode, frame: Frame, x: Int64, y: Int64, w: Int64, h: Int64, clipL: Int64, clipT: Int64,
    clipR: Int64, clipB: Int64): Unit {
    n.session.recordPaint()
    let c = n.component
    let r = n.resolved
    let style = r.style
    let right = lesser(clipR, sat(x, w));
    let bottom = lesser(clipB, sat(y, h))
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
    let borderInset: Int64 = if (r.borderStyle == BorderStyle.None) { 0 } else { 1 }
    let leftPad = lesser(sat(r.padLeft,borderInset), w)
    let topPad = lesser(sat(r.padTop,borderInset), h)
    let innerW = w - leftPad - lesser(sat(r.padRight,borderInset), w - leftPad)
    let innerH = h - topPad - lesser(sat(r.padBottom,borderInset), h - topPad)
    let ix = sat(x, leftPad);
    let iy = sat(y, topPad)
    let ir = lesser(right, sat(ix, innerW));
    let ib = lesser(bottom, sat(iy, innerH))
    if (c.kind == 0) {
        let clusters = richTextClusters(c.value)
        for (i in 0..n.lines.size) {
            let cy = sat(iy,i)
            let clipped = r.overflow == TextOverflow.Ellipsis && n.widths[i] > innerW && innerW > 0
            let marker = if (clipped) { generatedEllipsis(n.session.layoutGlyphPolicy,innerW,ambiguousWide:false) } else { "" }
            let markerWidth = displayWidth(marker)
            let budget = innerW - markerWidth
            let free = if (n.widths[i] < innerW) { innerW - n.widths[i] } else { 0 }
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
                if (cy >= clipT && cy < ib && cx >= clipL && cx < ir && gw <= ir - cx) {
                    frame.put(cx,cy,span.text,style:textStyle)
                }
                cx = sat(cx,gw); used = sat(used,gw)
            }
            if (clipped && cy >= clipT && cy < ib) {
                var mx = sat(ix,innerW - markerWidth)
                for (g in graphemeClusters(marker)) {
                    let mw = displayWidth(g)
                    if (mx >= clipL && mx < ir && mw <= ir - mx) { frame.put(mx,cy,g,style:markerStyle) }
                    mx = sat(mx,mw)
                }
            }
        }
        return
    }
    let mainSize = if (c.kind == 2) {
        innerW
    } else {
        innerH
    }
    let cross = if (c.kind == 2) {
        innerH
    } else {
        innerW
    }
    let count = n.children.size
    let (sizes,free) = allocateMain(n,mainSize)
    var cursor = offset(r.justify, free)
    for (i in 0..count) {
        let child = n.children[i];
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
        paint(child, frame, cx, cy, cw, ch, greater(clipL, ix), greater(clipT, iy), ir, ib)
        cursor = sat(cursor, sizes[i])
        if (i + 1 < count) {
            cursor = sat(cursor, r.spacing)
        }
    }
}

func renderLayout(root: Component, width: Int64, height: Int64, session: RuntimeSession): Frame {
    let frame = Frame(width, height)
    if (!root.isVisible) { return frame }
    // Public render may target a mounted subtree in the same session.
    // Only the application root owns this reusable measurement.
    let sessionRoot = root.descriptionId == session.root.descriptionId
    let node = if (sessionRoot && session.measuredLayout.isSome()) {
        session.measuredLayout.getOrThrow()
    } else {
        let measured = LayoutNode(root, session, themeSeed(session.theme), isRoot: true)
        measured.measure()
        if (sessionRoot) { session.measuredLayout = Some(measured) }
        measured
    }

    node.refresh(themeSeed(session.theme), true)
    let w = lesser(width, greater(node.resolved.fixedW ?? width, node.resolved.minW))
    let h = lesser(height, greater(node.resolved.fixedH ?? height, node.resolved.minH))
    node.constrain(w)
    paint(node, frame, 0, 0, w, h, 0, 0, width, height)
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
                session.applyPendingTheme()
                session.selectLayoutGlyphPolicy(offlineGlyphPolicy(glyphMode))
                let result = renderLayout(root, width, height, session)
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
