package cjtui

import std.collection.ArrayList

class LayoutNode {
    let session: RuntimeSession
    let component: Component
    let previewTheme: ?Theme
    let previousMeasurement: ?LayoutNode
    let commitGeometry: Bool
    var inheritedStyle: Style
    let rootNode: Bool
    var resolved: ResolvedStyle
    let children = ArrayList<LayoutNode>()
    // Indices retain the original grapheme identity across soft and hard lines.
    let lines = ArrayList<ArrayList<Int64>>()
    let widths = ArrayList<Int64>()
    var naturalW: Int64 = 0
    var naturalH: Int64 = 0
    var canvasNatural = Size(0,0)
    var canvasConstrained = Size(0,0)
    var constrainedWidth: ?Int64 = None
    var assignedWidth: Int64 = 0
    var assignedHeight: Int64 = -1
    var finalCanvasWidth: Int64 = -1
    var finalCanvasHeight: Int64 = -1
    var rootFallback = false
    var plannedMain: Int64 = -1
    var plannedNatural = false
    var plannedSizes = Array<Int64>()
    var plannedFree: Int64 = 0
    init(c: Component, session: RuntimeSession, inherited: Style, isRoot!: Bool = false, previewTheme!: ?Theme = None,
        previousMeasurement!: ?LayoutNode = None, commitGeometry!: Bool = true) {
        this.session = session
        component = c
        this.previewTheme = previewTheme
        this.previousMeasurement = previousMeasurement
        this.commitGeometry = commitGeometry
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
                canvasNatural = canvas.measured
                if (commitGeometry) { c.readMount().getOrThrow().canvasNatural = Some(canvasNatural) }
            } else if (let Some(previous) <- previousMeasurement) {
                canvasNatural = previous.canvasNatural
            } else {
                canvasNatural = c.readMount().getOrThrow().canvasNatural ?? canvas.measured
            }
            naturalW = canvasNatural.width; naturalH = canvasNatural.height
        } else if (c.kind == 0) {
            buildLines(0,false)
            for (width in widths) { naturalW = greater(naturalW,width) }
            naturalH = lines.size
        } else {
            for (entry in c.readMount().getOrThrow().sequence) {
                if (let ChildEntry.MountedChild(runtimeChild) <- entry) {
                    let child = runtimeChild.component
                    if (!child.isVisible) { continue }
                    var previousChild: ?LayoutNode = None
                    if (let Some(previous) <- previousMeasurement) {
                        for (entry in previous.children) {
                            if (entry.component.descriptionId == child.descriptionId) { previousChild = Some(entry); break }
                        }
                    }
                    let n = LayoutNode(child, session, resolved.style, previewTheme: previewTheme,
                        previousMeasurement: previousChild, commitGeometry: commitGeometry)
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
        constrainedWidth = Some(width); plannedMain = -1
        if (previewTheme.isNone()) { session.recordMeasure() }
        let available = innerWidth(width)
        if (component.kind == 3) {
            let canvas = component.canvas.getOrThrow()
            if (previewTheme.isNone()) {
                let axes = session.viewportAxes(component.readMount().getOrThrow()) ?? ScrollAxes.Off
                let limits = Constraints(maxWidth:if (axes.horizontal()) { Option<Int64>.None } else { Some(available) })
                component.canvasBinding("canvas-measure").trackConstrained({=> canvas.measured = limits.constrain(canvas.measure(limits)) })
                canvasConstrained = canvas.measured
                if (commitGeometry) { component.readMount().getOrThrow().canvasConstrained = Some(canvasConstrained) }
            } else if (let Some(previous) <- previousMeasurement) {
                canvasConstrained = previous.canvasConstrained
            } else {
                canvasConstrained = component.readMount().getOrThrow().canvasConstrained ?? canvas.measured
            }
            naturalH = sat(canvasConstrained.height,verticalInsets())
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
            let axes = session.viewportAxes(component.readMount().getOrThrow()) ?? ScrollAxes.Off
            let mainWidth = if (axes.horizontal()) { greater(available,naturalW-horizontalInsets()) } else { available }
            let (widths,_) = allocateMain(this,mainWidth,naturalBasis:axes.horizontal())
            var height: Int64 = 0
            for (i in 0..children.size) {
                let child = children[i]
                child.constrain(widths[i])
                height = greater(height,greater(child.resolved.fixedH ?? child.naturalH,child.resolved.minH))
            }
            naturalH = sat(height,verticalInsets())
        }
    }
    // Final finite allocation controls both axes of a Canvas measurement.
    func constrainCanvasFinal(width: Int64, height: Int64, axes: ScrollAxes): Unit {
        if (component.kind != 3 || previewTheme.isSome()) { return }
        if (finalCanvasWidth == width && finalCanvasHeight == height) { return }
        finalCanvasWidth = width; finalCanvasHeight = height
        let canvas = component.canvas.getOrThrow()
        let limits = Constraints(maxWidth:if (axes.horizontal()) { Option<Int64>.None } else { Some(width) },
            maxHeight:if (axes.vertical()) { Option<Int64>.None } else { Some(height) })
        component.canvasBinding("canvas-measure").trackConstrained({=> canvas.measured = limits.constrain(canvas.measure(limits)) })
        canvasConstrained = canvas.measured
        naturalH = sat(canvasConstrained.height,verticalInsets())
        if (commitGeometry) { component.readMount().getOrThrow().canvasConstrained = Some(canvasConstrained) }
    }
    // Reuse the same negotiated child sizes for paint after the finite pass.
    func mainAllocation(mainSize: Int64, naturalBasis: Bool): (Array<Int64>, Int64) {
        if (plannedMain == mainSize && plannedNatural == naturalBasis && plannedSizes.size == children.size) {
            return (plannedSizes,plannedFree)
        }
        let (sizes,free) = allocateMain(this,mainSize,naturalBasis:naturalBasis)
        plannedMain = mainSize; plannedNatural = naturalBasis; plannedSizes = sizes; plannedFree = free
        (sizes,free)
    }
    // Natural size for the scrolling axis, stopping at fixed-size or nested
    // vertical viewport boundaries while retaining the same LayoutNode tree.
    func scrollBasisHeight(): Int64 {
        if (component.viewportDeclared && component.viewportAxes.vertical() && assignedHeight >= 0) { return assignedHeight }
        scrollingHeight()
    }
    func scrollingHeight(): Int64 {
        if (component.kind == 0 || component.kind == 3) { return naturalH }
        var content: Int64 = 0
        for (child in children) {
            let measured = if (let Some(fixed) <- child.resolved.fixedH) { fixed }
                else if (child.component.viewportDeclared && child.component.viewportAxes.vertical()) { child.assignedHeight }
                else { child.scrollingHeight() }
            let height = greater(measured,child.resolved.minH)
            if (component.kind == 1) { content = sat(content,height) } else { content = greater(content,height) }
        }
        if (component.kind == 1) { content = addGaps(content) }
        sat(content,verticalInsets())
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
