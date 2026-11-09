package dependency_probe
// Evaluates imported Unicode algorithms; does not render a terminal UI.
import unicode.UnicodeWidth
import unicode.GraphemeIterator
import unicode.Codepoint
import unicode.types.NormalizationForm
func count(value: String): Int64 {
    let iterator = GraphemeIterator(value)
    var count: Int64 = 0
    while (true) {
        match (iterator.next()) {
            case None => break
            case Some(cluster) => count++
        }
    }
    return count
}
main(): Int64 {
    let values = ["ABC", "中文", "é", "👩‍💻", "👍🏽", "\u{2764}\u{FE0F}", "🇨🇳", "·", ""]
    let names = ["ascii", "cjk", "combining", "zwj", "skin-tone", "heart-vs16", "flag", "ambiguous", "empty"]
    let expectedCounts = [3, 2, 1, 1, 1, 1, 1, 1, 0]
    for (i in 0..values.size) {
        let value = values[i]
        println("${names[i]} width=${value.width()} graphemes=${count(value)}")
        if (i < 8 && count(value) != expectedCounts[i]) { return 1 }
    }
    let normalized = Codepoint.normalize(UInt32(r'é'.position()), form: NormalizationForm.NFD)
    if (normalized.size != 2 || normalized[0] != UInt32(r'e'.position()) || normalized[1] != 0x301) { return 1 }
    println("PASS eight representative non-empty grapheme counts and NFD decomposition")
    println("KNOWN GAP empty input emits one empty grapheme; heart/flag widths are 1")
    return 0
}
