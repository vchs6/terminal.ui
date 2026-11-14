package cjtui_composition
import cjtui.*

class Commands {
    let data: JobData
    let taskEditor = TextEditController()
    let logEditor = TextEditController()
    var taskFocus: ?NodeRef = None
    var logFocus: ?NodeRef = None
    var owner: ?NodeRef = None
    var details: ?OverlayHandle = None
    var app: ?Application = None
    var generation: Int64 = 0
    let running = Observable<Bool>(false)
    init(data: JobData) { this.data = data }
    func scene(logs: Bool): Unit {
        data.logsScene.set(logs)
        let focus = if (logs) { logFocus } else { taskFocus }
        if (let Some(ref) <- focus) { ref.requestFocus() }
    }
    func toggleTheme(): Unit {
        let next = !data.light.get()
        data.light.set(next)
        app.getOrThrow().loadTheme(ThemeSource.Preset(if (next) { ThemePreset.Light } else { ThemePreset.Classic }))
    }
    func openDetails(): Unit {
        if (let Some(handle) <- details) { if (handle.isOpen()) { return } }
        let panel = JobPanel(data, this, modal: true).alignItems(Alignment.Stretch).width(32).height(9)
            .border(BorderStyle.Rounded).shadow(style: Style(background: Color.Black))
        details = Some(owner.getOrThrow().openOverlay(panel, options: OverlayOptions(mode: OverlayMode.Modal)))
    }
    func closeDetails(): Unit { if (let Some(handle) <- details) { handle.close() } }
    func quit(): Unit { generation++; app.getOrThrow().stop() }
    func start(): Unit { if (!running.get() && data.stage.get() == 0) { calculate(false) } }
    func resume(): Unit { if (!running.get() && data.stage.get() == 1) { calculate(true) } }
    func calculate(squares: Bool): Unit {
        running.set(true)
        generation++
        let current = generation
        let app = app.getOrThrow()
        let owner = owner.getOrThrow()
        spawn {
            =>
                var result: Int64 = 0
                for (i in 1..10001) { result += if (squares) { i * i } else { i } }
                let expected: Int64 = if (squares) { 333383335000 } else { 50005000 }
                let computed = result
                if (computed == expected) {
                    app.post(owner, {=>
                        if (current == generation) {
                            running.set(false)
                            if (squares) { data.secondResult.set(computed) } else { data.firstResult.set(computed) }
                            data.stage.set(if (squares) { 2 } else { 1 })
                        }
                    })
                } else { false }
        }
    }
    func global(key: String): Unit {
        match (key) {
            case "f1" => scene(false)
            case "f2" => scene(true)
            case "f3" => toggleTheme()
            case "f4" => openDetails()
            case "f5" => start()
            case "f6" => resume()
            case "f9" => closeDetails()
            case "f10" => quit()
            case _ => ()
        }
    }
    func modalKey(event: UIKeyEvent): Unit {
        if (event.key.code == "f3" || event.key.code == "f9" || event.key.code == "f10") {
            global(event.key.code)
            event.consume()
        }
    }
}
