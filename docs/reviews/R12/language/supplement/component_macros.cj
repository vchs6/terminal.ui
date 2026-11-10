macro package audit_component_macros

import std.ast.*
import std.collection.ArrayList

// Language probe only. It preserves generic parameters and existing interface
// nodes, instruments nondelegating constructors, and explicitly rejects return.
public macro Component(input: Tokens): Tokens {
    let declaration = ClassDecl(input)
    let template = ClassDecl(quote(class Shape <: AuditBase {}))
    let oldParents = declaration.superTypes
    let newParents = ArrayList<TypeNode>()
    newParents.add(template.superTypes[0])
    var joins = quote()
    for (parent in oldParents) {
        newParents.add(parent)
        joins = quote($(joins) &)
    }
    declaration.upperBound = template.upperBound
    declaration.superTypes = newParents
    declaration.superTypeBitAnds = joins

    let overrideTemplate = FuncDecl(quote(public override func build(): Unit {}))
    var constructorCount: Int64 = 0
    for (member in declaration.body.decls) {
        if (let Some(method) <- (member as FuncDecl)) {
            if (method.keyword.value == "init") {
                constructorCount++
                for (token in method.block.toTokens()) {
                    if (token.kind == TokenKind.RETURN) {
                        diagReport(DiagReportLevel.ERROR, quote($(token)),
                            "AUDIT_INIT_RETURN: constructor return requires control-flow instrumentation; this probe rejects it",
                            "return in constructor is unsupported by this probe")
                        return input
                    }
                }
                let nodes = ArrayList<Node>()
                nodes.add(parseExpr(quote(super())))
                for (node in method.block.nodes) { nodes.add(node) }
                nodes.add(parseExpr(quote(finishConstruction())))
                method.block.nodes = nodes
            } else if (method.identifier.value == "build") {
                method.modifiers = overrideTemplate.modifiers
            }
        }
    }
    if (constructorCount == 0) {
        declaration.body.decls.add(parseDecl(quote(
            public init() { super(); finishConstruction() }
        )))
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
        private let $(storage) = Observable<$(fieldType)>($(initial))
        public mut prop $(name): $(fieldType) {
            get() { $(storage).get() }
            set(value) { $(storage).set(value) }
        }
    )
}

public macro Bind(input: Tokens): Tokens { quote({ => $(input) }) }
