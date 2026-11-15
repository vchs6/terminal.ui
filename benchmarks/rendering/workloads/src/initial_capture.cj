package rendering_workloads

import cjtui.*
import std.collection.ArrayList

public class InitialCapture {
    public let totals = InitialTotals()
    public let before = ArrayList<Observation>()
    public let after = ArrayList<Observation>()
    public var cells = cellCsvHeader()
    public var carets = "scenario,seed,epoch,stage,owner,owner_valid,x,y,visible\n"

    public init(options: Options, diagnostic: Bool) {
        for (epoch in 0..2) {
            let scene = TextScene("vertical_panels", options.width, options.height)
            let app = scene.app
            let first = Observation(app)
            try {
                app.startHeadless()
                let snapshot = app.snapshot(options.width, options.height)
                let caret = app.caretSnapshot()
                if (caret.visible || caret.owner.isSome() || caret.x != 0 || caret.y != 0) {
                    throw Exception("unexpected initial caret")
                }
                if (diagnostic) {
                    carets += "initial,${options.seed},${epoch},before_render,none,false,0,0,false\n"
                    let reference = render(scene.root, options.width, options.height)
                    let endingCaret = app.caretSnapshot()
                    if (endingCaret.visible || endingCaret.owner.isSome() || endingCaret.x != 0 || endingCaret.y != 0) {
                        throw Exception("reference render changed initial caret")
                    }
                    assertFramesEqual(snapshot, reference)
                    cells += cellCsv(snapshot, "initial", options.seed, epoch, "m2")
                    cells += cellCsv(reference, "initial", options.seed, epoch, "m1")
                    carets += "initial,${options.seed},${epoch},after_render,none,false,0,0,false\n"
                } else {
                    cells += cellCsv(snapshot, "initial", options.seed, epoch, "snapshot")
                    carets += "initial,${options.seed},${epoch},snapshot,none,false,0,0,false\n"
                }
                let last = Observation(app)
                before.add(first); after.add(last); totals.add(first, last)
                totals.textBytes = scene.textBytes()
            } finally { app.dispose() }
        }
    }
}
