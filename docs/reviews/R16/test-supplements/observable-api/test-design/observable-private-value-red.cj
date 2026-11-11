package glyph_observable_control
import cjtui.*
main(): Int64 {
    let text = Observable<String>("中")
    text.value = "文"
    println(text.value)
    return 0
}
