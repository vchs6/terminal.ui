macro package audit_macros

import std.ast.*

// Isolated language feasibility probe; not a product API.
public macro State(input: Tokens): Tokens {
    let field = VarDecl(input)
    let name = field.identifier
    let storage = cangjieLex("_audit_" + name.value)
    let fieldType = field.declType.toTokens()
    let initial = field.expr.toTokens()
    return quote(
        private var $(storage): $(fieldType) = $(initial)
        public mut prop $(name): $(fieldType) {
            get() { reads++; $(storage) }
            set(value) { $(storage) = value; writes++ }
        }
    )
}

public macro Component(input: Tokens): Tokens {
    let declaration = ClassDecl(input)
    declaration.body.decls.add(parseDecl(quote(
        public func generatedMarker(): String { "macro-component" }
    )))
    declaration.toTokens()
}

public macro Bind(input: Tokens): Tokens {
    quote({ => $(input) })
}

public macro AutoComponent(input: Tokens): Tokens {
    let declaration = ClassDecl(input)
    let parentTemplate = ClassDecl(quote(class AuditShape <: AuditBase {}))
    declaration.upperBound = parentTemplate.upperBound
    declaration.superTypes = parentTemplate.superTypes
    let overrideTemplate = FuncDecl(quote(public override func build(): String { "" }))
    for (member in declaration.body.decls) {
        if (let Some(method) <- (member as FuncDecl)) {
            if (method.identifier.value == "build") {
                method.modifiers = overrideTemplate.modifiers
            }
        }
    }
    declaration.body.decls.add(parseDecl(quote(
        public init() { super(); finishConstruction() }
    )))
    declaration.toTokens()
}

public macro BoxState(input: Tokens): Tokens {
    let field = VarDecl(input)
    let name = field.identifier
    let storage = cangjieLex("_box_" + name.value)
    let fieldType = field.declType.toTokens()
    let initial = field.expr.toTokens()
    quote(
        private let $(storage) = AuditState<$(fieldType)>($(initial))
        public mut prop $(name): $(fieldType) {
            get() { $(storage).get() }
            set(value) { $(storage).set(value) }
        }
    )
}
