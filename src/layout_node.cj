package cjtui

import std.collection.ArrayList

class LayoutNode {
    let session: RuntimeSession
    let component: Component
    let children = ArrayList<LayoutNode>()
    let lines = ArrayList<ArrayList<String>>()
    let widths = ArrayList<Int64>()
    var naturalW: Int64 = 0
    var naturalH: Int64 = 0
    init(c: Component, session: RuntimeSession) {
        this.session = session
        component = c
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
                    let n = LayoutNode(child, session);
                    n.measure();
                    children.add(n)
                    let cw = greater(child.fixedW ?? n.naturalW, child.minW)
                    let ch = greater(child.fixedH ?? n.naturalH, child.minH)
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
                    naturalH = sat(naturalH, c.spacing)
                } else {
                    naturalW = sat(naturalW, c.spacing)
                }
            }
        }
        let inset = sat(c.pad, if (c.borderStyle == BorderStyle.None) {
            0
        } else {
            1
        })
        naturalW = sat(sat(naturalW, inset), inset)
        naturalH = sat(sat(naturalH, inset), inset)
    }
}
