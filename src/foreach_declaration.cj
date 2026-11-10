package cjtui

class ForEachDeclaration<T> <: DynamicDeclaration {
    let items: () -> Array<T>
    let key: (T) -> String
    let body: (ListItem<T>) -> Unit
    init(items: () -> Array<T>, key: (T) -> String, body: (ListItem<T>) -> Unit) {
        this.items = items
        this.key = key
        this.body = body
    }
    public override func create(parent: RuntimeNode): DynamicGroup {
        ForEachGroup<T>(parent, items, key, body)
    }
}

public func ForEach<T>(items: () -> Array<T>, key: (T) -> String, body: (ListItem<T>) -> Unit): Unit {
    attachGroup(ForEachDeclaration<T>(items, key, body))
}
