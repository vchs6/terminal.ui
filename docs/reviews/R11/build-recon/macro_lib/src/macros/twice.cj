macro package macro_lib.macros
import std.ast.*
public macro Twice(input: Tokens): Tokens { quote(($(input)) * 2) }
