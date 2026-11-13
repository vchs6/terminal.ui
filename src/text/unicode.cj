package cjtui.text

import std.collection.ArrayList
import unicode.GraphemeIterator
import unicodewidth.StringWidth

// Shared segmentation provider for bounded or streaming consumers.
public func graphemeIterator(value: String): GraphemeIterator {
    GraphemeIterator(value)
}

public func graphemeClusters(value: String): Array<String> {
    if (value.isEmpty()) {
        return Array<String>()
    }
    let result = ArrayList<String>()
    let iterator = graphemeIterator(value)
    while (true) {
        match (iterator.next()) {
            case None => break
            case Some(cluster) => result.add(cluster.toString())
        }
    }
    return result.toArray()
}

public func displayWidth(value: String, ambiguousWide!: Bool = false): Int64 {
    if (ambiguousWide) {
        return Int64(value.widthCjk())
    }
    return Int64(value.width())
}
