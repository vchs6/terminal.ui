package toml_probe
import cangjie_toml.cangjie_toml.parser.*
main(): Unit {
    let p = Parser("")
    println(p.replaceEscapes("\\u0061"))
}
