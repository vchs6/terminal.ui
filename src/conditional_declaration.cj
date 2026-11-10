package cjtui

class ConditionalDeclaration <: DynamicDeclaration {
    let condition: () -> Bool
    let thenBody: () -> Unit
    let elseBody: () -> Unit
    init(condition: () -> Bool, thenBody: () -> Unit, elseBody: () -> Unit) {
        this.condition = condition
        this.thenBody = thenBody
        this.elseBody = elseBody
    }
    public override func create(parent: RuntimeNode): DynamicGroup {
        ConditionalGroup(parent, condition, thenBody, elseBody)
    }
}

public func If(condition: () -> Bool, thenBody: () -> Unit, elseBody!: () -> Unit = {=>}): Unit {
    attachGroup(ConditionalDeclaration(condition, thenBody, elseBody))
}
