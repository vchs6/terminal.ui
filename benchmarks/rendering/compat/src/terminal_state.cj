package rendering_compat

import cjtui.*
import rendering_workloads.*
import std.fs.File
import std.time.MonoTime

// Input events and a side file are ordinary business coordination. An ack
// never claims that its own callback's resulting frame is already presented.
class TerminalState {
    let options: Options
    let workload: Workload
    let app: Application
    let terminalRoot: Component
    let fence: Observable<String>
    let fenceX: Observable<Int64>
    let fenceY: Observable<Int64>
    let fenceSetup: () -> Unit
    let addedNodes: Int64
    let addedLayers: Int64
    var epoch: Int64 = 0
    var warmed: Int64 = 0
    var measured: Int64 = 0
    var before: ?Observation = None
    var after: ?Observation = None
    var facts: ?SceneFacts = None
    var started: ?MonoTime = None
    var loopUs: Int64 = 0
    var samplingUs: Int64 = 0
    var fenceNumber: Int64 = 0
    var setupStarted = false
    var childSetup = false
    var ready = false
    var warmupPending = false
    var actionPending = false
    var ended = false

    init(options: Options, workload: Workload, app: Application, terminalRoot: Component, fence: Observable<String>,
        fenceX: Observable<Int64>, fenceY: Observable<Int64>, fenceSetup: () -> Unit, addedNodes: Int64, addedLayers: Int64) {
        this.options = options; this.workload = workload; this.app = app; this.terminalRoot = terminalRoot; this.fence = fence
        this.fenceX = fenceX; this.fenceY = fenceY; this.fenceSetup = fenceSetup; this.addedNodes = addedNodes; this.addedLayers = addedLayers
    }

    func assertTerminalGeometry(): Unit {
        if (options.scenario != "resize_pair" && options.scenario != "viewport_caret") { return }
        let narrower = if (options.scenario == "resize_pair") { epoch % 2 == 1 } else { epoch % 3 == 2 }
        let expectedWidth = if (narrower) { options.width / 2 } else { options.width }
        let expectedHeight = if (narrower && options.scenario == "resize_pair") { options.height / 2 } else { options.height }
        let viewport = terminalRoot.reference().getOrThrow().viewportSnapshot()
        if (viewport.width != expectedWidth || viewport.height != expectedHeight) {
            throw Exception("terminal resize not committed: ${viewport.width}x${viewport.height}; expected ${expectedWidth}x${expectedHeight}")
        }
    }

    func setFencePosition(): Unit {
        let narrower = if (options.scenario == "resize_pair") { epoch % 2 == 1 }
            else if (options.scenario == "viewport_caret") { epoch % 3 == 2 } else { false }
        let x = if (narrower) { options.width / 2 - 1 } else { options.width - 1 }
        let y = if (narrower && options.scenario == "resize_pair") { options.height / 2 - 1 } else { options.height - 1 }
        if (fenceX.get() != x) { fenceX.set(x) }
        if (fenceY.get() != y) { fenceY.set(y) }
    }

    func acknowledge(value: String): Unit { File.writeTo(options.csv + ".ack", (value + "\n").toArray()) }

    func key(event: KeyEvent): Unit {
        if (event.text == "r" && before.isNone()) {
            if (!setupStarted) {
                workload.setup(); fenceSetup(); setupStarted = true; acknowledge("setup")
            } else if (options.scenario == "overlay_nested_close" && !childSetup) {
                workload.terminalAfterSetup(); childSetup = true; acknowledge("setup-child")
            } else {
                assertTerminalGeometry()
                if (warmupPending) {
                    workload.afterSnapshot(epoch); workload.terminalAfterAction(epoch); warmupPending = false
                }
                ready = true; acknowledge("ready")
            }
        } else if (event.text == "w" && before.isNone() && ready) {
            if (options.scenario != "idle") {
                epoch++; setFencePosition(); workload.action(epoch); app.glyphMode(workload.glyph(epoch))
            }
            warmed++; ready = false; warmupPending = options.scenario != "idle"; acknowledge("warmup:${warmed}")
        } else if (event.text == "b" && before.isNone() && ready) {
            if (warmed != options.warmup) { throw Exception("warmup count mismatch") }
            let t = MonoTime.now()
            before = Some(Observation(app))
            samplingUs += (MonoTime.now() - t).toMicroseconds()
            acknowledge("begin")
            started = Some(MonoTime.now())
        } else if (event.text == "a" && before.isSome() && !ended) {
            if (options.scenario == "idle") { throw Exception("idle interval must contain no mutations") }
            if (actionPending) { throw Exception("previous action requires its fence") }
            actionPending = true
            epoch++; measured++; setFencePosition(); workload.action(epoch); app.glyphMode(workload.glyph(epoch))
        } else if (event.text == "f" && before.isSome() && !ended) {
            if (options.scenario == "idle") { throw Exception("idle interval must contain no fence") }
            if (!actionPending) { throw Exception("fence requires an action") }
            actionPending = false
            assertTerminalGeometry()
            workload.afterSnapshot(epoch)
            workload.terminalAfterAction(epoch)
            fenceNumber++; fence.set(if (fenceNumber % 2 == 0) { "." } else { ":" })
            acknowledge("fence:${fenceNumber}")
        } else if (event.text == "k" && before.isSome() && !ended) {
            if (options.scenario == "idle") { throw Exception("idle interval must contain no fence") }
            acknowledge("presented:${fenceNumber}")
        } else if (event.text == "e" && before.isSome() && !ended) {
            if (actionPending) { throw Exception("last action requires its fence") }
            loopUs = (MonoTime.now() - started.getOrThrow()).toMicroseconds()
            let t = MonoTime.now()
            let finalObservation = Observation(app)
            after = Some(finalObservation)
            samplingUs += (MonoTime.now() - t).toMicroseconds()
            facts = simpleSceneFacts(options, workload, finalObservation, epoch, addedNodes: addedNodes)
            if (facts.isNone()) { throw Exception("terminal scene facts unavailable") }
            ended = true
            acknowledge("end")
            app.stop()
        } else { throw Exception("invalid terminal protocol key or phase") }
    }

    func report(): Unit {
        if (!ended || (options.scenario != "idle" && measured != options.updates)) {
            throw Exception("terminal interval did not complete requested actions")
        }
        let b = before.getOrThrow(); let a = after.getOrThrow(); let f = facts.getOrThrow()
        let dirty = if (options.scenario == "idle") { 0 } else { f.dirtyLeaves }
        let visible = f.visible + addedNodes
        let report = sampleCsv(options, b, a, scenarioPhase(options.scenario), f.total + addedNodes, visible,
            dirty, f.textBytes + 1, if (options.scenario == "idle") { 0 } else { options.warmup + 1 }, epoch,
            0, 0, 1, "${loopUs}", "${samplingUs}", "not_available", "not_available", "not_available", layers: f.layers + addedLayers)
        File.writeTo(options.csv, report.toArray())
    }
}
