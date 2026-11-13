package cjtui

public class ListItem<T> {
    public let key: String
    private let slot: Observable<T>
    init(key: String, value: T) {
        this.key = key
        slot = Observable<T>(value)
    }
    public prop value: T {
        get() {
            slot.get()
        }
    }
    func update(value: T): Unit {
        slot.set(value)
    }
}
