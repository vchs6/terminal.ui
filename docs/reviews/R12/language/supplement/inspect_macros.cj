macro package audit_supplement_macros
import std.ast.*

public macro Inspect(input: Tokens): Tokens {
    let declaration = ClassDecl(input)
    for (member in declaration.body.decls) {
        println("AST member keyword=" + member.keyword.value)
        println("AST member FuncDecl=" + (member is FuncDecl).toString() + " PrimaryCtorDecl=" + (member is PrimaryCtorDecl).toString())
    }
    input
}
