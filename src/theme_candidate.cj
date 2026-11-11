package cjtui

class ThemeCandidate {
    let job: ThemeLoadJob
    let theme: ?Theme
    let diagnostic: ?ThemeDiagnostic
    let fault: ?Exception
    init(job: ThemeLoadJob, theme: ?Theme, diagnostic: ?ThemeDiagnostic, fault!: ?Exception = Option<Exception>.None) {
        this.job = job; this.theme = theme; this.diagnostic = diagnostic; this.fault = fault
    }
}
