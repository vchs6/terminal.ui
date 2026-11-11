package cjtui

import std.collection.ArrayList

class LayoutNode {
    let session: RuntimeSession
    let component: Component
    var resolved: ResolvedStyle
    let children = ArrayList<LayoutNode>()
    let lines = ArrayList<ArrayList<String>>()
    let widths = ArrayList<Int64>()
    var naturalW: Int64 = 0
    var naturalH: Int64 = 0
    init(c: Component, session: RuntimeSession, inherited: Style, isRoot!: Bool = false) {
        this.session = session
        component = c
        resolved = resolveStyle(c,session.theme,inherited,isRoot)
    }
    func measure(): Unit {
        session.recordMeasure()
        let c = component
        if (c.kind == 0) {
            var line = ArrayList<String>()
            var w: Int64 = 0
            for (span in richTextClusters(c.value)) {
                let g = span.text
                if (g == "\n" || g == "\r\n") {
                    lines.add(line);
                    widths.add(w);
                    naturalW = greater(naturalW, w)
                    line = ArrayList<String>()
                    w = 0
                } else {
                    line.add(g);
                    w = sat(w, displayWidth(g))
                }
            }
            lines.add(line);
            widths.add(w);
            naturalW = greater(naturalW, w)
            naturalH = lines.size
        } else {
            for (entry in c.readMount().getOrThrow().sequence) {
                if (let ChildEntry.MountedChild(runtimeChild) <- entry) {
                    let child = runtimeChild.component
                    if (!child.isVisible) {
                        continue
                    }
                    let n = LayoutNode(child, session, resolved.style);
                    n.measure();
                    children.add(n)
                    let cw = greater(n.resolved.fixedW ?? n.naturalW, n.resolved.minW)
                    let ch = greater(n.resolved.fixedH ?? n.naturalH, n.resolved.minH)
                    if (c.kind == 1) {
                        naturalW = greater(naturalW, cw)
                        naturalH = sat(naturalH, ch)
                    } else {
                        naturalW = sat(naturalW, cw)
                        naturalH = greater(naturalH, ch)
                    }
                }
            }
            for (_ in 1..children.size) {
                if (c.kind == 1) {
                    naturalH = sat(naturalH, resolved.spacing)
                } else {
                    naturalW = sat(naturalW, resolved.spacing)
                }
            }
        }
        let border = if (resolved.borderStyle == BorderStyle.None) { 0 } else { 1 }
        naturalW = sat(sat(naturalW,sat(resolved.padLeft,border)),sat(resolved.padRight,border))
        naturalH = sat(sat(naturalH,sat(resolved.padTop,border)),sat(resolved.padBottom,border))
    }
    func refresh(inherited: Style, isRoot: Bool): Unit {
        resolved = resolveStyle(component,session.theme,inherited,isRoot)
        for (child in children) { child.refresh(resolved.style,false) }
    }
}
