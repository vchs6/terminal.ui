macro package cjtui.macros

import std.ast.*

public macro Bind(input: Tokens): Tokens { quote({ => $(input) }) }
