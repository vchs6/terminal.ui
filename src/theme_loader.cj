package cjtui

import std.env.getWorkingDirectory

// Application-owned ordering, worker slot, latest pending job and mailbox.
// The inherited lock protects all fields; I/O, parsing and observer notification
// occur after releasing it. Only the owning UI session may commit a candidate.
class ThemeLoader <: ObservableSource {
    private var accepted: Theme
    private var acceptedSource: ThemeSource
    private var revision: UInt64 = 0
    private var acceptedRequest: UInt64 = 0
    private var nextRequest: UInt64 = 0
    private var activeSessionId: ?Int64 = None
    private var latest: ?ThemeRequest = None
    private var pending: ?ThemeLoadJob = None
    private var mailbox: ?ThemeCandidate = None
    private var workerRunning = false

    init(initial: Theme) { accepted = initial; acceptedSource = ThemeSource.Prepared(initial) }
    func currentTheme(): Theme {
        lock.lock(); try { accepted } finally { lock.unlock() }
    }
    func info(): ThemeInfo {
        lock.lock()
        let value: ThemeInfo
        let observed: Int64
        try {
            value = ThemeInfo(accepted.name,revision,acceptedRequest,acceptedSource)
            observed = version
        } finally { lock.unlock() }
        if (let Some(binding) <- evaluating.get()) { binding.read(this,observed) }
        value
    }
    func open(sessionId: Int64): Unit {
        lock.lock(); try { activeSessionId = Some(sessionId) } finally { lock.unlock() }
    }
    func closeSession(sessionId: Int64): Unit {
        var completed: ?ThemeRequest = None
        lock.lock()
        try {
            if (activeSessionId == Some(sessionId)) {
                activeSessionId = None; pending = None; mailbox = None
                if (let Some(request) <- latest) {
                    if (request.complete(ThemeResult.SessionClosed)) { completed = Some(request) }
                }
            }
        } finally { lock.unlock() }
        if (let Some(request) <- completed) { request.announce() }
    }
    func freeze(source: ThemeSource): ThemeSource {
        match (source) {
            case ThemeSource.File(path) =>
                if (path.isEmpty() || path.contains("\u{0}") || path.startsWith("/")) { source }
                else { ThemeSource.File(getWorkingDirectory().toString() + "/" + path) }
            case _ => source
        }
    }
    func submit(requested: ThemeSource, reload: Bool): ThemeRequest {
        if (evaluating.get().isSome() || structureEvaluation.get().isSome()) {
            throw UIException("ReentrantEvaluation","theme load during evaluation")
        }
        let frozen = if (reload) { requested } else { freeze(requested) }
        var replaced: ?ThemeRequest = None
        var closed = false
        var startWorker = false
        let request: ThemeRequest
        lock.lock()
        try {
            if (nextRequest == UInt64.Max) { throw UIException("CapacityExceeded","theme request ids exhausted") }
            nextRequest++; request = ThemeRequest(nextRequest)
            match (activeSessionId) {
                case None => closed = request.complete(ThemeResult.SessionClosed)
                case Some(sessionId) =>
                    if (let Some(previous) <- latest) {
                        if (previous.complete(ThemeResult.Superseded(request.id))) { replaced = Some(previous) }
                    }
                    latest = Some(request); pending = None; mailbox = None
                    var actual = frozen
                    var missing = false
                    if (reload) {
                        match (accepted.sourcePath) {
                            case Some(path) => actual = ThemeSource.File(path)
                            case None => missing = true
                        }
                    }
                    let job = ThemeLoadJob(request,actual,sessionId)
                    if (missing) {
                        let d = ThemeDiagnostic("NoFileSource","<reload>","","accepted theme has no file source",Option<ThemeLocation>.None,"unavailable")
                        mailbox = Some(ThemeCandidate(job,Option<Theme>.None,Some(d)))
                    } else {
                        match (actual) {
                            case ThemeSource.Prepared(theme) => mailbox = Some(ThemeCandidate(job,Some(theme),Option<ThemeDiagnostic>.None))
                            case _ =>
                                pending = Some(job)
                                if (!workerRunning) { workerRunning = true; startWorker = true }
                        }
                    }
            }
        } finally { lock.unlock() }
        if (let Some(old) <- replaced) { old.announce() }
        if (closed) { request.announce() }
        if (startWorker) { let _ = spawn { worker() } }
        request
    }
    private func worker(): Unit {
        while (true) {
            let job: ?ThemeLoadJob
            lock.lock()
            try {
                job = pending; pending = None
                if (job.isNone()) { workerRunning = false; return }
            } finally { lock.unlock() }
            let current = job.getOrThrow()
            var value: ?Theme = None
            var error: ?ThemeDiagnostic = None
            var fault: ?Exception = None
            try {
                value = Some(match (current.source) {
                    case ThemeSource.File(path) => Theme.readFile(path)
                    case ThemeSource.Preset(preset) => Theme.preset(preset)
                    case ThemeSource.Prepared(theme) => theme
                })
            } catch (e: ThemeException) { error = Some(e.diagnostic) }
            catch (e: Exception) { fault = Some(e) }
            lock.lock()
            try {
                if (activeSessionId == Some(current.sessionId) && nextRequest == current.request.id) {
                    mailbox = Some(ThemeCandidate(current,value,error,fault:fault))
                }
            } finally { lock.unlock() }
        }
    }
    func hasCandidate(sessionId: Int64): Bool {
        lock.lock()
        try { activeSessionId == Some(sessionId) && mailbox.isSome() } finally { lock.unlock() }
    }
    func candidate(sessionId: Int64): ?ThemeCandidate {
        lock.lock()
        try { if (activeSessionId == Some(sessionId)) { mailbox } else { None } } finally { lock.unlock() }
    }
    func claimFault(sessionId: Int64, candidate: ThemeCandidate): ?Exception {
        lock.lock()
        try {
            if (activeSessionId != Some(sessionId) || nextRequest != candidate.job.request.id || mailbox.isNone()) {
                return Option<Exception>.None
            }
            mailbox = None
            candidate.fault
        } finally { lock.unlock() }
    }
    func finish(session: RuntimeSession, candidate: ThemeCandidate, error: ?ThemeDiagnostic, layoutChanged: Bool): Unit {
        var notifyRequest = false
        var notifyInfo = false
        lock.lock()
        try {
            if (activeSessionId != Some(session.id) || nextRequest != candidate.job.request.id || mailbox.isNone()) { return }
            mailbox = None
            if (let Some(diagnostic) <- error) {
                notifyRequest = candidate.job.request.complete(ThemeResult.Failed(diagnostic))
            } else if (revision == UInt64.Max) {
                let d = ThemeDiagnostic("CapacityExceeded","<theme>","","theme revision exhausted",Option<ThemeLocation>.None,"unavailable")
                notifyRequest = candidate.job.request.complete(ThemeResult.Failed(d))
            } else {
                let theme = candidate.theme.getOrThrow()
                session.acceptTheme(theme,layoutChanged)
                accepted = theme; acceptedSource = candidate.job.source
                revision++; acceptedRequest = candidate.job.request.id; version++
                notifyRequest = candidate.job.request.complete(ThemeResult.Applied(revision)); notifyInfo = true
            }
        } finally { lock.unlock() }
        if (notifyRequest) { candidate.job.request.announce() }
        if (notifyInfo) { emit() }
    }
}
