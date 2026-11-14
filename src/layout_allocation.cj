package cjtui

// Shared allocation for measurement and arrangement.
func allocateMain(n: LayoutNode, mainSize: Int64, naturalBasis!: Bool = false): (Array<Int64>, Int64) {
    let c = n.component
    let r = n.resolved
    let children = n.children()
    let count = children.size
    let sizes = Array<Int64>(count, repeat: 0)
    let bases = Array<Int64>(count, repeat: 0)
    let remainders = Array<Int64>(count, repeat: 0)
    var occupied: Int64 = 0
    var totalWeight: Int64 = 0
    var totalBase: Int64 = 0
    var flexCount: Int64 = 0
    for (i in 0..count) {
        let child = children[i];
        let cc = child.resolved
        if (i > 0) {
            occupied = sat(occupied, r.spacing)
        }
        let minimum = if (c.kind == 2) {
            cc.minW
        } else {
            cc.minH
        }
        let scrollHeight = if (naturalBasis && c.kind != 2) { child.scrollBasisHeight() } else { child.naturalH }
        if (cc.weight > 0) {
            if (totalWeight > Int64.Max - cc.weight) {
                throw IllegalArgumentException("weight sum overflow")
            }
            totalWeight += cc.weight
            flexCount++
            let natural = if (c.kind == 2) { cc.fixedW ?? child.naturalW }
                else { cc.fixedH ?? scrollHeight }
            bases[i] = if (naturalBasis) { greater(minimum,natural) } else { lesser(minimum, mainSize) }
            if (totalBase > Int64.Max - bases[i]) {
                throw IllegalArgumentException("minimum sum overflow")
            }
            totalBase += bases[i]
        } else {
            let desired = if (c.kind == 2) {
                cc.fixedW ?? child.naturalW
            } else {
                cc.fixedH ?? scrollHeight
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
            let cc = children[i].resolved
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
                if (children[i].resolved.weight > 0 && remainders[i] >= 0 && (best < 0 || remainders[i] > remainders[best])) {
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
    (sizes, free)
}
