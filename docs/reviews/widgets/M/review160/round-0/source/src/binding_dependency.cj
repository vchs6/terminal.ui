package cjtui

class BindingDependency {
    let source: ObservableSource
    let version: Int64
    init(source: ObservableSource, version: Int64) { this.source = source; this.version = version }
}
