import std.ref.{WeakRef, CleanupPolicy}

class Session {
    let nonce: Int64
    init(nonce: Int64) { this.nonce = nonce }
}

main(): Int64 {
    let session = Session(42)
    let weak = WeakRef<Session>(session, CleanupPolicy.EAGER)
    match (weak.value) {
        case Some(live) => if (live.nonce != session.nonce) { return 1 }
        case None => return 2
    }
    if (weak.cleanupPolicy != CleanupPolicy.EAGER) { return 3 }
    weak.clear()
    match (weak.value) {
        case Some(_) => return 4
        case None => ()
    }
    println("PASS SDK1.2 std.ref.WeakRef<T>(T,CleanupPolicy.EAGER), .value Option<T>, .cleanupPolicy and .clear()")
    return 0
}
