// Expected compiler rejection: unknown UI property is not silently accepted.
class Node {}
func Text(value: String): Node { Node() }
main() { Text("bad").nonexistentStyle(1) }
