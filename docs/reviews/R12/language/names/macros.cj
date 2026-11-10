macro package auditnames.macros

import std.ast.*

public macro Component(input: Tokens): Tokens {
    let declaration = ClassDecl(input)
    let template = ClassDecl(quote(class Shape <: auditnames.Component {}))
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

public macro State(input: Tokens): Tokens {
    let field = VarDecl(input)
    let name = field.identifier
    let storage = cangjieLex("_state_" + name.value)
    let fieldType = field.declType.toTokens()
    let initial = field.expr.toTokens()
    quote(
        private let $(storage) = auditnames.Observable<$(fieldType)>($(initial))
        public mut prop $(name): $(fieldType) {
            get() { $(storage).get() }
            set(value) { $(storage).set(value) }
        }
    )
}
