import std.sync.Mutex

main(): Int64 {
    let uiId = Thread.currentThread.id
    let current = ThreadLocal<Int64>()
    current.set(Some(uiId))
    let future = spawn {
        let workerId = Thread.currentThread.id
        if (workerId == uiId || current.get() != None) { return false }
        current.set(Some(workerId))
        current.get() == Some(workerId)
    }
    if (!future.get() || current.get() != Some(uiId)) { return 1 }
    current.set(None)
    if (current.get() != None) { return 2 }
    let lock = Mutex()
    lock.lock()
    lock.lock()
    if (!lock.tryLock()) { return 3 }
    lock.unlock()
    lock.unlock()
    lock.unlock()
    println("PASS SDK1.2 Thread.currentThread.id distinguishes live Cangjie threads; ThreadLocal<T> isolated and removable; Mutex reentrant")
    return 0
}
