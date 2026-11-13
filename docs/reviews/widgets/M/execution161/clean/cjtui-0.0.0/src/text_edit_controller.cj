package cjtui

import std.sync.Mutex

public class TextEditController {
    private let lock = Mutex()
    private var current: ?TextEditSession = None
    private let status = Observable<Int64>(0)
    public init() {}
    func attach(value: TextEditSession): Unit {
        lock.lock()
        try {
            if (let Some(old) <- current) {
                if (old.ref.isValid()) {
                    throw UIException("AlreadyMounted", "controller already mounted")
                }
            }
            current = Some(value)
        } finally {
            lock.unlock()
        }
        status.notify()
    }
    func detach(value: TextEditSession): Unit {
        lock.lock()
        try {
            if (let Some(old) <- current) {
                if (refEq(old, value)) {
                    current = None
                }
            }
        } finally {
            lock.unlock()
        }
        status.notify()
    }
    public func isValid(): Bool {
        status.get()
        lock.lock()
        try {
            if (let Some(value) <- current) {
                return value.ref.isValid()
            };
            false
        } finally {
            lock.unlock()
        }
    }
    private func session(mutate: Bool): TextEditSession {
        lock.lock()
        var value: ?TextEditSession = None
        try {
            value = current
        } finally {
            lock.unlock()
        }
        let edit = match (value) {
            case Some(current) => current
            case None => throw UIException("StaleReference", "controller is detached")
        }
        let node = edit.ref.resolve()
        if (mutate) {
            node.session.requireContext()
            if (node.session.inLifecycle) {
                throw UIException("LifecycleReentry", "editor mutation during lifecycle")
            }
            if (!node.session.inActiveDomain() || (node.session.batchDepth == 0 && !node.session.inCallback)) {
                throw UIException("WrongUIContext", "editor mutation requires an event, post or batch")
            }
        } else {
            node.session.requireReadContext()
        }
        if (mutate && edit.notifying) {
            throw UIException("LifecycleReentry", "editor callback reentry")
        }
        edit
    }
    public func snapshot(): TextEditSnapshot {
        session(false).snapshot()
    }
    public func select(selection: TextSelection): Unit {
        session(true).select(selection)
    }
    public func selectAll(): Unit {
        session(true).selectAll()
    }
    public func replaceSelection(text: String, ifUnchanged!: ?TextEditSnapshot = None): Bool {
        session(true).replace(text, ifUnchanged)
    }
    public func undo(): Bool {
        session(true).undo()
    }
    public func redo(): Bool {
        session(true).redo()
    }
    public func copy(): ?SessionResult {
        session(true).copy(false)
    }
    public func cut(): ?SessionResult {
        session(true).copy(true)
    }
}
