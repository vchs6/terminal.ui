macro package cjtui.macros

import std.ast.*

class ConstructorReturnVisitor <: Visitor {
    var found = false
    protected override func visit(_: LambdaExpr): Unit { breakTraverse() }
    protected override func visit(_: FuncDecl): Unit { breakTraverse() }
    protected override func visit(_: ReturnExpr): Unit { found = true }
}
