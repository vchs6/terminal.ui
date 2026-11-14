package rendering_compat

import cjtui.*
import rendering_workloads.*
import std.fs.File
import std.time.MonoTime

// External keys define business boundaries; each side-file write is an ack,
// not a claim that the current callback's resulting frame has been presented.
class TerminalState {
    let options: Options
    let scene: TextScene
    let app: Application
    let fence: Observable<String>
    var epoch: Int64 = 0
    var warmed: Int64 = 0
    var measured: Int64 = 0
    var before: ?Observation = None
    var after: ?Observation = None
    var started: ?MonoTime = None
    var loopUs: Int64 = 0
    var samplingUs: Int64 = 0
    var fenceNumber: Int64 = 0
    var ended = false

    init(options: Options, scene: TextScene, app: Application, fence: Observable<String>) {
        this.options = options; this.scene = scene; this.app = app; this.fence = fence
    }

    func acknowledge(value: String): Unit { File.writeTo(options.csv + ".ack", (value + "\n").toArray()) }

    func key(event: KeyEvent): Unit {
        if (event.text == "r" && before.isNone()) {
            acknowledge("ready")
        } else if (event.text == "w" && before.isNone()) {
            if (options.scenario != "idle") { epoch++; scene.action(epoch) }
            warmed++; acknowledge("warmup:${warmed}")
        } else if (event.text == "b" && before.isNone()) {
            if (warmed != options.warmup) { throw Exception("warmup count mismatch") }
            let t = MonoTime.now()
            before = Some(Observation(app))
            samplingUs += (MonoTime.now() - t).toMicroseconds()
            acknowledge("begin")
            started = Some(MonoTime.now())
        } else if (event.text == "a" && before.isSome() && !ended) {
            if (options.scenario == "idle") { throw Exception("idle interval must contain no mutations") }
            epoch++; measured++; scene.action(epoch)
        } else if (event.text == "f" && before.isSome() && !ended) {
            if (options.scenario == "idle") { throw Exception("idle interval must contain no fence") }
            fenceNumber++; fence.set(if (fenceNumber % 2 == 0) { "." } else { ":" })
            acknowledge("fence:${fenceNumber}")
        } else if (event.text == "k" && before.isSome() && !ended) {
            if (options.scenario == "idle") { throw Exception("idle interval must contain no fence") }
            acknowledge("presented:${fenceNumber}")
        } else if (event.text == "e" && before.isSome() && !ended) {
            loopUs = (MonoTime.now() - started.getOrThrow()).toMicroseconds()
            let t = MonoTime.now()
            after = Some(Observation(app))
            samplingUs += (MonoTime.now() - t).toMicroseconds()
            ended = true
            acknowledge("end")
            app.stop()
        } else { throw Exception("invalid terminal protocol key or phase") }
    }

    func report(): Unit {
        if (!ended || (options.scenario != "idle" && measured != options.updates)) {
            throw Exception("terminal interval did not complete requested actions")
        }
        let b = before.getOrThrow(); let a = after.getOrThrow()
        let total = a.stats.mountedNodes
        let dirty = if (options.scenario == "idle") { 0 } else { scene.dirtyLeaves() }
        let report = sampleCsv(options, b, a, scenarioPhase(options.scenario), total, total, dirty, scene.textBytes(),
            if (options.scenario == "idle") { 0 } else { options.warmup + 1 }, epoch,
            0, 0, 1, "${loopUs}", "${samplingUs}", "not_available", "not_available", "not_available")
        File.writeTo(options.csv, report.toArray())
    }
}
