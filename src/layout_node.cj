package cjtui

import std.collection.ArrayList

class LayoutNode {
    let session: RuntimeSession
    let component: Component
    let previewTheme: ?Theme
    var inheritedStyle: Style
    let rootNode: Bool
    var resolved: ResolvedStyle
    let children = ArrayList<LayoutNode>()
    // Indices retain the original grapheme identity across soft and hard lines.
    let lines = ArrayList<ArrayList<Int64>>()
    let widths = ArrayList<Int64>()
    var naturalW: Int64 = 0
    var naturalH: Int64 = 0
    var constrainedWidth: ?Int64 = None
    init(c: Component, session: RuntimeSession, inherited: Style, isRoot!: Bool = false, previewTheme!: ?Theme = None) {
        this.session = session
        component = c
        this.previewTheme = previewTheme
        inheritedStyle = inherited; rootNode = isRoot
        resolved = resolveStyle(c,previewTheme ?? session.theme,inherited,isRoot)
    }
    func measure(): Unit {
        if (previewTheme.isNone()) { session.recordMeasure() }
        let c = component
        if (c.kind == 3) {
            let canvas = c.canvas.getOrThrow()
            if (previewTheme.isNone()) {
                let limits = Constraints()
                c.canvasBinding("canvas-measure").trackNatural({=> canvas.measured = limits.constrain(canvas.measure(limits)) })
            }
            naturalW = canvas.measured.width; naturalH = canvas.measured.height
        } else if (c.kind == 0) {
            buildLines(0,false)
            for (width in widths) { naturalW = greater(naturalW,width) }
            naturalH = lines.size
        } else {
            for (entry in c.readMount().getOrThrow().sequence) {
                if (let ChildEntry.MountedChild(runtimeChild) <- entry) {
                    let child = runtimeChild.component
                    if (!child.isVisible) { continue }
                    let n = LayoutNode(child, session, resolved.style, previewTheme: previewTheme)
                    n.measure(); children.add(n)
                    let cw = greater(n.resolved.fixedW ?? n.naturalW, n.resolved.minW)
                    let ch = greater(n.resolved.fixedH ?? n.naturalH, n.resolved.minH)
                    if (c.kind == 1) { naturalW = greater(naturalW,cw); naturalH = sat(naturalH,ch) }
                    else { naturalW = sat(naturalW,cw); naturalH = greater(naturalH,ch) }
                }
            }
            if (c.kind == 1) { naturalH = addGaps(naturalH) } else { naturalW = addGaps(naturalW) }
        }
        naturalW = sat(naturalW,horizontalInsets())
        naturalH = sat(naturalH,verticalInsets())
    }
    func horizontalInsets(): Int64 {
        let b: Int64 = if (resolved.borderStyle == BorderStyle.None) { 0 } else { 1 }
        sat(sat(resolved.padLeft,b),sat(resolved.padRight,b))
    }
    func verticalInsets(): Int64 {
        let b: Int64 = if (resolved.borderStyle == BorderStyle.None) { 0 } else { 1 }
        sat(sat(resolved.padTop,b),sat(resolved.padBottom,b))
    }
    func innerWidth(width: Int64): Int64 {
        let b: Int64 = if (resolved.borderStyle == BorderStyle.None) { 0 } else { 1 }
        let left = lesser(width,sat(resolved.padLeft,b))
        width - left - lesser(width-left,sat(resolved.padRight,b))
    }
    func addGaps(base: Int64): Int64 {
        var result = base
        for (_ in 1..children.size) { result = sat(result,resolved.spacing) }
        result
    }
    func buildLines(width: Int64, wrap: Bool): Unit {
        lines.clear(); widths.clear()
        let clusters = richTextClusters(component.value)
        var line = ArrayList<Int64>()
        var used: Int64 = 0
        for (i in 0..clusters.size) {
            let g = clusters[i].text
            if (g == "\n" || g == "\r\n") {
                lines.add(line); widths.add(used); line = ArrayList<Int64>(); used = 0
            } else {
                let gw = displayWidth(g)
                if (wrap && width > 0 && gw > 0 && used > 0 && (used > width || gw > width - used)) {
                    lines.add(line); widths.add(used); line = ArrayList<Int64>(); used = 0
                }
                line.add(i); used = sat(used,gw)
            }
        }
        lines.add(line); widths.add(used)
    }
    // Recalculate only the natural heights affected by the allocated width.
    func constrain(width: Int64): Unit {
        if (constrainedWidth == Some(width)) { return }
        constrainedWidth = Some(width)
        if (previewTheme.isNone()) { session.recordMeasure() }
        let available = innerWidth(width)
        if (component.kind == 3) {
            let canvas = component.canvas.getOrThrow()
            if (previewTheme.isNone()) {
                let limits = Constraints(maxWidth:Some(available))
                component.canvasBinding("canvas-measure").trackConstrained({=> canvas.measured = limits.constrain(canvas.measure(limits)) })
            }
            naturalH = sat(canvas.measured.height,verticalInsets())
        } else if (component.kind == 0) {
            buildLines(available,resolved.wrap == TextWrap.Grapheme)
            naturalH = sat(lines.size,verticalInsets())
        } else if (component.kind == 1) {
            var height: Int64 = 0
            for (child in children) {
                let cr = child.resolved
                var cw = lesser(available,greater(cr.fixedW ?? child.naturalW,cr.minW))
                if (resolved.align == Alignment.Stretch && cr.fixedW.isNone()) { cw = available }
                child.constrain(cw)
                height = sat(height,greater(cr.fixedH ?? child.naturalH,cr.minH))
            }
            naturalH = sat(addGaps(height),verticalInsets())
        } else {
            let (widths,_) = allocateMain(this,available)
            var height: Int64 = 0
            for (i in 0..children.size) {
                let child = children[i]
                child.constrain(widths[i])
                height = greater(height,greater(child.resolved.fixedH ?? child.naturalH,child.resolved.minH))
            }
            naturalH = sat(height,verticalInsets())
        }
    }
    // Compare against the geometry that produced the cached measurement.
    func behaviorChangesLayout(inherited: Style, isRoot: Bool): Bool {
        let next = resolveStyle(component,session.theme,inherited,isRoot)
        if (layoutStyleDiff(resolved,next)) { return true }
        for (child in children) { if (child.behaviorChangesLayout(next.style,false)) { return true } }
        false
    }
    func refresh(inherited: Style, isRoot: Bool): Unit {
        inheritedStyle = inherited
        resolved = resolveStyle(component,session.theme,inherited,isRoot)
        for (child in children) { child.refresh(resolved.style,false) }
    }
}
