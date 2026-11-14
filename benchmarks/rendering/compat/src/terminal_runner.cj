package rendering_compat

import cjtui.*
import rendering_workloads.*

func runTerminal(options: Options): Unit {
    if (options.height < 2 || (!supportsTextScene(options.scenario) && options.scenario != "idle")) {
        throw Exception("terminal workload ${options.scenario} is not implemented")
    }
    let selected = if (options.scenario == "idle") { "vertical_panels" } else { options.scenario }
    let fence = Observable<String>(" ")
    let sceneRef: Array<?TextScene> = [None]
    let root = Column {
        let scene = TextScene(selected, options.width, options.height - 1)
        sceneRef[0] = Some(scene)
        Text({=> fence.get()}).width(options.width).height(1)
    }.width(options.width).height(options.height)
    let scene = sceneRef[0].getOrThrow()
    let app = Application(root, glyphMode: GlyphMode.Unicode,
        theme: Theme.parse("schema_version = 1\nname = \"benchmark\"\n"))
    let state = TerminalState(options, scene, app, fence)
    app.onKey({event => state.key(event)})
    app.run()
    state.report()
}
