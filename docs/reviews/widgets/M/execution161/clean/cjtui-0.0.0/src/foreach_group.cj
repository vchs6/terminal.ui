package cjtui

import std.collection.{ArrayList, HashMap, HashSet}

class ForEachGroup<T> <: DynamicGroup {
    let items: () -> Array<T>
    let key: (T) -> String
    let body: (ListItem<T>) -> Unit
    // A typed cell index, never a source of child order or retention.
    let cells = HashMap<String, ListItem<T>>()
    init(parent: RuntimeNode, items: () -> Array<T>, key: (T) -> String, body: (ListItem<T>) -> Unit) {
        super(parent)
        this.items = items
        this.key = key
        this.body = body
    }
    public override func forget(key: String): Unit {
        cells.remove(key)
    }
    public override func prepare(): Unit {
        let values = items().clone()
        let keys = ArrayList<String>()
        let uniqueKeys = HashSet<String>()
        let previous = HashMap<String, RuntimeNode>()
        for (node in owned()) {
            previous[node.groupKey] = node
        }
        for (value in values) {
            let itemKey = key(value)
            if (itemKey.isEmpty()) {
                throw UIException("InvalidKey", "list key cannot be empty")
            }
            if (!uniqueKeys.add(itemKey)) {
                throw UIException("DuplicateKey", "duplicate list key")
            }
            keys.add(itemKey)
        }
        let additions = ArrayList<Component>()
        let addedCells = ArrayList<ListItem<T>>()
        for (i in 0..keys.size) {
            if (previous.get(keys[i]).isNone()) {
                let item = ListItem<T>(keys[i], values[i])
                let component = collectDynamicRoot({=> body(item)}, true).getOrThrow()
                additions.add(component);
                addedCells.add(item)
            }
        }
        let retiring = ArrayList<RuntimeNode>()
        for (node in owned()) {
            if (!uniqueKeys.contains(node.groupKey)) {
                retiring.add(node)
            }
        }
        parent.session.preflight(additions.toArray(), Some(parent), retiring: retiring.toArray())
        plan = Some(
            {
                =>
                    let old = owned()
                    parent.session.useStructuralOps(parent.session.groupCost(old, keys.toArray()))
                    parent.session.preflight(additions.toArray(), Some(parent), retiring: retiring.toArray())
                    parent.session.replacing(
                        retiring.toArray(),
                        {
                            =>
                                let next = ArrayList<RuntimeNode>()
                                var added: Int64 = 0
                                for (i in 0..keys.size) {
                                    match (previous.get(keys[i])) {
                                        case Some(node) =>
                                            cells[keys[i]].update(values[i])
                                            next.add(node)
                                        case None =>
                                            let node = parent
                                                .session
                                                .mount(additions[added], Some(parent), parent.depth + 1)
                                            node.groupId = id
                                            node.groupKey = keys[i]
                                            cells[keys[i]] = addedCells[added]
                                            added++
                                            next.add(node)
                                    }
                                }
                                replace(next.toArray())
                        }
                    )
            }
        )
    }
}
