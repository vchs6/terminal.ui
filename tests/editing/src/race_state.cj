package editing_contract
import std.sync.Mutex
class RaceState {
    private let mutex = Mutex()
    private var stopped = false
    private var sequence: Int64 = 0
    private var last = ""
    func stop(): Unit { synchronized(mutex) { stopped = true } }
    func isStopped(): Bool { synchronized(mutex) { stopped } }
    func wrote(value: String): Unit { synchronized(mutex) { sequence++; last = value } }
    func completed(): (Int64, String) { synchronized(mutex) { (sequence, last) } }
}
