macro package auditnames.namespacemacros

import std.ast.*

public macro Component(input: Tokens): Tokens {
    let declaration = ClassDecl(input)
    let template = ClassDecl(quote(class Shape <: Component {}))
    declaration.upperBound = template.upperBound
    declaration.superTypes = template.superTypes
    let overrideTemplate = FuncDecl(quote(public override func build(): String { "" }))
    for (member in declaration.body.decls) {
        if (let Some(method) <- (member as FuncDecl)) {
            if (method.identifier.value == "build") { method.modifiers = overrideTemplate.modifiers }
        }
    }
    declaration.toTokens()
}
