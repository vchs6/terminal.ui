package cjtui.theme

import cangjie_toml.cangjie_toml.lexer.*
import std.collection.ArrayList

// Structural budget over the upstream token stream; no TOML values are decoded.
func checkThemeBudget(input: String, source: String): Unit {
    if (input.size > 1048576) { throw themeFailure("CapacityExceeded", source, "", "theme exceeds byte budget") }
    let lexer = Lexer(input)
    let stack = ArrayList<Int64>()
    var table: Int64 = 0
    var current: Int64 = 0
    var segments: Int64 = 0
    var inTable = false
    var inKey = false
    var tokens: Int64 = 0
    var declarations: Int64 = 0
    while (true) {
        let token = lexer.nextToken()
        let kind = token.tokenType
        if (kind == TokenType.EOF) { break }
        tokens++
        if (kind == TokenType.KeyStart || kind == TokenType.TableStart || kind == TokenType.ArrayTableStart) {
            declarations++
        }
        if (tokens > 65536 || declarations > 16384) { throw budgetAt(input, source, token, "token or declaration budget exceeded") }
        // Parser supplies its accumulated key path for lexical failures.
        // It stops on this same token; no deeper input reaches recursive parsing.
        if (kind == TokenType.Err) { break }
        if (kind == TokenType.TableStart || kind == TokenType.ArrayTableStart) {
            inTable = true; segments = 0
        } else if (kind == TokenType.TableEnd || kind == TokenType.ArrayTableEnd) {
            table = segments; current = table; inTable = false
        } else if (kind == TokenType.KeyStart) {
            inKey = true; segments = 0
        } else if (kind == TokenType.KeyEnd) {
            inKey = false
            current = (if (stack.size == 0) { table } else { stack[stack.size - 1] }) + segments
            if (current > 16) { throw budgetAt(input, source, token, "effective key path budget exceeded") }
        } else if (inTable || inKey) {
            segments++
            if (token.value.size > 1024) { throw budgetAt(input, source, token, "key segment budget exceeded") }
            let prefix = if (inTable) { 0 } else if (stack.size == 0) { table } else { stack[stack.size - 1] }
            if (prefix + segments > 16) { throw budgetAt(input, source, token, "effective key path budget exceeded") }
        } else if (kind == TokenType.ArrayStart || kind == TokenType.InlineTableStart) {
            stack.add(current)
            if (stack.size > 16) { throw budgetAt(input, source, token, "container depth budget exceeded") }
        } else if (kind == TokenType.ArrayEnd || kind == TokenType.InlineTableEnd) {
            if (stack.size > 0) { current = stack.remove(at: stack.size - 1) }
        }
    }
}

func budgetAt(input: String, source: String, token: Token, message: String): ThemeException {
    let p = token.position.withCol(input.toRuneArray())
    let loc = ThemeLocation(p.line, p.col, p.start, p.len)
    ThemeException(ThemeDiagnostic("CapacityExceeded", source, "", message, Some(loc), "value"))
}
func themeFailure(code: String, source: String, path: String, message: String): ThemeException {
    ThemeException(ThemeDiagnostic(code, source, path, message, Option<ThemeLocation>.None, "unavailable"))
}
