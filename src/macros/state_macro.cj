macro package cjtui.macros

import std.ast.*

public macro State(input: Tokens): Tokens {
    assertParentContext("Component")
    let field = VarDecl(input)
    if (field.keyword.value != "var") {
        diagReport(DiagReportLevel.ERROR, input, "STATE_MUTABLE: State requires var", "use a mutable instance field")
        return input
    }
    if (field.annotations.size > 0) {
        diagReport(DiagReportLevel.ERROR, input, "STATE_DUPLICATE: State cannot be repeated", "remove repeated annotations")
        return input
    }
    let name = field.identifier
    let storage = cangjieLex("_state_" + name.value)
    let fieldType = field.declType.toTokens()
    let initial = field.expr.toTokens()
    var visibility = quote()
    for (modifier in field.modifiers) {
        let value = modifier.keyword.value
        if (value == "public" || value == "protected" || value == "private" || value == "internal") {
            visibility = modifier.toTokens()
        }
        if (value == "static") {
            diagReport(DiagReportLevel.ERROR, input, "STATE_STATIC: state must be an instance variable", "remove static")
            return input
        }
    }
    if (fieldType.size == 0 || initial.size == 0) {
        diagReport(DiagReportLevel.ERROR, input, "STATE_DECLARATION: explicit type and initializer required", "declare a typed var with an initializer")
        return input
    }
    quote(
        private let $(storage) = cjtui.Observable<$(fieldType)>($(initial))
        $(visibility) mut prop $(name): $(fieldType) {
            get() { $(storage).get() }
            set(value) { $(storage).set(value) }
        }
    )
}
