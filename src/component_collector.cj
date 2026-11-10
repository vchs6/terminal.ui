package cjtui

import std.collection.ArrayList

let collector = ThreadLocal<ArrayList<ChildDeclaration>>()
let structureEvaluation = ThreadLocal<Bool>()

func inStructure<T>(action: () -> T): T {
    let previous = structureEvaluation.get()
    structureEvaluation.set(Some(true))
    try {
        action()
    } finally {
        structureEvaluation.set(previous)
    }
}

func collectDeclarations(body: () -> Unit): Array<ChildDeclaration> {
    let previous = collector.get()
    let previousBinding = evaluating.get()
    let next = ArrayList<ChildDeclaration>()
    collector.set(Some(next))
    evaluating.set(Option<Binding>.None)
    try {
        inStructure(body);
        next.toArray()
    } finally {
        collector.set(previous);
        evaluating.set(previousBinding)
    }
}

func collectChildren(parent: Component, body: () -> Unit): Unit {
    let declarations = collectDeclarations(body)
    parent.declarations.add(all: declarations)
}

func collectDynamicRoot(body: () -> Unit, required: Bool): ?Component {
    let declarations = collectDeclarations(body)
    if (declarations.size > 1 || (required && declarations.size != 1)) {
        throw UIException("ConstructionRootCount", "dynamic body must declare one component root")
    }
    if (declarations.isEmpty()) {
        return None
    }
    match (declarations[0]) {
        case ChildDeclaration.DeclaredComponent(component) => Some(component)
        case ChildDeclaration.DeclaredGroup(_) => throw UIException("ConstructionRootCount",
            "dynamic root must be a component")
    }
}

func attach(component: Component): Unit {
    if (let Some(current) <- collector.get()) {
        current.add(ChildDeclaration.DeclaredComponent(component))
    }
}

func attachGroup(group: DynamicDeclaration): Unit {
    if (let Some(current) <- collector.get()) {
        current.add(ChildDeclaration.DeclaredGroup(group))
    } else {
        throw UIException("InvalidParent", "dynamic group requires a component construction body")
    }
}
