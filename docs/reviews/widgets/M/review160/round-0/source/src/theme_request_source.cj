package cjtui

class ThemeRequestSource <: ObservableSource {
    private var terminal: ?ThemeResult = None
    func read(): ?ThemeResult {
        lock.lock()
        let value: ?ThemeResult
        let observed: Int64
        try { value = terminal; observed = version } finally { lock.unlock() }
        if (let Some(binding) <- evaluating.get()) { binding.read(this,observed) }
        value
    }
    func complete(value: ThemeResult): Bool {
        lock.lock()
        try {
            if (terminal.isSome()) { return false }
            terminal = Some(value); version++; true
        } finally { lock.unlock() }
    }
}
