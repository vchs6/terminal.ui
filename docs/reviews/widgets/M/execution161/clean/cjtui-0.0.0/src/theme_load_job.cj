package cjtui

class ThemeLoadJob {
    let request: ThemeRequest
    let source: ThemeSource
    let sessionId: Int64
    init(request: ThemeRequest, source: ThemeSource, sessionId: Int64) {
        this.request = request; this.source = source; this.sessionId = sessionId
    }
}
