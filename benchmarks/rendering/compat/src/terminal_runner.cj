package rendering_compat

import cjtui.*
import rendering_workloads.*

func runTerminal(options: Options): Unit {
    if (options.scenario == "initial") { runTerminalInitial(options); return }
    if (options.height < 2) { throw Exception("terminal fence requires at least two rows") }
    let fence = Observable<String>(" ")
    let fenceX = Observable<Int64>(options.width - 1)
    let fenceY = Observable<Int64>(options.height - 1)
    // A transparent overlay preserves the complete business root and all H
    // panel rows. It draws only the externally attributable fence character.
    let workload = Workload(options)
    workload.enableTerminal()
    let app = workload.app
    let fenceSetup = {=> app.batch({=>
        let layer = Canvas({constraints => constraints.constrain(Size(options.width, options.height))}, {context =>
            context.put(fenceX.get(), fenceY.get(), fence.get())
        }).width(options.width).height(options.height).padding(0)
        let _ = workload.root.reference().getOrThrow().openOverlay(layer,
            options: OverlayOptions(mode: OverlayMode.Passive, takeFocus: false))
    })}
    let state = TerminalState(options, workload, app, workload.root, fence, fenceX, fenceY, fenceSetup, 1, 1)
    app.onKey({event => state.key(event)})
    app.run()
    state.report()
}
