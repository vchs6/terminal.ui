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
    clipR: Int64, clipB: Int64, inherited: Style): Unit {
    let c = n.component
    let style = Style(foreground: c.fg ?? inherited.foreground, background: c.bg ?? inherited.background,
        bold: c.isBold ?? inherited.bold)
    let right = lesser(clipR, sat(x, w));
    let bottom = lesser(clipB, sat(y, h))
    let rect = Rect(x, y, w, h)
    if (c.shadowEnabled) {
        frame.shadowClipped(rect, c.shadowX, c.shadowY, c.shadowStyle, clipL, clipT, clipR, clipB)
    }
    if (c.bg != Option<Color>.None) {
        frame.fillClipped(rect, style, clipL, clipT, clipR, clipB)
    }
    let borderStyle = Style(foreground: c.borderFg ?? style.foreground, background: style.background, bold: style.bold)
    frame.borderClipped(rect, c.borderStyle, borderStyle, clipL, clipT, clipR, clipB)
    let inset = sat(c.pad, if (c.borderStyle == BorderStyle.None) {
        0
    } else {
        1
    })
    let leftPad = lesser(inset, w);
    let topPad = lesser(inset, h)
    let innerW = w - leftPad - lesser(inset, w - leftPad)
    let innerH = h - topPad - lesser(inset, h - topPad)
    let ix = sat(x, leftPad);
    let iy = sat(y, topPad)
    let ir = lesser(right, sat(ix, innerW));
    let ib = lesser(bottom, sat(iy, innerH))
    if (c.kind == 0) {
        for (i in 0..n.lines.size) {
            let cy = sat(iy, i)
            let free = if (n.widths[i] < innerW) {
                innerW - n.widths[i]
            } else {
                0
            }
            var cx = sat(ix, offset(c.textAlignment, free))
            for (g in n.lines[i]) {
                let gw = displayWidth(g)
                if (cy < ib && cx < ir && gw <= ir - cx) {
                    frame.put(cx, cy, g, style: style)
                }
                cx = sat(cx, gw)
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
    let sizes = Array<Int64>(count, repeat: 0)
    let bases = Array<Int64>(count, repeat: 0)
    let remainders = Array<Int64>(count, repeat: 0)
    var occupied: Int64 = 0
    var totalWeight: Int64 = 0
    var totalBase: Int64 = 0
    var flexCount: Int64 = 0
    for (i in 0..count) {
        let child = n.children[i];
        let cc = child.component
        if (i > 0) {
            occupied = sat(occupied, c.spacing)
        }
        let minimum = if (c.kind == 2) {
            cc.minW
        } else {
            cc.minH
        }
        if (cc.weight > 0) {
            if (totalWeight > Int64.Max - cc.weight) {
                throw IllegalArgumentException("weight sum overflow")
            }
            totalWeight += cc.weight
            flexCount++
            bases[i] = lesser(minimum, mainSize)
            if (totalBase > Int64.Max - bases[i]) {
                throw IllegalArgumentException("minimum sum overflow")
            }
            totalBase += bases[i]
        } else {
            let desired = if (c.kind == 2) {
                cc.fixedW ?? child.naturalW
            } else {
                cc.fixedH ?? child.naturalH
            }
            sizes[i] = lesser(mainSize, greater(desired, minimum))
            occupied = sat(occupied, sizes[i])
        }
    }
    let pool = if (occupied < mainSize) {
        mainSize - occupied
    } else {
        0
    }
    if (flexCount > 0) {
        let useMin = totalBase > pool
        let denominator = if (useMin) {
            totalBase
        } else {
            totalWeight
        }
        let amount = if (useMin) {
            pool
        } else {
            pool - totalBase
        }
        var used: Int64 = 0
        for (i in 0..count) {
            let cc = n.children[i].component
            if (cc.weight > 0) {
                let basis = if (useMin) {
                    bases[i]
                } else {
                    cc.weight
                }
                let (share, rem) = mulDiv(basis, amount, denominator)
                sizes[i] = share + if (useMin) {
                    0
                } else {
                    bases[i]
                }
                remainders[i] = rem
                used += share
            }
        }
        var remaining = amount - used
        while (remaining > 0) {
            var best: Int64 = -1
            for (i in 0..count) {
                if (n.children[i].component.weight > 0 && remainders[i] >= 0 && (best < 0 || remainders[i] > remainders[best])) {
                    best = i
                }
            }
            sizes[best]++;
            remainders[best] = -1
            remaining--
        }
    }
    let free = if (flexCount == 0 && occupied < mainSize) {
        mainSize - occupied
    } else {
        0
    }
    var cursor = offset(c.justify, free)
    for (i in 0..count) {
        let child = n.children[i];
        let cc = child.component
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
        if (c.align == Alignment.Stretch && fixed == Option<Int64>.None) {
            crossSize = cross
        }
        let crossOffset = offset(c.align, cross - crossSize)
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
        paint(child, frame, cx, cy, cw, ch, greater(clipL, ix), greater(clipT, iy), ir, ib, style)
        cursor = sat(cursor, sizes[i])
        if (i + 1 < count) {
            cursor = sat(cursor, c.spacing)
        }
    }
}

public func render(root: Component, width: Int64, height: Int64): Frame {
    let frame = Frame(width, height)
    let node = LayoutNode(root);
    node.measure()
    let w = lesser(width, greater(root.fixedW ?? width, root.minW))
    let h = lesser(height, greater(root.fixedH ?? height, root.minH))
    paint(node, frame, 0, 0, w, h, 0, 0, width, height, Style())
    frame
}
