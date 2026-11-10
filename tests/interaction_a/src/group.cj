package interaction_a_contract
import cjtui.*
import std.collection.ArrayList
// Factories execute inside the public component block; retained expressions do not attach.
func group(factories: Array<() -> Component>): (Component, Array<Component>) {
    let nodes=ArrayList<Component>()
    let root=Column { for(factory in factories){nodes.add(factory())} }
    (root,nodes.toArray())
}
