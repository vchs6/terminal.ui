macro package cjtui.macros

import std.ast.*
import std.collection.ArrayList

public macro Component(input: Tokens): Tokens {
    let declaration = ClassDecl(input)
    for (modifier in declaration.modifiers) {
        if (modifier.keyword.value == "open" || modifier.keyword.value == "abstract") {
            diagReport(DiagReportLevel.ERROR, modifier.toTokens(), "COMPONENT_MODIFIER: open or abstract component unsupported", "remove the modifier")
            return input
        }
    }
    for (token in declaration.body.toTokens()) {
        if (token.value == "finishConstruction") {
            diagReport(DiagReportLevel.ERROR, quote($(token)), "COMPONENT_RESERVED: finishConstruction is reserved", "remove the explicit member or call")
            return input
        }
    }
    let template = ClassDecl(quote(class Shape <: cjtui.Component {}))
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
                var prior = ""
                for (token in method.block.toTokens()) {
                    if (prior == "this" && token.value == "(") {
                        diagReport(DiagReportLevel.ERROR, quote($(token)), "COMPONENT_INIT_DELEGATION: delegating constructors are unsupported", "remove this constructor call")
                        return input
                    }
                    prior = token.value
                }
                let checker = ConstructorReturnVisitor()
                method.block.traverse(checker)
                if (checker.found) {
                    diagReport(DiagReportLevel.ERROR, method.block.toTokens(), "COMPONENT_INIT_RETURN: direct constructor return is unsupported", "remove return")
                    return input
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
