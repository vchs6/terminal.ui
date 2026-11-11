package toml_probe
import cangjie_toml.cangjie_toml.lexer.*
import cangjie_toml.cangjie_toml.parser.*
main(): Unit {
    let p = Parser("")
    let token = Token(TokenType.StringEsc, "\\u0061", Position(1, 0, 6))
    println(p.keyString(token))
}
