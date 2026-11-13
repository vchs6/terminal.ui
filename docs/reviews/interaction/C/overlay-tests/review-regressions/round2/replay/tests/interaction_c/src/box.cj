package interaction_c

// UI callback storage only; never used as cross-thread synchronization.
class Box<T> {
    var value: T
    init(value: T) {
        this.value = value
    }
}
