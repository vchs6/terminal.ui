package cjtui

import std.collection.ArrayList

let collector = ThreadLocal<ArrayList<Component>>()

func collectChildren(parent: Component, body: () -> Unit): Unit {
    let previous = collector.get()
    let next = ArrayList<Component>()
    collector.set(Some(next))
    try {
        body()
        for (child in next) { parent.children.add(child) }
    } finally {
        collector.set(previous)
    }
}

func attach(component: Component): Unit {
    if (let Some(current) <- collector.get()) { current.add(component) }
}
