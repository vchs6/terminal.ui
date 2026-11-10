package runtime_contract

import std.sync.{Condition, Mutex}

// A deterministic latch; timeout diagnoses a deadlock, never orders a race.
class Gate {
    private let mutex = Mutex()
    private var condition: Condition
    private var opened = false
    init() { synchronized(mutex) { condition = mutex.condition() } }
    func open(): Unit {
        synchronized(mutex) { opened = true; condition.notifyAll() }
    }
    func awaitOpen(): Unit {
        synchronized(mutex) {
            if (!condition.waitUntil({ => opened }, timeout: Duration.second * 5)) {
                throw Exception("synchronization gate timed out")
            }
        }
    }
}
