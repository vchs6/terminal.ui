package cjtui

import std.collection.ArrayList
import std.sync.Mutex

abstract class ObservableSource {
    let id = uniqueRuntimeId()
    let lock = Mutex()
    let observers = ArrayList<Binding>()
    var version: Int64 = 0
    func subscribe(binding: Binding, observedVersion: Int64): Unit {
        lock.lock()
        var changed = false
        try {
            var present = false
            for (observer in observers) { if (observer.id == binding.id) { present = true } }
            if (!present) { observers.add(binding) }
            changed = version != observedVersion
        } finally { lock.unlock() }
        if (changed) { binding.invalidate(deferred: true) }
    }
    func unsubscribe(binding: Binding): Unit {
        lock.lock()
        try {
            var i: Int64 = 0
            while (i < observers.size) {
                if (observers[i].id == binding.id) { observers.remove(at: i) } else { i++ }
            }
        } finally { lock.unlock() }
    }
    func emit(): Unit {
        let copy = ArrayList<Binding>()
        lock.lock()
        try { for (observer in observers) { copy.add(observer) } } finally { lock.unlock() }
        for (observer in copy) { observer.invalidate() }
    }
}
