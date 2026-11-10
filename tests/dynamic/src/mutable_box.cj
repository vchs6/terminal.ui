package dynamic_contract

// Cangjie escaping closures capture a let reference, not a mutable local slot.
class MutableBox<T> {
    var value: T
    init(value: T) { this.value = value }
}
