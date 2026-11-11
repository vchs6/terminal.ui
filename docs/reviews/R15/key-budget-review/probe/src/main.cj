package toml_probe
import std.fs.*
import cangjie_toml.cangjie_toml.lexer.*
main(args: Array<String>): Int64 {
    let input = String.fromUtf8(File.readFrom(args[0]))
    let lexer = Lexer(input)
    var index = 0
    while (true) {
        let token = lexer.nextToken()
        let payload = StringBuilder()
        for (b in token.value.toArray()) {
            payload.append("${b},")
        }
        println("${index}\t${token.tokenType}\t${token.value.size}\t${token.value.toArray().size}\t${token.position.line}\t${token.position.start}\t${token.position.len}\t${payload}")
        index++
        if (token.tokenType == TokenType.EOF) { return 0 }
        if (token.tokenType == TokenType.Err) { return 2 }
    }
    return 3
}
