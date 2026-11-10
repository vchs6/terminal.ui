package runtime_contract

// Reference storage for Cangjie escaping callbacks; never shared unsynchronized
// between threads. Gate controls the only cross-thread handshakes.
class Box<T> {
    var value: T
    init(value: T) { this.value = value }
}
