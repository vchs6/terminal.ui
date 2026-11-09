package cjtui

import std.collection.ArrayList
import unicode.GraphemeIterator
import unicodewidth.StringWidth

public func graphemeClusters(value: String): Array<String> {
    if (value.isEmpty()) { return Array<String>() }
    let result = ArrayList<String>()
    let iterator = GraphemeIterator(value)
    while (true) {
        match (iterator.next()) {
            case None => break
            case Some(cluster) => result.add(cluster.toString())
        }
    }
    return result.toArray()
}

public func displayWidth(value: String, ambiguousWide!: Bool = false): Int64 {
    if (ambiguousWide) { return Int64(value.widthCjk()) }
    return Int64(value.width())
}
