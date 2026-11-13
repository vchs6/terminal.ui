package editing_contract
import cjtui.*

// Runtime evidence is accepted only together with TASK120's unique CAS-failure-locus proof.
// No source version getter, lock override, fake Observable or sleep exists in this fixture.
func concurrentSource(): Unit {
    let payload = ascii(262144)
    var observed = false
    for (attempt in 0..8) {
        let source = Observable<String>("worker:0"); let c = TextEditController()
        let issues = Box<Int64>(0); let changes = Box<Int64>(0)
        let root = TextInput(source, controller: Some(c), onChange: {_ => changes.value++},
            onIssue: {issue => check(issue == TextEditIssue.ConcurrentValueChanged, "only source race issue"); issues.value++})
        let app = Application(root); app.startHeadless()
        let ready = Gate(); let go = Gate(); let firstWrite = Gate(); let state = RaceState()
        let ownerId = Thread.currentThread.id
        let worker = spawn {
            check(Thread.currentThread.id != ownerId, "actual distinct source writer thread")
            println("RACE attempt=${attempt} worker=${Thread.currentThread.id} READY")
            ready.open(); go.awaitOpen()
            var n: Int64 = 1
            while (!state.isStopped() && n <= 65536) {
                let marker = "worker:${n}"
                source.set(marker); state.wrote(marker)
                if (n == 1) { firstWrite.open() }
                n++
            }
            println("RACE attempt=${attempt} writer-completed=${state.completed()[0]}")
        }
        let changed = Box<Bool>(false)
        try {
            ready.awaitOpen()
            app.batch({ =>
                go.open(); firstWrite.awaitOpen()
                println("RACE attempt=${attempt} owner=${ownerId} BEGIN writes=${state.completed()[0]}")
                try { changed.value = c.replaceSelection(payload) }
                finally { state.stop(); worker.get(Duration.second * 10) }
                println("RACE attempt=${attempt} END changed.value=${changed.value} issue=${issues.value} changes.value=${changes.value} writes=${state.completed()[0]}")
            })
            if (issues.value == 1) {
                let done = state.completed()
                check(done[0] > 0 && !changed.value && changes.value == 0, "actual conditional conflict outcome")
                check(source.get() == done[1] && c.snapshot().text == done[1] &&
                    !c.snapshot().canUndo && !c.snapshot().canRedo, "conflict preserves final worker value and no local history")
                println("EVIDENCE actual ConcurrentValueChanged; precise interval requires fixed119 unique-locus proof")
                observed = true
            } else { check(issues.value == 0, "at most one conflict issue"); println("NO_CONFLICT round is not race proof") }
        } finally { state.stop(); worker.get(Duration.second * 10); app.dispose() }
        if (observed) { break }
    }
    check(observed, "INSUFFICIENT_EVIDENCE: no observed CAS conflict within eight bounded rounds")
}
