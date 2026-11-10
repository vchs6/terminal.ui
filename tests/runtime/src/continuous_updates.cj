package runtime_contract

import cjtui.*

// More than the default 64 stabilization passes, with a real background write
// ordered during each getter. Background work belongs to later turns, so this
// producer must never be diagnosed as a synchronous invalidation cycle.
func continuousBackgroundUpdates(): Unit {
    let requests = Array<Gate>(70, { _ => Gate() })
    let acknowledgements = Array<Gate>(70, { _ => Gate() })
    let value = Observable<Int64>(0)
    let reads = Box<Int64>(0)
    let producer = spawn {
        for (index in 0..70) {
            requests[index].awaitOpen()
            value.set(index + 1)
            acknowledgements[index].open()
        }
    }
    let app = Application(Text({ =>
        let observed = value.get()
        if (reads.value < 70) {
            let index = reads.value
            reads.value++
            requests[index].open()
            acknowledgements[index].awaitOpen()
        }
        "${observed}"
    }))
    app.startHeadless()
    for (_ in 0..72) { app.snapshot(3, 1) }
    producer.get(Duration.second * 5)
    picture(app.snapshot(3, 1), "70 ", "continuous background producer crosses turns without false UnstableUpdate")
    app.dispose()
}
