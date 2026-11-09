package slice_native_smoke
import cjtui.*
func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
    println("PASS: ${name}")
}
main(): Int64 {
    check(graphemeClusters("").size == 0, "empty has no clusters")
    check(displayWidth("") == 0, "empty width")
    let cjk = graphemeClusters("中文")
    check(cjk.size == 2 && cjk[0] == "中" && cjk[1] == "文", "CJK segmentation")
    check(displayWidth("中文") == 4, "CJK columns")
    let combining = graphemeClusters("e\u{301}")
    check(combining.size == 1 && combining[0] == "e\u{301}", "combining EGC")
    check(displayWidth("e\u{301}") == 1, "combining width")
    let emoji = graphemeClusters("👩‍💻🇨🇳")
    check(emoji.size == 2 && emoji[0] == "👩‍💻" && emoji[1] == "🇨🇳", "ZWJ and flag EGC")
    check(displayWidth("👩‍💻") == 2 && displayWidth("🇨🇳") == 2, "emoji columns")
    check(displayWidth("·") == 1 && displayWidth("·", ambiguousWide: true) == 2, "ambiguous width policy")
    return 0
}
