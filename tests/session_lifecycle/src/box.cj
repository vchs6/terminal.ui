package session_lifecycle

// UI-thread callback storage; not a cross-thread synchronization primitive.
class Box<T> {
    var value: T
    init(value: T) { this.value = value }
}
