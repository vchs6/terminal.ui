// Isolated language feasibility probe; NOT cjtui or a rendering implementation.
import std.collection.*

class Node {
    var name: String
    var style: String = "default"
    var children = ArrayList<Node>()
    var callback: () -> Unit = { => }
    init(name: String) { this.name = name }
    func color(value: String): Node { style = value; return this }
    func onClick(action: () -> Unit): Node { callback = action; return this }
}
var parents = ArrayList<Node>()
func attach(node: Node): Node {
    if (parents.size > 0) { parents[parents.size - 1].append(node) }
    return node
}
extend Node {
    func append(node: Node): Unit { children.add(node) }
}
func Text(value: String): Node { return attach(Node(value)) }
func Column(body: () -> Unit): Node {
    let node = attach(Node("Column"))
    parents.add(node)
    try { body() } finally { parents.remove(at: parents.size - 1) }
    return node
}
func Panel(title: String, body: () -> Unit): Node {
    return Column { Text(title); body() }
}
class Counter { var value: Int64 = 0 }
main(): Int64 {
    let clicked = Counter()
    let root = Column {
        Text("first").color("red")
        Column { Text("nested") }.color("blue")
        if (true) { Text("conditional") }
        for (i in 0..2) { Text("item-${i}") }
        Panel("custom") { Text("body") }
        Text("button").onClick { clicked.value++ }
    }.color("green")
    root.children[6].callback()
    if (root.children.size != 7 || root.style != "green" || root.children[0].style != "red" || root.children[1].style != "blue" || root.children[1].children.size != 1 || root.children[5].children.size != 2 || clicked.value != 1) { return 1 }
    println("PASS nested blocks, post-block chain, seven children, conditional/list, custom component and callback")
    return 0
}
