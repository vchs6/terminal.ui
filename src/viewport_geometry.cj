package cjtui

// Alignment works only on finite committed viewport and content dimensions.
func viewportAlignedOffset(current: Int64, viewport: Int64, extent: Int64, start: Int64, length: Int64,
    alignment: ScrollAlign): Int64 {
    if (viewport == 0 || length == 0) { return current }
    let end = signedAdd(start,length)
    let windowEnd = signedAdd(current,viewport)
    var desired = current
    match (alignment) {
        case ScrollAlign.Start => desired = start
        case ScrollAlign.End => desired = signedAdd(end,-viewport)
        case ScrollAlign.Center =>
            let gap = viewport - length
            var half = gap / 2
            if (gap < 0 && gap % 2 != 0) { half -= 1 }
            desired = signedAdd(start,-half)
        case ScrollAlign.Nearest =>
            if ((start >= current && end <= windowEnd) || (length > viewport && current >= start && windowEnd <= end)) {
                return current
            }
            if (start < current) { desired = start } else { desired = signedAdd(end,-viewport) }
    }
    lesser(greater(0,desired),greater(0,extent-viewport))
}

// Translate a requested local rectangle from the innermost viewport outward.
func applyViewportEnsure(session: RuntimeSession, command: ScrollCommand): Unit {
    if (!command.target.isValid()) { return }
    let target = command.target.resolve()
    if (!session.focusManager.effective(target,false)) { return }
    var node = target
    var x: Int64 = 0; var y: Int64 = 0; var w: Int64 = 0; var h: Int64 = 0
    if (let Some(rect) <- command.rect) {
        if (rect.x < 0 || rect.y < 0 || rect.x > node.logicalWidth || rect.y > node.logicalHeight ||
            rect.width > node.logicalWidth-rect.x || rect.height > node.logicalHeight-rect.y) { return }
        x = rect.x; y = rect.y; w = rect.width; h = rect.height
    } else {
        x = node.layoutX; y = node.layoutY; w = node.layoutWidth; h = node.layoutHeight
        match (node.parent) { case Some(parent) => node = parent; case None => return }
    }
    while (true) {
        let axes = session.viewportAxes(node)
        var ox: Int64 = 0; var oy: Int64 = 0
        if (let Some(active) <- axes) {
            let view = node.viewportState.snapshot()
            ox = if (active.horizontal()) { viewportAlignedOffset(view.offsetX,view.width,view.contentWidth,x,w,command.horizontal) } else { 0 }
            oy = if (active.vertical()) { viewportAlignedOffset(view.offsetY,view.height,view.contentHeight,y,h,command.vertical) } else { 0 }
            if (node.viewportState.setOffset(ox,oy)) { session.markChanged(node,ChangeKind.Style) }
            // Carry only the visible fragment through the next outer viewport.
            let right = lesser(signedAdd(x,w),signedAdd(ox,view.width))
            let bottom = lesser(signedAdd(y,h),signedAdd(oy,view.height))
            x = greater(x,ox); y = greater(y,oy)
            w = greater(0,right-x); h = greater(0,bottom-y)
            if (w == 0 || h == 0) { return }
        }
        let parent = node.parent
        if (parent.isNone()) { return }
        x = signedAdd(signedAdd(node.layoutX,node.contentX),signedAdd(x,-ox))
        y = signedAdd(signedAdd(node.layoutY,node.contentY),signedAdd(y,-oy))
        node = parent.getOrThrow()
    }
}

func applyPendingViewportEnsures(session: RuntimeSession): Unit {
    let pending = session.pendingEnsures.toArray(); session.pendingEnsures.clear()
    var focus = session.pendingFocusEnsure; session.pendingFocusEnsure = None
    for (command in pending) {
        if (let Some(current) <- focus) {
            if (current.order < command.order) { applyViewportEnsure(session,current); focus = None }
        }
        applyViewportEnsure(session,command)
    }
    if (let Some(current) <- focus) { applyViewportEnsure(session,current) }
}

// Framework fallback follows the user's Ancestor callback at this node.
func viewportDefault(node: RuntimeNode, key: KeyEvent): Bool {
    let axes = node.session.viewportAxes(node)
    if (axes.isNone()) { return false }
    let active = axes.getOrThrow(); let ref = node.reference()
    let view = node.viewportState.snapshot()
    match (key.code) {
        case "up" => if (active.vertical()) { ref.scrollBy(0,-1) } else { false }
        case "down" => if (active.vertical()) { ref.scrollBy(0,1) } else { false }
        case "left" => if (active.horizontal()) { ref.scrollBy(-1,0) } else { false }
        case "right" => if (active.horizontal()) { ref.scrollBy(1,0) } else { false }
        case "pageup" => if (active.vertical()) { ref.scrollBy(0,-greater(1,view.height-1)) } else { false }
        case "pagedown" => if (active.vertical()) { ref.scrollBy(0,greater(1,view.height-1)) } else { false }
        case "home" => if (active.vertical()) { ref.scrollTo(view.offsetX,0) } else if (active.horizontal()) { ref.scrollTo(0,view.offsetY) } else { false }
        case "end" => if (active.vertical()) { ref.scrollTo(view.offsetX,Int64.Max) } else if (active.horizontal()) { ref.scrollTo(Int64.Max,view.offsetY) } else { false }
        case _ => false
    }
}
