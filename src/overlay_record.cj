package cjtui

// One record refers to the existing mounted generation; it owns no second tree.
class OverlayRecord <: ObservableSource {
    let owner: NodeRef
    let options: OverlayOptions
    let sessionId: Int64
    let threadId: Int64
    let threadNonce: Int64
    var description: ?Component
    var root: ?NodeRef = None
    var savedFocus: ?NodeRef = None
    var terminal: ?OverlayCloseReason = None
    var requested: ?OverlayCloseReason = None
    init(session: RuntimeSession, owner: NodeRef, description: Component, options: OverlayOptions) {
        this.owner = owner; this.options = options; this.description = Some(description)
        sessionId = session.id; threadId = session.threadId; threadNonce = session.threadNonce
    }
    func guard(): Unit {
        if (Thread.currentThread.id != threadId || uiThreadIdentity().nonce != threadNonce) {
            throw UIException("WrongUIContext", "wrong UI thread")
        }
        if (let Some(current) <- activeSession.get()) {
            if (current.id != sessionId) { throw UIException("WrongUIContext", "another session owns the active callback") }
        }
    }
    func observe(): Unit {
        lock.lock(); let observed = version; lock.unlock()
        if (let Some(binding) <- evaluating.get()) { binding.read(this,observed) }
    }
    func changed(): Unit { lock.lock(); version++; lock.unlock(); emit() }
}
