package cjtui

import std.collection.ArrayList

class ConditionalGroup <: DynamicGroup {
    let condition: () -> Bool
    let thenBody: () -> Unit
    let elseBody: () -> Unit
    var branch: ?Bool = None
    init(parent: RuntimeNode, condition: () -> Bool, thenBody: () -> Unit, elseBody: () -> Unit) {
        super(parent)
        this.condition = condition
        this.thenBody = thenBody
        this.elseBody = elseBody
    }
    public override func prepare(): Unit {
        let selected = condition()
        if (branch == Some(selected)) {
            if (!owned().isEmpty()) {
                return
            }
            // An empty branch is stable; a manually removed root is rebuilt on coordination.
            if (emptyBranch) {
                return
            }
        }
        let component = collectDynamicRoot(if (selected) {
            thenBody
        } else {
            elseBody
        }, false)
        let additions = ArrayList<Component>()
        if (let Some(root) <- component) {
            additions.add(root)
        }
        parent.session.preflight(additions.toArray(), Some(parent), retiring: owned())
        plan = Some(
            {
                =>
                    parent.session.useStructuralOps(if (owned().isEmpty() && additions.isEmpty()) {
                        0
                    } else {
                        1
                    })
                    parent.session.preflight(additions.toArray(), Some(parent), retiring: owned())
                    parent.session.replacing(
                        owned(),
                        {
                            =>
                                let next = ArrayList<RuntimeNode>()
                                if (let Some(root) <- component) {
                                    let node = parent.session.mount(root, Some(parent), parent.depth + 1)
                                    node.groupId = id
                                    next.add(node)
                                }
                                branch = Some(selected)
                                emptyBranch = component.isNone()
                                replace(next.toArray())
                        }
                    )
            }
        )
    }
    var emptyBranch = false
}
