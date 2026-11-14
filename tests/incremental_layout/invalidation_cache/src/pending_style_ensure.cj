package incremental_invalidation_cache

import cjtui.*

// R1-N1: pending inline geometry changes must retain ordinary same-batch ensure validation.
func pendingStyleEnsure(): Unit {
    let epoch = [Int64(0)]
    let narrow = StyleRule().withValue(StyleKeys.width, StyleValue<Dimension>.Value(Dimension.Cells(1)))
    let wide = StyleRule().withValue(StyleKeys.width, StyleValue<Dimension>.Value(Dimension.Cells(3)))
    let target = Array<Option<Component>>(1, repeat: Option<Component>.None)
    let root = Column { target[0] = Some(Text("x").styles([StyleUse.Inline(narrow)])) }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 3, 1, "x  ", "R1-N1 warm inline width one")
        let component = target[0].getOrThrow()
        let reference = component.reference().getOrThrow()
        println("R1-N1 next_batch=inline_width3_then_ensure_Rect(2,0,1,1)")
        app.batch({ =>
            component.styles([StyleUse.Inline(wide)])
            reference.ensureVisible(rect: Some(Rect(2, 0, 1, 1)))
            epoch[0]++
        })
        paired(app, root, epoch, 3, 1, "x  ", "R1-N1 valid pending-width ensure completes")
    } catch (error: UIException) {
        println("R1-N1 actual_UIException code=${error.code} message=${error.message}")
        throw error
    } finally { app.dispose() }
}
