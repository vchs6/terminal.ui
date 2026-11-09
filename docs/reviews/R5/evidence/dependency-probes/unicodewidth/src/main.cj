package width_probe
import unicodewidth.*
main(): Int64 {
    let values = ["ABC", "中文", "é", "👩‍💻", "👍🏽", "\u{2764}\u{FE0F}", "🇨🇳", "·", ""]
    let names = ["ascii", "cjk", "combining", "zwj", "skin-tone", "heart-vs16", "flag", "ambiguous", "empty"]
    let expected = [3u64, 4u64, 1u64, 2u64, 2u64, 2u64, 2u64, 1u64, 0u64]
    for (i in 0..values.size) {
        let width = values[i].width()
        println("${names[i]} width=${width}")
        if (width != expected[i]) { return 1 }
    }
    if ("·".widthCjk() != 2) { return 1 }
    println("ambiguous-cjk width=2")
    println("PASS nine representative cases and configurable ambiguous width")
    return 0
}
