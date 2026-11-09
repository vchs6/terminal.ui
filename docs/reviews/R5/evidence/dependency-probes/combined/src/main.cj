package combined_probe
// Import only segmentation/normalization from unicode, never UnicodeWidth.
import unicode.{GraphemeIterator, Codepoint}
import unicode.types.NormalizationForm
import unicodewidth.StringWidth
main(): Int64 {
    let sample = "中é👩‍💻\u{2764}\u{FE0F}🇨🇳"
    let iterator = GraphemeIterator(sample)
    var count: Int64 = 0
    var summedWidth: UInt64 = 0
    while (true) {
        match (iterator.next()) {
            case None => break
            case Some(cluster) =>
                summedWidth += cluster.toString().width()
                count++
        }
    }
    let wholeWidth = sample.width()
    let normalized = Codepoint.normalize(UInt32(r'é'.position()), form: NormalizationForm.NFD)
    if (count != 5 || summedWidth != 9 || wholeWidth != 9 || normalized.size != 2 || normalized[0] != UInt32(r'e'.position()) || normalized[1] != 0x301) { return 1 }
    println("PASS combined imports: graphemes=${count}, per-cluster-width=${summedWidth}, whole-width=${wholeWidth}, NFD-size=${normalized.size}")
    println("LIMIT this sample does not establish universal width additivity across all grapheme boundaries")
    return 0
}
