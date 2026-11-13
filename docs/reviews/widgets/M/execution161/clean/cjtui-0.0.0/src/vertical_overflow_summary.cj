package cjtui

// Internal first-pass evidence; no public pass counter or alternate tree.
class VerticalOverflowSummary {
    var present = false
    var sourceNode: Int64 = 0
    var reason = ""
    func record(node: RuntimeNode, kind: String): Unit {
        if (!present) { present = true; sourceNode = node.id; reason = kind }
    }
}
